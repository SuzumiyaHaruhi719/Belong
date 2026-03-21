//
//  BelongApp.swift
//  Belong
//
//  Created by 666 on 2026/3/21.
//

import SwiftUI

// MARK: - App Entry Point
// Launches into RootView which handles auth routing.
// The warm cream background is set at the window level so
// there's never a white flash during launch or transitions.

@main
struct BelongApp: App {
    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    /// Global UIKit appearance overrides for native components
    /// that SwiftUI doesn't fully theme (tab bar, nav bar, etc.)
    private func configureAppearance() {
        // Tab bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(BelongColor.surface)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = UIColor(BelongColor.background)
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
