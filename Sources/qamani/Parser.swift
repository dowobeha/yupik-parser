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

    @Option(help:    "Mode: failure")
    var mode: String
    
    func run() {
        guard let l2s = FST(fromBinary: self.l2s) else {
            print("Unable to open \(self.l2s)", to: &stderr)
            return
        } //FST(fromBinary: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin")

        guard let l2i = FST(fromBinary: self.l2is) else {
            print("Unable to open \(self.l2is)", to: &stderr)
            return
        }
        
        guard let parsedSentences: [AnalyzedSentence] = Parser.parseFile(self.sentences, using: l2s, and: l2i) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }

        if self.mode == "failures" {
            for sentence in parsedSentences {
                //print(sentence.words.count)
                
                //var seen = Set<String>()
                let paths: Int = sentence.words.reduce(1, { (r:Int, w:AnalyzedWord) -> Int in return r * w.analyses.count})
                for word in sentence {
                    let forms: String = word.analyses.map{ $0.underlyingForm }.joined(separator: "\t")
                    var actual: String = "FAILURE"
                    if let a: String = word.actualSurfaceForm {
                        actual = a
                    }
                    if word.analyses.count >= 0 { //  && !seen.contains(actual)
                        //seen.insert(actual)
                        print("\(word.analyses.count)\t\(actual)\t\(paths)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)\t\(word.originalSurfaceForm)\t\(forms)")
                    }
                    /*
                    if word.analyses.isEmpty {
                        print("0\t\(word.originalSurfaceForm)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)")
                    } else {
                        print("SUCCESS\t\(word.analyses.count)\t\(word.originalSurfaceForm)\tWord \(word.wordNumber) of sentence \(sentence.lineNumber) in document \(sentence.document)")
                    }
 */
                }
            }
        }
    }
    
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
