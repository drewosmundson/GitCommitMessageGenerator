


function main()
    if not checkDependancies() then return end

    local remotePull = 'lastremotetemp.txt'
    local localChanges = 'localchangestemp.txt'
    createFile(remotePull)
    createFile(localChanges) 




end

function checkDependencies()
    local dependencies = { 
        git,
        ollama,
        qwen,
    }
    for _, func in ipairs(dependsncies) 
        if not func() then return end
    end

    function git() 
        result = os.execute("git --version")
        if result 

    end

    function ollama()

    end

    function qwen()

    end

end