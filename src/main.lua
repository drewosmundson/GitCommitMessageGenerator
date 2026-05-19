local http = require("socket.http")
local json = require("dkjson")
local CONFIG = dofile("CONFIG.lua")

local OLLAMA_URL = CONFIG.OLLAMA_URL
local PREFERRED_AI_MODEL = CONFIG.PREFERRED_AI_MODEL


local function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

local function savePreferrdModel(model)

    local file = io.open("CONFIG.lua", "w")

    file:write(string.format(
    [[return {
      OLLAMA_URL = "http://127.0.0.1:11434",
      PREFERRED_AI_MODEL = "%s",
    }]], model))

    file:close()
end 


local function promtUserForModelSelection(availableModels)
    print("Enter the number of the model you would like to use:")
    print("This will update your CONFIG.lua to your selected model")
    for key, value in pairs(availableModels) do
        print(key, value)
    end

    local choice = tonumber(io.read())

    while choice == nil or availableModels[choice] == nil do
        print("Invalid selection. Enter a number from the list:")
        for key, value in pairs(availableModels) do
            print(key, value)
        end
        choice = tonumber(io.read())
    end

    local model = availableModels[choice]
    savePreferrdModel(model)
    return model
end


local function isPreferrdModelAvailable(availableModels, preferrdAiModel)
    if not tableContains(availableModels, preferrdAiModel) then 
        return false
    end
    return true
end


local function getJsonDataFromURL(url)
    local body, code = http.request(url)
    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)
    if err then error("JSON decode failed: " .. err) end

    return data
end


local function isInstalled(dependency) 
    -- > /dev/null 2>&1 suppresses output from the command
    result = os.execute(dependency .. " --version > /dev/null 2>&1")
    -- depending on the version of lua this could return 0 or true on success
    if result == true or result == 0 then
        return true
    else
        print(dependency .. " is required")
        print("run install.lua or install dependencies manually")
        return false
    end
end


function checkDependencies()
    if not isInstalled("git") then return false end
    if not isInstalled("ollama") then return false end

    local data = getJsonDataFromURL(OLLAMA_URL .. "/api/tags")
    local availableModels = {}
    for _, m in ipairs(data.models or {}) do
        table.insert(availableModels, m.name)
    end

    if next(availableModels) == nil then
        print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    if not isPreferrdModelAvailable(availableModels, PREFERRED_AI_MODEL) then
        print("Your preferrd AI model is not available, you can change it in CONFIG.lua")
        PREFERRED_AI_MODEL = promtUserForModelSelection(availableModels)
    end

    return true
end

function main()
    if not checkDependencies() then return end
    print("passed")
end

main()