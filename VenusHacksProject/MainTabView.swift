//
//  MainTabView.swift
//  VenusHacksProject
//

import SwiftUI

struct MainTabView: View {
    @Bindable var state: AppState

    private var isReels: Bool { state.selectedTab == 1 }

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                if !isReels { statusBar }
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, 72)

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

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.dsSans(DS.FontSize.xs, weight: .black))
                .foregroundStyle(DS.textM)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "cellularbars")
                Image(systemName: "battery.100")
            }
            .font(.system(size: 11))
            .foregroundStyle(DS.textM)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}
