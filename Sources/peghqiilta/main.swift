import ArgumentParser
import Foundation
import Qamani
import Nasuqun

/// Morphological analyzer capable of analyzing each word in each sentence of a provided text file.
struct CommandLineProgram: ParsableCommand {
    
    @Option(help:    "Descriptive name to use for a given pair of FSTs (l2s & l2is)")
    var name: [String] = []
    
    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
    var l2s: [String] = []

    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
    var l2is: [String] = []

    @Option(help:     "Tab-separated file with format \"logprob\tword\"")
    var wordLogProbs: String
    
    @Option(help:    "Text file containing one sentence per line")
    var sentences: String

    @Option(help:    "Character that delimits morpheme boundaries")
    var delimiter: String = "^"

    
    /// Run morphological analyzer using provided command line arguments.
    func run() {

        var stderr = FileHandle.standardError
        
        guard let itemquulta = Itemquulta(name: self.name, l2s: self.l2s, l2is: self.l2is, delimiter: self.delimiter) else {
            return
        }
        
        guard let parsedSentences = itemquulta.analyzeFile(self.sentences) else {
            print("Unable to read \(self.sentences)", to: &stderr)
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
