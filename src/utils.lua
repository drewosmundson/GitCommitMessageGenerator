local http  = require("socket.http")
local ltn12 = require("ltn12")
local json  = require("dkjson")

local utils = {}

-------------------- TABLE --------------------

function utils.tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

-------------------- HTTP --------------------

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
        url     = url,
        method  = "POST",
        headers = {
            ["Content-Type"]   = "application/json",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink   = ltn12.sink.table(responseBody),
    })
    if code ~= 200 then
        error("Request failed with code: " .. tostring(code))
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

-------------------- SYSTEM --------------------

function utils.isInstalled(dependency)
    local result = os.execute(dependency .. " --version > /dev/null 2>&1")
    return result == true or result == 0
end

-------------------- DISPLAY --------------------

function utils.hyperlink(url, text)
    return string.format("\27]8;;%s\27\\%s\27]8;;\27\\", url, text)
end

-------------------- MODEL SELECTION --------------------

function utils.promptUserForModelSelection(availableModels)
    print("Enter the number of the model you would like to use:")
    print("This will update your CONFIG.lua to your selected model")
    for key, value in ipairs(availableModels) do
        print(key, value)
    end

    local choice = tonumber(io.read())
    while choice == nil or availableModels[choice] == nil do
        print("Invalid selection. Enter a number from the list:")
        for key, value in ipairs(availableModels) do
            print(key, value)
        end
        choice = tonumber(io.read())
    end

    local model = availableModels[choice]

    local file = io.open("CONFIG.lua", "w")
    file:write(string.format('return { PREFERRED_AI_MODEL = "%s" }', model))
    file:close()

    return model
end

-------------------- RETURN --------------------

return utils