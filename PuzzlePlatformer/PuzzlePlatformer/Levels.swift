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
            levels = levelFileString.componentsSeparatedByString("\n").count
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
        
        let number = Int(summary[0])!
        let name = summary[1]
        let start = Vector(X: Float(summary[2])!, Y: Float(summary[3])!)
        
        var initial: Int = 0
        if summary.count == 5 {
            initial = Int(summary[4])!
        }
        else if summary.count == 8 {
            initial = Int(summary[7])!
        }
        
        var rotates = false
        var gravityRotates = false
        if summary.count > 5 {
            rotates = summary[4].toBool()!
            gravityRotates = summary[5].toBool()!
        }
        
        var gravitySwitches = false
        if summary.count > 6 {
            gravitySwitches = summary[6].toBool()!
        }
        
        level = Level(num: number, nam: name, start: start, rotates: rotates, gravityRotates: gravityRotates, gravitySwitches: gravitySwitches, initial: initial)
        
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