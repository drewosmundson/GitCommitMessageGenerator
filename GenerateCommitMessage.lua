


function main()
    if not checkDependancies() then return end

    local remotePull = 'lastremotetemp.txt'
    local localChanges = 'localchangestemp.txt'
    createFile(remotePull)
    createFile(localChanges) 



end

function checkDependencies()
    if not isInstalled("git") then return false end
    if not isInstalled("ollama") then return false end
    if not isAiInstalled() then return false end

    local function isInstalled(dependency) 
        -- > /dev/null 2>&1 suppresses output from the command
        result = os.execute(dependancy .. " --version > /dev/null 2>&1")
        if result == true or result == 0 
            then  return true
            else print(dependancy .. " is required") return false
        end

    local function isAiInstalled()
        

end