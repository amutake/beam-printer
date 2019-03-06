.PHONY: build install clean test

build:
	dune build

install:
	dune install

clean:
	dune clean

test:
	dune runtest
