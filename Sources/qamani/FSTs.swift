/*
import Foma

struct FSTs {
    
    struct Pair {
        let name: String
        let l2s: FST
        let l2is: FST
    }
    
    let machines: [Pair]

    public init(machines: [Pair]) {
        self.machines = machines
    }
    
    struct Result {
        let parsedSurfaceForm: String?
        let analyses: [MorphologicalAnalysis]
        let providedBy: String?
    }
    
    public func analyzeWord(_ surfaceForm: String) -> FSTs.Result {
        
        for machine in self.machines {
            if let result = self.analyzeWord(surfaceForm, using: machine) {
                return result
            }
        }
        
        return Result(parsedSurfaceForm: nil, analyses: [], providedBy: nil)
    }
    
    /**
     Parses the surface form of a word into a list of morphological analyses licensed by the provided finite-state transducers.
     
     - Parameters:
        - surfaceForm: The surface form of the word to be morphologically analyzed
        - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
        - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
            
     - Returns: A tuple where the first element is either surface form that was parsed (if parsing was successful) or nil (if parsing failed), and where the second element is the list of morphological analyses licensed by the provided finite-state transducers for that parsed surface form.
    */
    private func analyzeWord(_ surfaceForm: String, using machine: FSTs.Pair) -> FSTs.Result? {
        var results = [MorphologicalAnalysis]()

        if let applyUpResult = machine.l2s.applyUp(surfaceForm, lowercaseBackoff: true, removePunctBackoff: false) {
            let parsedSurfaceForm = applyUpResult.input
            let upperForms = applyUpResult.outputs
            for analysis in upperForms {
                
                if let applyDownResult = machine.l2is.applyDown(analysis) {
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: applyDownResult.outputs))
                } else {
                    // We have an analysis, but l2i can't reproduce the surface form
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: []))
                }
            }
            
            return Result(parsedSurfaceForm: parsedSurfaceForm, analyses: results, providedBy: machine.name)
        } else {
            return nil
            //return (nil, results)
        }
    }
    
}
*/
