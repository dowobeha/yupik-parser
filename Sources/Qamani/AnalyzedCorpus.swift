import Dispatch
import Foma
import Foundation
import StreamReader
import Threading

public struct AnalyzedCorpus: Sequence, Codable {

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
    
    public static func fromJSON(path: String) -> AnalyzedCorpus? {
        if let lineReader = StreamReader(path: path) {
            let lines = Array<String>(lineReader)
            let jsonString = lines.joined(separator: "\n")
            
            do {
                if let data = jsonString.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let qamani = try decoder.decode(AnalyzedCorpus.self, from: data)
                    return qamani
                } else {
                    print("Unable to access data from jsonString", to: &stderr)
                    return nil
                }
            } catch {
                print("ERROR:\tThe JSON data in \(path) does not conform to the expected data format.\n\n\(error)", to: &stderr)
                return nil
            }
        } else {
            return nil
        }
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
