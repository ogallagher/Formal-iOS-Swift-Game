//
//  ViewController.swift
//  PuzzlePlatformer
//
//  Created by Owen Gallagher on 16/11/15.
//  Copyright © 2015 Owen. All rights reserved.
//

//NOTE: the date above is November 16, 2015. My laptop is set to Spanish, so XCode saved the date in the appropriate format.

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

var rotationIndicator: Double = 0
var menuIndicator = Vector(X: 0, Y: 0)

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
        
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "highestLevel") //Last completed level
        
        let saveData = NSUserDefaults.standardUserDefaults()
        highestLevel = saveData.integerForKey("highestLevel")
        beatenLevels = saveData.stringForKey("beatenLevels")
        
        if highestLevel == nil {
            highestLevel = 0
        }
        if beatenLevels == nil {
            beatenLevels = "0"
            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "beatenLevels") //List of completed levels
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
    
    func createButtons() {
        var link = 0
        var xPos = 0
        var yPos = 0
        
        for z in 0 ..< 3 {
            for y in 0 ..< 3 {
                for x in 0 ..< 3 {
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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(TouchAndDisplayView.tick), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        initialCursor = touches.first?.locationInView(self)
        finalCursor = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        finalCursor = touches.first?.locationInView(self)
        
        for button in buttons {
            button.checkSelected()
            button.slide()
        }
        updateMenu()
        player.flickForce()
        
        finalCursor = nil
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        
        if levels[level].enableRotation && rotationIndicator < 1 {
            CGContextBeginPath(context)
            UIColor.init(red: 0, green: 0.2, blue: 1, alpha: 0.5).set()
            CGContextSetLineWidth(context, CGFloat(3*scale))
            CGContextAddArc(context, CGFloat(35*scale), CGFloat(35*scale), CGFloat(20*scale), CGFloat(M_PI*0.1), CGFloat((M_PI*1.7*rotationIndicator) + M_PI*0.1), 0)
            CGContextStrokePath(context)
            
            CGContextBeginPath(context)
            CGContextTranslateCTM(context, CGFloat(35*scale), CGFloat(35*scale))
            CGContextRotateCTM(context, CGFloat((M_PI*1.7*rotationIndicator) + M_PI*0.1))
            CGContextMoveToPoint(context, CGFloat(16*scale), 0)
            CGContextAddLineToPoint(context, CGFloat(24*scale), 0)
            CGContextAddLineToPoint(context, CGFloat(20*scale), CGFloat(4*scale))
            CGContextRotateCTM(context, CGFloat(-1*((M_PI * 1.7 * rotationIndicator) + M_PI*0.1)))
            CGContextTranslateCTM(context, CGFloat(-35*scale), CGFloat(-35*scale))
            CGContextFillPath(context)
        }
        
        if level > 0 && (menuIndicator.y != 0 || previousLevel != level) {
            UIColor.init(red: 0, green: 0.2, blue: 1, alpha: 0.5).set()
            CGContextSetLineWidth(context, 3)
            
            CGContextTranslateCTM(context, CGFloat(screenWidth) - 35, -20 + (CGFloat(menuIndicator.x)/20*55))
            CGContextMoveToPoint(context, -20, -4)
            CGContextAddLineToPoint(context, -20, 20)
            CGContextMoveToPoint(context, 20, -4)
            CGContextAddLineToPoint(context, 20, 20)
            CGContextTranslateCTM(context, -1 * (CGFloat(screenWidth) - 35), 20 - (CGFloat(menuIndicator.x)/20*55))
            
            CGContextTranslateCTM(context, CGFloat(screenWidth) - 35, 35)
            CGContextMoveToPoint(context, 1, -21 * (CGFloat(menuIndicator.x) - 10) / 10)
            CGContextAddLineToPoint(context, -30, 5 * (CGFloat(menuIndicator.x) - 10) / 10)
            CGContextMoveToPoint(context, -1, -21 * (CGFloat(menuIndicator.x) - 10) / 10)
            CGContextAddLineToPoint(context, 30, 5 * (CGFloat(menuIndicator.x) - 10) / 10)
            CGContextTranslateCTM(context, -1 * (CGFloat(screenWidth) - 35), -35)
            
            CGContextStrokePath(context)
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
            if item.dock != nil {
                item.slide(levels[level].islands[item.dock!].rail[2])
            }
            if item.bullets.count > 0 {
                for i in 0 ..< item.bullets.count {
                    for wall in levels[level].islands {
                        item.bullets[i].collide(wall)
                    }
                    item.bullets[i].move()
                }
            }
            if item.shrapnel.count > 0 {
                for var i in 0 ..< item.shrapnel.count {
                    if i < item.shrapnel.count {
                        item.shrapnel[i].move()
                        
                        if round(item.shrapnel[i].velocity.mag()) == 0 {
                            item.shrapnel.removeAtIndex(i)
                            i -= 1
                        }
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
                    
                    for i in 0 ..< island.vertices.count {
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
        player.edgeBounce()
        if player.startMoving {
            player.control()
            player.move()
        }
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
        rotationIndicator = 0
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
                    level += 1
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
            button.move()
            button.action()
            button.changeSkin()
        }
        
        if menuIndicator.x == 1 {
            menuIndicator.y = 1
        }
        else if menuIndicator.x == 19 {
            menuIndicator.y = -1
        }
        
        if menuIndicator.y > 0 {
            menuIndicator.x += (20-menuIndicator.x)*0.1
            if round(menuIndicator.x) == 20 {
                menuIndicator.x = 20
            }
        }
        else {
            menuIndicator.x -= menuIndicator.x*0.1
            if round(menuIndicator.x) == 0 {
                menuIndicator.x = 0
            }
        }
    }
    
    func updateMenu() {
        if Int(initialCursor.x) > screenWidth - 50 && Int(initialCursor.y) < 50 {
            if menuIndicator.x == 0 && initialCursor.y < finalCursor.y {
                if round(menuIndicator.x) == 0 {
                    menuIndicator.x += 1
                }
                else {
                    menuIndicator.x = 20
                    menuIndicator.y = 0
                }
            }
            else if menuIndicator.x == 20 && initialCursor.y > finalCursor.y {
                if round(menuIndicator.x) == 20 {
                    menuIndicator.x -= 1
                }
                else {
                    menuIndicator.x = 0
                    menuIndicator.y = 0
                }
            }
        }
    }
    
    func tick() {
        self.setNeedsDisplay()
        updateLevel()
        if reset {
            resetLevel()
            menuIndicator.set(Vector(X: 0, Y: -1))
            reset = false
        }
        updatePlayer()
        updateButtons()
        updateIslands()
        updateItems()
        
        if rotationIndicator < 1 {
            rotationIndicator += (1 - rotationIndicator)*0.025
        }
    }
}

class RotatingSlidingView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timerRotateSlide = NSTimer.scheduledTimerWithTimeInterval(0.025, target: self, selector: #selector(RotatingSlidingView.tick), userInfo: nil, repeats: true)
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
                        for i in 1 ..< island.vertices.count {
                            CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                        }
                        CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                    }
                    else if island.timer > 0 {
                        CGContextMoveToPoint(context, CGFloat(lX + ((island.vertices[0].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[0].y*scale) * Float(island.timer!) / 150)))
                        for i in 1 ..< island.vertices.count {
                            CGContextAddLineToPoint(context, CGFloat(lX + ((island.vertices[i].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[i].y*scale) * Float(island.timer!) / 150)))
                        }
                        CGContextAddLineToPoint(context, CGFloat(lX + ((island.vertices[0].x*scale) * Float(island.timer!) / 150)), CGFloat(lY + ((island.vertices[0].y*scale) * Float(island.timer!) / 150)))
                    }
                }
                CGContextFillPath(context)
            }
            else if island.canSlide {
                let lX = centerX + ((island.location.x - centerX)*scale)
                let lY = centerY + ((island.location.y - centerY)*scale)
                
                if island.key == nil {
                    UIColor.blackColor().set()
                    CGContextMoveToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                    for i in 1 ..< island.vertices.count {
                        CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                    }
                    CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                }
                else if island.timer! > 0 {
                    UIColor.blackColor().set()
                    CGContextMoveToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                    for i in 1 ..< island.vertices.count {
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
                    for i in 1 ..< island.vertices.count {
                        CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[i].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[i].y*scale * Float(island.timer!) / 150)))
                    }
                    CGContextAddLineToPoint(context, CGFloat(lX + (island.vertices[0].x*scale * Float(island.timer!) / 150)), CGFloat(lY + (island.vertices[0].y*scale * Float(island.timer!) / 150)))
                    CGContextFillPath(context)
                }
            }
        }
        
        for item in levels[level].items {
            CGContextBeginPath(context)
            
            if item.type == "spike" && (item.pivot != nil || item.dock != nil || item.key != nil) {
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
        timerStatics = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(StaticView.tick), userInfo: nil, repeats: true)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for island in levels[level].islands {
            CGContextBeginPath(context)
            
            if !island.canRotate && !island.canSlide && island.key == nil {
                UIColor.init(red: 0, green: 0, blue: 0, alpha: 1).set()
                
                let lX = centerX + ((island.location.x - centerX)*scale)
                let lY = centerY + ((island.location.y - centerY)*scale)
                
                CGContextMoveToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                for i in 1 ..< island.vertices.count {
                    CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[i].x*scale), CGFloat(lY + island.vertices[i].y*scale))
                }
                CGContextAddLineToPoint(context, CGFloat(lX + island.vertices[0].x*scale), CGFloat(lY + island.vertices[0].y*scale))
                CGContextFillPath(context)
            }
            else if island.canSlide && island.rail.count > 0 && island.key == nil {
                UIColor.grayColor().set()
                CGContextMoveToPoint(context, CGFloat(island.rail[0].x * scale), CGFloat(island.rail[0].y * scale))
                CGContextAddLineToPoint(context, CGFloat(island.rail[1].x * scale), CGFloat(island.rail[1].y * scale))
                CGContextStrokePath(context)
            }
        }
        
        for item in levels[level].items {
            if item.pivot == nil && item.dock == nil && item.key == nil && item.type == "spike" {
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
        timerButtons = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(ButtonView.tick), userInfo: nil, repeats: true)
    }
    
    override func drawRect(rect: CGRect) {
        for button in buttons {
            if (button.location.x > 0 && button.location.x < Float(viewWidth) && button.location.y > 0 && button.location.y < Float(viewHeight)) && ((button.station != nil && level == button.station) || (button.station == nil && level != 0)) {
                
                let textColor: UIColor
                let text: NSString = button.skin.substringToIndex(button.skin.endIndex.advancedBy(-1))
                
                if button.skin.characters.contains("-") {
                    textColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                }
                else if button.skin.characters.contains("=") {
                    textColor = UIColor.init(red: 0.4, green: 0.7, blue: 0.45, alpha: 1)
                }
                else {
                    textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
                }
                
                if text != "0" {
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
    }
    
    func tick() {
        if level != previousLevel || (initialCursor != nil) || (buttons[0].target != buttons[0].location.x) || buttons[0].skinChanged {
            self.setNeedsDisplay()
        }
    }
}


