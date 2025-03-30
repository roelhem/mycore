import? 'local.just'

[private]
default:
    @just --list

# Format the code in this repository
format:
    nix fmt

# Run all checks.
check:
    nix flake check

update *inputs:
    nix flake update {{ inputs }}
