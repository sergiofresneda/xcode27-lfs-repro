import LFSDependency
import SwiftUI

@main
struct LFSReproApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ContentView: View {
    private let payloadStatus: String = {
        do {
            let payload = try LFSDependency.payload()
            return "LFS payload materialized (\(payload.count) bytes)"
        } catch {
            return "Unable to load LFS payload: \(error.localizedDescription)"
        }
    }()

    var body: some View {
        Text(payloadStatus)
            .multilineTextAlignment(.center)
            .padding()
    }
}
