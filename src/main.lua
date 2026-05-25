local json = require("dkjson")


local CONFIG    = dofile("CONFIG.lua")
local CONSTANTS = dofile("CONSTANTS.lua")
local utils     = dofile("utils.lua")

local PREFERRED_AI_MODEL      = CONFIG.PREFERRED_AI_MODEL
local OLLAMA_URL              = CONSTANTS.OLLAMA_URL
local GIT_COMMIT_INSTRUCTIONS = CONSTANTS.GIT_COMMIT_INSTRUCTIONS


function checkDependencies()
    if not utils.isInstalled("git")    then return false end
    if not utils.isInstalled("ollama") then return false end

    local data = utils.getJson(OLLAMA_URL .. "/api/tags")
    local availableModels = {}
    for _, m in ipairs(data.models or {}) do
        table.insert(availableModels, m.name)
    end

    if next(availableModels) == nil then
        print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    if not utils.tableContains(availableModels, PREFERRED_AI_MODEL) then
        print("Your preferred AI model is not available, you can change it in CONFIG.lua")
        PREFERRED_AI_MODEL = utils.promptUserForModelSelection(availableModels)
    end

    return true
end

local function loadCommands()
    local commands = {}
    local files = io.popen("ls commands/*.lua")
    for file in files:lines() do
        local name = file:match("commands/(.+)%.lua")
        local ok, result = pcall(dofile, file)
        if ok then
            commands[name] = result
        else
            print(string.format("Warning: skipping '%s' — %s", name, result))
        end
    end
    files:close()
    return commands
end

function main()
    if not checkDependencies() then return end

    local commands = loadCommands()

    local app = {
        config    = CONFIG,
        constants = CONSTANTS,
        utils     = utils,
        commands  = commands,
    }

    local userArg = arg[1]

    if userArg == nil then
        commands.help.run(app, nil)
        return
    end

    if not commands[userArg] then
        print(string.format("'%s' is not a valid command.", tostring(userArg)))
        commands.help.run(app, nil)
        return
    end

    local flag = arg[2]

    commands[userArg].run(app, flag)
end

main()