# Yupik morphological analyzer

> **qamani** *қамани* /qɑ.'mɑː.ni/ — (demonstrative adverb, localis case, obscured) in there <br> (*Badten et al, 2008*)

This code wraps a (foma)[https://fomafst.github.io/] morphological analyzer to provide morphological analyses for every word in a corpus. 
The corpus must be a text file containing one sentence per line. It should work even if you haven’t removed punctuation from words.

For each word, the code prints a line that provides:
- The number of analyses for that word
- The surface form of the word as it was actually analyzed (possibly lowercased, with any punctuation removed)
- The position of the word in the corpus (sentence number and word number within the sentence)
- The possible number of analyses for this sentence (calculated as the product over the number analyses of each word in the sentence)
- The original surface form of the word as it occurred in the sentence (original casing, possibly includes punctuation)
- The list of all analyses for that word

## How to compile

Ensure that you have Swift 5.2 or later installed.

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
* --mode <mode>           all | unique | failure 
* -h, --help              Show help information.

The arguments to the **l2s** and **l2is** flags must be absolute paths, not relative paths.

## Modes

The code can be run in one of three modes:

### all
Print count and value of all analyzes for every word in the provided text.

### unique
Print count and value of analyses for words with exactly 1 analysis in the provided text.

### failure
Print words in the provided text that failed to analyze.

