import ArgumentParser
import Foma
import StreamReader
import Foundation
import Dispatch
import Threading

/// Morphological analyzer capable of analyzing each word in each sentence of a provided text file.
struct CommandLineProgram: ParsableCommand {
    
    @Option(help:    "Descriptive name to use for a given pair of FSTs (l2s & l2is)")
    var name: [String] = []
    
    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
    var l2s: [String] = []

    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
    var l2is: [String] = []

    @Option(help:    "Text file containing one sentence per line")
    var sentences: String

    @Option(help:    "Character that delimits morpheme boundaries")
    var delimiter: String = "^"
    
    enum Mode: String, ExpressibleByArgument { case all, unique, failure }
    @Option(help:    """
                     Mode: all     (Print count and value of all analyzes for every word)
                           unique  (Print count and value of analyses for words with exactly 1 analysis)
                           failure (Print words that failed to analyze)

                     """)
    var mode: Mode = Mode.all
    
    /// Run morphological analyzer using provided command line arguments.
    func run() {

        var analyzers = [MorphologicalAnalyzer]()
        
        if self.l2s.count != self.l2is.count || self.l2s.count != self.name.count {
            print("The number of l2s analyzers \(self.l2s.count), l2is analyzers \(self.l2is.count), and names \(self.name.count) must be the same.", to: &stderr)
            return
        }
        
        for i in 0..<self.l2s.count {
            
            guard let l2s = FST(fromBinary: self.l2s[i]) else {
                print("Unable to open \(self.l2s[i])", to: &stderr)
                return
            }

            guard let l2is = FST(fromBinary: self.l2is[i]) else {
                print("Unable to open \(self.l2is[i])", to: &stderr)
                return
            }

            analyzers.append(MorphologicalAnalyzer(name: self.name[i], l2s: l2s, l2is: l2is, delimiter: self.delimiter))
            
        }
        
        guard let parsedSentences = CommandLineProgram.analyzeFile(self.sentences, using: MorphologicalAnalyzers(analyzers)) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }
        
        for sentence in parsedSentences {

            let paths: Int = sentence.words.reduce(1, { (r:Int, w:AnalyzedWord) -> Int in return r * w.count})
            for word in sentence {
                
                // Join all morphological analyses together with tabs
                let analyses: String =  word.analyses==nil ? "" : word.analyses!.analyses.map{ "\($0.underlyingForm) \($0.intermediateForm ?? "FAILURE")" }.joined(separator: "\t")
                
                let parsedSurfaceForm: String = word.analyses==nil ? "FAILURE" : word.analyses!.parsedSurfaceForm
                
                switch self.mode {
                case Mode.all:
                    print("\(word.count)\t\(parsedSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
                case Mode.unique:
                    if word.count == 1 {
                        print("\(word.count)\t\(parsedSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
                    }
                case Mode.failure:
                    if word.analyses == nil {
                        print("\(word.count)\t\(parsedSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
                    }
                }
            }
        }
    
    }
    
    /**
     Read sentences from the provided file and morphologically analyze every word in every sentence in the file.
     
      - Parameters:
         - filename: absolute path to text file containing one sentence per line
         - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
         - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
     
     - Returns: A list of morphologically analyzed sentences.
     */
    static func analyzeFile(_ filename: String, using machines: MorphologicalAnalyzers) -> ThreadedArray<AnalyzedSentence>? {
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
                    let sentence = AnalyzedSentence.init(line, lineNumber: offset+1, inDocument: document, using: machines)
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
            
            //let sorted = result.sorted()
            
            
            
            return result
            //return nonBlankLines.enumerated().map{ (tuple) -> AnalyzedSentence in return AnalyzedSentence.init(tuple.element, lineNumber: tuple.offset+1, inDocument: document, using: machines) }
        } else {
            return nil
        }
    }
}


CommandLineProgram.main()

/*
 
 let queue = DispatchQueue.global()
 let group = DispatchGroup()
 let n = 100
 for i in 0..<n {
     queue.async(group: group) {
         print("\(i): Running async task...")
         sleep(3)
         print("\(i): Async task completed")
     }
 }
 group.wait()
 print("done")

 print(str)
 
 
 */
