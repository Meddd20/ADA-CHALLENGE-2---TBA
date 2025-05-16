//
//  IntructionView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI

struct InstructionView: View {
    var tagId: String

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Title
            Text("Instruction")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3) // Add a subtle shadow
                .padding(.bottom, 10)
            
            // Instruction Card
            VStack {
                RecorderInstructionView()
            }
            .padding()
        }
    }
}


#Preview {
    InstructionView(tagId: "123123123")
}
