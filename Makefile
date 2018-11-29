all: 
	stack build 

run: all
	stack exec struct-string

code:
	stack build stylish-haskell hlint intero hoogle && \
	zsh -c -i "code ."

chs: MyStruct2.hs

%.hs: %.chs
	c2hs -C"-I." $< -o $@

.PHONY: run code chs
