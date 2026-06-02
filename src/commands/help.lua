-- commands/help.lua

-- Prints a list of all available commands that the app can call
-- Usage: luna help.lua [-usage]

return {
    description = "Shows this help message",
    run = function(app)
        print("Usage: luna <command>\n")
        print("Commands:")
        for name, command in pairs(app.commands) do
            print(string.format("  %-10s %s", name, command.description or ""))
        end

    end
}