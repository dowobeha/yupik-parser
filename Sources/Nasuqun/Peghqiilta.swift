import Foundation
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
        var stderr = FileHandle.standardError
        print("\(getTimeAsString())\tCollecting counts...", to: &stderr)
        let morphCounts = self.collectCounts(using: NaivePosterior(self.analyses), ngramLength: self.orderOfMorphLM)
        
        print("\(getTimeAsString())\tEstimating model...", to: &stderr)
        let morphLM = self.estimateModel(from: morphCounts)
        
        struct Probs {
            let morphLM: Weight
            let wordLM: Weight
            let wordGivenAnalysis: Weight
            let analysisGivenWord: Weight
        }
        
        print("\(getTimeAsString())\tProcessing analyses...", to: &stderr)
        for analyses in Progress(self.analyses) {
            
            // For each analysis, calculate unnormalized P(analysis|word) = P(word | analysis) * P(analysis) / P(word), where P(word | analysis) is assumed to be 1.0
            let scores: [Probs] = analyses.analyses.map{ (analysis: MorphologicalAnalysis) -> Probs in
                
                // P(analysis)
                let morphLMProb = morphLM(analysis.underlyingForm, addTags: true)
                
                // P(word)
                let wordLMProb = self.wordLM(analyses.originalSurfaceForm)
                
                // We make the simplifying assumption that P(word | analysis) = 1.0
                let wordGivenAnalysis = Weight(1.0)
                
                // Calculate unnormalized P(analysis|word) = P(word | analysis) * P(analysis) / P(word)
                let unnormalizedAnalysisGivenWord = morphLMProb * wordGivenAnalysis / wordLMProb
                
                return Probs(morphLM: morphLMProb,
                             wordLM: wordLMProb,
                             wordGivenAnalysis: wordGivenAnalysis,
                             analysisGivenWord: unnormalizedAnalysisGivenWord)
            }
            
            // Calculate ∑_{a in analyses} unnormalized P(a | word)
            let denominator = scores.map{$0.analysisGivenWord}.reduce(0.0, +)
            
            // Calculate normalized P(analysis|word) = unnormalized P(analysis|word) /  ∑_{a in analyses} unnormalized P(a | word)
            let normalizedScores = scores.map{ (p: Probs) -> Probs in
                return Probs(morphLM: p.morphLM,
                             wordLM: p.wordLM,
                             wordGivenAnalysis: p.wordGivenAnalysis,
                             analysisGivenWord: p.analysisGivenWord / denominator)
            }
            
            // Print results
            for (analysis, p) in zip(analyses.analyses, normalizedScores) {
                print("\(analyses.parsedSurfaceForm)\t\(p.analysisGivenWord)\t\(p.wordLM)\t\(p.morphLM)\t\(analysis.underlyingForm)")
            }
        }
        
        print("\(getTimeAsString())\tDone")
    }
    
    
    
    public func collectCounts(using p_μ: Posterior, ngramLength: Int) -> Counts {

        let result = ThreadedArray<WeightedLine>()
        
        var progressBar = ProgressBar(count: self.analyses.count)
        let progressSemaphore = DispatchSemaphore(value: 0)
        
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        for analyses in self.analyses {
            queue.async(group: group) {
                
                let underlyingForms: [MorphologicalAnalysis] = analyses.analyses
                let surfaceForm = analyses.parsedSurfaceForm
                let weightedLines = underlyingForms.map({ (analysis: MorphologicalAnalysis) -> WeightedLine in
                    return WeightedLine(line: analysis.underlyingForm, weight: p_μ(analysis.underlyingForm | surfaceForm))
                })
                
                result.append(contentsOf: weightedLines)
                progressSemaphore.signal()
            }
        }
        
        for _ in 0..<self.analyses.count {
            progressSemaphore.wait()
            progressBar.next()
        }
        
        group.wait()
        
        return Counts(from: WeightedCorpus(weightedLines: Array(result)), ngramOrder: ngramLength, tokenize: MorphemeTokenize())
        
        // Threaded code above
        // -------------------
        // Old code below
        /*
        let lines: [WeightedLine] = self.analyses.flatMap({ (analyses: MorphologicalAnalyses) -> [WeightedLine] in
            let underlyingForms: [MorphologicalAnalysis] = analyses.analyses
            let surfaceForm = analyses.parsedSurfaceForm
            let weightedLines = underlyingForms.map({ (analysis: MorphologicalAnalysis) -> WeightedLine in
                return WeightedLine(line: analysis.underlyingForm, weight: p_μ(analysis.underlyingForm | surfaceForm))
            })
            return weightedLines
        })
        
        return Counts(from: WeightedCorpus(weightedLines: lines), ngramOrder: ngramLength, tokenize: MorphemeTokenize())
 */
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
