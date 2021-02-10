import ArgumentParser
import Foundation
import Qamani
import Threading

/**
   Morphological analyzer capable of analyzing each word in each sentence of a provided text file.

   > **itemquulteki**
   > *итымқӯльтыки*
   > /i.'təm.'quːɬ.tə.ki/
   >
   > let's take them apart
   >
   > (transitive verb, optative mood, 1st person plural subject, 3rd person plural object)
   >
   > (*Badten et al, 2008*)

 */
struct Itemquulteki: ParsableCommand {
    
    static var configuration = CommandConfiguration(
            abstract: "Morphological analyzer capable of analyzing each word in each sentence of a provided text file.",
            discussion: """
                    Itemquulteki!
                    Let's take them apart!
                """)

    @Option(help:    "Text file containing one sentence per line")
    var sentences: String

    @Option(help:    "Character that delimits morpheme boundaries in the segmented lexical underlying forms and in the segmented surface forms")
    var delimiter: String = "^"

    @Option(help:    "Descriptive name to use for a given pair of FSTs (l2s & l2is)")
    var name: [String] = []
    
    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
    var l2s: [String] = []

    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
    var l2is: [String] = []

    /// Run morphological analyzer(s) using provided command line arguments.
    func run() {

        var stderr = FileHandle.standardError
        
        guard let itemquulta = Itemquulta(name: self.name, l2s: self.l2s, l2is: self.l2is, delimiter: self.delimiter) else {
            print("Unable to initialize analyzer(s)", to: &stderr)
            return
        }
        
        guard let parsedSentences: Qamani = itemquulta.analyzeFile(self.sentences) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }
        
        for sentence in parsedSentences {

            for word in sentence {
                
                // Join all morphological analyses together with tabs
                //let analyses: String =  word.analyses==nil ? "" : word.analyses!.analyses.map{ "\($0.underlyingForm) \($0.intermediateForm ?? "FAILURE")" }.joined(separator: "\t")
                
                let analyses: String =  word.analyses==nil ? "" : word.analyses!.analyses.map{ $0.morphemes }.joined(separator: "\t")
                
//                if let ans: MorphologicalAnalyses = word.analyses {
//                    if let firstAnalysis = ans.analyses.first {
//                        print("\(word.originalSurfaceForm)\t\"\(firstAnalysis.morphemes)\"\t\"\(firstAnalysis.underlyingForm)\"\t\"\(ans.parsedSurfaceForm)\"\tDone", to: &stderr)
//                    } else {
//                        print("\(word.originalSurfaceForm)\tNO FIRST ANALYSIS", to: &stderr)
//                    }
//                } else {
//                    print("\(word.originalSurfaceForm)\tFAILED", to: &stderr)
//                }
                
                
                if let parsedSurfaceForm: String = word.analyses==nil ? nil : word.analyses!.parsedSurfaceForm {
                    print("\(sentence.document)\t\(sentence.lineNumber)\t\(word.wordNumber)\t\(word.count)\t\(word.originalSurfaceForm)\t\(parsedSurfaceForm)\t\(analyses)")
                }

            }
        }
        
        /*
        do {
            let encoder = JSONEncoder()
            let encodedSentences = try encoder.encode(parsedSentences)
            let string = String(data: encodedSentences, encoding: String.Encoding.utf8)!
            print(string)
        } catch {
            print("Unable to export data", to: &stderr)
            return
        }
        
        guard let parsedSentences = Qamani.fromJSON(path: "/Users/lanes/work/summer/yupik/qamani/Ch03.json") else {
                   print("Unable to read \(self.sentences)", to: &stderr)
                   return
               }
        */
        
        /*
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
        */
    }
}


Itemquulteki.main()
