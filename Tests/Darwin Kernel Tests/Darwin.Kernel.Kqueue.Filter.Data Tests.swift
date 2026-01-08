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

#if canImport(Darwin)
    import Darwin
    import StandardsTestSupport
    import Testing

    import Kernel_Primitives
    @testable import Darwin_Kernel

    // Kernel.Kqueue.Filter.Data is a typealias to Tagged<Kernel.Kqueue.Filter, Int>
    // Use a custom test suite since #TestSuites cannot be used on typealiases

    @Suite("Kernel.Kqueue.Filter.Data Tests")
    struct KqueueFilterDataTests {

        // MARK: - Unit Tests

        @Test("zero constant equals 0")
        func zeroConstant() {
            let zero = Kernel.Kqueue.Filter.Data.zero
            #expect(zero == 0)
        }

        @Test("init from Int stores value")
        func initFromInt() {
            let data = Kernel.Kqueue.Filter.Data(42)
            #expect(data == 42)
        }

        @Test("literal initialization works")
        func literalInit() {
            let data: Kernel.Kqueue.Filter.Data = 100
            #expect(data == 100)
        }

        @Test("negative values are preserved")
        func negativeValues() {
            let data = Kernel.Kqueue.Filter.Data(-1)
            #expect(data == -1)
        }

        // MARK: - Conformance Tests

        @Test("Data is Sendable")
        func isSendable() {
            let data: any Sendable = Kernel.Kqueue.Filter.Data.zero
            #expect(data is Kernel.Kqueue.Filter.Data)
        }

        @Test("Data is Equatable")
        func isEquatable() {
            let a = Kernel.Kqueue.Filter.Data(42)
            let b = Kernel.Kqueue.Filter.Data(42)
            let c = Kernel.Kqueue.Filter.Data(0)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Data is Hashable")
        func isHashable() {
            var set = Set<Kernel.Kqueue.Filter.Data>()
            set.insert(Kernel.Kqueue.Filter.Data(1))
            set.insert(Kernel.Kqueue.Filter.Data(2))
            set.insert(Kernel.Kqueue.Filter.Data(1))  // duplicate
            #expect(set.count == 2)
        }

        // MARK: - Edge Cases

        @Test("Int.max is preserved")
        func intMaxPreserved() {
            let data = Kernel.Kqueue.Filter.Data(Int.max)
            #expect(data.rawValue == Int.max)
        }

        @Test("Int.min is preserved")
        func intMinPreserved() {
            let data = Kernel.Kqueue.Filter.Data(Int.min)
            #expect(data.rawValue == Int.min)
        }
    }
#endif
