//
//  Extensions.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 03/06/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

//
infix operator ~
func ~<T> (left: CountableClosedRange<T>, right: CountableClosedRange<T>) -> Bool {
    for i in right {
        if left.contains(i) {
            return true
        }
    }
    
    return false
}

//
extension UIView {
    
    func randomize(interval: TimeInterval, withVariance variance: Double) -> Double{
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
    func startWiggle(){
        
        // consts
        let wiggleBounceY = 2.0
        let wiggleBounceDuration = 0.12
        let wiggleBounceDurationVariance = 0.025
        
        let wiggleRotateAngle = 0.03
        let wiggleRotateDuration = 0.10
        let wiggleRotateDurationVariance = 0.025
        
        //Create rotation animation
        let rotationAnim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnim.values = [-wiggleRotateAngle, wiggleRotateAngle]
        rotationAnim.autoreverses = true
        rotationAnim.duration = randomize(interval: wiggleRotateDuration, withVariance: wiggleRotateDurationVariance)
        rotationAnim.repeatCount = HUGE
        
        //Create bounce animation
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounceAnimation.values = [wiggleBounceY, 0]
        bounceAnimation.autoreverses = true
        bounceAnimation.duration = randomize(interval: wiggleBounceDuration, withVariance: wiggleBounceDurationVariance)
        bounceAnimation.repeatCount = HUGE
        
        //Apply animations to view
        UIView.animate(withDuration: 0) {
            self.layer.add(rotationAnim, forKey: "rotation")
            self.layer.add(bounceAnimation, forKey: "bounce")
            self.transform = .identity
        }
    }
    
    func stopWiggle(){
        self.layer.removeAllAnimations()
    }
}

//
public enum MoveDirection: Int {
    case up,
    down,
    left,
    right
    
    public var isX: Bool {
        return self == .left || self == .right
    }
    
    public var isY: Bool {
        return !isX
    }
}

extension UIPanGestureRecognizer {
    var direction: MoveDirection {
        let velocity = self.velocity(in: view)
        let vertical = fabs(velocity.y) > fabs(velocity.x)
        
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y):
            return y < 0 ? .up : .down
            
        case (false, let x, _):
            return x > 0 ? .right : .left
        }
    }
}

//
func getClassName(of any: Any) -> String? {
    return "\(any)".components(separatedBy: ".").last
}
