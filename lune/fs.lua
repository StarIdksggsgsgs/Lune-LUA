-- lune/fs.lua
local M = {}

function M.readFileSync(path, mode)
    mode = mode or "rb"
    local f, err = io.open(path, mode)
    if not f then return nil, err end
    local c = f:read("*a")
    f:close()
    return c
end

function M.writeFileSync(path, data, mode)
    mode = mode or "wb"
    local f, err = io.open(path, mode)
    if not f then return nil, err end
    f:write(data)
    f:close()
    return true
end

function M.exists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

-- async wrappers (cooperative) depend on task module existing
local ok_task, task = pcall(require, "lune.task")
if ok_task and task then
    function M.readFile(path, mode, cb)
        if type(mode) == "function" then cb=mode; mode="rb" end
        if cb then
            task.spawn(function() local content, err = M.readFileSync(path, mode); pcall(cb, content, err) end)
            return
        end
        local co = coroutine.running()
        if not co then return M.readFileSync(path, mode) end
        local res, err
        task.spawn(function() res, err = M.readFileSync(path, mode); if coroutine.status(co)=="suspended" then coroutine.resume(co) end end)
        coroutine.yield()
        return res, err
    end

    function M.writeFile(path, data, mode, cb)
        if type(mode) == "function" then cb=mode; mode="wb" end
        if cb then task.spawn(function() local ok, err = M.writeFileSync(path, data, mode); pcall(cb, ok, err) end); return end
        local co = coroutine.running()
        if not co then return M.writeFileSync(path, data, mode) end
        local res, err
        task.spawn(function() res, err = M.writeFileSync(path, data, mode); if coroutine.status(co)=="suspended" then coroutine.resume(co) end end)
        coroutine.yield()
        return res, err
    end
end

return M
