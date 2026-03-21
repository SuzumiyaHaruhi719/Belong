import SwiftUI

// MARK: - OnboardingViewModel
// Drives all onboarding screens (S01–S11). Each step's validation
// and async operations (OTP send/verify, username check) live here.
//
// UX Decision: Validation is real-time (on change) for fields like username
// but on-submit for email/password to avoid premature error flashing.

@Observable
final class OnboardingViewModel {
    // S02 – Email
    var email = ""
    var emailError: String?
    var isSendingOTP = false

    // S03 – OTP
    var otpCode = ""
    var otpError: String?
    var isVerifyingOTP = false
    var otpCountdownSeconds = 60

    // S04 – Password
    var password = ""
    var confirmPassword = ""
    var showPassword = false

    // S05 – Username
    var username = ""
    var usernameError: String?
    var isCheckingUsername = false
    var usernameAvailable: Bool?

    // S07 – Avatar & Display Name
    var selectedAvatar = "🌿"
    var displayName = ""
    var displayNameError: String?

    // S08 – Language
    var selectedLanguage = "en"

    // S09 – City & School
    var selectedCity = ""
    var selectedSchool = ""
    var citySearchText = ""
    var schoolSearchText = ""

    // S10 – Cultural Tags
    var selectedBackground: [String] = []
    var selectedLanguages: [String] = []
    var selectedInterests: [String] = []

    // Global
    var isLoading = false
    var generalError: String?

    // MARK: - Validation

    var isEmailValid: Bool {
        let pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        return email.wholeMatch(of: pattern) != nil
    }

    var passwordRules: [(label: String, met: Bool)] {
        [
            ("At least 8 characters", password.count >= 8),
            ("One uppercase letter", password.contains(where: \.isUppercase)),
            ("One lowercase letter", password.contains(where: \.isLowercase)),
            ("One number", password.contains(where: \.isNumber)),
        ]
    }

    var isPasswordValid: Bool {
        passwordRules.allSatisfy(\.met) && password == confirmPassword && !confirmPassword.isEmpty
    }

    var isUsernameValid: Bool {
        let stripped = username.trimmingCharacters(in: .whitespaces)
        return stripped.count >= 3 && stripped.count <= 20
            && stripped.range(of: #"^[a-z0-9._]+$"#, options: .regularExpression) != nil
            && usernameAvailable == true
    }

    var isDisplayNameValid: Bool {
        let stripped = displayName.trimmingCharacters(in: .whitespaces)
        return !stripped.isEmpty && stripped.count <= 30
    }

    var isCitySchoolValid: Bool {
        !selectedCity.isEmpty && !selectedSchool.isEmpty
    }

    // MARK: - Async Actions (mock)

    func sendOTP() async {
        emailError = nil
        guard isEmailValid else {
            emailError = "Enter a valid email address"
            return
        }
        isSendingOTP = true
        defer { isSendingOTP = false }

        // Simulate network
        try? await Task.sleep(for: .seconds(1.5))
        // Success — navigation handled by the view
    }

    func verifyOTP() async -> Bool {
        otpError = nil
        guard otpCode.count == 6 else {
            otpError = "Enter all 6 digits"
            return false
        }
        isVerifyingOTP = true
        defer { isVerifyingOTP = false }

        try? await Task.sleep(for: .seconds(1))
        // Mock: "123456" always succeeds
        if otpCode == "123456" {
            return true
        } else {
            otpError = "Invalid code. Please try again."
            return false
        }
    }

    func checkUsernameAvailability() async {
        let candidate = username.lowercased().trimmingCharacters(in: .whitespaces)
        guard candidate.count >= 3 else {
            usernameAvailable = nil
            return
        }
        isCheckingUsername = true
        defer { isCheckingUsername = false }

        try? await Task.sleep(for: .seconds(0.8))
        // Mock: "taken" is unavailable, everything else is available
        usernameAvailable = candidate != "taken"
        usernameError = usernameAvailable == false ? "Username is taken" : nil
    }

    func buildUser() -> User {
        User(
            id: UUID().uuidString,
            email: email,
            username: username,
            displayName: displayName,
            avatarURL: nil,
            avatarEmoji: selectedAvatar,
            city: selectedCity,
            school: selectedSchool,
            language: selectedLanguage,
            culturalTags: CulturalTags(
                background: selectedBackground,
                languages: selectedLanguages,
                interests: selectedInterests
            ),
            stats: UserStats(attended: 0, hosted: 0, connections: 0)
        )
    }
}
