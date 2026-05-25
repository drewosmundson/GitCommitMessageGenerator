

-- commands/commit.lua
return {
    description = "Generates a commit message from the diff since the last commit using the installed LLM",
    run = function(app, flag)
        local json      = require("dkjson")
        local utils     = app.utils
        local constants = app.constants
        local config    = app.config

        os.execute("git add .")

        local handle = io.popen("git diff --staged")
        local diff = handle:read("*a")
        handle:close()

        if diff == "" then
            print("No staged changes detected. Save your changes before running this command.")
            return false
        end

        local prompt = string.format(constants.GIT_COMMIT_INSTRUCTIONS, diff)
        local body = json.encode({
            model  = config.PREFERRED_AI_MODEL,
            prompt = prompt,
            stream = false,
        })

        print("Generating commit message...")
        print("MODEL:", config.PREFERRED_AI_MODEL)
        print("PROMPT:")
        print(prompt)
        local responseRaw = utils.postJson(constants.OLLAMA_URL .. "/api/generate", body)
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
}