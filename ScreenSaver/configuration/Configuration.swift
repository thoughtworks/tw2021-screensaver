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

class Configuration
{
    static let sharedInstance = Configuration()

    let laneCount: Int = 5
    let changeProbability = 5 // 1:x chance that direction remains the same

    var grid = NSMakeSize(150, 150 * sqrt(0.75))
    var lineWidth: CGFloat = 5
    var startInterval: TimeInterval = 2
    var displayDuration: TimeInterval = 10
    var verticalDensity: Int = 2
    var randomColors: Bool = false

    private var defaults: UserDefaults
    private var colorIndex: Int = 0

    var traceColors     = [NSColor.twFlamingo, NSColor.twTurmeric, NSColor.twJade,
                           NSColor.twSapphire, NSColor.twAmethyst, NSColor.twMist ]
    var backgroundColor = NSColor.twWave
    var lineColor       = NSColor.twOnyx

    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [
            "GridSize": 150,
            "TraceSpeed": 1500,
            "StartInterval": 2,
            "DisplayDuration": 10,
            "VerticalDensity": 4
            ])
        update()
        grideSize = grideSize // TODO: This does what it should but it's a bit weird
    }
    
    func nextColor() -> NSColor
    {
        let color: NSColor
        if randomColors {
            color = traceColors.randomElement()!
        } else {
            color = traceColors[colorIndex]
            colorIndex = (colorIndex + 1) % traceColors.count
        }
        return color
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
    
    var grideSize: CGFloat
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
            lineWidth = newValue / 50 + 2
        }
    }
    
    private func update()
    {
        defaults.synchronize()
    }

    
}

