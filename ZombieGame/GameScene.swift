//
//  GameScene.swift
//  ZombieGame
//
//  Created by Yahia Ewida on 2/25/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let playableRect: CGRect
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var lastTouchLocation: CGPoint?
    var textures:[SKTexture] = []
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieAnimation: SKAction
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio + 60
        let playableMargin = (size.height-playableHeight)/2.0
        
        playableRect = CGRect(x: 100, y: playableMargin,
                              width: size.width - 200, height: playableHeight)
        
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        debugDrawPlayableArea()
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        
        run(SKAction.repeatForever(
                SKAction.sequence([SKAction.run(spawnEnemy),
                                   SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
                SKAction.sequence([SKAction.run(spawnCat),
                                   SKAction.wait(forDuration: 1.0)])))
        
        
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height/2,
                max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
        zombie.texture = textures[0]
    }
    
    func moveZombieToward(_ location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
        startZombieAnimation()
    }
    
    func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: playableRect.minX, y: playableRect.minY)
        let topRight = CGPoint(x: playableRect.maxX, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        
        // moveSprite(zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - zombie.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
                stopZombieAnimation()
                
            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}

//
//override init(size: CGSize) {
//  let maxAspectRatio:CGFloat = 16.0/9.0
//  let playableHeight = size.width / maxAspectRatio + 60
//  let playableMargin = (size.height-playableHeight)/2.0
//
//  playableRect = CGRect(x: 100, y: playableMargin,
//                        width: size.width - 200, height: playableHeight)
//  super.init(size: size)
//}
