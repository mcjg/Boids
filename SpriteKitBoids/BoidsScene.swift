//
//  GameScene.swift
//  SpriteKitBoids
//
//  Created by matt on 23/09/2015.
//  Copyright (c) 2015 Matthew Green Associates. All rights reserved.
//

import SpriteKit

class BoidsScene: SKScene {
    
    let numBoids = 50
    var boids = [Boid]()
    var boidsGrid:[[Array<Boid>]]!
    var resolution:CGFloat = 100
    var columns:Int!
    var rows:Int!
    
    var obstacles:Array<SKShapeNode> = []
    
    override func didMoveToView(view: SKView) {
        
        columns = Int(ceil(view.frame.size.width / resolution))
        rows = Int(ceil(view.frame.size.height / resolution))
        
        boidsGrid = [[Array<Boid>]](count: columns, repeatedValue: [Array<Boid>](count: rows, repeatedValue: []))
        
        for _ in 0 ..< numBoids {
            let boid = randomBoid()
            let column = Int(boid.position.x / resolution)
            let row = Int(boid.position.y / resolution)
            boid.columnIndex = column
            boid.rowIndex = row

            boidsGrid[column][row].append(boid)
            
            boids.append(boid)
            addChild(boid)
        }
        
        backgroundColor = SKColor.blackColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: Selector("dragged:"))
        self.view?.addGestureRecognizer(tapRecognizer)
        self.view?.addGestureRecognizer(dragRecognizer)
        
        
    }
    
    func randomBoid() -> Boid {
        var boid:Boid!
        let texture = SKTexture(imageNamed: "Spaceship")
        repeat {
            let randomX = randomFloatBetween(texture.size().width / 2, max: size.width - (texture.size().width / 2))
            let randomY = randomFloatBetween(texture.size().width / 2, max: size.height - (texture.size().height / 2))
            boid = Boid(texture: texture, velocity: CGVectorMake(randomFloatBetween(-5, max: 5), randomFloatBetween(-5, max: 5)), location: CGVectorMake(randomX, randomY))
        } while intersectsBoids(boid)
        boid.zPosition = 0
        return boid
    }
    
    func intersectsBoids(boidTemp:Boid) -> Bool {
        for boid:Boid in boids {
            if boidTemp.intersectsNode(boid) {
                return true;
            }
        }
        return false
    }
    
    
    func tapped(recognizer:UITapGestureRecognizer) {
        var touchPoint = recognizer.locationInView(self.view)
        touchPoint = self.convertPointFromView(touchPoint)

        if let node:SKNode = self.nodeAtPoint(touchPoint) {
            if node.name != "Obstacle" {
                createObstacle(touchPoint)
            } else {
                deleteObstacle(node as! SKShapeNode)
            }
        }
    }
    
    func dragged(recognizer:UIPanGestureRecognizer) {
        
        var touchPoint = recognizer.locationInView(self.view)
        touchPoint = self.convertPointFromView(touchPoint)
        if let node:SKNode = self.nodeAtPoint(touchPoint) {
            if node.name != "Obstacle" {
                return
            } else {
                
                if recognizer.state == .Began {
                    node.removeAllActions()
                    let scaleEffect = SKTScaleEffect(node: node, duration: 0.2, startScale: CGPoint(x: 1, y: 1), endScale: CGPoint(x: 2, y: 2))
                    scaleEffect.timingFunction = SKTTimingFunctionExtremeBackEaseIn
                    node.runAction(SKAction.actionWithEffect(scaleEffect))
                } else if recognizer.state == .Changed {
                    node.position = touchPoint
                } else if recognizer.state == .Ended {
                    node.removeAllActions()
                    let scaleEffect = SKTScaleEffect(node: node, duration: 0.2, startScale: CGPoint(x: 2, y: 2), endScale: CGPoint(x: 1, y: 1))
                    scaleEffect.timingFunction = SKTTimingFunctionExtremeBackEaseOut
                    node.runAction(SKAction.actionWithEffect(scaleEffect))
                }
            }
        }
        
    }
    
    func createObstacle(point:CGPoint) {
        let targetNode = SKShapeNode(circleOfRadius: 44)
        targetNode.strokeColor = SKColor.redColor()
        targetNode.lineWidth = 2
        targetNode.fillColor = SKColor.clearColor()
        targetNode.position = point
        targetNode.name = "Obstacle"
        targetNode.zPosition = 1
        self.addChild(targetNode)
        obstacles.append(targetNode)
    }
    
    func deleteObstacle(obstacle:SKShapeNode) {
        if let index = obstacles.indexOf(obstacle) {
            obstacles.removeAtIndex(index)
            obstacle.removeFromParent()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {

        
        for boid in boids {
            
            for shapeNode in obstacles {
                boid.flee(shapeNode)
            }
            
            var columnIndex = boid.columnIndex
            var rowIndex = boid.rowIndex
            
            let array:Array<Boid> = boidsGrid[columnIndex][rowIndex]
            if let index = array.indexOf(boid) {
                boidsGrid[columnIndex][rowIndex].removeAtIndex(index)
            }
            
            columnIndex = Int(boid.position.x / resolution)
            rowIndex = Int(boid.position.y / resolution)
            boid.columnIndex = columnIndex
            boid.rowIndex = rowIndex
            boidsGrid[columnIndex][rowIndex].append(boid)
            
            boid.update(boidsGrid[columnIndex][rowIndex])
//            boid.update(boids)
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func randomFloatBetween(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
