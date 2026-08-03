# Code Style — how to write code in Blue's projects

Applies to every Claude Code agent, every model, every language. No exceptions
unless Blue says otherwise for a specific task.

## Structure

- **Modular, folders over monoliths.** Split by responsibility into separate
  files in a clean folder tree. Never grow one file into a do-everything blob.
- **700 lines max per source file.** Approaching the limit means the file has
  more than one job — split it. Don't cheat with dense one-liners to stay under.
- New feature = usually a new file (or folder), not 400 lines appended to an
  existing one.

## File headers

Every source file starts with a one-line header comment, max 10 words, saying
what the file is:

```
// Main view window
```

```python
# Qar archive reader
```

Use the language's comment syntax. No author, license boilerplate, or paragraph
descriptions. A date/time is fine, on the header line or the line below, in
standard euro format — `DD/MM/YYYY` and 24-hour time:

```
// Main view window
// 07/07/2026 14:30
```

Any dates/times written anywhere (code, docs, logs) use euro format too.

## Comments

- As few words as possible. `// retry on stall` not `// This function retries
  the operation when a stall is detected`.
- Comment only what the code can't say: non-obvious constraints, magic values,
  gotchas. Never narrate what the next line does.
- No comments that talk to a reviewer ("fixed", "as requested", "this is
  correct because...").

## Language

Banned phrases — in comments, names, docs, commit messages, and output:
"full picture", "ground truth", "single source of truth", "battle-tested",
"deep dive", "holistic", "robust solution", "comprehensive", "seamless",
"leverage", and any similar AI-flavored filler. Say the plain thing instead.

## Quick checklist before finishing

1. Each file under 700 lines?
2. Each file has its one-line header?
3. Comments minimal and load-bearing?
4. No monolith growth — new logic in the right file/folder?
5. No filler language anywhere?
