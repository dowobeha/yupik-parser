import ArgumentParser
import Foundation
import Qamani
import Nasuqun

/**
   Learn models

   > **peghqiilta**
   > *пҳқӣльта*
   > /pəχ.'qiːɬ.tɑ/
   >
   > (intransitive verb, optative mood, 1st person plural subject)
   > let's train
   >
   > (*Badten et al, 2008*)
 */
struct Peghqiilta: ParsableCommand {

//    @Option(help:    "Descriptive name to use for a given pair of FSTs (l2s & l2is)")
//    var name: [String] = []
//    
//    @Option(help:    "Finite-state transducer (lexical underlying form to surface form) in foma binary file format")
//    var l2s: [String] = []
//
//    @Option(help:    "Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format")
//    var l2is: [String] = []

    static var configuration = CommandConfiguration(
            abstract: "Machine learning program for training",
            discussion: """
                    Peghqiilta!
                    Let's train!
                """)
/*
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
    */
    /// Run learning iterations
    func run() {

        let m = MorphologicalAnalysis("qikmigh^[Abs.Sg]", withIntermediateForm: "qikmiq^{0}", delimiter: "^")
  
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(m)
            
            let jsonString = String(data: data, encoding: .utf8)!
            
            print(jsonString)
            
            let jsonData = jsonString.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            
            let m2 = try decoder.decode(MorphologicalAnalysis.self, from: jsonData)
            
            print(m2)
            
        } catch {
            print("Problem")
        }
        
        
       
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
        
    /*
        if let parsedTSV = ParsedTSV(self.tsv),
            let morphLM = SampledMorphLM.sample(from: parsedTSV, lmplz: self.lmplz, arpaPath: self.arpa, query: self.query) {

            for (analysis, prob) in morphLM.probabality {
                print("\(analysis)\t\(prob)")
            }
            
        }
        */
        
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


Peghqiilta.main()
