import SwiftUI

struct AvatarSetupScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                AvatarSetupHeader()
                AvatarPreviewSection()
                AvatarGrid()
                AvatarDisplayNameField()
                AvatarContinueButton(path: $path)
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct AvatarSetupHeader: View {
    var body: some View {
        Text("Choose your avatar")
            .font(BelongFont.h1())
            .foregroundStyle(BelongColor.textPrimary)
    }
}

struct AvatarPreviewSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        HStack {
            Spacer()
            AvatarView(
                emoji: viewModel.selectedAvatar.isEmpty ? "?" : viewModel.selectedAvatar,
                size: .xlarge
            )
            Spacer()
        }
    }
}

struct AvatarGrid: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    private let avatars = [
        "🌿", "⭐", "🔥", "🌙", "🍊",
        "🌺", "💜", "🦋", "🌊", "✨"
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(avatars, id: \.self) { emoji in
                AvatarGridItem(
                    emoji: emoji,
                    isSelected: viewModel.selectedAvatar == emoji,
                    action: { viewModel.selectedAvatar = emoji }
                )
            }
        }
    }
}

struct AvatarGridItem: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? BelongColor.surfaceSecondary : BelongColor.surface)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? BelongColor.primary : BelongColor.border, lineWidth: isSelected ? 2 : 1)
                    )
                Text(emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 60, height: 60)
        }
        .accessibilityLabel("Avatar \(emoji)")
    }
}

struct AvatarDisplayNameField: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        BelongTextField(
            label: "Display name",
            text: $vm.displayName,
            placeholder: "How should we call you?",
            characterLimit: 50
        )
        .textContentType(.name)
        .accessibilityLabel("Display name")
    }
}

struct AvatarContinueButton: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Continue",
            style: .primary,
            isFullWidth: true,
            isDisabled: viewModel.displayName.trimmingCharacters(in: .whitespaces).isEmpty
        ) {
            path.append(.language)
        }
    }
}

#Preview {
    struct AvatarPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                AvatarSetupScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return AvatarPreview()
}
