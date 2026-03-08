local lune = require("lune")
local task = require("@lune/task")
local fs = require("@lune/fs")
local net = require("@lune/net")
local console = require("@lune/console")

console.info("Starting example...")

task.spawn(function()
    for i=1,3 do
        console.log("task tick", i)
        task.wait(0.5)
    end
end)

task.delay(1.2, function() console.log("delayed callback fired") end)

task.spawn(function()
    local body, code = net.http_request("http://example.com")
    if body then console.log("http ok, len=", #body) else console.warn("http not available") end
end)

local ok, err = fs.writeFileSync("test_lune.txt", "hello from lune-shim")
console.log("wrote file?", ok, err)
local content = fs.readFileSync("test_lune.txt")
console.log("file content:", content)

task.run()
console.info("Example finished")
