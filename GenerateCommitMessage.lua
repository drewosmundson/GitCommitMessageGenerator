


function main()
    if not checkDependancies() then return end

    createFile(fileName)


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

    end

    function ollama()

    end

    function 
end