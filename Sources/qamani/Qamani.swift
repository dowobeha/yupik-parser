import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

struct Qamani {

    let analyzers: MorphologicalAnalyzers
    
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
        
    }
    
    /**
     Read sentences from the provided file and morphologically analyze every word in every sentence in the file.
     
      - Parameters:
         - filename: absolute path to text file containing one sentence per line
         - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
         - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
     
     - Returns: A list of morphologically analyzed sentences.
     */
    func analyzeFile(_ filename: String) -> [AnalyzedSentence]? {
        if let lines = StreamReader(path: filename) {
            var document = filename
            if let x = filename.lastIndex(of: "/") {
                document = String(filename[filename.index(after: x)...])
            }
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            
            let result = ThreadedArray<AnalyzedSentence>()
            
            var progressBar = ProgressBar(count: nonBlankLines.count)
            let progressSemaphore = DispatchSemaphore(value: 0)
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            for (offset, line) in nonBlankLines.enumerated() {
                queue.async(group: group) {
                    let tokens = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ").map{String($0)}
                    let sentence = self.analyzers.analyzeSentence(tokens: tokens, lineNumber: offset+1, inDocument: document)
                    result.append(sentence)
                    //print(sentence)
                    progressSemaphore.signal()
                }
            }
            
            for _ in 0..<nonBlankLines.count {
                progressSemaphore.wait()
                progressBar.next()
            }
            
            group.wait()
            
            return Array(result).sorted(by: {$0.lineNumber < $1.lineNumber})

        } else {
            return nil
        }
    }

}
