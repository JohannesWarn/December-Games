//
//  GameViewController.swift
//  Chain Pop
//
//  Created by Johannes Wärn on 05/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        
        /* Set the scale mode to scale to fit the window */
        let scene = GameScene()
        scene.size = skView.frame.size
        scene.scaleMode = .AspectFill
        scene.backgroundColor = SKColor.blackColor()
        
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
