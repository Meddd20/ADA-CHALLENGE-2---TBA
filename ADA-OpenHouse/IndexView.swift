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
            HomeView()
                .environmentObject(navigationManager)
                .onOpenURL { url in
                    handleURL(url)
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
    }
    
    func handleURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        
        // Extract the path and query items from the URL
        let path = components.path
        let queryItems = components.queryItems
        
        // Example: Handle different paths and query parameters
        if path == "/details" {
            if let tagId = queryItems?.first(where: { $0.name == "id" })?.value {
                navigationManager.path.append(.details(tagId: tagId))
            } else {
                print("Tag ID missing")
            }
        } else {
            print("Unknown path: \(path)")
        }
    }
}

#Preview {
    IndexView()
}
