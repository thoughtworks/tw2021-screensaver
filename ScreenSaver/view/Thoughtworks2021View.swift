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

import ScreenSaver

@objc(Thoughtworks2021View)
class Thoughtworks2021View: ScreenSaverView, CALayerDelegate
{
    var trackViews: [TrackView]
    var lastTraceStart: Date

    override init?(frame: NSRect, isPreview: Bool)
    {
        trackViews = []
        lastTraceStart = Date.distantPast
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
        animationTimeInterval = 1/10
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }


    // deferred initialisations

    override func viewDidMoveToSuperview()
    {
        super.viewDidMoveToSuperview()
        resetSubviews()
    }
    
    func resetSubviews()
    {
        subviews.first?.removeFromSuperview()
        trackViews.forEach({ $0.removeFromSuperview() })
        trackViews = []

        addSubview(BackgroundView(frame: frame))
        trackViews = makeTrackViews()
        trackViews.forEach({ addSubview($0) })
    }
    
    func makeTrackViews() -> [TrackView]
    {
        var views: [TrackView] = []
        let grid = Configuration.sharedInstance.grid
        var p = NSMakePoint(grid.width * 1.5, 0)
        while p.x < bounds.width {
            let builder = VerticalBuilder(xStart: p.x, size: bounds.size)
            views.append(TrackView(frame: bounds, lines: builder.build()))
            p.x += grid.width * CGFloat(Configuration.sharedInstance.verticalDensity)
        }
        p = NSMakePoint(0, 0)
        while p.y < bounds.height - grid.height {
            let builder = HorizontalBuilder(yStart: p.y, size: bounds.size)
            views.append(TrackView(frame: bounds, lines: builder.build()))
            p.y += grid.height * 2
        }
        views.shuffle()
        return views
    }
    

    // configuration

    override var hasConfigureSheet: Bool
    {
        return true
    }

    override var configureSheet: NSWindow?
    {
        let controller = ConfigureSheetController.sharedInstance
        controller.loadConfiguration()
        return controller.window
    }


    // start and stop

    override func startAnimation()
    {
        super.startAnimation()
    }

    override func stopAnimation()
    {
        super.stopAnimation()
        resetSubviews()
    }
    
    
    // animation

    override func animateOneFrame()
    {
        let now = NSDate.now
        if now.timeIntervalSince(lastTraceStart) > Configuration.sharedInstance.startInterval {
            trackViews.filter({ $0.traceCount < 2 }).randomElement()?.addTrace()
            lastTraceStart = now
        }
        trackViews.forEach({ $0.animate(to: now) })
    }
    
}
