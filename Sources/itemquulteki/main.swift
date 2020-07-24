import ArgumentParser
import Foundation
import Qamani

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

    @Option(help:    "Character that delimits morpheme boundaries in the segmented lexical underlying forms and in the segmented surface forms")
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

        guard let itemquulta = Itemquulta(name: self.name, l2s: self.l2s, l2is: self.l2is, delimiter: self.delimiter) else {
            return
        }
        
        var stderr = FileHandle.standardError
        
        guard let parsedSentences: Qamani = itemquulta.analyzeFile(self.sentences) else {
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
}


CommandLineProgram.main()
