import Qamani

public struct NaivePosterior : Conditional {
    
    private let analysesOfWord: [String: MorphologicalAnalyses]
    
    public init(_ collection: [MorphologicalAnalyses]) {
        self.analysesOfWord = collection.reduce(into: [String: MorphologicalAnalyses]()) { dict, analyses in
            dict[analyses.parsedSurfaceForm] = analyses
        }
    }
    
    public typealias ValueType = String
    public typealias GivenType = String
    
    public func callAsFunction(_ condition: Condition<ValueType, GivenType>) -> Float {
        let analysis: String = condition.value
        let word: String = condition.given
        
        if let analyses = self.analysesOfWord[word], analyses.analyses.contains(where: {$0.underlyingForm == analysis}) {
            return 1.0 / Float(analyses.count)
        } else {
            return 0.0
        }
    }
    
}
