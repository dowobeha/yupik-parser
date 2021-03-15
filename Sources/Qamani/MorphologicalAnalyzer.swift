import Foma
import Foundation

public struct MorphologicalAnalyzer {

    public let name: String
    private let l2s: FST
    private let l2is: FST
    private let delimiter: String
    private let nullMorpheme: String
    
    //private let semaphore: DispatchSemaphore

    public init(name: String, l2s: FST, l2is: FST, delimiter: String, nullMorpheme: String = "{0}") {
        self.name = name
        self.l2s = l2s
        self.l2is = l2is
        self.delimiter = delimiter
        self.nullMorpheme = nullMorpheme
        //self.semaphore = DispatchSemaphore(value: 1)
    }
    
    /**
     Parses the surface form of a word into a list of morphological analyses licensed by the provided finite-state transducers.
     
     - Parameters:
        - surfaceForm: The surface form of the word to be morphologically analyzed
        - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
        - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
            
     - Returns: A list of analyses, or nil if the analysis failed
    */
    public func analyzeWord(_ surfaceForm: String) -> MorphologicalAnalyses? {
        //print("Waiting for \(self.name) to analyze \"\(surfaceForm)\"")
        //self.semaphore.wait()
        //print("\(self.name) will now analyze \"\(surfaceForm)\"")
        //print("MorphologicalAnalyzer.analyzeWord 1:\t\"\(surfaceForm)\"", to: &stderr)
        var analyses = [MorphologicalAnalysis]()

        // In principle, this shouldn't be necessary, but doing this appears to prevent a bizarre bug on Linux
        let _ = self.l2s.applyUp("", lowercaseBackoff: true, removePunctBackoff: false)
        
        if let applyUpResult = self.l2s.applyUp(surfaceForm, lowercaseBackoff: true, removePunctBackoff: false) {
            let parsedSurfaceForm = applyUpResult.input
            let upperForms = applyUpResult.outputs
            //print("MorphologicalAnalyzer.analyzeWord 2:\t\"\(surfaceForm)\"\t\"\(parsedSurfaceForm)\"\t\"\(upperForms.count)\"", to: &stderr)
            for analysis in upperForms {
                //print("MorphologicalAnalyzer.analyzeWord 3:\t\"\(surfaceForm)\"\t\"\(parsedSurfaceForm)\"\t\"\(analysis)\"\t\(upperForms.count)", to: &stderr)
                if let applyDownResult = self.l2is.applyDown(analysis),
                    let matchingIntermediteForm = applyDownResult.outputs.filter({$0.replacingOccurrences(of: self.delimiter, with: "").replacingOccurrences(of: self.nullMorpheme, with: "") == parsedSurfaceForm}).first {
                                   
                    //print("MorphologicalAnalyzer.analyzeWord 4a:\t\"\(surfaceForm)\"\t\"\(parsedSurfaceForm)\"\t\"\(upperForms.count)\"\t\"\(matchingIntermediteForm)\"", to: &stderr)
                    analyses.append(MorphologicalAnalysis(analysis,
                                                          withIntermediateForm: matchingIntermediteForm,
                                                          delimiter: self.delimiter))
                } else {
                    //print("MorphologicalAnalyzer.analyzeWord 4b:\t\"\(surfaceForm)\"\t\"\(parsedSurfaceForm)\"\t\"\(upperForms.count)\"\t\"nil\"", to: &stderr)
                    // We have an analysis, but l2i can't reproduce the surface form
                    analyses.append(MorphologicalAnalysis(analysis,
                                                          withIntermediateForm: nil,
                                                          delimiter: self.delimiter))
                }
            }
            
            //print("MorphologicalAnalyzer.analyzeWord 5:\t\"\(surfaceForm)\"\t\"\(parsedSurfaceForm)\"\t\"\(analyses.count)\"\t\"\(analyses.first!)\"", to: &stderr)
            //print("\(self.name) is done analyzing \"\(surfaceForm)\"")
            //self.semaphore.signal()
            return MorphologicalAnalyses(analyses, of: parsedSurfaceForm, originally: surfaceForm, parsedBy: self.name)

        } else {

            //print("MorphologicalAnalyzer.analyzeWord nil", to: &stderr)
            //print("\(self.name) failed to analyze \"\(surfaceForm)\"")
            //self.semaphore.signal()
            return nil
            
        }
    }
    
}

