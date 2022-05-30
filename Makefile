.PHONY: all src test slides parser

all : src slides

slides :
	make -C slides

src :
	make -C src all

test :
	make -C test

parser :
	make -C src/V3 parser

# EOF
