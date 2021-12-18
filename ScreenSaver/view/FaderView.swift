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

class FaderView : NSView, CALayerDelegate {
        
    override init(frame: NSRect)
    {
        super.init(frame: frame)
        alphaValue = 0
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func performWithFade(_ block: @escaping () -> Void)
    {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Configuration.sharedInstance.fadeTime
            self.animator().alphaValue = 1
        }) {
            block()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = Configuration.sharedInstance.fadeTime
                self.animator().alphaValue = 0
            })
        }
    }
    
    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
    }

    func draw(_ layer: CALayer, in ctx: CGContext)
    {
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSColor.black.set()
        NSBezierPath.fill(bounds)
    }
    
}
