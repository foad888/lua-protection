-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ FILE #01: HWID SPOOFER — ULTIMATE EDITION
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- Spoof كامل لـ:
--   • HWID (Hardware ID)
--   • Device ID
--   • Android ID
--   • IMEI / IMSI
--   • MAC Address
--   • Serial Number
--   • UUID / Advertising ID
--   • Fingerprint / Build Info
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══ [1] CORE HELPERS ═══
local _G = _G
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local math = math
local os = os
local pcall = pcall
local xpcall = xpcall
local error = error
local assert = assert
local select = select
local unpack = unpack or table.unpack

-- ═══ [2] PURE FUNCTIONS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retOne() return 1 end
local function retMinusOne() return -1 end
local function retNil() return nil end
local function retEmpty() return {} end
local function retEmptyString() return "" end
local function retHundred() return 100 end
local function retThousand() return 1000 end
local function retMillion() return 1000000 end
local function retBillion() return 1000000000 end

-- ═══ [3] RANDOM GENERATORS ═══
local HEX_CHARS = "0123456789ABCDEF"
local HEX_CHARS_LOWER = "0123456789abcdef"
local NUM_CHARS = "0123456789"
local LOWER_CHARS = "abcdefghijklmnopqrstuvwxyz"
local UPPER_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local ALPHA_NUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

local function randomFromChars(chars, len)
    if not len or len <= 0 then return "" end
    local out = {}
    local clen = #chars
    for i = 1, len do
        local p = math.random(1, clen)
        out[i] = chars:sub(p, p)
    end
    return table.concat(out)
end

local function RandomHex(len)
    return randomFromChars(HEX_CHARS, len)
end

local function RandomHexLower(len)
    return randomFromChars(HEX_CHARS_LOWER, len)
end

local function RandomNum(len)
    return randomFromChars(NUM_CHARS, len)
end

local function RandomLower(len)
    return randomFromChars(LOWER_CHARS, len)
end

local function RandomUpper(len)
    return randomFromChars(UPPER_CHARS, len)
end

local function RandomAlphaNum(len)
    return randomFromChars(ALPHA_NUM, len)
end

local function RandomMAC()
    return string.format("%02X:%02X:%02X:%02X:%02X:%02X",
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

local function RandomMACLower()
    return string.format("%02x:%02x:%02x:%02x:%02x:%02x",
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

local function RandomUUID()
    return RandomHex(8) .. "-" .. RandomHex(4) .. "-" .. RandomHex(4) .. "-" .. RandomHex(4) .. "-" .. RandomHex(12)
end

local function RandomIP()
    return tostring(math.random(1, 223)) .. "." ..
           tostring(math.random(0, 255)) .. "." ..
           tostring(math.random(0, 255)) .. "." ..
           tostring(math.random(1, 254))
end

local function RandomIMEI()
    return "35" .. RandomNum(13)
end

local function RandomIMSI()
    return "31015" .. RandomNum(10)
end

local function RandomSerial()
    return RandomUpper(1) .. RandomNum(11)
end

-- ═══ [4] BUILD IDENTITY ═══
local function BuildIdentity()
    local deviceId = RandomHex(32)
    local androidId = RandomHex(16)
    local hwid = RandomHex(40)
    local mac = RandomMAC()
    local imei = RandomIMEI()
    local imsi = RandomIMSI()
    local serial = RandomSerial()
    local uuid = RandomUUID()
    local advertisingId = RandomUUID()
    local ip = RandomIP()

    return {
        -- 🔑 IDs
        DeviceID        = deviceId,
        DeviceId        = deviceId,
        AndroidID       = androidId,
        AndroidId       = androidId,
        HWID            = hwid,
        Hwid            = hwid,
        UUID            = uuid,
        Uuid            = uuid,
        AdvertisingID   = advertisingId,
        AdvertisingId   = advertisingId,
        Serial          = serial,
        SerialNumber    = serial,
        IMEI            = imei,
        Imei            = imei,
        IMSI            = imsi,
        Imsi            = imsi,
        MAC             = mac,
        MacAddress      = mac,
        Mac             = mac,

        -- 📱 DEVICE INFO
        Model           = "SM-G998B",
        DeviceModel     = "SM-G998B",
        Brand           = "samsung",
        DeviceBrand     = "samsung",
        Manufacturer    = "samsung",
        Device          = "beyond1",
        Product         = "beyond1ltexx",
        Hardware        = "exynos2100",
        Board           = "exynos2100",
        Bootloader      = "G998BXXU5CVDD",
        Host            = "localhost",
        Fingerprint     = "samsung/beyond1ltexx/beyond1:13/TP1A.220624.014/G998BXXU5CVDD:user/release-keys",
        BuildID         = RandomHex(8),
        BuildTime       = tostring(os.time()),
        CPUABI          = "arm64-v8a",
        CPU             = "Exynos 2100 Octa-core",
        GPU             = "Mali-G78 MP14",
        KernelVersion   = "Linux version 5.4.86-android12-9-00001-gb7e5d6a1c8f2",

        -- 💻 OS INFO
        OSVersion       = "13",
        OSName          = "Android",
        SDKInt          = "33",
        SDKVersion      = "33",

        -- 🌍 REGIONAL
        Language        = "en-US",
        Country         = "US",
        CountryCode     = "US",
        Timezone        = "UTC",
        Locale          = "en_US",

        -- 📡 NETWORK
        IP              = ip,
        LocalIP         = "192.168.1." .. tostring(math.random(2, 254)),
        PublicIP        = ip,
        GatewayIP       = "192.168.1.1",
        SubnetMask      = "255.255.255.0",
        DNS1            = "8.8.8.8",
        DNS2            = "8.8.4.4",
        NetworkType     = "WiFi",
        Carrier         = "Google",
        SSID            = "HomeWiFi_" .. RandomHex(4),
        BSSID           = mac,
        Hostname        = "android-" .. RandomLower(8),

        -- 🖥️ SCREEN
        ScreenWidth     = "1440",
        ScreenHeight    = "3200",
        ScreenDensity   = "560",
        ScreenResolution = "1440x3200",

        -- ⚙️ HARDWARE
        RAM             = "12288",
        RAMSize         = "12288",
        Storage         = "512",
        StorageSize     = "512",
        BatteryLevel    = "100",
        BatteryStatus   = "Charging",
        Temperature     = "25",
        BatteryTemp     = "25",

        -- 🛡️ SECURITY FLAGS
        IsEmulator      = false,
        IsRooted        = false,
        IsRoot          = false,
        IsDebugged      = false,
        IsDebug         = false,
        IsJailbroken    = false,
        IsDeveloperMode = false,
        IsUSBConnected  = false,
        IsModded        = false,
        IsHooked        = false,
        IsVirtualMachine = false,
        IsSimulator     = false,
        IsVPN           = false,
        IsProxy         = false,
        IsXposed        = false,
        IsMagisk        = false,
        IsFrida         = false,
        IsTampered      = false,
    }
end

-- ═══ [5] GENERATE IDENTITY ONCE ═══
_G.Spoof = _G.Spoof or BuildIdentity()
local Spoof = _G.Spoof

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] SPOOF SystemInfo — ALL METHODS
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local SI = import("SystemInfo")
    if not SI then return end

    -- 🔑 Device ID
    SI.GetDeviceID          = function() return Spoof.DeviceID end
    SI.GetDeviceId          = function() return Spoof.DeviceID end
    SI.GetUniqueDeviceId    = function() return Spoof.DeviceID end
    SI.GetUniqueDeviceID    = function() return Spoof.DeviceID end
    SI.GetAndroidID         = function() return Spoof.AndroidID end
    SI.GetAndroidId         = function() return Spoof.AndroidID end
    SI.GetUUID              = function() return Spoof.UUID end
    SI.GetUuid              = function() return Spoof.UUID end
    SI.GetAdvertisingID     = function() return Spoof.AdvertisingID end
    SI.GetAdvertisingId     = function() return Spoof.AdvertisingID end
    SI.GetIMEI              = function() return Spoof.IMEI end
    SI.GetImei              = function() return Spoof.IMEI end
    SI.GetIMSI              = function() return Spoof.IMSI end
    SI.GetImsi              = function() return Spoof.IMSI end
    SI.GetSerial            = function() return Spoof.Serial end
    SI.GetSerialNumber      = function() return Spoof.Serial end
    SI.GetMACAddress        = function() return Spoof.MAC end
    SI.GetMacAddress        = function() return Spoof.MAC end
    SI.GetMac               = function() return Spoof.MAC end
    SI.GetWifiMac           = function() return Spoof.MAC end
    SI.GetBluetoothMac      = function() return Spoof.MAC end

    -- 📱 Device Info
    SI.GetDeviceName        = function() return Spoof.Model end
    SI.GetDeviceModel       = function() return Spoof.Model end
    SI.GetModel             = function() return Spoof.Model end
    SI.GetDeviceBrand       = function() return Spoof.Brand end
    SI.GetBrand             = function() return Spoof.Brand end
    SI.GetManufacturer      = function() return Spoof.Manufacturer end
    SI.GetDevice            = function() return Spoof.Device end
    SI.GetProduct           = function() return Spoof.Product end
    SI.GetHardware          = function() return Spoof.Hardware end
    SI.GetBoard             = function() return Spoof.Board end
    SI.GetBootloader        = function() return Spoof.Bootloader end
    SI.GetFingerprint       = function() return Spoof.Fingerprint end
    SI.GetHost              = function() return Spoof.Host end
    SI.GetBuildID           = function() return Spoof.BuildID end
    SI.GetBuildId           = function() return Spoof.BuildID end
    SI.GetBuildTime         = function() return Spoof.BuildTime end
    SI.GetCPUABI            = function() return Spoof.CPUABI end
    SI.GetCpuAbi            = function() return Spoof.CPUABI end
    SI.GetCPU               = function() return Spoof.CPU end
    SI.GetCpu               = function() return Spoof.CPU end
    SI.GetGPU               = function() return Spoof.GPU end
    SI.GetGpu               = function() return Spoof.GPU end

    -- 💻 OS Info
    SI.GetOSVersion         = function() return Spoof.OSVersion end
    SI.GetOsVersion         = function() return Spoof.OSVersion end
    SI.GetOSName            = function() return Spoof.OSName end
    SI.GetOsName            = function() return Spoof.OSName end
    SI.GetSDKInt            = function() return Spoof.SDKInt end
    SI.GetSdkInt            = function() return Spoof.SDKInt end
    SI.GetSDKVersion        = function() return Spoof.SDKVersion end
    SI.GetSdkVersion        = function() return Spoof.SDKVersion end
    SI.GetKernelVersion     = function() return Spoof.KernelVersion end
    SI.GetKernel            = function() return Spoof.KernelVersion end

    -- 🌍 Regional
    SI.GetLanguageCode      = function() return Spoof.Language end
    SI.GetLanguage          = function() return Spoof.Language end
    SI.GetCountryCode       = function() return Spoof.Country end
    SI.GetCountry           = function() return Spoof.Country end
    SI.GetTimeZone          = function() return Spoof.Timezone end
    SI.GetTimeZoneOffset    = function() return Spoof.Timezone end
    SI.GetLocale            = function() return Spoof.Locale end

    -- 📡 Network
    SI.GetNetworkType       = function() return Spoof.NetworkType end
    SI.GetCarrier           = function() return Spoof.Carrier end
    SI.GetCarrierName       = function() return Spoof.Carrier end
    SI.GetSSID              = function() return Spoof.SSID end
    SI.GetBSSID             = function() return Spoof.BSSID end
    SI.GetIPAddress         = function() return Spoof.IP end
    SI.GetLocalIP           = function() return Spoof.LocalIP end
    SI.GetPublicIP          = function() return Spoof.PublicIP end
    SI.GetGateway           = function() return Spoof.GatewayIP end
    SI.GetSubnetMask        = function() return Spoof.SubnetMask end
    SI.GetDNS               = function() return Spoof.DNS1 end
    SI.GetHostName          = function() return Spoof.Hostname end
    SI.GetHostname          = function() return Spoof.Hostname end

    -- 🖥️ Screen
    SI.GetScreenWidth       = function() return Spoof.ScreenWidth end
    SI.GetScreenHeight      = function() return Spoof.ScreenHeight end
    SI.GetScreenDensity     = function() return Spoof.ScreenDensity end
    SI.GetScreenResolution  = function() return Spoof.ScreenResolution end

    -- ⚙️ Hardware
    SI.GetRAMSize           = function() return Spoof.RAMSize end
    SI.GetRamSize           = function() return Spoof.RAMSize end
    SI.GetRAM               = function() return Spoof.RAM end
    SI.GetRam               = function() return Spoof.RAM end
    SI.GetStorageSize       = function() return Spoof.StorageSize end
    SI.GetStorage           = function() return Spoof.Storage end
    SI.GetBatteryLevel      = function() return Spoof.BatteryLevel end
    SI.GetBatteryStatus     = function() return Spoof.BatteryStatus end
    SI.GetTemperature       = function() return Spoof.Temperature end
    SI.GetBatteryTemperature = function() return Spoof.BatteryTemp end

    -- 🛡️ Security Flags (كلها false)
    SI.IsEmulator           = function() return false end
    SI.IsRooted             = function() return false end
    SI.IsRoot               = function() return false end
    SI.IsDebugged           = function() return false end
    SI.IsDebug              = function() return false end
    SI.IsJailbroken         = function() return false end
    SI.IsDeveloperMode      = function() return false end
    SI.IsUSBConnected       = function() return false end
    SI.IsModded             = function() return false end
    SI.IsHooked             = function() return false end
    SI.IsVirtualMachine     = function() return false end
    SI.IsSimulator          = function() return false end
    SI.IsVPN                = function() return false end
    SI.IsProxy              = function() return false end
    SI.IsXposed             = function() return false end
    SI.IsMagisk             = function() return false end
    SI.IsFrida              = function() return false end
    SI.IsTampered           = function() return false end
    SI.CheckKernelIntegrity = function() return true end
    SI.CheckIntegrity       = function() return true end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] SPOOF DeviceID Module
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local DI = import("DeviceID")
    if not DI then return end

    DI.GetDeviceID          = function() return Spoof.DeviceID end
    DI.GetDeviceId          = function() return Spoof.DeviceID end
    DI.GetAndroidID         = function() return Spoof.AndroidID end
    DI.GetAndroidId         = function() return Spoof.AndroidID end
    DI.GetUUID              = function() return Spoof.UUID end
    DI.GetUuid              = function() return Spoof.UUID end
    DI.GetAdvertisingID     = function() return Spoof.AdvertisingID end
    DI.GetAdvertisingId     = function() return Spoof.AdvertisingID end
    DI.GetIMEI              = function() return Spoof.IMEI end
    DI.GetImei              = function() return Spoof.IMEI end
    DI.GetIMSI              = function() return Spoof.IMSI end
    DI.GetImsi              = function() return Spoof.IMSI end
    DI.GetMACAddress        = function() return Spoof.MAC end
    DI.GetMacAddress        = function() return Spoof.MAC end
    DI.GetMac               = function() return Spoof.MAC end
    DI.GetUniqueDeviceID    = function() return Spoof.DeviceID end
    DI.GetUniqueDeviceId    = function() return Spoof.DeviceID end
    DI.GetDeviceName        = function() return Spoof.Model end
    DI.GetDeviceModel       = function() return Spoof.Model end
    DI.GetDeviceBrand       = function() return Spoof.Brand end
    DI.GetDeviceManufacturer = function() return Spoof.Manufacturer end
    DI.GetDeviceBoard       = function() return Spoof.Board end
    DI.GetDeviceBootloader  = function() return Spoof.Bootloader end
    DI.GetDeviceHardware    = function() return Spoof.Hardware end
    DI.GetDeviceHost        = function() return Spoof.Host end
    DI.GetDeviceFingerprint = function() return Spoof.Fingerprint end
    DI.GetDeviceSerial      = function() return Spoof.Serial end
    DI.GetDeviceSerialNumber = function() return Spoof.Serial end
    DI.GetDeviceProduct     = function() return Spoof.Product end
    DI.GetDevice             = function() return Spoof.Device end
    DI.GetDeviceId           = function() return Spoof.DeviceID end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] SPOOF KismetSystemLibrary
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local KSL = import("KismetSystemLibrary")
    if not KSL then return end

    KSL.GetDeviceId          = function() return Spoof.DeviceID end
    KSL.GetDeviceID          = function() return Spoof.DeviceID end
    KSL.GetMacAddress        = function() return Spoof.MAC end
    KSL.GetSerialNumber      = function() return Spoof.Serial end
    KSL.GetUniqueDeviceId    = function() return Spoof.DeviceID end
    KSL.GetUniqueDeviceID    = function() return Spoof.DeviceID end
    KSL.GetAndroidId         = function() return Spoof.AndroidID end
    KSL.GetAndroidID         = function() return Spoof.AndroidID end
    KSL.GetPlatformName      = function() return "Android" end
    KSL.GetDeviceName        = function() return Spoof.Model end
    KSL.GetDeviceModel       = function() return Spoof.Model end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] SPOOF Client
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not Client then return end

    Client.GetPhoneDeviceID  = function() return Spoof.DeviceID end
    Client.GetDeviceID       = function() return Spoof.DeviceID end
    Client.GetDeviceId       = function() return Spoof.DeviceID end
    Client.GetAndroidID      = function() return Spoof.AndroidID end
    Client.GetAndroidId      = function() return Spoof.AndroidID end
    Client.GetIMEI           = function() return Spoof.IMEI end
    Client.GetIMSI           = function() return Spoof.IMSI end
    Client.GetMacAddress     = function() return Spoof.MAC end
    Client.GetMACAddress     = function() return Spoof.MAC end
    Client.GetHWID           = function() return Spoof.HWID end
    Client.GetHwid           = function() return Spoof.HWID end
    Client.GetUUID           = function() return Spoof.UUID end
    Client.GetSerial         = function() return Spoof.Serial end
    Client.GetSerialNumber   = function() return Spoof.Serial end
    Client.GetFingerprint    = function() return Spoof.Fingerprint end
    Client.GetModel          = function() return Spoof.Model end
    Client.GetBrand          = function() return Spoof.Brand end
    Client.IsEmulator        = function() return false end
    Client.IsRooted          = function() return false end
    Client.IsDebugged        = function() return false end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] SPOOF TssSdk
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
    if not TssSdk then return end

    TssSdk.GetDeviceInfo = function()
        return {
            deviceId        = Spoof.DeviceID,
            deviceID        = Spoof.DeviceID,
            androidId       = Spoof.AndroidID,
            androidID       = Spoof.AndroidID,
            uuid            = Spoof.UUID,
            advertisingId   = Spoof.AdvertisingID,
            imei            = Spoof.IMEI,
            imsi            = Spoof.IMSI,
            mac             = Spoof.MAC,
            macAddress      = Spoof.MAC,
            serial          = Spoof.Serial,
            serialNumber    = Spoof.Serial,
            hwid            = Spoof.HWID,
            model           = Spoof.Model,
            brand           = Spoof.Brand,
            manufacturer    = Spoof.Manufacturer,
            fingerprint     = Spoof.Fingerprint,
            sdkInt          = Spoof.SDKInt,
            osVersion       = Spoof.OSVersion,
            buildId         = Spoof.BuildID,
            board           = Spoof.Board,
            hardware        = Spoof.Hardware,
            bootloader      = Spoof.Bootloader,
            host            = Spoof.Host,
            product         = Spoof.Product,
            device          = Spoof.Device,
        }
    end
    TssSdk.GetFingerprint     = function() return Spoof.Fingerprint end
    TssSdk.GetClientID        = function() return Spoof.DeviceID end
    TssSdk.GetClientId        = function() return Spoof.DeviceID end
    TssSdk.GetHWID            = function() return Spoof.HWID end
    TssSdk.GetHwid            = function() return Spoof.HWID end
    TssSdk.GetDeviceID        = function() return Spoof.DeviceID end
    TssSdk.GetDeviceId        = function() return Spoof.DeviceID end
    TssSdk.GetAndroidID       = function() return Spoof.AndroidID end
    TssSdk.GetAndroidId       = function() return Spoof.AndroidID end
    TssSdk.GetIMEI            = function() return Spoof.IMEI end
    TssSdk.GetImei            = function() return Spoof.IMEI end
    TssSdk.GetIMSI            = function() return Spoof.IMSI end
    TssSdk.GetImsi            = function() return Spoof.IMSI end
    TssSdk.GetMacAddress      = function() return Spoof.MAC end
    TssSdk.GetMACAddress      = function() return Spoof.MAC end
    TssSdk.GetSerial          = function() return Spoof.Serial end
    TssSdk.GetSerialNumber    = function() return Spoof.Serial end
    TssSdk.GetUUID            = function() return Spoof.UUID end
    TssSdk.GetUuid            = function() return Spoof.UUID end
    TssSdk.GetModel           = function() return Spoof.Model end
    TssSdk.GetBrand           = function() return Spoof.Brand end
    TssSdk.GetManufacturer    = function() return Spoof.Manufacturer end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] GLOBAL VARIABLES SPOOF
-- ═══════════════════════════════════════════════════════════════════════════════
_G.DeviceID             = Spoof.DeviceID
_G.DeviceId             = Spoof.DeviceID
_G.AndroidID            = Spoof.AndroidID
_G.AndroidId            = Spoof.AndroidID
_G.HWID                 = Spoof.HWID
_G.Hwid                 = Spoof.HWID
_G.UUID                 = Spoof.UUID
_G.Uuid                 = Spoof.UUID
_G.AdvertisingID        = Spoof.AdvertisingID
_G.SerialNumber         = Spoof.Serial
_G.Serial               = Spoof.Serial
_G.IMEI                 = Spoof.IMEI
_G.Imei                 = Spoof.IMEI
_G.IMSI                 = Spoof.IMSI
_G.MacAddress           = Spoof.MAC
_G.MACAddress           = Spoof.MAC
_G.Model                = Spoof.Model
_G.DeviceModel          = Spoof.Model
_G.Brand                = Spoof.Brand
_G.Manufacturer         = Spoof.Manufacturer
_G.Fingerprint          = Spoof.Fingerprint
_G.LocalIP              = Spoof.LocalIP
_G.PublicIP             = Spoof.PublicIP

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] METATABLE PROTECTION (منع أي محاولة قراءة الجهاز الحقيقي)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local blocked = {
        "GetRealDeviceID","GetRealAndroidID","GetRealIMEI","GetRealIMSI",
        "GetRealMAC","GetRealSerial","GetRealHWID","GetRealUUID",
        "GetRealFingerprint","GetRealModel","GetRealBrand",
        "GetSystemDeviceID","GetSystemAndroidID","GetSystemIMEI",
        "GetSystemMAC","GetSystemSerial","GetSystemHWID",
        "GetHardwareID","GetHardwareId","GetHardwareUUID"
    }
    for _, fn in ipairs(blocked) do
        if _G[fn] then _G[fn] = function() return Spoof.DeviceID end end
        if Client and Client[fn] then Client[fn] = function() return Spoof.DeviceID end end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] SELF-REFRESH (كل 60 ثانية يغير الهوية)
-- ═══════════════════════════════════════════════════════════════════════════════
local function RefreshSpoof()
    pcall(function()
        -- توليد هوية جديدة
        local newIdentity = BuildIdentity()
        for k, v in pairs(newIdentity) do
            Spoof[k] = v
        end
        -- تحديث Globals
        _G.DeviceID   = Spoof.DeviceID
        _G.AndroidID  = Spoof.AndroidID
        _G.HWID       = Spoof.HWID
        _G.IMEI       = Spoof.IMEI
        _G.MacAddress = Spoof.MAC
        _G.Serial     = Spoof.Serial
        _G.UUID       = Spoof.UUID
    end)
end

pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(60.0, RefreshSpoof, -1, 60.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[FILE #01] 🛡️ HWID SPOOFER LOADED")
    print("[FILE #01] 📱 DeviceID: " .. Spoof.DeviceID)
    print("[FILE #01] 🔑 HWID: "     .. Spoof.HWID)
    print("[FILE #01] 📡 AndroidID: ".. Spoof.AndroidID)
    print("[FILE #01] 📶 MAC: "      .. Spoof.MAC)
    print("[FILE #01] 📞 IMEI: "     .. Spoof.IMEI)
    print("[FILE #01] 🔢 Serial: "   .. Spoof.Serial)
    print("[FILE #01] 🆔 UUID: "     .. Spoof.UUID)
    print("[FILE #01] ✅ All IDs Spoofed Successfully")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF FILE #01
-- ═══════════════════════════════════════════════════════════════════════════════