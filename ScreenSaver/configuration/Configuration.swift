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

    let fadeTime: Double = 3
    let resetInterval: Double = 90
    
    let laneCount: Int = 5
    let hChangeProbability = 8 // 1:x chance that direction remains the same
    let vChangeProbability = 4 // 1:x chance that direction remains the same
    let baseSpeed: CGFloat = 2500

    let traceColors = [NSColor.twFlamingo, NSColor.twTurmeric, NSColor.twJade,
                       NSColor.twSapphire, NSColor.twAmethyst, NSColor.twMist]
    let backgroundColor = NSColor.twWave
    let lineColor = NSColor.twOnyx

    var grid = NSMakeSize(150, 150 * sqrt(0.75))
    var lineWidth: CGFloat = 5

    private var defaults: UserDefaults


    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [
            "GridSize": 125,
            "SpeedFactor": 0.25,
            "StartInterval": 3.0,
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

    var speedFactor: CGFloat
    {
        get
        {
            defaults.double(forKey: "SpeedFactor")
        }
        set
        {
            defaults.setValue(newValue, forKey: "SpeedFactor")
            update()
        }
    }
    
    var startInterval: Double
    {
        get
        {
            defaults.double(forKey: "StartInterval")
        }
        set
        {
            defaults.setValue(newValue, forKey: "StartInterval")
            update()
        }
    }
    
    var traceSpeed: CGFloat
    {
        baseSpeed * speedFactor
    }
    
    
    var displayDuration: Double
    {
        (Double(traceColors.count) - 0.5) * startInterval
    }
 
    private func update()
    {
        defaults.synchronize()
    }


}

