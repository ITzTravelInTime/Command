//
//  File.swift
//  
//
//  Created by Pietro Caruso on 10/07/21.
//

import Foundation

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
