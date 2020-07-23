
public struct MorphologicalAnalyzers {

    private let machines: [MorphologicalAnalyzer]

    public init(_ machines: [MorphologicalAnalyzer]) {
        self.machines = machines
    }

    public func analyzeSentence(tokens: [String], lineNumber: Int, inDocument document: String) -> AnalyzedSentence {
        let words = tokens.enumerated().map{ enumeratedToken -> AnalyzedWord in
            let token = enumeratedToken.element
            let position = enumeratedToken.offset+1
            return AnalyzedWord(word: token, atPosition: position, inSentence: lineNumber, inDocument: document, withAnalyses: self.analyzeWord(token))
        }
        return AnalyzedSentence(words: words, withLineNumber: lineNumber, inDocument: document)
    }
    
    public func analyzeWord(_ surfaceForm: String) -> MorphologicalAnalyses? {
        
        for machine in self.machines {
            if let result = machine.analyzeWord(surfaceForm) {
                return result
            }
        }
        
        return nil
    }
    
}
