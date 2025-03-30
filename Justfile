import? 'local.just'

[private]
default:
    @just --list

# Format the code in this repository
format:
    nix fmt
