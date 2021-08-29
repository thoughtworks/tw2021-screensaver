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

import Foundation

class Util
{
    class func randomBool() -> Bool
    {
        arc4random_uniform(2) == 0
    }
    
    class func randomInt(_ max: Int) -> Int
    {
        Int(arc4random_uniform(UInt32(max)))
    }
    
    class func randomInt(range: ClosedRange<Int>) -> Int
    {
        randomInt(range.upperBound - range.lowerBound + 1) - range.lowerBound
    }
    
}



