import Qamani

public struct NaivePosterior : Posterior {
    
//    private let analysesOfWord: [String: MorphologicalAnalyses]
    
    private let parsedWords: ParsedTSV
    
    public init(_ parsedTSV: ParsedTSV) {
        self.parsedWords = parsedTSV
  //      self.analysesOfWord = collection.reduce(into: [String: MorphologicalAnalyses]()) { dict, analyses in
//            dict[analyses.parsedSurfaceForm] = analyses
//        }
    }
    
    public typealias ValueType = String
    public typealias GivenType = String
    
    public func callAsFunction(_ condition: Condition<ValueType, GivenType>) -> Float {
        let analysis: String = condition.value
        let word: String = condition.given
        
        if let parsedWord = self.parsedWords[word], parsedWord.analyses.contains(where: {$0 == analysis}) {
            return 1.0 / Float(parsedWord.analyses.count)
        } else {
            return 0.0
        }
    }
    
}
