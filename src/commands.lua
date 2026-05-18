

-- module that contains all the commands for this script.

-- This table contains all the functions in this 'command' namespace to add a new command to create a new fuction
-- named commmands."your function name here"
-- input parameters are flags and aditional information passed
-- Usage example: 

-- $ AliasName commitMessageGenerate -I ""

local Commands = {}

function Commands.gitCommitMessage()
    return 
end

function Commands.addComments()
    return
end

-- creates a new prompt to be added to the promts.lua file
function Commands.newPrompt()
  -- check if prompts.lua exists if not create file
  -- check if user provieded a title if not prompt for title
  -- check if title already exists in prompts .lua if true prompt user for different title
  -- add prompt and title to table of prompts 
end
-- lists names of commands or titles of prompts
function Commands.ls()
  

end
-- Deletes specified Command or built in Prompt
function Commands.delete()

end

-- function Commands.yourCommandName(x)
--    return
-- end

return Commands

