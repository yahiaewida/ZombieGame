//
//  MainMenuScene.swift
//  ZombieGame
//
//  Created by Yahia Ewida on 3/20/21.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    let MainTapLabel = SKLabelNode(fontNamed: "Glimstick")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed:"MainMenu")
        background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        addChild(background)
        
        MainTapLabel.text = "Tap to begin the game"
        MainTapLabel.fontColor = SKColor.black
        MainTapLabel.fontSize = 80
        MainTapLabel.zPosition = 100
        MainTapLabel.horizontalAlignmentMode = .center
        MainTapLabel.verticalAlignmentMode = .center
        MainTapLabel.position = CGPoint(x: size.width / 2, y: size.height/11)
        
        addChild(MainTapLabel)
    }
    
    func sceneTapped() {
        let myScene = GameScene(size:self.size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
    }
}
