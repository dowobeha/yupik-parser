import Foma
import Foundation
/// Morphological analysis of a single word
public struct MorphologicalAnalysis: Codable {
          
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    public let morphemes: [Morpheme] //[String]
    
    /// List matching intermediate form(s)
    public let intermediateForm: String?
    
    public let delimiter: String
    
    public let surfaceMorphemes: [String]
    
    public let underlyingMorphemes: [String]
    
    public let partsOfSpeech: [String]
    
    public let heuristicScore: Int
    
    //public lazy var morphemeList = self.calculateMorphemes()
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withIntermediateForm intermediateForm: String?, delimiter: String) {
        self.underlyingForm = underlyingForm
        //self.morphemes = underlyingForm.replacingOccurrences(of: "=", with: " (Enclitic)").replacingOccurrences(of: delimiter, with: " ")
        self.intermediateForm = intermediateForm
        self.delimiter = delimiter
        //print(underlyingForm)
        if let intermediate =  self.intermediateForm {
            self.surfaceMorphemes = intermediate.components(separatedBy: self.delimiter)
        } else {
            self.surfaceMorphemes = []
        }
 //       self.surfaceMorphemes = self.intermediateForm!.components(separatedBy: self.delimiter)
        self.underlyingMorphemes = underlyingForm.replacingOccurrences(of: "=", with: " (Enclitic)").replacingOccurrences(of: delimiter, with: " ").components(separatedBy: " ")
        self.partsOfSpeech = self.underlyingMorphemes.enumerated().map{ (index: Int, morpheme: String) -> String in
            if morpheme.hasSuffix("(N)") {
                return "N" //"Nbase"
            } else if morpheme.hasSuffix("(V)") {
                return "V" //"Vbase"
            } else if morpheme.hasSuffix("(PTCL)") {
                return "Particle"
            } else if morpheme.hasSuffix("(PUNCT)") {
                return "Punctuation"
            } else if morpheme.hasSuffix("(N→V)") {
                return "N→V" //#"Vbase\Nbase"#
            } else if morpheme.hasSuffix("(V→V)") {
                return "V→V" //#"Vbase\Vbase"#
            } else if morpheme.hasSuffix("(N→N)") {
                return "N→N" //#"Nbase\Nbase"#
            } else if morpheme.hasSuffix("(V→N)") {
                return "V→N" //#"Nbase\Vbase"#
            } else if morpheme.hasPrefix("[Anaphor]") || morpheme.hasSuffix("[Anaphor]")  {
                return "Anaphor"
            } else if morpheme.hasPrefix("[Abs") || morpheme.hasPrefix("[Rel") || morpheme.hasPrefix("[Abl_Mod") {
                return "Ninfl"
            } else if morpheme.hasPrefix("[Opt") && (morpheme.hasSuffix("Sg]") || morpheme.hasSuffix("Pl]")) {
                return "Vinfl"
            } else if morpheme.hasPrefix("[Ind") || morpheme.hasPrefix("[Opt") || morpheme.hasPrefix("[Intrg") {
                return "Vcase"
            } else if morpheme.hasPrefix("[1Sg") || morpheme.hasPrefix("[1Du") || morpheme.hasPrefix("[1Pl") ||
                      morpheme.hasPrefix("[2Sg") || morpheme.hasPrefix("[2Du") || morpheme.hasPrefix("[2Pl") ||
                      morpheme.hasPrefix("[3Sg") || morpheme.hasPrefix("[3Du") || morpheme.hasPrefix("[3Pl") ||
                      morpheme.hasPrefix("[4Sg") || morpheme.hasPrefix("[4Du") || morpheme.hasPrefix("[4Pl") || morpheme.hasPrefix("[_.") {
                return "Vprnm"
            } else if morpheme.hasPrefix("(Enclitic)") {
                return "Clitic"
            }
            return morpheme
        }
        
        // Calculate list of morpheme objects
        var morphemes = [Morpheme]()
        for i in 0..<underlyingMorphemes.count {
            let surfaceMorpheme = self.surfaceMorphemes.count > i ? self.surfaceMorphemes[i] : ""
            let partOfSpeech = self.partsOfSpeech.count > i ? self.partsOfSpeech[i] : ""
            morphemes.append(Morpheme(underlying: self.underlyingMorphemes[i], type: partOfSpeech, surface: surfaceMorpheme))
        }
        self.morphemes = morphemes
       
        var score = 0
        
        // Add a penalty if the analysis contains any morphemes that occur more than once in the analysis.
        // In principle, this could happen, but in practice it almost always is a sign of a bad analysis.
        score += 10000 * (self.underlyingMorphemes.count - Set(self.underlyingMorphemes).count)

        // Add a penalty if the number of morphemes in the underlying form differs from the number in the surface form.
        // This really shouldn't happen, but if it does, the analysis should be penalized.
        score += 1000  * abs(self.underlyingMorphemes.count - self.surfaceMorphemes.count)

        score += self.underlyingMorphemes.count
        
        //score += self.surfaceMorphemes.count
        
        self.heuristicScore = score
        
    }

    
    public func interLinearGloss() -> String {
        //let morphemes = self.calculateMorphemes()
        
        let lengths = self.morphemes.map{ (morpheme: Morpheme) -> Int in 1+max(max(morpheme.surfaceForm.count, morpheme.type.count), morpheme.underlyingForm.count)}
        
        var s = ""
        for i in 0..<self.morphemes.count {
            if i > 0 { s += "\t" }
            s += self.morphemes[i].type.padding(toLength: lengths[i], withPad: " ", startingAt: 0)
        }
        s += "\n"
        
        for i in 0..<morphemes.count {
            if i > 0 { s += "\t" }
            s += morphemes[i].underlyingForm.padding(toLength: lengths[i], withPad: " ", startingAt: 0)
        }
        s += "\n"
        
        for i in 0..<morphemes.count {
            if i > 0 { s += "\t" }
            s += morphemes[i].surfaceForm.padding(toLength: lengths[i], withPad: " ", startingAt: 0)
        }
        s += "\n"
        
        return s
    }
    
    
}
