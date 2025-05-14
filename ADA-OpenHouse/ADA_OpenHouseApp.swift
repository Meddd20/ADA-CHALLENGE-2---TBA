//
//  ADA_OpenHouseApp.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

enum Routes: Hashable {
    case dashboard
    case details(tagId: String)
}

@main
struct ADA_OpenHouseApp: App {
    @StateObject var navigationManager = NavigationManager<Routes>()

    var body: some Scene {
        WindowGroup {
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
                        }
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
