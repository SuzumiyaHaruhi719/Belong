# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Belong is an early-stage SwiftUI iOS app targeting iOS 26.2+, supporting iPhone and iPad.

## Build & Run

Open `Belong.xcodeproj` in Xcode and build/run using the standard Xcode workflow (`Cmd+R`). There are no external dependencies (no CocoaPods, SPM, or Carthage).

- **Bundle ID:** `hhh.Belong`
- **Deployment Target:** iOS 26.2
- **Swift Version:** 5.0

## Architecture

- **SwiftUI** throughout — no UIKit
- Entry point: `Belong/BelongApp.swift` (`@main`, `WindowGroup` scene)
- Source files live in `Belong/` (inner directory); `Belong.xcodeproj` is at repo root
- `MainActor` isolation is enabled project-wide (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Approachable concurrency enabled (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)
- No test targets configured yet
- App structure: `NavigationStack` for onboarding (Tasks 0) → `TabView` (4 tabs) for main loop (Tasks 1–6)

## Product Knowledge Base

All product decisions, UI specifications, and interaction design are documented in `docs/`:

| File | Contents |
|------|---------|
| `docs/01-app-specification.md` | Full app spec: design system, all tasks (0–6), data models, navigation structure, build order |
| `docs/02-interaction-structure.md` | Screen architecture (S01–S26 + 3 bottom sheets), HTA→UI pattern mapping, missing flows, user flow map |
| `docs/03-ui-specification.md` | Implementation-ready UI spec: every screen's goal, content hierarchy, components, microcopy, edge cases, accessibility |

**Read `docs/` before building any screen.** Every component state, color token, copy string, and edge case is pre-defined there — do not guess or invent values.

## Key Design Decisions (quick reference)

- **Use mock/dummy data** for all gatherings and users. No backend in early phases.
- **26 screens + 3 bottom sheets** total. See `docs/02` for the full screen map.
- **All Swift source files** go into `Belong/` (the inner directory).
- **Design tokens** are defined in `docs/01` (colors, fonts, spacing). Use them exactly.
- **Onboarding** uses `NavigationStack`; main app uses `TabView` with 4 tabs: Home, My Events, Host, Profile.
- **Cultural tag chips** are multi-selectable with terracotta fill on select.
- **"Skip for now"** on the cultural tags screen must be visually equivalent to the primary button — never hidden or de-emphasized.
- **Emoji feedback (Task 6.1)** is a bottom sheet, not a full screen. One tap submits — no confirm step.
- **System/backend processes (Task 6.2)** are never user-facing.
