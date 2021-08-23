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


    func loadConfiguration()
    {
        scaleSlider.integerValue = Int(configuration.grideSize)
        speedSlider.integerValue = Int(configuration.traceSpeed)
        intervalSlider.integerValue = Int(configuration.startInterval)
        durationSlider.integerValue = Int(configuration.displayDuration)
        vDensitySlider.integerValue = 4 - configuration.verticalDensity + 2
        colorSequencePopup.selectItem(withTag: configuration.randomColors ? 1 : 0)

        scaleSlider.sendAction()
        speedSlider.sendAction()
        intervalSlider.sendAction()
        durationSlider.sendAction()
        vDensitySlider.sendAction()
    }

    private func saveConfiguration()
    {
        configuration.grideSize = CGFloat(scaleSlider.intValue)
        configuration.traceSpeed = CGFloat(speedSlider.intValue)
        configuration.startInterval = TimeInterval(intervalSlider.intValue)
        configuration.displayDuration = TimeInterval(durationSlider.intValue)
        configuration.verticalDensity = 4 - Int(vDensitySlider.intValue) + 2
        configuration.randomColors = colorSequencePopup.selectedTag() == 1
    }

}
