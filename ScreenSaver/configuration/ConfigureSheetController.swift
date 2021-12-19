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
  
    @IBOutlet var window: NSWindow!
    @IBOutlet var versionField: NSTextField!
    @IBOutlet var presetSelector: NSPopUpButton!
    @IBOutlet var scaleSlider: NSSlider!
    @IBOutlet var speedSlider: NSSlider!
    @IBOutlet var delaySlider: NSSlider!

    var configuration: Configuration
    var ignoreSliderChanges: Bool

    override init()
    {
        configuration = Configuration.sharedInstance
        ignoreSliderChanges = false

        super.init()

        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        let bundleVersion = (myBundle.infoDictionary!["CFBundleShortVersionString"] ?? "n/a") as! String
        let sourceVersion = (myBundle.infoDictionary!["Source Version"] ?? "n/a") as! String
        versionField.stringValue = String(format: "Version %@ (%@)", bundleVersion, sourceVersion)
    }
    
    func loadConfiguration()
    {
        scaleSlider.integerValue = Int(configuration.gridSize)
        speedSlider.integerValue = sliderValueForSpeedFactor(configuration.speedFactor)
        delaySlider.integerValue = Int(configuration.startInterval)
        selectPresetFromSliderValues()
    }

    private func saveConfiguration()
    {
        configuration.gridSize = CGFloat(scaleSlider.integerValue)
        configuration.speedFactor = speedFactorForSliderValue(speedSlider.integerValue)
        configuration.startInterval = Double(delaySlider.integerValue)
        configuration.sync()
    }

    private func selectPresetFromSliderValues()
    {
        let index = ConfigureSheetController.presets.firstIndex { preset in
            preset.gridSize == CGFloat(scaleSlider.integerValue) &&
            preset.speedFactor == speedFactorForSliderValue(speedSlider.integerValue) &&
            preset.startInterval == Double(delaySlider.integerValue)
        }
        presetSelector.selectItem(withTag: index ?? -1)
    }
    
    private func applyPresetToSliders()
    {
        let tag = presetSelector.selectedTag()
        if tag >= 0 && tag < ConfigureSheetController.presets.count {
            let preset = ConfigureSheetController.presets[tag]
            scaleSlider.animator().integerValue = Int(preset.gridSize)
            speedSlider.animator().integerValue = sliderValueForSpeedFactor(preset.speedFactor)
            delaySlider.animator().integerValue = Int(preset.startInterval)
        }
    }
    
    private func speedFactorForSliderValue(_ value: Int) -> CGFloat {
        1 / (speedSlider.maxValue - Double(value) + 1)
    }
    
    private func sliderValueForSpeedFactor(_ factor: CGFloat) -> Int {
        Int(speedSlider.maxValue - (1.0 / factor) + 1)
    }
    
    
    @IBAction func openProjectPage(_ sender: AnyObject)
    {
        NSWorkspace.shared.open(URL(string: "https://github.com/thoughtworks/tw2021-screensaver")!);
    }

    @IBAction func applyPreset(_ sender: NSButton)
    {
        ignoreSliderChanges = true
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in self.ignoreSliderChanges = false }
        applyPresetToSliders()
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider)
    {
        if ignoreSliderChanges == false {
            selectPresetFromSliderValues()
        }
    }
   
    @IBAction func closeConfigureSheet(_ sender: NSButton)
    {
        if sender.tag == 1 {
            saveConfiguration()
        }
        window.sheetParent!.endSheet(window, returnCode: (sender.tag == 1) ? NSApplication.ModalResponse.OK : NSApplication.ModalResponse.cancel)
    }


}
