-- commands/find.lua


local REGISTRIES = {
    ["Cargo (Rust)"]   = { check = "https://crates.io/crates/%s",              link = "https://crates.io/crates/%s" },
    ["PyPI (Python)"]  = { check = "https://pypi.org/project/%s",              link = "https://pypi.org/project/%s" },
    ["LuaRocks (Lua)"] = { check = "https://luarocks.org/modules/luarocks/%s", link = "https://luarocks.org/modules/luarocks/%s" },
    ["npm (Node.js)"]  = { check = "https://registry.npmjs.org/%s",            link = "https://npmjs.com/package/%s" },
    ["GitHub (Repo)"]  = { check = "https://github.com/%s",                    link = "https://github.com/%s" },
}


return {
    description = "Find name accross package registries",
    run = function(app, flag)
        local name = flag

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
            local status    = app.HTTP.getHttpStatus(check_url)

            if status == 404 then
                print(string.format("%-18s \27[32m%-12s\27[0m %-30s",
                    registry_name, "404", "Available"))
            elseif status == 200 then
                local verdict = string.format("TAKEN  %s", string.format("\27]8;;%s\27\\%s\27]8;;\27\\", link_url, link_url))
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