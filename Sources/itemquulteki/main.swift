import ArgumentParser
import Foundation
import Qamani
import Threading

enum OutputFormat: String, EnumerableFlag {
    case outputJson
    case outputTsv
}

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

    @Flag(help:      "Specify output format as either JSON or TSV")
    var outputFormat: OutputFormat
    
    /// Run morphological analyzer(s) using provided command line arguments.
    func run() {

        var stderr = FileHandle.standardError
        
        guard let itemquulta = Itemquulta(name: self.name, l2s: self.l2s, l2is: self.l2is, delimiter: self.delimiter) else {
            print("Unable to initialize analyzer(s)", to: &stderr)
            return
        }
        
        guard let parsedSentences: AnalyzedCorpus = itemquulta.analyzeFile(self.sentences) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }
        
        
        switch self.outputFormat {
        
        case .outputJson:
            if let jsonString = parsedSentences.toJson() {
                print(jsonString)
            } else {
                print("Unable to convert analyzed corpus to JSON", to: &stderr)
                return
            }
        
        
        case .outputTsv:
            for sentence in parsedSentences {

                for word in sentence {
    
//                    let analyses: String =  word.analyses==nil ? "" : word.analyses!.analyses.map{ $0.morphemes }.joined(separator: "\t")
//                    
//                    if let parsedSurfaceForm: String = word.analyses==nil ? nil : word.analyses!.parsedSurfaceForm {
//                        print("\(sentence.document)\t\(sentence.lineNumber)\t\(word.wordNumber)\t\(word.count)\t\(word.originalSurfaceForm)\t\(parsedSurfaceForm)\t\(analyses)")
//                    }

                }
            }
        
        }
        
        
    
    }
}


Itemquulteki.main()
