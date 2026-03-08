local core = {}

-- load all modules that are sitting in the same folder
local function safe_require(name)
    local ok, m = pcall(require, name)
    if ok then return m end
    return nil
end

core.task = safe_require("lune.task") or {}
core.fs = safe_require("lune.fs") or {}
core.net = safe_require("lune.net") or {}
core.process = safe_require("lune.process") or {}
core.json = safe_require("lune.json") or {}
core.console = safe_require("lune.console") or {}
core.EventEmitter = safe_require("lune.event") or {}
core.roblox = safe_require("lune.roblox") or {}
core.datetime = safe_require("lune.datetime") or {}
core.regex = safe_require("lune.regex") or {}

-- Setup package.preload to emulate @lune/* style requires
local preload_map = {
    ["@lune/task"] = function() return core.task end,
    ["@lune/fs"] = function() return core.fs end,
    ["@lune/net"] = function() return core.net end,
    ["@lune/process"] = function() return core.process end,
    ["@lune/json"] = function() return core.json end,
    ["@lune/console"] = function() return core.console end,
    ["@lune/event"] = function() return core.EventEmitter end,
    ["@lune/roblox"] = function() return core.roblox end,
    ["@lune/datetime"] = function() return core.datetime end,
    ["@lune/regex"] = function() return core.regex end,
}
for k,v in pairs(preload_map) do package.preload[k] = v end

-- Optionally patch safe globals but avoid clobbering existing globals
local function patch_if_nil(name, value)
    if _G[name] == nil then _G[name] = value end
end
patch_if_nil("task", core.task)
patch_if_nil("fs", core.fs)
patch_if_nil("net", core.net)
patch_if_nil("json", core.json)
patch_if_nil("console", core.console)

return core
