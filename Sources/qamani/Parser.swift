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
        
        guard let parsedSentences: [Sentence] = Parser.parseFile(self.sentences, using: l2s, and: l2i) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }

        if self.mode == "failures" {
            for sentence in parsedSentences {
                //print(sentence.words.count)
                
                //var seen = Set<String>()
                let paths: Int = sentence.words.reduce(1, { (r:Int, w:Word) -> Int in return r * w.analyses.count})
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
        
        /*
        let x = (sentences.lastIndex(of: "/")!)
        let document = String(sentences[sentences.index(after: x)...])
        
        
        //let result = fst.applyUp("qikmiq")
        //print("Hello, \(result)!")
        
        if let lines = StreamReader(path: self.sentences) {
            let sentences: [Sentence] = lines.enumerated().map{ (tuple) -> Sentence in return Sentence.init(tuple.element, lineNumber: tuple.offset+1, inDocument: document, using: l2s, and: l2i) }
            for sentence in sentences {
                print(sentence, to: &stderr)
                for word in sentence {
                    
                }
                /*
                let lattice = sentence.parse(using: l2s, l2i: l2i)
                for analyses in lattice {
                    if let values: [Analysis] = analyses.values {
                        //print("\t\(analyses.surfaceForm)")
                        for analysis in values {
                          //  print("\t\t\(analysis)")
                        }
                    } else {
                        //print("FAILURE        \t\tWord \(self.wordNumber)\t\(self.sentence)")
                        print("\t\(analyses.surfaceForm)\tANALYSIS FAILED")
                    }
                }
                */
            }
        }
        */
    }
    
    static func parseFile(_ filename: String, using l2s: FST, and l2i: FST) -> [Sentence]? {
        if let lines = StreamReader(path: filename) {
            var document = filename
            if let x = filename.lastIndex(of: "/") {
                document = String(filename[filename.index(after: x)...])
            }
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            return nonBlankLines.enumerated().map{ (tuple) -> Sentence in return Sentence.init(tuple.element, lineNumber: tuple.offset+1, inDocument: document, using: l2s, and: l2i) }
        } else {
            return nil
        }
    }
}

struct Morpheme {
    let underlyingLexicalForm: String
    let surfaceForm: String
}

struct MorphologicalAnalysis {
    
    //let morphemes: [Morpheme]
    let underlyingForm: String
    let actualSurfaceForm: String
    let possibleSurfaceForms: [String]
    
    init(_ underlyingForm: String, withSurfaceForm surfaceForm: String, ofPossibleSurfaceForms possibleForms: [String]) {
//        self.morphemes = morphemes
        self.underlyingForm = underlyingForm
        self.actualSurfaceForm = surfaceForm
        self.possibleSurfaceForms = possibleForms
    }
    
    public static func parseWord(_ surfaceForm: String, using l2s: FST, and l2i: FST) -> (String?, [MorphologicalAnalysis]) {
        var results = [MorphologicalAnalysis]()
        
        if let applyUpResult = l2s.applyUp(surfaceForm) {
            let parsedSurfaceForm = applyUpResult.input
            let upperForms = applyUpResult.outputs
            for analysis in upperForms {
                //let underlyingMorphemes = analysis.split(separator: delimiter).map{String($0)}
                if let applyDownResult = l2i.applyDown(analysis) {
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: applyDownResult.outputs))
                } else {
                    // We have an analysis, but l2i can't reproduce the surface form
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: []))
                }
            }
            
            return (parsedSurfaceForm, results)
        } else {
            return (nil, results)
        }
    }
}

struct Word {
    let wordNumber: Int
    let sentenceNumber: Int
    let document: String
    
    let originalSurfaceForm: String
    let actualSurfaceForm: String?
    
    let analyses: [MorphologicalAnalysis]
    
    init(parseToken word: String, atPosition: Int, inSentence: Int, inDocument: String, using l2s: FST, and l2i: FST) {
        self.originalSurfaceForm = word
        self.wordNumber = atPosition
        self.sentenceNumber = inSentence
        self.document = inDocument
        let tuple = MorphologicalAnalysis.parseWord(word, using: l2s, and: l2i)
        self.actualSurfaceForm = tuple.0
        self.analyses = tuple.1
    }
    
}
    
struct Sentence: Sequence, CustomStringConvertible {
    
    let tokens: [String]
    let document: String
    let lineNumber: Int
    
    let words: [Word]
    
    init(_ tokens: String, lineNumber: Int, inDocument documentID: String, using l2s: FST, and l2i: FST) {
        self.tokens = tokens.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ").map{String($0)}
        self.words = self.tokens.enumerated().map{ enumeratedToken -> Word in
            let token = enumeratedToken.element
            let position = enumeratedToken.offset+1
            return Word(parseToken: token, atPosition: position, inSentence: lineNumber, inDocument: documentID, using: l2s, and: l2i)
        }
        self.lineNumber = lineNumber
        self.document = documentID
    }
    
    var description: String {
        return "Sentence \(self.lineNumber) of \(self.document)\t\(self.tokens.joined(separator: " "))"
    }
    
    func makeIterator() -> IndexingIterator<[Word]> {
        return self.words.makeIterator()
    }
}
/*
protocol Morpheme {
    var root: Bool { get }
    var derivational: Bool { get }
    var inflectional: Bool { get }
}
*/
/*
struct Morpheme {
    let underlyingLexicalForm: String
    let surfaceForm: String
}
*/

/*
enum SurfaceSegmentation {
    case Success(String)
    case ContainsNullMorpheme(String)
    case Nonmatching(String)
    case NonmatchingContainsNull(String)
    indirect case Multiple([SurfaceSegmentation])
    case Failure
}

struct Analysis: Sequence, CustomStringConvertible {

    public let morphemes: [String]
    //public let segments: String?
    //public let description: String
    let sentence: Sentence
    let wordNumber: Int
    let segmentation: SurfaceSegmentation
    
    init(_ analysis: String, surfaceForm: String, delimiter: String.Element, l2i: FST, word wordNumber: Int, ofSentence sentence: Sentence) {
        self.morphemes = analysis.split(separator: delimiter).map{String($0)}
        self.sentence = sentence
        self.wordNumber = wordNumber
        
        self.segmentation = Analysis.segmentSurfaceForm(surfaceForm, analysis: analysis, delimiter: delimiter, using: l2i)
        //self.segments =
        /*
        if let segments = Analysis.segmentSurfaceForm(surfaceForm, analysis: analysis, delimiter: delimiter, using: l2i, withID: sentence.description) {
            self.description = "\(analysis)\t\(segments)"
        } else {
            self.description = "\(analysis)\tnil"
        }*/
    }
        
    public func makeIterator() -> IndexingIterator<[String]> {
        return self.morphemes.makeIterator()
    }
    
    
    public var description: String {
        switch(segmentation) {
            case SurfaceSegmentation.Success(let surfaceSegmentation):
                return "SUCCESS        \t\(surfaceSegmentation)\tWord \(self.wordNumber)\t\(self.sentence)"
            case SurfaceSegmentation.ContainsNullMorpheme(let surfaceSegmentation):
                return "CONTAINS NULL  \t\(surfaceSegmentation)\tWord \(self.wordNumber)\t\(self.sentence)"
            case SurfaceSegmentation.Nonmatching(let surfaceSegmentation):
                return "NONMATCHING    \t\(surfaceSegmentation)\tWord \(self.wordNumber)\t\(self.sentence)"
            case SurfaceSegmentation.NonmatchingContainsNull(let surfaceSegmentation):
                return "NONMATCHINGNULL\t\(surfaceSegmentation)\tWord \(self.wordNumber)\t\(self.sentence)"
            case SurfaceSegmentation.Multiple(let segmentations):
                return "MULTIPLE       \t\(segmentations)\tWord \(self.wordNumber)\t\(self.sentence)"
            case SurfaceSegmentation.Failure:
                return "FAILURE        \t\tWord \(self.wordNumber)\t\(self.sentence)"
        }
    }
    
    static func segmentSurfaceForm(_ surfaceForm: String, analysis: String, delimiter: String.Element, using fst: FST) -> SurfaceSegmentation {
        if let (_, strings) = fst.applyDown(analysis) {
            if strings.count < 1 {
                return SurfaceSegmentation.Failure
            } else {
                let segmentations: [SurfaceSegmentation] = strings.map { (segmentation: String) -> SurfaceSegmentation in
                    
                    var possibleSurfaceForm = segmentation.replacingOccurrences(of: "{0}", with: "")
                    possibleSurfaceForm.removeAll(where: {$0==delimiter})
                    let matchesSurfaceForm = (possibleSurfaceForm.caseInsensitiveCompare(surfaceForm) == ComparisonResult.orderedSame)
                    
                    let containsNullMorpheme = segmentation.contains("\(delimiter)\(delimiter)")
                    
                    if matchesSurfaceForm {
                        if containsNullMorpheme {
                            return SurfaceSegmentation.ContainsNullMorpheme(segmentation)
                        } else {
                            return SurfaceSegmentation.Success(segmentation)
                        }
                    } else {
                        if containsNullMorpheme {
                            return SurfaceSegmentation.NonmatchingContainsNull(segmentation)
                        } else {
                            return SurfaceSegmentation.Nonmatching(segmentation)
                        }
                    }
                }
                
                return SurfaceSegmentation.Multiple(segmentations)
            }
 /*
            if strings.count != 1 &&
                !analysis.starts(with: "Sivuqagh(N)") &&
                !analysis.starts(with: "Sivungagh(N)") &&
                analysis != "negh(V)^–ghte(V→V)^[Cnsq1.Intr]^[4Pl]" &&
                analysis != "ne(N)^–ghte(N→V)^[Cnsq1.Intr]^[4Pl]" &&
                surfaceForm != "apeghtughisteka" &&
                surfaceForm != "nallukaqa" &&
                surfaceForm != "neghegkaawaa" &&
                (surfaceForm != "qulmesiin" && surfaceForm != "aghveliighsiin" && surfaceForm != "angyangllaghyugsiin") &&
                surfaceForm != "sangavek" && surfaceForm != "sangan" && surfaceForm != "sangama" && surfaceForm != "sangami" &&
                surfaceForm != "nekreget" && surfaceForm != "latakaagunga" && surfaceForm != "kaaskaagut" {
                print("WARNING:\t\(id)\t\(surfaceForm)\tapplyDown(\(analysis)) was expected to produce exactly 1 surface form, but produced \(strings.count) instead:\t\(strings)", to: &stderr)
            }
            for string in strings {
                if string.contains("\(delimiter)\(delimiter)") {
                    print("WARNING:\t\(id)\t\(surfaceForm)\tapplyDown(\(analysis)) produced a surface form with adjacent delimiters:\t\(string)", to: &stderr)
                } else {
                    var possibleSurfaceForm = string.replacingOccurrences(of: "{0}", with: "")
                    possibleSurfaceForm.removeAll(where: {$0==delimiter})
                    if possibleSurfaceForm.caseInsensitiveCompare(surfaceForm) == ComparisonResult.orderedSame {
                    //surfaceForm {
                        return string
                        //return possibleSurfaceForm.split(separator: delimiter).map{String($0)}
                    } /*else {
                        print("WARNING:\tp:\t\t\t\"\(possibleSurfaceForm)\"", to: &stderr)
                        print("WARNING:\ts:\t\t\t\"\(surfaceForm)\"", to: &stderr)
                    }*/
                }
            }
            return SurfaceSegmentation.Failure
 */
        } else {
            return SurfaceSegmentation.Failure
        }
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
    
    func parse(using fst: FST, l2i: FST, withMorphemeDelimiter morphemeDelimiter: String.Element = "^") -> AnalysisLattice {
        let result: [Analyses] = self.tokens.enumerated().map { (wordWithIndex) -> Analyses in
            let word = wordWithIndex.element
            let w = 1+wordWithIndex.offset
            if let (surfaceForm, strings) = fst.applyUp(word) {
                let analyses: [Analysis] = strings.map { Analysis($0, surfaceForm: surfaceForm, delimiter: morphemeDelimiter, l2i: l2i, word: w, ofSentence: self) }
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
*/
