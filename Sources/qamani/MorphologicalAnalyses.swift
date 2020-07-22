import Foma

/// Morphological analyses of a single word
struct MorphologicalAnalyses {
    
    /// Orthographic representation of a word that was successfully morphologically parsed.
    let actualSurfaceForm: String
    
    let parsedSurfaceForm: String
    
    /// List of morphological analyses of a word
    let analyses: [MorphologicalAnalysis]
    
    /// Name of morphological analyzer that provided this analysis
    let parsedBy: String
    
    /**
     Stores a morphological analysis.
     */
    init(_ analyses: [MorphologicalAnalysis], of surfaceForm: String, parsedAs parsedSurfaceForm: String, by: String) {
        self.analyses = analyses
        self.actualSurfaceForm = surfaceForm
        self.parsedSurfaceForm = parsedSurfaceForm
        self.parsedBy = by
    }

}
