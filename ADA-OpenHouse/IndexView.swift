//
//  IndexView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI


enum Routes: Hashable {
    case home
    case dashboard
    case details(tagId: String)
    case instruction(tagId: String)
}

struct IndexView: View {
    @StateObject var navigationManager = NavigationManager<Routes>()
    @State private var didCompleteOnboarding = false
    
    var body: some View {        
        NavigationStack(path: $navigationManager.path) {
            contentView()
            .onOpenURL { url in
                if let tagId = extractTagId(url) {
                    navigationManager.path = [.instruction(tagId: tagId)]
                }
            }
            .navigationDestination(for: Routes.self) { route in
                switch route {
                case .home:
                    HomeView()
                case .dashboard:
                    Text("Dashboard")
                case .details(let tagId):
                    DetailView(tagId: tagId)
                case .instruction(let tagId):
                    InstructionView(tagId: tagId)
                }
            }
        }
        .environmentObject(navigationManager)
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        if didCompleteOnboarding {
            HomeView()
                .transition(.opacity.combined(with: .slide))
        } else {
            OnboardingView {
                didCompleteOnboarding = true
                UserDefaults.standard.didCompleteOnboarding = true
            }
        }
    }
}


#Preview {
    IndexView()
}
