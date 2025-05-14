//
//  ContentView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

enum Routes: Hashable {
    case dashboard
    case details(tagId: String)
}

struct ContentView: View {
    @StateObject var navigationManager = NavigationManager<Routes>()
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            HomeView()
                .navigationDestination(for: Routes.self) { route in
                    switch route {
                    case .dashboard:
                        Text("Dashboard")
                    case .details(let tagId):
                        Text("Details for \(tagId)")
                    }
                }
        }
        .environmentObject(navigationManager)
    }
}


#Preview {
    ContentView()
}
