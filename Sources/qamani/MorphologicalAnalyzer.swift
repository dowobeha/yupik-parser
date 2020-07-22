import Foma

public struct MorphologicalAnalyzer {

    public let name: String
    private let l2s: FST
    private let l2is: FST

    public init(name: String, l2s: FST, l2is: FST) {
        self.name = name
        self.l2s = l2s
        self.l2is = l2is
    }
    
    /**
     Parses the surface form of a word into a list of morphological analyses licensed by the provided finite-state transducers.
     
     - Parameters:
        - surfaceForm: The surface form of the word to be morphologically analyzed
        - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
        - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
            
     - Returns: A list of analyses, or nil if the analysis failed
    */
    public func analyzeWord(_ surfaceForm: String) -> MorphologicalAnalyses? {
        
        var analyses = [MorphologicalAnalysis]()

        if let applyUpResult = self.l2s.applyUp(surfaceForm, lowercaseBackoff: true, removePunctBackoff: false) {
            let parsedSurfaceForm = applyUpResult.input
            let upperForms = applyUpResult.outputs
            for analysis in upperForms {
                
                if let applyDownResult = self.l2is.applyDown(analysis) {
                    analyses.append(MorphologicalAnalysis(analysis,
                                                          withPossibleSurfaceForms: applyDownResult.outputs))
                } else {
                    // We have an analysis, but l2i can't reproduce the surface form
                    analyses.append(MorphologicalAnalysis(analysis,
                                                          withPossibleSurfaceForms: []))
                }
            }
            
            return MorphologicalAnalyses(analyses, of: parsedSurfaceForm, parsedBy: self.name)

        } else {

            return nil
            
        }
    }
    
}

