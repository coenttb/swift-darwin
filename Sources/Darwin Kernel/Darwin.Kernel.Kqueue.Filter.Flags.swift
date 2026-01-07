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

    extension Kernel.Kqueue.Filter {
        /// Filter-specific flags for kqueue events.
        ///
        /// These flags (stored in the `fflags` field) provide filter-specific
        /// configuration. The meaning depends on the filter type being used.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // User events: trigger immediately
        /// let event = Kernel.Kqueue.Event(
        ///     id: Kernel.Event.ID(userEventId),
        ///     filter: .user,
        ///     flags: [.add, .enable],
        ///     fflags: .trigger
        /// )
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue/Event``
        /// - ``Kernel/Kqueue/Filter``
        public struct Flags: Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Kernel.Kqueue.Filter.Flags {
        /// Triggers the user event immediately.
        ///
        /// Used with `EVFILT_USER` to cause the event to be delivered
        /// to the kqueue. The event will appear in the next `kevent()` call.
        ///
        /// - Darwin: `NOTE_TRIGGER`
        public static let trigger = Self(rawValue: UInt32(NOTE_TRIGGER))

        /// No filter flags.
        public static let none = Self(rawValue: 0)

        /// Combines multiple filter flags.
        @inlinable
        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Checks if this contains another filter flag.
        @inlinable
        public func contains(_ other: Self) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }
    }

#endif
