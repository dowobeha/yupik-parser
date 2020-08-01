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
    
    public func sample(times t: Int = 1, posterior p: Posterior? = nil) -> SampledMorphLM {
        let morphLM = SampledMorphLM()
        
        let posterior = (p==nil) ? NaivePosterior(self) : p!
        let out: FileHandle = morphLM.inputPipe.fileHandleForWriting
        
        defer {
            out.closeFile()
            morphLM.group.wait()
        }
        
        for analyzedWord in self.data.values {
            
            let word = analyzedWord.word
            
            // Sample once for each instance of this word in the corpus
            for _ in 0..<analyzedWord.count {
            
                // Sample as many times as the user said to
                for _ in 0..<t {
                    
                    let r = Float.random(in: 0.0..<1.0)
                    var sum = Float(0.0)
                    
                    for analysis in analyzedWord.analyses {
                        sum += posterior(analysis | word)
                        if r < sum {
                            out.write(analysis + "\n")
                            //print(analysis)
                            break
                        }
                    }
                }
            }
            
        }
        
        
        return morphLM
    }
    
}
