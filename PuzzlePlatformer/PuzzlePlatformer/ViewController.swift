//
//  ViewController.swift
//  PuzzlePlatformer
//
//  Created by Owen Gallagher on 16/11/15.
//  Copyright © 2015 Owen. All rights reserved.
//

// Possible Names:  Jigsaw, Key, Blue, Poly, Shift, Rift, Quaker...

import Foundation
import UIKit
import CoreGraphics
import CoreMotion

var timer = NSTimer()
var timerRotateSlide = NSTimer()
var timerStatics = NSTimer()
var timerButtons = NSTimer()

var viewWidth: Float = 320                     //These initial values are the dimensions of the iPhone 4s, which represents the interactive view area
var viewHeight: Float = 480
var screenWidth = 320
var screenHeight = 480
var scale: Float = 1
var centerX = viewWidth/2
var centerY = viewHeight/2

let gravity = Vector(X: 0, Y: 1)

var finalCursor: CGPoint!
var initialCursor: CGPoint!

var player: Player = Player()
var levels: [Level] = []
var buttons: [Button] = []

var level = 0
var previousLevel = 0
var levelSelect = 1
var highestLevel: Int? = 0
var beatenLevels: String? = "0"
var reset = false

var rotationIndicatorAngle: Double = 0

//———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————— GLOBAL SETUP

class ViewController: UIViewController {
    var motionManager: CMMotionManager = {
        let motion = CMMotionManager()
        motion.deviceMotionUpdateInterval = 0.1
        return motion
    }()
    
    let queue = NSOperationQueue.mainQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = Int(self.view.bounds.width)
        screenHeight = Int(self.view.bounds.height)
        
        let scaleW = Float(screenWidth) / viewWidth
        let scaleH = Float(screenHeight) / viewHeight
        
        if scaleW < scaleH {
            scale = scaleW
            viewWidth = Float(screenWidth)
            viewHeight *= scale
            centerY = Float(screenHeight)*1.5 - (Float(screenHeight)/2 + viewHeight/2)
        }
        else {
            scale = scaleH
            viewWidth *= scale
            viewHeight = Float(screenHeight)
            centerY = Float(screenHeight)/2
        }
        centerX = Float(screenWidth)/2
        
        NSUserDefaults.standardUserDefaults().setObject(18, forKey: "highestLevel") //Last completed level
        
        let saveData = NSUserDefaults.standardUserDefaults()
        highestLevel = saveData.integerForKey("highestLevel")
        beatenLevels = saveData.stringForKey("beatenLevels")
        
        if highestLevel == nil {
            highestLevel = 0
        }
        if beatenLevels == nil {
            beatenLevels = "0"
            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "beatenLevels")
        }
        
        self.motionManager.startDeviceMotionUpdates()
        self.motionManager.startDeviceMotionUpdatesToQueue(queue) {
            (data, error) in
            if levels[level].enableRotation {
                let rotation = atan2(data!.gravity.x, data!.gravity.y) - (M_PI * 0.5)
                gravity.set(createVectorFromAngle(Float(rotation)))
            }
            else {
                gravity.set(Vector(X: 0, Y: 1))
            }
        }
        
        createLevels()
        createButtons()
    }
    
    func createLevels() {
        //————————————————————————————————————————————————————————————————— 0: Menu
        levels.append(Level(start: Vector(X: -90, Y: 100), rotates: false))
            levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: 100), a: 20, t: "Tap the desired level\nSwipe for more levels"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: 190), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 1: Almost nothing
        levels.append(Level(start: Vector(X: -100, Y: 0), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 100), v: "-150,-10 150,-10 150,10 -150,10", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: -170), a: 30, t: "Swipe to move\nthe blue square"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: 20), a: 25, t: "To the green\none"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 89), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 2: One chasm
        levels.append(Level(start: Vector(X: -90, Y: -30), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -115, Y: 20), v: "-20,-10 160,-10 160,10 -20,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 130, Y: 180), v: "-50,-20 20,-20 20,20 -50,20", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: -140), a: 70, t: "Try not to\ntouch"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 90), a: 60, t: "the edges"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 159), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 3: Statics
        levels.append(Level(start: Vector(X: -90, Y: -50), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-40,-20 -30,-30 50,-30 60,-20 60,20 50,30 -30,30 -40,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "Swiping is only enabled\nwhen touching the\nground"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 160), a: 30, t: "So no flying"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: 109), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 4: Chimneys
        levels.append(Level(start: Vector(X: 130, Y: -80), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 100, Y: -40), v: "-45,-10 -40,-15 45,-15 45,15 -45,15", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: -50), v: "-5,-25 5,-25 5,25 -5,25", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: 70), v: "-15,-100 15,-100 15,100 -15,100", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: 70), v: "-15,-100 15,-100 15,100 -15,100", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -35, Y: -40), v: "-65,-15 60,-15 65,-10 65,15 -65,15", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 43, Y: 190), v: "-10,-5 10,-5 10,5 -10,5", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: -105), v: "-5,-80 5,-80 5,80 -5,80", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -55, Y: -160), v: "-5,-25 5,-25 5,80 -5,80", rotates: false, slides: false))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -160), a: 40, t: "You can\njump"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 10), a: 70, t: "from\nwalls"))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: -61, Y: -170), a: Float(M_PI*1.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 43, Y: 184), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 5: Triangles
        levels.append(Level(start: Vector(X: -115, Y: -190), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -80), v: "-60,-60 50,40 50,50 -70,50 -70,-60", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 55, Y: 40), v: "70,-80 -70,60 -70,70 80,70 80,-80", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 50), v: "-30,-40 30,20 30,30 -40,30 -40,-40", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -20, Y: 200), v: "-100,-10 100,-10 100,10 -100,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -110, Y: 170), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: -140), a: 20, t: "Feel free to swipe in any\n    direction, not just the\n        cardinal ones"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 40), a: Float(M_PI*0.25), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 104, Y: -20), a: Float(M_PI*1.75), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 20,Y: 189), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 6: Classic
        levels.append(Level(start: Vector(X: -55, Y: -10), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: -20), v: "-5,-38 5,-38 5,32 -5,32", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: 20), v: "-80,-8 160,-8 160,8 -80,8", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -5, Y: 5), v: "0,-20 20,10 -20,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 45, Y: 5), v: "0,-25 50,-25 65,10 -30,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 125, Y: -40), v: "-20,-8 25,-8 25,8 -20,8", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: -48), v: "0,-20 0,0 -20,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 50, Y: -80), v: "-40,-5 23,-5 23,5 -40,5", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -140, Y: 0), v: "-10,-100 10,-100 10,200 -10,200", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 190), v: "-130,-10 140,-10 140,10 -130,10", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: 179), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: 179), a: 0, t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -145, Y: -140), a: 25, t: "Shorter swipe = shorter jump"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -65, Y: 120), a: 15, t: "Don't touch those"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 45, Y: -86), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 179), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 7: First gravitational rotation
        levels.append(Level(start: Vector(X: 0, Y: 50), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 200), v: "-160,-10 160,-10 160,10 -160,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: 0), v: "-10,-150 10,-150 10,200 -10,200", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -150), v: "-160,-10 160,-10 160,10 -160,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -150, Y: -90), v: "-10,-50 10,-50 10,50 -10,50", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: -120), a: 25, t: "That curly arrow in the\ncorner is \na restart button"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -100), a: 40, t: "not"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: 120), a: 25, t: "Try rotating\nthe device"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -139, Y: -100), a: Float(M_PI*0.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 8: Square within a square
        levels.append(Level(start: Vector(X: 0, Y: 0), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 130), v: "-110,-10 110,-10 110,10 -110,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 120, Y: 120), v: "0,-10 20,-10 -10,20 -10,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 130, Y: 0), v: "-10,-110 10,-110 10,110 -10,110", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 120, Y: -120), v: "-10,0 -10,-20 20,10 0,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -130), v: "-110,-10 110,-10 110,10 -110,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X:-120, Y: -120), v: "10,0 10,-20 -20,10 0,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -130, Y: 0), v: "-10,-110 10,-110 10,110 -10,110", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: 120), v: "0,-10 -20,-10 10,20 10,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -30), v: "-90,-10 90,-10 90,10 -90,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -0), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: 90), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 20), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 10), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 0), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: -10), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 110), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 100), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 90), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 80), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 70), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 59), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -10, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 10, Y: -41), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 20, Y: -41), a: 0, t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: -180), a: 25, t: "Now put"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -100), a: 35, t: "movement"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: 25), a: 25, t: "and"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: 20), a: 35, t: "rotation"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 155), a: 25, t: "together"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -119), a: Float(M_PI), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 80), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -41), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 9: Elongated spiral
        levels.append(Level(start: Vector(X: -70,Y: -180), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: -160), v: "-50,-10 60,-10 60,10 -60,10 -60,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: -55), v: "-10,-115 10,-115 10,115 -10,115", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-10,-150 10,-150 10,150 -10,150", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: 160), v: "-90,-10 90,-10 90,0 80,10 -80,10 -90,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: 110), v: "-10,-40 10,-40 10,40 -10,40", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -160), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -150), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -140), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -130), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -120), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -110), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -100), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -90), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -80), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -70), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -60), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: 69), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 10, Y: 61), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 34, Y: 149), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 44, Y: 149), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 54, Y: 149), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 10), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 0), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -10), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -20), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -30), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -40), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -50), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -60), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -70), a: Float(M_PI*0.5), t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: -150), a: 25, t: "Your gravity\nonly changes\nwhen you're\ntouching\nground"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -149), a: Float(M_PI), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 20, Y: 171), a: Float(M_PI), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: 35), a: Float(M_PI*0.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 10: First rounded
        levels.append(Level(start: Vector(X: -120, Y: 55), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90.72, Y: 80.72), v: "-50,-10 20,-10 20,10 -50,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: 61), v: "-10,-10 10,-10 10,10 -10,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 90.72, Y: -100.72), v: "-20,-40 20,-40 20,40 -20,40", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 0), v: "-100,0 100,0 100,10 0,100 -100,10", rotates: true, slides: false))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: -200), a: 50, t: "Rounded\nground\nalways"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: 130), a: 55, t: "stays  upright"))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: 69.28, Y: -110), a: Float(M_PI * 1.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 11: Toothbrush
        levels.append(Level(start: Vector(X: -50,Y: -160), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -110), v: "-50,-15 70,-15 70,15 -70,15 -70,0", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -110, Y: 15), v: "-10,-110 10,-110 10,100 0,110 -10,110", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -60), v: "-60,-10 50,-10 55,-5 55,5 50,10 -60,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: -40), v: "-20,-10 20,-10 20,10 -20,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: -20), v: "-50,-10 20,-10 25,-5 25,5 20,10 -50,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 10), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 30), v: "-40,-10 10,-10 10,10 -40,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -20, Y: 90), v: "-10,-50 10,-50 10,40 0,50 -10,50", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -80, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -60, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -10, Y: -94), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -94), a: Float(M_PI), t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -40), a: 30, t: "       The\n   best\nway\nmay not\nbe the"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 145), a: 55, t: "only  way"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 11, Y: -40), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -1, Y: 5), a: Float(M_PI*1.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 12: Getting the hang of it
        levels.append(Level(start: Vector(X: -130, Y: -180), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 0), v: "-100,0 100,0 100,10 0,100 -100,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: -80), v: "-50,-10 50,-10 50,10 -50,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: 150), v: "-10,-50 10,-50 10,50 -10,50", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -180), a: 85, t: "Don't"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: -60), a: 40, t: "slide  too\n\n\n\n                far..."))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 1, Y: 165), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -21, Y: 145), a: Float(M_PI*1.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 13: Nostalgia
        levels.append(Level(start: Vector(X: 80, Y: 100), rotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-50,-20 -40,-30 50,-30 60,-20 60,20 50,30 -40,30 -50,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "Remember this one?\n   Here's a hint: when you\n       drag your finger, the\n         square doesn't move\n           until you release it."))
            levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 160), a: 30, t: "     Now go up"))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -31), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 14: Alignment introduction
        levels.append(Level(start: Vector(X: -100, Y: -200), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: -150), v: "-40,0 40,0 40,10 0,40 -40,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -25, Y: -140), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: -160), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: -70), v: "-60,0 60,0 60,10 0,60 -60,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 8, Y: 51), v: "-70,0 70,0 70,10 0,70 -70,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: 170), v: "50,-40 60,-40 60,40 -60,40 -60,30", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -45, Y: -151), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -35, Y: -151), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -25, Y: -151), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -151), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -5, Y: -151), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 15, Y: -191), a: 0, t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -160), a: 40, t: "    There\n    is"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -35), a: 55, t: "nothing"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 20), a: 48, t: "to\nsay."))
            levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: 130), a: 20, t: "...In addition to\nwhat I just said,\nI mean."))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -71), a: 0, t: "door", p: 3))
            levels[levels.count-1].addItem(Item(l: Vector(X: 65, Y: 50), a: 0, t: "door", p: 4))
            levels[levels.count-1].addItem(Item(l: Vector(X: -82, Y: 181), a: Float(-1 * atan(0.63)), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 11, Y: 200), a: Float(M_PI * 0.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 15: Door crowding
        levels.append(Level(start: Vector(X: 80, Y: 100), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-40,-20 -30,-30 50,-30 60,-20 60,20 50,30 -30,30 -40,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "This is the last time \nthat I copy this level.\n\n                 I promise."))
            
            levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 101, Y: 40), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: 71), a: Float(M_PI), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -31), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -121, Y: 0), a: Float(M_PI*1.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 16: Uneven Random
        levels.append(Level(start: Vector(X: -110, Y: 90), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 115), v: "-50,0 50,0 50,10 0,50 -50,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 170), v: "-70,-5 60,-5 60,5 -70,5", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: 100), v: "-5,-35 5,-35 5,75 -5,75", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -35), v: "-30,-80 -10,-100 20,-100 30,-90 30,100 -30,100", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: -80), v: "-40,-20 40,-20 40,20 -40,20", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: -20), v: "-40,0 40,0 40,10 0,40 -40,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 110, Y: 60.62), v: "-50,0 50,0 50,10 0,50 -50,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 105, Y: 160.62), v: "-5,-50 5,-50 5,50 -5,50", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 99, Y: 200), a: Float(M_PI*1.5), t: "button"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: 164), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: 66), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -60, Y: 66), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 66), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 66), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: 66), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 55), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 45), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 35), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 55), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 45), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 35), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 40, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 60, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 90, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -101), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -90), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -80), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -70), a: Float(M_PI*0.5), t: "spike")) 
            levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -59), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: -59), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 90, Y: -59), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -59), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -90), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -80), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -70), a: Float(M_PI*1.5), t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -135, Y: -190), a: 25, t: "That little yellow thing \nin the corner is a"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -140), a: 45, t: "b"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -110), a: 45, t: "u"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -80), a: 45, t: "t"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -50), a: 45, t: "t"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -20), a: 45, t: "o"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 10), a: 45, t: "n"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: -80), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: 200), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -125, Y: 176), a: Float(M_PI), t: "door", k: 0))
        
        //————————————————————————————————————————————————————————————————— 17: Spike hoops
        levels.append(Level(start: Vector(X: -10, Y: 45), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 100), v: "-50,-10 50,-10 50,10 -50,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -45, Y: 75), v: "-10,-35 10,-35 10,35 0,35 -10,25", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 165), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: 20), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 75, Y: 20), v: "-30,-10 10,-10 10,10 -30,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -85), v: "-10,-115 10,-115 10,115 -10,115", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: -65), v: "-40,-10 36,-10 36,10 -40,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: -95), v: "-10,-40 10,-40 10,40 -10,40", rotates: false, slides: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: 61, Y: 100), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 111), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -9, Y: 20), a: Float(M_PI*0.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 44, Y: 20), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 75, Y: 9), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 45, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 35, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 15, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 5, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -5, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -54), a: Float(M_PI), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -125), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -115), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -105), a: Float(M_PI*1.5), t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -136), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -80, Y: -201), a: 0, t: "spike"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -69, Y: -190), a: Float(M_PI*0.5), t: "spike"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -180), a: 37, t: "Precision"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -125), a: 55, t: "is"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -40), a: 25, t: "probably"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 35), a: 40, t: "the\n\nfor this     level"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: 38), a: 30, t: "key word"))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -69, Y: -30), a: Float(M_PI*0.5), t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: -76), a: 0, t: "door"))
            levels[levels.count-1].addItem(Item(l: Vector(X: -91, Y: -170), a: Float(M_PI*1.5), t: "door"))
        
        //————————————————————————————————————————————————————————————————— 18: Align the Bridge
        levels.append(Level(start: Vector(X: -90, Y: -120), rotates: true))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -100), v: "-25,0 25,0 25,10 0,25 -25,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 100), v: "-25,0 25,0 25,10 0,25 -25,10", rotates: true, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -60, Y: -140), v: "-5,-40 5,-40 5,40 -5,40", rotates: true, slides: false, pivotNum: 0))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -5, Y: -175), v: "-50,-5 50,-5 50,5 -50,5", rotates: true, slides: false, pivotNum: 0))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: 60), v: "-5,-40 5,-40 5,40 -5,40", rotates: true, slides: false, pivotNum: 1))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -130, Y: 25), v: "-25,-5 25,-5 25,5 -25,5", rotates: true, slides: false, pivotNum: 1))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 75, Y: -160), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false, keyNum: 2))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 60, Y: -20), v: "-30,-8 30,-8 30,8 -30,8", rotates: false, slides: false, keyNum: 1))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 80, Y: 40), v: "-50,-8 50,-8 50,8 -50,8", rotates: false, slides: false, keyNum: 1))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -65, Y: 99), a: 0, t: "button", p: 1))
            levels[levels.count-1].addItem(Item(l: Vector(X: 35, Y: -181), a: 0, t: "button", p: 0))
            levels[levels.count-1].addItem(Item(l: Vector(X: 60, Y: -29), a: 0, t: "button", k: 1))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -145, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
            levels[levels.count-1].addItem(Item(l: Vector(X: -125, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
            levels[levels.count-1].addItem(Item(l: Vector(X: -105, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
            levels[levels.count-1].addItem(Item(l: Vector(X: -94, Y: 30), a: Float(M_PI*0.5), t: "spike", p: 1, k: 0, i: false))
            levels[levels.count-1].addItem(Item(l: Vector(X: -94, Y: 60), a: Float(M_PI*0.5), t: "spike", p: 1, k: 0, i: false))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -92, Y: -101), a: 0, t: "door", p: 0, k: 0))
            levels[levels.count-1].addItem(Item(l: Vector(X: 95, Y: -171), a: 0, t: "door", k: 2))
            levels[levels.count-1].addItem(Item(l: Vector(X: 120, Y: 31), a: 0, t: "door", k: 1))
        
        //————————————————————————————————————————————————————————————————— 19: Sliding Trap-door
        levels.append(Level(start: Vector(X: -120, Y: 180), rotates: true, gravityRotates: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: 200), v: "-20,0 -10,-10 20,-10 20,10 -20,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: -60, Y: 200), v: "-40,-10 -20,-40 40,-40 40,10 -40,10", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 170), v: "-40,-10 -30,-30 40,-30 40,40 -40,40", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 110, Y: 0), v: "-40,150 -40,140 25,-125 50,-125 50,150", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -140), v: "-30,-5 30,-5 30,5 -30,5", rotates: false, slides: false))
            levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: 0), v: "-30,-30 30,-30 30,30 -30,30", rotates: false, slides: true, railStart: Vector(X: 30, Y: -105), railEnd: Vector(X: 30, Y: 110)))
        
            levels[levels.count-1].addItem(Item(l: Vector(X: -60, Y: -120), a: 0, t: "door"))
        
        //————————————————————————————————————————————————————————————————— 20: Guillotine
        
        //————————————————————————————————————————————————————————————————— 21: Boat
        
        //————————————————————————————————————————————————————————————————— 22: Falling Sideways
        
        //————————————————————————————————————————————————————————————————— 23: Wound Chain
    }
    
    func createButtons() {
        var link = 0
        var xPos = 0
        var yPos = 0
        
        for var z=0; z<3; z++ {
            for var y=0; y<3; y++ {
                for var x=0; x<3; x++ {
                    link = x+1+(y*3)+(z*9)
                    xPos = Int(centerX) - Int(130 * scale) + (z*Int(viewWidth))
                    xPos += x * Int((80+35) * scale)
                    yPos = y * Int((80+40) * scale)
                    
                    let newButton = Button(l: Vector(X: Float(xPos), Y: Float(yPos) + (centerY - 200*scale)), r: Int(40*scale), lnk: link, lvl: 0)
                    buttons.append(newButton)
                }
            }
        }
        buttons.append(Button(l: Vector(X: Float(screenWidth) - 45*scale, Y: 32*scale), r: Int(40*scale), lnk: 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————— MY VIEWS


class TouchAndDisplayView: UIView {
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        initialCursor = touches.first?.locationInView(self)
        finalCursor = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        finalCursor = touches.first?.locationInView(self)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        
        if levels[level].enableRotation && rotationIndicatorAngle < 1 {
            CGContextBeginPath(context)
            UIColor.init(red: 0, green: 0.2, blue: 1, alpha: 0.5).set()
            CGContextSetLineWidth(context, CGFloat(3*scale))
            CGContextAddArc(context, CGFloat(25*scale), CGFloat(25*scale), CGFloat(10*scale), CGFloat(M_PI*0.1), CGFloat((M_PI*1.7*rotationIndicatorAngle) + M_PI*0.1), 0)
            CGContextStrokePath(context)
            
            CGContextBeginPath(context)
            CGContextTranslateCTM(context, CGFloat(25*scale), CGFloat(25*scale))
            CGContextRotateCTM(context, CGFloat((M_PI*1.7*rotationIndicatorAngle) + M_PI*0.1))
            CGContextMoveToPoint(context, CGFloat(6*scale), 0)
            CGContextAddLineToPoint(context, CGFloat(14*scale), 0)
            CGContextAddLineToPoint(context, CGFloat(10*scale), CGFloat(4*scale))
            CGContextRotateCTM(context, CGFloat(-1*((M_PI * 1.7 * rotationIndicatorAngle) + M_PI*0.1)))
            CGContextTranslateCTM(context, CGFloat(-25*scale), CGFloat(-25*scale))
            CGContextFillPath(context)
        }
        
        for item in levels[level].items {
            if item.bullets.count > 0 {
                for bullet in item.bullets {
                    let lX = centerX + ((bullet.location.x - centerX)*scale)
                    let lY = centerY + ((bullet.location.y - centerY)*scale)
                    
                    CGContextBeginPath(context)
                    UIColor.init(red: 0.95, green: 0.08, blue: 0, alpha: 1).set()
                    CGContextAddArc(context, CGFloat(lX), CGFloat(lY), CGFloat(bullet.radius) * CGFloat(scale), 0, CGFloat(2*M_PI), 1)
                    CGContextFillPath(context)
                }
                for shard in item.shrapnel {
                    let lX = centerX + ((shard.location.x - centerX)*scale)
                    let lY = centerY + ((shard.location.y - centerY)*scale)
                    
                    CGContextBeginPath(context)
                    UIColor.init(red: 0.8, green: 0.08, blue: 0.6, alpha: CGFloat(shard.velocity.mag() / shard.speed)).set()
                    CGContextAddArc(context, CGFloat(lX), CGFloat(lY), 2 * CGFloat(scale), 0, CGFloat(2 * M_PI), 1)
                    CGContextFillPath(context)
                }
            }
        }
        
        if !player.location.equals(Vector(X: -1, Y: -1)) && level > 0 {
            let lX = centerX + ((player.location.x - centerX)*scale)
            let lY = centerY + ((player.location.y - centerY)*scale)
            
            CGContextBeginPath(context)
            UIColor.init(red: 0, green: 0.1, blue: 0.95, alpha: 1).set()
            CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
            CGContextMoveToPoint(context, CGFloat(player.vertices[3].x*scale), CGFloat(player.vertices[3].y*scale))
            for vertex in player.vertices {
                CGContextAddLineToPoint(context, CGFloat(vertex.x*scale), CGFloat(vertex.y*scale))
            }
            CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
            CGContextFillPath(context)
        }
    }
    
    func updateIslands() {
        for island in levels[level].islands {
            if island.key != nil {
                if island.timer > 0 {
                    island.rotate()
                    island.slide()
                }
            }
            else {
                island.rotate()
                island.slide()
            }
            island.unlock()
        }
    }
    
    func updateItems() {
        for item in levels[level].items {
            item.action(player.location)
            
            if item.pivot != nil {
                item.rotate(levels[level].islands[item.pivot!].location, angleV: levels[level].islands[item.pivot!].angleV)
            }
            
            if item.bullets.count > 0 {
                for var i=0; i<item.bullets.count; i++ {
                    for wall in levels[level].islands {
                        item.bullets[i].collide(wall)
                    }
                    item.bullets[i].move()
                }
            }
            if item.shrapnel.count > 0 {
                for var i=0; i<item.shrapnel.count; i++ {
                    item.shrapnel[i].move()
                    
                    if round(item.shrapnel[i].velocity.mag()) == 0 {
                        item.shrapnel.removeAtIndex(i)
                    }
                }
            }
        }
    }
    
    func updatePlayer() {
        if player.startMoving {
            for island in levels[level].islands {
                if island.key == nil || (island.key != nil && island.timer! > 150){
                    let point1 = Vector(X: 0, Y: 0)
                    let point2 = Vector(X: 0, Y: 0)
                    let point3 = Vector(X: 0, Y: 0)
                    
                    for var i=0; i<island.vertices.count; i++ {
                        point1.set(island.location)
                        point2.set(island.location)
                        point3.set(island.location)
                        if i+1 == island.vertices.count {
                            point1.add(island.vertices[i])
                            point2.add(island.vertices[0])
                        }
                        else {
                            point1.add(island.vertices[i])
                            point2.add(island.vertices[i+1])
                        }
                        if island.canRotate {
                            let radial = Vector(X: point2.x, Y: point2.y)
                            radial.sub(island.location)
                            let magnitude = radial.mag() * 0.5
                            radial.set(createVectorFromAngle(radial.heading() + Float(M_PI * 0.5)))
                            radial.mult(magnitude)
                            point3.add(radial)
                            
                            player.collisionCornerWithLine(point1, p2: point2, p3: point3, a: island.angle)
                        }
                        else {
                            player.collisionCornerWithLine(point1, p2: point2, p3: point3)
                        }
                    }
                    
                    if island.canRotate && island.anchorIsland == nil {
                        point1.set(island.location)
                        var angle = island.angle + Float(M_PI * 0.5)
                        if angle < 0 {
                            angle += Float(M_PI * 2)
                        }
                        if angle > Float(M_PI * 2) {
                            angle -= Float(M_PI * 2)
                        }
                        point2.set(createVectorFromAngle(angle))
                        point2.mult(island.vertices[0].mag())
                        player.repelForce(point1, otherNormal: point2)
                    }
                }
            }
            player.fallForce()
        }
        player.flickForce()
        player.edgeBounce()
        if player.startMoving {
            player.move()
        }
        player.touchingSurface = false
    }
    
    func resetLevel() {
        for aLevel in levels {
            for island in aLevel.islands {
                if island.key != nil {
                    island.timer = 0
                }
            }
            for item in aLevel.items {
                if item.type == "door" {
                    item.opened = false
                    if item.timer != nil {
                        item.timer = 0
                    }
                }
                if item.type == "turret" && level != previousLevel {
                    item.bullets.removeAll()
                    item.shrapnel.removeAll()
                }
                if item.type == "button" {
                    item.opened = false
                    item.timer = 0
                }
                if item.type == "spike" {
                    if item.timer != nil {
                        item.timer = 0
                    }
                }
            }
            aLevel.doorsOpened = 0
        }
        player.restart(levels[level].playerStart)
        rotationIndicatorAngle = 0
    }
    
    func updateLevel() {
        if level == 0 {
            if initialCursor != nil && initialCursor.x > CGFloat(viewWidth/2) + 80 && initialCursor.y > CGFloat(viewHeight - 100) {
                reset = true
                level = levelSelect
            }
        }
        else {
            levels[level].checkDoors()
            if levels[level].doorsOpened == levels[level].doorCount {
                reset = true
                
                let saveData = NSUserDefaults.standardUserDefaults()
                beatenLevels = saveData.stringForKey("beatenLevels")
                if beatenLevels == nil {
                    beatenLevels = "0"
                    saveData.setObject("0", forKey: "beatenLevels")
                }
                
                let beatenArray = beatenLevels!.componentsSeparatedByString(",")
                if !(beatenArray.contains(String(level))) {
                    saveData.setObject(beatenLevels! + "," + String(level), forKey: "beatenLevels")
                    beatenLevels = saveData.stringForKey("beatenLevels")
                }
                if level > highestLevel {
                    saveData.setObject(level, forKey: "highestLevel")
                    highestLevel = level
                }
                
                if level < levels.count-1 {
                    level++
                }
                else {
                    level = 0
                    levelSelect = 0
                }
            }
            else if level > 0 && levelSelect == 0 {
                reset = true
                level = levelSelect
            }
        }
    }
    
    func updateButtons() {
        for button in buttons {
            button.changeSkin()
            button.checkSelected()
            if level == 0 {
                button.slide()
            }
            button.action()
        }
    }
    
    func tick() {
        self.setNeedsDisplay()
        updateLevel()
        if reset {
            resetLevel()
            reset = false
        }
        updateButtons()
        updateIslands()
        updateItems()
        updatePlayer()
        
        if rotationIndicatorAngle < 1 {
            rotationIndicatorAngle += (1 - rotationIndicatorAngle)*0.025
        }
    }
}

class RotatingSlidingView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timerRotateSlide = NSTimer.scheduledTimerWithTimeInterval(0.025, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for island in levels[level].islands {
            CGContextBeginPath(context)
            
            if island.canRotate {
                UIColor.blackColor().set()
                
                let lX = centerX + ((island.location.x - centerX)*scale)
                let lY = centerY + ((island.location.y - centerY)*scale)
                
                if island.anchorIsland == nil {
                    if island.key == nil {
                        CGContextAddArc(context, CGFloat(lX), CGFloat(lY), CGFloat(island.vertices[0].mag()*scale), CGFloat(island.angle), CGFloat(island.angle + Float(M_PI)), 0)
                    }
                    else if island.timer > 0 {
                        CGContextAddArc(context, CGFloat(lX), CGFloat(lY), CGFloat(island.vertices[0].mag()*scale) * CGFloat(island.timer!) / 150, CGFloat(island.angle), CGFloat(island.angle + Float(M_PI)), 0)
                    }
                }
                else {
                    if island.key == nil {
                        CGContextMoveToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                        for var i=1; i<island.vertices.count; i++ {
                            CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                        }
                        CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                    }
                    else if island.timer > 0 {
                        CGContextMoveToPoint(context, CGFloat(lX + ((island.vertices[0].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[0].y*scale) * Float(island.timer!) / 150)))
                        for var i=1; i<island.vertices.count; i++ {
                            CGContextAddLineToPoint(context, CGFloat(lX + ((island.vertices[i].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[i].y*scale) * Float(island.timer!) / 150)))
                        }
                        CGContextAddLineToPoint(context, CGFloat(lX + ((island.vertices[0].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[0].y*scale) * Float(island.timer!) / 150)))
                    }
                }
                CGContextFillPath(context)
            }
            else if island.canSlide {
                UIColor.grayColor().set()
                CGContextMoveToPoint(context, CGFloat(island.rail[0].x * scale), CGFloat(island.rail[0].y * scale))
                CGContextAddLineToPoint(context, CGFloat(island.rail[1].x * scale), CGFloat(island.rail[1].y * scale))
                CGContextStrokePath(context)
                
                let lX = centerX + ((island.location.x - centerX)*scale)
                let lY = centerY + ((island.location.y - centerY)*scale)
                
                if island.key == nil {
                    UIColor.blackColor().set()
                    CGContextMoveToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                    for var i=1; i<island.vertices.count; i++ {
                        CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                    }
                    CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                }
                else if island.timer! > 0 {
                    UIColor.blackColor().set()
                    CGContextMoveToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                    for var i=1; i<island.vertices.count; i++ {
                        CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[i].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[i].y*scale * Float(island.timer!) / 150)))
                    }
                    CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                }
                CGContextFillPath(context)
            }
            else if island.key != nil {
                if island.timer! > 0 {
                    UIColor.init(red: 0, green: 0, blue: 0, alpha: 1).set()
                    
                    let lX = centerX + ((island.location.x - centerX)*scale)
                    let lY = centerY + ((island.location.y - centerY)*scale)
                    
                    CGContextMoveToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                    for var i=1; i<island.vertices.count; i++ {
                        CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[i].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[i].y*scale * Float(island.timer!) / 150)))
                    }
                    CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                    CGContextFillPath(context)
                }
            }
        }
        
        for item in levels[level].items {
            CGContextBeginPath(context)
            
            if item.type == "spike" && (item.pivot != nil || item.key != nil) {
                UIColor.init(red: 0.95, green: 0.08, blue: 0, alpha: 1).set()
                
                let lX = centerX + ((item.location.x - centerX)*scale)
                let lY = centerY + ((item.location.y - centerY)*scale)
                
                CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
                CGContextRotateCTM(context, CGFloat(item.angle))
                CGContextMoveToPoint(context, CGFloat(-4*scale), 0)
                if item.key != nil {
                    if item.initialState != nil && item.initialState == false {
                        CGContextAddLineToPoint(context, 0, -6 * CGFloat(scale) * CGFloat(item.timer!) / 50)
                    }
                    else {
                        CGContextAddLineToPoint(context, 0, -6 * CGFloat(scale) * (50 - CGFloat(item.timer!)) / 50)
                    }
                }
                else {
                    CGContextAddLineToPoint(context, 0, CGFloat(-6*scale))
                }
                CGContextAddLineToPoint(context, CGFloat(4*scale), 0)
                CGContextAddLineToPoint(context, CGFloat(-4*scale), 0)
                CGContextFillPath(context)
                CGContextRotateCTM(context, CGFloat(item.angle * -1))
                CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
            }
            else if item.type == "door" {
                if item.opened {
                    UIColor.init(red: 0.1, green: 1, blue: 0.5, alpha: 0.25).set()
                }
                else {
                    UIColor.init(red: 0.1, green: 1, blue: 0.5, alpha: 1).set()
                }
                
                let lX = centerX + ((item.location.x - centerX)*scale)
                let lY = centerY + ((item.location.y - centerY)*scale)
                
                CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
                CGContextRotateCTM(context, CGFloat(item.angle))
                if level > 0 {
                    CGContextMoveToPoint(context, -8 * CGFloat(scale), 0)
                    if item.timer != nil {
                        CGContextAddLineToPoint(context, -8 * CGFloat(scale), -17 * CGFloat(scale) * CGFloat(item.timer!) / 200)
                        CGContextAddLineToPoint(context, 8 * CGFloat(scale), -17 * CGFloat(scale) * CGFloat(item.timer!) / 200)
                    }
                    else {
                        CGContextAddLineToPoint(context, -8 * CGFloat(scale), -17 * CGFloat(scale))
                        CGContextAddLineToPoint(context, 8 * CGFloat(scale), -17 * CGFloat(scale))
                    }
                    CGContextAddLineToPoint(context, 8 * CGFloat(scale), 0)
                    CGContextAddLineToPoint(context, -8 * CGFloat(scale), 0)
                }
                else {
                    CGContextMoveToPoint(context, -20 * CGFloat(scale), -5 * CGFloat(scale))
                    CGContextAddLineToPoint(context, 50 * CGFloat(scale), -5 * CGFloat(scale))
                    CGContextAddLineToPoint(context, 50 * CGFloat(scale), -10 * CGFloat(scale))
                    CGContextAddLineToPoint(context, 60 * CGFloat(scale), 0 * CGFloat(scale))
                    CGContextAddLineToPoint(context, 50 * CGFloat(scale), 10 * CGFloat(scale))
                    CGContextAddLineToPoint(context, 50 * CGFloat(scale), 5 * CGFloat(scale))
                    CGContextAddLineToPoint(context, -20 * CGFloat(scale), 5 * CGFloat(scale))
                }
                CGContextFillPath(context)
                CGContextRotateCTM(context, CGFloat(item.angle * -1))
                CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
            }
            else if item.type == "button" {
                if item.key == nil || (item.key != nil && levels[level].items[item.key!].opened) {
                    UIColor.init(red: 0.7, green: 0.9, blue: 0.2, alpha: 1).set()
                    
                    let lX = centerX + ((item.location.x - centerX)*scale)
                    let lY = centerY + ((item.location.y - centerY)*scale)
                    
                    CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
                    CGContextRotateCTM(context, CGFloat(item.angle))
                    CGContextMoveToPoint(context, -6 * CGFloat(scale), 0)
                    CGContextAddLineToPoint(context, -6 * CGFloat(scale), -4 * CGFloat(scale) * CGFloat(50 - item.timer!) / 50)
                    CGContextAddLineToPoint(context, 6 * CGFloat(scale), -4 * CGFloat(scale) * CGFloat(50 - item.timer!) / 50)
                    CGContextAddLineToPoint(context, 6 * CGFloat(scale), 0)
                    CGContextAddLineToPoint(context, -6 * CGFloat(scale), 0)
                    CGContextFillPath(context)
                    CGContextRotateCTM(context, CGFloat(item.angle * -1))
                    CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
                }
            }
        }
    }
    
    func tick() {
        self.setNeedsDisplay()
    }
}

class StaticView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timerStatics = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.lightGrayColor().set()
        CGContextSetLineWidth(context, CGFloat(2*scale))
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, -10, CGFloat(centerY - (Float(viewHeight)/2)))
        CGContextAddLineToPoint(context, CGFloat(screenWidth) + 10, CGFloat(centerY - (Float(viewHeight)/2)))
        CGContextStrokePath(context)
        
        for island in levels[level].islands {
            CGContextBeginPath(context)
            
            if !island.canRotate && !island.canSlide && island.key == nil {
                UIColor.init(red: 0, green: 0, blue: 0, alpha: 1).set()
                
                let lX = centerX + ((island.location.x - centerX)*scale)
                let lY = centerY + ((island.location.y - centerY)*scale)
                
                CGContextMoveToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                for var i=1; i<island.vertices.count; i++ {
                    CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                }
                CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                CGContextFillPath(context)
            }
        }
        
        for item in levels[level].items {
            if item.pivot == nil && item.key == nil && item.type == "spike" {
                CGContextBeginPath(context)
                
                let lX = centerX + ((item.location.x - centerX)*scale)
                let lY = centerY + ((item.location.y - centerY)*scale)
                
                UIColor.init(red: 0.95, green: 0.08, blue: 0, alpha: 1).set()
                CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
                CGContextRotateCTM(context, CGFloat(item.angle))
                CGContextMoveToPoint(context, CGFloat(-4*scale), 0)
                CGContextAddLineToPoint(context, 0, CGFloat(-6*scale))
                CGContextAddLineToPoint(context, CGFloat(4*scale), 0)
                CGContextAddLineToPoint(context, CGFloat(-4*scale), 0)
                CGContextFillPath(context)
                CGContextRotateCTM(context, CGFloat(item.angle * -1))
                CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
            }
            else if item.type == "turret" {
                CGContextBeginPath(context)
                
                let lX = centerX + ((item.location.x - centerX)*scale)
                let lY = centerY + ((item.location.y - centerY)*scale)
                
                UIColor.init(red: 0.6, green: 0.08, blue: 0.8, alpha: 1).set()
                CGContextTranslateCTM(context, CGFloat(lX), CGFloat(lY))
                CGContextRotateCTM(context, CGFloat(item.angle))
                CGContextAddArc(context, 0, 0, CGFloat(10*scale), 0, CGFloat(M_PI), 1)
                CGContextFillPath(context)
                CGContextRotateCTM(context, CGFloat(item.angle * -1))
                CGContextTranslateCTM(context, CGFloat(-1*lX), CGFloat(-1*lY))
            }
            else if item.type != "door" && item.type != "spike" && item.type != "turret" && item.type != "button" {
                
                let lX = centerX + ((item.location.x - centerX)*scale)
                let lY = centerY + ((item.location.y - centerY)*scale)
                
                let textColor: UIColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
                let text: NSString = item.type
                let textSize: Float = item.angle*scale
                let textFont: UIFont = UIFont(name: "GillSans", size: CGFloat(textSize))!
                let textAlignment = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                    textAlignment.alignment = NSTextAlignment.Left
                let attributes: NSDictionary = [
                    NSForegroundColorAttributeName: textColor,
                    NSFontAttributeName: textFont,
                    NSParagraphStyleAttributeName: textAlignment
                ]
                text.drawInRect(CGRect(x: CGFloat(lX), y: CGFloat(lY), width: CGFloat(text.length)*CGFloat(textSize), height: CGFloat(text.length)*CGFloat(textSize)), withAttributes: attributes as? [String : AnyObject])
            }
        }
    }
    
    func tick() {
        if level != previousLevel || reset {
            self.setNeedsDisplay()
        }
        previousLevel = level
    }
}

class ButtonView: UIView {
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timerButtons = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    override func drawRect(rect: CGRect) {
        for button in buttons {
            if (button.location.x > 0 && button.location.x < Float(viewWidth) && button.location.y > 0 && button.location.y < Float(viewHeight)) && ((button.station != nil && level == button.station) || (button.station == nil && level != 0)) {
                
                let textColor: UIColor
                var text: NSString = button.skin.substringToIndex(button.skin.endIndex.advancedBy(-1))
                
                if text == "0" {
                    text = "H"
                }
                
                if button.skin.characters.contains("-") {
                    textColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                }
                else if button.skin.characters.contains("=") {
                    textColor = UIColor.init(red: 0.4, green: 0.7, blue: 0.45, alpha: 1)
                }
                else {
                    textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
                }
                
                let textSize = Int(80*scale)// - Float((text.length-1) * 10)
                let textFont: UIFont = UIFont(name: "GillSans-Light", size: CGFloat(textSize))!
                
                let textAlignment = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                textAlignment.alignment = NSTextAlignment.Center
                
                let attributes: NSDictionary = [
                    NSForegroundColorAttributeName: textColor,
                    NSFontAttributeName: textFont,
                    NSParagraphStyleAttributeName: textAlignment
                ]
                text.drawInRect(CGRect(x: CGFloat(button.location.x - Float(textSize)*0.5), y: CGFloat(button.location.y - Float(textSize)*0.5), width: CGFloat(textSize + 30), height: CGFloat(textSize + 10)), withAttributes: attributes as? [String : AnyObject])
            }
        }
    }
    
    func tick() {
        if level != previousLevel || (initialCursor != nil) || (buttons[0].target != buttons[0].location.x) || buttons[0].skinChanged {
            self.setNeedsDisplay()
        }
    }
}


