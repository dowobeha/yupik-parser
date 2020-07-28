import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

public struct Qamani: Sequence, Codable {

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
    
    public static func fromJSON(path: String) -> Qamani? {
        if let lineReader = StreamReader(path: path) {
            let lines = Array<String>(lineReader)
            let jsonString = lines.joined(separator: "")
            do {
                let data = jsonString.data(using: .utf8)!
                let decoder = JSONDecoder()
                let qamani = try decoder.decode(Qamani.self, from: data)
                return qamani
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
