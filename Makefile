
FLAGS=-Xlinker -L/usr/local/lib/

all: build test

build:
	swift build $(FLAGS)

test:
	swift test $(FLAGS)

clean:
	swift package clean

.PHONY: test build all clean
