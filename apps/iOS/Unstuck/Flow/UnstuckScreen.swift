import SwiftUI

/// Shared screen container: warm ivory background, safe-area + content-inset aware,
/// generous whitespace, calm. (DESIGN_SYSTEM_V1: whitespace is the primary structure.)
struct UnstuckScreen<Content: View>: View {
    let step: UnstuckFlowStep?
    let content: Content

    init(step: UnstuckFlowStep? = nil, @ViewBuilder content: () -> Content) {
        self.step = step
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.unstuckSurfaceBase.ignoresSafeArea()
            VStack(spacing: UnstuckSpacing.zero) {
                if let step, step.rawValue >= UnstuckFlowStep.whatsGoingOn.rawValue {
                    StepProgress(step: step.rawValue, total: UnstuckFlowStep.allCases.count - 1)
                        .padding(.top, UnstuckSpacing.md)
                        .padding(.horizontal, UnstuckSpacing.contentInset)
                }
                ScrollView {
                    content
                        .padding(.horizontal, UnstuckSpacing.contentInset)
                        .padding(.top, UnstuckSpacing.xl)
                        .padding(.bottom, UnstuckSpacing.x2l)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}
