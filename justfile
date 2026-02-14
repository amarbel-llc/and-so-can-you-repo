# and-so-can-you-repo

default:
    @just --list

# Build the package
build:
    nix build

# Run the script
run *ARGS:
    nix run . -- {{ARGS}}

# Run tests
test:
    nix develop --command bats tests/

# Check with shellcheck
check:
    nix develop --command shellcheck bin/and-so-can-you-repo.bash

# Format with shfmt
fmt:
    nix develop --command shfmt -w -i 2 -ci bin/and-so-can-you-repo.bash

# Clean build artifacts
clean:
    rm -rf result
