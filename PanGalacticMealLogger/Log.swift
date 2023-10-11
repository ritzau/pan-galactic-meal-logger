import Foundation

var initialTimestamp: DispatchTime?

func log(_ message: String) {
    let timestamp = DispatchTime.now()

    if initialTimestamp == nil {
        initialTimestamp = timestamp
    }

    guard let initialTime = initialTimestamp else { return }

    let nanoTime = timestamp.uptimeNanoseconds - initialTime.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000 // Convert to seconds

    let hours = Int(timeInterval / 3600)
    let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600) / 60)
    let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
    let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)

    let timestampString = String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)

    print("[\(timestampString)] \(message)")
}

func logExecutionTime(_ message: String, of block: () -> Void)  {
    let startTime = DispatchTime.now()
    log("Start: \(message)")

    block()

    let endTime = DispatchTime.now()
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let duration = Double(nanoTime) / 1_000_000 // Convert to milliseconds

    log("End: \(message) - Duration: \(String(format: "%.3f", duration)) ms")
}

func logExecutionTime(_ message: String, of block: () throws -> Void) rethrows {
    let startTime = DispatchTime.now()
    log("Start: \(message)")

    do {
        try block()
    } catch {
        log("Error: \(error)")
        throw error
    }

    let endTime = DispatchTime.now()
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let duration = Double(nanoTime) / 1_000_000 // Convert to milliseconds

    log("End: \(message) - Duration: \(String(format: "%.3f", duration)) ms")
}

func logExecutionTime(_ message: String, of block: () async -> Void) async {
    let startTime = DispatchTime.now()
    log("Start: \(message)")

    await block()

    let endTime = DispatchTime.now()
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let duration = Double(nanoTime) / 1_000_000 // Convert to milliseconds

    log("End: \(message) - Duration: \(String(format: "%.3f", duration)) ms")
}
