import Qamani

public struct Peghqiilta {
    
    let analyzedCorpus: Qamani
    
    public let startOfWord = "<w>"
    public let endOfWord = "</w>"
    
    public init(analyzedCorpus: Qamani) {
        self.analyzedCorpus = analyzedCorpus
    }
    
    public func train() {
       return
    }
        
    public func collectCounts(using p_μ: Posterior, ngramLength: Int) -> Counts {
        
        typealias NgramContext = String
        typealias NgramFinalMorpheme = String
        
        // Initialize empty dictionary of n-gram counts
        var countDictionary = [NgramContext: [NgramFinalMorpheme: Float]]()
        
        for analyses in self.analyzedCorpus.flatMap({$0.words}).compactMap({$0.analyses}) {
            let word = analyses.parsedSurfaceForm
            for analysis in analyses.analyses {
                if analysis.morphemes.count >= ngramLength {
                    for contextStart in 0...(analysis.morphemes.count - ngramLength) {
                        let contextEnd = contextStart + ngramLength - 1
                        
                        // Create a morpheme-delimited string representing the n-gram context
                        let context: NgramContext = (analysis.morphemes[contextStart...contextEnd]).joined(separator: analyzedCorpus.morphemeDelimiter)
                        
                        // Get the final morpheme in the n-gram
                        let finalMorpheme: NgramFinalMorpheme = analysis.morphemes[contextEnd+1]
                        
                        // Set count( finalMorpheme | context ) += p_μ(analysis.underlyingForm | word) :
                        // ------------------------------------------------------------------------------
                        // 1) Access the inner dictionary representing all counts with this context
                        var completionCounts: [NgramFinalMorpheme: Float] = countDictionary[context, default: [NgramFinalMorpheme: Float]()]
                        //
                        // 2) Get the current value of the inner dictionary for the finalMorpheme
                        let previousCount: Float = completionCounts[finalMorpheme, default: 0.0]
                        //
                        // 3) Calculate the new count by adding a fractional count based on the current estimate of the posterior
                        let newCount: Float = previousCount + p_μ(analysis.underlyingForm | word)
                        //
                        // 4) Insert the new count into the inner dictionary
                        completionCounts.updateValue(newCount, forKey: finalMorpheme)
                        //
                        // 5) Insert the updated inner dictionary into the outer dictionary
                        countDictionary.updateValue(completionCounts, forKey: context)
                        
                    }
                }
            }
        }
        return Counts(countDictionary)
 
    }
    
    public func estimatePrior(from counts: Counts) -> Void {
        
    }

}
