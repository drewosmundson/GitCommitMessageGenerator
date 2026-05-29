
local http = require("socket.http")
local json = require("dkjson")


local httpUtils = {}

function httpUtils.getJson(url)
    local body, code = http.request(url)
    if code ~= 200 then error("Request failed: " .. tostring(code)) end

    local data, _, err = json.decode(body)
    if err then error("JSON decode failed: " .. err) end

    return data
end

function httpUtils.postJson(url, body)
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


function httpUtils.getHttpStatus(url)
    local cmd = string.format("curl -s -o /dev/null -w '%%{http_code}' -L --max-time 5 '%s'", url)
    local handle = io.popen(cmd)
    if not handle then return 0 end
    local result = handle:read("*a")
    handle:close()
    return tonumber(result) or 0
end



return httpUtils