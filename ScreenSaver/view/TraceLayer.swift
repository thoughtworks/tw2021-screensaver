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

class TraceLayer : CAShapeLayer {
    
    enum State: Int {
        case
            ready,
            filling,
            showing,
            fading,
            done
    }
    
    public let laneIndex: Int

    private var state: State
    private var lastStateChange: CFTimeInterval
    
    init(laneIndex: Int, path: NSBezierPath, color: NSColor)
    {
        self.laneIndex = laneIndex
        state = .ready
        lastStateChange = 0
        
        super.init()

        self.path = path.cgPath
        self.lineWidth = path.lineWidth
        self.strokeColor = color.cgColor
        self.fillColor = nil
    }
    
    override init(layer: Any)
    {
        let other = layer as! TraceLayer
        self.laneIndex = other.laneIndex
        self.state = other.state
        self.lastStateChange = other.lastStateChange
        super.init(layer: other)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setState(_ newState: State, at time: CFTimeInterval)
    {
        state = newState
        lastStateChange = time
    }

    public func animate(to time: CFTimeInterval)
    {
        switch state {
        case .ready:
            strokeEnd = 0
            setState(.filling, at: time)
        case .filling:
            let distance = CGFloat(time - lastStateChange) * Configuration.sharedInstance.traceSpeed
            let bb = path!.boundingBox
            strokeEnd = min(1, distance / max(bb.width, bb.height))
            if strokeEnd == 1 {
                setState(.showing, at: time)
            }
        case .showing:
            if time - lastStateChange > Configuration.sharedInstance.displayDuration {
                opacity = 1
                setState(.fading, at: time)
            }
        case .fading:
            opacity = max(0, Float(1 - (time - lastStateChange)))
            if opacity == 0 {
                setState(.done, at: time)
            }
        case .done:
            removeFromSuperlayer()
        }
    }

    override func action(forKey event: String) -> CAAction?
    {
        // TODO: confirm that this really has less overhead than using a CATransaction
        if event == "strokeEnd" || event == "opacity" {
            return nil
        }
        return super.action(forKey: event)
    }


}
