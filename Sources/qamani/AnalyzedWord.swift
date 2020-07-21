import Foma

/// A morphologically analyzed word in a corpus.
struct AnalyzedWord {
    
    /// Name of the document where this word is located.
    let document: String
    
    /// Index of the sentence within the document where this word is located.
    let sentenceNumber: Int
    
    /// Index of the word within the sentence where this word is located.
    let wordNumber: Int
    
    /// Orthographic form of the word as it appears in the document.
    let originalSurfaceForm: String
    
    /**
     If nil, indicates that the word was not successfully analyzed; otherwise, represents the orthographic variant of the word that was successfully analyzed.
     
     For example, if the morphological analyzer is case-sensitive, the original surface form could be in all-caps, but the actual surface form is in all lowercase.
    */
    let actualSurfaceForm: String?
    
    /// List of morphological analyses of the word
    let analyses: [MorphologicalAnalysis]
    
    /// Performs morphological analysis of a word in a document, storing the results.
    init(parseToken word: String, atPosition: Int, inSentence: Int, inDocument: String, using machines: FSTs) {
        self.originalSurfaceForm = word
        self.wordNumber = atPosition
        self.sentenceNumber = inSentence
        self.document = inDocument
        let tuple = machines.analyzeWord(word)
        self.actualSurfaceForm = tuple.0
        self.analyses = tuple.1
    }
    
}
