//
//  IntructionView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI

enum GameViewType: CaseIterable {
    case punch, flip, recorder, compass, ballBalancing, cameraExpression, rockPaperScissors, wordle, slotMachine
}  

struct InstructionView: View {
    var tagId: String
    @State var gameViewType: GameViewType = GameViewType.allCases.randomElement() ?? .punch
    @State var isPlayingGame: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if isPlayingGame {
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
                    Title()
                    SlotMachineView(tagId: tagId)
                case .rockPaperScissors:
                    Title()
                    RockPaperScissorsView(tagId: tagId)
                case .wordle:
                    WordleGameView(tagId: tagId)
                }
            }
            else {
                InstructionStartView(game: $gameViewType, isPlayingGame: $isPlayingGame)
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
