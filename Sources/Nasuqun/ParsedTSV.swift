import Foundation
import StreamReader

public struct ParsedTSV {

    public typealias Analysis = String
    public typealias Word = String
    public typealias Count = Int
    
    public struct AnalyzedWord {
        let count: Count
        let word: Word
        let analyses: [Analysis]
        
        public init(_ line: String) {
            let parts = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: "\t")
            self.count = Count(String(parts[0]))!
            self.word = Word(parts[1])
            self.analyses = parts[2...].map({Analysis($0)})
        }
    }
    
    public let data: [Word: AnalyzedWord]
    
    public init?(_ filename: String) {
        if let lines = StreamReader(path: filename) {
            self.data = lines.reduce(into: [Word: AnalyzedWord]()) { (dict: inout [Word: AnalyzedWord], line: String) -> Void in
                let entry = AnalyzedWord(line)
                dict[entry.word] = entry
            }
        } else {
            return nil
        }
    }
    
    public subscript(word: Word) -> AnalyzedWord? {
        get {
            if let analyzedWord = self.data[word] {
                return analyzedWord
            } else {
                return nil
            }
        }
    }
    
}
