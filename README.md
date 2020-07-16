# Yupik morphological analyzer

> **qamani** *қамани* /qɑ.'mɑː.ni/ — (demonstrative adverb, localis case, obscured) in there <br> (*Badten et al, 2008*)


## How to compile

- Option 1: On macOS, double-click on Package.swift, and the whole project should open in XCode

- Option 2: At the terminal, run `swift build`. This will compile the code and put it in a `.build` directory, probably in `.build/debug/qamani`


## How to prepare models

* Clone https://github.com/chenemile/yupik-foma-v2
* In the cloned directory, `make l2s.fomabin l2is.fomabin`

## How to run

`qamani --l2s <l2s> --l2is <l2is> --sentences <sentences> --mode <mode>`

OPTIONS:
* --l2s <l2s>             Finite-state transducer (lexical underlying form to surface form) in foma binary file format 
* --l2is <l2is>           Finite-state transducer (lexical underlying form to segmented surface form) in foma binary file format 
* --sentences <sentences> Text file containing one sentence per line 
* --mode <mode>           Mode: all | unique | failure 
* -h, --help              Show help information.

The arguments to the **l2s** and **l2is** flags must be absolute paths, not relative paths.

## Modes

### all
Print count and value of all analyzes for every word in the provided text.

### unique
Print count and value of analyses for words with exactly 1 analysis in the provided text.

### failure
Print words in the provided text that failed to analyze.

