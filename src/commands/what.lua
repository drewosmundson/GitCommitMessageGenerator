

local PROMTS = {

    EVALUATE_COMMAND_OUTPUT = [[You are a developer assistant. 
        The user ran a terminal command and you are given its output.
        Explain clearly what the output means, highlight any errors or warnings, 
        and suggest next steps if relevant. Be concise.]],


    EVALUATE_WITH_DIFF = [[You are a developer assistant.
        The user ran a terminal command and you are given its output along with 
        a git diff of their recent changes.
        Explain what the output means in the context of the diff.
        Identify if any of the changes are likely causing errors or unexpected behavior.
        Be concise and actionable.]],
}

-- Add a command to this list to be allowed to run
local ALLOWED = { 
    ls = true,
    gcc = true,
    node = true ,
    java = true,
    lua = true ,
}

local BLOCKED_CHAR = "[;&><|`$]"

local TIMEOUT_LIMIT = 100000 -- Miliseconds

local unpack = table.unpack or unpack -- Lua 5.1 vs Lua 5.2

-- Termial colored text. use reset at the end of each line
local red     = "\27[31m"
local green   = "\27[32m"
local yellow  = "\27[33m"
local blue    = "\27[34m"
local reset   = "\27[0m"

return {
    description = "Run an allowed command and use AI to explain the output.",

    run = function(app, args)

        -- $luna what lua main.lua commit
        -- $lua main.lua what lua main.lua commit 
        local target = "what"
        local baseCommand = ""
        local commandArgs = {}

        for i, v in ipairs(args) do
            if v == target then
                baseCommand = args[i+1]
                commandArgs = { unpack(args, i+2) }
                break
            end
        end

        if not baseCommand or baseCommand == "" then
            print("Usage: luna what <command> [args...]")
            return nil
        end

        if not ALLOWED[baseCommand] then
            print("'" .. baseCommand .. "' is not in the allowed list.")
            print("Edit ALLOWED in commands/what.lua to add it.")
            return
        end

        if table.concat(commandArgs, " "):find(BLOCKED_CHAR) then
            print("command contains blocked charectors")
            print("edit this in commands/what.lua BLOCKED_CHAR")
            return nil
        end

        print("Are you sure you want to run this command?:")
        print(baseCommand .. " " .. table.concat(commandArgs, " "))
        print("(y / n)")

        local input = io.read()

        if input ~= "y" then
            print(input .. " cancelled")
            return nil
        end

        local result = app.utils.startProcess(baseCommand, commandArgs, TIMEOUT_LIMIT)


        if result.stdout ~= "" then
            print(green .. "Output:\n" .. result.stdout .. reset)
        end
        if result.stderr ~= "" then
            print(red .. "Errors:\n" .. result.stderr .. reset)
        end
        print(green .. "Exit code:", result.exitCode .. reset)


        local api = app.OLLAMA_URL .. "/api/generate"
        print("API URL: " .. api)
        local message = string.format(PROMTS.EVALUATE_COMMAND_OUTPUT, table.concat(result))
        local responce = app.utils.promptModel(PREFERRED_AI_MODEL, message, api)

        print(responce)

        print("would you like to compare the changes to your last commit?:")
        print("(y / n)")

        input = io.read()

        if input ~= "y" then
            print(input) 
            return nil
        end

        -- git add .
        -- local diff = git diff 

        -- send output prompt and diff to local llm 

        t = {}
        return t
    end
}



        --old method using shell new method spawns a process using
        -- the libuv lua library 

        --local pipe = io.popen(fullCommand)
        --if not pipe then
            --print("command produced no output")
            --return 
        --end 
        --local output = pipe:read(8192)
        --local ok, reason, code = pipe:close()

