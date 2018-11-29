all:
	stack build

run: all
	stack exec struct-string

code:
	stack build stylish-haskell hlint intero hoogle && \
	zsh -c -i "code ."

.PHONY: run code
