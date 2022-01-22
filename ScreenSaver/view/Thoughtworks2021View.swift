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
final class Thoughtworks2021View: ScreenSaverView
{
    var faderView: FaderView
    var trackViews: [TrackView]
    var lastFade: CFTimeInterval
    var lastTraceStart: CFTimeInterval
    var colorSequence: ColorSequence
    var isFirstStart: Bool

    override init?(frame: NSRect, isPreview: Bool)
    {
        faderView = FaderView(frame: frame)
        trackViews = []
        lastFade = 0
        lastTraceStart = 0
        colorSequence = ColorSequence()
        isFirstStart = true

        super.init(frame: frame, isPreview: isPreview)

        wantsLayer = true
        animationTimeInterval = 1/60
        if isPreview {
            setBoundsSize(NSMakeSize(bounds.width * 6, bounds.height * 6))
        }

        faderView.frame = bounds
        addSubview(faderView)
        addSceneViews()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }


    // scene views
    
    func addSceneViews() {
        addSubview(makeBackgroundView(), positioned: .below, relativeTo: faderView)
        trackViews = makeTrackViews()
        trackViews.forEach({ addSubview($0, positioned: .below, relativeTo: faderView) })
    }
    
    private func makeBackgroundView() -> BackgroundView
    {
        return BackgroundView(frame: bounds)
    }
    
    private func makeTrackViews() -> [TrackView]
    {
        var views: [TrackView] = []
        let grid = Configuration.sharedInstance.grid
        var p = NSMakePoint(3 * grid.width, -grid.height/2)
        while p.x < bounds.width {
            views.append(TrackView.verticalView(frame: bounds, startAt: p, colorSequence: colorSequence))
            p.x += 5 * grid.width
        }
        p = NSMakePoint(-grid.width, 3/2 * grid.height)
        while p.y < bounds.height - grid.height {
            views.append(TrackView.horizontalView(frame: bounds, startAt: p, colorSequence: colorSequence))
            p.y += 4 * grid.height
        }
        views.shuffle()
        return views
    }

    func removeSceneViews() {
        while subviews.count > 1 {
            subviews.first!.removeFromSuperview()
        }
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
        NSLog("TW2021: %p will start animation in frame \(frame)", self)
        if !isFirstStart {
            NSLog("TW2021: %p is a restart", self)
            removeSceneViews()
            addSceneViews()
        }
        isFirstStart = false
        lastFade = CACurrentMediaTime()
        lastTraceStart = 0
        super.startAnimation()
        NSLog("TW2021: %p did start animation", self)
    }

    override func stopAnimation()
    {
        NSLog("TW2021: %p will stop animation", self)
        super.stopAnimation()
        NSLog("TW2021: %p did stop animation", self)
    }
    
    
    // animation

    override func animateOneFrame()
    {
        let currentTime = CACurrentMediaTime()
        if currentTime - lastFade > Configuration.sharedInstance.resetInterval {
            faderView.performWithFade { self.removeSceneViews(); self.addSceneViews(); }
            lastFade = currentTime
        }
        if currentTime - lastTraceStart > Configuration.sharedInstance.startInterval {
            trackViews.filter({ $0.traceCount < 2 }).randomElement()?.addTrace()
            lastTraceStart = currentTime
        }
        trackViews.forEach({ $0.animate(to: currentTime) })
    }


}
