import Foma

public struct MorphologicalAnalyzers {

    private let machines: [MorphologicalAnalyzer]

    public init(_ machines: [MorphologicalAnalyzer]) {
        self.machines = machines
    }
    
    public func analyzeWord(_ surfaceForm: String) -> MorphologicalAnalyses? {
        
        for machine in self.machines {
            if let result = machine.analyzeWord(surfaceForm) {
                return result
            }
        }
        
        return nil
    }
    
}
