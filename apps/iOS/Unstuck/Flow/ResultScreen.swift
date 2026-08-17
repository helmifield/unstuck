import SwiftUI

/// Initial Read — renders the analysis result in the LOCKED hierarchy, or a calm
/// loading state, or an honest failure state (never fabricated results).
/// (USER_FLOWS §5; UI_UX §11, §14, §15.)
struct ResultScreen: View {
    let state: UnstuckFlowViewModel.ResultState
    let onRetry: () -> Void
    let onReset: () -> Void
    let onSelectCuriosity: () -> Void

    var body: some View {
        UnstuckScreen(step: .result) {
            switch state {
            case .idle, .loading:
                VStack {
                    Spacer()
                    AnalysisProgress()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            case .loaded(let loaded):
                AnalysisResultView(
                    result: loaded.result,
                    whyExplanation: loaded.whyExplanation,
                    curiosityHook: loaded.curiosityHook,
                    onSelectCuriosity: onSelectCuriosity
                )
                .transition(.opacity)
            case .failed(let message):
                VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
                    Text("We couldn't get a read.")
                        .font(UnstuckType.section)
                        .foregroundStyle(Color.unstuckTextPrimary)
                    Text(message)
                        .font(UnstuckType.body)
                        .foregroundStyle(Color.unstuckTextSecondary)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .safeAreaInset(edge: .bottom) {
            switch state {
            case .failed:
                BottomAction("Try again") { onRetry() }
                    .padding(.horizontal, UnstuckSpacing.contentInset)
                    .padding(.bottom, UnstuckSpacing.md)
            case .loaded:
                BottomAction("Start over") { onReset() }
                    .padding(.horizontal, UnstuckSpacing.contentInset)
                    .padding(.bottom, UnstuckSpacing.md)
            default:
                EmptyView()
            }
        }
    }
}
