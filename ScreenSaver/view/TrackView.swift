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

class TrackView : NSView, CALayerDelegate {
    
    var lanes: [NSBezierPath]
    var rects: [NSRect]
    var traces: [Trace]

    init(frame: NSRect, lines: [[NSPoint]], rects: [NSRect])
    {
        self.lanes = TrackView.makeLanes(lines: lines)
        self.rects = rects
        self.traces = []
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    static func makeLanes(lines: [[NSPoint]]) -> [NSBezierPath]
    {
        var lanes: [NSBezierPath] = []
        for i in 0..<(lines.count - 1) {
            let path = NSBezierPath()
            for point in lines[i] {
                if path.isEmpty {
                    path.move(to: point)
                } else {
                    path.line(to: point)
                }
            }
            for point in lines[i + 1].reversed() {
                path.line(to: point)
            }
            path.close()
            path.lineWidth = Configuration.sharedInstance.lineWidth
            path.lineJoinStyle = .bevel
            lanes.append(path)
        }
        return lanes
    }
  
    
    public func startTrace(t now: TimeInterval)
    {
        if traces.count == 0 {
            traces.append(makeFirstTrace().startFill(at: now))
        } else if traces.count == 1 {
            traces.append(makeSecondTrace(first: traces[0]).startFill(at: now))
        }
    }
    
    func makeFirstTrace() -> Trace
    {
        let idx = Util.randomInt(lanes.count)
        let color = Configuration.sharedInstance.traceColors.randomElement()!
        return makeTrace(index: idx, color: color)
    }
    
    func makeSecondTrace(first: Trace) -> Trace
    {
        let idx = first.index + ((first.index > 1) ? -1 : +1)
        var color: NSColor
        repeat {
            color = Configuration.sharedInstance.traceColors.randomElement()!
        } while color == first.color
        return makeTrace(index: idx, color: color)
    }
    
    func makeTrace(index: Int, color: NSColor) -> Trace
    {
        let l = (self is HorizontalTrackView) ? bounds.width : bounds.height
        return Trace(index: index, color: color, speed: bounds.width * 1.5, length: l)
    }
    
    
    public func animate(to now: TimeInterval)
    {
        for t in traces {
            if t.isAtEnd {
                if t.timestamp < now - 10 {
                    t.startClear(at: now)
                }
            } else {
                let prevPosition = t.position
                t.move(to: now)
                let grid = Configuration.sharedInstance.grid
                let u = (self is HorizontalTrackView) ? grid.width/2 : grid.height
                let range = Int(floor(prevPosition / u)) ..< Int(ceil(t.position / u))
                rects[range].forEach({ setNeedsDisplay($0) })
            }
        }
        traces.removeAll(where: { ($0.isAtEnd && !$0.isFilling) })
    }
    
    
    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext)
    {        
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)

        Configuration.sharedInstance.backgroundColor.set()
        lanes.forEach(({ $0.fill() }))

        for t in traces {
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(rect: clipRectForTrace(t)).addClip()
            t.color.set()
            lanes[t.index].fill()
            NSGraphicsContext.restoreGraphicsState()
        }

        Configuration.sharedInstance.lineColor.set()
        lanes.forEach({ $0.stroke() })

//        NSColor.red.set()
//        rects.forEach({ NSBezierPath.stroke($0) })
    }

    func clipRectForTrace(_ trace: Trace) -> NSRect
    {
        return bounds
    }
    
}


