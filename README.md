# FoxClaude

The portable working folder for agents on this machine: the method docs they
read every session, the skills they load, the local MGSV modding wiki, the name
dictionaries, and the two built tools.

```
reasoning.md          per-prompt working method — read first, every session
code-style.md         mandatory code style for anything written here
skills/               cleancode · fox-tools · fox-wiki
                      (junctioned from C:\Users\Blue\.claude\skills\)
wiki/                 local MGSV / Fox Engine modding wiki
Fox_parser/           modbldr-tools.exe + dict/ + fox_logo.txt   [exe untracked]
FoxBrowser/           FoxBrowser.exe + its payloads              [untracked]
```

## What is and isn't tracked

Tracked: the docs, the skills, the wiki, and `Fox_parser/dict/` — the name
dictionaries, which are edited here and are the newest copies.

Not tracked: the two built exes and `release.zip`. They are build outputs of
the `Fox_parser` and `FoxBrowser` repos, ~115 MB together, and rebuilt often;
a compressed single-file exe doesn't delta, so every rebuild would add its full
size to history. Rebuild them instead:

```bash
pwsh -File sync.ps1
```

or by hand:

```bash
dotnet publish C:\rsearch\Fox_parser\MgsvModBldr.Tools.App -c Release -r win-x64 --self-contained -p:PublishSingleFile=true
```

then copy the published `modbldr-tools.exe` into `Fox_parser\`. FoxBrowser has
its own publish script that mirrors here:

```bash
pwsh -File C:\rsearch\FoxBrowser\publish.ps1 -Mirror C:\rsearch\FoxClaude\FoxBrowser
```

Don't overwrite `Fox_parser\dict\` from a build — the copies here are the
updated ones.

## Layout note

`Fox_parser\` and `FoxBrowser\` each hold one tool with its payloads beside it.
That matters for the parser: `modbldr-tools.exe` resolves `dict\` relative to
its own directory, so the exe and its dictionaries have to travel together.
