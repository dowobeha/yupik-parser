import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

public struct Qamani: Sequence {

    let analyzedSentences: [AnalyzedSentence]
    
    public init(analyzedSentences: [AnalyzedSentence]) {
        self.analyzedSentences = analyzedSentences
    }

    /// Returns an iterator over the morphologically analyzed words in the sentence.
    public func makeIterator() -> IndexingIterator<[AnalyzedSentence]> {
        return self.analyzedSentences.makeIterator()
    }
}
