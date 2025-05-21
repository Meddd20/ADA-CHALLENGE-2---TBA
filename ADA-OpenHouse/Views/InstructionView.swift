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
            Text("iTour")
                .font(.system(size: 50))
                .fontWeight(.heavy)
                .bold()
                .padding(.top)
            Spacer()
            PunchDetection(tagId: tagId)
//            FlipReactionView(tagId: tagId)
//            RecorderInstructionView(tagId: tagId)
        }
    }
}


#Preview {
    InstructionView(tagId: "123123123")
}
