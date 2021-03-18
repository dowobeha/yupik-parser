import Foma
import Foundation

/// Morphologically analyzed sentence.
public struct AnalyzedSentence: Sequence, CustomStringConvertible, Codable {

    /// Name of the document where this sentence is located.
    public let document: String

    /// Index of the sentence within the document where this word is located.
    public let lineNumber: Int

    /// Orthographic surface forms of the tokens in the sentence.
    public let tokens: [String]
    
    /// Morphologically analyzed representations of the words in the sentence.
    public let words: [AnalyzedWord]
    
    /// Stores the morphological analysis of each token in a sentence
    public init(words: [AnalyzedWord], withLineNumber lineNumber: Int, inDocument documentID: String) {
        self.tokens = words.map{$0.originalSurfaceForm}
        self.words = words
        self.lineNumber = lineNumber
        self.document = documentID
    }
    
    /// String representation of this sentence.
    public var description: String {
        return "Sentence \(self.lineNumber) of \(self.document)\t\(self.tokens.joined(separator: " "))"
    }
    
    /// Returns an iterator over the morphologically analyzed words in the sentence.
    public func makeIterator() -> IndexingIterator<[AnalyzedWord]> {
        return self.words.makeIterator()
    }

    public func toJson() -> String? {
        
        do {
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            
            let jsonString = String(data: data, encoding: .utf8)!
            
            return jsonString
                
        } catch {
            return nil
        }
        
    }
}
