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
    import Kernel_Test_Support

    extension Kernel.Kqueue {
        #TestSuites
    }

    // MARK: - Syscall Unit Tests

    extension Kernel.Kqueue.Test.Unit {

        // MARK: - Lifecycle Tests

        @Test("create returns valid kqueue descriptor")
        func createReturnsValidDescriptor() throws {
            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            #expect(kq.rawValue >= 0)
        }

        // MARK: - Registration Tests

        @Test("register read event on pipe succeeds")
        func registerReadEventOnPipeSucceeds() throws {
            let (readFd, writeFd) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd)
                Kernel.Event.Test.closeNoThrow(writeFd)
            }

            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            let event = Kernel.Kqueue.Event(
                id: .init(descriptor: readFd),
                filter: .read,
                flags: .add
            )

            // Should not throw
            try Kernel.Kqueue.register(kq, events: [event])
        }

        @Test("register invalid descriptor throws kevent error")
        func registerInvalidDescriptorThrows() throws {
            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            let invalidDescriptor = Kernel.Descriptor(rawValue: -1)
            let event = Kernel.Kqueue.Event(
                id: .init(descriptor: invalidDescriptor),
                filter: .read,
                flags: .add
            )

            #expect(throws: Kernel.Kqueue.Error.self) {
                try Kernel.Kqueue.register(kq, events: [event])
            }
        }

        // MARK: - Poll Tests

        @Test("poll with no events times out and returns zero")
        func pollTimesOutWithNoEvents() throws {
            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            // Create a placeholder event for the array
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)

            let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(10))

            #expect(count == 0)
        }

        @Test("poll returns readability after write to pipe")
        func pollReturnsReadabilityAfterWrite() throws {
            let (readFd, writeFd) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd)
                Kernel.Event.Test.closeNoThrow(writeFd)
            }

            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            // Register read interest on the read end of the pipe
            let registerEvent = Kernel.Kqueue.Event(
                id: .init(descriptor: readFd),
                filter: .read,
                flags: .add
            )
            try Kernel.Kqueue.register(kq, events: [registerEvent])

            // Write a byte to make the pipe readable
            Kernel.Event.Test.writeByte(writeFd)

            // Poll for events
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)
            let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(100))

            #expect(count == 1)
            #expect(results[0].filter == .read)
            #expect(Kernel.Descriptor(results[0].id)?.rawValue == readFd.rawValue)
        }

        @Test("delete registration prevents event delivery")
        func deleteRegistrationPreventsEvent() throws {
            let (readFd, writeFd) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd)
                Kernel.Event.Test.closeNoThrow(writeFd)
            }

            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            // Register read interest
            let addEvent = Kernel.Kqueue.Event(
                id: .init(descriptor: readFd),
                filter: .read,
                flags: .add
            )
            try Kernel.Kqueue.register(kq, events: [addEvent])

            // Delete the registration
            let deleteEvent = Kernel.Kqueue.Event(
                id: .init(descriptor: readFd),
                filter: .read,
                flags: .delete
            )
            try Kernel.Kqueue.register(kq, events: [deleteEvent])

            // Write data to the pipe
            Kernel.Event.Test.writeByte(writeFd)

            // Poll - should return no events since registration was deleted
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)
            let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(50))

            #expect(count == 0)
        }

        @Test("poll on closed kqueue throws error")
        func pollOnClosedKqueueThrows() throws {
            let kq = try Kernel.Kqueue.create()

            // Close the kqueue
            Kernel.Event.Test.closeNoThrow(kq)

            // Now attempt to poll on it - should throw
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)

            #expect(throws: Kernel.Kqueue.Error.self) {
                _ = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(10))
            }
        }

        // MARK: - Multiple Event Tests

        @Test("poll detects multiple readable pipes")
        func pollDetectsMultipleReadablePipes() throws {
            let (readFd1, writeFd1) = try Kernel.Event.Test.makePipe()
            let (readFd2, writeFd2) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd1)
                Kernel.Event.Test.closeNoThrow(writeFd1)
                Kernel.Event.Test.closeNoThrow(readFd2)
                Kernel.Event.Test.closeNoThrow(writeFd2)
            }

            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            // Register read interest on both pipes
            let events = [
                Kernel.Kqueue.Event(
                    id: .init(descriptor: readFd1),
                    filter: .read,
                    flags: .add
                ),
                Kernel.Kqueue.Event(
                    id: .init(descriptor: readFd2),
                    filter: .read,
                    flags: .add
                ),
            ]
            try Kernel.Kqueue.register(kq, events: events)

            // Write to both pipes
            Kernel.Event.Test.writeByte(writeFd1)
            Kernel.Event.Test.writeByte(writeFd2)

            // Poll - should return 2 events
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)
            let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(100))

            #expect(count == 2)
            #expect(results[0].filter == .read)
            #expect(results[1].filter == .read)
        }

        @Test("poll returns only pipe with data when one of two has data")
        func pollReturnsOnlyPipeWithData() throws {
            let (readFd1, writeFd1) = try Kernel.Event.Test.makePipe()
            let (readFd2, writeFd2) = try Kernel.Event.Test.makePipe()
            defer {
                Kernel.Event.Test.closeNoThrow(readFd1)
                Kernel.Event.Test.closeNoThrow(writeFd1)
                Kernel.Event.Test.closeNoThrow(readFd2)
                Kernel.Event.Test.closeNoThrow(writeFd2)
            }

            let kq = try Kernel.Kqueue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            // Register read interest on both pipes
            let events = [
                Kernel.Kqueue.Event(
                    id: .init(descriptor: readFd1),
                    filter: .read,
                    flags: .add
                ),
                Kernel.Kqueue.Event(
                    id: .init(descriptor: readFd2),
                    filter: .read,
                    flags: .add
                ),
            ]
            try Kernel.Kqueue.register(kq, events: events)

            // Write only to pipe 2
            Kernel.Event.Test.writeByte(writeFd2)

            // Poll - should return only 1 event for pipe 2
            let placeholder = Kernel.Kqueue.Event(
                id: Kernel.Event.ID(UInt(0)),
                filter: .read,
                flags: .none
            )
            var results: [Kernel.Kqueue.Event] = Array(repeating: placeholder, count: 10)
            let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(100))

            #expect(count == 1)
            #expect(Kernel.Descriptor(results[0].id)?.rawValue == readFd2.rawValue)
        }
    }

#endif
