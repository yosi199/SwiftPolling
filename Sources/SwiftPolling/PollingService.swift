//
//  PollingService.swift
//  SwiftPolling
//
//  Created by Yosi Mizrachi on 21/01/2025.
//

import Foundation

public actor PollingService: PollingServiceProtocol {
    
    private var policyMaker: PolicyMaker
    private var lastRunTimestamp = Date()
    
    private var continuation: AsyncThrowingStream<Int, Error>.Continuation?
    private var task: Task<Void, Never>?
    public init(policyMaker: PolicyMaker) {
        self.policyMaker = policyMaker
    }
    
    public func stream() -> AsyncThrowingStream<Int, Error> {
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
            self.task = Task {
                do {
                    var policy = policyMaker.make(currentIteration: 0)
                    var currentIteration = 1
                    
                    while currentIteration <= policy.maxRuns {
                        policy = policyMaker.make(currentIteration: currentIteration)
                        
                        if currentIteration == 1 {
                            continuation.yield(currentIteration)
                        } else {
                            let waitDurationNanoseconds = UInt64(policy.durationBetweenRuns * Double(NSEC_PER_SEC))
                            try await Task.sleep(nanoseconds: waitDurationNanoseconds)
                            continuation.yield(currentIteration)
                        }
                        
                        currentIteration += 1
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func finish() {
        task?.cancel()
        continuation?.finish()
    }
}

public protocol PollingServiceProtocol: Actor {
    func stream() -> AsyncThrowingStream<Int, Error>
    func finish()
}
