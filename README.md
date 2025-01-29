# SwiftPolling

SwiftPolling is a lightweight, Swift 6-compatible polling utility that allows for flexible and customizable polling strategies. It supports multiple interval strategies such as linear and exponential backoff, making it ideal for scenarios where periodic execution is required.

## Features
- **Actor-based implementation** for thread safety
- **Multiple polling strategies**
  - Linear intervals
  - Exponential backoff
  - Exponential backoff with a max interval
- **Custom polling strategies** by conforming to `PollingStrategy`
- **Async/Await support** using `AsyncThrowingStream`
- **Graceful cancellation** support

## Installation

### Swift Package Manager (SPM)
Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/yosi99/SwiftPolling.git", from: "1.0.0")
```

Then add it as a dependency in your target:

```swift
.target(name: "YourProject", dependencies: ["SwiftPolling"])
```

## Usage

### Creating a PollingService
The `PollingService` uses a `PollingStrategy` to determine intervals between operations. You can choose from different built-in strategies.

#### Example: Linear Polling
```swift
import SwiftPolling

let pollingService = PollingService(strategy: LinearPollingStrategy(maxRuns: 5, durationBetweenRuns: 2))
```
This will execute the polling operation 5 times with a 2-second interval.

#### Example: Exponential Backoff
```swift
let pollingService = PollingService(strategy: ExponentialPollingStrategy(maxRuns: 5, durationBetweenRuns: 1))
```
This will increase the interval exponentially (e.g., 1s, 2s, 4s, etc.).

#### Example: Exponential Backoff with Max Interval
```swift
let pollingService = PollingService(strategy: ExponentialWithMaxPollingStrategy(maxRuns: 5, durationBetweenRuns: 1, maxInterval: 8))
```
This ensures that the interval does not exceed the specified `maxInterval`.

### Running the Polling Service
To start polling, use the `stream()` method and handle each iteration:

```swift
Task {
    for try await iteration in pollingService.stream() {
        print("Polling iteration: \(iteration)")
    }
}
```

### Cancelling the Polling Service
You can cancel polling anytime by calling:
```swift
pollingService.finish()
```

### Creating a Custom Polling Strategy
You can create your own custom polling strategy by conforming to the `PollingStrategy` protocol and implementing custom logic:

```swift
struct CustomPollingStrategy: PollingStrategy {
    let maxRuns: Int
    let durationBetweenRuns: TimeInterval
    
    func make(currentIteration: Int) -> PollingStrategy {
        return CustomPollingStrategy(maxRuns: maxRuns, durationBetweenRuns: durationBetweenRuns + Double(currentIteration))
    }
}
```
This allows you to define polling intervals that increase or change based on custom logic.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project is licensed under the MIT License. See the `LICENSE` file for more details.

