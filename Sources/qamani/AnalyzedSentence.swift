import Foma
import Foundation

/// Morphologically analyzed sentence.
public struct AnalyzedSentence: Sequence, CustomStringConvertible {

    /// Name of the document where this sentence is located.
    public let document: String

    /// Index of the sentence within the document where this word is located.
    public let lineNumber: Int

    /// Orthographic surface forms of the tokens in the sentence.
    public let tokens: [String]
    
    /// Morphologically analyzed representations of the words in the sentence.
    public let words: [AnalyzedWord]
    
    /// Performs morphological analysis of each token in the sentence, storing the results.
    public init(_ tokens: String, lineNumber: Int, inDocument documentID: String, using machines: MorphologicalAnalyzers) {
        self.tokens = tokens.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ").map{String($0)}
        self.words = self.tokens.enumerated().map{ enumeratedToken -> AnalyzedWord in
            let token = enumeratedToken.element
            let position = enumeratedToken.offset+1
            return AnalyzedWord(parseToken: token, atPosition: position, inSentence: lineNumber, inDocument: documentID, using: machines)
        }
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
}
