//
//  GameScene.swift
//  SpaceShip
//
//  Created by Андрей on 06.12.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
        
    let screenHeight = UIScreen.main.bounds.height
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    var spaceShip: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    
    override func didMove(to view: SKView) {
        
        setScene()
        setWorld()
        setBackground()
        setScore()
        setPlayerShip()
        
        asteroidRain()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        spaceShip.removeAllActions()
        
        let shipLocation = spaceShip.position
        
        let moveSpeed: CGFloat = 250
        let distance = distanceCalc(a: shipLocation, b: touchLocation)
        
        let moveAction = SKAction.move(to: touchLocation, duration: distance/moveSpeed)
        
        spaceShip.run(moveAction)
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            if asteroid.position.y < -self.screenHeight {
                asteroid.removeFromParent()
                self.upScore(by: 1)
            }
        }
    }
    
    private func setScene() {
        self.scene?.size = UIScreen.main.bounds.size
    }
    
    private func setWorld() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
    }
    
    private func setBackground() {
        let backGround = SKSpriteNode(imageNamed: "spaceBG")
        backGround.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.addChild(backGround)
    }
    
    private func setPlayerShip() {
        spaceShip = SKSpriteNode(imageNamed: "playerShip")
        spaceShip.size = CGSize(width: 70, height: 70)
        spaceShip.position = CGPoint(x: 0, y: -373)
        spaceShip.zPosition = 1
        
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        self.addChild(spaceShip)
    }
    
    private func setScore() {
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: 0, y: 300)
        scoreLabel.zPosition = 3
        
        self.addChild(scoreLabel)
    }
    
    private func upScore(by points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }
    
    private func clearScore() {
        score = 0
        scoreLabel.text = "Score: \(score)"
    }
    
    private func createAsteroid() -> SKSpriteNode{
        
        let imageNameDistribution = GKRandomDistribution(lowestValue: 1, highestValue: 4)
        let randomNumber = imageNameDistribution.nextInt()
        let imageName = "meteorBrown_big" + "\(randomNumber)"
        
        let asteroid = SKSpriteNode(imageNamed: imageName)
        
        let positionDistribution = GKRandomDistribution(
            lowestValue: -Int(frame.size.width / 2 + asteroid.size.width),
            highestValue: Int(frame.size.width / 2 - asteroid.size.width)
        )
        asteroid.position.x = CGFloat(positionDistribution.nextInt())
        asteroid.position.y = frame.size.height / 2 + asteroid.size.height
        asteroid.zPosition = 1
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        asteroid.name = "asteroid"
        
        return asteroid
    }
    
    private func asteroidRain() {
        let createAsteroid = SKAction.run {
            let asteroid = self.createAsteroid()
            self.addChild(asteroid)
        }
        let delay = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        let sequence = SKAction.sequence([createAsteroid, delay])
        let runAction = SKAction.repeatForever(sequence)
        
        run(runAction)
    }
    
    private func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        if (bodyA == spaceShipCategory && bodyB == asteroidCategory) ||
            (bodyA == asteroidCategory && bodyB == spaceShipCategory) {
            clearScore()
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}
