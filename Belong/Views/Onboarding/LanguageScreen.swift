import SwiftUI

// MARK: - LanguageScreen (S08)
// App language selection from a scrollable list.
// Selected row shows checkmark and highlighted background.

struct LanguageScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                Text("Choose your language")
                    .font(BelongFont.h1())
                    .foregroundStyle(BelongColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.top, Spacing.sm)
                    .accessibilityAddTraits(.isHeader)

                // Language list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(SampleData.languages, id: \.code) { language in
                            languageRow(language)
                        }
                    }
                    .padding(.horizontal, Layout.screenPadding)
                }

                // Continue button
                BelongButton(title: "Continue", style: .primary) {
                    onContinue()
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
                .accessibilityHint("Continue to city and school selection")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Back")
            }
        }
    }

    // MARK: - Language Row

    private func languageRow(
        _ language: (code: String, name: String, nativeName: String)
    ) -> some View {
        let isSelected = viewModel.selectedLanguage == language.code

        return Button {
            viewModel.selectedLanguage = language.code
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(language.name)
                        .font(BelongFont.bodyMedium())
                        .foregroundStyle(BelongColor.textPrimary)

                    Text(language.nativeName)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(BelongColor.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(height: 60)
            .padding(.horizontal, Spacing.base)
            .background(isSelected ? BelongColor.surfaceSecondary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(language.name), \(language.nativeName)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack {
        LanguageScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
