import Foma

/// Morphological analysis of a single word
public struct MorphologicalAnalysis {
    
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    /// List of all orthographic variants of this word that are consistent with the underlying form.
    public let possibleSurfaceForms: [String]
        
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withPossibleSurfaceForms possibleForms: [String]) {
        self.underlyingForm = underlyingForm
        self.possibleSurfaceForms = possibleForms
    }

}
