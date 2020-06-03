import ArgumentParser
import Foma
import StreamReader

struct Parser: ParsableCommand {
    
    @Option(default: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin",
            help:    "Finite-state transducer in foma binary file format")
    var fst: String
    
    @Option(default: "/Users/lanes/work/summer/yupik/qamani/jacobson/Ch03.txt",
            help:    "Text file containing one sentence per line")
    var sentences: String
    
    func run() {
        let fst = FST(fromBinary: self.fst) //FST(fromBinary: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin")

        let result = fst.applyUp("qikmiq")
        print("Hello, \(result)!")
        
        if let sentences = StreamReader(path: self.sentences) {
            for line in sentences {
                print(line, to: &stderr)
            }
        }
    }
}

