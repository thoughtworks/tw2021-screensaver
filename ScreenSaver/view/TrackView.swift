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

    var colors: ColorSequence
    var trackPath: NSBezierPath
    var laneMarkerPaths: [NSBezierPath]
    var tracePaths: [NSBezierPath]

    
    public class func verticalView(frame: NSRect, startAt p: NSPoint, colorSequence: ColorSequence) -> TrackView
    {
        let builder = VerticalBuilder(start: p, size: frame.size)
        return TrackView(frame: frame, colors: colorSequence, lines: builder.build())
    }
    
    public class func horizontalView(frame: NSRect, startAt p: NSPoint, colorSequence: ColorSequence) -> TrackView
    {
        let builder = HorizontalBuilder(start: p, size: frame.size)
        return TrackView(frame: frame, colors: colorSequence, lines: builder.build())
    }
    
    
    init(frame: NSRect, colors: ColorSequence, lines: [[NSPoint]])
    {
        self.colors = colors
        trackPath = TrackView.makeTrackPath(lines: lines)
        laneMarkerPaths = TrackView.makeLaneMarkerPaths(lines: lines)
        tracePaths = TrackView.makeTracePaths(lines: lines)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    static func makeTrackPath(lines: [[NSPoint]]) -> NSBezierPath
    {
        let path = makePath(line: lines[0])
        for point in lines[lines.count - 1].reversed() {
            path.line(to: point)
        }
        path.close()
        return path
    }

    static func makeLaneMarkerPaths(lines: [[NSPoint]]) -> [NSBezierPath]
    {
        var pathList: [NSBezierPath] = []
        for i in stride(from: 0, to: lines.count, by: 2) {
            let path = makePath(line: lines[i])
            path.lineWidth = Configuration.sharedInstance.lineWidth
            path.lineJoinStyle = .bevel
            pathList.append(path)
        }
        return pathList
    }

    static func makeTracePaths(lines: [[NSPoint]]) -> [NSBezierPath]
    {
        var pathList: [NSBezierPath] = []
        for i in stride(from: 1, to: lines.count - 1, by: 2) {
            let path = makePath(line: lines[i])
            let config = Configuration.sharedInstance
            path.lineWidth = config.grid.height / CGFloat(config.laneCount) - config.lineWidth
            pathList.append(path)
        }
        return pathList
    }

    static func makePath(line: [NSPoint]) -> NSBezierPath
    {
        let path = NSBezierPath()
        for point in line {
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.line(to: point)
            }
        }
        return path
    }


    public var traceLayers: [TraceLayer]
    {
        guard let layers = layer?.sublayers else {
            return []
        }
        return layers.filter({ $0 is TraceLayer }) as! [TraceLayer]
    }

    public var traceCount: Int
    {
        guard let layers = layer?.sublayers else {
            return 0
        }
        return layers.count
    }

    public func addTrace()
    {
        let traceLayers = traceLayers
        let newLayer: TraceLayer
        if traceLayers.count == 0 {
            newLayer = makeFirstTraceLayer()
        } else if traceLayers.count == 1 {
            newLayer = makeSecondTraceLayer(first: traceLayers[0])
        } else {
            return
        }
        layer?.addSublayer(newLayer)
    }

    func makeFirstTraceLayer() -> TraceLayer
    {
        let idx = Util.randomInt(tracePaths.count)
        let color = colors.next()!
        return TraceLayer(laneIndex: idx, path: tracePaths[idx], color: color, reverse: Util.randomBool())
    }

    func makeSecondTraceLayer(first: TraceLayer) -> TraceLayer
    {
        var idx = first.laneIndex
        idx = idx + ((idx >= 2) ? -1 : +1)
        var color: NSColor
        repeat {
            color = colors.next()!
        } while color == NSColor(cgColor: first.strokeColor!)
        return TraceLayer(laneIndex: idx, path: tracePaths[idx], color: color, reverse: first.reverse)
    }


    public func animate(to time: CFTimeInterval)
    {
        traceLayers.forEach({ $0.animate(to: time) })
    }


    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
    }

    func draw(_ layer: CALayer, in ctx: CGContext)
    {
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        Configuration.sharedInstance.backgroundColor.set()
        trackPath.fill()
        Configuration.sharedInstance.lineColor.set()
        laneMarkerPaths.forEach({ $0.stroke() })
    }

}


