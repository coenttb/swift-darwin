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

    // Kernel.Kqueue.Event.Data is a typealias to Tagged<Kernel.Kqueue.Event, UInt64>
    // Use a custom test suite since #TestSuites cannot be used on typealiases

    @Suite("Kernel.Kqueue.Event.Data Tests")
    struct KqueueEventDataTests {

        // MARK: - Unit Tests

        @Test("zero constant equals 0")
        func zeroConstant() {
            let zero = Kernel.Kqueue.Event.Data.zero
            #expect(zero == 0)
        }

        @Test("init from UInt64 stores value")
        func initFromUInt64() {
            let data = Kernel.Kqueue.Event.Data(42)
            #expect(data == 42)
        }

        @Test("literal initialization works")
        func literalInit() {
            let data: Kernel.Kqueue.Event.Data = 100
            #expect(data == 100)
        }

        // MARK: - Pointer Conversion Tests

        @Test("init from optional mutable raw pointer preserves bitPattern")
        func initFromOptionalMutableRawPointer() {
            var value: Int = 42
            let pointer: UnsafeMutableRawPointer? = withUnsafeMutablePointer(to: &value) {
                UnsafeMutableRawPointer($0)
            }
            let data = Kernel.Kqueue.Event.Data(pointer)
            #expect(data.rawValue == UInt64(UInt(bitPattern: pointer)))
        }

        @Test("init from nil pointer gives zero")
        func initFromNilPointer() {
            let pointer: UnsafeMutableRawPointer? = nil
            let data = Kernel.Kqueue.Event.Data(pointer)
            #expect(data == 0)
        }

        @Test("init from raw pointer preserves bitPattern")
        func initFromRawPointer() {
            var value: Int = 42
            let data = withUnsafePointer(to: &value) { ptr in
                Kernel.Kqueue.Event.Data(UnsafeRawPointer(ptr))
            }
            #expect(data != 0)
        }

        @Test("init from typed pointer preserves bitPattern")
        func initFromTypedPointer() {
            var value: Int = 42
            let data = withUnsafePointer(to: &value) { ptr in
                Kernel.Kqueue.Event.Data(pointer: ptr)
            }
            #expect(data != 0)
        }

        @Test("init from mutable typed pointer preserves bitPattern")
        func initFromMutableTypedPointer() {
            var value: Int = 42
            let data = withUnsafeMutablePointer(to: &value) { ptr in
                Kernel.Kqueue.Event.Data(pointer: ptr)
            }
            #expect(data != 0)
        }

        // MARK: - Pointer Extraction Tests

        @Test("UnsafeMutableRawPointer init from non-zero data returns pointer")
        func pointerExtractionNonZero() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let originalPtr = UnsafeMutableRawPointer(ptr)
                let data = Kernel.Kqueue.Event.Data(originalPtr)
                let extractedPtr = UnsafeMutableRawPointer(data)
                #expect(extractedPtr == originalPtr)
            }
        }

        @Test("UnsafeMutableRawPointer init from zero data returns nil")
        func pointerExtractionZero() {
            let data = Kernel.Kqueue.Event.Data.zero
            let extractedPtr = UnsafeMutableRawPointer(data)
            #expect(extractedPtr == nil)
        }

        @Test("pointer roundtrip preserves address")
        func pointerRoundtrip() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let originalPtr = UnsafeMutableRawPointer(ptr)
                let data = Kernel.Kqueue.Event.Data(originalPtr)
                let extractedPtr = UnsafeMutableRawPointer(data)
                #expect(extractedPtr == originalPtr)
            }
        }

        // MARK: - Conformance Tests

        @Test("Data is Sendable")
        func isSendable() {
            let data: any Sendable = Kernel.Kqueue.Event.Data.zero
            #expect(data is Kernel.Kqueue.Event.Data)
        }

        @Test("Data is Equatable")
        func isEquatable() {
            let a = Kernel.Kqueue.Event.Data(42)
            let b = Kernel.Kqueue.Event.Data(42)
            let c = Kernel.Kqueue.Event.Data(0)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Data is Hashable")
        func isHashable() {
            var set = Set<Kernel.Kqueue.Event.Data>()
            set.insert(Kernel.Kqueue.Event.Data(1))
            set.insert(Kernel.Kqueue.Event.Data(2))
            set.insert(Kernel.Kqueue.Event.Data(1))  // duplicate
            #expect(set.count == 2)
        }

        // MARK: - Edge Cases

        @Test("UInt64.max is preserved")
        func uint64MaxPreserved() {
            let data = Kernel.Kqueue.Event.Data(UInt64.max)
            #expect(data.rawValue == UInt64.max)
        }

        @Test("large pointer values are preserved")
        func largePointerValues() {
            // Create data from a large value simulating a high memory address
            let largeValue: UInt64 = 0x7FFF_FFFF_FFFF_FFFF
            let data = Kernel.Kqueue.Event.Data(largeValue)
            #expect(data.rawValue == largeValue)
        }
    }
#endif
