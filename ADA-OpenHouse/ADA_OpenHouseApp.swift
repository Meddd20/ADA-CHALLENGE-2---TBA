//
//  ADA_OpenHouseApp.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI


@main
struct ADA_OpenHouseApp: App {
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    var body: some Scene {
        WindowGroup {
            IndexView()
            
        }
    }
    
    
}
