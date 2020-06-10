import ArgumentParser
import Foma
import StreamReader
import Foundation

struct Parser: ParsableCommand {
    
    @Option(help:    "Finite-state transducer in foma binary file format")
    var fst: String
    
    @Option(help:    "Text file containing one sentence per line")
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
                let lattice = sentence.parse(using: fst)
                for analyses in lattice {
                    if let values: [Analysis] = analyses.values {
                        print("\t\(analyses.surfaceForm)")
                        for analysis in values {
                            print("\t\t\(analysis)")
                        }
                    } else {
                        print("\t\(analyses.surfaceForm)\tANALYSIS FAILED")
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

protocol Morpheme {
    var root: Bool { get }
    var derivational: Bool { get }
    var inflectional: Bool { get }
}

struct Analysis: Sequence, CustomStringConvertible {

    public let morphemes: [String]
    public let description: String

    init(_ analysis: String, delimiter: String.Element) {
        self.description = analysis
        self.morphemes = analysis.split(separator: delimiter).map{String($0)}
    }
    
    func makeIterator() -> IndexingIterator<[String]> {
        return self.morphemes.makeIterator()
    }
}

struct Analyses {

    public let surfaceForm: String
    public let values: [Analysis]?
    
    public init(_ analyses: [Analysis], of surfaceForm: String) {
        self.surfaceForm = surfaceForm
        self.values = analyses
    }
    
    private init(failedSurfaceForm: String) {
        self.surfaceForm = failedSurfaceForm
        self.values = nil
    }
    
    public static func failure(parsingSurfaceForm word: String) -> Analyses {
        return Analyses(failedSurfaceForm: word)
    }

}

extension Sentence {
    
    func parse(using fst: FST, withMorphemeDelimiter morphemeDelimiter: String.Element = "^") -> AnalysisLattice {
        let result: [Analyses] = self.tokens.map { (word: String) -> Analyses in
            if let strings: [String] = fst.applyUp(word) {
                let analyses: [Analysis] = strings.map { Analysis($0, delimiter: morphemeDelimiter) }
                return Analyses(analyses, of: word)
            } else {
                return Analyses.failure(parsingSurfaceForm: word)
            }
        }
        return AnalysisLattice(result)
    }
    
}


struct AnalysisLattice: Sequence {
    
    let analyses: [Analyses]
    
    init(_ analyses: [Analyses]) {
        self.analyses = analyses
    }
 
    func makeIterator() -> IndexingIterator<[Analyses]> {
        return self.analyses.makeIterator()
    }
}
