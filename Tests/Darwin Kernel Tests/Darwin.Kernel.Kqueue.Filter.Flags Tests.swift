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

    extension Kernel.Kqueue.Filter.Flags {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.Kqueue.Filter.Flags.Test.Unit {
        @Test("init with rawValue stores value")
        func initWithRawValue() {
            let flags = Kernel.Kqueue.Filter.Flags(rawValue: 42)
            #expect(flags.rawValue == 42)
        }

        @Test("none has rawValue of 0")
        func noneHasZeroRawValue() {
            #expect(Kernel.Kqueue.Filter.Flags.none.rawValue == 0)
        }

        @Test("trigger matches NOTE_TRIGGER")
        func triggerMatchesNoteTrigger() {
            #expect(Kernel.Kqueue.Filter.Flags.trigger.rawValue == UInt32(NOTE_TRIGGER))
        }

        @Test("flags can be combined with |")
        func flagsCombineWithOr() {
            let combined = Kernel.Kqueue.Filter.Flags.trigger | Kernel.Kqueue.Filter.Flags.none
            #expect(combined.rawValue == Kernel.Kqueue.Filter.Flags.trigger.rawValue)
        }

        @Test("contains returns true for contained flag")
        func containsReturnsTrueForContained() {
            let flags = Kernel.Kqueue.Filter.Flags.trigger
            #expect(flags.contains(.trigger))
        }

        @Test("contains returns true for none in any flags")
        func containsReturnsTrueForNone() {
            let flags = Kernel.Kqueue.Filter.Flags.trigger
            #expect(flags.contains(.none))
        }

        @Test("contains returns false for non-contained flag")
        func containsReturnsFalseForNonContained() {
            let flags = Kernel.Kqueue.Filter.Flags.none
            #expect(!flags.contains(.trigger))
        }

        @Test("rawValue roundtrip preserves value")
        func rawValueRoundtrip() {
            let original: UInt32 = 0xDEAD_BEEF
            let flags = Kernel.Kqueue.Filter.Flags(rawValue: original)
            #expect(flags.rawValue == original)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Kqueue.Filter.Flags.Test.Unit {
        @Test("Flags is Sendable")
        func isSendable() {
            let flags: any Sendable = Kernel.Kqueue.Filter.Flags.trigger
            #expect(flags is Kernel.Kqueue.Filter.Flags)
        }

        @Test("Flags is Equatable")
        func isEquatable() {
            let a = Kernel.Kqueue.Filter.Flags.trigger
            let b = Kernel.Kqueue.Filter.Flags.trigger
            let c = Kernel.Kqueue.Filter.Flags.none
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Flags is Hashable")
        func isHashable() {
            var set = Set<Kernel.Kqueue.Filter.Flags>()
            set.insert(.trigger)
            set.insert(.none)
            set.insert(.trigger)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Kqueue.Filter.Flags.Test.EdgeCase {
        @Test("combining same flag is idempotent")
        func combiningIdempotent() {
            let combined = Kernel.Kqueue.Filter.Flags.trigger | .trigger
            #expect(combined == .trigger)
        }

        @Test("combining with none is identity")
        func combiningWithNoneIsIdentity() {
            let combined = Kernel.Kqueue.Filter.Flags.trigger | .none
            #expect(combined == .trigger)
        }

        @Test("none combined with none is none")
        func noneCombinedWithNone() {
            let combined = Kernel.Kqueue.Filter.Flags.none | .none
            #expect(combined == .none)
        }
    }
#endif
