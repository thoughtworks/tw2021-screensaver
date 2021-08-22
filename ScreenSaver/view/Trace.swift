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

public class Trace {
    
    public let index: Int
    public let color: NSColor
    public let speed: CGFloat
    public let length: CGFloat
    
    public var timestamp: TimeInterval
    public var position: CGFloat
    public var isFilling: Bool
    
    init(index: Int, color: NSColor, speed: CGFloat, length: CGFloat) {
        self.index = index
        self.color = color
        self.speed = speed
        self.length = length
        timestamp = 0
        position = 0
        isFilling = true
    }
    
    public func startFill(at t: TimeInterval) -> Trace {
        self.timestamp = t
        position = 0
        isFilling = true
        return self
    }
    
    public func startClear(at t: TimeInterval) {
        self.timestamp = t
        position = 0
        isFilling = false
    }
    
    public func move(to now: TimeInterval) {
        let delta = speed * CGFloat(now - timestamp)
        position = min(position + delta, length)
        timestamp = now
    }
    
    public var isAtEnd: Bool
    {
        get { return position >= length }
    }
    
}
