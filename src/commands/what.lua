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

-- example usage startProcess(lua, {arg1, arg2}, {cwd="path", env={debug=1, ETC}})
-- run_process(
--    "python",
--    {"script.py", "--verbose"},
--    {
--        cwd = "/tmp",
--        env = {
--            "DEBUG=1",
 --     }
--    }
--)

local function startProcess(command, args)

    stdout = {}
    stderr = {} 



    return 

end

return   {
    description = "Run an allowed command and use AI to explain the output.",

    run = function(app, args) 

        -- $luna what lua main.lua commit
        -- $lua main.lua what lua main.lua commit 
        local target = "what"
        local baseCommand = "" 
        local commandArgs = {}
        for i, v in ipairs(args)
            if v == target then 
                baseCommand = args[i+1]
                commandArgs = table.concat(args, " ", i+2)
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

        if commandArgs:find(BLOCKED_CHAR) then 
            print("command contains blocked charectors")
            print("edit this in commands/what.lua BLOCKED_CHAR")
            return
        end

        print("Are you sure you want to run this command?:")
        print(baseCommand .. " " .. commandArgs)
        print("( y / n )")

        local input = io.read()

        if input ~= "y" then
            print(input .. " cancelled")
            return
        end


        --old method using shell new method spawns a process using
        -- the libuv lua library 

        --local pipe = io.popen(fullCommand)
        --if not pipe then
            --print("command produced no output")
            --return 
        --end 
        --local output = pipe:read(8192)
        --local ok, reason, code = pipe:close()

        local processOutputTable = startProcess(baseCommand, commandArgs)



        -- send output and instruction prompt to llm
        -- print out llms explination of the output of the command 

        print("would you like to compare to your last commit to try to diagnose?:")
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