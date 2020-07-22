import Foma

/// Morphological analyses of a single word
struct MorphologicalAnalyses {
    
    /// Surface representation that was successfully analyzed
    let parsedSurfaceForm: String
    
    /// List of morphological analyses of a word
    let analyses: [MorphologicalAnalysis]
    
    /// Name of morphological analyzer that provided this analysis
    let parsedBy: String
    
    /**
     Stores a morphological analysis.
     */
    init(_ analyses: [MorphologicalAnalysis], of surfaceForm: String, parsedBy: String) {
        self.analyses = analyses
        self.parsedSurfaceForm = surfaceForm
        self.parsedBy = parsedBy
    }

}
