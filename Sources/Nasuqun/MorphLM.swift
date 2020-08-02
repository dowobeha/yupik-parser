import Dispatch
import Foundation

public struct SampledMorphLM {
    
    let lmplzInputPipe: Pipe
    
    let queryInputPipe: Pipe
    let queryOutputPipe: Pipe
    
    let group: DispatchGroup
    
    public init(lmplz: String, arpaPath: String, query: String) {
//    public init(_ tsv: String, n: Int, p: Posterior, order: Int, lmplz: String, query: String) {
        let lmplzTask = Process()
        lmplzTask.executableURL = URL(fileURLWithPath: lmplz)
        lmplzTask.arguments = ["--arpa", arpaPath]
        
        self.lmplzInputPipe = Pipe()
        //let outputPipe = Pipe()
        //let errorPipe = Pipe()

        lmplzTask.standardInput = self.lmplzInputPipe
        //lmplzTask.standardOutput = outputPipe
        //lmplzTask.standardError = errorPipe
        
        let queryTask = Process()
        queryTask.executableURL = URL(fileURLWithPath: query)
        queryTask.arguments = [arpaPath]
        
        self.queryInputPipe = Pipe()
        self.queryOutputPipe = Pipe()

        queryTask.standardInput = self.queryInputPipe
        queryTask.standardOutput = self.queryOutputPipe
        
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
               try lmplzTask.run()
               lmplzTask.waitUntilExit()
            } catch _ {
            
            }
        }


        queue.async(group: self.group) {
            do {
               try queryTask.run()
               queryTask.waitUntilExit()
            } catch _ {
            
            }
        }
 
        /*
        queue.async(group: self.group) {
            //print("Ready to write")
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            //print("Read stdout")
            //let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(decoding: outputData, as: UTF8.self)
            //let error = String(decoding: errorData, as: UTF8.self)

            //print("output:\n\(output)")
            print(output)
//            print("\nerror:\n\(error)")
        }
        */
        //group.wait()
    }
    
    
}
