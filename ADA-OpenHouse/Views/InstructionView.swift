//
//  IntructionView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI
import SwiftData

struct InstructionView: View {
    var tagId: String
    @Environment(\.modelContext) private var context
    @EnvironmentObject var navManager: NavigationManager<Routes>

//    @State var gameViewType: GameViewType = .anomaly
    @State var gameViewType: GameViewType = GameViewType.allCases.randomElement() ?? .punch
    @State var isPlayingGame: Bool = false
    @State var isShowAlert: Bool = false
    
    @StateObject var haptic = HapticModel()

    
    func onComplete() {
        isShowAlert = true
        haptic.playHaptic()
        upsertGameViewState(type: gameViewType, isDone: true, context: context)
        upsertTagViewState(tag: tagId, isDone: true, context: context)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navManager.path = .init([.details(tagId: tagId)])
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if isPlayingGame {
                switch gameViewType {
                case .punch:
                    Title()
                    PunchDetection(tagId: tagId, onComplete: onComplete)
                case .flip:
                    Title()
                    FlipReactionView(tagId: tagId, onComplete: onComplete)
                case .recorder:
                    Title()
                    RecorderInstructionView(tagId: tagId, onComplete: onComplete)
                case .compass:
                    Title()
                    CompassView(tagId: tagId, onComplete: onComplete)
                case .ballBalancing:
                    BallBalancingGameView(tagId: tagId, onComplete: onComplete)
                case .cameraExpression:
                    Title()
                    CameraExpression(tagId: tagId, onComplete: onComplete)
                case .slotMachine:
                    SlotMachineView(tagId: tagId, onComplete: onComplete)
                case .rockPaperScissors:
                    Title()
                    RockPaperScissorsView(tagId: tagId, onComplete: onComplete)
                case .wordle:
                    WordleGameView(tagId: tagId, onComplete: onComplete)
                case .cubeShaper:
                    CubeShaperGameView(tagId: tagId, onComplete: onComplete)
                case .speechRecognition:
                    SpeechView(tagId: tagId, onComplete: onComplete)
                case .anomaly:
                    Title()
                    AnomalyView(tagId: tagId, onComplete: onComplete)
                }
            } else {
                InstructionStartView(game: $gameViewType, isPlayingGame: $isPlayingGame)
            }
        }
        .alert(isPresented: $isShowAlert) {
            Alert(title: Text("You WIN!"), message: Text("Congratulations! You completed the game."))
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
