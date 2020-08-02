import Dispatch
import Foundation
import StreamReader
import Threading

public struct SampledMorphLM {
    
    let probabality: [String: Float]
    
    private init(_ probs: [String: Float]) {
        self.probabality = probs
    }
 
    public static func sample(from tsv: ParsedTSV, lmplz: String, arpaPath: String, query: String, times t: Int = 1, posterior p: Posterior? = nil) -> SampledMorphLM? {
        //let morphLM = SampledMorphLM(lmplz: lmplz, arpaPath: arpaPath, query: query)

        // If any thread fails, it will set this value to false
        var success = Atomic<Bool>(true)
        
        // Configure process to estimate LM using lmplz
        let lmplzTask = Process()
        let lmplzInputPipe = Pipe()
        let lmplzStandardInput: FileHandle = lmplzInputPipe.fileHandleForWriting
        lmplzTask.executableURL = URL(fileURLWithPath: lmplz)
        lmplzTask.arguments = ["--arpa", arpaPath]
        lmplzTask.standardInput = lmplzInputPipe
        
        // Configure process to query LM using query
        let queryTask = Process()
        let queryInputPipe = Pipe()
        let queryOutputPipe = Pipe()
        let queryStandardInput: FileHandle = queryInputPipe.fileHandleForWriting
        let queryStandardOutput: FileHandle = queryOutputPipe.fileHandleForReading
        queryTask.executableURL = URL(fileURLWithPath: query)
        queryTask.arguments = ["-v", "sentence", arpaPath]
        queryTask.standardInput = queryInputPipe
        queryTask.standardOutput = queryOutputPipe
        
        // Configure Swift multi-threading
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        // Launch lmplz in its own thread
        queue.async(group: group) {
            do {
                // Launch lmplz as an external process
                try lmplzTask.run()
                
                // If a posterior distribution p(analysis | word) was provided, use it. Otherwise use the NaivePosterior distribution.
                let posterior = (p==nil) ? NaivePosterior(tsv) : p!
                
                // Perform sampling and write samples to standard input of lmplz
                for analyzedWord in tsv.data.values {
                    
                    let word = analyzedWord.word
                    
                    // Sample once for each instance of this word in the corpus
                    for _ in 0..<analyzedWord.count {
                    
                        // Sample as many times as the user said to
                        for _ in 0..<t {
                            
                            let r = Float.random(in: 0.0..<1.0)
                            var sum = Float(0.0)
                            
                            for analysis in analyzedWord.analyses {
                                sum += posterior(analysis | word)
                                if r < sum {
                                    lmplzStandardInput.write(analysis + "\n")
                                    //print(analysis)
                                    break
                                }
                            }
                        }
                    }
                    
                }
                
                // Complete running lmplz as an external process
                lmplzStandardInput.closeFile()
                lmplzTask.waitUntilExit()
                
            } catch _ {
                success.store(false)
                lmplzTask.terminate()
                queryTask.terminate()
            }
        }

        // Launch query in its own thread
        queue.async(group: group) {
            do {
                try queryTask.run()
                
                for analyzedWord in tsv.data.values {
                    for analysis in analyzedWord.analyses {
                        queryStandardInput.write(analysis + "\n")
                    }
                }
                
                queryStandardInput.closeFile()

            } catch _ {
                success.store(false)
                lmplzTask.terminate()
                queryTask.terminate()
            }
        }
        
        // Wait until both threads have completed
        group.wait()
        
        let eitherThreadFailed = !success.load()
        
        if eitherThreadFailed {

            return nil

        } else {
            
            // Read values returned by query
            let analyses: [String] = tsv.data.values.flatMap{ $0.analyses }
            
            let encoding = String.Encoding.utf8
            let delimiter = "\n".data(using: encoding)!
            var queryResults = [Float]()
            
            for line in StreamReader(fileHandle: queryStandardOutput, delimiterData: delimiter, encoding: encoding, chunkSize: 4096) {
                if line.starts(with: "Total:") {
                    if let value = Float(line.split(separator: " ")[1]) {
                        queryResults.append(value)
                    }
                }
            }
            
            let analysisProbs: [String: Float] = zip(analyses, queryResults).reduce(into: [String: Float]()) { (dict: inout [String: Float], tuple: (String, Float)) in
                let analysis = tuple.0
                let logprob = tuple.1
                let prob = pow(10.0, logprob)
                dict[analysis] = prob
            }
            
            return SampledMorphLM(analysisProbs)
        }
               
    }
}
