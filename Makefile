.PHONY: build install clean test

build:
	dune build

install: build
	dune install

clean:
	dune clean

test:
	dune runtest
