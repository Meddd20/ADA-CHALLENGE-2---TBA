//
//  OnboardingView.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 23/05/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @State private var bottomSheetUp = false
    @State private var navigateHome = false
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            Text("iTour")
                .font(.system(size: 35, weight: .heavy))
                .fontWidth(.expanded)
            
            Spacer()
                .frame(height: 23)
            
            Text("Bring your device close to nfc tag!")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.6))
                .fontWidth(.expanded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Spacer()
                .frame(height: 58)
            
            Image("nfc-guidance")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 65)
            
            Button(action: {
                bottomSheetUp = true
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .bold))
                    .fontWidth(.expanded)
                    .foregroundColor(.white)
                    .frame(width: 246, height: 51)
                    .background(.primaryBlue)
                    .cornerRadius(20)
            }
        }
        .padding()
        .sheet(isPresented: $bottomSheetUp, onDismiss: {
            if navigateHome {
                onComplete()
            }
        }) {
            OnboardingViewSheet (shouldNavigate: $navigateHome, showSheet: $bottomSheetUp)
            .environmentObject(navManager)
            .presentationDetents([.height(800)])
        }
    }
}

struct OnboardingViewSheet: View {
    @State private var selectedPage = 0
    @Binding var shouldNavigate: Bool
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 42)
            
            switch selectedPage {
            case 0:
                explorePage()
            case 1:
                scanNFCPage()
            case 2:
                finishQuestPage()
            default:
                explorePage()
            }
            
            Spacer()
                .frame(height: 80)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    if selectedPage < 2 {
                        selectedPage += 1
                    } else {
                        shouldNavigate = true
                        showSheet = false
                    }
                }
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .bold))
                    .fontWidth(.expanded)
                    .foregroundColor(.white)
                    .frame(width: 246, height: 51)
                    .background(.primaryBlue)
                    .cornerRadius(20)
            }
            
            Spacer()
                .frame(height: 15)
            
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == selectedPage ? Color.white : Color.lightGray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.darkGray)
            .cornerRadius(20)
        }
    }
}

struct explorePage: View {
    var body: some View {
        VStack {
            Text("Explore the area")
                .font(.system(size: 27, weight: .heavy))
                .fontWidth(.expanded)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 58)
            
            Image("explore")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 60)
            
            Text("You are able to walk around and find the NFC tag yourself.")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.6))
                .fontWidth(.expanded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
    }
}

struct scanNFCPage: View {
    var body: some View {
        VStack {
            Text("Scan NFC tag")
                .font(.system(size: 27, weight: .heavy))
                .fontWidth(.expanded)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 58)
            
            Image("scan")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 77)
            
            Text("Tap the button to begin scanning.")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.6))
                .fontWidth(.expanded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
    }
}

struct finishQuestPage: View {
    var body: some View {
        VStack {
            Text("Finish the quest")
                .font(.system(size: 27, weight: .heavy))
                .fontWidth(.expanded)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 58)
            
            Image("finish")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 60)
            
            Text("Complete the challenge to reveal hidden discoveries.")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.6))
                .fontWidth(.expanded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
    }
}

#Preview {
    OnboardingView() {}
    .environmentObject(NavigationManager<Routes>())
}
