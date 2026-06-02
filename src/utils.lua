
local lfs = require("lfs")

local utils = {}

function utils.getLuaFilesFromDirectory(path)
    local files = {}
    for filename in lfs.dir(path) do
        -- Ignore the default '.' (current) and '..' (parent) directory markers
        if filename ~= "." and filename ~= ".." then
            table.insert(files, filename)
        end
    end
    return files
end

function utils.loadModulesFromFileTable(path, fileTable)
    local loadedModules = {}

    for _, filename in ipairs(fileTable) do
        -- Match files ending in .lua and extract the name without extension
        local moduleName = filename:match("(.+)%.lua$")

        if moduleName then
            print("Loading module: " .. moduleName)
            loadedModules[moduleName] = require(path .. "." .. moduleName)
        end
    end
    return loadedModules -- usage: loadedModules["script"].functionName()
end



function utils.tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end


return utils