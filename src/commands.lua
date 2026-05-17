

-- module that contains all the commands for this script.

-- This table contains all the functions in this 'command' namespace to add a new command to create a new fuction
-- named commmands."your function name here"
-- input parameters are flags and aditional information passed
-- Usage example: 

-- $ AliasName commitMessageGenerate -I ""

local commands = {} 

function Commands.gitCommitMessage(a, b)
    return a + b
end

function Commands.newUserPrompt()

end

-- lists names of commands or titles of prompts
function Commands.ls()

end
-- deletes specified Command or built inPrompt
function Commands.delete()

function Commands.subtract(a, b)
    return a - b
end

function Commands.yourCommandName(x)
  return x

return Commands
