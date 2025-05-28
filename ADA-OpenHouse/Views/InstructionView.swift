//
//  IntructionView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI

enum GameViewType: CaseIterable {
    case punch, flip, recorder, compass, ballBalancing, cameraExpression, slotMachine, rockPaperScissors
}
struct InstructionView: View {
    var tagId: String
    @State var gameViewType: GameViewType = GameViewType.allCases.randomElement() ?? .punch
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            switch gameViewType {
            case .punch:
                Title()
                PunchDetection(tagId: tagId)
            case .flip:
                Title()
                FlipReactionView(tagId: tagId)
            case .recorder:
                Title()
                RecorderInstructionView(tagId: tagId)
            case .compass:
                Title()
                CompassView(tagId: tagId)
            case .ballBalancing:
                BallBalancingGameView(tagId: tagId)
            case .cameraExpression:
                Title()
                CameraExpression(tagId: tagId)
            case .slotMachine:
                SlotMachineView()
            case .rockPaperScissors:
                Title()
                RockPaperScissorsView(tagId: tagId)
            }
        }
    }
}

struct Title: View {
    var body: some View {
        Text("iTour")
            .font(.system(size: 50))
            .fontWeight(.heavy)
            .bold()
            .padding(.top)
        Spacer()
    }
}


#Preview {
    InstructionView(tagId: "123123123")
}
