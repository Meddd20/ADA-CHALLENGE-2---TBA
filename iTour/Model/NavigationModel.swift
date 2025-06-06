//
//  NavigationModel.swift
//  iTour
//
//  Created by Ramdan on 14/05/25.
//

import Foundation

class NavigationManager<T>: ObservableObject {
    @Published var path: [T] = []
}
