import ArgumentParser
import Foundation
import Qamani
import Nasuqun

/// Learn models
struct CommandLineProgram: ParsableCommand {

//    @Option(help:    "Descriptive name to use for a given pair of FSTs (l2s & l2is)")
//    var name: [String] = []
//    
//    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
//    var l2s: [String] = []
//
//    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
//    var l2is: [String] = []

    @Option(help:     "Tab-separated file with format \"logprob\tword\"")
    var wordLogProbs: String
    
    @Option(help:    "TSV file")
    var tsv: String

    @Option(help:    "Character that delimits morpheme boundaries")
    var delimiter: String = "^"

    @Option(help:    "Path to lmplz")
    var lmplz: String
    
    @Option(help:    "Path to query")
    var query: String
    
    @Option(help: "Path where ARPA file will be created")
    var arpa: String
    
    /// Run learning iterations
    func run() {

        
/*
        print("Loading LMs...", to: &stderr)
        guard let itemquulta = Itemquulta(name: self.name, l2s: self.l2s, l2is: self.l2is, delimiter: self.delimiter) else {
            return
        }
        
        print("Reading and analyzing sentences...", to: &stderr)
        guard let parsedSentences = itemquulta.analyzeFile(self.sentences) else {
            print("Unable to read \(self.sentences)", to: &stderr)
            return
        }
        */
//        print("Reading wordLM from file...", to: &stderr)
//        guard let wordProbs = WordLM(from: self.wordLogProbs) else {
//            print("Unable to read \(self.wordLogProbs)", to: &stderr)
//            return
//        }
        
        //let m = SampledMorphLM("foo", n: 5, p: NaivePosterior())
        //let _ = SampledMorphLM()
        
        if let parsedTSV = ParsedTSV(self.tsv) {
            let _ = parsedTSV.sample(lmplz: self.lmplz, arpaPath: self.arpa, query: self.query)
        }
        
        
        /*
        let learner = Peghqiilta(analyzedCorpus: parsedSentences, orderOfMorphLM: 2, wordLM: wordProbs)
        
        learner.sampleMorphologicalAnalyses(using: NaivePosterior(learner.analyses), times: 100, createCorpus: "/nas/models/experiment/qamani.experiment/corpus.tmp", createLM: "/nas/models/experiment/qamani.experiment/lm.tmp")
        */
        
        
        /*
        print("EM iteration 1 using naive posterior...", to: &stderr)
        var updatedModel = learner.train(iteration: 1, posterior: NaivePosterior(learner.analyses))
    
        for i in 2..<30 {
            print("EM iteration \(i)...", to: &stderr)
            updatedModel = learner.train(iteration: i, posterior: updatedModel)
        }
 */
    }
}


CommandLineProgram.main()
