// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Primitives
public import Darwin_Primitives

extension Darwin_Primitives.Darwin {
    /// Darwin kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives.Kernel`, allowing Darwin-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Darwin-specific syscall wrappers for:
    /// - kqueue event notification
    /// - Shared memory (shm_open with variadic workaround)
    /// - Darwin-specific dlopen flags (RTLD_MAIN_ONLY, RTLD_FIRST)
    public typealias Kernel = Kernel_Primitives.Kernel
}
