import SwiftUI

struct PasswordRule: Identifiable {
    let id = UUID()
    let label: String
    var met: Bool
}

@Observable @MainActor
final class OnboardingViewModel {
    // MARK: - Dependencies
    private let deps: DependencyContainer

    // MARK: - Form Fields
    var email = ""
    var otpCode = ""
    var password = ""
    var confirmPassword = ""
    var username = ""
    var displayName = ""
    var selectedAvatar = ""
    var selectedLanguage = "en"
    var selectedCity = ""
    var selectedSchool = ""

    // MARK: - Cultural Tags
    var selectedBackgrounds: Set<String> = []
    var selectedLanguages: Set<String> = []
    var selectedInterests: Set<String> = []

    // MARK: - Validation
    var emailError: String?
    var loginError: String?
    var passwordRules: [PasswordRule] = [
        PasswordRule(label: "At least 8 characters", met: false),
        PasswordRule(label: "One uppercase letter", met: false),
        PasswordRule(label: "One lowercase letter", met: false),
        PasswordRule(label: "One number or special character", met: false)
    ]
    var usernameAvailable: Bool?
    var isCheckingUsername = false
    var otpVerified = false
    var otpError: String?

    // MARK: - Loading States
    var isSendingOTP = false
    var isVerifyingOTP = false
    var isRegistering = false
    var isLoggingIn = false
    var isSubmittingTags = false
    var registerError: String?

    // MARK: - Registered User (set after successful registration)
    var registeredUser: User?

    // MARK: - OTP Timer
    var otpCountdown = 0
    private var otpTimerTask: Task<Void, Never>?

    // MARK: - Username debounce
    private var usernameCheckTask: Task<Void, Never>?

    // MARK: - Search results
    var cityResults: [String] = []
    var schoolResults: [String] = []
    var cityQuery = ""
    var schoolQuery = ""
    var isSearchingCities = false
    var isSearchingSchools = false

    // MARK: - Tag presets
    var backgroundPresets: [String] = []
    var languagePresets: [String] = []
    var interestPresets: [String] = []

    init(deps: DependencyContainer) {
        self.deps = deps
    }

    // MARK: - Computed

    var maskedEmail: String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let prefix = String(email[email.startIndex..<atIndex])
        let domain = String(email[atIndex...])
        if prefix.count <= 2 {
            return prefix + "***" + domain
        }
        let visible = String(prefix.prefix(2))
        return visible + String(repeating: "*", count: max(prefix.count - 2, 3)) + domain
    }

    var isEmailValid: Bool {
        email.lowercased().hasSuffix(".edu") || email.lowercased().hasSuffix(".edu.au")
    }

    var allPasswordRulesMet: Bool {
        passwordRules.allSatisfy(\.met)
    }

    var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    var isPasswordStepValid: Bool {
        allPasswordRulesMet && passwordsMatch
    }

    var isUsernameValid: Bool {
        username.count >= 3 && username.count <= 30 && usernameAvailable == true
    }

    var canSelectCitySchool: Bool {
        !selectedCity.isEmpty && !selectedSchool.isEmpty
    }

    // MARK: - Email Validation

    func validateEmail() {
        if email.isEmpty {
            emailError = nil
        } else if !isEmailValid {
            emailError = "Please use a valid .edu email address"
        } else {
            emailError = nil
        }
    }

    // MARK: - OTP

    func sendOTP() async {
        validateEmail()
        guard emailError == nil, isEmailValid else { return }
        isSendingOTP = true
        defer { isSendingOTP = false }
        do {
            try await deps.authService.sendOTP(to: email)
            startOTPCountdown()
        } catch {
            emailError = "Failed to send verification code. Try again."
        }
    }

    func verifyOTP() async {
        isVerifyingOTP = true
        otpError = nil
        defer { isVerifyingOTP = false }
        do {
            let success = try await deps.authService.verifyOTP(email: email, code: otpCode)
            otpVerified = success
            if !success {
                otpError = "Invalid or expired code. Please check and try again."
            }
        } catch {
            let msg = error.localizedDescription.lowercased()
            if msg.contains("expired") || msg.contains("token") {
                otpError = "Code expired. Tap Resend to get a new code."
            } else if msg.contains("network") || msg.contains("connection") {
                otpError = "Network error. Check your connection and try again."
            } else {
                otpError = "Verification failed: \(error.localizedDescription)"
            }
        }
    }

    func resendOTP() async {
        guard otpCountdown == 0 else { return }
        otpCode = ""
        otpError = nil
        await sendOTP()
    }

    private func startOTPCountdown() {
        otpCountdown = 60
        otpTimerTask?.cancel()
        otpTimerTask = Task {
            while otpCountdown > 0, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    otpCountdown -= 1
                }
            }
        }
    }

    // MARK: - Password Validation

    func validatePassword() {
        let pw = password
        passwordRules[0].met = pw.count >= 8
        passwordRules[1].met = pw.range(of: "[A-Z]", options: .regularExpression) != nil
        passwordRules[2].met = pw.range(of: "[a-z]", options: .regularExpression) != nil
        passwordRules[3].met = pw.range(of: "[0-9!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
    }

    // MARK: - Username

    func checkUsername() {
        usernameCheckTask?.cancel()
        let trimmed = username.trimmingCharacters(in: .whitespaces).lowercased()
        guard trimmed.count >= 3 else {
            usernameAvailable = nil
            isCheckingUsername = false
            return
        }
        isCheckingUsername = true
        usernameCheckTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            do {
                let available = try await deps.authService.checkUsername(trimmed)
                if !Task.isCancelled {
                    usernameAvailable = available
                    isCheckingUsername = false
                }
            } catch {
                if !Task.isCancelled {
                    usernameAvailable = nil
                    isCheckingUsername = false
                }
            }
        }
    }

    // MARK: - Registration

    func register() async -> User? {
        isRegistering = true
        registerError = nil
        defer { isRegistering = false }
        do {
            let user = try await deps.authService.register(
                email: email,
                password: password,
                username: username
            )
            registeredUser = user
            return user
        } catch {
            registerError = error.localizedDescription
            return nil
        }
    }

    // MARK: - Login

    func login() async -> User? {
        isLoggingIn = true
        loginError = nil
        defer { isLoggingIn = false }
        do {
            let user = try await deps.authService.login(email: email, password: password)
            return user
        } catch {
            loginError = "Invalid email or password. Please try again."
            return nil
        }
    }

    // MARK: - Tags

    func submitTags() async {
        isSubmittingTags = true
        defer { isSubmittingTags = false }
        var tags: [UserTag] = []
        for bg in selectedBackgrounds {
            tags.append(UserTag(id: UUID().uuidString, userId: "", category: .culturalBackground, value: bg))
        }
        for lang in selectedLanguages {
            tags.append(UserTag(id: UUID().uuidString, userId: "", category: .language, value: lang))
        }
        for interest in selectedInterests {
            tags.append(UserTag(id: UUID().uuidString, userId: "", category: .interestVibe, value: interest))
        }
        do {
            try await deps.userService.updateTags(tags)
        } catch {
            // Silently fail for now
        }
    }

    // MARK: - City & School Search

    func searchCities() {
        isSearchingCities = true
        Task {
            do {
                let results = try await deps.userService.fetchCities(query: cityQuery)
                cityResults = results
            } catch {
                cityResults = []
            }
            isSearchingCities = false
        }
    }

    func searchSchools() {
        guard !selectedCity.isEmpty else { return }
        isSearchingSchools = true
        Task {
            do {
                let results = try await deps.userService.fetchSchools(city: selectedCity)
                schoolResults = results
            } catch {
                schoolResults = []
            }
            isSearchingSchools = false
        }
    }

    func selectCity(_ city: String) {
        selectedCity = city
        cityQuery = city
        cityResults = []
        selectedSchool = ""
        schoolQuery = ""
        searchSchools()
    }

    func selectSchool(_ school: String) {
        selectedSchool = school
        schoolQuery = school
        schoolResults = []
    }

    // MARK: - Tag Presets

    func loadTagPresets() async {
        do {
            async let bg = deps.userService.fetchTagPresets(category: .culturalBackground)
            async let lang = deps.userService.fetchTagPresets(category: .language)
            async let vibes = deps.userService.fetchTagPresets(category: .interestVibe)
            backgroundPresets = try await bg
            languagePresets = try await lang
            interestPresets = try await vibes
        } catch {
            backgroundPresets = SampleData.culturalBackgrounds
            languagePresets = SampleData.languages
            interestPresets = SampleData.interestVibes
        }
    }
}
