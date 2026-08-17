import SwiftUI

/// Root flow container for the Phase 3A vertical slice. Holds the single source of
/// truth (`UnstuckFlowViewModel`) and renders the active step with calm transitions.
/// Honors Reduce Motion via `UnstuckMotion.reduced`.
struct FlowContainerView: View {
    @StateObject private var viewModel: UnstuckFlowViewModel

    init(viewModel: UnstuckFlowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.step {
            case .launch:
                LaunchScreen(onBegin: viewModel.goForward)
                    .transition(UnstuckTransition.forward)
            case .whatsGoingOn:
                WhatsGoingOnScreen(onContinue: viewModel.goForward)
                    .transition(UnstuckTransition.forward)
            case .selectSituation:
                SelectSituationScreen(
                    selection: $viewModel.selectedSituation,
                    onContinue: viewModel.goForward
                )
                .transition(UnstuckTransition.forward)
            case .tell:
                TellScreen(
                    text: $viewModel.tellText,
                    guidance: viewModel.tellGuidance,
                    canContinue: viewModel.canContinueFromTell
                ) {
                    Task { await viewModel.requestAnalysis() }
                }
                .transition(UnstuckTransition.forward)
            case .result:
                ResultScreen(
                    state: viewModel.resultState,
                    onRetry: { Task { await viewModel.requestAnalysis() } },
                    onReset: viewModel.reset,
                    onSelectCuriosity: {
                        // Curiosity → ANSWER/SHOW is a future step; here it returns to Tell
                        // to gather more context. (No fake destination.)
                        viewModel.reset()
                    }
                )
                .transition(UnstuckTransition.forward)
            }
        }
        .animation(UnstuckMotion.reduced(UnstuckMotion.transition), value: viewModel.step)
    }
}
