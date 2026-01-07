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

    extension Kernel.Kqueue {
        /// Errors from kqueue operations.
        ///
        /// Low-level errors from kqueue syscalls. Each case wraps the
        /// underlying `Kernel.Error.Code` for platform-specific details.
        /// Convert to `Kernel.Error` for semantic error handling.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// do {
        ///     let kq = try Kernel.Kqueue.create()
        /// } catch let error as Kernel.Kqueue.Error {
        ///     switch error {
        ///     case .create(let code):
        ///         print("kqueue creation failed: \(code)")
        ///     case .interrupted:
        ///         // Retry the operation
        ///     default:
        ///         throw Kernel.Error(error)
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Kqueue``
        /// - ``Kernel/Error``
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Failed to create a kqueue instance.
            ///
            /// Returned by `kqueue()` syscall. Common causes: process
            /// has too many open file descriptors, system limit reached.
            case create(Kernel.Error.Code)

            /// Failed to register, modify, or query events.
            ///
            /// Returned by `kevent()` syscall. Common causes: invalid
            /// kqueue descriptor, bad event specification, invalid filter.
            case kevent(Kernel.Error.Code)

            /// Operation was interrupted by a signal.
            ///
            /// The operation should typically be retried.
            case interrupted
        }
    }

    extension Kernel.Kqueue.Error: CustomStringConvertible {
        public var description: String {
            switch self {
            case .create(let code):
                return "kqueue creation failed (\(code))"
            case .kevent(let code):
                return "kevent failed (\(code))"
            case .interrupted:
                return "operation interrupted"
            }
        }
    }

#endif
