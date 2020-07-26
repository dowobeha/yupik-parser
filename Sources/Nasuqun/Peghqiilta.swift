import NgramLM
import Qamani

public struct Peghqiilta {
    
    let analyzedCorpus: Qamani
    let analyses: [MorphologicalAnalyses]
    let orderOfMorphLM: NgramOrder
    let wordLM: WordLM
    
    public init(analyzedCorpus: Qamani, orderOfMorphLM: Int, wordLM: WordLM) {
        self.analyzedCorpus = analyzedCorpus
        self.analyses = self.analyzedCorpus.flatMap({$0.words}).compactMap({$0.analyses})
        self.orderOfMorphLM = orderOfMorphLM
        self.wordLM = wordLM
    }
    
    public func train() {
        let morphCounts = self.collectCounts(using: NaivePosterior(self.analyses), ngramLength: self.orderOfMorphLM)
        let morphLM = self.estimateModel(from: morphCounts)
        for analyses in self.analyses {
            for analysis in analyses.analyses {
                let morphLMProb = morphLM(analysis.underlyingForm, addTags: true)
                let wordLMProb = self.wordLM(analyses.originalSurfaceForm)
                let newMuProb = morphLMProb / wordLMProb
                print("\(analyses.parsedSurfaceForm)\t\(newMuProb)\t\(wordLMProb)\t\(morphLMProb)\t\(analysis.underlyingForm)")
            }
        }
    }
    
    
    
    public func collectCounts(using p_μ: Posterior, ngramLength: Int) -> Counts {

        let lines: [WeightedLine] = self.analyses.flatMap({ (analyses: MorphologicalAnalyses) -> [WeightedLine] in
            let underlyingForms: [MorphologicalAnalysis] = analyses.analyses
            let surfaceForm = analyses.parsedSurfaceForm
            let weightedLines = underlyingForms.map({ (analysis: MorphologicalAnalysis) -> WeightedLine in
                return WeightedLine(line: analysis.underlyingForm, weight: p_μ(analysis.underlyingForm | surfaceForm))
            })
            return weightedLines
        })
        
        return Counts(from: WeightedCorpus(weightedLines: lines), ngramOrder: ngramLength, tokenize: MorphemeTokenize())
 
    }
    
    public func estimateModel(from counts: Counts) -> NgramLM {
        return NgramLM(counts)
    }

}

public struct MorphemeTokenize: Tokenize {
    public func callAsFunction(_ line: Line, addTags: Bool = true) -> Tokens {
        let tokens = line.replacingOccurrences(of: "=", with: "^").split(separator: "^").map{Token($0)}
        if addTags {
            return ["<s>"] + tokens + ["</s>"]
        } else {
            return tokens
        }
    }
}
