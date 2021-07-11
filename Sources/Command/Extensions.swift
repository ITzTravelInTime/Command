//
//  File.swift
//  
//
//  Created by Pietro Caruso on 10/07/21.
//

import Foundation

public extension Array where Element == String{
    
    ///Resturns the current array as a string, each element of the array is a new line on the string
    func stringList() -> String{
        var ret = ""
        for r in self{
            ret += r + "\n"
        }
        
        if !ret.isEmpty{
            ret.removeLast()
        }
        
        return ret
    }
    
    func stringLine() -> String{
        var ret = ""
        for r in self{
            ret += r + " "
        }
        
        if !ret.isEmpty{
            ret.removeLast()
        }
        
        return ret
    }
    
}
