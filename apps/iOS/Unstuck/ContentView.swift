import SwiftUI

/// Root content view. Hosts the Phase 3A flow, wired to the backend through the
/// `RancaBoundary` (iOS → UNSTUCK API → Ranca boundary → analysis). No AI provider
/// credentials live here; the client only talks to the UNSTUCK backend.
struct ContentView: View {
    private let environment = UnstuckEnvironment.localDefault

    var body: some View {
        FlowContainerView(viewModel: makeViewModel())
    }

    private func makeViewModel() -> UnstuckFlowViewModel {
        let client = URLSessionAPIClient(baseURL: environment.apiBaseURL)
        let service = BackendAnalysisService(client: client)
        return UnstuckFlowViewModel(boundary: service)
    }
}

#Preview {
    ContentView()
}
