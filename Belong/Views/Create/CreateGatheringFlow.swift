import SwiftUI

struct CreateGatheringFlow: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateGatheringViewModel?
    @State private var path = NavigationPath()
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            CreateGatheringFlowRoot(
                viewModel: resolvedViewModel,
                path: $path,
                dismiss: dismiss
            )
            .navigationDestination(for: CreateRoute.self) { route in
                switch route {
                case .templatePicker:
                    EmptyView() // root is the template picker
                case .customizeGathering(let template):
                    CustomizeGatheringScreen(
                        viewModel: resolvedViewModel,
                        template: template,
                        path: $path
                    )
                case .previewGathering:
                    GatheringPreviewScreen(
                        viewModel: resolvedViewModel,
                        path: $path
                    )
                case .publishedGathering(let gatheringId):
                    GatheringPublishedScreen(
                        gatheringId: gatheringId,
                        onViewGathering: {
                            dismiss()
                        },
                        onShare: {
                            showShareSheet = true
                        }
                    )
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(
                            shareURL: URL(string: "https://belong.app/gathering/\(gatheringId)")!,
                            shareTitle: "Join my gathering '\(resolvedViewModel.title)' on Belong!"
                        )
                    }
                case .createPost:
                    CreatePostScreen()
                }
            }
        }
    }

    private var resolvedViewModel: CreateGatheringViewModel {
        if let vm = viewModel { return vm }
        let vm = CreateGatheringViewModel(container: container)
        Task { @MainActor in viewModel = vm }
        return vm
    }
}

// MARK: - Flow Root (shows TemplatePickerScreen)

private struct CreateGatheringFlowRoot: View {
    let viewModel: CreateGatheringViewModel
    @Binding var path: NavigationPath
    let dismiss: DismissAction

    var body: some View {
        TemplatePickerScreen(viewModel: viewModel, path: $path)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationTitle("Host a gathering")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CreateGatheringFlow()
        .environment(AppState())
        .environment(DependencyContainer())
}
