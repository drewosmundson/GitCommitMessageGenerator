


return {
    description = "Uncommits the most recent git commit via git reset --soft HEAD~1",
    run = function(app, flag)
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
}








