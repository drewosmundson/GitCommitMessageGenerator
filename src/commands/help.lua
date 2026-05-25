-- help.lua

-- Prints a list of all available commands that the app can call
-- Usage: luna help.lua [-usage]


return {
    description = "Show this help message",
    run = function(app)
        print("Usage: luna <command>\n")
        print("Commands:")
        for name, cmd in pairs(app.commands) do
            print(string.format("  %-20s %s", name, cmd.description))
        end
    end
}
