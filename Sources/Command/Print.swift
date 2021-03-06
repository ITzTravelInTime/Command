/*
 Swift Library to launch, run and get the output of executables and terminal commands/scripts in a simple and quick way.
 Copyright (C) 2021-2022 Pietro Caruso

 This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

import Foundation

//the library ITzTravelInTime/SwiftLoggedPrint can be used instead of this class

///This class manages prints
open class GeneralPrinter {
    public static var enabled: Bool = true
    open class var prefix: String{
        return ""
    }
    
    open class func print( _ str: String){
        if enabled{
            Swift.print("\(prefix) \(str)")
        }
    }
}

///Subclass of the printer class adding the custom prefix
public class DebugPrinter: GeneralPrinter{
    public override class var prefix: String{
        return "[Command] [Debug]"
    }
}

internal func print( _ stuff: Any){
    DebugPrinter.print("\(stuff)")
}
