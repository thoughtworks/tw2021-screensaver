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
    struct Preset {
        var gridSize: CGFloat
        var speedFactor: CGFloat
        var startInterval: Double
    }
    
    static var presets = [ Preset(gridSize: 125, speedFactor: 1/4,  startInterval: 3),
                           Preset(gridSize: 125, speedFactor: 1,    startInterval: 1),
                           Preset(gridSize: 150, speedFactor: 1/13, startInterval: 9),
                           Preset(gridSize: 100, speedFactor: 1/13, startInterval: 1) ]
    
    static var sharedInstance = ConfigureSheetController()
    
    var configuration: Configuration!
    
    @IBOutlet var window: NSWindow!
    @IBOutlet var versionField: NSTextField!
    @IBOutlet var presetSelector: NSPopUpButton!
    @IBOutlet var scaleSlider: NSSlider!
    @IBOutlet var speedSlider: NSSlider!
    @IBOutlet var delaySlider: NSSlider!


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
    
    @IBAction func applyPreset(_ sender: NSButton)
    {
        if sender.selectedTag() >= 0 {
            let preset = ConfigureSheetController.presets[sender.selectedTag()]
            configuration.gridSize = preset.gridSize
            configuration.speedFactor = preset.speedFactor
            configuration.startInterval = preset.startInterval
        }
        loadConfiguration()
    }
    
    func selectPreset()
    {
        let index = ConfigureSheetController.presets.firstIndex { preset in
            preset.gridSize == configuration.gridSize &&
            preset.speedFactor == configuration.speedFactor &&
            preset.startInterval == configuration.startInterval
        }
        presetSelector.selectItem(withTag: index ?? -1)
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider)
    {
        if sender.allowsTickMarkValuesOnly {
            saveConfiguration()
            selectPreset()
        }
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
        scaleSlider.animator().integerValue = Int(configuration.gridSize)
        speedSlider.animator().integerValue = Int(speedSlider.maxValue - (1.0 / configuration.speedFactor) + 1)
        delaySlider.animator().integerValue = Int(configuration.startInterval)
    }

    private func saveConfiguration()
    {
        configuration.gridSize = CGFloat(scaleSlider.intValue)
        configuration.speedFactor = 1 / (speedSlider.maxValue - speedSlider.doubleValue + 1)
        configuration.startInterval = delaySlider.doubleValue
    }

}
