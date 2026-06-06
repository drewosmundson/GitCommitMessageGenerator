local uv = require("luv")

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


local function startProcess(command, args)
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
        command,                            -- Path

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


    timer:start(TIMEOUT_LIMIT, 0, function()
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
                commandArgs = { table.unpack(args, i+2) }
                break
            end
        end

        if not baseCommand or baseCommand == "" then
            print("Usage: luna what <command> [args...]")
            return 
        end

        if not ALLOWED[baseCommand] then
            print("'" .. baseCommand .. "' is not in the allowed list.")
            print("Edit ALLOWED in commands/what.lua to add it.")
            return
        end

        if table.concat(commandArgs, " "):find(BLOCKED_CHAR) then
            print("command contains blocked charectors")
            print("edit this in commands/what.lua BLOCKED_CHAR")
            return
        end

        print("Are you sure you want to run this command?:")
        print(baseCommand .. " " .. table.concat(commandArgs, " "))
        print("( y / n )")

        local input = io.read()

        if input ~= "y" then
            print(input .. " cancelled")
            return
        end

        local processOutputTable = startProcess(baseCommand, commandArgs)


        for i, v in ipairs(processOutputTable) do
            print(i, v)
        end





        -- TODO BELOW
        -- send output and instruction prompt to llm
        -- print out llms explination of the output of the command 

        print("would you like to compare to your last commit to try and diagnose?:")
        print("( y / n )")

        input = io.read()

        if input ~= "y" then
            print(input) 
            return
        end

        -- git add .
        -- local diff = git diff 

        -- send output prompt and diff to local llm 


        return
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

