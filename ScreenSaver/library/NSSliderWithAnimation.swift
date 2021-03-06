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

class NSSliderWithAnimation: NSSlider, CAAnimationDelegate {
    
    override func animation(forKey key: NSAnimatablePropertyKey) -> Any?
    {
        if key == "integerValue" {
            allowsTickMarkValuesOnly = false
            let animation = CABasicAnimation()
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.delegate = self
            return animation
        }
        return super.animation(forKey: key)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        allowsTickMarkValuesOnly = true
        sendAction()
    }
    
}
