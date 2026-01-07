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

    extension Kernel.Kqueue.Filter {
        /// Kernel-returned data from a kqueue event.
        ///
        /// This is an opaque value whose interpretation depends on the filter type.
        /// The kernel populates this field when an event fires.
        ///
        /// ## Filter-Specific Meanings
        ///
        /// | Filter | Data Interpretation |
        /// |--------|---------------------|
        /// | `.read` | Bytes available to read |
        /// | `.write` | Bytes available in write buffer |
        /// | `.timer` | Number of times timer fired |
        /// | `.vnode` | 0 |
        /// | `.proc` | 0 |
        /// | `.signal` | Number of times signal delivered |
        /// | `.user` | User-defined data |
        ///
        /// ## Usage
        ///
        /// ```swift
        /// for event in events {
        ///     if event.filter == .read {
        ///         let bytesAvailable = Int(event.filterData)
        ///         // Read up to bytesAvailable bytes
        ///     }
        /// }
        /// ```
        ///
        /// - Note: Primarily output data. When registering events, use `.zero`.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue/Event``
        /// - ``Kernel/Kqueue/Filter``
        public typealias Data = Tagged<Kernel.Kqueue.Filter, Int>
    }

    // MARK: - Common Values

    extension Kernel.Kqueue.Filter.Data {
        /// Zero filter data (default for event registration).
        public static let zero: Self = 0
    }

#endif
