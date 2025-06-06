//
//  iTour.swift
//  iTour
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI


@main
struct iTour: App {
    @StateObject var colorManager = ColorManager()
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    var body: some Scene {
        WindowGroup {
            IndexView()
                .environmentObject(colorManager)
        }
    }
}
