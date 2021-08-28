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
    @IBOutlet var scaleSlider: NSSlider!
    @IBOutlet var speedSlider: NSSlider!
    @IBOutlet var intervalSlider: NSSlider!
    @IBOutlet var durationSlider: NSSlider!
    @IBOutlet var vDensitySlider: NSSlider!
    @IBOutlet var colorSequencePopup: NSPopUpButton!

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
        NSWorkspace.shared.open(URL(string: "https://github.com/thoughtworks/tw2021-screensaver")!);
    }

    @IBAction func closeConfigureSheet(_ sender: NSButton)
    {
        if sender.tag == 1 {
            saveConfiguration()
        }
        window.sheetParent!.endSheet(window, returnCode: (sender.tag == 1) ? NSApplication.ModalResponse.OK : NSApplication.ModalResponse.cancel)
    }

    @IBAction func applyPreset(_ sender: NSButton)
    {
        switch sender.tag {
        case 0:
            configuration.gridSize = 200
            configuration.traceSpeed = 2500
            configuration.startInterval = 1
            configuration.displayDuration = 4
            configuration.verticalDensity = 2
            configuration.randomizeColorSequence = false
        case 1:
            configuration.gridSize = 175
            configuration.traceSpeed = 3500
            configuration.startInterval = 2
            configuration.displayDuration = 12
            configuration.verticalDensity = 2
            configuration.randomizeColorSequence = false
        case 2:
            configuration.gridSize = 125
            configuration.traceSpeed = 500
            configuration.startInterval = 6
            configuration.displayDuration = 34
            configuration.verticalDensity = 2
            configuration.randomizeColorSequence = false
        case 3:
            configuration.gridSize = 100
            configuration.traceSpeed = 250
            configuration.startInterval = 2
            configuration.displayDuration = 20
            configuration.verticalDensity = 3
            configuration.randomizeColorSequence = false
        default:
            return
        }
        loadConfiguration()
        
    }

    func loadConfiguration()
    {
        scaleSlider.animator().integerValue = Int(configuration.gridSize)
        speedSlider.animator().integerValue = Int(configuration.traceSpeed)
        intervalSlider.animator().integerValue = Int(configuration.startInterval)
        durationSlider.animator().integerValue = Int(configuration.displayDuration)
        vDensitySlider.animator().integerValue = configuration.verticalDensity
        colorSequencePopup.selectItem(withTag: configuration.randomizeColorSequence ? 1 : 0)

        scaleSlider.sendAction()
        speedSlider.sendAction()
        intervalSlider.sendAction()
        durationSlider.sendAction()
        vDensitySlider.sendAction()
    }

    private func saveConfiguration()
    {
        configuration.gridSize = CGFloat(scaleSlider.intValue)
        configuration.traceSpeed = CGFloat(speedSlider.intValue)
        configuration.startInterval = TimeInterval(intervalSlider.intValue)
        configuration.displayDuration = TimeInterval(durationSlider.intValue)
        configuration.verticalDensity = Int(vDensitySlider.intValue)
        configuration.randomizeColorSequence = colorSequencePopup.selectedTag() == 1
    }

}
