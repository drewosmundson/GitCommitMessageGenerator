





local PROMPTS = {
    FIND_MEANING = [[
        Given the output from the terminal explain what the meaning of the output is and if possible determine or speculate on what the bug might be and if possible make a suggestion on how to fix.
        Rules: 
        - Max 300 words.
        - Be concise. No fluff.
        - Suggest the simplest possible fix no odd syntactical behaviors.
    ]]
}

return {
    description = "Given the previous output of the terminal explain what its meaning is",


    run = function(app, args)
    
        local command = table.concat(arg, " ", 2)
        
        local pipe = io.popen(command)

        local output = pipe:read("*a")
        pipe:close()

        local pipe = io.popen("git add .") 
        local diff = pipe:read("*a") 
        -- send output to LLM for analysis 

        io.popen("git reset") 


    print(output)
    
    end
}