//
//  File.swift
//  
//
//  Created by Pietro Caruso on 10/07/21.
//

import Foundation

#if os(macOS)

public extension Command{
    
    ///This struct is used to manage the execution of a 'Process' object
    struct Handle {
        
        ///Initializes a `Handle` object using the provvided `Process` and `Pipe` objects.
        internal init(process: Process = Process(), outputPipe: Pipe = Pipe(), errorPipe: Pipe = Pipe()) {
            self.process = process
            self.outputPipe = outputPipe
            self.errorPipe = errorPipe
        }
        
        ///The `Process` object to track
        public let process: Process
        ///The `Pipe` object used to track the standard output of `process`
        public let outputPipe: Pipe
        ///The `Pipe` object used to track the standard error of `process`
        public let errorPipe: Pipe
        
        /**
         This function gets the outputs of a `Process` object from an handle
         
         - Parameter from: The path to the executable to launch in order to perform the command
         
         - Returns: The `Result` object obtained from the execution of the `Handle`'s `Process` object
         
         - Precondition:
         - This will suspend the thread it's running on, it's highly reccommended to absolutley avoid running this from the main thread or the app/program will stop responding!
         - Unless an executable embedded inside the current bundle is used, executing this function will most likely need sandboxing to be disabled.
         
         */
        public func result() -> Result?{
            //our temporary storage
            var output : [String] = []
            var error : [String] = []
            //var status = Int32()
            
            
            //The assert was commented because of all the false positives it gave
            /*assert(!Thread.current.isMainThread, """
             /-------------------------------------------------------\\
             |Running a command from the main thread is unsupported!!|
             \\-------------------------------------------------------/
             """)*/
            
            //Be carefoul, thanks to this line the whole thread stops, it's not reccommended to use this function from the main thread
            process.waitUntilExit() //we need our process to be completed, so we wait i guess
            
            let outdata = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            
            let errdata = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: errdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
            
            //status = process.terminationStatus
            
            //return Result(exitCode: status, output: output, error: error)//(output, error, status)
            return Result(exitCode: process.terminationStatus, output: output, error: error)
        }
    }
    
    ///This struct is used to represent the outputs of the execution of a  `Process`  object
    struct Result: Equatable {
        
        internal init(exitCode: Int32, output: [String] = [], error: [String] = []) {
            self.exitCode = exitCode
            self.output = output
            self.error = error
        }
        
        ///The exit code produced by the execution
        public let exitCode: Int32
        ///The standard ouput lines produced by the execution
        public let output: [String]
        ///The standard error lines produced by the execution
        public let error: [String]
        
        ///Returns the output as one string, each element of the output is in a separated line
        public func outputString() -> String{
            return output.stringList()
        }
        
        ///Returns the error as one string, each element of the error is in a separated line
        public func errorString() -> String{
            return error.stringList()
        }
    }
    
}

#endif
