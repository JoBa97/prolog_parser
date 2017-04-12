CC=g++
CCFLAGS=-Wall -Wextra -fno-exceptions -Wno-format -std=c++1y
CCLIBS=-lfl
BIN=bin
BINNAME=prolog
SRC=src
SRCGEN=src_generated
INC=include


all: generate
	$(CC) $(CCFLAGS) -o $(BIN)/$(BINNAME) $(SRC)/*.cpp $(SRCGEN)/*.c -I $(INC)/ $(CCLIBS)

generate: $(SRCGEN)/prolog.tab.c $(SRCGEN)/lex.yy.c

$(SRCGEN)/prolog.tab.c: .FORCE
	bison -v -d -o $(SRCGEN)/prolog.tab.c $(SRC)/prolog.y

$(SRCGEN)/lex.yy.c: .FORCE
		flex -o $(SRCGEN)/lex.yy.c $(SRC)/prolog.l

clean:
	rm -f $(BIN)/* $(SRCGEN)/*

dirs:
	mkdir $(BIN) $(SRCGEN)


.PHONY: all clean generate dirs .FORCE
FORCE:
