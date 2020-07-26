import Foma

/// Morphological analyses of a single word
public struct MorphologicalAnalyses {
    
    /// Surface representation that was successfully analyzed
    public let parsedSurfaceForm: String
    
    /// Surface form before any changes (lowercasing, etc)
    public let originalSurfaceForm: String
    
    /// List of morphological analyses of a word
    public let analyses: [MorphologicalAnalysis]
    
    /// Name of morphological analyzer that provided this analysis
    public let parsedBy: String
    
    /**
     Stores a morphological analysis.
     */
    public init(_ analyses: [MorphologicalAnalysis], of surfaceForm: String, originally: String, parsedBy: String) {
        self.analyses = analyses
        self.parsedSurfaceForm = surfaceForm
        self.originalSurfaceForm = originally
        self.parsedBy = parsedBy
    }

    public var count: Int {
        return self.analyses.count
    }
    
}
