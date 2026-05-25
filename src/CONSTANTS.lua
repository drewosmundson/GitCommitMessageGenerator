

local constants = {
    COMMAND_LIST = {
        "commit",
        "undo",
        "find",
        "comment",
        "chat",
        "help",
    },

    OLLAMA_URL = "http://127.0.0.1:11434",

    -- Registry table: check URL (for HTTP probe) + link URL (shown when taken)
    REGISTRIES = {
        ["Cargo (Rust)"]   = { check = "https://crates.io/crates/%s",              link = "https://crates.io/crates/%s" },
        ["PyPI (Python)"]  = { check = "https://pypi.org/project/%s",              link = "https://pypi.org/project/%s" },
        ["LuaRocks (Lua)"] = { check = "https://luarocks.org/modules/luarocks/%s", link = "https://luarocks.org/modules/luarocks/%s" },
        ["npm (Node.js)"]  = { check = "https://registry.npmjs.org/%s",            link = "https://npmjs.com/package/%s" },
        ["GitHub (Repo)"]  = { check = "https://github.com/%s",                    link = "https://github.com/%s" },
    },

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

return constants