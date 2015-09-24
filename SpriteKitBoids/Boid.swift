//
//  Boid.swift
//  SpriteKitBoids
//
//  Created by matt on 23/09/2015.
//  Copyright © 2015 Matthew Green Associates. All rights reserved.
//

import SpriteKit

class Boid: SKSpriteNode {
    
    var columnIndex:Int!
    var rowIndex:Int!
    
    var velocity:CGVector!
    var location:CGVector!
    let range:CGFloat = 20
    let maxVelocity:CGFloat = 3
    var radius:CGFloat!
    
    var separation:CGVector!
    var alignment:CGVector!
    var cohesion:CGVector!
    
    init(texture:SKTexture, velocity:CGVector, location:CGVector) {
        self.velocity = velocity
        self.location = location
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.position = CGPointMake(location.dx, location.dy)
        self.radius = size.width / 2
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func update(boids:[Boid]) {
        wrapAround()
        flock(boids)
        velocity.limit(maxVelocity)
        location = location + velocity
        self.position = CGPointMake(location.dx, location.dy)
    }
    
    func wrapAround() {
        let scene = parent as! SKScene
        
        if location.dx > scene.size.width + radius {
            location.dx = -(2 * radius)
        }
        else if location.dx < -(2 * radius) {
            location.dx = scene.size.width + radius
        }
        
        if location.dy > scene.size.height + radius {
            location.dy = -(2 * radius)
        }
        else if location.dy < -(2 * radius) {
            location.dy = scene.size.height + radius
        }

    }
    
    func flock(boids:[Boid]) {
        
        var separation:CGVector = CGVector(dx: 0, dy: 0)
        var alignment:CGVector = CGVector(dx: 0, dy: 0)
        var cohesion:CGVector = CGVector(point: CGPointZero)
        
        var numBoidsInVicinity:CGFloat = 0
        
        for i in 0 ..< boids.count {
            let boid = boids[i]
            if boid == self { continue }
            
            let distance = location.distanceTo(boid.location)
            if distance < range {
                
                numBoidsInVicinity++
                
                // Separation
                var displacement = location - boid.location
                displacement.normalize()
                displacement /= distance
                separation += displacement
                
                // Alignment
                alignment += boid.velocity
                
                // Cohesion
                cohesion += boid.location
            }
        }
        
        if numBoidsInVicinity > 0 {
            
            // Separation
            separation /= numBoidsInVicinity
            separation *= 8
            
            // Alignment
            alignment /= numBoidsInVicinity
            alignment -= velocity
            alignment /= 10
            
            // Cohesion
            cohesion /= numBoidsInVicinity
            cohesion -= location
            cohesion /= 50
        }

        velocity = velocity + separation
        velocity = velocity + alignment
        velocity = velocity + cohesion
        
        self.rotateToVelocity(velocity, rate: 1/60.0)
    }
    
    func seek(target:SKNode) {
        var targetVector = CGVector(point: target.position)
        targetVector -= location
        targetVector /= 2000
        velocity = velocity + targetVector
    }
    
    func flee(target:SKNode) {
        var targetVector = CGVector(point: target.position)
        targetVector -= location
        targetVector /= 2000
        velocity = velocity + targetVector
    }
}
