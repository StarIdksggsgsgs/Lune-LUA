-- lune/process.lua
local M = {}

function M.exec(cmd)
    return os.execute(cmd)
end

local ok_task, task = pcall(require, "lune.task")
function M.exec_async(cmd, cb)
    if cb then
        if ok_task then task.spawn(function() local ok, code = os.execute(cmd); pcall(cb, ok, code) end)
        else local ok, code = os.execute(cmd); pcall(cb, ok, code) end
        return
    end
    if not ok_task then return os.execute(cmd) end
    local co = coroutine.running()
    local res, code
    task.spawn(function() res, code = os.execute(cmd); if coroutine.status(co)=="suspended" then coroutine.resume(co) end end)
    coroutine.yield()
    return res, code
end

function M.popen(cmd)
    return io.popen(cmd)
end

return M
