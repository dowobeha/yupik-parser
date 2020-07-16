import ArgumentParser
import Foma
import StreamReader
import Foundation

struct Parser: ParsableCommand {
    
    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
    var l2s: String

    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
    var l2is: String
    
    @Option(help:    "Text file containing one sentence per line")
    var sentences: String

    enum Mode: String, ExpressibleByArgument { case all, unique, failure }
    @Option(help:    """
                     Mode: all     (Print count and value of all analyzes for every word)
                           unique  (Print count and value of analyses for words with exactly 1 analysis)
                           failure (Print words that failed to analyze)

                     """)
    var mode: Mode = Mode.all
    
    func run() {

        guard let l2s = FST(fromBinary: self.l2s) else {
            print("Unable to open \(self.l2s)", to: &stderr)
            return
        }

        guard let l2i = FST(fromBinary: self.l2is) else {
            print("Unable to open \(self.l2is)", to: &stderr)
            return
        }
        
        guard let parsedSentences: [AnalyzedSentence] = Parser.parseFile(self.sentences, using: l2s, and: l2i) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }

        for sentence in parsedSentences {

            let paths: Int = sentence.words.reduce(1, { (r:Int, w:AnalyzedWord) -> Int in return r * w.analyses.count})
            for word in sentence {
                let forms: String = word.analyses.map{ $0.underlyingForm }.joined(separator: "\t")
                var actual: String = "FAILURE"
                if let a: String = word.actualSurfaceForm {
                    actual = a
                }
                
                switch self.mode {
                case Mode.all:
                    print("\(word.analyses.count)\t\(actual)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(forms)")
                case Mode.unique:
                    if word.analyses.count == 1 {
                        print("\(word.analyses.count)\t\(actual)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(forms)")
                    }
                case Mode.failure:
                    if word.analyses.isEmpty {
                        print("\(word.analyses.count)\t\(actual)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(forms)")
                    }
                }
            }
        }
    
    }
    
    /// Read sentences from the provided file and morphologically analyze every word in every sentence in the file.
    static func parseFile(_ filename: String, using l2s: FST, and l2i: FST) -> [AnalyzedSentence]? {
        if let lines = StreamReader(path: filename) {
            var document = filename
            if let x = filename.lastIndex(of: "/") {
                document = String(filename[filename.index(after: x)...])
            }
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            return nonBlankLines.enumerated().map{ (tuple) -> AnalyzedSentence in return AnalyzedSentence.init(tuple.element, lineNumber: tuple.offset+1, inDocument: document, using: l2s, and: l2i) }
        } else {
            return nil
        }
    }
}
