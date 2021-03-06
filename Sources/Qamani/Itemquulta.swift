import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

public struct Itemquulta {

    let analyzers: MorphologicalAnalyzers
    let delimiter: String
    
    public init?(name: [String], l2s: [String], l2is: [String], delimiter: String) {
        
        var analyzers = [MorphologicalAnalyzer]()
               
        if l2s.count != l2is.count || l2s.count != name.count {
            print("The number of l2s analyzers \(l2s.count), l2is analyzers \(l2is.count), and names \(name.count) must be the same.", to: &stderr)
            return nil
        }
               
        for i in 0..<l2s.count {
                   
            guard let l2sFST = FST(fromBinary: l2s[i]) else {
               print("Unable to open \(l2s[i])", to: &stderr)
               return nil
            }

            guard let l2isFST = FST(fromBinary: l2is[i]) else {
               print("Unable to open \(l2is[i])", to: &stderr)
               return nil
            }

            analyzers.append(MorphologicalAnalyzer(name: name[i], l2s: l2sFST, l2is: l2isFST, delimiter: delimiter))
                   
        }
              
        self.analyzers = MorphologicalAnalyzers(analyzers)
        self.delimiter = delimiter
        
    }
    
    /**
     Read sentences from the provided file and morphologically analyze every word in every sentence in the file.
     
      - Parameters:
         - filename: absolute path to text file containing one sentence per line
         - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
         - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
     
     - Returns: A list of morphologically analyzed sentences.
     */
    public func analyzeFile(_ filename: String) -> AnalyzedCorpus? {
        
        if let lines = StreamReader(path: filename) {
            var document = filename
            if let x = filename.lastIndex(of: "/") {
                document = String(filename[filename.index(after: x)...])
            }
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            
            let result = ThreadedArray<AnalyzedSentence>()
            //let result2 = ThreadedArray<String>()
            
            var tokensInCorpus = 0
            for line in nonBlankLines {
                for _ in line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ") {
                    tokensInCorpus += 1
                }
            }
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            var progressBar = ProgressBar(count: tokensInCorpus)
            let progressSemaphore = DispatchSemaphore(value: 0)
            
            // Thread for displaying progress bar
            queue.async(group: group) {
                for _ in 0..<tokensInCorpus {
                    progressSemaphore.wait()
                    progressBar.next()
                }
            }
            
            for (offset, line) in nonBlankLines.enumerated() {
                queue.async(group: group) {
                    let tokens = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ").map{String($0)}
                    let sentence = self.analyzers.analyzeSentence(tokens: tokens, lineNumber: offset+1, inDocument: document)
                    //let sentence = "\(offset+1) \(line)"
//                    if let json = sentence.toJson() {
//                        print(json, to: &stderr)
//                    } else {
//                        print("Failed to convert \(sentence.description) to JSON", to: &stderr)
//                    }
                    result.append(sentence)
                    //print(tokens)
                    for _ in tokens {
                        progressSemaphore.signal()
                    }
                }
            }
            
           
            group.wait()
            
//            for result in result2 {
//                print(result)
//            }
            
            //return nil
            return AnalyzedCorpus(analyzedSentences: Array(result).sorted(by: {$0.lineNumber < $1.lineNumber}), morphemeDelimiter: self.delimiter)

        } else {
            return nil
        }
    }

}
