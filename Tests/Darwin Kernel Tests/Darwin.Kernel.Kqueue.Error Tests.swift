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
    import Kernel_Primitives

    extension Kernel.Kqueue.Error {
        #TestSuites
    }

    // MARK: - Error Unit Tests

    extension Kernel.Kqueue.Error.Test.Unit {

        @Test("create error captures posix error code")
        func createErrorCapturesPosixCode() {
            let code = Kernel.Error.Code.posix(EBADF)
            let error = Kernel.Kqueue.Error.create(code)

            if case .create(let capturedCode) = error {
                #expect(capturedCode.posix == EBADF)
            } else {
                Issue.record("Expected .create error case")
            }
        }

        @Test("kevent error captures posix error code")
        func keventErrorCapturesPosixCode() {
            let code = Kernel.Error.Code.posix(EINVAL)
            let error = Kernel.Kqueue.Error.kevent(code)

            if case .kevent(let capturedCode) = error {
                #expect(capturedCode.posix == EINVAL)
            } else {
                Issue.record("Expected .kevent error case")
            }
        }

        @Test("error conforms to Swift.Error")
        func errorConformsToSwiftError() {
            let error: any Swift.Error = Kernel.Kqueue.Error.interrupted
            #expect(error is Kernel.Kqueue.Error)
        }

        @Test("error conforms to Equatable")
        func errorEquatable() {
            let error1 = Kernel.Kqueue.Error.interrupted
            let error2 = Kernel.Kqueue.Error.interrupted
            let error3 = Kernel.Kqueue.Error.create(.posix(EBADF))

            #expect(error1 == error2)
            #expect(error1 != error3)
        }

        @Test("error has description")
        func errorHasDescription() {
            let error = Kernel.Kqueue.Error.interrupted
            #expect(!error.description.isEmpty)
        }
    }

#endif
