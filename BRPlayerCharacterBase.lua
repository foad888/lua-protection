local GITHUB_USERNAME = "iip44323-lab"
local GITHUB_REPO = "DevClayBypas"
local GITHUB_BRANCH = "main"

local GITHUB_BASE = "https://raw.githubusercontent.com/" ..
                    GITHUB_USERNAME .. "/" ..
                    GITHUB_REPO .. "/" ..
                    GITHUB_BRANCH .. "/"

local PROTECTION_FILES = {
    { name = "ClayBypass", path = "ClayBypass.lua" },
    { name = "CharacterBase", path = "CharacterBase.lua" },
}

local function LoadProtection(name, path)
    local url = GITHUB_BASE .. path
    if _G.HttpRequest then
        _G.HttpRequest(url, function(success, data)
            if success and data and #data > 0 then
                local fn, err = loadstring(data)
                if fn then
                    local ok, result = pcall(fn)
                    if ok then
                        print("[CLAY] ✅ " .. name .. " loaded")
                        return
                    else
                        print("[CLAY] ❌ " .. name .. " error: " .. tostring(result))
                    end
                else
                    print("[CLAY] ❌ " .. name .. " syntax: " .. tostring(err))
                end
            end
            print("[CLAY] ❌ " .. name .. " failed")
        end)
    end
end

local function LoadAllProtections()
    for _, protection in ipairs(PROTECTION_FILES) do
        LoadProtection(protection.name, protection.path)
    end
end

pcall(LoadAllProtections)
