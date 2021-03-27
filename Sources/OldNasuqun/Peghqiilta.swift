import Foundation
import NgramLM
import Qamani
import Threading

public struct Peghqiilta {
      
    let analyzedCorpus: AnalyzedCorpus
    public let analyses: [MorphologicalAnalyses]
    let orderOfMorphLM: NgramOrder
    let wordLM: WordLM
    
    public init(analyzedCorpus: AnalyzedCorpus, orderOfMorphLM: Int, wordLM: WordLM) {
        self.analyzedCorpus = analyzedCorpus
        self.analyses = self.analyzedCorpus.flatMap({$0.words}).compactMap({$0.analyses})
        self.orderOfMorphLM = orderOfMorphLM
        self.wordLM = wordLM
    }
    
    public func train(iteration: Int, posterior: Posterior) -> Posterior {
        var stderr = FileHandle.standardError
        print("Iteration \(iteration)\t\(getTimeAsString())\tCollecting counts...", to: &stderr)
        let morphCounts = self.collectCounts(using: posterior, ngramLength: self.orderOfMorphLM)
        
        print("Iteration \(iteration)\t\(getTimeAsString())\tEstimating model...", to: &stderr)
        let morphLM = self.estimateModel(from: morphCounts)
        
        struct Probs {
            let morphLM: Weight
            let wordLM: Weight
            let wordGivenAnalysis: Weight
            let analysisGivenWord: Weight
        }
        
        typealias ValueType = String
        typealias GivenType = String
        var result = [GivenType: [ValueType: Weight]]()
        
        print("Iteration \(iteration)\t\(getTimeAsString())\tProcessing analyses...", to: &stderr)
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
            
            var valuesDict = [ValueType: Weight]()
            // Print results
            for (analysis, p) in zip(analyses.analyses, normalizedScores) {
                valuesDict[analysis.underlyingForm] = p.analysisGivenWord
                print("Iteration \(iteration)\t\(analyses.parsedSurfaceForm)\t\(p.analysisGivenWord)\t\(p.wordLM)\t\(p.morphLM)\t\(analysis.underlyingForm)")
            }
            
            result[analyses.parsedSurfaceForm] = valuesDict
        }
        
        print("Iteration \(iteration)\t\(getTimeAsString())\tComplete", to: &stderr)
        return PosteriorDistribution(result)
    }
    
    public func sampleMorphologicalAnalyses(using p_μ: Posterior, times: Int, createCorpus corpusPath: String, createLM lmPath: String) -> String? {
        var stderr = FileHandle.standardError
        FileManager.default.createFile(atPath: corpusPath, contents: nil, attributes: nil)
        if var corpus = FileHandle(forWritingAtPath: corpusPath) {
            let weightedCorpus = self.analyses.map{WeightedAnalyses($0, weightedBy: p_μ)}
            for _ in 0..<times {
                for weightedAnalyses in weightedCorpus {
//                    corpus.write(weightedAnalyses.sample().data(using: .utf8)!)
                    print(weightedAnalyses.sample().replacingOccurrences(of: "^", with: " ").replacingOccurrences(of: "=", with: " "), to: &corpus)
                }
            }
            return nil
        } else {
            print("ERROR", to: &stderr)
            return nil
        }
    }
    /*
    public func generateMorphLM() -> Void {
        /usr/local/bin/foma
    }
    */
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
