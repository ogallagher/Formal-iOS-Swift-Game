//
//  Levels.swift
//  PuzzlePlatformer
//
//  Created by Owen Gallagher on 8/4/16.
//  Copyright © 2016 Owen. All rights reserved.
//

import Foundation

func readLevel(i: Int) {
    do {
        let levelFileString = try String(contentsOfFile: levelFile!)
        if i == 0 {
            levels = levelFileString.componentsSeparatedByString("\n").count - 1
        }
        
        let levelString = levelFileString.componentsSeparatedByString("\n")[i]
        let levelObjects: [String] = levelString.componentsSeparatedByString("+")
        var summary: [String] = []
        var islands: [Island] = []
        var items: [Item] = []
        
        for levelObject in levelObjects {
            if levelObject.rangeOfString("=") == nil {
                summary = levelObject.componentsSeparatedByString(",")
            }
            else {
                let objectData = levelObject.componentsSeparatedByString("=")
                
                if objectData[0] == "island" {
                    let locations = objectData[1].componentsSeparatedByString(",")
                    let location = Vector(X: Float(locations[0])!, Y: Float(locations[1])!)
                    
                    if (objectData.count == 4) {
                        let aspects = objectData[3].componentsSeparatedByString(",") //MAX = 7: rotates,slides,rail1,rail2,pivot,dock,key
                        
                        if aspects[1].toBool()! {
                            let rails1 = aspects[2].componentsSeparatedByString(" ")
                            let rails2 = aspects[3].componentsSeparatedByString(" ")
                                var rail1: Vector? = nil
                                    if Float(rails1[0]) != -1 {
                                        rail1 = Vector(X: Float(rails1[0])!, Y: Float(rails1[1])!)
                                    }
                                var rail2: Vector? = nil
                                    if Float(rails2[0]) != -1 {
                                        rail2 = Vector(X: Float(rails2[0])!, Y: Float(rails2[1])!)
                                    }
                            var pivot: Int? = nil
                                if Int(aspects[4]) > -1 {
                                    pivot = Int(aspects[4])
                                }
                            var dock: Int? = nil
                                if Int(aspects[5]) > -1 {
                                    dock = Int(aspects[5])
                                }
                            var key: Int? = nil
                                if Int(aspects[6]) > -1 {
                                    key = Int(aspects[6])
                                }
                                
                            islands.append(Island(l: location, v: objectData[2], rotates: aspects[0].toBool()!, slides: true, railStart: rail1, railEnd: rail2, pivotNum: pivot, dockNum: dock, keyNum: key))
                        }
                        else {
                            var pivot: Int? = nil
                                if Int(aspects[2]) > -1 {
                                    pivot = Int(aspects[2])
                                }
                            var dock: Int? = nil
                                if Int(aspects[3]) > -1 {
                                    dock = Int(aspects[3])
                                }
                            var key: Int? = nil
                                if Int(aspects[4]) > -1 {
                                    key = Int(aspects[4])
                                }
                            islands.append(Island(l: location, v: objectData[2], rotates: aspects[0].toBool()!, slides: false, pivotNum: pivot, dockNum: dock, keyNum: key))
                        }
                    }
                    else {
                        islands.append(Island(l: location, v: objectData[2], rotates: false, slides: false))
                    }
                }
                else {
                    let locations = objectData[1].componentsSeparatedByString(",")
                    let location = Vector(X: Float(locations[0])!, Y: Float(locations[1])!)
                    
                    if (objectData.count == 4) {
                        let aspects = objectData[3].componentsSeparatedByString(",") //MAX = 4: pivot,dock,key,initial
                        var pivot: Int? = nil
                            if Int(aspects[0]) > -1 {
                                pivot = Int(aspects[0])
                            }
                        var dock: Int? = nil
                            if Int(aspects[1]) > -1 {
                                dock = Int(aspects[1])
                            }
                        var key: Int? = nil
                            if Int(aspects[2]) > -1 {
                                key = Int(aspects[2])
                            }
                        var initial: Bool? = nil
                            if Int(aspects[3]) > -1 {
                                initial = aspects[3].toBool()
                            }
                        items.append(Item(l: location, a: Float(objectData[2])!, t: objectData[0], p: pivot, d: dock, k: key, i: initial))
                    }
                    else {
                        items.append(Item(l: location, a: Float(objectData[2])!, t: objectData[0]))
                    }
                }
            }
        }
        
        if summary.count == 6 {
            //number,name,x,y,rotates,gravityrotates
            level = Level(num: Int(summary[0])!, nam: summary[1], start: Vector(X: Float(summary[2])!, Y: Float(summary[3])!), rotates: summary[4].toBool()!, gravityRotates: summary[5].toBool()!)
        }
        else if summary.count == 4 {
            //number,name,x,y
            level = Level(num: Int(summary[0])!, nam: summary[1], start: Vector(X: Float(summary[2])!, Y: Float(summary[3])!), rotates: false)
        }
        
        for island in islands {
            level.addIsland(island)
        }
        for item in items {
            level.addItem(item)
        }
    }
    catch {
        print("ERROR: FILE NOT FOUND")
    }
}

//    //————————————————————————————————————————————————————————————————— 0: Menu
//    levels.append(Level(start: Vector(X: -90, Y: 100), rotates: false))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: 100), a: 20, t: "Tap the desired level\nSwipe for more levels"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: 190), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 1: Nothing
//    levels.append(Level(start: Vector(X: -100, Y: 0), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 100), v: "-150,-10 150,-10 150,10 -150,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: -170), a: 30, t: "Swipe to move\nthe blue square"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: 20), a: 25, t: "To the green\none"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 89), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 2: Cliff
//    levels.append(Level(start: Vector(X: -90, Y: -30), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -115, Y: 20), v: "-20,-10 160,-10 160,10 -20,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 130, Y: 180), v: "-50,-20 20,-20 20,20 -50,20", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: -140), a: 70, t: "Try not to\ntouch"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 90), a: 60, t: "the edges"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 159), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 3: Statics
//    levels.append(Level(start: Vector(X: -90, Y: -50), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-40,-20 -30,-30 50,-30 60,-20 60,20 50,30 -30,30 -40,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "Swiping is only enabled\nwhen touching the\nground"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 160), a: 30, t: "So no flying"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: 109), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 4: Chimneys
//    levels.append(Level(start: Vector(X: 130, Y: -80), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 100, Y: -40), v: "-45,-10 -40,-15 45,-15 45,15 -45,15", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: -50), v: "-5,-25 5,-25 5,25 -5,25", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: 70), v: "-15,-100 15,-100 15,100 -15,100", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: 70), v: "-15,-100 15,-100 15,100 -15,100", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -35, Y: -40), v: "-65,-15 60,-15 65,-10 65,15 -65,15", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 43, Y: 190), v: "-10,-5 10,-5 10,5 -10,5", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: -105), v: "-5,-80 5,-80 5,80 -5,80", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -55, Y: -160), v: "-5,-25 5,-25 5,80 -5,80", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -160), a: 40, t: "You can\njump"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 10), a: 70, t: "from\nwalls"))
//        
//    levels[levels.count-1].addItem(Item(l: Vector(X: -61, Y: -170), a: Float(M_PI*1.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 43, Y: 184), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 5: Triangles
//    levels.append(Level(start: Vector(X: -115, Y: -190), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -80), v: "-60,-60 50,40 50,50 -70,50 -70,-60", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 55, Y: 40), v: "70,-80 -70,60 -70,70 80,70 80,-80", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 50), v: "-30,-40 30,20 30,30 -40,30 -40,-40", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -20, Y: 200), v: "-100,-10 100,-10 100,10 -100,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -110, Y: 170), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: -140), a: 20, t: "Feel free to swipe in any\n    direction, not just the\n        cardinal ones"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 40), a: Float(M_PI*0.25), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 104, Y: -20), a: Float(M_PI*1.75), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 20,Y: 189), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 6: Classic
//    levels.append(Level(start: Vector(X: -55, Y: -10), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: -20), v: "-5,-38 5,-38 5,32 -5,32", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: 20), v: "-80,-8 160,-8 160,8 -80,8", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -5, Y: 5), v: "0,-20 20,10 -20,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 45, Y: 5), v: "0,-25 50,-25 65,10 -30,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 125, Y: -40), v: "-20,-8 25,-8 25,8 -20,8", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: -48), v: "0,-20 0,0 -20,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 50, Y: -80), v: "-40,-5 23,-5 23,5 -40,5", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -140, Y: 0), v: "-10,-100 10,-100 10,200 -10,200", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 190), v: "-130,-10 140,-10 140,10 -130,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: 179), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: 179), a: 0, t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -145, Y: -200), a: 25, t: "A shorter swipe\nis a shorter jump"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -65, Y: 120), a: 15, t: "Don't touch those"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 45, Y: -86), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 130, Y: 179), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 7: Attic
//    levels.append(Level(start: Vector(X: 0, Y: 50), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 200), v: "-160,-10 160,-10 160,10 -160,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: 0), v: "-10,-150 10,-150 10,200 -10,200", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -150), v: "-160,-10 160,-10 160,10 -160,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -150, Y: -90), v: "-10,-50 10,-50 10,50 -10,50", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: -120), a: 25, t: "That curly arrow in the\ncorner is \na restart button"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -100), a: 40, t: "not"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: 120), a: 25, t: "Try rotating\nthe device"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -139, Y: -100), a: Float(M_PI*0.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 8: Square
//    levels.append(Level(start: Vector(X: 0, Y: 0), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 130), v: "-110,-10 110,-10 110,10 -110,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 120, Y: 120), v: "0,-10 20,-10 -10,20 -10,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 130, Y: 0), v: "-10,-110 10,-110 10,110 -10,110", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 120, Y: -120), v: "-10,0 -10,-20 20,10 0,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -130), v: "-110,-10 110,-10 110,10 -110,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X:-120, Y: -120), v: "10,0 10,-20 -20,10 0,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -130, Y: 0), v: "-10,-110 10,-110 10,110 -10,110", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: 120), v: "0,-10 -20,-10 10,20 10,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -30), v: "-90,-10 90,-10 90,10 -90,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -0), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: 90), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 20), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 10), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 0), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: -10), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 110), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 100), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 90), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 80), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -39, Y: 70), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 59), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -10, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 10, Y: -41), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 20, Y: -41), a: 0, t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: -180), a: 25, t: "Now put"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -100), a: 35, t: "movement"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: 25), a: 25, t: "and"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: 20), a: 35, t: "rotation"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 155), a: 25, t: "together"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -119), a: Float(M_PI), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -119, Y: 80), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -41), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 9: Spiral
//    levels.append(Level(start: Vector(X: -70,Y: -180), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: -160), v: "-50,-10 60,-10 60,10 -60,10 -60,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: -55), v: "-10,-115 10,-115 10,115 -10,115", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-10,-150 10,-150 10,150 -10,150", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: 160), v: "-90,-10 90,-10 90,0 80,10 -80,10 -90,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: 110), v: "-10,-40 10,-40 10,40 -10,40", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -160), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -150), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -140), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -130), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -120), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -110), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -100), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -90), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -80), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -70), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: -60), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: 69), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 34, Y: 149), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 44, Y: 149), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 54, Y: 149), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 10), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 0), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -10), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -20), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -30), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -40), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -50), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -60), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: -70), a: Float(M_PI*0.5), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: -150), a: 25, t: "Your gravity\nonly changes\nwhen you're\ntouching\nground"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -149), a: Float(M_PI), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 20, Y: 171), a: Float(M_PI), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 21, Y: 35), a: Float(M_PI*0.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 10: Rounded
//    levels.append(Level(start: Vector(X: -120, Y: 55), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90.72, Y: 80.72), v: "-50,-10 20,-10 20,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: 61), v: "-10,-10 10,-10 10,10 -10,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 90.72, Y: -100.72), v: "-20,-40 20,-40 20,40 -20,40", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 0), v: "-100,0 100,0 100,10 0,100 -100,10", rotates: true, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: -200), a: 50, t: "Rounded\nground\nalways"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: 130), a: 55, t: "stays  upright"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 69.28, Y: -110), a: Float(M_PI * 1.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 11: Toothbrush
//    levels.append(Level(start: Vector(X: -50,Y: -160), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -110), v: "-50,-15 70,-15 70,15 -70,15 -70,0", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -110, Y: 15), v: "-10,-110 10,-110 10,100 0,110 -10,110", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -60), v: "-60,-10 50,-10 55,-5 55,5 50,10 -60,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: -40), v: "-20,-10 20,-10 20,10 -20,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: -20), v: "-50,-10 20,-10 25,-5 25,5 20,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 10), v: "-10,-20 10,-20 10,20 -10,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 30), v: "-40,-10 10,-10 10,10 -40,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -20, Y: 90), v: "-10,-50 10,-50 10,40 0,50 -10,50", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -80, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -60, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -10, Y: -94), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -94), a: Float(M_PI), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -40), a: 30, t: "       The\n   best\nway\nmay not\nbe the"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 145), a: 55, t: "only  way"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 11, Y: -40), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -1, Y: 5), a: Float(M_PI*1.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 12: Balance
//    levels.append(Level(start: Vector(X: -130, Y: -180), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 0), v: "-100,0 100,0 100,10 0,100 -100,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: -80), v: "-50,-10 50,-10 50,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -10, Y: 150), v: "-10,-50 10,-50 10,50 -10,50", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -180), a: 85, t: "Don't"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: -60), a: 40, t: "slide  too\n\n\n\n                far..."))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 1, Y: 165), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -21, Y: 145), a: Float(M_PI*1.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 13: Nostalgia
//    levels.append(Level(start: Vector(X: 80, Y: 100), rotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-50,-20 -40,-30 50,-30 60,-20 60,20 50,30 -40,30 -50,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "Remember this one?\n   Here's a hint: when you\n       drag your finger, the\n         square doesn't move\n           until you release it."))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 160), a: 30, t: "     Now go up"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -31), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 14: Fountain
//    levels.append(Level(start: Vector(X: -100, Y: -200), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: -150), v: "-40,0 40,0 40,10 0,40 -40,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -25, Y: -140), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: -160), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: -70), v: "-60,0 60,0 60,10 0,60 -60,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 8, Y: 51), v: "-70,0 70,0 70,10 0,70 -70,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: 170), v: "50,-40 60,-40 60,40 -60,40 -60,30", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -45, Y: -151), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -35, Y: -151), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -25, Y: -151), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -151), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -5, Y: -151), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 15, Y: -191), a: 0, t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -160), a: 40, t: "    There\n    is"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -35), a: 55, t: "nothing"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 20), a: 48, t: "to\nsay."))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: 130), a: 20, t: "...In addition to\nwhat I just said,\nI mean."))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -71), a: 0, t: "door", p: 3))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 65, Y: 50), a: 0, t: "door", p: 4))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -82, Y: 181), a: Float(-1 * atan(0.63)), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 11, Y: 200), a: Float(M_PI * 0.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 15: Crowding
//    levels.append(Level(start: Vector(X: 80, Y: 100), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -90, Y: 0), v: "-30,-20 -20,-30 20,-30 30,-20 30,20 20,30 -20,30 -30,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 40), v: "-40,-20 -30,-30 50,-30 60,-20 60,20 50,30 -30,30 -40,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 120), v: "-120,-10 100,-10 100,10 -120,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -160), a: 25, t: "This is the last time \nthat I copy this level.\n\n                 I promise."))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 9), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 101, Y: 40), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: 71), a: Float(M_PI), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -90, Y: -31), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -121, Y: 0), a: Float(M_PI*1.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 16: Random
//    levels.append(Level(start: Vector(X: -110, Y: 90), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 115), v: "-50,0 50,0 50,10 0,50 -50,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 170), v: "-70,-5 60,-5 60,5 -70,5", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: 100), v: "-5,-35 5,-35 5,75 -5,75", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -50, Y: -35), v: "-30,-80 -10,-100 20,-100 30,-90 30,100 -30,100", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: -80), v: "-40,-20 40,-20 40,20 -40,20", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 70, Y: -20), v: "-40,0 40,0 40,10 0,40 -40,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 110, Y: 60.62), v: "-50,0 50,0 50,10 0,50 -50,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 105, Y: 160.62), v: "-5,-50 5,-50 5,50 -5,50", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 99, Y: 200), a: Float(M_PI*1.5), t: "button"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -110, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: 164), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -70, Y: 66), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -60, Y: 66), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -50, Y: 66), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 66), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -30, Y: 66), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 55), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 45), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -81, Y: 35), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 55), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 45), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: 35), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 40, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 60, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 90, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -101), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -90), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -80), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: -70), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -59), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 80, Y: -59), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 90, Y: -59), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: -59), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -90), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -80), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: -70), a: Float(M_PI*1.5), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -135, Y: -200), a: 25, t: "That little yellow thing \nin the corner is a"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -140), a: 45, t: "b"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -110), a: 45, t: "u"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -80), a: 45, t: "t"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -50), a: 45, t: "t"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -20), a: 45, t: "o"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: 10), a: 45, t: "n"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -19, Y: -80), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 111, Y: 200), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -125, Y: 176), a: Float(M_PI), t: "door", k: 0))
//    
//    //————————————————————————————————————————————————————————————————— 17: Skyscraper
//    levels.append(Level(start: Vector(X: -10, Y: 45), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 100), v: "-50,-10 50,-10 50,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -45, Y: 75), v: "-10,-35 10,-35 10,35 0,35 -10,25", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 10, Y: 165), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -40, Y: 20), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 75, Y: 20), v: "-30,-10 10,-10 10,10 -30,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -85), v: "-10,-115 10,-115 10,115 -10,115", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 15, Y: -65), v: "-40,-10 36,-10 36,10 -40,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -15, Y: -95), v: "-10,-40 10,-40 10,40 -10,40", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 61, Y: 100), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: 111), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -9, Y: 20), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 44, Y: 20), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 75, Y: 9), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 45, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 35, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 15, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 5, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -5, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -54), a: Float(M_PI), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -125), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -115), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -26, Y: -105), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -15, Y: -136), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -80, Y: -201), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -69, Y: -190), a: Float(M_PI*0.5), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -40, Y: -180), a: 37, t: "Precision"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 70, Y: -125), a: 55, t: "is"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -20, Y: -40), a: 25, t: "probably"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -140, Y: 35), a: 40, t: "the\n\nfor this     level"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: 38), a: 30, t: "key word"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -69, Y: -30), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 25, Y: -76), a: 0, t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -91, Y: -170), a: Float(M_PI*1.5), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 18: Bridge
//    levels.append(Level(start: Vector(X: -90, Y: -120), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: -100), v: "-25,0 25,0 25,10 0,25 -25,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -80, Y: 100), v: "-25,0 25,0 25,10 0,25 -25,10", rotates: true, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -60, Y: -140), v: "-5,-40 5,-40 5,40 -5,40", rotates: true, slides: false, pivotNum: 0))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -5, Y: -175), v: "-50,-5 50,-5 50,5 -50,5", rotates: true, slides: false, pivotNum: 0))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -100, Y: 60), v: "-5,-40 5,-40 5,40 -5,40", rotates: true, slides: false, pivotNum: 1))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -130, Y: 25), v: "-25,-5 25,-5 25,5 -25,5", rotates: true, slides: false, pivotNum: 1))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 75, Y: -160), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false, keyNum: 2))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 60, Y: -20), v: "-30,-8 30,-8 30,8 -30,8", rotates: false, slides: false, keyNum: 1))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 80, Y: 40), v: "-50,-8 50,-8 50,8 -50,8", rotates: false, slides: false, keyNum: 1))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -65, Y: 99), a: 0, t: "button", p: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 35, Y: -181), a: 0, t: "button", p: 0))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 60, Y: -29), a: 0, t: "button", k: 1))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -145, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -125, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -105, Y: 19), a: 0, t: "spike", p: 1, k: 0, i: true))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -94, Y: 30), a: Float(M_PI*0.5), t: "spike", p: 1, k: 0, i: false))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -94, Y: 60), a: Float(M_PI*0.5), t: "spike", p: 1, k: 0, i: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -92, Y: -101), a: 0, t: "door", p: 0, k: 0))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 95, Y: -171), a: 0, t: "door", k: 2))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 120, Y: 31), a: 0, t: "door", k: 1))
//    
//    //————————————————————————————————————————————————————————————————— 19: Guillotine
//    levels.append(Level(start: Vector(X: -120, Y: 180), rotates: true, gravityRotates: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -120, Y: 200), v: "-20,0 -10,-10 20,-10 20,10 -20,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -60, Y: 200), v: "-40,-10 -20,-40 40,-40 40,10 -40,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 20, Y: 170), v: "-40,-10 -30,-30 40,-30 40,40 -40,40", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 110, Y: 0), v: "-40,150 -40,140 25,-125 50,-125 50,150", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: -140), v: "-30,-5 30,-5 30,5 -30,5", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 30, Y: 0), v: "-30,-30 30,-30 30,30 -30,30", rotates: false, slides: true, railStart: Vector(X: 30, Y: -80), railEnd: Vector(X: 30, Y: 100)))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -105, Y: -110), v: "-25,-5 20,-5 20,5 -25,5", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 10, Y: 31), a: Float(M_PI), t: "spike", d: 5))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 20, Y: 31), a: Float(M_PI), t: "spike", d: 5))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 30, Y: 31), a: Float(M_PI), t: "spike", d: 5))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 40, Y: 31), a: Float(M_PI), t: "spike", d: 5))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 50, Y: 31), a: Float(M_PI), t: "spike", d: 5))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -120, Y: -116), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 20: Hatch
//    levels.append(Level(start: Vector(X: 80, Y: 105), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 80, Y: 130), v: "-30,-10 40,-10 40,10 -30,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 120, Y: 5), v: "-10,-185 10,-185 10,135 -10,135", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 40, Y: 5), v: "-10,-145 10,-145 10,135 -10,135", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 105, Y: -185), v: "-15,-5 -15,-25 -5,-25 25,5 25,15 5,15", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -200), v: "-100,-10 100,-10 100,10 -100,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -145), v: "-50,-10 50,-10 50,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: 65), v: "-50,-10 40,-10 40,10 -50,10", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -20), v: "-50,20 40,-60 40,40 -40,40 -50,35", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -75, Y: -100), v: "-35,-50 25,-50 25,50 -25,50 -35,40", rotates: false, slides: true, railStart: Vector(X: -75, Y: -125), railEnd: Vector(X: -75, Y: 25)))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -95, Y: -151), a: 0, t: "spike", d: 8))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -80, Y: -151), a: 0, t: "spike", d: 8))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -65, Y: -151), a: 0, t: "spike", d: 8))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -111, Y: -140), a: Float(M_PI*1.5), t: "spike", d: 8))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: -55), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: -40), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: -25), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: -10), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: 5), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: 20), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: 35), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: 50), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 109, Y: 65), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -145), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -130), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -115), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -100), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -85), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -70), a: Float(M_PI*0.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 51, Y: -55), a: Float(M_PI*0.5), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 99, Y: -179), a: Float(M_PI*1.25), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 29, Y: 40), a: Float(M_PI*1.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -111, Y: -115), a: Float(M_PI*1.5), t: "door", d: 8))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 100, Y: 141), a: Float(M_PI), t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 21: Boat
//    levels.append(Level(start: Vector(X: 90, Y: 100), rotates: true))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 90, Y: 140), v: "-46,-20 46,-20 46,10 36,20 -36,20 -46,10", rotates: false, slides: true, railStart: Vector(X: -116, Y: 140), railEnd: Vector(X: 116, Y: 140)))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 80, Y: -60), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: true, railStart: Vector(X: 35, Y: -60), railEnd: Vector(X: 115, Y: -60)))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 54, Y: 90), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: true, dockNum: 0))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 126, Y: 90), v: "-10,-30 10,-30 10,30 -10,30", rotates: false, slides: true, dockNum: 0))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 150, Y: -60), v: "-10,-120 10,-120 10,120 -10,120", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: 0, Y: -60), v: "-10,-170 10,-170 10,120 -10,120", rotates: false, slides: false))
//    levels[levels.count-1].addIsland(Island(l: Vector(X: -110, Y: 10), v: "-30,-10 30,-10 30,10 -30,10", rotates: false, slides: false))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 0, Y: -231), a: 0, t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -145), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -130), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -115), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -100), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -85), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 91, Y: -80), a: Float(M_PI*0.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 91, Y: -60), a: Float(M_PI*0.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 91, Y: -40), a: Float(M_PI*0.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 69, Y: -80), a: Float(M_PI*1.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 69, Y: -60), a: Float(M_PI*1.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 69, Y: -40), a: Float(M_PI*1.5), t: "spike", d: 1))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -141, Y: 10), a: Float(M_PI*1.5), t: "spike"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -79, Y: 10), a: Float(M_PI*0.5), t: "spike"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: -150, Y: -190), a: 35, t: "Tilt\ngravity\nto\n\n\n\n\njump\n\nf    u   r   t   h   e   r"))
//    
//    levels[levels.count-1].addItem(Item(l: Vector(X: 90, Y: 161), a: Float(M_PI), t: "door", d: 0))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 11, Y: -220), a: Float(M_PI*0.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -11, Y: -220), a: Float(M_PI*1.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: 139, Y: -165), a: Float(M_PI*1.5), t: "door"))
//    levels[levels.count-1].addItem(Item(l: Vector(X: -130, Y: -1), a: 0, t: "door"))
//    
//    //————————————————————————————————————————————————————————————————— 22: Train
//    
//    //————————————————————————————————————————————————————————————————— 23: Antennae
//    
//    //————————————————————————————————————————————————————————————————— 24: Shell
//    
//    //————————————————————————————————————————————————————————————————— 25: Intrusion
//    
//    //————————————————————————————————————————————————————————————————— 26: Hail