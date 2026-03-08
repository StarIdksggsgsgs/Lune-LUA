# lune-lua-project

Pure-Lua approximation of the Lune runtime for use in Termux / Lua 5.5.

> ⚠️ Limitations: this is a cooperative, pure-Lua shim. It approximates many Lune APIs but cannot reproduce compiled Luau or native asynchronous internals. Use the actual Lune runtime for full compatibility.

## Quick start (Termux)

1. Clone repo:

```bash
git clone https://github.com/<you>/lune-lua-project.git
cd lune-lua-project
