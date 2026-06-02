local json = require("dkjson")
local lfs = require("lfs")

local UTILS = require("utils")
local HTTP = require("http")

local CONFIG = dofile("CONFIG.lua")

local OLLAMA_URL = CONFIG.OLLAMA_URL
local PREFERRED_AI_MODEL = CONFIG.PREFERRED_AI_MODEL


local function savePreferredModelToConfig(model)
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
    savePreferredModelToConfig(model)
    return model
end



local function isInstalled(dependency)
    local result = os.execute(dependency .. " --version > /dev/null 2>&1")
    if result == true or result == 0 then
        return true
    else
        print(dependency .. " is required")
        print("run install.lua or install dependencies manually")
        return false
    end
end


---------- DEPENDENCY CHECKS --------------------
function checkDependencies()
    if not isInstalled("git") then return false end
    if not isInstalled("ollama") then return false end

    local data = HTTP.getJson(OLLAMA_URL .. "/api/tags")
    local availableModels = {}
    for _, m in ipairs(data.models or {}) do
        table.insert(availableModels, m.name)
    end

    if next(availableModels) == nil then
        print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    if not UTILS.tableContains(availableModels, PREFERRED_AI_MODEL) then
        print("Your preferred AI model is not available, you can change it in CONFIG.lua")
        PREFERRED_AI_MODEL = promtUserForModelSelection(availableModels)
    end

    return true
end



---------- MAIN --------------------

function main()
    if not checkDependencies() then return end

    local userArg = arg[1]
    local flag = arg[2]

    print(CONFIG.PREFERRED_AI_MODEL .. " ")

    local commands = {}

    for file in lfs.dir("commands/") do
        local name = file:match("^(.+)%.lua$")
        if name then
            commands[name] = require("commands." .. name)
        end
    end


    local app = {
        PREFERRED_AI_MODEL = PREFERRED_AI_MODEL,
        OLLAMA_URL         = OLLAMA_URL,
        UTILS              = require("utils"),
        JSON               = require("dkjson"),
        HTTP               = require("http"),
        commands           = commands
    } 

    if userArg == nil then
        commands["help"].run()
        return
    end


    if not commands[userArg] then
        print(string.format("'%s' is not a valid command.", tostring(userArg)))
        commands["help"].run()
        return
    end


    commands[userArg].run(app, flag)


    return true
end

main() 