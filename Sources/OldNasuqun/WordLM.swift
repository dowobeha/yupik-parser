import StreamReader
import Foundation

public struct WordLM {
    
    let probabilities: [String: Float]
    
    public init?(from filename: String) {
        var probabilities = [String: Float]()
        if let lines = StreamReader(path: filename) {
            let nonBlankLines = lines.filter{!($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)}
            for line in nonBlankLines {
                let tokens = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: "\t").map{String($0)}
                if let logprobString = tokens.first, let word = tokens.last, let logprob = Float(logprobString) {
                    let prob = pow(10.0, logprob)
                    probabilities[word] = prob
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
        self.probabilities = probabilities
    }
    
    public func callAsFunction(_ word: String) -> Float {
        if let prob = self.probabilities[word] {
            return prob
        } else {
            return 0.0
        }
    }
}
