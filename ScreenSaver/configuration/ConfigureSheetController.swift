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

class ConfigureSheetController : NSObject
{
    static var sharedInstance = ConfigureSheetController()

    var configuration: Configuration!
    
    @IBOutlet var window: NSWindow!
    @IBOutlet var versionField: NSTextField!
    @IBOutlet var sizeSlider: NSSlider!
    @IBOutlet var palettePopup: NSPopUpButton!

    override init()
    {
        super.init()

        configuration = Configuration.sharedInstance

        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        let bundleVersion = (myBundle.infoDictionary!["CFBundleShortVersionString"] ?? "n/a") as! String
        let sourceVersion = (myBundle.infoDictionary!["Source Version"] ?? "n/a") as! String
        versionField.stringValue = String(format: "Version %@ (%@)", bundleVersion, sourceVersion)
    }
    

    @IBAction func openProjectPage(_ sender: AnyObject)
    {
        NSWorkspace.shared.open(URL(string: "https://github.com/erikdoe/hexafliptile")!);
    }

    @IBAction func closeConfigureSheet(_ sender: NSButton)
    {
        if sender.tag == 1 {
            saveConfiguration()
        }
        window.sheetParent!.endSheet(window, returnCode: (sender.tag == 1) ? NSApplication.ModalResponse.OK : NSApplication.ModalResponse.cancel)
    }


    func loadConfiguration()
    {
        sizeSlider.integerValue = 1
        palettePopup.removeAllItems()
    }

    private func saveConfiguration()
    {
    }

    func makeImage(palette: [String]) -> NSImage
    {
        let unit = CGFloat(16)
        let size = NSSize(width: CGFloat(palette.count)*unit, height: unit)

        let image = NSImage(size: size)
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8,
                                        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB,
                                        bytesPerRow: Int(size.width)*4, bitsPerPixel:32)!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: imageRep)

        let path = NSBezierPath(rect: NSMakeRect(0, 0, unit, unit));
        for colorString in palette {
            NSColor(webcolor: colorString as NSString).set()
            path.fill()
            path.transform(using: AffineTransform(translationByX: unit, byY: 0))
        }

        NSGraphicsContext.restoreGraphicsState()

        image.addRepresentation(imageRep)
        return image
    }

}
