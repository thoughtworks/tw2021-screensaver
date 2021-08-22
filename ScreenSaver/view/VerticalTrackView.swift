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

class VerticalTrackView: TrackView {
    
    init(frame: NSRect, startAt point: NSPoint)
    {
        let lines = Builder(xStart: point.x, size: frame.size).build()
        let rects = VerticalTrackView.makeDrawingRects(line: lines[0])
        super.init(frame: frame, lines: lines, rects: rects)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    static func makeDrawingRects(line: [NSPoint]) -> [NSRect]
    {
        let grid = Configuration.sharedInstance.grid
        var r: [NSRect] = []
        for i in 0..<(line.count - 1) {
            let p0 = line[i]
            let p1 = line[i + 1]
            r.append(NSMakeRect(min(p0.x, p1.x), p0.y, 1.5 * grid.width, grid.height))
        }
        return r
    }
    
    override func clipRectForTrace(_ trace: Trace) -> NSRect
    {
        if trace.isFilling {
            return NSMakeRect(0, 0, bounds.width, trace.position)
        } else {
            return NSMakeRect(0, trace.position, bounds.width, bounds.height)
        }
    }
    
    
    class Builder {
        
        let config: Configuration
        let size: NSSize
        var lines: [[NSPoint]]
        var p0: NSPoint
        var bearing: CGFloat

        init(xStart: CGFloat, size: NSSize) {
            self.config = Configuration.sharedInstance
            self.size = size
            lines = Array(repeating: [], count: config.laneCount + 1)
            p0 = NSMakePoint(xStart, -config.grid.height)
            bearing = Util.randomBool() ? -1 : 1
        }
        
        public func build() -> [[NSPoint]] {
            while p0.y < size.height {
                movePoint()
                setNewDirection()
                appendPoints()
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
            } else if p0.x >= size.width - 1.5 * config.grid.width {
                bearing = -1
            } else if Util.randomInt(config.changeProbability) != 0 {
                bearing *= -1
            }
        }
        
        func appendPoints() {
            var p = p0
            for i in 0..<lines.count {
                lines[i].append(p)
                p.x += config.grid.width / CGFloat(config.laneCount)
            }
        }
        
    }

}

