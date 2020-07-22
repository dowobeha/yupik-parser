import Foma

/// Morphological analysis of a single word
public struct MorphologicalAnalysis {
    
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    /// List matching intermediate form(s)
    public let intermediateForm: String?
        
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withIntermediateForm intermediateForm: String?) {
        self.underlyingForm = underlyingForm
        self.intermediateForm = intermediateForm
    }

}
