# Unsupervised learning of probabilistic models for morphological analysis

> **qamani** *қамани* /qɑ.'mɑː.ni/ — (demonstrative adverb, localis case, obscured) in there <br> (*Badten et al, 2008*)

Given a user-provided morphological analyzer implemented in [foma](https://fomafst.github.io/), **qamani** provides morphological analyses for every word in a corpus and learns a conditional probability model `p(analysis | word)`.

The corpus must be a text file containing one sentence per line. It should work even if you haven’t removed punctuation from words.


> **nasuqun** *насюқун* /nɑ.'suː.qun/ — (noun, absolutive case, singular, from **nasuqe-** 'to estimate') model <br> (*Badten et al, 2008*, p. 289)

## How to compile

Ensure that you have [Swift 5.2](https://www.swift.org/download) or later installed.

- Option 1: On macOS with XCode 11.4 or later, double-click on Package.swift, and the whole project should open in XCode

- Option 2: At the terminal, run `swift build`. This will compile the code and put it in a `.build/debug` directory.


## Finite-state morphology models

Two finite-state models are required:
* **l2s** Maps lexical underlying forms (upper side) to orthographic surface forms (lower side)
* **l2is** Maps lexical underlying forms (upper side) to intermediate morpheme-segmented orthographic surface forms (lower side)

Each finite-state model must be in [foma](https://fomafst.github.io/) binary format.

### Example (St. Lawrence Island Yupik)

* Clone https://github.com/SaintLawrenceIslandYupik/finite_state_morphology
* In the cloned directory, `make l2s.fomabin l2is.fomabin`


## Perform morphological analysis

> **itemquulteki** *итымқӯльтыки* /i.'təm.'quːɬ.tə.ki/ — (transitive verb, optative mood, 1st person plural subject, 3rd person plural object) let's take them apart <br> (*Badten et al, 2008*)

For each word in the provided *sentences* file, **itemquulteki** prints a line that provides:
- The number of analyses for that word
- The surface form of the word as it was actually analyzed (possibly lowercased, with any punctuation removed)
- The position of the word in the corpus (sentence number and word number within the sentence)
- The possible number of analyses for this sentence (calculated as the product over the number analyses of each word in the sentence)
- The original surface form of the word as it occurred in the sentence (original casing, possibly includes punctuation)
- The list of all analyses for that word

`swift run itemquulteki --l2s <l2s> --l2is <l2is> --sentences <sentences> --mode <mode>`

**itemquulteki** can be run in one of three modes:
* *all* Print count and value of all analyzes for every word in the provided text.
* *unique* Print count and value of analyses for words with exactly 1 analysis in the provided text.
* *failure* Print words in the provided text that failed to analyze.

OPTIONS:
* --l2s <l2s>             Finite-state transducer (segmented lexical underlying form to surface form) in foma binary file format 
* --l2is <l2is>           Finite-state transducer (segmented lexical underlying form to segmented surface form) in foma binary file format 
* --sentences <sentences> Text file containing one sentence per line
* --delimiter <delimiter> Character that delimits morpheme boundaries in the segmented lexical underlying forms and in the segmented surface forms (default: ^)
* --mode <mode>           all | unique | failure 
* -h, --help              Show help information.

The arguments to the **l2s**, **l2is**, and **sentences** flags must be absolute paths, not relative paths.


## Learn probabilistic models of morphology

> **peghqiilta** *пҳқӣльта* /pəχ.'qiːɬ.tɑ/ — (intransitive verb, optative mood, 1st person plural subject) let's train <br> (*Badten et al, 2008*)


