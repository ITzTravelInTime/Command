import Foundation
//import TINURecovery

#if os(macOS)

///This class manages the usage of executables and terminal commands using `Process` objects.
public final class Command: CommandExecutor{
    
    /**
     This function stars a `Process` object.
     
        - Parameters:
           - cmd: The path to the executable to launch in order to perform the command.
           - args: The args for the executable.
     
        - Returns: If the `Process` object launched successfully an `Handle` object is returned to track it, otherwise nil is returned.
     
        - Precondition:
            - The parameter `cmd` must not be empty and must be a file that exists or an assertion error will be triggered.
            - Unless an executable embedded inside the current bundle is used, executing this function will most likely need sandboxing to be disabled.
     
     */
    public class func start(cmd: String, args: [String]! = nil) -> Handle? {
        
        assert(!cmd.isEmpty, "The process needs a path to an executable to execute!")
        assert(FileManager.default.fileExists(atPath: cmd), "A valid path to an executable file that exist must be specified for this arg")
        
        //our temporary Process trackers
        //let process = Process()
        //let outputPipe = Pipe()
        //let errorPipe = Pipe()
        
        let handle = Handle()
        
        handle.process.launchPath = cmd //Sets the executable path
        handle.process.arguments = args //Sets the executable arguments
        
        //create the standard error and output connections
        handle.process.standardOutput = handle.outputPipe
        handle.process.standardError = handle.errorPipe
        
        //launches the Process
        handle.process.launch()
        
        //Perhaps a better check should be used, but for now this works well enought
        if !handle.process.isRunning{
            return nil
        }
        
        //return Handle(process: process, outputPipe: outputPipe, errorPipe: errorPipe)
        
        return handle
    }
    
    /**
     Executes a command from start to finish using the sh shell and then returns either the standard output or the standard error of it's execution.
        
        - Parameters:
            - cmd: The command to perform using the sh shell.
            - isErr: Determinates if this function should return the standard error or the standard output
     
        - Returns: The `String` object obtained from the execution of the `Process` object, which is either the standard output or the standard error of it. If both the standard error and the standard output are need use the `Command.run` function with the `arg` parameter setted to nil instead.
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled.
     
     */
    @available(*, deprecated, message: "This method can lead to dangerous exploits using the shell PATH variable, it's highly reccomended not use it")
    public class func getOut(cmd: String, isErr: Bool) -> String?{
        //ths function runs a command on the sh shell and it does return the output or the error produced
        
        guard let res = run(cmd: cmd) else { return nil }
        
        return (isErr ? res.error : res.output).stringList()
    }
    
    /**
     Executes a command from start to finish using the sh shell and then returns either the standard output or the standard error of it's execution.
        
        - Parameters:
            - cmd: The command to perform using the sh shell.
     
        - Returns: The `String` object obtained from the execution of the `Process` object, which is it's standard output. If both the standard error and the standard output are need use the `Command.run` function with the `arg` parameter setted to nil instead.
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled.
     
     */
    @available(*, deprecated, message: "This method can lead to dangerous exploits using the shell PATH variable, it's highly reccomended not use it")
    @inline(__always) public static func getOut(cmd: String) -> String? {
        return getOut(cmd: cmd, isErr: false)
    }
    
    /**
     Specialized versions of the `Command.getOut` function which returns just the Standard error.
     
     - Parameters:
         - cmd: The command to perform using the sh shell.
     
     - Returns: The `[String]` object obtained from the execution of the `Process` object, which contains the standard error of the execution. If both the standard error and the standard output are need use the `Command.run` function with the `arg` parameter setted to nil instead.
     
     - Precondition:
         - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
         - This function requres sandboxing to be dissbled.
    */
    @available(*, deprecated, message: "This method can lead to dangerous exploits using the shell PATH variable, it's highly reccomended not use it")
    @inline(__always) public class func getErr(cmd: String) -> String?{
        //ths function runs a command on the sh shell and it does return the error output
        return getOut(cmd: cmd, isErr: true)
    }
    
}

#endif
