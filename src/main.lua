local http = require("socket.http")
local json = require("dkjson")

local CONFIG = dofile("CONFIG.lua")

local OLLAMA_URL = CONFIG.OLLAMA_URL
local PREFERRED_AI_MODEL = CONFIG.PREFERRED_AI_MODEL


-------------------- UTILS -----------------------

local function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

local function savePreferredModel(model)
    local file = io.open("CONFIG.lua", "w")
    file:write(string.format(
    [[return {
      OLLAMA_URL = "http://127.0.0.1:11434",
      PREFERRED_AI_MODEL = "%s",
    }]], model))
    file:close()
end

local function promtUserForModelSelection(availableModels)
    print("Enter the number of the model you would like to use:")
    print("This will update your CONFIG.lua to your selected model")
    for key, value in pairs(availableModels) do
        print(key, value)
    end

    local choice = tonumber(io.read())
    while choice == nil or availableModels[choice] == nil do
        print("Invalid selection. Enter a number from the list:")
        for key, value in pairs(availableModels) do
            print(key, value)
        end
        choice = tonumber(io.read())
    end

    local model = availableModels[choice]
    savePreferredModel(model)
    return model
end

local function getJson(url)
    local body, code = http.request(url)
    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)
    if err then error("JSON decode failed: " .. err) end

    return data
end

local function postJson(url, body)
    local responseBody = {}
    local _, code = http.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(responseBody),
    })
    if code ~= 200 then
        error("Ollama request failed with code: " .. tostring(code))
    end
    return table.concat(responseBody)
end

local function isInstalled(dependency)
    result = os.execute(dependency .. " --version > /dev/null 2>&1")
    if result == true or result == 0 then
        return true
    else
        print(dependency .. " is required")
        print("run install.lua or install dependencies manually")
        return false
    end
end

-- Registry table: check URL (for HTTP probe) + link URL (shown when taken)
local REGISTRIES = {
    ["Cargo (Rust)"]   = { check = "https://crates.io/crates/%s",              link = "https://crates.io/crates/%s" },
    ["PyPI (Python)"]  = { check = "https://pypi.org/project/%s",              link = "https://pypi.org/project/%s" },
    ["LuaRocks (Lua)"] = { check = "https://luarocks.org/modules/luarocks/%s", link = "https://luarocks.org/modules/luarocks/%s" },
    ["npm (Node.js)"]  = { check = "https://registry.npmjs.org/%s",            link = "https://npmjs.com/package/%s" },
    ["GitHub (Repo)"]  = { check = "https://github.com/%s",                    link = "https://github.com/%s" },
}

local function getHttpStatus(url)
    local cmd = string.format("curl -s -o /dev/null -w '%%{http_code}' -L --max-time 5 '%s'", url)
    local handle = io.popen(cmd)
    if not handle then return 0 end
    local result = handle:read("*a")
    handle:close()
    return tonumber(result) or 0
end

local function hyperlink(url, text)
    return string.format("\27]8;;%s\27\\%s\27]8;;\27\\", url, text)
end


---------- DEPENDENCY CHECKS --------------------

function checkDependencies()
    if not isInstalled("git") then return false end
    if not isInstalled("ollama") then return false end

    local data = getJson(OLLAMA_URL .. "/api/tags")
    local availableModels = {}
    for _, m in ipairs(data.models or {}) do
        table.insert(availableModels, m.name)
    end

    if next(availableModels) == nil then
        print("No Models Available at: " .. OLLAMA_URL)
        return false
    end

    if not tableContains(availableModels, PREFERRED_AI_MODEL) then
        print("Your preferred AI model is not available, you can change it in CONFIG.lua")
        PREFERRED_AI_MODEL = promtUserForModelSelection(availableModels)
    end

    return true
end


---------- PROMPTS --------------------

local PROMPTS = {
    GIT_COMMIT_INSTRUCTIONS = [[
        You generate a single git commit message from a git diff.
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
        - Do not invent changes not present in the diff.
        - If unclear, default to refactor.
        - Output ONLY the commit message. No explanation, no formatting.

        <diff>
        %s
        </diff>
    ]],
}

local GIT_COMMIT_INSTRUCTIONS = PROMPTS.GIT_COMMIT_INSTRUCTIONS


---------- COMMANDS --------------------

local function createJsonBody(model, prompt)
    return json.encode({
        model = model,
        prompt = prompt,
        stream = false,
    })
end

local Commands = {}

function Commands.commit()
    os.execute("git add .")

    local handle = io.popen("git diff --staged")
    local diff = handle:read("*a")
    handle:close()

    if diff == "" then
        print("No staged changes detected. Save your changes before running this command.")
        return false
    end

    local prompt = string.format(GIT_COMMIT_INSTRUCTIONS, diff)
    local body = createJsonBody(PREFERRED_AI_MODEL, prompt)

    print("Generating commit message...")

    local responseRaw = postJson(OLLAMA_URL .. "/api/generate", body)
    local response, _, err = json.decode(responseRaw)

    if err or not response then
        print("Failed to parse Ollama response: " .. tostring(err))
        return false
    end

    local message = response.response and response.response:match("^%s*(.-)%s*$")

    if not message or message == "" then
        print("No commit message returned from model.")
        return false
    end

    print("\nSuggested commit message:\n")
    print("  " .. message)
    print("\nCommit with this message? (y/n): ")

    local confirm = io.read()
    if confirm:lower() == "y" then
        local commitCmd = string.format('git commit -m "%s"', message:gsub('"', '\\"'))
        os.execute(commitCmd)
        print("Committed!")
    else
        print("Commit cancelled.")
    end

    return true
end

function Commands.undo()
    local handle = io.popen("git log --oneline -1")
    local lastCommit = handle:read("*a"):match("^%s*(.-)%s*$")
    handle:close()

    if lastCommit == "" then
        print("No commits to undo.")
        return false
    end

    print("Last commit: " .. lastCommit)
    print("Undo this commit? Changes will be kept staged. (y/n): ")

    local confirm = io.read()
    if confirm:lower() ~= "y" then
        print("Undo cancelled.")
        return false
    end

    local result = os.execute("git reset --soft HEAD~1")
    if result == true or result == 0 then
        print("Commit undone. Your changes are still staged.")
    else
        print("Failed to undo commit.")
        return false
    end

    return true
end



function Commands.isNameAvailable()
    local name = arg[2]

    if not name then
        print("Usage: <script> isNameAvailable <name>")
        return false
    end

    if name:match("[^%w%-_]") then
        print("Error: Invalid name. Use only letters, numbers, hyphens, and underscores.")
        return false
    end

    print(string.format("Checking availability for: '%s'\n", name))
    print(string.format("%-18s %-12s %-30s", "Registry", "Status", "Verdict"))
    print(string.rep("-", 60))

    for registry_name, urls in pairs(REGISTRIES) do
        local check_url = string.format(urls.check, name)
        local link_url  = string.format(urls.link,  name)
        local status    = getHttpStatus(check_url)

        if status == 404 then
            print(string.format("%-18s \27[32m%-12s\27[0m %-30s",
                registry_name, "404", "Available"))
        elseif status == 200 then
            local verdict = string.format("TAKEN  %s", hyperlink(link_url, link_url))
            print(string.format("%-18s \27[31m%-12s\27[0m %s",
                registry_name, "200", verdict))
        else
            print(string.format("%-18s \27[33m%-12s\27[0m %-30s",
                registry_name, tostring(status), "Unknown or Error"))
        end
    end

    return true
end

function Commands.addComments()
    -- TODO: add comments to your file
end

function Commands.chat()
    -- TODO: starts a chat stream, clears history when finished
end

function Commands.help()
    print("Available commands:")
    for name, _ in pairs(Commands) do
        print("  " .. name)
    end
end

function Commands.usage()
    print("Available commands:")
    for name, _ in pairs(Commands) do
        print("  " .. name)
    end
end


---------- MAIN --------------------

function main()
    if not checkDependencies() then return end

    local userArg = arg[1]

    if userArg == nil then
        Commands.help()
        return
    end

    if not Commands[userArg] then
        print(string.format("'%s' is not a valid command.", tostring(userArg)))
        Commands.help()
        return
    end

    Commands[userArg]()
end

main()