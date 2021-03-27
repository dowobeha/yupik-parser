import Foundation
import StreamReader

public struct ParsedTSV {

    public typealias Analysis = String
    public typealias Word = String
    public typealias Count = Int
    
    public typealias CorpusName = String
    public typealias SentenceInCorpus = Int
    public typealias WordInSentence = Int
    
    public struct AnalyzedWord {
        
        let corpus: CorpusName
        let sentenceNumber: SentenceInCorpus
        let wordNumber: WordInSentence
        
        let count: Count
        let originalWord: Word
        let analyzedWord: Word
        let analyses: [Analysis]
        
        public init(_ line: String) {
            
            let field = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: "\t")
            
            self.corpus = String(field[0])
            self.sentenceNumber = SentenceInCorpus(field[1])!
            self.wordNumber = WordInSentence(field[2])!
            
            self.count = Count(String(field[3]))!
            
            self.originalWord = Word(field[4])
            self.analyzedWord = Word(field[5])
            
            self.analyses = field[6...].map({Analysis($0)})
            
            // self.count = Count(String(parts[0]))!
            // self.word = Word(parts[1])
            // self.analyses = parts[2...].map({Analysis($0)})
        }
    }
    
    public let data: [Word: AnalyzedWord]
    
    public init?(_ filename: String) {
        if let lines = StreamReader(path: filename) {
            self.data = lines.reduce(into: [Word: AnalyzedWord]()) { (dict: inout [Word: AnalyzedWord], line: String) -> Void in
                let entry = AnalyzedWord(line)
                dict[entry.analyzedWord] = entry
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
