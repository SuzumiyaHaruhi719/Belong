import SwiftUI

struct LanguageScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(spacing: 0) {
            LanguageHeader()
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xl)

            LanguageList()

            LanguageContinueButton(path: $path)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct LanguageHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("App language")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("Choose your preferred language for the app.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LanguageList: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    private let languages: [(code: String, flag: String, name: String, native: String)] = [
        ("en", "🇬🇧", "English", "English"),
        ("zh", "🇨🇳", "Chinese (Simplified)", "\u{7B80}\u{4F53}\u{4E2D}\u{6587}"),
        ("zh-Hant", "🇹🇼", "Chinese (Traditional)", "\u{7E41}\u{9AD4}\u{4E2D}\u{6587}"),
        ("ko", "🇰🇷", "Korean", "\u{D55C}\u{AD6D}\u{C5B4}"),
        ("ja", "🇯🇵", "Japanese", "\u{65E5}\u{672C}\u{8A9E}"),
        ("vi", "🇻🇳", "Vietnamese", "Ti\u{1EBF}ng Vi\u{1EC7}t"),
        ("hi", "🇮🇳", "Hindi", "\u{939}\u{93F}\u{928}\u{94D}\u{926}\u{940}"),
        ("ar", "🇸🇦", "Arabic", "\u{627}\u{644}\u{639}\u{631}\u{628}\u{64A}\u{629}"),
        ("es", "🇪🇸", "Spanish", "Espa\u{F1}ol"),
        ("fr", "🇫🇷", "French", "Fran\u{E7}ais"),
        ("pt", "🇧🇷", "Portuguese", "Portugu\u{EA}s"),
        ("id", "🇮🇩", "Indonesian", "Bahasa Indonesia")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.xs) {
                ForEach(languages, id: \.code) { lang in
                    LanguageRow(
                        flag: lang.flag,
                        name: lang.name,
                        nativeName: lang.native,
                        isSelected: viewModel.selectedLanguage == lang.code,
                        action: { viewModel.selectedLanguage = lang.code }
                    )
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.base)
        }
    }
}

struct LanguageRow: View {
    let flag: String
    let name: String
    let nativeName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Text(flag)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(BelongFont.bodyMedium())
                        .foregroundStyle(BelongColor.textPrimary)
                    Text(nativeName)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(BelongColor.primary)
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? BelongColor.surfaceSecondary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        }
        .accessibilityLabel("\(name), \(nativeName)")
    }
}

struct LanguageContinueButton: View {
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Continue",
            style: .primary,
            isFullWidth: true
        ) {
            path.append(.citySchool)
        }
    }
}

#Preview {
    struct LanguagePreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                LanguageScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return LanguagePreview()
}
