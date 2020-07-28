import ArgumentParser
import Foundation
import Qamani
import Nasuqun

/// Learn models
struct CommandLineProgram: ParsableCommand {

    @Option(help:     "JSON file containing a morphologically analyzed corpus")
    var corpus: String
    
    @Option(help:     "Tab-separated file with format \"logprob\tword\"")
    var wordLogProbs: String

    @Option(help:    "Character that delimits morpheme boundaries")
    var delimiter: String = "^"

    /// Run learning iterations
    func run() {

        var stderr = FileHandle.standardError
        
        guard let parsedSentences = Qamani.fromJSON(path: self.corpus) else {
            print("Unable to read \(self.corpus)", to: &stderr)
            return
        }
        
        guard let wordProbs = WordLM(from: self.wordLogProbs) else {
            print("Unable to read \(self.wordLogProbs)", to: &stderr)
            return
        }
        
        let learner = Peghqiilta(analyzedCorpus: parsedSentences, orderOfMorphLM: 2, wordLM: wordProbs)
        
        learner.train()
    
    }
}


CommandLineProgram.main()
