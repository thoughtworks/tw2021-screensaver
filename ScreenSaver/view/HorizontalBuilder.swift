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

class HorizontalBuilder {
            
    let config: Configuration
    let size: NSSize
    var lines: [[NSPoint]]
    var p0: NSPoint
    var bearing: CGFloat
    var xOffset: CGFloat

    init(yStart: CGFloat, size: NSSize)
    {
        self.config = Configuration.sharedInstance
        self.size = size
        lines = Array(repeating: [], count: (config.laneCount * 2) + 1)
        p0 = NSMakePoint(-config.grid.width, yStart)
        bearing = Util.randomBool() ? -1 : 1
        xOffset = 0
    }
    
    public func build() -> [[NSPoint]] {
        while p0.x < size.width + config.grid.width {
            movePoint()
            setNewDirection()
            if bearing != 0 {
                xOffset = -bearing * (config.grid.width/2 / CGFloat(config.laneCount * 2))
            }
            appendPoints()
            if bearing == 0 {
               xOffset = 0
            }
        }
        return lines
    }

    func movePoint()
    {
        p0.x += config.grid.width / ((bearing != 0) ? 2 : 1)
        p0.y += config.grid.height * bearing
    }
    
    func setNewDirection()
    {
        if (p0.y < config.grid.height) && (bearing < 1) {
            bearing += 1
        } else if (p0.y > size.height - 2 * config.grid.height) && (bearing > -1) {
            bearing += -1
        } else if Util.randomInt(config.changeProbability) != 0 {
            if bearing == 0 {
                bearing = Util.randomBool() ? 1 : -1
            } else {
                bearing = 0
            }
        }
    }
    
    func appendPoints()
    {
        var p = p0
        for i in 0..<lines.count {
            lines[i].append(p)
            p.x += xOffset
            p.y += config.grid.height / CGFloat(config.laneCount * 2)
        }
    }
    
}
