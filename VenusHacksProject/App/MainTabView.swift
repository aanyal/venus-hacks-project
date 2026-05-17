//
//  MainTabView.swift
//  VenusHacksProject
//

import SwiftUI

struct MainTabView: View {
    @Bindable var state: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomNav(tab: $state.selectedTab)
        }
        .sheet(isPresented: $state.showProfile) {
            ProfileView(state: state)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch state.selectedTab {
        case 0:
            HomeView(state: state) { state.showProfile = true }
        case 1:
            ReelsView(state: state)
        case 2:
            AdvocacyView(state: state)
        case 3:
            RoadmapView(state: state)
        default:
            CommunityView(state: state)
        }
    }

}
