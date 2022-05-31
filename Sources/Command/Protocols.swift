/*
 Swift Library to launch, run and get the output of executables and terminal commands/scripts in a simple and quick way.
 Copyright (C) 2021-2022 Pietro Caruso

 This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

import Foundation
import SwiftPackagesBase

#if os(macOS)

public protocol CommandExecutor {
    static func start(cmd: String, args: [String]!) -> Command.Handle?
    //static func run(cmd : String, args : [String]?) -> Command.Result?
    //static func run(cmd : String) -> Command.Result?
    static func getOut(cmd: String) -> String?
}

public extension CommandExecutor{
    /**
     Manages a complete execution for a `CommandExecutor` object from start to finish.
        
        - Parameters:
            - cmd: The path to the executable to launch in order to perform the command, or the command to execute (see the description of the `args` parameter to learn more).
            - args: The arguments for the specified executable, if nil the `cmd` parameter will be run as a terminal command using the sh shell.
     
        - Returns: The `Command.Result` object obtained from the execution of the `Process` object
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled unless it's run by passing the path for an executable embedded into the current bundle into the `cmd` argument and the `args` argument is not nil
     */
    static func run(cmd : String, args : [String]? = nil) -> Command.Result? {
        
        var ret: Command.Result!
        
        if let cargs = args{
             ret = Self.start(cmd: cmd, args: cargs)?.result()
        }else{
            assert(!cmd.isEmpty, "The process needs a path to an executable to execute!")
            //assert(FileManager.default.fileExists(atPath: cmd), "A valid path to an executable file that exist must be specified for this arg")
            //assert(!Sandbox.isEnabled, "The app sandbox should be disabled to perform this operation!!")
            ret = Self.start(cmd: "/bin/sh", args: ["-c", cmd])?.result()
        }
        
        print("Executed command: \(cmd) \(args?.stringLine() ?? "")")
        
        if ret != nil{
            print("Exit code: \(ret.exitCode)")
            print("Output:\n\(ret.outputString())")
            print("Error:\n\(ret.errorString())")
        }else{
            print("Command returned nil")
        }
            
        return ret
    }
}

#endif
