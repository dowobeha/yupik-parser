import ArgumentParser
import Foma
import StreamReader
import Foundation

struct Parser: ParsableCommand {
    
    @Option(default: "/Users/lanes/work/summer/yupik/yupik-foma-v2/l2s.fomabin",
            help:    "Finite-state transducer in foma binary file format")
    var fst: String
    
    @Option(default: "/Users/lanes/work/summer/yupik/qamani/jacobson/Ch03.txt",
            help:    "Text file containing one sentence per line")
    var sentences: String
    
    func run() {
        guard let fst = FST(fromBinary: self.fst) else {
            print("Unable to open \(self.fst)", to: &stderr)
            return
        } //FST(fromBinary: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin")

        //let result = fst.applyUp("qikmiq")
        //print("Hello, \(result)!")
        
        if let lines = StreamReader(path: self.sentences) {
            let sentences: [Sentence] = lines.map(Sentence.init)
            for sentence in sentences {
                print(sentence, to: &stderr)
                for word in sentence.tokens {
                    if let analyses = fst.applyUp(word) {
                        print("\t\(word)")
                        for analysis in analyses {
                            print("\t\t\(analysis)")
                        }
                    } else {
                        print("\t\(word)\tANALYSIS FAILED")
                    }
                }
            }
        }
    }
}

struct Sentence: Sequence {
    
    let tokens: [String]
    
    init(_ tokens: String) {
        self.tokens = tokens.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ").map{String($0)}
    }
    
    func makeIterator() -> IndexingIterator<[String]> {
        return self.tokens.makeIterator()
    }
}

struct Morpheme {

}

struct Analysis: Sequence {

    public let morphemes: [String]

    init(_ analysis: String, delimiter: String.Element = "^") {
        self.morphemes = analysis.split(separator: delimiter).map{String($0)}
    }
    
    func makeIterator() -> IndexingIterator<[String]> {
        return self.morphemes.makeIterator()
    }
}

struct Analyses: Sequence {

    public let surfaceForm: String
    public let analyses: [Analysis]
    
    public init(_ analyses: [Analysis], of surfaceForm: String) {
        self.surfaceForm = surfaceForm
        self.analyses = analyses
    }
    
    func makeIterator() -> IndexingIterator<[Analysis]> {
        return self.analyses.makeIterator()
    }
}

/*
struct AnalysisLattice {
    
    let analyses: [[String]]
    
    init(sentence: Sentence, using fst: FST) {
        self.analyses
        fst.applyUp(word)
    }
    
    
}
*/
