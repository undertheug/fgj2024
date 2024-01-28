//
//  GameScene.swift
//  HabiticaStoriez
//
//  Created by Aki Gibson on 27.01.24.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {

    var backgroundMusic: SKAudioNode!
    var combatMusic: SKAudioNode!
    let backgroundImage = SKSpriteNode(imageNamed: "backgroundImage")
    let heroNode = SKSpriteNode(imageNamed: "heroCharacter")
    let kidNPC = SKSpriteNode(imageNamed: "kidNPC")
    var leftController: SKSpriteNode!
    let dialogBox = SKLabelNode(fontNamed: "Arial")  // Use SKLabelNode for text
    let actionButton = SKSpriteNode(imageNamed: "actionButton")
   
    var dialogManager: DialogManager!

    // Variable to store the direction of hero movement
    var heroMovementDirection: HeroMovementDirection = .none

    enum HeroMovementDirection {
        case none, left, right, up, down, upLeft, upRight, downLeft, downRight
    }

    override func didMove(to view: SKView) {
        // Set up the background image
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.size = CGSize(width: frame.size.width, height: frame.size.width / backgroundImage.size.width * backgroundImage.size.height)
        addChild(backgroundImage)

        // Set up the heroNode
        let heroSize = CGSize(width: 25, height: 25)
        heroNode.size = heroSize
        heroNode.position = CGPoint(x: frame.midX, y: frame.midY)
        heroNode.zPosition = 1
        addChild(heroNode)

        // Set up the kidNPC in the middle of the background image
        // kidNPC.size = CGSize(width: 25, height: 25)
        // kidNPC.position = CGPoint(x: backgroundImage.frame.midX + 135, y: backgroundImage.frame.midY)
        // kidNPC.zPosition = 2
        // addChild(kidNPC)
        
        
        // Set up the kidNPC with zPosition
        kidNPC.zPosition = 2
        kidNPC.size = CGSize(width: 25, height: 25)
        kidNPC.position = CGPoint(x: frame.midX + 135, y: frame.midY)
        addChild(kidNPC)
        
        // Set up the leftController with zPosition
        leftController = SKSpriteNode(imageNamed: "leftController")
        leftController.zPosition = 4
        leftController.size = CGSize(width: 30, height: 30)
        leftController.position = CGPoint(x: leftController.size.width / 2 + backgroundImage.frame.minX + 15, y: leftController.size.height / 2 + backgroundImage.frame.minY + 15)
        addChild(leftController)

        // Create a container node
        let dialogContainer = SKSpriteNode()

        // Set up the dialogBox
        dialogBox.fontSize = 18
        dialogBox.fontColor = SKColor.white
        dialogBox.numberOfLines = 0
        dialogBox.preferredMaxLayoutWidth = frame.size.width - 100
        dialogBox.lineBreakMode = .byWordWrapping

        // Add the dialogBox to the container
        dialogContainer.addChild(dialogBox)

        // Set the size of the container
        dialogContainer.size = CGSize(width: frame.size.width - 100, height: 80)

        // Set the position of the container
        dialogContainer.position = CGPoint(x: frame.midX, y: frame.midY)

        // Set the zPosition to ensure it's drawn above other nodes
        dialogContainer.zPosition = 3

        // Add the container to the scene
        addChild(dialogContainer)

        
        // Set up the actionButton in the lower right corner of the background image
        actionButton.size = CGSize(width: 30, height: 30)
        actionButton.position = CGPoint(x: backgroundImage.frame.maxX - actionButton.size.width / 2 - 15, y: backgroundImage.frame.minY + actionButton.size.height / 2 + 15)
        addChild(actionButton)
        
        
        // Set up the dialog manager
        dialogManager = DialogManager(dialogBox: dialogBox, continueButtonAction: { [weak self] in
            self?.continueDialog()
        }, backButtonAction: { [weak self] in
            self?.goBackInDialog()
        })
        
        
        // Load background music
        if let musicURL = Bundle.main.url(forResource: "main_track", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }

        // Load combat music
        if let combatMusicURL = Bundle.main.url(forResource: "combat_track", withExtension: "mp3") {
            combatMusic = SKAudioNode(url: combatMusicURL)
            addChild(combatMusic)
        }

        // Configure background music
        backgroundMusic.autoplayLooped = true
        backgroundMusic.isPositional = false
        backgroundMusic.run(SKAction.changeVolume(to: 0.5, duration: 0))
        backgroundMusic.run(SKAction.play())
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        processTouches(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        processTouches(touches: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        // Pass the touch location to the DialogManager
        dialogManager.handleTap(at: touchLocation)

        // Reset the hero's movement direction when touches end
        heroMovementDirection = .none
    }

    func processTouches(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        if leftController.contains(touchLocation) {
            // Calculate the angle of the touch relative to the center of the leftController
            let angle = atan2(touchLocation.y - leftController.position.y,
                              touchLocation.x - leftController.position.x)

            // Convert the angle to degrees
            let degrees = angle * 180.0 / CGFloat.pi

            // Update the hero's movement direction based on the touched angle
            if degrees >= -22.5 && degrees < 22.5 {
                heroMovementDirection = .right
            } else if degrees >= 22.5 && degrees < 67.5 {
                heroMovementDirection = .upRight
            } else if degrees >= 67.5 && degrees < 112.5 {
                heroMovementDirection = .up
            } else if degrees >= 112.5 && degrees < 157.5 {
                heroMovementDirection = .upLeft
            } else if degrees >= 157.5 || degrees < -157.5 {
                heroMovementDirection = .left
            } else if degrees >= -157.5 && degrees < -112.5 {
                heroMovementDirection = .downLeft
            } else if degrees >= -112.5 && degrees < -67.5 {
                heroMovementDirection = .down
            } else if degrees >= -67.5 && degrees < -22.5 {
                heroMovementDirection = .downRight
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        moveHero()

        // Check the distance between heroNode and kidNPC
        let distance = distanceBetween(heroNode.position, kidNPC.position)
        
        // Show or hide dialogBox based on distance
        dialogBox.isHidden = distance > 20

        // Switch music based on dialogBox visibility
        if dialogBox.isHidden {
            switchToBackgroundMusic()
        } else {
            switchToCombatMusic()
        }
        
        
    }
    
    
    

    // Function to calculate the distance between two points
    func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }

    func moveHero() {
        let movementSpeed: CGFloat = 5.0  // Adjust the speed as needed

        switch heroMovementDirection {
        case .left:
            heroNode.position.x -= movementSpeed
        case .right:
            heroNode.position.x += movementSpeed
        case .up:
            heroNode.position.y += movementSpeed
        case .down:
            heroNode.position.y -= movementSpeed
        case .upLeft:
            heroNode.position.x -= movementSpeed * cos(CGFloat.pi / 4)
            heroNode.position.y += movementSpeed * sin(CGFloat.pi / 4)
        case .upRight:
            heroNode.position.x += movementSpeed * cos(CGFloat.pi / 4)
            heroNode.position.y += movementSpeed * sin(CGFloat.pi / 4)
        case .downLeft:
            heroNode.position.x -= movementSpeed * cos(CGFloat.pi / 4)
            heroNode.position.y -= movementSpeed * sin(CGFloat.pi / 4)
        case .downRight:
            heroNode.position.x += movementSpeed * cos(CGFloat.pi / 4)
            heroNode.position.y -= movementSpeed * sin(CGFloat.pi / 4)
        default:
            // No movement when direction is .none
            break
        }
    }
    func displayDialog() {
            // Example dialog content
            let dialogText = "Woo: What are we against the endless universe?\n1: Will anything change if you get the answer?\n2: The stars will keep turning into tiny white dwarfs..."
        
            // Show dialog using the DialogManager
            dialogManager.showText(dialogText)
        }
    
    func continueDialog() {
           // Logic for continuing the dialog
       }

    func goBackInDialog() {
           // Logic for going back in the dialog
    }
    
    func switchToBackgroundMusic() {
        combatMusic.run(SKAction.stop())
        backgroundMusic.run(SKAction.play())
    }

    func switchToCombatMusic() {
        backgroundMusic.run(SKAction.stop())
        combatMusic.run(SKAction.play())
    }
    
}







