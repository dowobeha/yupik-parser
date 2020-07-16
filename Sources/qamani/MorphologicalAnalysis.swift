import Foma

/// Morphological analysis of a single word
struct MorphologicalAnalysis {
    
    /// Orthographic representation of a word that was successfully morphologically parsed.
    let actualSurfaceForm: String
    
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    let underlyingForm: String
    
    /// List of all orthographic variants of this word that are consistent with the underlying form.
    let possibleSurfaceForms: [String]
    
    /**
     Stores a morphological analysis.
     */
    init(_ underlyingForm: String, withSurfaceForm surfaceForm: String, ofPossibleSurfaceForms possibleForms: [String]) {
        self.underlyingForm = underlyingForm
        self.actualSurfaceForm = surfaceForm
        self.possibleSurfaceForms = possibleForms
    }
    
    /**
     Parses the surface form of a word into a list of morphological analyses licensed by the provided finite-state transducers.
     
     - Parameters:
        - surfaceForm: The surface form of the word to be morphologically analyzed
        - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
        - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
            
     - Returns: A tuple where the first element is either surface form that was parsed (if parsing was successful) or nil (if parsing failed), and where the second element is the list of morphological analyses licensed by the provided finite-state transducers for that parsed surface form.
    */
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
