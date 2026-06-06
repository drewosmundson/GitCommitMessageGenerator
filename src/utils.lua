
local lfs = require("lfs")
local uv = require("luv")



local utils = {}

function utils.getLuaFilesFromDirectory(path)
    local files = {}
    for filename in lfs.dir(path) do
        -- Ignore the default '.' (current) and '..' (parent) directory markers
        if filename ~= "." and filename ~= ".." then
            table.insert(files, filename)
        end
    end
    return files
end

function utils.loadModulesFromFileTable(path, fileTable)
    local loadedModules = {}

    for _, filename in ipairs(fileTable) do
        -- Match files ending in .lua and extract the name without extension
        local moduleName = filename:match("(.+)%.lua$")

        if moduleName then
            print("Loading module: " .. moduleName)
            loadedModules[moduleName] = require(path .. "." .. moduleName)
        end
    end
    return loadedModules -- usage: loadedModules["script"].functionName()
end

function utils.tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

function utils.startProcess(path, args, timeoutLimit)
    
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)

    local stdout_data = {}
    local stderr_data = {}

    local exitCode   = nil
    local exitSignal = nil
    local done       = false

    local timer = uv.new_timer()

    -- uv.spawn(path, options, callback)
    local handle, pid = uv.spawn(
        path,                            -- Path

        {
            args = args,                    -- Options
            stdio = { nil, stdout, stderr }
        },

        function(code, signal)              -- Callback
            exitCode   = code
            exitSignal = signal
            done       = true

            timer:stop()
            timer:close()
            stdout:close()
            stderr:close()
            handle:close()

        end
    )

    if not handle then
        return nil, "Failed to spawn process: " .. pid  -- pid holds err msg on failure
    end


    print("Started process with pid:", pid)


    uv.read_start(stdout, function(err, data)
        if err then print("stdout error") return end
        if data then table.insert(stdout_data, data) end
    end)

    uv.read_start(stderr, function(err, data)
        if err then print("stdout error") return end
        if data then table.insert(stderr_data, data) end
    end)


    timer:start(timeoutLimit, 0, function()
        print("Process timed out")
        if handle and not handle:is_closing() then handle:kill("sigterm") end

        if not stdout:is_closing() then stdout:close() end
        if not stderr:is_closing() then stderr:close() end

        timer:stop()
        timer:close()
    end)


    while not done do
        uv.run("nowait")
    end


    return {
        stdout   = table.concat(stdout_data),
        stderr   = table.concat(stderr_data),
        exitCode = exitCode,
        signal   = exitSignal,
    }
end

return utils