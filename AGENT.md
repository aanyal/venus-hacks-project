# AGENT.md — VenusHacks MVP Build Guide

See project repository for full build guide. Swift implementation lives in `VenusHacksProject/`.

## Swift app structure

- `DesignSystem.swift` — colors, typography, spacing
- `Models.swift` — UserProfile, AwarenessLevel, reels, roadmap
- `SafetyText.swift` — medical-safe copy templates
- `Personalization.swift` — rule-based insights, reel scoring, advocacy
- `Similarity.swift` — community match scoring
- `MockData.swift` — sample stats, reels, milestones
- `AppState.swift` — app state + UserDefaults persistence
- `Components.swift` — glass cards, nav, charts
- `OnboardingView.swift` — 5-step onboarding
- `HomeView.swift` — AI + Stats
- `ReelsView.swift` — personalized educational feed
- `AdvocacyView.swift` — questions + practice simulator
- `RoadmapView.swift` — Duolingo-style care path
- `CommunityView.swift` — consent-based matching
- `ProfileView.swift` — privacy + emergency contact
- `MainTabView.swift` — tab shell

## Demo script

1. Complete onboarding with postpartum + high blood pressure or CHD.
2. Home shows personalized insight and preventive checkup reminder.
3. Reels reorder by profile match score.
4. Advocacy practice includes dismissal scenario + stronger response.
5. Roadmap tabs: Pregnancy / General / Postpartum / Lifetime.
6. Community shows % match with consent badges.
7. Profile shows privacy messaging and optional emergency contact demo alert.
