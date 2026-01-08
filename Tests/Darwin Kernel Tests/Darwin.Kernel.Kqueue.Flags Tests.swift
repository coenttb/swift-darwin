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

    extension Kernel.Kqueue.Flags {
        #TestSuites
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Kqueue.Flags.Test.Unit {

        @Test("add and delete flags are distinct")
        func addAndDeleteAreDistinct() {
            #expect(Kernel.Kqueue.Flags.add != .delete)
            #expect(Kernel.Kqueue.Flags.add.rawValue != Kernel.Kqueue.Flags.delete.rawValue)
        }

        @Test("flags combine with OR operator")
        func flagsCombineWithOrOperator() {
            let combined = Kernel.Kqueue.Flags.add | .enable
            #expect(combined.contains(.add))
            #expect(combined.contains(.enable))
            #expect(!combined.contains(.delete))
        }

        @Test("contains detects single flag")
        func containsDetectsSingleFlag() {
            #expect(Kernel.Kqueue.Flags.add.contains(.add))
            #expect(!Kernel.Kqueue.Flags.add.contains(.delete))
        }

        @Test("none has rawValue zero")
        func noneHasRawValueZero() {
            #expect(Kernel.Kqueue.Flags.none.rawValue == 0)
        }

        @Test("add flag rawValue matches EV_ADD")
        func addRawValueMatchesEVADD() {
            #expect(Kernel.Kqueue.Flags.add.rawValue == UInt16(EV_ADD))
        }

        @Test("delete flag rawValue matches EV_DELETE")
        func deleteRawValueMatchesEVDELETE() {
            #expect(Kernel.Kqueue.Flags.delete.rawValue == UInt16(EV_DELETE))
        }
    }

#endif
