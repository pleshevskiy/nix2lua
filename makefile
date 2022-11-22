
# Run all tests
test:
	nix eval --impure --expr 'import ./lib.test.nix {}'

