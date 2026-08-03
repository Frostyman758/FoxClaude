---
name: cleancode
description: Blue's mandatory code style ethics — apply whenever writing, refactoring, or generating ANY source code in any language or project, even a single new file or a quick script. Modular folders over monoliths, 700-line file cap, one-line ≤10-word header comment per file, terse comments, euro-format dates, no AI-filler language. If code is being written, this applies.
---

# cleancode — how code gets written here

Canonical guide: `C:\rsearch\FoxClaude\code-style.md`. These rules apply to every
file you create or substantially edit, in every language and project.

## Structure

- Modular, folders over monoliths. Split by responsibility into separate files
  in a clean folder tree. A new feature is usually a new file or folder, not
  400 lines appended to an existing one.
- **700 lines max per source file.** Nearing the cap means the file has more
  than one job — split it. Don't cheat with dense one-liners to stay under.

## File headers

Every source file opens with a one-line comment, max 10 words, saying what it is:

```
// Main view window
```

```python
# Qar archive reader
```

No author or license boilerplate. A date/time is fine, on the header line or
the line below, euro format — `DD/MM/YYYY` and 24-hour time:

```
// Main view window
// 07/07/2026 14:30
```

## Comments

- As few words as possible: `// retry on stall`, not a sentence.
- Comment only what the code can't say — non-obvious constraints, magic
  values, gotchas. Never narrate the next line.
- No reviewer-directed comments ("fixed", "as requested").

## Language

Banned everywhere (comments, names, docs, commit messages, output): "full
picture", "ground truth", "single source of truth", "battle-tested", "deep
dive", "holistic", "robust", "comprehensive", "seamless", "leverage", and
similar AI-flavored filler. Say the plain thing.

## Dates

Euro format everywhere: `DD/MM/YYYY`, 24-hour time.

## Before finishing

1. Each file ≤700 lines?
2. One-line header on every file?
3. Comments minimal and load-bearing?
4. New logic in the right file/folder, not grafted onto a monolith?
5. No filler language?
