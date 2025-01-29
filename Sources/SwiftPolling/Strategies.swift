//
//  PollingStrategy.swift
//  SwiftPolling
//
//  Created by Yosi Mizrachi on 21/01/2025.
//

import Foundation

public protocol PollingStrategy: Sendable {
    var maxRuns: Int { get }
    var durationBetweenRuns: TimeInterval { get }
    func make(currentIteration: Int) -> any PollingStrategy
}

public struct LinearPollingStrategy: PollingStrategy {
    public let maxRuns: Int
    public let durationBetweenRuns: TimeInterval
    
    public init(maxRuns: Int, durationBetweenRuns: TimeInterval) {
        self.maxRuns = maxRuns
        self.durationBetweenRuns = durationBetweenRuns
    }
    
    public func make(currentIteration: Int) -> PollingStrategy {
        LinearPollingStrategy(maxRuns: maxRuns, durationBetweenRuns: durationBetweenRuns)
    }
}

public struct ExponentialPollingStrategy: PollingStrategy {
    public let maxRuns: Int
    public let durationBetweenRuns: TimeInterval
    
    public func make(currentIteration: Int) -> PollingStrategy {
        let calculatedDuration = durationBetweenRuns * pow(2, Double(currentIteration))
        
        return ExponentialPollingStrategy(
            maxRuns: maxRuns,
            durationBetweenRuns: calculatedDuration)
    }
}

public struct ExponentialWithMaxPollingStrategy: PollingStrategy {
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
        return ExponentialWithMaxPollingStrategy(
            maxRuns: maxRuns,
            durationBetweenRuns: useInterval,
            maxInterval: maxInterval)
    }
}
