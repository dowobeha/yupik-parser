import ArgumentParser
import Foma

struct RunFST: ParsableCommand {
    
    @Option(default: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin",
            help:    "Finite-state transducer in foma binary file format")
    var fst: String
    
    func run() {
        let fst = FST(fromBinary: self.fst) //FST(fromBinary: "/Users/lanes/work/summer/yupik/yupik-foma-v2/lower.fomabin")

        let result = fst.applyUp("qikmiq")
        print("Hello, \(result)!")
    }
}

RunFST.main()
