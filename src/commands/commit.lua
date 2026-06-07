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
-- commands/commit.lua
return {
    description = "Generates a commit message from the diff since the last commit using the installed LLM",

    run = function(app, arg)
        os.execute("git add .")

        local handle = io.popen("git diff --staged")
        local diff = handle:read("*a")
        handle:close()

        if diff == "" then
            print("No staged changes detected. Save your changes before running this command.")
            return false
        end

        print("Generating commit message...")

        local prompt = string.format(PROMPTS.GIT_COMMIT_INSTRUCTIONS, diff)
        local body = app.json.encode({
            model = app.PREFERRED_AI_MODEL,
            prompt = prompt,
            stream = false,
        })

        local responseRaw = app.http.postJson(app.OLLAMA_URL .. "/api/generate", body)
        local response, _, err = app.json.decode(responseRaw)

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
            local commitCmd = string.format(
                'git commit -m "%s"',
                message:gsub('"', '\\"')
            )

            local ok = os.execute(commitCmd)

            if ok then
                print("Committed!")
            else
                print("Commit failed.")
            end
        else
            print("Commit cancelled.")
        end

        return true
    end
}


