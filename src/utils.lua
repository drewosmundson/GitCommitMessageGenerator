
local lfs = require("lfs")
local uv = require("luv")
local json = require("dkjson")
local http = require("socket.http")
local ltn12 = require("ltn12")

local utils = {}

-- No state functions anly

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

function utils.getJson(url)
    local body, code = http.request(url)
    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)
    if err then error("JSON decode failed: " .. err) end

    return data
end

function utils.postJson(url, body)
    local responseBody = {}
    local _, code = http.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(responseBody),
    })
    if code ~= 200 then
        error("Ollama request failed with code: " .. tostring(code))
    end
    return table.concat(responseBody)
end 


function utils.getHttpStatus(url)
    local cmd = string.format("curl -s -o /dev/null -w '%%{http_code}' -L --max-time 5 '%s'", url)
    local handle = io.popen(cmd)
    if not handle then return 0 end
    local result = handle:read("*a")
    handle:close()
    return tonumber(result) or 0
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

--- Sends a prompt to the configured Ollama model and returns the response text.
-- @param prompt string: The prompt to send
-- @return string|nil, string|nil: (message, err)
function utils.promptModel(model, prompt, api)
    local body = json.encode({
        model =  model,
        prompt = prompt,
        stream = false,
    })

    local responseRaw = utils.postJson(api, body)
    local response, _, err = json.decode(responseRaw)

    if err or not response then
        return nil, "Failed to parse Ollama response: " .. tostring(err)
    end

    local message = response.response and response.response:match("^%s*(.-)%s*$")

    if not message or message == "" then
        return nil, "No response returned from model."
    end

    return message, nil
end


function utils.startProcess(path, args, TIMEOUT_LIMIT)

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

        function(code, signal)
            exitCode   = code
            exitSignal = signal
            done       = true

            timer:stop()
            timer:close()
            stdout:close()
            stderr:close()

            -- handle can be nil if the process exited very fast
            -- before uv.spawn finished setting it up
            if handle then
                handle:close()
                handle = nil
            end
        end
    )

    if not handle then
        timer:stop()
        timer:close()
        stdout:close()
        stderr:close()
        return nil, "Failed to spawn process: " .. pid
    end

    print("Started process with pid:" .. pid)


    uv.read_start(stdout, function(err, data)
        if err then print("stdout error") return end
        if data then table.insert(stdout_data, data) end
    end)

    uv.read_start(stderr, function(err, data)
        if err then print("stdout error") return end
        if data then table.insert(stderr_data, data) end
    end)


    timer:start(TIMEOUT_LIMIT, 0, function()
        -- Early return if the process already finished normally, the spawn callback already closed pipes
        if done then
            timer:stop()
            timer:close()
            return
        end
        print("Process timed out")

        -- check handle is non-nil and not already closing before killing, since the spawn callback may have run between ticks if the prosses finishes very quickly
        if handle and not handle:is_closing() then
            handle:kill("sigterm")
            handle:close()
            handle = nil
        end
        if not stdout:is_closing() then stdout:close() end
        if not stderr:is_closing() then stderr:close() end
        timer:stop()
        timer:close()
    end)


    while not done do
        uv.run("once")
    end


    return {
        stdout   = table.concat(stdout_data),
        stderr   = table.concat(stderr_data),
        exitCode = exitCode,
        signal   = exitSignal,
    }
end

return utils