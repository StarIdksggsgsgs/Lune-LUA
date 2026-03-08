-- lune/regex.lua
local ok_lpeg, lpeg = pcall(require, "lpeg")
local M = {}
if ok_lpeg then
    function M.match(s, pat) return lpeg.match(pat, s) end
else
    function M.match(s, pat) return string.match(s, pat) end
end
M.gmatch = string.gmatch
return M
