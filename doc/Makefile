SHELL = /bin/sh
SOURCES = $(shell echo *.gv)
TARGETS = $(SOURCES:.gv=.png)

%.png: %.gv
	dot -T png -o $@ $^

.PHONY: all clean

all: $(TARGETS)

clean:
	rm -f $(TARGETS)
