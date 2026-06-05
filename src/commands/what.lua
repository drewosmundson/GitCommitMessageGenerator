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

local function startProcess(command, args, options)






    return 

end

return   {
    description = "Run an allowed command and use AI to explain the output.",

    run = function(app, args) 

        -- $luna what lua main.lua commit

        local baseCommand = args[2] -- "lua"

        if not baseCommand or baseCommand == "" then
            print("Usage: luna what <command> [args...]")
            print("Example: what lua main.lua")
            return
        end

        if not ALLOWED[baseCommand] then
            print("'" .. baseCommand .. "' is not in the allowed list.")
            print("Edit ALLOWED in commands/what.lua to add it.")
            return
        end

        local command = table.concat(args, " ", 2)

        if command:find(BLOCKED_CHAR) then 
            print("command contains blocked charectors")
            print("edit this in commands/what.lua BLOCKED_CHAR")
            return
        end

        print("Are you sure you want to run this command?:")
        print(command)
        print("( y / n )")

        local input = io.read()

        if input ~= "y" then
            print(input) 
            return
        end
            
        local pipe = io.popen(command)
    
        if not pipe then
            print("command produced no output")
            return 
        end 

        local output = pipe:read(8192)
        local ok, reason, code = pipe:close()
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