//
//  HomeViewModel.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 20/05/25.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    func shuffleRiddle() -> String {
        riddle.shuffle()
        return riddle.first ?? ""
    }
}
