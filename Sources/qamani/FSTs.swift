import Foma

struct FSTs {
    
    struct Pair {
        let l2s: FST
        let l2is: FST
    }
    
    let machines: [Pair]

    public init(machines: [Pair]) {
        self.machines = machines
    }
    
    public func analyzeWord(_ surfaceForm: String) -> (String?, [MorphologicalAnalysis]) {
        
        for machine in self.machines {
            if let tuple = self.analyzeWord(surfaceForm, using: machine.l2s, and: machine.l2is) {
                return tuple
            }
        }
        
        return (nil, [])
    }
    
    /**
     Parses the surface form of a word into a list of morphological analyses licensed by the provided finite-state transducers.
     
     - Parameters:
        - surfaceForm: The surface form of the word to be morphologically analyzed
        - using: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the surface forms
        - and: Finite state transducer where the upper side represents the underlying lexical forms of words and the lower side represents the intermediate forms
            
     - Returns: A tuple where the first element is either surface form that was parsed (if parsing was successful) or nil (if parsing failed), and where the second element is the list of morphological analyses licensed by the provided finite-state transducers for that parsed surface form.
    */
    private func analyzeWord(_ surfaceForm: String, using l2s: FST, and l2i: FST) -> (String?, [MorphologicalAnalysis])? {
        var results = [MorphologicalAnalysis]()
        if surfaceForm.starts(with: "John") {
            print(surfaceForm)
        }
        if let applyUpResult = l2s.applyUp(surfaceForm) {
            let parsedSurfaceForm = applyUpResult.input
            let upperForms = applyUpResult.outputs
            for analysis in upperForms {
                
                if let applyDownResult = l2i.applyDown(analysis) {
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: applyDownResult.outputs))
                } else {
                    // We have an analysis, but l2i can't reproduce the surface form
                    results.append(MorphologicalAnalysis(analysis, withSurfaceForm: parsedSurfaceForm, ofPossibleSurfaceForms: []))
                }
            }
            
            return (parsedSurfaceForm, results)
        } else {
            return nil
            //return (nil, results)
        }
    }
    
}
