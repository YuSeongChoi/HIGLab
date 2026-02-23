# HIGPractice

Practice app for HIGLab framework learning.

## Goal

Use a single SwiftUI app to navigate learning tracks by phase and framework.

## Project Structure

- `HIGPractice/App`: app entry point
- `HIGPractice/Models`: domain models (`FrameworkPhase`, `FrameworkItem`)
- `HIGPractice/Data`: phase/framework catalog data
- `HIGPractice/Features/Home/Views`: phase sections and framework cards
- `HIGPractice/Features/FrameworkDetail/Views`: per-framework study detail view

## Learning Phases

### Phase 1: App Frameworks

- WidgetKit
- ActivityKit
- App Intents
- SwiftUI
- SwiftData
- Observation
- Foundation Models

### Phase 2: App Services

- StoreKit 2
- PassKit
- CloudKit
- Authentication Services
- HealthKit
- WeatherKit
- MapKit
- Core Location
- Core ML
- Vision
- User Notifications
- TipKit
- SharePlay

## MVP Behavior

1. Home screen shows phase section headers.
2. Each section renders framework cards.
3. Tapping a card navigates to detail.
4. Detail shows study paths and a daily checklist.
