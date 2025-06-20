import Foundation
import FirebasePerformance
import FirebaseAnalytics

final class PerformanceTracer {
    private var trace: Trace?

    init(name: String) {
        self.trace = Performance.startTrace(name: name)
        Analytics.logEvent("trace_started", parameters: [
            "trace_name": name
        ])
    }

    func increment(metric name: String, by amount: Int64 = 1) {
        trace?.incrementMetric(name, by: amount)
        Analytics.logEvent("trace_metric_incremented", parameters: [
            "metric_name": name,
            "amount": amount
        ])
    }

    func stop() {
        if let name = trace?.name {
            Analytics.logEvent("trace_stopped", parameters: [
                "trace_name": name
            ])
        }
        trace?.stop()
    }
}
