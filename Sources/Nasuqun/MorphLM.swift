import Dispatch
import Foundation

public struct SampledMorphLM {
    
    let inputPipe: Pipe
    
    let group: DispatchGroup
    
    public init() {
//    public init(_ tsv: String, n: Int, p: Posterior, order: Int, lmplz: String, query: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/tr")
        task.arguments = ["A", "a"]
        
        self.inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardInput = inputPipe
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        let queue = DispatchQueue.global()
        self.group = DispatchGroup()
        
/*
        queue.async(group: group) {
            self.inputPipe.fileHandleForWriting.write("HAPPY\n".data(using: .utf8)!)
            self.inputPipe.fileHandleForWriting.closeFile()
        }
  */
        queue.async(group: self.group) {
            do {
               try task.run()
               task.waitUntilExit()
            } catch _ {
            
            }
        }
        
        queue.async(group: self.group) {
            //print("Ready to write")
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            //print("Read stdout")
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(decoding: outputData, as: UTF8.self)
            let error = String(decoding: errorData, as: UTF8.self)

            //print("output:\n\(output)")
            print(output)
//            print("\nerror:\n\(error)")
        }
        
        //group.wait()
    }
    
}
