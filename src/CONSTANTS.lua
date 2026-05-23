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

return PROMPTS