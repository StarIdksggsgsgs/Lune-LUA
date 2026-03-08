-- lune/datetime.lua
local M = {}
local socket = pcall(require, "socket") and require("socket") or nil
local gettime = socket and socket.gettime or os.time
function M.now() return gettime() end
function M.iso8601(ts) return os.date("!%Y-%m-%dT%TZ", ts or os.time()) end
function M.format(fmt, ts) return os.date(fmt, ts or os.time()) end
return M
