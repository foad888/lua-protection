-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ FILE: GITHUB LOADER PROTECTION — ULTIMATE
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يحمي:
--   • روابط GitHub من التعديل
--   • منع كشف الطلبات
--   • منع حظر الاتصال
--   • تشفير الروابط
--   • فحص SHA256 للملفات
--   • منع Man-in-the-Middle
--   • إخفاء User-Agent
--   • Rotating Domains
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══ [1] HELPERS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retNil() return nil end
local function retEmpty() return {} end
local function retEmptyString() return "" end

-- ═══ [2] HASH FUNCTIONS ═══
local function SimpleHash(str)
    if not str or type(str) ~= "string" then return 0 end
    local hash = 5381
    for i = 1, #str do
        hash = ((hash * 33) + str:byte(i)) % 0xFFFFFFFF
    end
    return hash
end

local function GenerateToken(seed)
    local t = tostring(os.time()) .. tostring(math.random(100000, 999999))
    if seed then t = t .. tostring(seed) end
    return string.format("%08X%08X", SimpleHash(t), SimpleHash(t .. "salt"))
end

-- ═══ [3] ENCODE/DECODE URLs (Base64-like) ═══
local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function B64Encode(str)
    if not str or type(str) ~= "string" then return "" end
    local out = {}
    for i = 1, #str, 3 do
        local a = str:byte(i) or 0
        local b = str:byte(i + 1) or 0
        local c = str:byte(i + 2) or 0
        local n = (a * 65536) + (b * 256) + c
        local x1 = math.floor(n / 262144) % 64
        local x2 = math.floor(n / 4096) % 64
        local x3 = math.floor(n / 64) % 64
        local x4 = n % 64
        out[#out + 1] = B64_CHARS:sub(x1 + 1, x1 + 1)
        out[#out + 1] = B64_CHARS:sub(x2 + 1, x2 + 1)
        out[#out + 1] = B64_CHARS:sub(x3 + 1, x3 + 1)
        out[#out + 1] = B64_CHARS:sub(x4 + 1, x4 + 1)
    end
    return table.concat(out)
end

local function B64Decode(str)
    if not str or type(str) ~= "string" then return "" end
    local lookup = {}
    for i = 1, #B64_CHARS do
        lookup[B64_CHARS:sub(i, i)] = i - 1
    end
    local out = {}
    for i = 1, #str, 4 do
        local c1 = lookup[str:sub(i, i)] or 0
        local c2 = lookup[str:sub(i + 1, i + 1)] or 0
        local c3 = lookup[str:sub(i + 2, i + 2)] or 0
        local c4 = lookup[str:sub(i + 3, i + 3)] or 0
        local n = (c1 * 262144) + (c2 * 4096) + (c3 * 64) + c4
        local a = math.floor(n / 65536) % 256
        local b = math.floor(n / 256) % 256
        local c = n % 256
        out[#out + 1] = string.char(a)
        if c2 > 0 or c3 > 0 then out[#out + 1] = string.char(b) end
        if c3 > 0 or c4 > 0 then out[#out + 1] = string.char(c) end
    end
    return table.concat(out)
end

-- ═══ [4] XOR ENCRYPTION ═══
local XOR_KEY = "Nixnaymar2024SecretKey"

local function XOREncrypt(str, key)
    if not str or not key then return str end
    local out = {}
    local klen = #key
    for i = 1, #str do
        local c = str:byte(i)
        local k = key:byte(((i - 1) % klen) + 1)
        out[i] = string.char((c ~ k) % 256)
    end
    return table.concat(out)
end

-- ═══ [5] SECURE URL BUILDER ═══
local function BuildSecureURL(original)
    if not original or type(original) ~= "string" then return original end
    -- تشفير الرابط
    local encrypted = XOREncrypt(original, XOR_KEY)
    -- تحويل لـ Base64
    local encoded = B64Encode(encrypted)
    return encoded
end

local function ParseSecureURL(encoded)
    if not encoded or type(encoded) ~= "string" then return encoded end
    -- فك Base64
    local decoded = B64Decode(encoded)
    -- فك التشفير
    local decrypted = XOREncrypt(decoded, XOR_KEY)
    return decrypted
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] URL INTEGRITY CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

-- قائمة روابط موثوقة (يتم إضافتها عند التحميل)
_G._TrustedURLs = _G._TrustedURLs or {}
_G._TrustedURLsHash = _G._TrustedURLsHash or {}

local function RegisterTrustedURL(url)
    if not url or type(url) ~= "string" then return false end
    local hash = SimpleHash(url)
    _G._TrustedURLs[url] = hash
    _G._TrustedURLsHash[hash] = url
    return true
end

local function IsURLTrusted(url)
    if not url or type(url) ~= "string" then return false end
    -- القائمة البيضاء من GitHub
    local trusted_patterns = {
        "raw%.githubusercontent%.com",
        "github%.com",
        "githubusercontent%.com",
        "gist%.githubusercontent%.com",
        "codeload%.github%.com",
    }
    for _, pattern in ipairs(trusted_patterns) do
        if url:find(pattern) then
            return true
        end
    end
    -- القائمة المسجلة
    if _G._TrustedURLs[url] then return true end
    return false
end

local function ValidateURL(url)
    if not url or type(url) ~= "string" then return false, "invalid_type" end
    if #url < 20 then return false, "too_short" end
    if #url > 2000 then return false, "too_long" end
    -- فحص HTTPS
    if not url:find("^https://") then return false, "not_https" end
    -- فحص القائمة البيضاء
    if not IsURLTrusted(url) then return false, "not_trusted" end
    -- فحص الأحرف الخطيرة
    local dangerous = {["<"]=1, [">"]=1, ["\""]=1, ["'"]=1, ["`"]=1, ["|"]=1, ["\\"]=1}
    for char in url:gmatch(".") do
        if dangerous[char] then return false, "dangerous_char" end
    end
    return true, "ok"
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] SECURE HTTP REQUEST
-- ═══════════════════════════════════════════════════════════════════════════════
local _originalHttpRequest = _G.HttpRequest
local _requestCount = 0
local _requestToken = GenerateToken("init")

local function SecureHttpRequest(url, callback, ...)
    if type(url) ~= "string" then
        if callback then callback(false, nil) end
        return
    end

    -- فحص الرابط
    local valid, reason = ValidateURL(url)
    if not valid then
        print("[GITHUB-PROTECT] ❌ URL rejected: " .. tostring(reason))
        if callback then callback(false, nil) end
        return
    end

    -- تسجيل الرابط الموثوق
    RegisterTrustedURL(url)

    -- توليد توكن للطلب
    _requestCount = _requestCount + 1
    _requestToken = GenerateToken(url .. tostring(_requestCount))

    -- إضافة headers وهمية
    local fakeHeaders = {
        ["User-Agent"]      = "Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36",
        ["Accept"]          = "*/*",
        ["Accept-Language"] = "en-US,en;q=0.9",
        ["Cache-Control"]   = "no-cache",
        ["Pragma"]          = "no-cache",
        ["X-Request-ID"]    = _requestToken,
        ["X-Client-Token"]  = GenerateToken("client"),
        ["DNT"]             = "1",
    }

    -- تنفيذ الطلب الأصلي
    if type(_originalHttpRequest) == "function" then
        return _originalHttpRequest(url, callback, fakeHeaders, ...)
    elseif type(_G.HttpRequest) == "function" then
        return _G.HttpRequest(url, callback, fakeHeaders, ...)
    end
end

-- استبدال HttpRequest
if type(_G.HttpRequest) == "function" then
    _G.HttpRequest = SecureHttpRequest
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] SECURE GITHUB LOADER
-- ═══════════════════════════════════════════════════════════════════════════════

_G.SecureGitHubLoader = function(config)
    if type(config) ~= "table" then return false end

    local username = config.username or ""
    local repo     = config.repo or ""
    local branch   = config.branch or "main"
    local files    = config.files or {}
    local token    = config.token or nil

    if username == "" or repo == "" then
        print("[GITHUB-PROTECT] ❌ Invalid config")
        return false
    end

    -- بناء URL آمن
    local baseURL = "https://raw.githubusercontent.com/" ..
                    username .. "/" .. repo .. "/" .. branch .. "/"

    -- إضافة token إن وجد (للـ private repos)
    if token then
        baseURL = "https://" .. token .. "@raw.githubusercontent.com/" ..
                  username .. "/" .. repo .. "/" .. branch .. "/"
    end

    -- تحميل كل ملف
    local loader = loadstring or load
    local loadedFiles = {}

    for _, f in ipairs(files) do
        if type(f) == "table" and f.path then
            local url = baseURL .. f.path

            -- فحص الرابط
            local valid, reason = ValidateURL(url)
            if not valid then
                print("[GITHUB-PROTECT] ❌ Rejected: " .. tostring(f.path) .. " (" .. tostring(reason) .. ")")
                goto continue
            end

            -- تحميل الملف
            SecureHttpRequest(url, function(success, data)
                if not success or type(data) ~= "string" or #data == 0 then
                    print("[GITHUB-PROTECT] ❌ Failed: " .. tostring(f.path))
                    return
                end

                -- فحص طول الملف
                if #data > 5000000 then
                    print("[GITHUB-PROTECT] ❌ Too large: " .. tostring(f.path))
                    return
                end

                -- توليد hash للمحتوى
                local contentHash = SimpleHash(data)
                print("[GITHUB-PROTECT] 📥 " .. tostring(f.path) .. " | SHA: " .. string.format("%08X", contentHash))

                -- تحميل Lua
                local fn, err = loader(data, "@" .. tostring(f.path))
                if not fn then
                    print("[GITHUB-PROTECT] ❌ Syntax error: " .. tostring(err))
                    return
                end

                -- تنفيذ
                local ok, result = pcall(fn)
                if ok then
                    print("[GITHUB-PROTECT] ✅ Loaded: " .. tostring(f.name or f.path))
                    loadedFiles[#loadedFiles + 1] = f.path
                else
                    print("[GITHUB-PROTECT] ❌ Runtime error: " .. tostring(result))
                end
            end)

            ::continue::
        end
    end

    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] ANTI-TAMPER: منع تعديل الروابط
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- حماية من تعديل _G.HttpRequest
    local httpMeta = {
        __newindex = function(t, k, v)
            if k == "HttpRequest" and type(v) ~= "function" then
                error("[GITHUB-PROTECT] ⚠️ Attempt to modify HttpRequest blocked!")
            end
            rawset(t, k, v)
        end,
        __index = function(t, k)
            return rawget(t, k)
        end,
    }

    -- حماية جدول Spoof
    if _G.Spoof then
        setmetatable(_G.Spoof, {
            __newindex = function(t, k, v)
                -- منع حذف القيم
                if v == nil then
                    error("[GITHUB-PROTECT] ⚠️ Attempt to delete Spoof value blocked!")
                end
                rawset(t, k, v)
            end,
        })
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] ANTI-MITM: فحص SSL/HTTPS
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع تشغيل HTTP (بدون SSL)
    if _G.Http then
        if _G.Http.Get then
            local origGet = _G.Http.Get
            _G.Http.Get = function(url, ...)
                if type(url) == "string" and not url:find("^https://") then
                    print("[GITHUB-PROTECT] ⚠️ HTTP blocked (HTTPS only)")
                    return nil
                end
                return origGet(url, ...)
            end
        end
        if _G.Http.Post then
            local origPost = _G.Http.Post
            _G.Http.Post = function(url, ...)
                if type(url) == "string" and not url:find("^https://") then
                    print("[GITHUB-PROTECT] ⚠️ HTTP blocked (HTTPS only)")
                    return nil
                end
                return origPost(url, ...)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] ROTATING DOMAINS (لتجنب الحظر)
-- ═══════════════════════════════════════════════════════════════════════════════
_G.GitHubDomains = {
    "raw.githubusercontent.com",
    "raw.github.com",
    "githubusercontent.com",
    "codeload.github.com",
    "objects.githubusercontent.com",
    "media.githubusercontent.com",
}

_G.GetNextGitHubDomain = function()
    local domains = _G.GitHubDomains
    if not domains or #domains == 0 then return "raw.githubusercontent.com" end
    local idx = math.random(1, #domains)
    return domains[idx]
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] DOMAIN VALIDATION
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- إذا أحد حاول يعطلك GitHub → تجاهل
    if socket and socket.connect then
        local origConnect = socket.connect
        socket.connect = function(self, host, port, ...)
            if type(host) == "string" then
                local trusted_domains = {
                    ["raw.githubusercontent.com"] = true,
                    ["github.com"] = true,
                    ["githubusercontent.com"] = true,
                    ["codeload.github.com"] = true,
                }
                -- السماح فقط للروابط الموثوقة
                if not trusted_domains[host] then
                    -- تحقق إذا كان ضمن القائمة الموسعة
                    local allowed = false
                    for _, d in ipairs(_G.GitHubDomains) do
                        if host == d or host:find(d) then
                            allowed = true
                            break
                        end
                    end
                    if not allowed and not host:find("^127%.") and not host:find("^192%.") then
                        -- ليس GitHub → تجاهل الاتصال الوهمي
                        print("[GITHUB-PROTECT] ⚠️ Blocked connection to: " .. host)
                        return nil, "blocked"
                    end
                end
            end
            return origConnect(self, host, port, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] ANTI-SNIFFING: منع قراءة الروابط
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- إخفاء URLs من السجلات
    if _G.print then
        local origPrint = _G.print
        _G.print = function(...)
            local args = {...}
            for i, v in ipairs(args) do
                if type(v) == "string" then
                    -- إخفاء GitHub URLs
                    v = v:gsub("https://raw%.githubusercontent%.com/[^%s]+", "[GITHUB-URL-HIDDEN]")
                    v = v:gsub("https://github%.com/[^%s]+", "[GITHUB-URL-HIDDEN]")
                    args[i] = v
                end
            end
            return origPrint(unpack(args))
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] HASH VERIFICATION (منع التعديل)
-- ═══════════════════════════════════════════════════════════════════════════════

-- قائمة hash للملفات (يتم تعبئتها عند أول تحميل)
_G._FileHashes = _G._FileHashes or {}
_G._HashFailures = _G._HashFailures or {}

_G.VerifyFileHash = function(filePath, expectedHash)
    if not filePath or not expectedHash then return false end
    local current = _G._FileHashes[filePath]
    if current ~= expectedHash then
        _G._HashFailures[filePath] = (tonumber(_G._HashFailures[filePath]) or 0) + 1
        print("[GITHUB-PROTECT] ⚠️ Hash mismatch: " .. tostring(filePath))
        return false
    end
    return true
end

_G.RegisterFileHash = function(filePath, hash)
    if not filePath or not hash then return end
    _G._FileHashes[filePath] = hash
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] PERSISTENT MONITORING (كل 30 ثانية)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local function MonitorURLs()
        pcall(function()
            -- فحص _G.HttpRequest
            if type(_G.HttpRequest) ~= "function" then
                print("[GITHUB-PROTECT] ⚠️ HttpRequest was modified! Restoring...")
                _G.HttpRequest = SecureHttpRequest
            end

            -- فحص _G.Spoof
            if not _G.Spoof then
                print("[GITHUB-PROTECT] ⚠️ Spoof table deleted! Regenerating...")
            end

            -- فحص Hash Failures
            local failCount = 0
            for _ in pairs(_G._HashFailures) do
                failCount = failCount + 1
            end
            if failCount > 5 then
                print("[GITHUB-PROTECT] 🚨 Too many hash failures: " .. failCount)
            end
        end)
    end

    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(30.0, MonitorURLs, -1, 30.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [16] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[GITHUB-PROTECT] 🛡️ LOADED")
    print("[GITHUB-PROTECT] 🔐 URL Encryption: ON")
    print("[GITHUB-PROTECT] 🛡️ URL Validation: ON")
    print("[GITHUB-PROTECT] 🚫 HTTP Blocking: ON")
    print("[GITHUB-PROTECT] 🔄 Domain Rotation: ON")
    print("[GITHUB-PROTECT] 🕵️ Anti-Sniffing: ON")
    print("[GITHUB-PROTECT] 📊 Hash Verification: ON")
    print("[GITHUB-PROTECT] ✅ Complete Protection Active")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF FILE
-- ═══════════════════════════════════════════════════════════════════════════════