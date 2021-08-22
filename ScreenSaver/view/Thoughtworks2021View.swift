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
    var lastTraceStart: TimeInterval

    override init?(frame: NSRect, isPreview: Bool)
    {
        trackViews = []
        lastTraceStart = 0
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
        animationTimeInterval = 1.0/60.0
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }


    // deferred initialisations

    override func viewDidMoveToSuperview()
    {
        super.viewDidMoveToSuperview()
        addSubview(BackgroundView(frame: frame))
        makeTrackViews()
    }
    
    func makeTrackViews()
    {
        let grid = Configuration.sharedInstance.grid
        trackViews.forEach({ $0.removeFromSuperview() })
        trackViews = []
        var p = NSMakePoint(grid.width * 1.5, 0)
        while p.x < bounds.width {
            trackViews.append(VerticalTrackView(frame: bounds, startAt: p))
            p.x += grid.width * 3
        }
        p = NSMakePoint(0, 0)
        while p.y < bounds.height - grid.height {
            trackViews.append(HorizontalTrackView(frame: bounds, startAt: p))
            p.y += grid.height * 2
        }
        trackViews.shuffle()
//        trackViews = [trackViews.first!]
        trackViews.forEach({ addSubview($0) })
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
        makeTrackViews()
    }
    
    
    // animation

    override func animateOneFrame()
    {
        let now = NSDate.now.timeIntervalSinceReferenceDate
        if (now - lastTraceStart) > 2 {
            trackViews.randomElement()?.startTrace(t: now)
            lastTraceStart = now
        }
        trackViews.forEach({ $0.animate(to: now) })
    }
    
}
