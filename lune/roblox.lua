-- lune/roblox.lua
local M = {}
M.Instance = {}
function M.Instance.new(className)
    return { ClassName = className, Name = className, Children = {}, Parent = nil }
end
function M.Instance.addChild(self, child) table.insert(self.Children, child); child.Parent = self end
M.workspace = M.Instance.new("Workspace")
M.Players = { LocalPlayer = M.Instance.new("Player") }
function M.createPart(name)
    local p = M.Instance.new("Part"); p.Name = name or "Part"; p.Position = {x=0,y=0,z=0}; return p
end
return M
