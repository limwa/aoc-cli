# AoC CLI

A CLI for downloading Advent of Code problem inputs.

## Usage

### Nix

```sh
nix run github:limwa/aoc-cli -- help
```

### Manual

```sh
git clone https://github.com/limwa/aoc-cli
cd aoc-cli
./aoc.sh help
```

## Commands

### session

Manage your AOC session.

- `get`: Store and/or get the session cookie for the current session
- `invalidate`: Invalidate the session cookie for the current session

### input

Download problem inputs.

- `download -- <day> [<year>]`: Download the input for the given day and year (defaults to current year)
