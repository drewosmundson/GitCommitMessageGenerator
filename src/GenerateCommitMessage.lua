

local http = require("socket.http")
local json = require("dksjson")
local CONFIG = dofile("config")

function main()
    if not checkDependancies() then return end
end


function checkDependencies()
    if not isInstalled("git") then return false end
    if not isInstalled("ollama") then return false end

    local availableModels = getJsonDataFromURL(OLLAMA_URL .. "/api/tags")

    if next(availableModels) == nil
        then print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    local perferdAiModel = CONFIG.PREFERED_AI_MODEL

    if not isPreferdModelAvailable(availableModels) then return false end
        then perferdAiModel = promtUserForModelSelection() 
    end
end


local function isInstalled(dependency) 
    -- > /dev/null 2>&1 suppresses output from the command
    result = os.execute(dependancy .. " --version > /dev/null 2>&1")
    -- depending on the version of lua this could return 0 or true on success
    if result == true or result == 0 
        then return true
        else print(dependancy .. " is required") return false
    end
end


local function getJsonDataFromURL(url)
    local body, code = http.request(url)

    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)

    if err then error("JSON decode failed: " .. err) end

    return data
end

local function isPreferdAiInstalled(availableModels)
    

end




