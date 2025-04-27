import? 'local.just'

[private]
default:
    @just --list

# Format the code in this repository
format *files:
    nix fmt {{ files }}

# Run all checks.
check:
    nix flake check

repl:
    nix repl --file ./repl.nix

# Update nix flake dependencies.
update *inputs:
    nix flake update {{ inputs }}
