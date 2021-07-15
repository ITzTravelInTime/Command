import Foundation
import Command

//Disable debug printing for the library
Printer.enabled = false

func info() -> String?{
    
    var out: String?
        
    //Execution of the command must be in a separated thread, not the main!
    DispatchQueue.global(qos: .background).sync {
        let result = Command.run(cmd: "/usr/bin/uname", args: ["-a"]) //Executes the uname -a command and returns it's ouput
        
        out = result?.outputString() //Gets the output as a string
    }
    
    return out
}

print(info() ?? "Error: launch of the \"uname -a\" command failed!")
