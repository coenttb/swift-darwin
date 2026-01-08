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

public import Darwin_Primitives
public import Kernel_Primitives
import POSIX_Kernel

/// Re-export Kernel namespace from primitives for use within Darwin module.
public typealias Kernel = Kernel_Primitives.Kernel

/// Re-export Darwin namespace from Darwin_Primitives.
public typealias Darwin = Darwin_Primitives.Darwin
