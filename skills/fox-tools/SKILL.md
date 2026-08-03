---
name: fox-tools
description: Fox Engine (MGSV TPP/GZ) tooling. modbldr-tools.exe converts every Fox format (.fox2 .fpk .fpkd .dat .qar .ftex .lng .mtar .spch .rdf .fv2 .sbp .g0s ...) and computes/reverses game hashes (StrCode32, StrCode64/StringId, PathCode64, FNV1). FoxBrowser.exe searches/extracts across ALL the game's packed dats at once (query language, nested archives, reference tracing). Use for any MGSV file, asset-search, or hash work.
---

# Fox Engine tooling (MGSV)

Everything lives in one portable folder: `C:\rsearch\FoxClaude\`

- `C:\rsearch\FoxClaude\Fox_parser\modbldr-tools.exe` — convert any single Fox file, hash/unhash.
- `C:\rsearch\FoxClaude\FoxBrowser\FoxBrowser.exe` — find and pull files out of the
  game's packed dats (whole-install search, nested archives, reference tracing).
- `C:\rsearch\FoxClaude\reasoning.md` — the per-prompt working method; read it.
- `C:\rsearch\FoxClaude\wiki\` — local MGSV modding wiki (knowledge base; see the
  fox-wiki skill).

Typical loop: **FoxBrowser search → FoxBrowser extract → modbldr-tools convert**.

**Hard rule: never use GzsTool or other legacy tools** — modbldr-tools is the
only sanctioned converter (byte-exact round-trips, regression-gated).
Sources: `C:\rsearch\Fox_parser\` (converter, per-format projects, `test`
subcommand) and `C:\rsearch\FoxBrowser\` (browser GUI + CLI).

## File conversion

Pass a file (or unpacked folder) as the only argument; direction is inferred
from the extension. `modbldr-tools --help` lists all ~20 formats. Examples:

```
modbldr-tools file.fox2          -> file.fox2.xml       (and .xml -> .fox2)
modbldr-tools pack.fpkd          -> pack.fpkd.json + folder (and .json -> .fpkd)
modbldr-tools chunk0.dat         -> chunk0.dat.json + folder
modbldr-tools tex.ftex           -> tex.dds             (and .dds -> .ftex)
```

Errors print as `FOXDIE: ...` on stderr. `.ftexs` files are mipmap sidecars —
convert their parent `.ftex` instead.

## foxhash: forward hashing

```
modbldr-tools hash <string...>
```

Prints every engine hash variant per string:

| variant | meaning |
|---|---|
| `PathCode64` | QAR/PathServer file-path hash (51-bit base + 13-bit ext code, bit 50 = user flag) |
| `StrCode64` | Fox StringId, 48-bit CityHash StrCode (entity names, fox2 string ids) |
| `StrCode32` | low 32 bits of StrCode64 — Lua GameObject command ids, labels |
| `FNV1_32` | spch/rdf voice ids (a second lowercased line prints when it differs — spch/rdf convention) |

Ground truth check: `hash Spawn` → StrCode32 `df2005c4` (decomp-confirmed
vehicle Spawn command).

## foxhash: reverse lookup

```
modbldr-tools unhash <hex...> [-d extra_wordlist.txt]
```

Hashes every line of every dictionary in `C:\rsearch\FoxClaude\Fox_parser\dict\*.txt`
(~120k strings) under **all** variants and reports which algorithm + dictionary
hit, so you don't need to know which id space a bare hash came from. Hex input,
`0x` optional. ~2 s per run. Exit 0 = all resolved, 1 = at least one miss.

- PathCode base hits resolve the target's own extension code, so the printed
  path carries the right extension even though dictionary lines are
  extensionless.
- Dictionaries are loose and updatable: `modbldr-tools update-dicts` refreshes
  them from caplag/mgsv-lookup-strings.
- `no match` on a Lua command verb is normal — command names aren't dictionary
  content. Brute-force those instead with the candidate generator at
  `C:\rsearch\BN\tools\hash_match\` (`dotnet run -c Release -- targets.txt words.txt`,
  applies casing/verb×noun variants; resolved results in
  `resolved_soldier_commands.md` there).

## FoxBrowser CLI: search the packed game

`C:\rsearch\FoxClaude\FoxBrowser\FoxBrowser.exe` — headless verbs over the same
engine the GUI uses. **It is a WinExe: ALWAYS pipe its output**
(`2>&1 | ForEach-Object ToString` or `| Out-String`) or PowerShell may not wait
for it; don't trust `$LASTEXITCODE` — judge success by the output lines.

```
FoxBrowser search <query...> [-root <dir|archive>] [-cap N] [-noarch]
FoxBrowser trace  <hex-hash | name> [-root ...] [-cap N]
FoxBrowser extract <chain-path...> [-root <dir>] [-o <outdir>]
FoxBrowser ls     [<chain-path>] [-root <dir>]
```

- **Default root**: Steam `MGS_TPP\master`, falling back to `MGS_TPP\backup`
  (where the dats live while the install runs unpacked/modded). `-root` takes
  any folder OR a single archive file; searches recurse into nested archives
  (dat → fpk/fpkd/pftxs → files).
- **Query language** (same as the GUI search box): bare substring terms, all
  ANDed; `name:` `path:` `type:` `ext:` `is:` `size:` `hash:` modifiers; `-`
  negation; `*`/`?` globs; quoted values.
  `type:` categories: texture/model/archive/shader/sound/ui/lua/data/text.
  Examples: `search type:lua path:quiet`, `search ext:fmdl,fox2 size:>1mb`,
  `search hash:18e0ec02`.
- **Output** (stdout): `chain-path <TAB> size <TAB> pathcode64`. Progress and
  result counts go to stderr.
- **Chain paths** cross archive boundaries by name — feed a search hit
  (prefixed with the dat it came from when the root was a folder) straight to
  `extract`:
  `extract "chunk0.dat/Assets/tpp/.../cypr_script.fpkd/Assets/tpp/script/location/cypr/cypr.lua" -o out\`
- **trace** = what-references-this: finds files whose *bytes* embed the
  target's PathCode64 (8-byte LE) or its path string (lua/xml). Point `-root`
  at the smallest scope you can (a single dat/fpkd) — it reads every candidate
  file's bytes, so whole-install traces are slow.
- Search over one chunk dat ≈ seconds; the whole install is minutes — scope
  `-root` to a specific dat when you can.
- 010 binary templates for Fox formats: `C:\rsearch\FoxClaude\FoxBrowser\BT\*.bt`.

## index / search — the archive by GAME path

```
modbldr-tools index  <archive.dat|.g0s> [substring]   tree of game paths
modbldr-tools search <archive.dat|.g0s> <pattern>     find files (* ? globs)
```

Packs are FLATTENED AWAY: a model inside `plparts_*.fpk` appears where the game
looks for it, with the owning container noted on the right. Output is a folder
tree; single-child chains collapse (`Assets/tpp/chara/sna/`) because Fox paths are
deep and narrow.

Reads container INDEXES only — chunk0 is 21,842 entries across 2,787 containers
for ~2.4 MB, instead of decoding every pack. Works on TPP `.dat` and GZ `.g0s`.

```
modbldr-tools search chunk0.dat "*sna2_main0_def.fmdl"
└─ Assets/tpp/chara/sna/Scenes/
   └─ sna2_main0_def.fmdl  (633,632)   ← mis_com_snake_gz.fpk
```

**This is the fastest way to answer "where does X live".** Then `stream` it.

## stream — pull ONE file out, no unpack

```
modbldr-tools stream <archive.dat|.g0s> <path-or-hash> [-o <outfile>]
modbldr-tools stream <archive.dat|.g0s> --list [substring]
modbldr-tools stream --game <gameDir> <path> [-o <outfile>]
```

Parses only the index, decodes only the entry you asked for. The path may walk
through a nested pack:
`"…/ui_prefab_list.fpk/Assets/fox/ui/prefab/GraphAsset/list/list.uigb"`.
`--list` resolves names through the dictionaries (QAR entries store a hash, not
a name). `--game` searches a whole install and reads the copy the game loads
(patch archives override base). `--virtual <gamePath>` reads by GAME path without
you knowing which pack holds it — pair it with `index`/`search` above.

Use this instead of unpacking a 1.5 GB archive to get one file. For search
across the install FoxBrowser is still the better tool; `stream` is the
surgical single-entry read, and the same engine (`MgsvModBldr.Tools.Streaming`)
does the splice-writes behind FoxBrowser's "Replace file…".

**Extensions lie.** `master\e2f*.dat` (five of them) and GZ's `data_00.g0s` are
`.wmv` movies, not archives — `stream` detects that by magic and says so.

## Other subcommands

```
pathcode | stringid <str...>    single-variant forward hash (legacy)
buildmgsv <srcDir> <out.mgsv>   full mod build pipeline (managed FPK archiver)
test [<tool>] [--harvest]       regression suite (run after changing Fox_parser code)
```

## Rebuilding / deploying (targets are FoxClaude)

- modbldr-tools: `dotnet publish C:\rsearch\Fox_parser\MgsvModBldr.Tools.App -c Release
  -r win-x64 --self-contained -p:PublishSingleFile=true`, then copy **only the exe** to
  `C:\rsearch\FoxClaude\Fox_parser\modbldr-tools.exe` — `FoxClaude\Fox_parser\dict\` holds updated
  dictionaries; don't overwrite them.
- FoxBrowser: `pwsh -File C:\rsearch\FoxBrowser\publish.ps1` builds into
  `FoxBrowser\release\` and auto-mirrors to `C:\rsearch\FoxClaude\FoxBrowser\`.
- The fox-tools skill's canonical home is `C:\rsearch\FoxClaude\skills\fox-tools\`;
  `C:\Users\Blue\.claude\skills\fox-tools` is a junction to it.

## Gotchas

- Getting new/renamed files into the *running game* is a separate problem from
  packing them: the game (FastBite, unpacked from `Z:\`) only resolves novel
  paths after a PathServer dictionary update + restart. Hashed-filename
  fallbacks are not a content route.
