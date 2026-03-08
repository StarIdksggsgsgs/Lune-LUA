-- lune/console.lua
local M = {}
local supports = true
local ANSI = { reset = "\27[0m", red = "\27[31m", green = "\27[32m", yellow = "\27[33m" }
function M.log(...) print(...) end
function M.info(...) print("[info]", ...) end
function M.warn(...) if supports then io.write(ANSI.yellow) end; print("[warn]", ...); if supports then io.write(ANSI.reset) end end
function M.error(...) if supports then io.write(ANSI.red) end; print("[error]", ...); if supports then io.write(ANSI.reset) end end
return M
