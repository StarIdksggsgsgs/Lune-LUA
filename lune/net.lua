-- lune/net.lua
local M = {}
local ok_http, http = pcall(require, "socket.http")
local ok_ltn, ltn12 = pcall(require, "ltn12")
local ok_socket, socket = pcall(require, "socket")

function M.http_request_sync(url, opts)
    if not ok_http then return nil, "socket.http not available" end
    opts = opts or {}
    local sink = {}
    local res, code, headers, status = http.request{ url = url, method = opts.method or "GET", sink = ltn12 and ltn12.sink.table(sink) or nil, headers = opts.headers }
    if type(sink) == "table" then res = table.concat(sink) end
    return res, code, headers, status
end

-- coroutine style async wrapper uses lune.task if available
local ok_task, task = pcall(require, "lune.task")
function M.http_request(url, opts, cb)
    if type(opts) == "function" then cb = opts; opts = nil end
    opts = opts or {}
    if cb then
        if ok_task then
            task.spawn(function() local res, code, h, s = M.http_request_sync(url, opts); pcall(cb, res, code, h, s) end)
        else
            local res, code, h, s = M.http_request_sync(url, opts); pcall(cb, res, code, h, s)
        end
        return
    end
    if not ok_task then return M.http_request_sync(url, opts) end
    local co = coroutine.running()
    local out
    task.spawn(function() out = { M.http_request_sync(url, opts) }; if coroutine.status(co) == "suspended" then coroutine.resume(co) end end)
    coroutine.yield()
    return unpack(out)
end

-- Simple TCP helpers
function M.tcp_connect(host, port)
    if not ok_socket then return nil, "socket library missing" end
    local client = socket.tcp()
    client:settimeout(5)
    local ok, err = client:connect(host, port)
    if not ok then return nil, err end
    return client
end

function M.tcp_server(port, handler)
    if not ok_socket then return nil, "socket library missing" end
    local server = assert(socket.bind("*", port))
    server:settimeout(0)
    task.spawn(function()
        while true do
            local client = server:accept()
            if client then
                client:settimeout(0)
                task.spawn(function() pcall(handler, client); pcall(function() client:close() end) end)
            else
                if socket.sleep then socket.sleep(0.01) end
            end
            task.wait(0.01)
        end
    end)
    return server
end

return M
