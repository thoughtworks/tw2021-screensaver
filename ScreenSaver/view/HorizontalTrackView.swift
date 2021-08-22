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

class HorizontalTrackView: TrackView {
    
    init(frame: NSRect, startAt point: NSPoint)
    {
        let lines = Builder(yStart: point.y, size: frame.size).build()
        let rects = HorizontalTrackView.makeDrawingRects(line: lines[0])
        super.init(frame: frame, lines: lines, rects: rects)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func makeDrawingRects(line: [NSPoint]) -> [NSRect]
    {
        // The following is what happens when you hack stuff together at night
        // rather than thinking it through properly
        let grid = Configuration.sharedInstance.grid
        var r: [NSRect] = []
        for i in 0..<(line.count - 1) {
            let p0 = line[i]
            let p1 = line[i + 1]
            let p2 = (i < line.count - 2) ? line[i + 2] : nil
            let pn1 = (i > 0) ? line[i - 1] : nil
            if p0.y > p1.y {
                if let pn1 = pn1, pn1.y > p0.y {
                    r.append(NSMakeRect(p0.x, p0.y - grid.height, grid.width / 2, 3 * grid.height))
                } else {
                    r.append(NSMakeRect(p0.x, p0.y - grid.height, grid.width / 2, 2 * grid.height))
                }
            } else if p0.y < p1.y {
                if let p2 = p2, p1.y < p2.y {
                    r.append(NSMakeRect(p0.x, p0.y, grid.width / 2, 3 * grid.height))
                } else {
                    r.append(NSMakeRect(p0.x, p0.y, grid.width / 2, 2 * grid.height))
                }
            } else {
                if let p2 = p2, p1.y < p2.y {
                    r.append(NSMakeRect(p0.x, p0.y, grid.width / 2, 2 * grid.height))
                    r.append(NSMakeRect(p0.x + grid.width / 2, p0.y, grid.width / 2, 2 * grid.height))
                } else if let pn1 = pn1, pn1.y > p0.y {
                    r.append(NSMakeRect(p0.x, p0.y, grid.width / 2, 2 * grid.height))
                    r.append(NSMakeRect(p0.x + grid.width / 2, p0.y, grid.width / 2, 2 * grid.height))
                } else {
                    r.append(NSMakeRect(p0.x, p0.y, grid.width / 2, grid.height))
                    r.append(NSMakeRect(p0.x + grid.width / 2, p0.y, grid.width / 2, grid.height))
                }
            }
        }
        r.removeAll(where: { $0.minX < 0} )
        return r
    }
    
    override func clipRectForTrace(_ trace: Trace) -> NSRect
    {
        if trace.isFilling {
            return NSMakeRect(0, 0, trace.position, bounds.height)
        } else {
            return NSMakeRect(trace.position, 0, bounds.width, bounds.height)
        }
    }
    
    
    class Builder {
            
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
            lines = Array(repeating: [], count: config.laneCount + 1)
            p0 = NSMakePoint(-config.grid.width, yStart)
            bearing = Util.randomBool() ? -1 : 1
            xOffset = 0
        }
        
        public func build() -> [[NSPoint]] {
            while p0.x < size.width + config.grid.width {
                movePoint()
                setNewDirection()
                if bearing != 0 {
                    xOffset = -bearing * (config.grid.width/2 / CGFloat(config.laneCount))
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
                p.y += config.grid.height / CGFloat(config.laneCount)
            }
        }
        
    }
    
    
}
