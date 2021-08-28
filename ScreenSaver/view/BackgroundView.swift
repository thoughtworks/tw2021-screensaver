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

class BackgroundView : NSView, CALayerDelegate {

    var triangles: [NSBezierPath] = []

    override init(frame: NSRect)
    {
        triangles = BackgroundView.makeTriangleTiling(frame.size)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }


    override var isOpaque: Bool
    {
        get { true }
    }


    static func makeTriangleTiling(_ size: NSSize) -> [NSBezierPath]
    {
        let grid = Configuration.sharedInstance.grid
        var triangles: [NSBezierPath] = []
        var p = NSMakePoint(-grid.width/2, -grid.height/2)
        var xOffset: CGFloat = 0
        while p.y < size.height + 1 {
            var up = false
            while p.x < size.width {
                triangles.append(makeTriangle(p, up))
                p.x += grid.width/2
                up = !up
            }
            xOffset = (xOffset < 0) ? 0 : -grid.width/2
            p.x = -grid.width/2 + xOffset
            p.y += grid.height
        }
        return triangles
    }

    static func makeTriangle(_ p: NSPoint, _ up: Bool) -> NSBezierPath
    {
        let grid = Configuration.sharedInstance.grid
        let laneCount = Configuration.sharedInstance.laneCount

        let lines = NSBezierPath()
        lines.lineWidth = Configuration.sharedInstance.lineWidth
        lines.lineCapStyle = .round

        var p0 = NSMakePoint(0, 2/3 * grid.height)
        var p1 = p0
        for _ in 0...laneCount {
            lines.move(to: p0)
            lines.line(to: p1)
            let lc = CGFloat(laneCount)
            p0.x -= 1/(2*lc) * grid.width;  p0.y -= 1/lc * grid.height
            p1.x += 1/(2*lc) * grid.width;  p1.y -= 1/lc * grid.height
        }
        let rotation = CGFloat(Util.randomInt(range: -1...1) * 120)
        lines.transform(using: AffineTransform(rotationByDegrees: rotation))
        if !up {
            lines.transform(using: AffineTransform(rotationByDegrees: 180))
            lines.transform(using: AffineTransform(translationByX: 0, byY: grid.height/3))
        }
        lines.transform(using: AffineTransform(translationByX: grid.width/2, byY: grid.height/3))
        lines.transform(using: AffineTransform(translationByX: p.x, byY: p.y))

        return lines
    }


    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
    }

    func draw(_ layer: CALayer, in ctx: CGContext)
    {
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        Configuration.sharedInstance.backgroundColor.darker(0.0).set()
        NSBezierPath.fill(bounds)
        Configuration.sharedInstance.lineColor.set()
        triangles.forEach({ $0.stroke() })
    }

}

