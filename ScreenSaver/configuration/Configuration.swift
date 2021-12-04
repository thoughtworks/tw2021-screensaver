/*
 *  Copyright (c) 2016-2021 Erik Doernenburg and contributors
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

class Configuration {
    static let sharedInstance = Configuration()

    let laneCount: Int = 5
    let hChangeProbability = 8 // 1:x chance that direction remains the same
    let vChangeProbability = 4 // 1:x chance that direction remains the same

    var grid = NSMakeSize(150, 150 * sqrt(0.75))
    var lineWidth: CGFloat = 5

    var traceColors = [NSColor.twFlamingo, NSColor.twTurmeric, NSColor.twJade,
                       NSColor.twSapphire, NSColor.twAmethyst, NSColor.twMist]
    var backgroundColor = NSColor.twWave
    var lineColor = NSColor.twOnyx

    private var defaults: UserDefaults


    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [
            "GridSize": 150,
            "TraceSpeed": 1500,
            "StartInterval": 2,
            "DisplayDuration": 10,
            "VerticalDensity": 2,
            "RandomColors": false
        ])
        update()
        gridSize = gridSize // TODO: This does what it should but it's a bit weird
    }

    var gridSize: CGFloat
    {
        get
        {
            CGFloat(defaults.integer(forKey: "GridSize"))
        }
        set
        {
            defaults.setValue(newValue, forKey: "GridSize")
            grid.width = newValue
            grid.height = newValue * sqrt(0.75)
            lineWidth = newValue / 25
        }
    }

    var traceSpeed: CGFloat
    {
        get
        {
            CGFloat(defaults.integer(forKey: "TraceSpeed"))
        }
        set
        {
            defaults.setValue(newValue, forKey: "TraceSpeed")
            update()
        }
    }

    var startInterval: TimeInterval
    {
        get
        {
            TimeInterval(defaults.float(forKey: "StartInterval"))
        }
        set
        {
            defaults.set(newValue, forKey: "StartInterval")
            update()
        }
    }

    var displayDuration: TimeInterval
    {
        get
        {
            TimeInterval(defaults.float(forKey: "DisplayDuration"))
        }
        set
        {
            defaults.set(newValue, forKey: "DisplayDuration")
            update()
        }
    }

    var verticalDensity: Int
    {
        get
        {
            defaults.integer(forKey: "VerticalDensity")
        }
        set
        {
            defaults.set(newValue, forKey: "VerticalDensity")
            update()
        }
    }

    var randomizeColorSequence: Bool
    {
        get
        {
            defaults.bool(forKey: "RandomColors")
        }
        set
        {
            defaults.set(newValue, forKey: "RandomColors")
        }
    }

    private func update()
    {
        defaults.synchronize()
    }


}

