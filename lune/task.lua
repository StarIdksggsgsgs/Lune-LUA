-- lune/task.lua
-- Cooperative coroutine-based scheduler with timers and helpers

local socket = (pcall(require, "socket") and require("socket")) or nil
local gettime = socket and socket.gettime or os.time
local sleep = socket and socket.sleep

local M = {}

local _tasks = {}
local _timers = {}
local _next_timer_id = 0
local _deferred = {}

local function now() return gettime() end

local function insert_timer(t) table.insert(_timers, t) end
local function remove_timer_by_id(id)
    for i=#_timers,1,-1 do if _timers[i].id == id then table.remove(_timers, i) end end
end

function M.spawn(fn)
    local co = coroutine.create(fn)
    table.insert(_tasks, co)
    return co
end

function M.defer(fn)
    table.insert(_deferred, fn)
end

function M.delay(seconds, fn)
    _next_timer_id = _next_timer_id + 1
    insert_timer({time = now() + (seconds or 0), fn = fn, id = _next_timer_id})
    return _next_timer_id
end

function M.cancel(id) remove_timer_by_id(id) end

function M.wait(seconds)
    seconds = seconds or 0
    local co = coroutine.running()
    if not co then
        local target = now() + seconds
        while now() < target do if sleep then sleep(0.01) end end
        return
    end
    local resumed = false
    local tid = M.delay(seconds, function() if coroutine.status(co) == "suspended" then coroutine.resume(co) end end)
    coroutine.yield()
    remove_timer_by_id(tid)
end

local function run_tick()
    local n = now()
    -- handle timers
    local due = {}
    for i=#_timers,1,-1 do if _timers[i].time <= n then table.insert(due, table.remove(_timers, i)) end end
    for _,t in ipairs(due) do pcall(t.fn) end
    -- deferred
    while #_deferred > 0 do local f = table.remove(_deferred, 1); pcall(f) end
    -- resume tasks
    for i=#_tasks,1,-1 do
        local co = _tasks[i]
        if coroutine.status(co) == "dead" then table.remove(_tasks, i) else
            local ok, err = coroutine.resume(co)
            if not ok and err then table.remove(_tasks,i); print("task error:", err) end
        end
    end
end

function M.run(timeout)
    timeout = timeout or math.huge
    local start = now()
    while (#_tasks>0) or (#_timers>0) or (#_deferred>0) do
        run_tick()
        if sleep then sleep(0.005) end
        if now() - start > timeout then break end
    end
end

function M.runAll() M.run() end

return M
