local PROMTS = {

    EVALUATE_COMMAND_OUTPUT = "", 

} 

-- add a command to this list to be allowed to run
local ALLOWED = { 
    ls = true,

    gcc = true,
    node = true ,
    java = true,
    lua = true ,
} 
local BLOCKED_CHAR = "[;&><`$]"


return   {
    description = "",
    run = function(app, args) 

        local command = args[2]

        if not ALLOWED[command] then
            print("command not in allowed list")
            print("edit this in commands/what.lua ALLOWED")
            return 
        end 
        
        if command:find(BLOCKED_CHAR) then 
            print("command contains blocked charectors")
            print("edit this in commands/what.lua BLOCKED_CHAR")
            return
        end
    (
        print("Are you sure you want to run this command?:"
        print(command)
        print("( y / n )")

        input = io.read()

        if not input == "y" then
            print(input) 
            return
        end
            
        local pipe = io.popen(command)
    
        if not pipe then
            print("command produced no output")
            return 
        end 

        local output = pipe:read(8192)

        -- send output and instruction prompt to llm
        -- print out llms explination of the output of the command 

        print("would you like to compare to your last commit to try to diagnose?:"
        print("( y / n )")

        input = io.read()

        if not input == "y" then
            print(input) 
            return
        end
            
        -- git add .
        -- local diff = git diff 

        -- send output prompt and diff to local llm 


        return
    end

}