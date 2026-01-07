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
        /// Action and status flags for kqueue events.
        ///
        /// Flags serve two purposes:
        /// - **Input (action)**: Control event registration (`.add`, `.delete`, `.enable`)
        /// - **Output (status)**: Report conditions in returned events (`.eof`, `.error`)
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Register an edge-triggered read event
        /// let event = Kernel.Kqueue.Event(
        ///     ident: UInt(fd.rawValue),
        ///     filter: .read,
        ///     flags: [.add, .enable, .clear],  // Edge-triggered
        ///     fflags: [],
        ///     data: 0,
        ///     udata: nil
        /// )
        ///
        /// // Check returned event for EOF
        /// if returnedEvent.flags.contains(.eof) {
        ///     // Connection closed
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue/Filter``
        /// - ``Kernel/Kqueue/Event``
        public struct Flags: Sendable, Equatable, Hashable {
            public let rawValue: UInt16

            @inlinable
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Action Flags

    extension Kernel.Kqueue.Flags {
        /// Adds the event to kqueue.
        ///
        /// If the event already exists, this modifies it. Automatically enables
        /// delivery unless `.disable` is also specified.
        ///
        /// - Darwin: `EV_ADD`
        public static let add = Self(rawValue: UInt16(EV_ADD))

        /// Removes the event from kqueue.
        ///
        /// The event is deregistered and will no longer trigger.
        ///
        /// - Darwin: `EV_DELETE`
        public static let delete = Self(rawValue: UInt16(EV_DELETE))

        /// Enables event delivery.
        ///
        /// Events are delivered when their condition triggers. Use after
        /// disabling to resume delivery.
        ///
        /// - Darwin: `EV_ENABLE`
        public static let enable = Self(rawValue: UInt16(EV_ENABLE))

        /// Disables event delivery without removing.
        ///
        /// The event stays registered but won't be returned by kevent.
        /// Useful for temporarily pausing monitoring.
        ///
        /// - Darwin: `EV_DISABLE`
        public static let disable = Self(rawValue: UInt16(EV_DISABLE))
    }

    // MARK: - Behavior Flags

    extension Kernel.Kqueue.Flags {
        /// Enables edge-triggered behavior.
        ///
        /// The event only triggers on state *changes*, not while the condition
        /// persists. After retrieval, the internal state resets. You must fully
        /// drain data or the event won't re-trigger.
        ///
        /// - Darwin: `EV_CLEAR`
        public static let clear = Self(rawValue: UInt16(EV_CLEAR))

        /// Disables the event after delivery.
        ///
        /// Combines with edge-triggered: event triggers once, then disables.
        /// Call with `.enable` to re-arm.
        ///
        /// - Darwin: `EV_DISPATCH`
        public static let dispatch = Self(rawValue: UInt16(EV_DISPATCH))

        /// Deletes the event after delivery.
        ///
        /// One-shot behavior: event triggers once, then is automatically removed.
        ///
        /// - Darwin: `EV_ONESHOT`
        public static let oneshot = Self(rawValue: UInt16(EV_ONESHOT))
    }

    // MARK: - Status Flags (Output Only)

    extension Kernel.Kqueue.Flags {
        /// End-of-file condition detected.
        ///
        /// For sockets: peer closed the connection. For files: read position
        /// at end. Check this in returned events.
        ///
        /// - Darwin: `EV_EOF`
        public static let eof = Self(rawValue: UInt16(EV_EOF))

        /// Error condition on descriptor.
        ///
        /// An error occurred. The `data` field contains the error code.
        ///
        /// - Darwin: `EV_ERROR`
        public static let error = Self(rawValue: UInt16(EV_ERROR))
    }

    // MARK: - Combining

    extension Kernel.Kqueue.Flags {
        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Checks if this contains another flag.
        @inlinable
        public func contains(_ other: Self) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }

        /// Returns an empty set of flags.
        public static let none = Self(rawValue: 0)
    }

#endif
