import Foma

/// Morphological analyses of a single word
public struct MorphologicalAnalyses {
    
    /// Surface representation that was successfully analyzed
    public let parsedSurfaceForm: String
    
    /// List of morphological analyses of a word
    public let analyses: [MorphologicalAnalysis]
    
    /// Name of morphological analyzer that provided this analysis
    public let parsedBy: String
    
    /**
     Stores a morphological analysis.
     */
    public init(_ analyses: [MorphologicalAnalysis], of surfaceForm: String, parsedBy: String) {
        self.analyses = analyses
        self.parsedSurfaceForm = surfaceForm
        self.parsedBy = parsedBy
    }

}
