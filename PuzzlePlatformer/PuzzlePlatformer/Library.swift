//
//  Library.swift
//  PuzzlePlatformer
//
//  Created by Owen Gallagher on 23/11/15.
//  Copyright © 2015 Owen. All rights reserved.
//

import Foundation

class Player: RigidPolygon {
    var startMoving: Bool
    var flick: Vector
    
    init() {
        startMoving = false
        flick = Vector(X: 0, Y: 0)
        super.init(l: Vector(X: -1, Y: -1), v: "-6,-6 6,-6 6,6 -6,6", f: true)
    }
    
    func flickForce() {
        if !startMoving {
            startMoving = true
        }
        
        let flickForce = Vector(X: Float(finalCursor!.x), Y: Float(finalCursor!.y))
        flickForce.x -= Float(initialCursor!.x)
        flickForce.y -= Float(initialCursor!.y)
        
        var magnitude = flickForce.mag()
        if magnitude > 200 {
            magnitude = 200
        }
        magnitude = 3*(magnitude/200)
        
        flickForce.norm()
        flickForce.mult(magnitude)
        
        if level.number > 0 {
            flick.set(flickForce)
        }
    }
    
    func edgeBounce() {
        if location.x > centerX + Float(160) || location.x < centerX - Float(160) || location.y > centerY + Float(240) || location.y < centerY - Float(240) {
            reset = true
        }
    }
    
    func repelForce(otherLocation: Vector, otherNormal: Vector) {
        let repelForce = Vector(X: location.x, Y: location.y)
        repelForce.sub(otherLocation)
        if angleBetween(otherNormal, vector2: repelForce) < Float(M_PI * 0.45) {
            if repelForce.mag() < otherNormal.mag()+10 {
                repelForce.norm()
                repelForce.mult(1.5)
                if level.number > 0 {
                    velocity.set(repelForce)
                }
            }
        }
    }
    
    func restart(l: Vector) {
        startMoving = false
        location.set(l)
        velocity.mult(0)
        if level.initialGravity == 1 {
            myGravity.set(Vector(X: -1, Y: 0))
        }
        else if level.initialGravity == 2 {
            myGravity.set(Vector(X: 0, Y: -1))
        }
        else if level.initialGravity == 3 {
            myGravity.set(Vector(X: 1, Y: 0))
        }
        else {
            myGravity.set(Vector(X: 0, Y: 1))
        }
        myGravity.mult(0.05)
    }
    
    func control() {
        if touchingSurface && !flick.equals(Vector(X: 0, Y: 0)) {
            let angle = angleBetween(flick, vector2: surfaceTouched)
            if angle < Float(M_PI*0.5) {
                let newFlick = Vector(X: 0, Y: 0)
                newFlick.set(createVectorFromAngle(surfaceTouched.heading() + Float(M_PI*0.5)))
                
                var sHead = surfaceTouched.heading()
                var fHead = flick.heading()
                
                if abs(sHead - fHead) > Float(M_PI*0.5) {
                    if sHead > fHead {
                        sHead -= Float(2*M_PI)
                    }
                    else {
                        fHead -= Float(2*M_PI)
                    }
                }
                
                if sHead > fHead {
                    newFlick.mult(-1)
                }
                
                newFlick.mult(flick.mag()*sin(angle))
                flick.set(newFlick)
            }
        
            velocity.set(flick)
            flick.mult(0)
        }
        else if !touchingSurface {
            flick.mult(0)
        }
    }
}

class RigidPolygon {
    var location: Vector
    var velocity: Vector
    var acceleration: Vector
    
    var angle: Float
    var angleV: Float
    var angleA: Float
    
    var myGravity: Vector
    var surfaceTouched: Vector
    var touchingSurface: Bool
    var surfaceRotates: Bool
    var createFriction: Bool
    
    var vertices: [Vector] = []
    
    init(l: Vector, v: String, f: Bool) {
        location = Vector(X: l.x, Y: l.y)
        velocity = Vector(X: 0, Y: 0)
        acceleration = Vector(X: 0, Y: 0)
        angle = 0
        angleV = 0
        angleA = 0.09
        
        myGravity = Vector(X: 0, Y: 1)
        myGravity.mult(0.05)
        surfaceTouched = Vector(X: 0, Y: 1)
        touchingSurface = false
        surfaceRotates = false
        createFriction = f
        
        let vStrings = v.componentsSeparatedByString(" ")
        for vertex in vStrings {
            let vComponents = vertex.componentsSeparatedByString(",")
            vertices.append(Vector(X: Float(vComponents[0])!, Y: Float(vComponents[1])!))
        }
    }
    
    func collisionCornerWithLine(p1: Vector, p2: Vector, p3: Vector, a: Float? = nil, v: Vector? = nil) {
        if level.number > 0 {
            let boundary = Vector(X: 0, Y: 0)
            let line = Vector(X: 0, Y: 0)
            var collisionsAngle: Float = 0
            var closestCorner: Float = 10
            
            for vertex in vertices {
                let corner = Vector(X: vertex.x, Y: vertex.y)
                let myLocation = Vector(X: location.x, Y: location.y)
                corner.add(myLocation)
                
                boundary.set(corner)
                boundary.sub(p1)
                
                line.set(p2)
                line.sub(p1)
                
                collisionsAngle = angleBetween(line, vector2: boundary)
                
                if collisionsAngle < Float(M_PI*0.5) {
                    boundary.set(corner)
                    boundary.sub(p2)
                    
                    line.set(p1)
                    line.sub(p2)
                    
                    collisionsAngle = angleBetween(line, vector2: boundary)
                    
                    if collisionsAngle < Float(M_PI*0.5) {
                        line.norm()
                        line.mult(cos(collisionsAngle)*boundary.mag())
                        line.add(p2)
                        
                        let shadow: Vector = Vector(X: line.x, Y: line.y)
                        line.sub(corner)
                        
                        if line.mag() < 10 {
                            touchingSurface = true
                            
                            surfaceTouched.set(line)
                        }
                        
                        if line.mag() < 1.8*(velocity.mag()+1) {
                            collisionsAngle = angleBetween(velocity,vector2: line)
                            if collisionsAngle < Float(M_PI*0.5) {
                                let force = Vector(X: line.x, Y: line.y)
                                var friction: Vector? = nil
                                if (createFriction) {
                                    friction = Vector(X: myLocation.x, Y: myLocation.y)
                                }
                                
                                force.norm()
                                force.mult(velocity.mag() * cos(collisionsAngle))
                                if (createFriction) {
                                    friction!.add(force)
                                }
                                force.mult(-1.4)
                                
                                myLocation.add(velocity)
                                if (createFriction) {
                                    friction!.sub(myLocation)
                                    friction!.mult(0.085)
                                    velocity.add(friction!)
                                }
                                
                                velocity.add(force)
                                
                                let radial = Vector(X: shadow.x, Y: shadow.y)
                                radial.sub(p3)
                                
                                if (line.mag() <= closestCorner && createFriction) {
                                    location.add(line)
                                    line.norm()
                                    line.mult(1.5*(force.mag()+1))
                                    if angleBetween(line, vector2: radial) > Float(M_PI * 0.5) {
                                        line.mult(-1)
                                    }
                                    location.add(line)
                                    
                                    closestCorner = line.mag()
                                }
                                else {
                                    line.mult(-1)
                                }
                                
                                radial.set(location)
                                radial.sub(corner)
                                
                                collisionsAngle = angleBetween(radial, vector2: line)
                                if (collisionsAngle < Float(M_PI*0.25)) {
                                    let v = Vector(X: line.x, Y: line.y)
                                    if angleBetween(v, vector2: velocity) > Float(M_PI*0.5) {
                                        v.mult(-1)
                                    }
                                    
                                    angleV = abs(sin(collisionsAngle) * cos(angleBetween(v, vector2: velocity)) * (velocity.mag()+1) * 0.1)
                                    if radial.heading() < line.heading() {
                                        angleV *= -1
                                    }
                                }
                                else {
                                    angleV = 0
                                    
                                    if radial.heading() < line.heading() {
                                        angle = line.heading() - Float(M_PI*0.5)
                                    }
                                    else {
                                        angle = line.heading() + Float(M_PI*0.5)
                                    }
                                }
                                
                                if a != nil && level.enableGravityRotation {
                                    var otherGravity = a! + Float(M_PI * 0.5)
                                    while otherGravity < 0 {
                                        otherGravity += Float(M_PI * 2)
                                    }
                                    while otherGravity > Float(M_PI * 2) {
                                        otherGravity -= Float(M_PI * 2)
                                    }
                                    myGravity.set(createVectorFromAngle(otherGravity))
                                    myGravity.mult(0.05)
                                    
                                    surfaceRotates = true
                                }
                                else {
                                    surfaceRotates = false
                                }
                                
                                if v != nil {
                                    let otherVelocity = Vector(X: 0, Y: 0)
                                    otherVelocity.set(v!)
                                    
                                    location.add(otherVelocity)
                                    acceleration.sub(myGravity)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fallForce() {
        if level.number > 0 {
            if level.enableGravityRotation && touchingSurface && !surfaceRotates {
                myGravity.set(gravity)
                myGravity.mult(0.05)
            }
            
            acceleration.add(myGravity)
        }
    }
    
    func move() {
        if level.number > 0 {
            velocity.add(acceleration)
            velocity.mult(0.99)
            location.add(velocity)
            
            angleV += angleA
            angleV *= 0.99
            angle += angleV
        }
        
        for i in 0 ..< vertices.count {
            let radial = Vector(X: vertices[i].x, Y: vertices[i].y)
            let distance = radial.mag()
            radial.set(createVectorFromAngle(radial.heading() + angleV))
            radial.mult(distance)
            vertices[i] = radial
        }
        
        acceleration.mult(0)
        angleA = 0
        player.touchingSurface = false
    }
}


class Level {
    let number: Int
    let name: String
    var islands: [Island] = []
    var items: [Item] = []
    var doorCount: Int = 0
    var doorsOpened: Int = 0
    var playerStart: Vector
    var enableRotation: Bool = false
    var enableGravityRotation: Bool = false
    var enableGravitySwitches: Bool = false
    var initialGravity: Int = 0
    
    init(num: Int, nam: String, start: Vector, rotates: Bool, initial: Int? = nil, gravityRotates: Bool? = nil, gravitySwitches: Bool? = nil) {
        number = num
        name = nam
        playerStart = Vector(X: centerX + start.x, Y: centerY + start.y)
        enableRotation = rotates
        if gravityRotates != nil {
            enableGravityRotation = gravityRotates!
        }
        else {
            enableGravityRotation = enableRotation
        }
        if gravitySwitches != nil {
            enableGravitySwitches = gravitySwitches!
        }
        if initial != nil {
            initialGravity = initial!
        }
    }
    
    func addIsland(island: Island) {
        islands.append(island)
    }
    
    func addItem(item: Item) {
        items.append(item)
        if item.type == "door" {
            doorCount += 1
        }
    }
    
    func checkDoors() {
        var counter = 0
        for item in items {
            if item.type == "door" && item.opened {
                counter += 1
            }
        }
        if counter > doorsOpened {
            doorsOpened = counter
        }
    }
}

class Island {
    var location: Vector
    var angle: Float
    var angleV: Float
    var angleA: Float
    var vertices: [Vector] = []
    var canRotate: Bool
    var canSlide: Bool
    var rail: [Vector] = []
    var anchorIsland: Int? = nil
    var key: Int? = nil
    var dock: Int? = nil
    var timer: Int? = nil
    
    init(l: Vector, v: String, rotates: Bool, slides: Bool, railStart: Vector? = nil, railEnd: Vector? = nil, pivotNum: Int? = nil, dockNum: Int? = nil, keyNum: Int? = nil) {
        location = Vector(X: centerX + l.x, Y: centerY + l.y)
        angle = 0
        angleV = 0
        angleA = 0
        
        let vStrings = v.componentsSeparatedByString(" ")
        for vertex in vStrings {
            let vComponents = vertex.componentsSeparatedByString(",")
            vertices.append(Vector(X: Float(vComponents[0])!, Y: Float(vComponents[1])!))
        }
        
        canRotate = rotates
        
        canSlide = slides
        
        if canSlide {
            if railStart != nil && railEnd != nil {
                let railStartPosition = Vector(X: centerX, Y: centerY)
                let railEndPosition = Vector(X: centerX, Y: centerY)
                
                railStartPosition.add(railStart!)
                rail.append(railStartPosition)                                     //bound1
                
                railEndPosition.add(railEnd!)
                rail.append(railEndPosition)                                       //bound2
                
                rail.append(Vector(X: 0, Y: 0))                                    //velocity parallel to the rail
            }
            else if dockNum != nil {
                dock = dockNum
            }
        }
        
        if canRotate &&  pivotNum != nil {
            anchorIsland = pivotNum!
        }
        
        if keyNum != nil {
            key = keyNum
            timer = 0
        }
    }
    
    func rotate() {
        if canRotate {
            if anchorIsland != nil {
                let otherLocation = Vector(X: level.islands[anchorIsland!].location.x, Y: level.islands[anchorIsland!].location.y)
                let radial = Vector(X: location.x, Y: location.y)
                
                radial.sub(otherLocation)
                let magnitude = radial.mag()
                
                angleV = level.islands[anchorIsland!].angleV
                angle += angleV
                if angle < 0 {
                    angle += Float(M_PI * 2)
                }
                if angle > Float(M_PI * 2) {
                    angle -= Float(M_PI * 2)
                }
                
                radial.set(createVectorFromAngle(radial.heading() + angleV))
                radial.mult(magnitude)
                radial.add(otherLocation)
                location.set(radial)
            }
            else {
                angleA = (gravity.heading() - Float(M_PI*0.5))
                if angleA < 0 {
                    angleA += Float(M_PI * 2)
                }
                if angleA > Float(M_PI * 2) {
                    angleA -= Float(M_PI * 2)
                }
                if angle < 0 {
                    angle += Float(M_PI * 2)
                }
                if angle > Float(M_PI * 2) {
                    angle -= Float(M_PI * 2)
                }
                
                angleA -= angle
                
                if angleA > Float(M_PI) {
                    angleA = Float(M_PI * 2)-angleA
                    angleA *= -1
                }
                else if angleA < -1*Float(M_PI) {
                    angleA = Float(M_PI * -2)-angleA
                    angleA *= -1
                }
                
                angleA *= 0.001
                
                angleV += angleA
                angleV *= 0.95
                angle += angleV
            }
            
            for vertex in vertices {
                let radial = Vector(X: vertex.x, Y: vertex.y)
                let magnitude = radial.mag()
                
                radial.set(createVectorFromAngle(radial.heading() + angleV))
                radial.mult(magnitude)
                vertex.set(radial)
            }
        }
    }
    
    func slide() {
        if canSlide {
            if rail.count > 0 {
                let railLine = Vector(X: rail[0].x, Y: rail[0].y)
                railLine.sub(rail[1])
                
                let acceleration = Vector(X: gravity.x, Y: gravity.y)
                acceleration.mult(0.05)
                rail[2].add(acceleration)
                
                if angleBetween(railLine, vector2: rail[2]) > Float(M_PI * 0.5) {
                    railLine.mult(-1)
                }
                
                let railAngle = angleBetween(railLine, vector2: rail[2])
                let magnitude = rail[2].mag()
                
                rail[2].set(railLine)
                rail[2].norm()
                rail[2].mult(cos(railAngle) * magnitude * 0.95)
                
                let checkLine = Vector(X: location.x, Y: location.y)
                checkLine.sub(rail[0])
                if checkLine.mag() > railLine.mag() {
                    checkLine.set(rail[1])
                    checkLine.sub(location)
                    rail[2].set(checkLine)
                }
                checkLine.set(location)
                checkLine.sub(rail[1])
                if checkLine.mag() > railLine.mag() {
                    checkLine.set(rail[0])
                    checkLine.sub(location)
                    rail[2].set(checkLine)
                }
                
                location.add(rail[2])
            }
            else if dock != nil {
                location.add(level.islands[dock!].rail[2])
            }
        }
    }
    
    func unlock() {
        if key != nil {
            if level.items[key!].opened {
                if !(timer > 150) {
                    timer! += 1
                }
            }
        }
    }
}

class Shrapnel {
    let location: Vector
    let velocity: Vector
    let speed: Float
    
    init(start: Vector, heading: Vector) {
        speed = 3
        
        location = start
        velocity = heading
        velocity.mult(speed)
    }
    
    func move() {
        velocity.mult(0.9)
        location.add(velocity)
    }
}

class Bullet {
    let location: Vector
    let velocity: Vector
    let acceleration: Vector
    let radius: Int
    let speed: Float
    var timer: Int
    var explode: Int
    
    init(start: Vector, heading: Vector) {
        speed = 4.5
        timer = 0
        explode = 0
        
        location = start
        velocity = heading
        velocity.mult(speed)
        acceleration = Vector(X: 0, Y: 0)
        radius = 3
    }
    
    func tick() {
        if explode == 0 {
            if timer > 3 || location.x < centerX - viewWidth/2 || location.x > centerX + viewWidth/2 || location.y < centerY - viewHeight/2 || location.y > centerY + viewHeight/2 {
                explode = 1
            }
            else if Vector(X: location.x-player.location.x, Y: location.y-player.location.y).mag() < Float(radius + 4) {
                explode = 3
            }
        }
    }
    
    func collide(island: Island) {
        for v2 in 0 ..< island.vertices.count {
            let p2 = Vector(X: 0, Y: 0)
            p2.set(island.location)
            p2.add(island.vertices[v2])
            
            let line2 = Vector(X: p2.x, Y: p2.y)
            line2.sub(location)
            
            if line2.mag() < Float(radius) + (velocity.mag()*0.5) {
                let angle = angleBetween(velocity, vector2: line2)
                
                if angle < Float(0.5 * M_PI) {
                    line2.norm()
                    line2.mult(-2 * cos(angle) * velocity.mag())
                    velocity.add(line2)
                }
            }
            
            var v1 = v2 - 1
            if v1 < 0 {
                v1 = island.vertices.count-1
            }
            
            let p1 = Vector(X: 0, Y: 0)
            p1.set(island.location)
            p1.add(island.vertices[v1])
            
            let wall = Vector(X: p2.x, Y: p2.y)
            wall.sub(p1)
            
            let line1 = Vector(X: location.x, Y: location.y)
            line1.sub(p1)
            
            if angleBetween(line2, vector2: wall) < Float(0.5 * M_PI) && angleBetween(line1, vector2: wall) < Float(0.5 * M_PI) {
                var angle = angleBetween(line1, vector2: wall)
                let shadow = Vector(X: wall.x, Y: wall.y)
                shadow.norm()
                shadow.mult(cos(angle) * line1.mag())
                shadow.add(p1)
                
                let line3 = Vector(X: shadow.x, Y: shadow.y)
                line3.sub(location)
                
                if line3.mag() < Float(radius) + (velocity.mag()*0.5) {
                    angle = angleBetween(line3, vector2: velocity)
                    
                    if angle < Float(0.5 * M_PI) {
                        line3.norm()
                        line3.mult(-2 * cos(angle) * velocity.mag())
                        velocity.add(line3)
                        timer += 1
                    }
                }
            }
        }
    }
    
    func move() {
        if timer > 0 {
            let myGravity = Vector(X: player.myGravity.x, Y: player.myGravity.y)
            myGravity.norm()
            myGravity.mult(0.05)
            
            acceleration.add(myGravity)
            velocity.add(acceleration)
            velocity.mult(0.99)
        }
        location.add(velocity)
        
        acceleration.mult(0)
    }
}

class Item {
    var location: Vector
    var angle: Float
    var type: String
    var pivot: Int? = nil
    var dock: Int? = nil
    var bullets: [Bullet] = []
    var shrapnel: [Shrapnel] = []
    var opened: Bool
    var key: Int? = nil
    var timer: Int? = nil
    var initialState: Bool? = nil
    var direction: Int? = nil
    
    init(l: Vector, a: Float, t: String, p: Int? = nil, d: Int? = nil, k: Int? = nil, i: Bool? = nil) {
        location = Vector(X: centerX + l.x, Y: centerY + l.y)
        angle = a
        type = t
        if p != nil {
            pivot = p
        }
        if d != nil {
            dock = d
        }
        if k != nil {
            key = k
        }
        if i != nil {
            initialState = i
        }
        opened = false
        if t == "turret" {
            timer = 150
        }
        else if (t == "door" && k != nil) || t == "button" || (t == "spike" && k != nil) {
            timer = 0
        }
        if t == "switch" {
            direction = Int(angle)
            angle = 0
        }
        var newLineRange = type.rangeOfString("\\n")
        while newLineRange != nil {
            type.replaceRange(newLineRange!, with: "\n")
            newLineRange = type.rangeOfString("\\n")
        }
    }
    
    func rotate(anchor: Vector, angleV: Float) {
        let radial = Vector(X: location.x, Y: location.y)
        radial.sub(anchor)
        let magnitude = radial.mag()
        
        radial.set(createVectorFromAngle(radial.heading() + angleV))
        radial.mult(magnitude)
        radial.add(anchor)
        
        location.set(radial)
        angle += angleV
    }
    
    func slide(anchorV: Vector) {
        location.add(anchorV)
    }
    
    func action(p: Vector) {
        let distance = Vector(X: p.x, Y: p.y)
        
        if type == "spike" {
            let actionSite = createVectorFromAngle(angle-Float(M_PI*0.5))
            actionSite.mult(4)
            actionSite.add(location)
            distance.sub(actionSite)
            
            if key != nil {
                if level.items[key!].opened {
                    if !(timer > 50) {
                        timer! += 1
                    }
                }
            }
            
            if distance.mag() < 10 {
                if key == nil {
                    reset = true
                }
                else {
                    if initialState == true {
                        if timer == 0 {
                            reset = true
                        }
                    }
                    else {
                        if timer >= 50 {
                            reset = true
                        }
                    }
                }
            }
        }
        else if type == "door" {
            let actionSite = createVectorFromAngle(angle-Float(M_PI*0.5))
            actionSite.mult(8)
            actionSite.add(location)
            distance.sub(actionSite)
            
            if key != nil {
                if level.items[key!].opened {
                    if !(timer > 200) {
                        timer! += 1
                    }
                }
            }
            
            if distance.mag() < 14 {
                if key != nil {
                    if timer > 200 {
                        opened = true
                    }
                }
                else {
                    opened = true
                }
            }
        }
        else if type == "turret" {
            distance.sub(location)
            timer! -= 1
            
            if (timer! < 1) {
                timer = 50 + Int(arc4random_uniform(100))
                
                let eye = createVectorFromAngle(angle - 0.5*Float(M_PI))
                
                if angleBetween(distance, vector2: eye) < 0.5*Float(M_PI) {
                    distance.norm()
                    distance.mult(Float(arc4random_uniform(100)) * 0.01 * 12)
                    
                    let bullet = Vector(X: location.x, Y: location.y)
                    bullet.add(distance)
                    distance.norm()
                    
                    bullets.append(Bullet(start: Vector(X: bullet.x, Y: bullet.y), heading: Vector(X: distance.x, Y: distance.y)))
                }
            }
            
            for bullet in 0 ..< bullets.count {
                if bullet < bullets.count {
                    bullets[bullet].tick()
                    
                    if bullets[bullet].explode > 0 {
                        if bullets[bullet].explode == 3 {
                            reset = true
                        }
                        
                        for _ in 0 ..< 3 {
                            shrapnel.append(Shrapnel(start: Vector(X: bullets[bullet].location.x, Y: bullets[bullet].location.y), heading: Vector(X: bullets[bullet].velocity.x + (Float(arc4random_uniform(100)) * 0.01 * 4) - 2, Y: bullets[bullet].velocity.y + (Float(arc4random_uniform(100)) * 0.01 * 4) - 2)))
                        }
                        
                        bullets.removeAtIndex(bullet)
                    }
                }
            }
        }
        else if type == "button" {
            distance.sub(location)
            
            if key == nil {
                if timer > 0 && timer < 50 {
                    timer! += 1
                }
                else if timer > 49 {
                    opened = true
                }
                if distance.mag() < 15 && timer == 0 {
                    timer = 1
                }
            }
            else if level.items[key!].opened {
                if timer > 0 && timer < 50 {
                    timer! += 1
                }
                else if timer > 49 {
                    opened = true
                }
                if distance.mag() < 15 && timer == 0 {
                    timer = 1
                }
            }
        }
        else if type == "switch" {
            let actionSite = createVectorFromAngle(angle-Float(M_PI*0.5))
            actionSite.mult(6)
            actionSite.add(location)
            distance.sub(actionSite)
            
            if distance.mag() < 12 {
                if !opened {
                    player.location.set(actionSite)
                    player.velocity.mult(0)
                    if direction == 0 {
                        player.myGravity.set(Vector(X: 0, Y: 1))
                    }
                    else if direction == 1 {
                        player.myGravity.set(Vector(X: -1, Y: 0))
                    }
                    else if direction == 2 {
                        player.myGravity.set(Vector(X: 0, Y: -1))
                    }
                    else if direction == 3 {
                        player.myGravity.set(Vector(X: 1, Y: 0))
                    }
                    player.myGravity.mult(0.05)
                    
                    opened = true
                }
            }
        }
    }
}

class Button {
    var initial: Float
    var location: Vector
    var target: Float
    var radius: Int
    var tapped: Bool
    var skin: String
    var link: Int
    var station: Int? = nil
    var skinChanged: Bool = false
    
    init(l: Vector, r: Int, lnk: Int, lvl: Int? = nil) {
        initial = l.x
        location = Vector(X: l.x, Y: l.y)
        target = location.x
        radius = r
        tapped = false
        skin = String(lnk) + "-"
        link = lnk
        
        if lvl != nil {
            station = lvl
        }
    }
    
    func changeSkin() {
        let previousSkin = skin
        if station != nil {
            if level.number != station {
                skin = ""
            }
            else if link <= highestLevel!+2 && link < levels {
                if levelSelect == link {
                    skin = String(link) + "+"
                }
                else if beatenLevels!.componentsSeparatedByString(",").contains(String(link)) {
                    skin = String(link) + "="
                }
                else {
                    skin = String(link) + "-"
                }
            }
            else {
                skin = "•-"
            }
        }
        
        if previousSkin != skin {
            skinChanged = true
        }
        else {
            skinChanged = false
        }
    }
    
    func checkSelected() {
        if ((station != nil && level.number == station) || (station == nil && level.number > 0)) && initialCursor != nil && finalCursor != nil && tapped == false {
            let difference = Vector(X: Float(initialCursor.x), Y: Float(initialCursor.y))
            difference.sub(Vector(X: Float(finalCursor.x), Y: Float(finalCursor.y)))
            
            if ((link == 0 && menuIndicator.x == 20) || (link != 0)) && difference.mag() < 5 {
                let distance = Vector(X: Float(location.x), Y: Float(location.y))
                distance.x += Float(radius)*0.5
                distance.sub(Vector(X: Float(initialCursor.x), Y: Float(initialCursor.y)))
                
                if distance.mag() < Float(radius) {
                    if levelSelect == link {
                        reset = true
                        readLevel(levelSelect)
                    }
                    else {
                        tapped = true
                    }
                }
            }
        }
    }
    
    func action() {
        if ((station != nil && level.number == station!) || (station == nil && level.number > 0)) && (tapped && link <= highestLevel!+2 && link < levels) {
            levelSelect = link
            tapped = false
        }
    }
    
    func move() {
        if abs(location.x-target) < 2 {
            location.x = target
        }
        
        location.x += (target-location.x)*0.5
    }
    
    func slide() {
        if level.number == 0 && station == 0 && link > 0 && target-location.x == 0 {
            if initialCursor != nil && finalCursor != nil && initialCursor.x != finalCursor.x {
                target = Float(finalCursor.x)
                target -= Float(initialCursor.x)
                target /= abs(target)
                target *= Float(viewWidth)
                
                if location.x < Float(viewWidth) && target < 0 {
                    target = Float(2*viewWidth)
                }
                if location.x > Float(2*viewWidth) && target > 0 {
                    target = Float(-2*viewWidth)
                }
                
                target += location.x
            }
        }
    }
}

class Vector {
    var x: Float
    var y: Float
    
    init(X: Float, Y: Float) {
        x = X
        y = Y
    }
    
    func set(vector: Vector) {
        x = vector.x
        y = vector.y
    }
    
    func mag() ->Float {
        return pow((powf(x, 2) + powf(y, 2)), 0.5)
    }
    
    func heading() ->Float {
        var heading: Float = 0.0
        if y >= 0 {
            if (x > 0) {
                heading = atan(y/x)
            }
            else {
                heading = Float(M_PI) - abs(atan(y/x))
            }
        }
        else {
            if (x >= 0) {
                heading = Float(M_PI * 2.0) - abs(atan(y/x))
            }
            else {
                heading = Float(M_PI) + atan(y/x)
            }
        }
        return heading
    }
    
    func add(vector: Vector) {
        x += vector.x
        y += vector.y
    }
    
    func sub(vector: Vector) {
        x -= vector.x
        y -= vector.y
    }
    
    func mult(constant: Float) {
        x *= constant
        y *= constant
    }
    
    func div(constant: Float) {
        x /= constant
        y /= constant
    }
    
    func norm() {
        if (!(x == 0 && y == 0)) {
            let heading = self.heading()
            
            x = cos(heading)
            y = sin(heading)
        }
    }
    
    func equals(vector: Vector) ->Bool {
        var isEsqual: Bool = false
        
        if (x == vector.x && y == vector.y) {
            isEsqual = true
        }
        
        return isEsqual
    }
}

func angleBetween(vector1: Vector, vector2: Vector)->Float {
    let heading1: Float = vector1.heading()
    let heading2: Float = vector2.heading()
    var angle: Float = 0
    
    angle = abs(heading2 - heading1)
    
    if Double(angle) > M_PI {
        angle = Float(M_PI*2.0) - angle
    }
    
    return angle
}

func createVectorFromAngle(angle: Float) ->Vector {
    let created = Vector(X: 0, Y: 0)
    
    created.x = cos(angle)
    created.y = sin(angle)
    
    return created
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
