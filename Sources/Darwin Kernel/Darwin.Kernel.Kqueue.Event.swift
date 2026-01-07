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

    extension Kernel.Kqueue {
        /// A kqueue event describing an event source and its state.
        ///
        /// Events are used both for registering interest (input) and receiving
        /// notifications (output). When registering, you specify what to monitor;
        /// when receiving, you get details about what happened.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Register interest in read events on a socket
        /// let event = Kernel.Kqueue.Event(
        ///     id: Kernel.Event.ID(socketFd.rawValue),
        ///     filter: .read,
        ///     flags: [.add, .enable]
        /// )
        /// try Kernel.Kqueue.kevent(kq, changes: [event], events: &results)
        ///
        /// // Process returned events
        /// for event in results {
        ///     if event.filter == .read {
        ///         let bytesAvailable = event.filterData
        ///         // Read from event.id
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue``
        /// - ``Kernel/Kqueue/Filter``
        /// - ``Kernel/Kqueue/Flags``
        public struct Event: Sendable, Equatable, Hashable {
            /// Identifier for this event.
            ///
            /// The meaning depends on the filter type:
            /// - `EVFILT_READ`, `EVFILT_WRITE`: file descriptor
            /// - `EVFILT_SIGNAL`: signal number
            /// - `EVFILT_PROC`: process ID
            public var id: Kernel.Event.ID

            /// Filter type (EVFILT_READ, EVFILT_WRITE, etc.).
            public var filter: Filter

            /// Action and status flags (EV_ADD, EV_DELETE, etc.).
            public var flags: Flags

            /// Filter-specific flags.
            public var fflags: Filter.Flags

            /// Filter-specific data (e.g., bytes available for read).
            public var filterData: Filter.Data

            /// User-defined data for event routing.
            ///
            /// Typically stores an ID to dispatch the event to the correct handler.
            public var data: Data

            /// Creates a kqueue event.
            ///
            /// - Parameters:
            ///   - id: Event source identifier.
            ///   - filter: Filter type.
            ///   - flags: Action and behavior flags.
            ///   - fflags: Filter-specific flags.
            ///   - filterData: Filter-specific data.
            ///   - data: User-defined routing data.
            public init(
                id: Kernel.Event.ID,
                filter: Filter,
                flags: Flags,
                fflags: Filter.Flags = .none,
                filterData: Filter.Data = .zero,
                data: Data = .zero
            ) {
                self.id = id
                self.filter = filter
                self.flags = flags
                self.fflags = fflags
                self.filterData = filterData
                self.data = data
            }
        }
    }

    // MARK: - Darwin Conversion

    extension Kernel.Kqueue.Event {
        /// Creates an Event from the Darwin kevent struct.
        internal init(_ cEvent: kevent) {
            self.id = Kernel.Event.ID(cEvent.ident)
            self.filter = Kernel.Kqueue.Filter(rawValue: cEvent.filter)
            self.flags = Kernel.Kqueue.Flags(rawValue: cEvent.flags)
            self.fflags = Kernel.Kqueue.Filter.Flags(rawValue: cEvent.fflags)
            self.filterData = Kernel.Kqueue.Filter.Data(cEvent.data)
            self.data = Data(cEvent.udata)
        }

        /// Converts to the Darwin kevent struct.
        internal var cValue: kevent {
            var ev = kevent()
            ev.ident = id.rawValue
            ev.filter = filter.rawValue
            ev.flags = flags.rawValue
            ev.fflags = fflags.rawValue
            ev.data = filterData.rawValue
            ev.udata = UnsafeMutableRawPointer(data)
            return ev
        }
    }

#endif
