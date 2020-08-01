import Dispatch
import Foundation

public struct SampledMorphLM {
    
    public init() {
//    public init(_ tsv: String, n: Int, p: Posterior, order: Int, lmplz: String, query: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
        task.arguments = ["A", "a"]
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardInput = inputPipe
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        

        queue.async(group: group) {
            inputPipe.fileHandleForWriting.write("HAPPY\n".data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
        }
        
        queue.async(group: group) {
            do {
               try task.run()
               task.waitUntilExit()
            } catch _ {
            
            }
        }
        
        queue.async(group: group) {
            
            let f = outputPipe.fileHandleForReading
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(decoding: outputData, as: UTF8.self)
            let error = String(decoding: errorData, as: UTF8.self)

            print("output=\(output)")
            print("error=\(error)")
        }
        
        group.wait()
    }
    
}
