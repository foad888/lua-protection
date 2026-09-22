-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎭 IP + DEVICE INFO SPOOFER — ULTIMATE
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══ HELPERS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retEmptyString() return "" end

local function RandomHex(len)
    local chars = "0123456789ABCDEF"
    local out = {}
    for i = 1, len do
        local p = math.random(1, #chars)
        out[i] = chars:sub(p, p)
    end
    return table.concat(out)
end

local function RandomNum(len)
    local out = {}
    for i = 1, len do out[i] = tostring(math.random(0, 9)) end
    return table.concat(out)
end

local function RandomMAC()
    return string.format("%02X:%02X:%02X:%02X:%02X:%02X",
        math.random(0,255), math.random(0,255), math.random(0,255),
        math.random(0,255), math.random(0,255), math.random(0,255))
end

local function RandomIP()
    return tostring(math.random(1,223)) .. "." ..
           tostring(math.random(0,255)) .. "." ..
           tostring(math.random(0,255)) .. "." ..
           tostring(math.random(1,254))
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1] توليد هوية جديدة
-- ═══════════════════════════════════════════════════════════════════════════════
_G.NewSpoof = {
    -- 🌐 IP ADDRESS
    IP              = RandomIP(),
    PublicIP        = RandomIP(),
    LocalIP         = "192.168." .. math.random(0,255) .. "." .. math.random(1,254),
    GatewayIP       = "192.168.1.1",
    SubnetMask      = "255.255.255.0",
    DNS1            = "8.8.8.8",
    DNS2            = "8.8.4.4",
    MAC             = RandomMAC(),
    SSID            = "HomeWiFi_" .. RandomHex(4),

    -- 📱 DEVICE INFO
    DeviceID        = RandomHex(32),
    AndroidID       = RandomHex(16),
    HWID            = RandomHex(40),
    IMEI            = "35" .. RandomNum(13),
    IMSI            = "31015" .. RandomNum(10),
    Serial          = "R" .. RandomHex(11),
    UUID            = RandomHex(8).."-"..RandomHex(4).."-"..RandomHex(4).."-"..RandomHex(4).."-"..RandomHex(12),

    -- 📱 DEVICE DETAILS
    Model           = "SM-G998B",
    Brand           = "samsung",
    Manufacturer    = "samsung",
    Device          = "beyond1",
    Product         = "beyond1ltexx",
    Hardware        = "exynos2100",
    Board           = "exynos2100",
    Bootloader      = "G998BXXU5CVDD",
    Fingerprint     = "samsung/beyond1ltexx/beyond1:13/TP1A.220624.014/G998BXXU5CVDD:user/release-keys",
    Host            = "localhost",
    BuildID         = RandomHex(8),

    -- 💻 OS
    OSVersion       = "13",
    SDKInt          = "33",

    -- 🌍 REGION
    Country         = "US",
    Language        = "en-US",
    Timezone        = "UTC",

    -- 📡 NETWORK
    Carrier         = "Google",
    NetworkType     = "WiFi",

    -- 🖥️ SCREEN
    ScreenWidth     = "1440",
    ScreenHeight    = "3200",
    ScreenDensity   = "560",

    -- ⚙️ HARDWARE
    RAM             = "12288",
    Storage         = "512",
    BatteryLevel    = "100",
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- [2] SPOOF IP ADDRESS
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- Globals
    _G.GetLocalIP       = function() return _G.NewSpoof.LocalIP end
    _G.GetIPAddress     = function() return _G.NewSpoof.IP end
    _G.GetPublicIP      = function() return _G.NewSpoof.PublicIP end
    _G.GetExternalIP    = function() return _G.NewSpoof.PublicIP end
    _G.GetGatewayIP     = function() return _G.NewSpoof.GatewayIP end
    _G.GetSubnetMask    = function() return _G.NewSpoof.SubnetMask end
    _G.GetDNS           = function() return _G.NewSpoof.DNS1 end
    _G.GetMACAddress    = function() return _G.NewSpoof.MAC end
    _G.GetSSID          = function() return _G.NewSpoof.SSID end

    -- Network Module
    local Net = import("Network")
    if Net then
        Net.GetIPAddress    = function() return _G.NewSpoof.IP end
        Net.GetLocalIP      = function() return _G.NewSpoof.LocalIP end
        Net.GetPublicIP     = function() return _G.NewSpoof.PublicIP end
        Net.GetExternalIP   = function() return _G.NewSpoof.PublicIP end
        Net.GetGateway      = function() return _G.NewSpoof.GatewayIP end
        Net.GetSubnetMask   = function() return _G.NewSpoof.SubnetMask end
        Net.GetDNS          = function() return _G.NewSpoof.DNS1 end
        Net.GetMACAddress   = function() return _G.NewSpoof.MAC end
        Net.GetSSID         = function() return _G.NewSpoof.SSID end
        Net.GetBSSID        = function() return _G.NewSpoof.MAC end
        Net.GetHostname     = function() return "android-" .. RandomHex(6) end
        Net.GetNetworkType  = function() return "WiFi" end
        Net.GetCarrier      = function() return "Google" end
        Net.IsConnected     = retTrue
        Net.IsWiFi          = retTrue
        Net.IsVPN           = retFalse
        Net.IsProxy         = retFalse
        Net.GetNetworkStats = function() return { ping = 40, loss = 0, rtt = 40 } end
    end

    -- DNS Module
    local DNS = import("DNS")
    if DNS then
        DNS.Resolve      = function() return _G.NewSpoof.IP end
        DNS.GetIPAddress = function() return _G.NewSpoof.IP end
        DNS.GetHostName  = function() return "android-" .. RandomHex(6) end
        DNS.GetDNS1      = function() return _G.NewSpoof.DNS1 end
        DNS.GetDNS2      = function() return _G.NewSpoof.DNS2 end
    end

    -- Socket
    if socket then
        if socket.getpeername then
            local orig = socket.getpeername
            socket.getpeername = function(self, ...)
                local _, port = orig(self, ...)
                return _G.NewSpoof.IP, port
            end
        end
        if socket.getsockname then
            local orig = socket.getsockname
            socket.getsockname = function(self, ...)
                local _, port = orig(self, ...)
                return _G.NewSpoof.LocalIP, port
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [3] SPOOF DEVICE INFO
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local SI = import("SystemInfo")
    if SI then
        -- IDs
        SI.GetDeviceID        = function() return _G.NewSpoof.DeviceID end
        SI.GetDeviceId        = function() return _G.NewSpoof.DeviceID end
        SI.GetUniqueDeviceId  = function() return _G.NewSpoof.DeviceID end
        SI.GetAndroidID       = function() return _G.NewSpoof.AndroidID end
        SI.GetAndroidId       = function() return _G.NewSpoof.AndroidID end
        SI.GetIMEI            = function() return _G.NewSpoof.IMEI end
        SI.GetIMSI            = function() return _G.NewSpoof.IMSI end
        SI.GetMacAddress      = function() return _G.NewSpoof.MAC end
        SI.GetSerial          = function() return _G.NewSpoof.Serial end
        SI.GetUUID            = function() return _G.NewSpoof.UUID end

        -- Device
        SI.GetDeviceName      = function() return _G.NewSpoof.Model end
        SI.GetDeviceModel     = function() return _G.NewSpoof.Model end
        SI.GetModel           = function() return _G.NewSpoof.Model end
        SI.GetDeviceBrand     = function() return _G.NewSpoof.Brand end
        SI.GetBrand           = function() return _G.NewSpoof.Brand end
        SI.GetManufacturer    = function() return _G.NewSpoof.Manufacturer end
        SI.GetDevice           = function() return _G.NewSpoof.Device end
        SI.GetProduct         = function() return _G.NewSpoof.Product end
        SI.GetHardware        = function() return _G.NewSpoof.Hardware end
        SI.GetBoard           = function() return _G.NewSpoof.Board end
        SI.GetBootloader      = function() return _G.NewSpoof.Bootloader end
        SI.GetFingerprint     = function() return _G.NewSpoof.Fingerprint end
        SI.GetHost            = function() return _G.NewSpoof.Host end
        SI.GetBuildID         = function() return _G.NewSpoof.BuildID end

        -- OS
        SI.GetOSVersion       = function() return _G.NewSpoof.OSVersion end
        SI.GetSDKInt          = function() return _G.NewSpoof.SDKInt end

        -- Region
        SI.GetCountryCode     = function() return _G.NewSpoof.Country end
        SI.GetLanguageCode    = function() return _G.NewSpoof.Language end
        SI.GetTimeZone        = function() return _G.NewSpoof.Timezone end

        -- Network
        SI.GetNetworkType     = function() return _G.NewSpoof.NetworkType end
        SI.GetCarrier         = function() return _G.NewSpoof.Carrier end

        -- Screen
        SI.GetScreenWidth     = function() return _G.NewSpoof.ScreenWidth end
        SI.GetScreenHeight    = function() return _G.NewSpoof.ScreenHeight end
        SI.GetScreenDensity   = function() return _G.NewSpoof.ScreenDensity end

        -- Hardware
        SI.GetRAMSize         = function() return _G.NewSpoof.RAM end
        SI.GetStorageSize     = function() return _G.NewSpoof.Storage end
        SI.GetBatteryLevel    = function() return _G.NewSpoof.BatteryLevel end

        -- Security
        SI.IsEmulator         = retFalse
        SI.IsRooted           = retFalse
        SI.IsDebugged         = retFalse
        SI.IsJailbroken       = retFalse
        SI.IsDeveloperMode    = retFalse
    end

    -- DeviceID Module
    local DI = import("DeviceID")
    if DI then
        DI.GetDeviceID       = function() return _G.NewSpoof.DeviceID end
        DI.GetAndroidID      = function() return _G.NewSpoof.AndroidID end
        DI.GetIMEI           = function() return _G.NewSpoof.IMEI end
        DI.GetMACAddress     = function() return _G.NewSpoof.MAC end
        DI.GetUniqueDeviceID = function() return _G.NewSpoof.DeviceID end
        DI.GetDeviceName     = function() return _G.NewSpoof.Model end
        DI.GetDeviceModel    = function() return _G.NewSpoof.Model end
        DI.GetDeviceBrand    = function() return _G.NewSpoof.Brand end
        DI.GetDeviceSerial   = function() return _G.NewSpoof.Serial end
    end

    -- Kismet
    local KSL = import("KismetSystemLibrary")
    if KSL then
        KSL.GetDeviceId     = function() return _G.NewSpoof.DeviceID end
        KSL.GetMacAddress   = function() return _G.NewSpoof.MAC end
        KSL.GetSerialNumber = function() return _G.NewSpoof.Serial end
    end

    -- Client
    if Client then
        Client.GetPhoneDeviceID = function() return _G.NewSpoof.DeviceID end
        Client.GetDeviceID      = function() return _G.NewSpoof.DeviceID end
        Client.GetAndroidID     = function() return _G.NewSpoof.AndroidID end
        Client.GetIMEI          = function() return _G.NewSpoof.IMEI end
        Client.GetMacAddress    = function() return _G.NewSpoof.MAC end
    end

    -- TssSdk
    local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
    if TssSdk then
        TssSdk.GetDeviceInfo = function()
            return {
                deviceId    = _G.NewSpoof.DeviceID,
                androidId   = _G.NewSpoof.AndroidID,
                mac         = _G.NewSpoof.MAC,
                imei        = _G.NewSpoof.IMEI,
                model       = _G.NewSpoof.Model,
                brand       = _G.NewSpoof.Brand,
                fingerprint = _G.NewSpoof.Fingerprint,
            }
        end
        TssSdk.GetFingerprint = function() return _G.NewSpoof.Fingerprint end
        TssSdk.GetClientID    = function() return _G.NewSpoof.DeviceID end
        TssSdk.GetHWID        = function() return _G.NewSpoof.HWID end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [4] Globals
-- ═══════════════════════════════════════════════════════════════════════════════
_G.DeviceID     = _G.NewSpoof.DeviceID
_G.AndroidID    = _G.NewSpoof.AndroidID
_G.HWID         = _G.NewSpoof.HWID
_G.IMEI         = _G.NewSpoof.IMEI
_G.MacAddress   = _G.NewSpoof.MAC
_G.Serial       = _G.NewSpoof.Serial
_G.UUID         = _G.NewSpoof.UUID
_G.IP           = _G.NewSpoof.IP
_G.LocalIP      = _G.NewSpoof.LocalIP
_G.PublicIP     = _G.NewSpoof.PublicIP
_G.SSID         = _G.NewSpoof.SSID
_G.Model        = _G.NewSpoof.Model
_G.Brand        = _G.NewSpoof.Brand
_G.Fingerprint  = _G.NewSpoof.Fingerprint

-- ═══════════════════════════════════════════════════════════════════════════════
-- [5] Auto Refresh (كل 60 ثانية)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local function Refresh()
        pcall(function()
            -- IP
            _G.NewSpoof.IP         = RandomIP()
            _G.NewSpoof.PublicIP   = RandomIP()
            _G.NewSpoof.MAC        = RandomMAC()
            -- Device
            _G.NewSpoof.DeviceID   = RandomHex(32)
            _G.NewSpoof.AndroidID  = RandomHex(16)
            _G.NewSpoof.HWID       = RandomHex(40)
            _G.NewSpoof.IMEI       = "35" .. RandomNum(13)
            -- Globals
            _G.IP         = _G.NewSpoof.IP
            _G.DeviceID   = _G.NewSpoof.DeviceID
            _G.HWID       = _G.NewSpoof.HWID
            _G.MacAddress = _G.NewSpoof.MAC
            _G.IMEI       = _G.NewSpoof.IMEI
        end)
    end
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(60.0, Refresh, -1, 60.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[SPOOFER] 🎭 LOADED")
    print("[SPOOFER] 🌐 IP:         " .. _G.NewSpoof.IP)
    print("[SPOOFER] 🌐 Local IP:   " .. _G.NewSpoof.LocalIP)
    print("[SPOOFER] 📡 MAC:        " .. _G.NewSpoof.MAC)
    print("[SPOOFER] 📱 DeviceID:   " .. _G.NewSpoof.DeviceID)
    print("[SPOOFER] 🔑 HWID:       " .. _G.NewSpoof.HWID)
    print("[SPOOFER] 📞 IMEI:       " .. _G.NewSpoof.IMEI)
    print("[SPOOFER] 🏷️ Model:      " .. _G.NewSpoof.Model)
    print("[SPOOFER] 🔄 Auto-Refresh: ON (60s)")
    print("[SPOOFER] ✅ COMPLETE")
    print("═══════════════════════════════════════════════════")
end)