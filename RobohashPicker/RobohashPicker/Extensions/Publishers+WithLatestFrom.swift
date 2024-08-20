//
//  Publishers+WithLatestFrom.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 20.08.2024.
//

import Foundation
import Combine

// TODO: add comments

enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

extension Publishers {
    /// Naive implementation of WithLatestFrom
    struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher where Upstream.Failure == Other.Failure {
        typealias Output = (Upstream.Output, Other.Output)
        typealias Failure = Upstream.Failure
        
        private let upstream: Upstream
        private let second: Other
        
        init(
            upstream: Upstream,
            second: Other
        ) {
            self.upstream = upstream
            self.second = second
        }
        
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let merged = mergedStream(upstream, second: second)
            let result = resultStream(from: merged)
            result.subscribe(subscriber)
        }
    }
    
}

extension Publisher {
    func withLatestFrom<Other: Publisher>(_ second: Other) -> Publishers.WithLatestFrom<Self, Other> {
        .init(upstream: self, second: second)
    }
}

private extension Publishers.WithLatestFrom {
    typealias MergedElement = Either<Upstream.Output, Other.Output>
    typealias ScanOutput = (left: Upstream.Output?, right: Other.Output?, shouldEmit: Bool)
    
    private func mergedStream(_ upstream: Upstream, second: Other) -> AnyPublisher<MergedElement, Failure> {
        let left = upstream.map(MergedElement.left)
        let right = second.map(MergedElement.right)
        
        return left.merge(with: right)
            .eraseToAnyPublisher()
    }
    
    private func resultStream(from mergedStream: AnyPublisher<MergedElement, Failure>) -> some Publisher<Output, Failure> {
        mergedStream.scan((nil, nil, false) as ScanOutput) { prev, mergedElement in
            var output = prev
            
            switch mergedElement {
            case .left(let value):
                output.left = value
                output.shouldEmit = true
            case .right(let value):
                output.right = value
                output.shouldEmit = false
            }
            return output
        }
        .compactMap { result -> Output? in
            guard
                result.shouldEmit,
                let left = result.left,
                let right = result.right
            else { return nil }
            return (left, right)
        }
    }
}
