import Foma

/// Morphological analysis of a single word
public struct MorphologicalAnalysis: Codable {
    
    public static let startOfWord = "<w>"
    public static let endOfWord = "</w>"
        
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    public let morphemes: [String]
    
    /// List matching intermediate form(s)
    public let intermediateForm: String?
    
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withIntermediateForm intermediateForm: String?, delimiter: String) {
        self.underlyingForm = underlyingForm
        self.morphemes = [MorphologicalAnalysis.startOfWord] + underlyingForm.components(separatedBy: delimiter) + [MorphologicalAnalysis.endOfWord]
        self.intermediateForm = intermediateForm
    }

}
