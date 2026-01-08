# swift-darwin

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Type-safe Darwin kqueue syscall wrappers for Swift. Provides Sendable, typed APIs over raw kernel primitives with Swift Duration support.

---

## Key Features

- **Typed throws end-to-end** – Error enum with `.create`, `.kevent`, and `.interrupted` cases
- **Swift 6 strict concurrency** – Full `Sendable` compliance throughout
- **Policy-free design** – Raw syscall wrappers without scheduling or lifecycle opinions
- **Typed filters and flags** – RawRepresentable wrappers prevent magic number errors
- **Duration-based timeouts** – Swift `Duration` support for poll operations
- **Swift-native interface** – Both raw pointer and `[Event]` array APIs

---

## Installation

### Package.swift dependency

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-darwin.git", from: "0.1.0")
]
```

### Target dependency

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Darwin Kernel", package: "swift-darwin")
    ]
)
```

### Requirements

- Swift 6.2+
- macOS 26+ / iOS 26+ / tvOS 26+ / watchOS 26+

---

## Quick Start

```swift
import Darwin_Kernel

// Create kqueue
let kq = try Kernel.Kqueue.create()
defer { try? Kernel.Close.close(kq) }

// Register for read events on a file descriptor
let event = Kernel.Kqueue.Event(
    id: .init(rawValue: UInt(fd.rawValue)),
    filter: .read,
    flags: [.add, .enable],
    fflags: .none,
    filterData: .zero,
    data: .zero
)
try Kernel.Kqueue.register(kq, events: [event])

// Wait for events (100ms timeout)
var results = [Kernel.Kqueue.Event](repeating: .init(...), count: 8)
let count = try Kernel.Kqueue.poll(kq, into: &results, timeout: .milliseconds(100))
for i in 0..<count {
    print("Event on fd: \(results[i].id)")
}
```

---

## Architecture

| Type                    | Description                                                    |
|-------------------------|----------------------------------------------------------------|
| `Kernel.Kqueue`         | Kqueue syscall namespace with `create`, `kevent`, `register`, `poll` |
| `Kernel.Kqueue.Event`   | Event descriptor with id, filter, flags, and data              |
| `Kernel.Kqueue.Filter`  | Filter type (`.read`, `.write`, `.user`)                       |
| `Kernel.Kqueue.Flags`   | Action flags (`.add`, `.delete`, `.enable`, `.oneshot`)        |
| `Kernel.Kqueue.Error`   | Typed error enum (`.create`, `.kevent`, `.interrupted`)        |

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS            | —   | Full support |
| iOS/tvOS/watchOS | —   | Supported    |

---

## Related Packages

### Dependencies

- [swift-kernel-primitives](https://github.com/coenttb/swift-kernel-primitives): Cross-platform kernel primitives
- [swift-posix](https://github.com/coenttb/swift-posix): POSIX syscall wrappers

### Used By

- [swift-io](https://github.com/coenttb/swift-io): Async I/O executor

---

## License

This project is licensed under the Apache License v2.0. See [LICENSE.md](LICENSE.md) for details.
