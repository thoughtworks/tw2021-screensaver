/*
 *  Copyright (c) 2021 Erik Doernenburg and contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

import Cocoa

class TraceLayer : CAShapeLayer, CAAnimationDelegate {
    
    enum State: Int {
        case
            ready,
            filling,
            showing,
            fading,
            done
    }
    
    public let laneIndex: Int
    public var state: State
    public var timestamp: Date
    
    init(laneIndex: Int, path: NSBezierPath, color: NSColor)
    {
        self.laneIndex = laneIndex
        state = .ready
        timestamp = Date.distantPast
        
        super.init()

        self.path = path.cgPath
        self.strokeColor = color.cgColor
        self.lineWidth = path.lineWidth
        self.fillColor = nil
    }
    
    override init(layer: Any)
    {
        let other = layer as! TraceLayer
        self.laneIndex = other.laneIndex
        self.state = other.state
        self.timestamp = other.timestamp
        super.init(layer: other)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func animate(to now: Date)
    {
        if state == .ready {
            startFilling()
            state = .filling
            timestamp = now
        }
        else if state == .showing && now.timeIntervalSince(timestamp) > Configuration.sharedInstance.displayDuration {
            startFading()
            state = .fading
            timestamp = now
        }
        else if state == .done {
            removeFromSuperlayer()
        }
    }
    
    private func startFilling()
    {
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.fromValue = 0
        let bb = path!.boundingBox
        animation.duration = CFTimeInterval(max(bb.width, bb.height) / Configuration.sharedInstance.traceSpeed)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.delegate = self
        strokeEnd = 1
        add(animation, forKey: #keyPath(CAShapeLayer.strokeEnd))
    }

    private func startFading()
    {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.delegate = self
        opacity = 0
        add(animation, forKey: #keyPath(CALayer.opacity))
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        state = (state == .filling) ? .showing : .done
        timestamp += anim.duration // a good enough approximation
    }

}
