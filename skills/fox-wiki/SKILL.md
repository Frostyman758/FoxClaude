---
name: fox-wiki
description: Local MGSV/Fox Engine modding knowledge base — a decade of community RE knowledge. Covers file formats (fmdl, ftex, fox2, fpk/fpkd, qar/dat, lua, subtitles, sound...), the full engine entity class reference (Fox.* and Tpp.* classes with inheritance + properties), Lua scripting/commands, AI/routes/navmesh, missions, tools, and modding guides. Consult BEFORE reverse-engineering or guessing anything about MGSV TPP/GZ internals — it is likely already documented here.
---

# MGSV Modding Wiki (local copy)

`C:\rsearch\FoxClaude\wiki\` — the mgsvmoddingwiki as plain text.
**Check here FIRST** when a question touches Fox Engine formats, entities, Lua,
or how any part of MGSV works. Ten years of community findings; a 30-second grep
beats an hour of re-reversing something already documented.

## How to use it

1. **Start from the index**: `C:\rsearch\FoxClaude\wiki\INDEX.md` — one line per
   article with tags. ~200 articles.
2. **Grep for specifics** — the whole wiki is markdown/text:
   - `Grep pattern:"SendCommand" path:"C:\rsearch\FoxClaude\wiki"` → Lua command docs
   - `Grep pattern:"0x[0-9a-f]{8}" glob:"*.md"` → hash tables in articles
3. **Entity classes** live in `wiki\Entity_Reference\` as one `.txt` per class,
   organized AS the class hierarchy:
   `Entity_Reference/<Fox|Tpp>/<Module>/.../<ClassName>/<ClassName>.txt`
   Each file has the inheritance chain, a property table, and usage notes.
   Find a class fast with Glob `**/<ClassName>.txt` under the wiki folder.
   (~1200 classes; some are TODO stubs — a stub still confirms the class exists
   and where it sits in the hierarchy.)

## High-value entry points

- `Commands.md` — Lua GameObject `SendCommand` reference (pairs with
  modbldr-tools `hash`/`unhash` for command StrCode32 ids).
- File-format pages (tag `File Formats`): FMDL, FTEX, GANI, FOX2, FPK, QAR...
  pair them with the 010 templates at `C:\rsearch\FoxClaude\FoxBrowser\BT\*.bt`.
- `AI/` — nav/routes/domroutes internals; `Meta/` — wiki meta pages (skippable).
- Guides (tag `Guides`): end-to-end modding walkthroughs, Ghidra tips,
  graphics-debugger attachment.

## Trust model

Community-sourced: mostly verified by working mods, but pages can be stale or
partial (TODOs). Treat it as a **strong prior, not ground truth** — for
load-bearing claims, verify against the actual binary/files (per
`C:\rsearch\FoxClaude\reasoning.md`). Cite the page you used so the user can
check it. Jekyll artifacts (`{% include %}`, front matter, `/Entity_Reference/?/`
link syntax) are rendering noise — ignore them.

## Related

- Tools for acting on this knowledge: the **fox-tools** skill
  (modbldr-tools convert/hash, FoxBrowser search/extract of the packed dats).
- Refreshing the copy: re-download the repo and copy its `wiki\` folder over
  `C:\rsearch\FoxClaude\wiki\`, then regenerate INDEX.md (or ask an agent to).
