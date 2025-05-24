//
//  IndexView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI


enum Routes: Hashable {
    case dashboard
    case details(tagId: String)
    case instruction(tagId: String)
}

struct IndexView: View {
    @StateObject var navigationManager = NavigationManager<Routes>()
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
//            HomeView()
            TestUI()
                .onOpenURL { url in
                    let tagId = extractTagId(url)
                    if let tagId = tagId {
                        self.navigationManager.path = .init([.instruction(tagId: tagId)])
                    }
                }
                .navigationDestination(for: Routes.self) { route in
                    switch route {
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
}

#Preview {
    IndexView()
}
