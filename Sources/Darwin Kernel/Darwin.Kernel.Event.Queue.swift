//
//  File.swift
//  swift-kernel
//
//  Created by Coen ten Thije Boonkkamp on 06/01/2026.
//
#if canImport(Darwin)
    public import Kernel_Primitives

    extension Kernel.Event {
        public typealias Queue = Kernel.Kqueue
    }
#endif
