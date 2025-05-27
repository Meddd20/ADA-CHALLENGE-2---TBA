import SpriteKit
import CoreMotion
import AVFoundation

extension SKSpriteNode {
    // This extension is useful for scaling other nodes, but for the background
    // that needs to fill the entire scene, directly setting its 'size' is more appropriate.
    func scaleToFill(_ size: CGSize) {
        let horizontalScale = size.width / self.size.width
        let verticalScale = size.height / self.size.height
        self.xScale = horizontalScale
        self.yScale = verticalScale
    }
}

class BallBalancingGameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    private var ball: SKNode?
    private var goal: SKNode?
    private let motionManager = CMMotionManager()
    private var isGameOver = false

    // Z-Positions for layering
    private var backgroundZPosition: CGFloat = 0
    private var wallsZPosition: CGFloat = 0
    private var pitsZPosition: CGFloat = 0
    private var ballZPosition: CGFloat = 0
    private var goalZPosition: CGFloat = 0

    // Sound effect players
    private var explosionSoundPlayer: AVAudioPlayer?
    private var bonusSoundPlayer: AVAudioPlayer?

    // Category BitMasks
    private let ballCategory: UInt32 = 0x1 << 0
    private let pitCategory: UInt32 = 0x1 << 1
    private let wallCategory: UInt32 = 0x1 << 2
    private let goalCategory: UInt32 = 0x1 << 3

    // Game state
    var onGameOver: ((Bool) -> Void)?

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        // Force the scene size to match the view's bounds
        self.size = view.bounds.size
        print("Scene size in didMove:", self.size)

        // Add debug red background to ensure the scene fills the screen
        let debugBackground = SKSpriteNode(color: .red, size: self.size)
        debugBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        debugBackground.zPosition = -10
        addChild(debugBackground)

        // Setup physics of the world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        setupAudio()
        setupGame()
        startMotionUpdates()
    }

    private func setupAudio() {
        // Load explosion sound
        if let explosionSoundURL = Bundle.main.url(forResource: "Arcade Game Explosion Sound", withExtension: "wav") {
            do {
                explosionSoundPlayer = try AVAudioPlayer(contentsOf: explosionSoundURL)
                explosionSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading explosion sound: \(error)")
            }
        } else {
            print("Could not find Arcade Game Explosion Sound.wav")
        }

        // Load bonus sound
        if let bonusSoundURL = Bundle.main.url(forResource: "Arcade Bonus Alert", withExtension: "wav") {
            do {
                bonusSoundPlayer = try AVAudioPlayer(contentsOf: bonusSoundURL)
                bonusSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading bonus sound: \(error)")
            }
        } else {
            print("Could not find Arcade Bonus Alert.wav")
        }
    }

    // MARK: - Game Setup
    private func setupGame() {
        // Create background
        backgroundColor = .red // Fallback color if image fails to load

        let solidBackground = SKSpriteNode(color: .blue, size: self.size)
            solidBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
            solidBackground.zPosition = backgroundZPosition
            addChild(solidBackground)
        
        // Create and add the lava background image
        let lavaBackgroundTexture = SKTexture(imageNamed: "LavaBackground.jpeg")
        let lavaBackground = SKSpriteNode(texture: lavaBackgroundTexture)

        // Set the background's position to the center of the scene
        lavaBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        lavaBackground.zPosition = backgroundZPosition
        lavaBackground.alpha = 1

        // The scene's 'size' property is already set to the full screen bounds by ContentView.
        lavaBackground.size = self.size // This makes the background fill the entire scene

        addChild(lavaBackground)

        // Create walls (boundaries)
        createWalls()
        wallsZPosition = 1

        // Create pits
        pitsZPosition = -1
        createPits()

        // Create ball (ghost)
        ballZPosition = 2
        createBall()

        // Create goal (flag)
        goalZPosition = 2
        createGoal()
    }

    private func createBall() {
        let ghostEmoji = SKLabelNode(text: "👻")
        ball = ghostEmoji

        guard let ball = ball as? SKLabelNode else { return }

        ball.fontSize = 45
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.15)
        ball.zPosition = ballZPosition

        ball.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.restitution = 0.5
        ball.physicsBody?.friction = 0.2
        ball.physicsBody?.linearDamping = 0.5
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = pitCategory | goalCategory
        ball.physicsBody?.collisionBitMask = wallCategory

        addChild(ball)
    }

    private func createGoal() {
        let goalEmoji = SKLabelNode(text: "🏁")
        goal = goalEmoji

        guard let goal = goal as? SKLabelNode else { return }

        goal.fontSize = 50
        goal.position = CGPoint(x: size.width * 0.76, y: size.height * 0.85)
        goal.zPosition = goalZPosition

        goal.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.categoryBitMask = goalCategory
        goal.physicsBody?.contactTestBitMask = ballCategory
        goal.physicsBody?.collisionBitMask = 0

        addChild(goal)
    }

    private func createWalls() {
        let wallThickness: CGFloat = 10.0

        // Top wall
        let topWall = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: wallThickness))
        topWall.position = CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.categoryBitMask = wallCategory
        topWall.zPosition = wallsZPosition // Ensure walls are at correct Z-position

        // Bottom wall
        let bottomWall = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: wallThickness))
        bottomWall.position = CGPoint(x: size.width / 2, y: wallThickness / 2)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.categoryBitMask = wallCategory
        bottomWall.zPosition = wallsZPosition

        // Left wall
        let leftWall = SKSpriteNode(color: .clear, size: CGSize(width: wallThickness, height: size.height))
        leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = wallCategory
        leftWall.zPosition = wallsZPosition

        // Right wall
        let rightWall = SKSpriteNode(color: .clear, size: CGSize(width: wallThickness, height: size.height))
        rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = wallCategory
        rightWall.zPosition = wallsZPosition

        addChild(topWall)
        addChild(bottomWall)
        addChild(leftWall)
        addChild(rightWall)
    }

    private func createPits() {
        // Example: Creating multiple rotated rectangular pits to align with lava
        // Ensure pits are also using the scene's size for relative positioning
        createPitHitbox(at: CGPoint(x: size.width * 0.25, y: size.height * 0.8),
                        size: CGSize(width: size.width * 0.2, height: size.height * 0.6),
                        rotation: -0.3, // in radians
                        zPosition: pitsZPosition)

        createPitHitbox(at: CGPoint(x: size.width * 0.9, y: size.height * 0.7),
                        size: CGSize(width: size.width * 0.3, height: size.height * 0.2),
                        rotation: -0.2,
                        zPosition: pitsZPosition)

        createPitHitbox(at: CGPoint(x: size.width * 0.15, y: size.height * 0.5),
                        size: CGSize(width: size.width * 1, height: size.height * 0.1),
                        rotation: 1.5,
                        zPosition: pitsZPosition)

        createPitHitbox(at: CGPoint(x: size.width * 0.96, y: size.height * 0.35),
                        size: CGSize(width: size.width * 0.45, height: size.height * 2.0),
                        rotation: -0.12,
                        zPosition: pitsZPosition)

        createPitHitbox(at: CGPoint(x: size.width * 0.05, y: size.height * 0.2),
                        size: CGSize(width: size.width * 0.6, height: size.height * 0.12),
                        rotation: -2.0,
                        zPosition: pitsZPosition)
    }

    private func createPitHitbox(at position: CGPoint, size: CGSize, rotation: CGFloat, zPosition: CGFloat) {
        let pitHitbox = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size), cornerRadius: 0)
        pitHitbox.fillColor = UIColor.red.withAlphaComponent(0)
        pitHitbox.strokeColor = UIColor.red
        pitHitbox.lineWidth = 2
        pitHitbox.position = position
        pitHitbox.zRotation = rotation
        pitHitbox.zPosition = zPosition

        pitHitbox.physicsBody = SKPhysicsBody(rectangleOf: size)
        pitHitbox.physicsBody?.isDynamic = false
        pitHitbox.physicsBody?.categoryBitMask = pitCategory
        pitHitbox.physicsBody?.contactTestBitMask = ballCategory
        pitHitbox.physicsBody?.collisionBitMask = 0

        addChild(pitHitbox)
    }

    // MARK: - Core Motion
    private func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data, error == nil, let self = self, !self.isGameOver else { return }

                let force = CGVector(dx: data.acceleration.x * 10, dy: data.acceleration.y * 10)
                self.ball?.physicsBody?.applyForce(force)
            }
        }
    }

    private func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
    }

    // MARK: - Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == ballCategory | pitCategory {
            if let ballPosition = ball?.position {
                explosionSoundPlayer?.play()

                let explosionEmoji = SKLabelNode(text: "💥")
                explosionEmoji.fontSize = 40
                explosionEmoji.position = ballPosition
                addChild(explosionEmoji)

                ball?.removeFromParent()
                ball = nil

                let wait = SKAction.wait(forDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                explosionEmoji.run(sequence)
            }
            gameOver(didWin: false)
        } else if collision == ballCategory | goalCategory {
            bonusSoundPlayer?.play()
            if let ballPosition = ball?.position {
                let trophyEmoji = SKLabelNode(text: "🏆")
                trophyEmoji.fontSize = 40
                trophyEmoji.position = ballPosition
                addChild(trophyEmoji)

                ball?.removeFromParent()
                ball = nil

                let wait = SKAction.wait(forDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                trophyEmoji.run(sequence)
            }
            gameOver(didWin: true)
        }
    }

    private func gameOver(didWin: Bool) {
        isGameOver = true
        stopMotionUpdates()

        let message = didWin ? "You Win!" : "Game Over!"
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = message
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = didWin ? .green : .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)

        onGameOver?(didWin)

        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 25
        restartLabel.fontColor = .black
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(restartLabel)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            // When restarting, ensure the new scene also gets the full screen size
            let newScene = BallBalancingGameScene(size: UIScreen.main.bounds.size) // Use UIScreen.main.bounds.size here
            newScene.scaleMode = .resizeFill
            newScene.onGameOver = onGameOver
            view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

    // MARK: - Cleanup
    deinit {
        stopMotionUpdates()
    }
}
