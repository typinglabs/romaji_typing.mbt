# Repository Guidelines

## Project Structure & Module Organization
- `src/`: MoonBit source files (`*.mbt`). Core modules include `typing.mbt`, `kana_graph.mbt`, and `romaji_table.mbt`.
- `tests/`: Additional test modules (for example `tests/datore.mbt`).
- `_build/`, `target/`: Build outputs (generated; do not edit).
- `moon.mod.json`, `src/moon.pkg.json`, `tests/moon.pkg.json`: MoonBit module/package configuration.

## Build, Test, and Development Commands
This is a MoonBit project; use the MoonBit CLI (`moon`). Common commands:
- `moon build`: Build the library.
- `moon test`: Run all `test "..." { ... }` blocks across `src/` and `tests/`.
If your environment uses different scripts, update this section accordingly.

## Coding Style & Naming Conventions
- Indentation: 2 spaces (as seen in `src/typing.mbt`).
- Naming: types in `UpperCamelCase`, functions/vars in `snake_case` (for example `create_roman_engine`).
- Keep functions small and focused; prefer explicit types on public APIs.
- Comments are short and purposeful; avoid redundant narration.

## Testing Guidelines
- Tests use MoonBit’s built-in `test` blocks embedded in source and test files.
- Naming: `test "<behavior description>" { ... }` with a concise, behavior-first description.
- Run all tests with `moon test` before submitting changes that affect behavior.

## Commit & Pull Request Guidelines
- Git history is minimal and has no strict convention. Use concise, imperative messages; Japanese is acceptable.
- PRs should include:
  - A brief summary of changes and motivation.
  - Test status (`moon test` output or note if not run).
  - Any relevant screenshots or sample inputs/outputs for behavior changes.

## Notes for Contributors
- The library targets romaji typing input validation. When adding features, include tests for multiple valid input patterns (for example `kyuu`, `kilyuu`).
- Prefer updating both the romaji table and graph logic together to keep input guidance consistent.
