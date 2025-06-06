//
//  ColorManger.swift
//  iTour
//
//  Created by Medhiko Biraja on 03/06/25.
//

import SwiftUI

class ColorManager: ObservableObject {
    @Published var primaryColor: Color = .primaryBlue
    @Published var primaryDarkColor: Color = .darkBlue
    
    @Published var completedPrimaryColor: Color = .primaryBlue
    @Published var completedPrimaryDarkColor: Color = .darkBlue
}
