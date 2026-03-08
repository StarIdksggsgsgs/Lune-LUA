-- lune/event.lua
local Event = {}
Event.__index = Event
function Event.new() return setmetatable({_listeners={}}, Event) end
function Event:on(name, cb) self._listeners[name] = self._listeners[name] or {}; table.insert(self._listeners[name], cb); return cb end
function Event:off(name, cb) local list = self._listeners[name]; if not list then return end; for i=#list,1,-1 do if list[i]==cb then table.remove(list,i) end end end
function Event:emit(name, ...) local list = self._listeners[name]; if list then for _,cb in ipairs(list) do pcall(cb, ...) end end end
return Event
