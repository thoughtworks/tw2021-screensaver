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

    let grid = NSMakeSize(200, 200 * sqrt(0.75))
    let laneCount: Int = 5
    let lineWidth: CGFloat = 6
    let changeProbability = 5 // 1:x chance that direction does not change
    
    private var defaults: UserDefaults

    var traceColors     = [NSColor.twFlamingo, NSColor.twTurmeric, NSColor.twJade,
                           NSColor.twSapphire, NSColor.twAmethyst, NSColor.twMist ]
    var backgroundColor = NSColor.twWave
    var lineColor       = NSColor.twOnyx

    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
//        defaults.register(defaults: [
//            "traceColors": [NSColor.twFlamingo, NSColor.twTurmeric, NSColor.twJade, NSColor.twSapphire, NSColor.twAmethyst, NSColor.twMist ]
//            ])
//        update()
//        traceColors = palette.map { NSColor(webcolor: $0 as NSString) }
    }

//    var palette: [String]
//    {
//        set
//        {
//            defaults.set(newValue, forKey: "traceColors")
//            traceColors = newValue.map { NSColor(webcolor: $0 as NSString) }
//            update()
//        }
//        get
//        {
//            defaults.array(forKey: "traceColors") as! [String]
//        }
//    }
//
//    private func update()
//    {
//        defaults.synchronize()
//    }

    
}

