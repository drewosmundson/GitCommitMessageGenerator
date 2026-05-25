-- commands/find.lua
return {
    description = "Find name accross package registries",
    run = function(app, name)
        local utils     = app.utils
        local constants = app.constants

        if not name then
            print("Usage: <script> find <name>")
            return false
        end

        if name:match("[^%w%-_]") then
            print("Error: Invalid name. Use only letters, numbers, hyphens, and underscores.")
            return false
        end

        print(string.format("Checking availability for: '%s'\n", name))
        print(string.format("%-18s %-12s %-30s", "Registry", "Status", "Verdict"))
        print(string.rep("-", 60))

        for registry_name, urls in pairs(constants.REGISTRIES) do
            local check_url = string.format(urls.check, name)
            local link_url  = string.format(urls.link,  name)
            local status    = utils.getHttpStatus(check_url)

            if status == 404 then
                print(string.format("%-18s \27[32m%-12s\27[0m %-30s",
                    registry_name, "404", "Available"))
            elseif status == 200 then
                local verdict = string.format("TAKEN  %s", utils.hyperlink(link_url, link_url))
                print(string.format("%-18s \27[31m%-12s\27[0m %s",
                    registry_name, "200", verdict))
            else
                print(string.format("%-18s \27[33m%-12s\27[0m %-30s",
                    registry_name, tostring(status), "Unknown or Error"))
            end
        end

        return true
    end
}