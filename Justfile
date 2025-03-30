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

# Update nix flake dependencies.
update *inputs:
    nix flake update {{ inputs }}
