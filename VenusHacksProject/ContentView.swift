//
//  ContentView.swift
//  VenusHacksProject
//

import SwiftUI

struct ContentView: View {
    @State private var state = AppState()

    var body: some View {
        Group {
            if state.profile.hasCompletedOnboarding {
                MainTabView(state: state)
            } else {
                OnboardingView(state: state)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
