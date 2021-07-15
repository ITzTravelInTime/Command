//
//  Print.swift
//  Command
//
//  Created by Pietro Caruso on 15/07/21.
//

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
public class Printer: GeneralPrinter{
    public override class var prefix: String{
        return "[Command] [Debug]"
    }
}

internal func print( _ stuff: Any){
    Printer.print("\(stuff)")
}
