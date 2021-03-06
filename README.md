# Command
Swift Library to launch, run and get the output of executables and terminal commands/scripts in a simple and quick way.

## Features
- Manages the usage of Swift's `Process` Objects, and so allows the library user to: launch, run or just get the standard output/error of a `Process` execution
- Provvides comvenint structs for abstraction and ease of usage
- Allows for class extensions, and extension libraryes to increase the functionality offered (see the `Known extensions for this library` section for more info)
- Provvides a protocol for extensions to conform to the basic usage of the main class
- Debug checks to ensure the library code is used as intended
- No particular dependecies

## Usage

Usage is well documented into the source code, so check that out for more info. To prevent having mirrors of this information, this file will be just limited to the following very usefoul example usage:

```swift

import Foundation
import Command

//TODO: Remove this warning when I understood what I need to do
#warning("This code needs the app sandbox to be tuned off for the current project! (unless you decide to execute an embedded executable inside your app's bundle)")

//Disable debug printing for the library
Command.Printer.enabled = false

func info() -> String?{
    
    var out: String?
        
    //Execution of the command must be in a separated thread, not the main!
    DispatchQueue.global(qos: .background).sync {
        out = Command.run(cmd: "/usr/bin/uname", args: ["-a"])?.outputString() //Executes the uname -a command and returns it's ouput as a string
    }
    
    return out
}

print(info() ?? "Error: launch of the \"uname -a\" command failed!")

```

## What apps/programs is this Library intended for?

This library should be used by non-sandboxed swift apps/programs (unless only commands targeted at embedded executables inside the current bundle are run) or embedded helper tools, that needs to run terminal scripts/commands or separated executables from their own.

This code is intended for macOS only since it requires the system library `Process` type from the Swift API, that is only available on that platform.

## **Warnings**

 - To let the code to fully work (expecially the `Command.run` and the `Command.get...` functions ) your app/program might most likely need to not be sandboxed, unless an executable located inside the current bundle is specified, see the documentation inside the source code for more details.
 - All functions from the `Command` class needs to be run from a non-main thread, except from the `Command.start` function.

## Known extensions for this library

 - [ITzTravelInTime/CommandSudo](https://github.com/ITzTravelInTime/CommandSudo) Adds support for privileged executions using apple scripts.

## About the project

This code was created as part of my [TINU project](https://github.com/ITzTravelInTime/TINU) and it has been separated and made into it's own library to make the main project's source less complex and more focused on it's aim. 

Also having this as it's own library allows for code to be updated separately and so various versions of the main TINU app will be able to be compiled all with the latest version of this library.

## Used libraries

- [ITzTravelInTime/SwiftPackagesBase](https://github.com/ITzTravelInTime/SwiftPackagesBase)

## Credits

 - ITzTravelInTime (Pietro Caruso) - Project creator and main developer

## Contacts

 - ITzTravelInTime (Pietro Caruso): piecaruso97@gmail.com

## Legal info

Swift Library to launch, run and get the output of executables and terminal commands/scripts in a simple and quick way.
Copyright (C) 2021-2022 Pietro Caruso

This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
