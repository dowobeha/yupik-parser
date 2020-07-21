import ArgumentParser
import Foma
import StreamReader
import Foundation

/// Morphological analyzer capable of analyzing each word in each sentence of a provided text file.
struct MorphologicalAnalyzer: ParsableCommand {
    
    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
    var l2s: String

    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
    var l2is: String

    @Option(help:    "Finite-state transducer (guessed underlying form to surface form) in foma binary file format")
    var g2s: String

    @Option(help:    "Finite-state transducer (guessed underlying form to segmented surface form) in foma binary file format")
    var g2is: String

    @Option(help:    "Finite-state transducer (guessed foreign underlying form to surface form) in foma binary file format")
    var f2s: String

    @Option(help:    "Finite-state transducer (guessed foreign underlying form to segmented surface form) in foma binary file format")
    var f2is: String
    
    @Option(help:    "Text file containing one sentence per line")
    var sentences: String

    enum Mode: String, ExpressibleByArgument { case all, unique, failure }
    @Option(help:    """
                     Mode: all     (Print count and value of all analyzes for every word)
                           unique  (Print count and value of analyses for words with exactly 1 analysis)
                           failure (Print words that failed to analyze)

                     """)
    var mode: Mode = Mode.all
    
    /// Run morphological analyzer using provided command line arguments.
    func run() {

        guard let l2s = FST(fromBinary: self.l2s) else {
            print("Unable to open \(self.l2s)", to: &stderr)
            return
        }

        guard let l2is = FST(fromBinary: self.l2is) else {
            print("Unable to open \(self.l2is)", to: &stderr)
            return
        }

        guard let g2s = FST(fromBinary: self.g2s) else {
            print("Unable to open \(self.g2s)", to: &stderr)
            return
        }

        guard let g2is = FST(fromBinary: self.g2is) else {
            print("Unable to open \(self.g2is)", to: &stderr)
            return
        }
        
        guard let f2s = FST(fromBinary: self.f2s) else {
            print("Unable to open \(self.f2s)", to: &stderr)
            return
        }

        guard let f2is = FST(fromBinary: self.f2is) else {
            print("Unable to open \(self.f2is)", to: &stderr)
            return
        }
        
        let machines = FSTs(machines: [FSTs.Pair(l2s: l2s, l2is: l2is),
                                       FSTs.Pair(l2s: g2s, l2is: g2is),
                                       FSTs.Pair(l2s: f2s, l2is: f2is)])
        
        guard let parsedSentences: [AnalyzedSentence] = MorphologicalAnalyzer.analyzeFile(self.sentences, using: machines) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }

        for sentence in parsedSentences {

            let paths: Int = sentence.words.reduce(1, { (r:Int, w:AnalyzedWord) -> Int in return r * w.analyses.count})
            for word in sentence {
                
                // Join all morphological analyses together with tabs
                let analyses: String = word.analyses.map{ $0.underlyingForm }.joined(separator: "\t")
                
                let actualSurfaceForm: String = word.actualSurfaceForm==nil ? "FAILURE" : word.actualSurfaceForm!
                
                switch self.mode {
                case Mode.all:
                    print("\(word.analyses.count)\t\(actualSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
                case Mode.unique:
                    if word.analyses.count == 1 {
                        print("\(word.analyses.count)\t\(actualSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
                    }
                case Mode.failure:
                    if word.analyses.isEmpty {
                        print("\(word.analyses.count)\t\(actualSurfaceForm)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(analyses)")
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
    static func analyzeFile(_ filename: String, using machines: FSTs) -> [AnalyzedSentence]? {
        if let lines = StreamReader(path: filename) {
            var document = filename
            if let x = filename.lastIndex(of: "/") {
                document = String(filename[filename.index(after: x)...])
            }
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            return nonBlankLines.enumerated().map{ (tuple) -> AnalyzedSentence in return AnalyzedSentence.init(tuple.element, lineNumber: tuple.offset+1, inDocument: document, using: machines) }
        } else {
            return nil
        }
    }
}
