import Foma

/// Morphological analysis of a single word
public struct MorphologicalAnalysis: Codable {
          
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    public let morphemes: String //[String]
    
    /// List matching intermediate form(s)
    public let intermediateForm: String?
    
    public let delimiter: String
    
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withIntermediateForm intermediateForm: String?, delimiter: String) {
        self.underlyingForm = underlyingForm
        self.morphemes = underlyingForm.replacingOccurrences(of: "=", with: delimiter).replacingOccurrences(of: delimiter, with: " ")
        self.intermediateForm = intermediateForm
        self.delimiter = delimiter
    }

}
