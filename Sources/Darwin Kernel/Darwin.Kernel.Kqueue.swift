// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//
public import Kernel_Primitives

#if canImport(Darwin)
    public import Darwin

    /// Type alias for C kevent struct to avoid ambiguity with Swift kevent method.
    internal typealias CKevent = kevent

    extension Kernel {
        /// Raw kqueue syscall wrappers (Darwin only).
        ///
        /// Kqueue is the kernel event notification mechanism on macOS/BSD.
        /// This namespace provides policy-free syscall wrappers.
        ///
        /// Higher layers (swift-io) build registration management,
        /// ID tracking, and event dispatch on top of these primitives.
        ///
        /// ## Threading
        ///
        /// All syscall wrappers are thread-safe at the kernel level. The kqueue
        /// descriptor can be shared across threads, but concurrent registration
        /// and polling should be coordinated by the caller.
        ///
        /// ## Blocking
        ///
        /// `poll()` and `kevent()` block the calling thread until events arrive
        /// or the timeout expires. Use from a dedicated thread or blocking executor,
        /// not from Swift's cooperative thread pool.
        ///
        /// ## Cancellation
        ///
        /// No native cancellation support. For async contexts, use short timeouts
        /// and check `Task.isCancelled` between polls.
        ///
        /// ## Lifecycle
        ///
        /// The kqueue descriptor must be closed via `Kernel.Close.close(_:)` when
        /// no longer needed. Leaking descriptors exhausts process file descriptor
        /// limits. Use `defer` for cleanup.
        public enum Kqueue {}
    }

    // MARK: - Syscalls

    // Import kevent function explicitly (avoiding conflict with kevent struct)
    @_silgen_name("kevent")
    internal func _kevent(
        _ kq: Int32,
        _ changelist: UnsafePointer<kevent>?,
        _ nchanges: Int32,
        _ eventlist: UnsafeMutablePointer<kevent>?,
        _ nevents: Int32,
        _ timeout: UnsafePointer<timespec>?
    ) -> Int32

    extension Kernel.Kqueue {
        /// Creates a new kqueue descriptor.
        ///
        /// - Returns: A file descriptor for the new kqueue.
        /// - Throws: `Error.create` if kqueue creation fails.
        public static func create() throws(Kernel.Kqueue.Error) -> Kernel.Descriptor {
            let kq = kqueue()
            guard kq >= 0 else {
                throw .create(.captureErrno())
            }
            return Kernel.Descriptor(rawValue: kq)
        }

        /// Registers events and/or waits for events.
        ///
        /// This is the raw kevent syscall. It can:
        /// - Register new events (changelist)
        /// - Wait for events (eventlist)
        /// - Both simultaneously
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - changelist: Events to register/modify, or `nil`.
        ///   - nchanges: Number of events in changelist.
        ///   - eventlist: Buffer for returned events, or `nil`.
        ///   - nevents: Size of eventlist buffer.
        ///   - timeout: Timeout for waiting, or `nil` for infinite.
        /// - Returns: Number of events placed in eventlist.
        /// - Throws: `Error.kevent` on failure, `Error.interrupted` on EINTR.
        public static func kevent(
            _ kq: Kernel.Descriptor,
            changelist: UnsafePointer<kevent>?,
            nchanges: Int32,
            eventlist: UnsafeMutablePointer<kevent>?,
            nevents: Int32,
            timeout: UnsafePointer<timespec>?
        ) throws(Kernel.Kqueue.Error) -> Int {
            let result = _kevent(kq.rawValue, changelist, nchanges, eventlist, nevents, timeout)
            guard result >= 0 else {
                let code = Kernel.Error.Code.captureErrno()
                if code.posix == EINTR {
                    throw .interrupted
                }
                throw .kevent(code)
            }
            return Int(result)
        }

        /// Registers events and/or waits for events (buffer pointer variant).
        ///
        /// Convenience wrapper that takes buffer pointers instead of raw pointers.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - changelist: Events to register/modify.
        ///   - eventlist: Buffer for returned events.
        ///   - timeout: Timeout for waiting, or `nil` for infinite.
        /// - Returns: Number of events placed in eventlist.
        /// - Throws: `Error.kevent` on failure, `Error.interrupted` on EINTR.
        public static func kevent(
            _ kq: Kernel.Descriptor,
            changelist: UnsafeBufferPointer<kevent>,
            eventlist: UnsafeMutableBufferPointer<kevent>,
            timeout: UnsafePointer<timespec>?
        ) throws(Kernel.Kqueue.Error) -> Int {
            try kevent(
                kq,
                changelist: changelist.baseAddress,
                nchanges: Int32(changelist.count),
                eventlist: eventlist.baseAddress,
                nevents: Int32(eventlist.count),
                timeout: timeout
            )
        }

        /// Registers events without waiting.
        ///
        /// Convenience wrapper for registration-only operations.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - changelist: Events to register/modify.
        /// - Throws: `Error.kevent` on failure.
        public static func register(
            _ kq: Kernel.Descriptor,
            changelist: UnsafeBufferPointer<kevent>
        ) throws(Kernel.Kqueue.Error) {
            _ = try kevent(
                kq,
                changelist: changelist.baseAddress,
                nchanges: Int32(changelist.count),
                eventlist: nil,
                nevents: 0,
                timeout: nil
            )
        }

        /// Waits for events without registering.
        ///
        /// Convenience wrapper for poll-only operations.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - eventlist: Buffer for returned events.
        ///   - timeout: Timeout for waiting, or `nil` for infinite.
        /// - Returns: Number of events placed in eventlist.
        /// - Throws: `Error.kevent` on failure, `Error.interrupted` on EINTR.
        public static func poll(
            _ kq: Kernel.Descriptor,
            eventlist: UnsafeMutableBufferPointer<kevent>,
            timeout: UnsafePointer<timespec>?
        ) throws(Kernel.Kqueue.Error) -> Int {
            try kevent(
                kq,
                changelist: nil,
                nchanges: 0,
                eventlist: eventlist.baseAddress,
                nevents: Int32(eventlist.count),
                timeout: timeout
            )
        }
    }

    // MARK: - Duration Convenience

    extension Kernel.Kqueue {
        /// Waits for events with a Duration timeout.
        ///
        /// Convenience wrapper that converts Duration to timespec.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - eventlist: Buffer for returned events.
        ///   - timeout: Timeout duration, or `nil` for infinite.
        /// - Returns: Number of events placed in eventlist.
        /// - Throws: `Error.kevent` on failure, `Error.interrupted` on EINTR.
        public static func poll(
            _ kq: Kernel.Descriptor,
            eventlist: UnsafeMutableBufferPointer<kevent>,
            timeout: Duration?
        ) throws(Kernel.Kqueue.Error) -> Int {
            if var ts = Kernel.Time.timespec(from: timeout) {
                return try poll(kq, eventlist: eventlist, timeout: &ts)
            } else {
                let nilTimeout: UnsafePointer<timespec>? = nil
                return try poll(kq, eventlist: eventlist, timeout: nilTimeout)
            }
        }
    }

    // MARK: - Swift-Native Event API

    extension Kernel.Kqueue {
        /// Registers events without waiting (Swift-native interface).
        ///
        /// Takes Swift `Event` structs instead of raw `kevent`.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - events: Array of events to register/modify.
        /// - Throws: `Error.kevent` on failure.
        public static func register(
            _ kq: Kernel.Descriptor,
            events: [Event]
        ) throws(Kernel.Kqueue.Error) {
            guard !events.isEmpty else { return }

            // Convert Swift events to C events using stack allocation
            let outcome: Result<Void, Kernel.Kqueue.Error> = withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: events.count
            ) { (buffer: UnsafeMutableBufferPointer<CKevent>) -> Result<Void, Kernel.Kqueue.Error> in
                for i in 0..<events.count {
                    buffer[i] = events[i].cValue
                }
                let result = _kevent(
                    kq.rawValue,
                    buffer.baseAddress,
                    Int32(events.count),
                    nil,
                    0,
                    nil
                )
                guard result >= 0 else {
                    let code = Kernel.Error.Code.captureErrno()
                    if code.posix == EINTR {
                        return .failure(.interrupted)
                    }
                    return .failure(.kevent(code))
                }
                return .success(())
            }
            try outcome.get()
        }

        /// Waits for events (Swift-native interface).
        ///
        /// Takes a Swift `[Event]` buffer instead of raw `kevent`.
        ///
        /// - Parameters:
        ///   - kq: The kqueue descriptor.
        ///   - events: Buffer for returned events (pre-sized).
        ///   - timeout: Timeout duration, or `nil` for infinite.
        /// - Returns: Number of events written to buffer.
        /// - Throws: `Error.kevent` on failure, `Error.interrupted` on EINTR.
        public static func poll(
            _ kq: Kernel.Descriptor,
            into events: inout [Event],
            timeout: Duration?
        ) throws(Kernel.Kqueue.Error) -> Int {
            guard !events.isEmpty else { return 0 }

            let count = events.count
            var pollError: Error? = nil
            var eventCount = 0

            withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: count
            ) { (buffer: UnsafeMutableBufferPointer<CKevent>) in
                do {
                    if var ts = Kernel.Time.timespec(from: timeout) {
                        eventCount = try kevent(
                            kq,
                            changelist: nil,
                            nchanges: 0,
                            eventlist: buffer.baseAddress,
                            nevents: Int32(count),
                            timeout: &ts
                        )
                    } else {
                        let nilTimeout: UnsafePointer<timespec>? = nil
                        eventCount = try kevent(
                            kq,
                            changelist: nil,
                            nchanges: 0,
                            eventlist: buffer.baseAddress,
                            nevents: Int32(count),
                            timeout: nilTimeout
                        )
                    }

                    // Convert C events to Swift events
                    for i in 0..<eventCount {
                        events[i] = Event(buffer[i])
                    }
                } catch let error as Error {
                    pollError = error
                } catch {
                    // Should never reach here with typed throws
                }
            }

            if let error = pollError {
                throw error
            }
            return eventCount
        }
    }

#endif
