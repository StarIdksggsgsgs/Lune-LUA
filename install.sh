#!/usr/bin/env bash
set -e

# Simple installer for Termux / Debian-like systems. Adjust as needed.
echo "Installing dependencies (luarocks, luasocket, luafilesystem, lua-cjson, lpeg)..."
if command -v pkg >/dev/null 2>&1; then
    pkg update -y || true
    pkg install -y git lua luarocks
else
    echo "Please install lua and luarocks via your package manager"
fi

# Install common rocks
luarocks install luasocket || true
luarocks install luafilesystem || true
luarocks install lua-cjson || true
luarocks install lpeg || true
luarocks install dkjson || true

echo "Done. You can run examples/example.lua with: lua examples/example.lua"
