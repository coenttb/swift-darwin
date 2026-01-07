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
    internal import Darwin

    extension Kernel.Kqueue {
        /// Filter types determining what conditions trigger kqueue events.
        ///
        /// Each event in kqueue is associated with a filter that defines what
        /// condition is being monitored. Common filters include descriptor
        /// readiness (`.read`, `.write`) and user-triggered events (`.user`).
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Monitor for read readiness
        /// let event = Kernel.Kqueue.Event(
        ///     ident: UInt(fd.rawValue),
        ///     filter: .read,
        ///     flags: [.add, .enable],
        ///     fflags: [],
        ///     data: 0,
        ///     udata: nil
        /// )
        /// try Kernel.Kqueue.register(kq, events: [event])
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue/Flags``
        /// - ``Kernel/Kqueue/Event``
        public struct Filter: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: Int16

            public init(rawValue: Int16) {
                self.rawValue = rawValue
            }
        }
    }

    extension Kernel.Kqueue.Filter {
        /// Monitors a descriptor for read readiness.
        ///
        /// Triggers when data is available to read from the descriptor.
        /// For sockets, also triggers on connection close (EOF). The `data`
        /// field in returned events contains the number of bytes available.
        ///
        /// - Darwin: `EVFILT_READ`
        public static let read = Self(rawValue: Int16(EVFILT_READ))

        /// Monitors a descriptor for write readiness.
        ///
        /// Triggers when the descriptor can accept writes without blocking.
        /// The `data` field in returned events contains the amount of space
        /// available in the write buffer.
        ///
        /// - Darwin: `EVFILT_WRITE`
        public static let write = Self(rawValue: Int16(EVFILT_WRITE))

        /// User-defined event for inter-thread signaling.
        ///
        /// Allows manual triggering of events without I/O. Useful for
        /// waking up an event loop from another thread. Use `EV_TRIGGER`
        /// in fflags to fire the event.
        ///
        /// - Darwin: `EVFILT_USER`
        public static let user = Self(rawValue: Int16(EVFILT_USER))
    }

#endif
