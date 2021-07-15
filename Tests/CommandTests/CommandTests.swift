    import XCTest
    import Foundation
    @testable import Command

    final class CommandTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            //XCTAssertEqual(TINUCommand().text, "Hello, World!")
            
            var out: String?
                
            DispatchQueue.global(qos: .background).sync {
                //out = Command.getOut(cmd: "uname -a")
            
                out = Command.run(cmd: "/usr/bin/uname", args: ["-a"])?.outputString()
                
                print(out ?? "[Error]")
            }
            
            XCTAssert(out != nil)
        }
    }
