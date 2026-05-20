local http = require("socket.http")
local json = require("dkjson")

local CONFIG = dofile("CONFIG.lua")
local PROMPTS = dofile("PROMPTS.lua")

local OLLAMA_URL = CONFIG.OLLAMA_URL
local PREFERRED_AI_MODEL = CONFIG.PREFERRED_AI_MODEL
local GIT_COMMIT_INSTRUCTIONS = PROMPTS.GIT_COMMIT_INSTRUCTIONS


-------------------- UTILS -----------------------
local function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

local function savePreferredModel(model)
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

local function getJson(url)
    local body, code = http.request(url)
    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)
    if err then error("JSON decode failed: " .. err) end

    return data
end


local function postJson(url, body)
    local responseBody = {}
    local _, code = http.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body), -- wraps a string so it can be sent in pieces to the server
        sink = ltn12.sink.table(responseBody), -- takes incoming pieces and adds to the table
    })
    if code ~= 200 then
        error("Ollama request failed with code: " .. tostring(code))
    end
    return table.concat(responseBody)
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

    local data = getJson(OLLAMA_URL .. "/api/tags")
    local availableModels = {}
    for _, m in ipairs(data.models or {}) do
        table.insert(availableModels, m.name)
    end

    if next(availableModels) == nil then
        print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    if not tableContains(availableModels, PREFERRED_AI_MODEL) then
        print("Your preferrd AI model is not available, you can change it in CONFIG.lua")
        PREFERRED_AI_MODEL = promtUserForModelSelection(availableModels)
    end

    return true
end










---------- COMMANDS --------------------

-- module that contains all the commands for this script.

-- This table contains all the functions in this 'command' namespace to add a new command to create a new fuction
-- named commmands."your function name here"
-- input parameters are flags and aditional information passed
-- Usage example: 

-- $ AliasName commitMessageGenerate -I ""

local function createJsonBody(model, prompt)
    return json.encode({
        model = model,
        prompt = prompt,
        stream = false,
    })
end


local Commands = {}

function Commands.commit()
    os.execute("git add .")

    local handle = io.popen("git diff --staged")
    local diff = handle:read("*a")
    handle:close()

    if diff == "" then
        print("No staged changes detected. Save your changes before running this command.")
        return false
    end

    local prompt = string.format(GIT_COMMIT_INSTRUCTIONS, diff)
    local body = createJsonBody(PREFERRED_AI_MODEL, prompt)

    print("Generating commit message...")

    local responseRaw = postJson(OLLAMA_URL .. "/api/generate", body)
    local response, _, err = json.decode(responseRaw)

    if err or not response then
        print("Failed to parse Ollama response: " .. tostring(err))
        return false
    end

    local message = response.response and response.response:match("^%s*(.-)%s*$") -- trim whitespace

    if not message or message == "" then
        print("No commit message returned from model.")
        return false
    end

    print("\nSuggested commit message:\n")
    print("  " .. message)
    print("\nCommit with this message? (y/n): ")

    local confirm = io.read()
    if confirm:lower() == "y" then
        local commitCmd = string.format('git commit -m "%s"', message:gsub('"', '\\"'))
        os.execute(commitCmd)
        print("Committed!")
    else
        print("Commit cancelled.")
    end

    return true
end

function Commands.undo()
    -- Show the last commit so the user knows what they're undoing
    local handle = io.popen("git log --oneline -1")
    local lastCommit = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()

    if lastCommit == "" then
        print("No commits to undo.")
        return false
    end

    print("Last commit: " .. lastCommit)
    print("Undo this commit? Changes will be kept staged. (y/n): ")

    local confirm = io.read()
    if confirm:lower() ~= "y" then
        print("Undo cancelled.")
        return false
    end

    -- Soft reset: removes the commit but keeps changes staged
    local result = os.execute("git reset --soft HEAD~1")
    if result == true or result == 0 then
        print("Commit undone. Your changes are still staged.")
    else
        print("Failed to undo commit.")
        return false
    end

    return true
end

function Commands.addComments()
    -- TODO add comments to your file
end

function Commands.chat()
    -- TODO: starts a chat stream, clears history when finished
end

function Commands.help()
    print("Available commands:")
    for name, _ in pairs(Commands) do
        print("  " .. name)
    end
end

function Commands.delete()
    -- TODO: deletes specified command or built-in prompt
end

function Commands.add()
    -- TODO: adds a new command
end







function main()
    if not checkDependencies() then return end

    local userArg = arg[1]

    if userArg == nil then
        Commands.help()
        return
    end

    if not userArg or not Commands[userArg] then
        print(string.format("'%s' is not a valid command.", tostring(userArg)))
        Commands.help()
        return
    end

    Commands[userArg]()
end

main()