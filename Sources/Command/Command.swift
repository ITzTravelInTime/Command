import Foundation
//import TINURecovery

#if os(macOS)

public protocol CommandExecutor {
    static func start(cmd: String, args: [String]) -> Command.Handle?
    static func run(cmd : String, args : [String]?) -> Command.Result?
    static func run(cmd : String) -> Command.Result?
    static func getOut(cmd: String) -> String?
    init()
}

///This class manages the usage of executables and terminal commands using `Process` objects.
public final class Command: CommandExecutor{
    
    ///Initializer for compliance with the `CommandExecutor` protocol
    public required init(){
        //Litterally does nothing since this class is used more like a namespe and so it doesn't contain any stored values to intialize
    }
    
    //initalizers are kept internal to avoid having the library user messing too with the execution state or results.
    
    ///This struct is used to manage the execution of a 'Process' object
    public struct Handle {
        ///The `Process` object to track
        public let process: Process
        ///The `Pipe` object used to track the standard output of `process`
        public let outputPipe: Pipe
        ///The `Pipe` object used to track the standard error of `process`
        public let errorPipe: Pipe
    }
    
    ///This struct is used to represent the outputs of the execution of a  `Process`  object
    public struct Result: Equatable {
        ///The exit code produced by the execution
        public let exitCode: Int32
        ///The standard ouput lines produced by the execution
        public let output: [String]
        ///The standard error lines produced by the execution
        public let error: [String]
    }
    
    /**
     This function stars a `Process` object.
     
        - Parameters:
           - cmd: The path to the executable to launch in order to perform the command.
           - args: The args for the executable.
     
        - Returns: If the `Process` object launched successfully an `Handle` object is returned to track it, otherwise nil is returned.
     
        - Precondition:
            - The parameter `cmd` must not be empty.
            - Unless an executable embedded inside the current bundle is used, executing this function will most likely need sandboxing to be disabled.
     
     */
    public class func start(cmd: String, args: [String]) -> Handle? {
        
        assert(!cmd.isEmpty, "The process needs a path to an executable to execute!")
        
        //our temporary Process trackers
        let task = Process()
        let outpipe = Pipe()
        let errpipe = Pipe()
        
        task.launchPath = cmd //Sets the executable path
        task.arguments = args //Sets the executable arguments
        //create the standard error and output connections
        task.standardOutput = outpipe
        task.standardError = errpipe
        
        //launches the Process
        task.launch()
        
        //TODO: perhaps a better check should be used to detect if
        if !task.isRunning{
            return nil
        }
        
        return Handle(process: task, outputPipe: outpipe, errorPipe: errpipe)
    }
    
    /**
     This function gets the outputs of a `Process` object from an handle
        
        - Parameter from: The path to the executable to launch in order to perform the command
     
        - Returns: The `Result` object obtained from the execution of the `Handle`'s `Process` object
     
        - Precondition:
            - This will suspend the thread it's running on, it's highly reccommended to absolutley avoid running this from the main thread or the app/program will stop responding!
            - Unless an executable embedded inside the current bundle is used, executing this function will most likely need sandboxing to be disabled.
     
     */
    public class func result(from handle: Handle?) -> Result?{
        //this thing is here to allow nested usage of result and start
        guard let p = handle else { return nil }
        
        //our temporary storage
        var output : [String] = []
        var error : [String] = []
        var status = Int32()
        
        //Be carefoul, thanks to this line the whole thread stops, it's not reccommended to use this function from the main thread
        /*assert(!Thread.current.isMainThread, """
            /-------------------------------------------------------\\
            |Running a command from the main thread is unsupported!!|
            \\-------------------------------------------------------/
        """)*/
        
        p.process.waitUntilExit() //we need our process to be completed, so we wait i guess
        
        let outdata = p.outputPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = p.errorPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        status = p.process.terminationStatus
        
        return Result(exitCode: status, output: output, error: error)//(output, error, status)
    }
    
    /**
     This function manages an exectuin from start to execution finish, for a gived `CommandExecutor` type object
        
        - Parameters:
            - executor: Instance of the `CommandExecutor` type class that is going to run the execution
            - cmd: The path to the executable to launch in order to perform the command, or the String with the command/script to execute (see the description of the `args` parameter to learn more).
            - args: The arguments for the specified executable, if nil the `cmd` parameter will be run as a terminal command/script using the sh shell.
     
        - Returns: The `Command.Result` object obtained from the execution
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled unless it's run by passing the path for an executable embedded into the current bundle into the `cmd` argument and the `args` argument is not nil
     */
    public class func genericRun<T: CommandExecutor>(_ executor: T, cmd : String, args : [String]? = nil ) -> Command.Result? {
        //Can't do T.run because that's recursive with the current implementation
        if let cargs = args{
            return Command.result(from: T.start(cmd: cmd, args: cargs))
        }
        
        assert(!cmd.isEmpty, "The process needs a path to an executable to execute!")
        //assert(!Sandbox.isEnabled, "The app sandbox should be disabled to perform this operation!!")
        return Command.result(from: T.start(cmd: "/bin/sh", args: ["-c", cmd]))
    }
    
    /**
     This function manages a `Process` object from start to execution finish
        
        - Parameters:
            - cmd: The path to the executable to launch in order to perform the command, or the command to execute (see the description of the `args` parameter to learn more).
            - args: The arguments for the specified executable, if nil the `cmd` parameter will be run as a terminal command using the sh shell.
     
        - Returns: The `Command.Result` object obtained from the execution of the `Process` object
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled unless it's run by passing the path for an executable embedded into the current bundle into the `cmd` argument and the `args` argument is not nil
     */
    public static func run(cmd: String, args: [String]?) -> Result? {
        return genericRun(Command(), cmd: cmd, args: args)
    }
    
    /**
     This function manages a `Process` object from start to execution finish, from a shell command/script string
        
        - Parameters:
            - cmd: The string with the command/script to execute using the sh shell.
     
        - Returns: The `Command.Result` object obtained from the execution of the `Process` object
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled unless it's run by passing the path for an executable embedded into the current bundle into the `cmd` argument and the `args` argument is not nil
     */
    public static func run(cmd: String) -> Result? {
        return genericRun(Command(), cmd: cmd, args: nil)
    }
    
    /**
     Executes a command from start to finish using the sh shell and then returns either the standard output or the standard error of it's execution.
        
        - Parameters:
            - cmd: The command to perform using the sh shell.
            - isErr: Determinates if this function should return the standard error or the standard output
     
        - Returns: The `[String]` object obtained from the execution of the `Process` object, which is either the standard output or the standard error of it. If both the standard error and the standard output are need use the `Command.run` function with the `arg` parameter setted to nil instead.
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled.
     
     */
    public class func getOut(cmd: String, isErr: Bool) -> String?{
        //ths function runs a command on the sh shell and it does return the output or the error produced
        
        guard let res = run(cmd: cmd) else { return nil }
        
        let ret = (isErr ? res.error : res.output)
        
        var rett = ""
        
        for r in ret{
            rett += r + "\n"
        }
        
        if !rett.isEmpty{
            rett.removeLast()
        }
        
        return rett
    }
    
    /**
     Executes a command from start to finish using the sh shell and then returns either the standard output or the standard error of it's execution.
        
        - Parameters:
            - cmd: The command to perform using the sh shell.
     
        - Returns: The `[String]` object obtained from the execution of the `Process` object, which is it's standard output. If both the standard error and the standard output are need use the `Command.run` function with the `arg` parameter setted to nil instead.
     
        - Precondition:
            - This will suspend the thread it's running on, avoid running this from the main thread or the app/program will stop responding!
            - This function requres sandboxing to be dissbled.
     
     */
    public static func getOut(cmd: String) -> String? {
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
    @inline(__always) public class func getErr(cmd: String) -> String?{
        //ths function runs a command on the sh shell and it does return the error output
        return getOut(cmd: cmd, isErr: true)
    }
    
}

#endif
