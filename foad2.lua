-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ FILE #02: IP SPOOFER — ULTIMATE EDITION
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- Spoof كامل لـ:
--   • IP Address (Public + Local + Gateway)
--   • MAC Address
--   • Network Type
--   • DNS Servers
--   • SSID / BSSID
--   • Carrier Info
--   • Socket Level
--   • HTTP Request Level
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
local select = select
local unpack = unpack or table.unpack

-- ═══ [2] PURE FUNCTIONS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retNil() return nil end
local function retEmpty() return {} end
local function retEmptyString() return "" end

-- ═══ [3] RANDOM GENERATORS ═══
local HEX_CHARS = "0123456789ABCDEF"

local function RandomHex(len)
    local out = {}
    for i = 1, len do
        local p = math.random(1, #HEX_CHARS)
        out[i] = HEX_CHARS:sub(p, p)
    end
    return table.concat(out)
end

local function RandomNum(len)
    local out = {}
    for i = 1, len do
        out[i] = tostring(math.random(0, 9))
    end
    return table.concat(out)
end

local function RandomLower(len)
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local out = {}
    for i = 1, len do
        local p = math.random(1, #chars)
        out[i] = chars:sub(p, p)
    end
    return table.concat(out)
end

local function RandomMAC()
    return string.format("%02X:%02X:%02X:%02X:%02X:%02X",
        math.random(0, 255), math.random(0, 255), math.random(0, 255),
        math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local function RandomIP()
    return tostring(math.random(1, 223)) .. "." ..
           tostring(math.random(0, 255)) .. "." ..
           tostring(math.random(0, 255)) .. "." ..
           tostring(math.random(1, 254))
end

local function RandomPrivateIP()
    local ranges = {
        function() return "10." .. math.random(0,255) .. "." .. math.random(0,255) .. "." .. math.random(1,254) end,
        function() return "172." .. math.random(16,31) .. "." .. math.random(0,255) .. "." .. math.random(1,254) end,
        function() return "192.168." .. math.random(0,255) .. "." .. math.random(1,254) end,
    }
    return ranges[math.random(1, #ranges)]()
end

-- ═══ [4] BUILD NETWORK IDENTITY ═══
local function BuildNetworkIdentity()
    local publicIP = RandomIP()
    local localIP = RandomPrivateIP()
    local mac = RandomMAC()
    local gateway = "192.168." .. math.random(0, 255) .. ".1"
    local ssid = "HomeWiFi_" .. RandomHex(4)

    return {
        -- 🌐 IP ADDRESSES
        IP              = publicIP,
        Ip              = publicIP,
        PublicIP        = publicIP,
        PublicIp        = publicIP,
        ExternalIP      = publicIP,
        ExternalIp      = publicIP,
        WANIP           = publicIP,
        WANIPAddress    = publicIP,

        LocalIP         = localIP,
        LocalIp         = localIP,
        PrivateIP       = localIP,
        LANIP           = localIP,
        LANIPAddress    = localIP,
        InternalIP      = localIP,

        GatewayIP       = gateway,
        Gateway         = gateway,
        DefaultGateway  = gateway,
        RouterIP        = gateway,

        SubnetMask      = "255.255.255.0",
        Netmask         = "255.255.255.0",
        PrefixLength    = "24",
        Broadcast       = "192.168.1.255",

        -- 📡 DNS
        DNS1            = "8.8.8.8",
        DNS2            = "8.8.4.4",
        DNS3            = "1.1.1.1",
        PrimaryDNS      = "8.8.8.8",
        SecondaryDNS    = "8.8.4.4",
        DNSServers      = "8.8.8.8,8.8.4.4",

        -- 🔑 MAC ADDRESS
        MAC             = mac,
        Mac             = mac,
        MacAddress      = mac,
        MACAddress      = mac,
        PhysicalAddress = mac,
        HardwareAddress = mac,
        WiFiMAC         = mac,
        WifiMac         = mac,
        BluetoothMAC    = mac,
        EthernetMAC     = mac,

        -- 📶 WIFI
        SSID            = ssid,
        Ssid            = ssid,
        WifiSSID        = ssid,
        WiFiName        = ssid,
        BSSID           = mac,
        Bssid           = mac,
        WifiBSSID       = mac,

        -- 📱 NETWORK
        NetworkType     = "WiFi",
        NetworkName     = "WiFi",
        NetworkState    = "Connected",
        ConnectionType  = "WiFi",
        IsConnected     = true,
        IsOnline        = true,
        IsWiFi          = true,
        IsMobile        = false,
        IsEthernet      = false,
        IsVPN           = false,
        IsProxy         = false,
        IsTor           = false,
        IsDatacenter    = false,

        -- 📡 CARRIER
        Carrier         = "Google",
        CarrierName     = "Google",
        CarrierID       = "310410",
        MCC             = "310",
        MNC             = "410",
        SIMCountry      = "US",
        SIMOperator     = "Google",
        SIMState        = "READY",

        -- 🖥️ HOSTNAME
        Hostname        = "android-" .. RandomLower(8),
        HostName        = "android-" .. RandomLower(8),
        LocalHostname   = "android-" .. RandomLower(8),
        Domain          = "local",

        -- 📊 NETWORK STATS
        SignalStrength  = tostring(math.random(80, 100)),
        NetworkSpeed    = tostring(math.random(100, 1000)),
        NetworkLatency  = tostring(math.random(10, 50)),
        NetworkLoss     = "0",
        NetworkRTT      = tostring(math.random(10, 50)),
        NetworkMTU      = "1500",
        NetworkBandwidth = "1000",
    }
end

-- ═══ [5] APPLY ONCE ═══
_G.NetSpoof = _G.NetSpoof or BuildNetworkIdentity()
local NetSpoof = _G.NetSpoof

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] GLOBAL IP FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════
_G.GetLocalIP       = function() return NetSpoof.LocalIP end
_G.GetIPAddress     = function() return NetSpoof.IP end
_G.GetPublicIP      = function() return NetSpoof.PublicIP end
_G.GetExternalIP    = function() return NetSpoof.ExternalIP end
_G.GetInternalIP    = function() return NetSpoof.LocalIP end
_G.GetPrivateIP     = function() return NetSpoof.LocalIP end
_G.GetGatewayIP     = function() return NetSpoof.GatewayIP end
_G.GetGateway       = function() return NetSpoof.GatewayIP end
_G.GetRouterIP      = function() return NetSpoof.GatewayIP end
_G.GetSubnetMask    = function() return NetSpoof.SubnetMask end
_G.GetNetmask       = function() return NetSpoof.Netmask end
_G.GetDNS           = function() return NetSpoof.DNS1 end
_G.GetDNS1          = function() return NetSpoof.DNS1 end
_G.GetDNS2          = function() return NetSpoof.DNS2 end
_G.GetPrimaryDNS    = function() return NetSpoof.PrimaryDNS end
_G.GetSecondaryDNS  = function() return NetSpoof.SecondaryDNS end
_G.GetMACAddress    = function() return NetSpoof.MAC end
_G.GetMacAddress    = function() return NetSpoof.MAC end
_G.GetMac           = function() return NetSpoof.MAC end
_G.GetPhysicalAddress = function() return NetSpoof.MAC end
_G.GetHardwareAddress = function() return NetSpoof.MAC end
_G.GetWiFiMAC       = function() return NetSpoof.WiFiMAC end
_G.GetBluetoothMAC  = function() return NetSpoof.BluetoothMAC end
_G.GetSSID          = function() return NetSpoof.SSID end
_G.GetSsid          = function() return NetSpoof.SSID end
_G.GetBSSID         = function() return NetSpoof.BSSID end
_G.GetBssid         = function() return NetSpoof.BSSID end
_G.GetHostname      = function() return NetSpoof.Hostname end
_G.GetHostName      = function() return NetSpoof.HostName end
_G.GetNetworkType   = function() return NetSpoof.NetworkType end
_G.GetCarrier       = function() return NetSpoof.Carrier end
_G.GetCarrierName   = function() return NetSpoof.CarrierName end
_G.IsConnected      = function() return true end
_G.IsWiFi           = function() return true end
_G.IsMobile         = function() return false end
_G.IsVPN            = function() return false end
_G.IsProxy          = function() return false end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] SPOOF Network Module
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local Net = import("Network")
    if not Net then return end

    Net.GetIPAddress        = function() return NetSpoof.IP end
    Net.GetIpAddress        = function() return NetSpoof.IP end
    Net.GetLocalIP          = function() return NetSpoof.LocalIP end
    Net.GetLocalIp          = function() return NetSpoof.LocalIP end
    Net.GetPrivateIP        = function() return NetSpoof.LocalIP end
    Net.GetPublicIP         = function() return NetSpoof.PublicIP end
    Net.GetPublicIp         = function() return NetSpoof.PublicIP end
    Net.GetExternalIP       = function() return NetSpoof.ExternalIP end
    Net.GetExternalIp       = function() return NetSpoof.ExternalIP end
    Net.GetGateway          = function() return NetSpoof.GatewayIP end
    Net.GetGatewayIP        = function() return NetSpoof.GatewayIP end
    Net.GetDefaultGateway   = function() return NetSpoof.GatewayIP end
    Net.GetSubnetMask       = function() return NetSpoof.SubnetMask end
    Net.GetNetmask          = function() return NetSpoof.Netmask end
    Net.GetBroadcast        = function() return NetSpoof.Broadcast end
    Net.GetDNS              = function() return NetSpoof.DNS1 end
    Net.GetDNS1             = function() return NetSpoof.DNS1 end
    Net.GetDNS2             = function() return NetSpoof.DNS2 end
    Net.GetPrimaryDNS       = function() return NetSpoof.PrimaryDNS end
    Net.GetSecondaryDNS     = function() return NetSpoof.SecondaryDNS end
    Net.GetMACAddress       = function() return NetSpoof.MAC end
    Net.GetMacAddress       = function() return NetSpoof.MAC end
    Net.GetMac              = function() return NetSpoof.MAC end
    Net.GetPhysicalAddress  = function() return NetSpoof.MAC end
    Net.GetHardwareAddress  = function() return NetSpoof.MAC end
    Net.GetWiFiMAC          = function() return NetSpoof.WiFiMAC end
    Net.GetBluetoothMAC     = function() return NetSpoof.BluetoothMAC end
    Net.GetSSID             = function() return NetSpoof.SSID end
    Net.GetSsid             = function() return NetSpoof.SSID end
    Net.GetWiFiSSID         = function() return NetSpoof.SSID end
    Net.GetBSSID            = function() return NetSpoof.BSSID end
    Net.GetBssid            = function() return NetSpoof.BSSID end
    Net.GetWifiBSSID        = function() return NetSpoof.BSSID end
    Net.GetHostname         = function() return NetSpoof.Hostname end
    Net.GetHostName         = function() return NetSpoof.HostName end
    Net.GetNetworkType      = function() return NetSpoof.NetworkType end
    Net.GetNetworkName      = function() return NetSpoof.NetworkName end
    Net.GetNetworkState     = function() return NetSpoof.NetworkState end
    Net.GetConnectionType   = function() return NetSpoof.ConnectionType end
    Net.GetCarrier          = function() return NetSpoof.Carrier end
    Net.GetCarrierName      = function() return NetSpoof.CarrierName end
    Net.GetMCC              = function() return NetSpoof.MCC end
    Net.GetMNC              = function() return NetSpoof.MNC end
    Net.GetSIMCountry       = function() return NetSpoof.SIMCountry end
    Net.GetSIMOperator      = function() return NetSpoof.SIMOperator end
    Net.GetSignalStrength   = function() return NetSpoof.SignalStrength end
    Net.GetNetworkSpeed     = function() return NetSpoof.NetworkSpeed end
    Net.GetNetworkLatency   = function() return NetSpoof.NetworkLatency end
    Net.GetRTT              = function() return NetSpoof.NetworkRTT end
    Net.GetMTU              = function() return NetSpoof.NetworkMTU end
    Net.IsConnected         = function() return true end
    Net.IsOnline            = function() return true end
    Net.IsWiFi              = function() return true end
    Net.IsWifi              = function() return true end
    Net.IsMobile            = function() return false end
    Net.IsEthernet          = function() return false end
    Net.IsVPN               = function() return false end
    Net.IsProxy             = function() return false end
    Net.IsTor               = function() return false end
    Net.GetNetworkStats     = function() return { ping = 40, loss = 0, rtt = 40 } end
    Net.CheckNetworkType    = function() return "WIFI" end
    Net.CheckLatency        = function() return 20 end
    Net.GetPacketLoss       = function() return 0 end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] SPOOF DNS Module
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local DNS = import("DNS")
    if not DNS then return end

    DNS.Resolve             = function() return NetSpoof.IP end
    DNS.ResolveHostname     = function() return NetSpoof.IP end
    DNS.GetIPAddress        = function() return NetSpoof.IP end
    DNS.GetIpAddress        = function() return NetSpoof.IP end
    DNS.GetLocalIP          = function() return NetSpoof.LocalIP end
    DNS.GetPublicIP         = function() return NetSpoof.PublicIP end
    DNS.GetHostName         = function() return NetSpoof.Hostname end
    DNS.GetHostname         = function() return NetSpoof.Hostname end
    DNS.GetDNS1             = function() return NetSpoof.DNS1 end
    DNS.GetDNS2             = function() return NetSpoof.DNS2 end
    DNS.GetPrimaryDNS       = function() return NetSpoof.PrimaryDNS end
    DNS.GetSecondaryDNS     = function() return NetSpoof.SecondaryDNS end
    DNS.GetDNSServers       = function() return NetSpoof.DNSServers end
    DNS.Lookup              = function() return NetSpoof.IP end
    DNS.LookupHost          = function() return NetSpoof.IP end
    DNS.GetResolverIP       = function() return NetSpoof.DNS1 end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] SPOOF Socket (Lua Level)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not socket then return end

    -- socket.getpeername
    if socket.getpeername then
        local orig = socket.getpeername
        socket.getpeername = function(self, ...)
            local _, port = orig(self, ...)
            return NetSpoof.IP, port
        end
    end

    -- socket.getsockname
    if socket.getsockname then
        local orig = socket.getsockname
        socket.getsockname = function(self, ...)
            local _, port = orig(self, ...)
            return NetSpoof.LocalIP, port
        end
    end

    -- socket.connect
    if socket.connect then
        local orig = socket.connect
        socket.connect = function(self, host, port, ...)
            return orig(self, NetSpoof.IP, port, ...)
        end
    end

    -- socket.tcp
    if socket.tcp then
        local origTcp = socket.tcp
        socket.tcp = function(...)
            local tcp = origTcp(...)
            if tcp and tcp.connect then
                local origTCPConnect = tcp.connect
                tcp.connect = function(self, host, port, ...)
                    return origTCPConnect(self, NetSpoof.IP, port, ...)
                end
            end
            if tcp and tcp.getpeername then
                local origGetPeer = tcp.getpeername
                tcp.getpeername = function(self, ...)
                    local _, port = origGetPeer(self, ...)
                    return NetSpoof.IP, port
                end
            end
            if tcp and tcp.getsockname then
                local origGetSock = tcp.getsockname
                tcp.getsockname = function(self, ...)
                    local _, port = origGetSock(self, ...)
                    return NetSpoof.LocalIP, port
                end
            end
            return tcp
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] SPOOF HttpRequest (يخفي IP عند كل طلب)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if type(_G.HttpRequest) == "function" then
        local orig = _G.HttpRequest
        _G.HttpRequest = function(url, callback, ...)
            -- إضافة Headers وهمية
            local fakeHeaders = {
                ["X-Forwarded-For"]   = NetSpoof.IP,
                ["X-Real-IP"]         = NetSpoof.IP,
                ["X-Client-IP"]       = NetSpoof.IP,
                ["CF-Connecting-IP"]  = NetSpoof.IP,
                ["True-Client-IP"]    = NetSpoof.IP,
                ["X-Originating-IP"]  = NetSpoof.IP,
                ["Forwarded"]         = "for=" .. NetSpoof.IP,
                ["User-Agent"]        = "Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36",
            }
            return orig(url, callback, fakeHeaders, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] SPOOF HTTP Module
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not _G.Http then return end
    local fakeHeaders = {
        ["X-Forwarded-For"] = NetSpoof.IP,
        ["X-Real-IP"]       = NetSpoof.IP,
        ["X-Client-IP"]     = NetSpoof.IP,
        ["User-Agent"]      = "Mozilla/5.0 (Linux; Android 13; SM-G998B)",
    }
    if _G.Http.Get then
        local origGet = _G.Http.Get
        _G.Http.Get = function(url, ...)
            return origGet(url, fakeHeaders, ...)
        end
    end
    if _G.Http.Post then
        local origPost = _G.Http.Post
        _G.Http.Post = function(url, ...)
            return origPost(url, fakeHeaders, ...)
        end
    end
    if _G.Http.Request then
        local origReq = _G.Http.Request
        _G.Http.Request = function(url, ...)
            return origReq(url, fakeHeaders, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] SPOOF WebSocket
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if _G.WebSocket and _G.WebSocket.Connect then
        local orig = _G.WebSocket.Connect
        _G.WebSocket.Connect = function(url, ...)
            return orig(url, {
                ["X-Forwarded-For"] = NetSpoof.IP,
                ["X-Real-IP"]       = NetSpoof.IP,
            }, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] SPOOF NetworkManager
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local NM = import("NetworkManager")
    if not NM then return end

    NM.GetNetworkStats      = function() return { ping = 40, loss = 0, rtt = 40 } end
    NM.GetIPAddress         = function() return NetSpoof.IP end
    NM.GetLocalIP           = function() return NetSpoof.LocalIP end
    NM.GetPublicIP          = function() return NetSpoof.PublicIP end
    NM.GetMACAddress        = function() return NetSpoof.MAC end
    NM.GetConnectionInfo    = function() return NetSpoof.IP .. ":8080" end
    NM.CapturePackets       = nop
    NM.AnalyzeTraffic       = retEmpty
    NM.MonitorTraffic       = nop
    NM.ReportTraffic        = nop
    NM.ReportNetwork        = nop
    NM.ReportBandwidth      = nop
    NM.ReportLatency        = nop
    NM.ReportPacketLoss     = nop
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] SPOOF NetworkDetect
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ND = import("NetworkDetect")
    if not ND then return end

    ND.IsNetworkError       = retFalse
    ND.GetNetworkError      = retEmptyString
    ND.ReportNetworkError   = nop
    ND.CheckNetwork         = retTrue
    ND.ValidateNetwork      = retTrue
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] SPOOF SystemInfo (Network Part)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local SI = import("SystemInfo")
    if not SI then return end

    SI.GetIPAddress         = function() return NetSpoof.IP end
    SI.GetLocalIP           = function() return NetSpoof.LocalIP end
    SI.GetPublicIP          = function() return NetSpoof.PublicIP end
    SI.GetExternalIP        = function() return NetSpoof.ExternalIP end
    SI.GetGatewayIP         = function() return NetSpoof.GatewayIP end
    SI.GetSubnetMask        = function() return NetSpoof.SubnetMask end
    SI.GetDNS               = function() return NetSpoof.DNS1 end
    SI.GetMacAddress        = function() return NetSpoof.MAC end
    SI.GetMACAddress        = function() return NetSpoof.MAC end
    SI.GetSSID              = function() return NetSpoof.SSID end
    SI.GetBSSID             = function() return NetSpoof.BSSID end
    SI.GetNetworkType       = function() return NetSpoof.NetworkType end
    SI.GetCarrier           = function() return NetSpoof.Carrier end
    SI.GetCarrierName       = function() return NetSpoof.CarrierName end
    SI.GetHostname          = function() return NetSpoof.Hostname end
    SI.GetHostName          = function() return NetSpoof.Hostname end
    SI.GetSignalStrength    = function() return NetSpoof.SignalStrength end
    SI.GetNetworkSpeed      = function() return NetSpoof.NetworkSpeed end
    SI.IsConnected          = retTrue
    SI.IsWiFi               = retTrue
    SI.IsMobile             = retFalse
    SI.IsVPN                = retFalse
    SI.IsProxy              = retFalse
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [16] SPOOF Client (Network Part)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not Client then return end

    Client.GetIPAddress     = function() return NetSpoof.IP end
    Client.GetLocalIP       = function() return NetSpoof.LocalIP end
    Client.GetPublicIP      = function() return NetSpoof.PublicIP end
    Client.GetMACAddress    = function() return NetSpoof.MAC end
    Client.GetSSID          = function() return NetSpoof.SSID end
    Client.GetBSSID         = function() return NetSpoof.BSSID end
    Client.GetNetworkType   = function() return NetSpoof.NetworkType end
    Client.IsConnected      = retTrue
    Client.IsWiFi           = retTrue
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [17] SPOOF GLOBAL VARIABLES
-- ═══════════════════════════════════════════════════════════════════════════════
_G.IP               = NetSpoof.IP
_G.Ip               = NetSpoof.IP
_G.PublicIP         = NetSpoof.PublicIP
_G.ExternalIP       = NetSpoof.ExternalIP
_G.LocalIP          = NetSpoof.LocalIP
_G.PrivateIP        = NetSpoof.LocalIP
_G.InternalIP       = NetSpoof.LocalIP
_G.WANIP            = NetSpoof.IP
_G.LANIP            = NetSpoof.LocalIP
_G.GatewayIP        = NetSpoof.GatewayIP
_G.Gateway          = NetSpoof.GatewayIP
_G.RouterIP         = NetSpoof.GatewayIP
_G.SubnetMask       = NetSpoof.SubnetMask
_G.Netmask          = NetSpoof.Netmask
_G.DNS1             = NetSpoof.DNS1
_G.DNS2             = NetSpoof.DNS2
_G.PrimaryDNS       = NetSpoof.PrimaryDNS
_G.SecondaryDNS     = NetSpoof.SecondaryDNS
_G.DNSServers       = NetSpoof.DNSServers
_G.MAC              = NetSpoof.MAC
_G.Mac              = NetSpoof.MAC
_G.MacAddress       = NetSpoof.MAC
_G.MACAddress       = NetSpoof.MAC
_G.PhysicalAddress  = NetSpoof.MAC
_G.HardwareAddress  = NetSpoof.MAC
_G.SSID             = NetSpoof.SSID
_G.Ssid             = NetSpoof.SSID
_G.BSSID            = NetSpoof.BSSID
_G.Bssid            = NetSpoof.BSSID
_G.Hostname         = NetSpoof.Hostname
_G.HostName         = NetSpoof.HostName
_G.NetworkType      = NetSpoof.NetworkType
_G.Carrier          = NetSpoof.Carrier
_G.CarrierName      = NetSpoof.CarrierName
_G.MCC              = NetSpoof.MCC
_G.MNC              = NetSpoof.MNC
_G.SIMCountry       = NetSpoof.SIMCountry
_G.SIMOperator      = NetSpoof.SIMOperator

-- ═══════════════════════════════════════════════════════════════════════════════
-- [18] BLOCK Real Network Getters
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local blocked = {
        "GetRealIP","GetRealLocalIP","GetRealPublicIP","GetRealMAC",
        "GetSystemIP","GetSystemMAC","GetHardwareIP","GetHardwareMAC",
        "GetActualIP","GetActualMAC","GetNativeIP","GetNativeMAC"
    }
    for _, fn in ipairs(blocked) do
        if _G[fn] then _G[fn] = function() return NetSpoof.IP end end
        if Client and Client[fn] then Client[fn] = function() return NetSpoof.IP end end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [19] SELF-REFRESH (كل 90 ثانية)
-- ═══════════════════════════════════════════════════════════════════════════════
local function RefreshNetSpoof()
    pcall(function()
        local newNet = BuildNetworkIdentity()
        for k, v in pairs(newNet) do
            NetSpoof[k] = v
        end
        _G.IP         = NetSpoof.IP
        _G.LocalIP    = NetSpoof.LocalIP
        _G.MACAddress = NetSpoof.MAC
        _G.SSID       = NetSpoof.SSID
    end)
end

pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(90.0, RefreshNetSpoof, -1, 90.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [20] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[FILE #02] 🛡️ IP SPOOFER LOADED")
    print("[FILE #02] 🌐 Public IP:  " .. NetSpoof.PublicIP)
    print("[FILE #02] 🔒 Local IP:   " .. NetSpoof.LocalIP)
    print("[FILE #02] 🚪 Gateway:    " .. NetSpoof.GatewayIP)
    print("[FILE #02] 📡 MAC:        " .. NetSpoof.MAC)
    print("[FILE #02] 📶 SSID:       " .. NetSpoof.SSID)
    print("[FILE #02] 🔍 DNS:        " .. NetSpoof.DNS1)
    print("[FILE #02] 📱 Carrier:    " .. NetSpoof.Carrier)
    print("[FILE #02] ✅ All Network Spoofed Successfully")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF FILE #02
-- ═══════════════════════════════════════════════════════════════════════════════