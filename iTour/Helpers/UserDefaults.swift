//
//  UserDefaults.swift
//  iTour
//
//  Created by Medhiko Biraja on 25/05/25.
//

import Foundation

extension UserDefaults {
    var didCompleteOnboarding: Bool {
        get { bool(forKey: "didCompleteOnboarding") }
        set { set(newValue, forKey: "didCompleteOnboarding")}
    }
}
