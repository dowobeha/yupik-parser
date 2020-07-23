import Foma

/// A morphologically analyzed word in a corpus.
public struct AnalyzedWord {
    
    /// Name of the document where this word is located.
    public let document: String
    
    /// Index of the sentence within the document where this word is located.
    public let sentenceNumber: Int
    
    /// Index of the word within the sentence where this word is located.
    public let wordNumber: Int
    
    /// Orthographic form of the word as it appears in the document.
    public let originalSurfaceForm: String
    
    /// List of morphological analyses of the word
    public let analyses: MorphologicalAnalyses?
    
    public let count: Int
    
    /// Performs morphological analysis of a word in a document, storing the results.
    public init(word: String, atPosition: Int, inSentence: Int, inDocument: String, withAnalyses analyses: MorphologicalAnalyses?) {
        self.originalSurfaceForm = word
        self.wordNumber = atPosition
        self.sentenceNumber = inSentence
        self.document = inDocument
        self.analyses = analyses
        self.count = (self.analyses==nil ? 0 : self.analyses!.analyses.count)
    }
    
}
