import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

public struct Qamani: Sequence {

    public let analyzedSentences: [AnalyzedSentence]
    public let morphemeDelimiter: String
    
    public init(analyzedSentences: [AnalyzedSentence], morphemeDelimiter: String) {
        self.analyzedSentences = analyzedSentences
        self.morphemeDelimiter = morphemeDelimiter
    }

    /// Returns an iterator over the morphologically analyzed words in the sentence.
    public func makeIterator() -> IndexingIterator<[AnalyzedSentence]> {
        return self.analyzedSentences.makeIterator()
    }
}
