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
    import Kernel_Primitives_Test_Support
    @testable import Darwin_Kernel

    extension Kernel.Kqueue.Event {
        #TestSuites
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Kqueue.Event.Test.Unit {

        @Test("event roundtrips through C conversion")
        func eventRoundtripsThoughCConversion() throws {
            let (readFd, writeFd) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd)
                Kernel.Event.Test.closeNoThrow(writeFd)
            }

            let original = Kernel.Kqueue.Event(
                id: .init(descriptor: readFd),
                filter: .read,
                flags: .add | .enable,
                fflags: .none,
                filterData: .zero,
                data: Kernel.Kqueue.Event.Data(42)
            )

            // Convert to C and back
            let cEvent = original.cValue
            let restored = Kernel.Kqueue.Event(cEvent)

            #expect(restored.id == original.id)
            #expect(restored.filter == original.filter)
            #expect(restored.flags == original.flags)
            #expect(restored.fflags == original.fflags)
            // Note: data may not roundtrip perfectly due to pointer conversion
        }

        @Test("event data roundtrips value")
        func eventDataRoundtripsValue() {
            let data = Kernel.Kqueue.Event.Data(12345)
            #expect(data == 12345)
        }

        @Test("event data zero constant exists")
        func eventDataZeroConstantExists() {
            let data = Kernel.Kqueue.Event.Data.zero
            #expect(data == 0)
        }

        @Test("event conforms to Equatable")
        func eventEquatable() {
            let event1 = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event2 = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event3 = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .write,
                flags: .add
            )

            #expect(event1 == event2)
            #expect(event1 != event3)
        }

        @Test("event conforms to Hashable")
        func eventHashable() {
            let event1 = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event2 = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )

            #expect(event1.hashValue == event2.hashValue)
        }
    }

#endif
