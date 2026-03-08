-- lune/json.lua
local M = {}
local ok_cjson, cjson = pcall(require, "cjson")
local ok_dk, dkjson = pcall(require, "dkjson")
if ok_cjson then
    M.encode = cjson.encode
    M.decode = cjson.decode
elseif ok_dk then
    M.encode = function(t) return dkjson.encode(t) end
    M.decode = function(s) return dkjson.decode(s) end
else
    -- tiny fallback encoder/decoder (limited)
    local function encode_value(v)
        local t = type(v)
        if t == "number" or t == "boolean" then return tostring(v) end
        if t == "string" then return '"'..v:gsub('"','\\"')..'"' end
        if t == "table" then
            local isarr = true
            local max = 0
            for k,_ in pairs(v) do if type(k) ~= "number" then isarr = false end; if type(k)=="number" and k>max then max=k end end
            local parts = {}
            if isarr then for i=1,max do table.insert(parts, encode_value(v[i])) end; return "["..table.concat(parts,",").."]" end
            for k,val in pairs(v) do table.insert(parts, '"'..tostring(k)..'":'..encode_value(val)) end
            return "{"..table.concat(parts,",").."}"
        end
        return "null"
    end
    function M.encode(t) return encode_value(t) end
    function M.decode(s)
        local f, err = load("return "..s)
        if not f then return nil, err end
        local ok, res = pcall(f)
        if not ok then return nil, res end
        return res
    end
end
return M
