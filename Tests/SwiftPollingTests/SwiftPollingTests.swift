import Testing
import Foundation
import Numerics

@testable import SwiftPolling

public enum PollingError: Error, Equatable {
    case error(String)
}

@Test func testSimplePolling() async throws {
    
    var completed = 0
    let workToComplete = { completed += 1 }
    let strategy = LinearPollingStrategy(maxRuns: 10, durationBetweenRuns: 0.1)
    let service = PollingService(strategy: strategy)
    
    for try await _ in await service.stream() {
        workToComplete()
    }
    
    #expect(completed == 10)
}

@Test func testPollingSucceedAfter3Runs() async throws {
    var completed = 0
    
    let strategy = LinearPollingStrategy(maxRuns: 10, durationBetweenRuns: 0.1)
    let service = PollingService(strategy: strategy)
    
    let workToComplete = {
        if completed == 2 {
            await service.finish()
            completed += 1
            return
        }
        
        completed += 1
    }
    
    for try await _ in await service.stream() {
        await workToComplete()
    }
    
    #expect(completed == 3)
    
}

@Test func testPollingThrowsAfter3Runs() async throws {
    var completed = 0
    
    let strategy = LinearPollingStrategy(maxRuns: 10, durationBetweenRuns: 0.1)
    let service = PollingService(strategy: strategy)
    
    let workToComplete = {
        if completed == 2 {
            throw PollingError.error("polling error")
        }
        
        completed += 1
    }
    
    var thrownError: PollingError?
    
    do {
        for try await _ in await service.stream() {
            try workToComplete()
        }
    } catch {
        thrownError = error as? PollingError
    }
    
    await confirmation { confirmation in
        #expect(thrownError != nil)
        #expect(PollingError.error("polling error") == thrownError)
        confirmation()
    }
    
}

@Test func testSimpleExponentialPollingStrategy() async throws {
    let strategy = ExponentialPollingStrategy(maxRuns: 4, durationBetweenRuns: 0.1)
    let service = PollingService(strategy: strategy)
    let start: Date = .now
    
    for try await _ in await service.stream() {
        
    }
    
    let delta = Date.now.timeIntervalSince(start)
    #expect(delta >= 1.0)
}

@Test func testExponentialMaxPollingStrategy() async throws {
    let strategy = ExponentialWithMaxPollingStrategy(maxRuns: 2,
                                                     durationBetweenRuns: 1.0,
                                                     maxInterval: 2)
    let service = PollingService(strategy: strategy)
    var start: Date = .now
    var delta = 0.0
    
    for try await _ in await service.stream() {
        delta = Date.now.timeIntervalSince(start)
        start = .now
    }
    #expect(delta.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.15))
}

@Test func testPollingCancellation() async throws {
    var completed = 0
    
    let strategy = LinearPollingStrategy(maxRuns: 10, durationBetweenRuns: 0.1)
    let service = PollingService(strategy: strategy)
    
    for try await _ in await service.stream() {
        if completed == 3 {
            await service.finish()
        } else {
            completed += 1
        }
    }
    
    #expect(completed == 3)
}
