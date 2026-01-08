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

    extension Kernel.Kqueue.Filter {
        #TestSuites
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Kqueue.Filter.Test.Unit {

        @Test("read and write filters are distinct")
        func readAndWriteAreDistinct() {
            #expect(Kernel.Kqueue.Filter.read != .write)
            #expect(Kernel.Kqueue.Filter.read.rawValue != Kernel.Kqueue.Filter.write.rawValue)
        }

        @Test("read filter rawValue matches EVFILT_READ")
        func readRawValueMatchesEVFILTREAD() {
            #expect(Kernel.Kqueue.Filter.read.rawValue == Int16(EVFILT_READ))
        }

        @Test("write filter rawValue matches EVFILT_WRITE")
        func writeRawValueMatchesEVFILTWRITE() {
            #expect(Kernel.Kqueue.Filter.write.rawValue == Int16(EVFILT_WRITE))
        }

        @Test("user filter rawValue matches EVFILT_USER")
        func userRawValueMatchesEVFILTUSER() {
            #expect(Kernel.Kqueue.Filter.user.rawValue == Int16(EVFILT_USER))
        }

        @Test("filter conforms to Equatable")
        func filterEquatable() {
            let filter1 = Kernel.Kqueue.Filter.read
            let filter2 = Kernel.Kqueue.Filter.read
            let filter3 = Kernel.Kqueue.Filter.write

            #expect(filter1 == filter2)
            #expect(filter1 != filter3)
        }

        @Test("filter conforms to Hashable")
        func filterHashable() {
            let filter1 = Kernel.Kqueue.Filter.read
            let filter2 = Kernel.Kqueue.Filter.read

            #expect(filter1.hashValue == filter2.hashValue)
        }
    }

#endif
