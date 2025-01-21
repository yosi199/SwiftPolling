//
//  PolicyMaker.swift
//  SwiftPolling
//
//  Created by Yosi Mizrachi on 21/01/2025.
//

import Foundation

public protocol PolicyMaker: Sendable {
    func make(currentIteration: Int) -> any PollingStrategy
}

public protocol PollingStrategy: Sendable {
    var maxRuns: Int { get }
    var durationBetweenRuns: TimeInterval { get }
}

public struct LinearPollingPolicy: PollingStrategy, PolicyMaker {
    public let maxRuns: Int
    public let durationBetweenRuns: TimeInterval
    
    public init(maxRuns: Int, durationBetweenRuns: TimeInterval) {
        self.maxRuns = maxRuns
        self.durationBetweenRuns = durationBetweenRuns
    }
    
    public func make(currentIteration: Int) -> PollingStrategy {
        LinearPollingPolicy(maxRuns: maxRuns, durationBetweenRuns: durationBetweenRuns)
    }
}

public struct ExponentialPollingPolicy: PollingStrategy, PolicyMaker {
    public let maxRuns: Int
    public let durationBetweenRuns: TimeInterval
    
    public func make(currentIteration: Int) -> PollingStrategy {
        let calculatedDuration = durationBetweenRuns * pow(2, Double(currentIteration))
        
        return ExponentialPollingPolicy(
            maxRuns: maxRuns,
            durationBetweenRuns: calculatedDuration)
    }
}

public struct ExponentialWithMaxPollingPolicy: PollingStrategy, PolicyMaker {
    public let maxRuns: Int
    public let durationBetweenRuns: TimeInterval
    public let maxInterval: TimeInterval
    
    init(maxRuns: Int, durationBetweenRuns: TimeInterval, maxInterval: TimeInterval) {
        self.maxRuns = maxRuns
        self.durationBetweenRuns = durationBetweenRuns
        self.maxInterval = maxInterval
    }
    
    public func make(currentIteration: Int) -> PollingStrategy {
        let calculatedDuration = durationBetweenRuns * pow(2, Double(currentIteration))
        let useInterval = min(calculatedDuration, maxInterval)
        return ExponentialWithMaxPollingPolicy(
            maxRuns: maxRuns,
            durationBetweenRuns: useInterval,
            maxInterval: maxInterval)
    }
}
