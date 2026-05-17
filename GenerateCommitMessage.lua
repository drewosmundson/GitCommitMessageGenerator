

local http = require("socket.http")

local ollamaApiUrl = "http://127.0.0.1:11434/api/ps" 

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

    local function isAiInstalled(ollamaApiUrl)
      local body, code = http.request()

      if code == 200 then
      -- Match JSON like:
      --   "name": "llama3:8b"
      --
      -- Pattern breakdown:
      --   "name"      -> match the literal key "name"
      --   %s*         -> match optional whitespace
      --   :           -> match the colon
      --   %s*         -> match optional whitespace again
      --   "([^"]+)"   -> capture everything inside the quotes
      --                  [^"]  = any character except "
      --                  +     = one or more characters
      --                  ()    = return/capture this part
      --
      -- Result:
      --   returns only: llama3:8b
          local model = body:match('"name"%s*:%s*"([^"]+)"')

          return model;
      end
end