public import Dimension
// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//
public import Kernel_Primitives

#if canImport(Darwin)

    extension Kernel.Kqueue.Event {
        /// Opaque data associated with a kqueue event.
        ///
        /// Event data is a 64-bit value that the kernel returns unchanged
        /// when the event fires. This is used to route events to their handlers.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Use as an identifier
        /// let data = Kernel.Kqueue.Event.Data(id)
        ///
        /// // Use with pointer-based context lookup
        /// let data = Kernel.Kqueue.Event.Data(pointer: contextPtr)
        /// ```
        public typealias Data = Tagged<Kernel.Kqueue.Event, UInt64>
    }

    // MARK: - Pointer Conversions

    extension Kernel.Kqueue.Event.Data {
        /// Creates event data from an optional mutable raw pointer.
        ///
        /// This is the canonical conversion from kqueue's `udata` field.
        ///
        /// - Parameter pointer: The pointer from kevent's udata field.
        @inlinable
        public init(_ pointer: UnsafeMutableRawPointer?) {
            self.init(UInt64(UInt(bitPattern: pointer)))
        }

        /// Creates event data from a raw pointer.
        ///
        /// This is useful when you want to associate a context object
        /// with an event.
        ///
        /// - Parameter pointer: A pointer to associate with the event.
        @inlinable
        public init(_ pointer: UnsafeRawPointer) {
            self.init(UInt64(UInt(bitPattern: pointer)))
        }

        /// Creates event data from a typed pointer.
        ///
        /// - Parameter pointer: A pointer to associate with the event.
        @inlinable
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(UInt64(UInt(bitPattern: pointer)))
        }

        /// Creates event data from a mutable typed pointer.
        ///
        /// - Parameter pointer: A mutable pointer to associate with the event.
        @inlinable
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(UInt64(UInt(bitPattern: pointer)))
        }
    }

    // MARK: - Pointer Extraction

    extension UnsafeMutableRawPointer {
        /// Creates a pointer from kqueue event data.
        ///
        /// Returns `nil` if the data value is zero.
        ///
        /// - Parameter data: The event data to convert.
        @inlinable
        public init?(_ data: Kernel.Kqueue.Event.Data) {
            self.init(bitPattern: UInt(data.rawValue))
        }
    }

    // MARK: - Common Values

    extension Kernel.Kqueue.Event.Data {
        /// Zero event data.
        public static let zero: Self = 0
    }

#endif
