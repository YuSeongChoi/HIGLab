# HIGPractice Learning Log

Track each framework/scope with links to Issue, PR, and retrospective.

## How To Record

For each completed scope, append one row:

- `Date`: completion date (YYYY-MM-DD)
- `Phase`: e.g. Phase 1
- `Framework`: e.g. WidgetKit
- `Scope`: e.g. Core timeline
- `Issue`: GitHub issue link
- `PR`: Pull request link
- `Velog`: retrospective post link
- `Key Learning`: one concise takeaway

## Log Table

| Date | Phase | Framework | Scope | Issue | PR | Velog | Key Learning |
|---|---|---|---|---|---|---|---|
| 2026-02-23 | Phase 1 | WidgetKit | Core timeline | #5 | #6 | https://velog.io/@... | Understood placeholder/snapshot/timeline flow |
| 2026-02-26 | Phase 1 | WidgetKit | Theory review & architecture notes | #5 | #9 | https://devyuseong.tistory.com/38 | Clarified TimelineEntry/date, provider lifecycle, family-based density, and iOS 17 interactive widget patterns. |
| 2026-03-04 | Phase 1 | ActivityKit | DeliveryTracker (Local lifecycle + Widget UI + Debug logging) | #11 | - | - | Separated app control plane vs widget rendering plane, unified shared models, and validated local start/update/end debugging flow. |
| 2026-03-10 | Phase 1 | App Intents | SiriTodo sample adaptation, intents, shortcuts, concurrency troubleshooting | #16 | #18 | - | Reframed a standalone sample into an in-app learning flow, clarified `nonisolated` vs `MainActor.run`, and reduced App Shortcut registration to a valid minimal set. |
| 2026-03-12 | Phase 1 | SwiftUI | TaskMaster scaffold, shared layer, navigation hookup, concept notes | #20 | #22 | - | Reframed a standalone sample app into a navigable in-app demo and clarified `some View`, accessibility, `ContentUnavailableView`, and `static ModelContainer` responsibilities. |
| 2026-03-13 | Phase 1 | SwiftData | TaskMaster data flow review, CRUD path tracing, service/query notes | #23 | - | - | Clarified how `@Model`, `ModelContainer`, `@Query`, `@Bindable`, `FetchDescriptor`, and relationships connect storage changes to SwiftUI updates. |
| 2026-03-17 | Phase 1 | Observation | CartFlow Views 구현 및 Apple Pay 결제 흐름 UI 정리 | #26 | - | - | Connected `@Observable` store reads to actual SwiftUI screens, and clarified where `@Environment`, `@Bindable`, and local `@State` each own or project state. |

## Weekly Reflection (Optional)

- Wins:
- Blockers:
- Next week's focus:
