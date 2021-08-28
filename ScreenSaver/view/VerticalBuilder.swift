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

class VerticalBuilder {
        
    let config: Configuration
    let size: NSSize
    var lines: [[NSPoint]]
    var p0: NSPoint
    var bearing: CGFloat

    init(start: NSPoint, size: NSSize) {
        config = Configuration.sharedInstance
        self.size = size
        lines = Array(repeating: [], count: (config.laneCount * 2) + 1)
        p0 = start
        bearing = Util.randomBool() ? -1 : 1
    }
    
    public func build() -> [[NSPoint]] {
        while p0.y < size.height + config.grid.height {
            appendPoints()
            movePoint()
            setNewDirection()
        }
        return lines
    }

    func movePoint() {
        p0.x += bearing * config.grid.width / 2
        p0.y += config.grid.height
    }
    
    func setNewDirection() {
        if p0.x < config.grid.width/2 {
            bearing = 1
        } else if p0.x >= size.width - 2/3 * config.grid.width {
            bearing = -1
        } else if Util.randomInt(config.vChangeProbability) != 0 {
            bearing *= -1
        }
    }
    
    func appendPoints() {
        var p = p0
        for i in 0..<lines.count {
            lines[i].append(p)
            p.x += config.grid.width / CGFloat(config.laneCount * 2)
        }
    }
        
}

