import Foma
import Foundation
/// Morphological analysis of a single word
public struct MorphologicalAnalysis: Codable {
          
    /// A single morphological analysis of a word, as represented by a morpheme-delimited string of underlying lexical morphemes.
    public let underlyingForm: String
    
    public let morphemes: String //[String]
    
    /// List matching intermediate form(s)
    public let intermediateForm: String?
    
    public let delimiter: String
    
    //public lazy var morphemeList = self.calculateMorphemes()
    /**
     Stores a morphological analysis.
     */
    public init(_ underlyingForm: String, withIntermediateForm intermediateForm: String?, delimiter: String) {
        self.underlyingForm = underlyingForm
        self.morphemes = underlyingForm.replacingOccurrences(of: "=", with: " (Enclitic)").replacingOccurrences(of: delimiter, with: " ")
        self.intermediateForm = intermediateForm
        self.delimiter = delimiter
    }

    public func partsOfSpeech() -> [String] {
        let morphemes: [String] = self.underlyingForm.replacingOccurrences(of: "=", with: " (Enclitic)").replacingOccurrences(of: delimiter, with: " ").components(separatedBy: " ")
        return morphemes.enumerated().map{ (index: Int, morpheme: String) -> String in
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
    }
    
    public func underlyingMorphemes() -> [String] {
        return self.morphemes.components(separatedBy: " ") //.split(separator: " ").map { String($0) }
    }
    
    public func surfaceMorphemes() -> [String] {
        return self.intermediateForm!.components(separatedBy: self.delimiter)
    }
    
    public func calculateMorphemes() -> [Morpheme] {
        let underlyingMorphemes = self.underlyingMorphemes()
        let surfaceForms = self.surfaceMorphemes() //analysis.intermediateForm!.components(separatedBy: analysis.delimiter) //.split(separator: analysis.delimiter)
        let partsOfSpeech = self.partsOfSpeech()

        var morphemes = [Morpheme]()
        for i in 0..<underlyingMorphemes.count {
            morphemes.append(Morpheme(underlying: underlyingMorphemes[i], type: partsOfSpeech[i], surface: surfaceForms[i]))
        }
        
        return morphemes
    }
    
    public func interLinearGloss() -> String {
        let morphemes = self.calculateMorphemes()
        
        let lengths = morphemes.map{ (morpheme: Morpheme) -> Int in 1+max(max(morpheme.surfaceForm.count, morpheme.type.count), morpheme.underlyingForm.count)}
        
        var s = ""
        for i in 0..<morphemes.count {
            if i > 0 { s += "\t" }
            s += morphemes[i].type.padding(toLength: lengths[i], withPad: " ", startingAt: 0)
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
