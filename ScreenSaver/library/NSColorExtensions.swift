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

import Cocoa
import Metal

extension NSColor
{
    static let twOnyx     = NSColor(webcolor: "#000000")
    static let twFlamingo = NSColor(webcolor: "#f2617a")
    static let twWave     = NSColor(webcolor: "#003d4f")
    static let twTurmeric = NSColor(webcolor: "#cc850a")
    static let twJade     = NSColor(webcolor: "#6b9e78")
    static let twSapphire = NSColor(webcolor: "#47a1ad")
    static let twAmethyst = NSColor(webcolor: "#634f7d")
    static let twMist     = NSColor(webcolor: "#edf1f3")
    static let twTalc     = NSColor(webcolor: "#ffffff")

    convenience init(webcolor: NSString)
    {
        var red:   Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(1, 2))).scanHexDouble(&red)
        var green: Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(3, 2))).scanHexDouble(&green)
        var blue:  Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(5, 2))).scanHexDouble(&blue)
        self.init(red: CGFloat(red/256), green: CGFloat(green/256), blue: CGFloat(blue/256), alpha: 1)
    }

    func lighter(_ amount :CGFloat = 0.15) -> NSColor
    {
        hueColorWithBrightnessAmount(amount)
    }

    func darker(_ amount :CGFloat = 0.15) -> NSColor
    {
        hueColorWithBrightnessAmount(-amount)
    }

    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> NSColor
    {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(hue: hue, saturation: saturation, brightness: brightness*(1+amount), alpha: alpha)
    }
    
    var CGColor: CGColor
    {
        get {
            var components: [CGFloat] = [0, 0, 0, 0]
            let deviceColor = self.usingColorSpace(NSColorSpace.deviceRGB)
            deviceColor?.getComponents(&components)
            return CoreGraphics.CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components)!
        }
    }
    
}

