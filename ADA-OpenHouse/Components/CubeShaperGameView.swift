//
//  CubeShaperGameView.swift
//  ADA-OpenHouse
//
//  Created by Wira Wibisana on 27/05/25.
//

import SwiftUI
import SceneKit
import CoreMotion
import AVFoundation

struct CubeShaperGameView: View {
    // MARK: - Game State
    @State private var currentWidth: Float = 1.0
    @State private var currentHeight: Float = 1.0
    @State private var currentLength: Float = 1.0
    
    @State private var targetWidth: Float = 1.5
    @State private var targetHeight: Float = 2.0
    @State private var targetLength: Float = 1.2
    
    @State private var hasWon = false
    @State private var showWinAlert = false
    @State private var winAlertScale: CGFloat = 0.5
    @State private var winAlertOpacity: Double = 0.0
    
    // Motion tracking for parallax
    @State private var deviceMotion = CMMotionManager()
    @State private var parallaxOffsetX: CGFloat = 0
    @State private var parallaxOffsetY: CGFloat = 0
    
    // Audio player for victory sound
    @State private var audioPlayer: AVAudioPlayer?
    
    private let minSize: Float = 0.2
    private let maxSize: Float = 3.0
    private let winThreshold: Float = 0.94
    private let material = SCNMaterial()
    
    private var averageProgress: Float {
        let widthProgress = calculateProgress(current: currentWidth, target: targetWidth)
        let heightProgress = calculateProgress(current: currentHeight, target: targetHeight)
        let lengthProgress = calculateProgress(current: currentLength, target: targetLength)
        return (widthProgress + heightProgress + lengthProgress) / 3
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Parallax Background - FULL SCREEN including safe areas
                ParallaxBackgroundView(
                    offsetX: parallaxOffsetX,
                    offsetY: parallaxOffsetY,
                    screenSize: geometry.size
                )
                .ignoresSafeArea(.all) // Ignore ALL safe areas
                
                VStack(spacing: 0) {
                    // Header - perfectly centered with no offset
                    VStack(spacing: 4) {
                        Text("Marshmallow Shaper")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        Text("Get at least 95% accuracy to win!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity) // Full width centering
                    .padding(.top, 120)
                    
                    // 3D Scene View - centered with no offset
                    SceneKitView(
                        width: currentWidth,
                        height: currentHeight,
                        length: currentLength
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: min(geometry.size.height * 0.4, 300))
                    
                    Spacer()
                    
                    // Controls Panel - centered with consistent padding
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Progress")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // Progress bar with proper width and padding
                            HStack {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemRed))
                                        .frame(height: 8)

                                    // Win zone indicator (95% to 100%)
                                    HStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue.opacity(0.8))
                                            .frame(width: 50, height: 8) // Fixed width for win zone
                                    }

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                        .frame(height: 8)
                                        .scaleEffect(x: CGFloat(averageProgress), y: 1.0, anchor: .leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.horizontal, 4) // Small padding to prevent cutoff
                            
                            Text("\(Int(averageProgress * 100))% accurate")
                                .font(.caption2)
                                .foregroundColor(averageProgress >= winThreshold ? .green : .secondary)
                                .fontWeight(averageProgress >= winThreshold ? .bold : .regular)
                        }
                        
                        // Control Sliders
                        VStack(spacing: 12) {
                            ControlSliderView(
                                title: "Width",
                                value: $currentWidth,
                                target: targetWidth,
                                range: minSize...maxSize,
                                winThreshold: winThreshold
                            )
                            
                            ControlSliderView(
                                title: "Height",
                                value: $currentHeight,
                                target: targetHeight,
                                range: minSize...maxSize,
                                winThreshold: winThreshold
                            )
                            
                            ControlSliderView(
                                title: "Length",
                                value: $currentLength,
                                target: targetLength,
                                range: minSize...maxSize,
                                winThreshold: winThreshold
                            )
                        }
                        
                        // New Game Button
                        Button(action: startNewGame) {
                            Text("New Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                    )
                    .padding(20) // Added proper horizontal padding
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Force perfect centering
                
                // Fullscreen Win Alert
                if showWinAlert {
                    ZStack {
                        // Background blur
                        Color.black.opacity(0.7)
                            .ignoresSafeArea(.all)
                            .onTapGesture {
                                handleTapToContinue()
                            }
                        
                        // Win alert content
                        VStack(spacing: 30) {
                            // Trophy icon
                            Text("🏆")
                                .font(.system(size: 100))
                                .scaleEffect(winAlertScale)
                            
                            // Win text
                            VStack(spacing: 16) {
                                Text("CONGRATULATIONS!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                
                                Text("YOU WIN!")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                
                                Text("Perfect accuracy achieved!")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            }
                            
                            // Confetti or sparkles effect
                            HStack(spacing: 20) {
                                ForEach(0..<5, id: \.self) { _ in
                                    Text("✨")
                                        .font(.title2)
                                        .scaleEffect(winAlertScale)
                                }
                            }
                            
                            // Tap to continue instruction
                            VStack(spacing: 8) {
                                Text("TAP TO CONTINUE")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                                
                                // Animated tap indicator
                                Text("👆")
                                    .font(.title2)
                                    .scaleEffect(winAlertScale * 0.8)
                                    .opacity(0.7)
                            }
                        }
                        .scaleEffect(winAlertScale)
                        .opacity(winAlertOpacity)
                        .onTapGesture {
                            handleTapToContinue()
                        }
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                generateRandomTargets()
                startParallaxMotion()
            }
            .onDisappear {
                deviceMotion.stopDeviceMotionUpdates()
            }
            .onReceive([currentWidth, currentHeight, currentLength].publisher) { _ in
                checkWinCondition()
            }
        }
        .ignoresSafeArea(.all) // Also ignore safe area at the main view level
    }
    
    // MARK: - Parallax Motion
    private func startParallaxMotion() {
        if deviceMotion.isDeviceMotionAvailable {
            deviceMotion.deviceMotionUpdateInterval = 1.0 / 60.0
            deviceMotion.startDeviceMotionUpdates(to: .main) { (motion, error) in
                guard let motion = motion else { return }
                
                // Convert device motion to parallax offset - reduced movement to prevent overflow
                let roll = motion.attitude.roll
                let pitch = motion.attitude.pitch
                
                // Reduced parallax movement to prevent ANY offset to other elements
                withAnimation(.easeOut(duration: 0.1)) {
                    parallaxOffsetX = CGFloat(roll) * 8  // Further reduced
                    parallaxOffsetY = CGFloat(pitch) * 5 // Further reduced
                }
            }
        }
    }
    
    // MARK: - Game Logic
    private func generateRandomTargets() {
        targetWidth = Float.random(in: minSize...maxSize)
        targetHeight = Float.random(in: minSize...maxSize)
        targetLength = Float.random(in: minSize...maxSize)
        hasWon = false
        showWinAlert = false
        winAlertScale = 0.5
        winAlertOpacity = 0.0
    }
    
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "VictorySFX", withExtension: "mp3") else {
            print("Could not find VictorySFX.mp3 file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func playVictorySound() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func startNewGame() {
        currentWidth = 1.0
        currentHeight = 1.0
        currentLength = 1.0
        generateRandomTargets()
    }
    
    private func calculateProgress(current: Float, target: Float) -> Float {
        let difference = abs(current - target)
        let maxDifference = max(target, maxSize - target, target - minSize, maxSize - minSize)
        let progress = max(0, 1 - (difference / maxDifference))
        return progress
    }
    
    private func checkWinCondition() {
        let widthProgress = calculateProgress(current: currentWidth, target: targetWidth)
        let heightProgress = calculateProgress(current: currentHeight, target: targetHeight)
        let lengthProgress = calculateProgress(current: currentLength, target: targetLength)
        
        let newWinState = widthProgress >= winThreshold && heightProgress >= winThreshold && lengthProgress >= winThreshold
        
        if newWinState && !hasWon {
            hasWon = true
            showWinAlert = true
            playVictorySound()
            showWinAlertAnimation()
        }
    }
    
    private func handleTapToContinue() {
        withAnimation(.easeOut(duration: 0.5)) {
            showWinAlert = false
            winAlertOpacity = 0.0
        }
        
        // Start new game after fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startNewGame()
        }
    }
    
    private func showWinAlertAnimation() {
        // Animate the win alert appearance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            winAlertScale = 1.0
            winAlertOpacity = 1.0
        }
        
        // Add pulsing animation to the trophy and tap indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                winAlertScale = 1.1
            }
        }
    }
}

// MARK: - Parallax Background View
struct ParallaxBackgroundView: View {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let screenSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layers - with proper scaling to fill entire screen
                ForEach(1...5, id: \.self) { layerIndex in
                    if let image = UIImage(named: "sky\(layerIndex)") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: max(geometry.size.width, screenSize.width) + 60,
                                height: max(geometry.size.height, screenSize.height) + 60
                            )
                            .offset(
                                x: offsetX * CGFloat(layerIndex) * 0.2,
                                y: offsetY * CGFloat(layerIndex) * 0.3
                            )
                            .opacity(1.0 - Double(layerIndex - 1) * 0.1)
                            .clipped()
                    }
                }
                
                // Static gradient overlay - NO parallax offset
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.clear,
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .clipped()
        .ignoresSafeArea(.all)
    }
}

// MARK: - Control Slider Component
struct ControlSliderView: View {
    let title: String
    @Binding var value: Float
    let target: Float
    let range: ClosedRange<Float>
    let winThreshold: Float
    
    private var progress: Float {
        let difference = abs(value - target)
        let maxDifference = max(target, range.upperBound - target, target - range.lowerBound, range.upperBound - range.lowerBound)
        return max(0, 1 - (difference / maxDifference))
    }
    
    private var progressColor: Color {
        let red = Double(1.0 - progress)
        let green = Double(progress)
        return Color(red: red, green: green, blue: 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title and Current Value
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Current: \(String(format: "%.2f", value))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Slider
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Float($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound))
            .accentColor(.blue)
        }
    }
}

// MARK: - SceneKit View Wrapper
struct SceneKitView: UIViewRepresentable {
    let width: Float
    let height: Float
    let length: Float
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Scene setup
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = true
        sceneView.antialiasingMode = .multisampling4X
        
        // Camera setup
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        // Lighting setup
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1200
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.darkGray
        ambientLight.intensity = 300
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Create initial cube
        let cubeGeometry = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(length), chamferRadius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "PlasterTexture.png")
        material.specular.contents = UIColor.white
        material.shininess = 0.3
        cubeGeometry.materials = [material]
        
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.name = "cube"
        scene.rootNode.addChildNode(cubeNode)
        
        // Add rotation animation
        let rotationAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 24)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        cubeNode.runAction(repeatAction)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Find the cube node and update its geometry
        if let cubeNode = uiView.scene?.rootNode.childNode(withName: "cube", recursively: false),
           let geometry = cubeNode.geometry as? SCNBox {
            geometry.width = CGFloat(width)
            geometry.height = CGFloat(height)
            geometry.length = CGFloat(length)

            // Re-apply the material if missing
            if geometry.materials.isEmpty {
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "PlasterTexture.png")
                material.specular.contents = UIColor.white
                material.shininess = 1.0
                geometry.materials = [material]
            }
        }
    }
}

// MARK: - Preview
struct CubeShaperGameView_Previews: PreviewProvider {
    static var previews: some View {
        CubeShaperGameView()
    }
}
