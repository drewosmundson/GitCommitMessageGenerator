
-- module that contains all the commands for this script.

-- This table contains all the functions in this 'command' namespace to add a new command to create a new fuction
-- named commmands."your function name here"
-- input parameters are flags and aditional information passed
-- Usage example: 

-- $ AliasName commitMessageGenerate -I ""






local Commands = {}

function Commands.gitCommitMessage()
    os.execute("git add .") 

    local modifiedFiles = {}
    
    handle = ipopen("git status --porcelain)

    for line in handle:lines() do
        if line:sub(1, 2) == "MM" then
            table.insert(modifiedFiles, line:sub(4))
        end
    end
    
    
    

    return 
end

function Commands.addComments()
    return
end



function Commands.help()
  

end
-- Deletes specified Command or built in Prompt
function Commands.delete()

end


function Commands.add()
-- function Commands.yourCommandName(x)
--    return
-- end

return Commands




local prompts = {


"You generate a single git commit message from structured repository change data.

Rules:
- Output must follow Conventional Commits style.
- Choose type based on changes:
  feat: new functionality
  fix: bug fix
  refactor: no behavior change
  docs: documentation only
  test: tests only
  chore: tooling, build, config
- Be concise. No fluff.
- Subject line max 72 characters.
- Use imperative mood ("add", "fix", "remove").
- Do not invent changes not present in input.
- If unclear, default to refactor.", 

