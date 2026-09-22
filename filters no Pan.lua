-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
local _G = _G
local pcall = pcall
local type = type
local tostring = tostring
local table = table
local string = string
local os = os
local Game = Game
local slua = slua
local FILTERS = {
    ["com.tencent.ig"] = {
        deny = {
            ports = {80, 443, 20371, 15692, 18081, 8089, 9081, 10012, 8085, 9030, 17000, 8013},
            domains = {
                "asia.csoversea.mbgame.anticheatexpert.com",
                "asia.csoversea.mbgase.anticheatexpert.com",
            },
            ipRanges = {
                "101.32.143.0/24",
                "129.226.0.0/16",
            }
        },
        allow = {
            ports = {8080, 8088, 17500}
        }
    },
    blockedApps = {
        "com.realsignal.packetcapturepro",
        "com.reqable.android",
        "com.termux",
        "com.whatsapp",
    },
    allowedApps = {
        "ru.iiec.pyahmed",
        "com.deepseek.chat",
        "org.telegram.messenger.web",
    }
}
local function TO_IsValid(obj)
    return slua.isValid(obj)
end
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retEmptyString() return "" end
local function retTrue() return true end
local function BypassTssSdk()
    pcall(function()
        local TssSdk = _G.TssSdk
        if TssSdk then
            local reportFuncs = {
                "SendReportInfo", "ScanMemory", "IsEmulator", "GetTssSdkReportInfo",
                "CheckEnvironment", "VerifyProcess", "GetDeviceInfo", "GetFingerprint",
                "GetClientID", "GetFileMD5", "VerifyFileSignature", "OnRecvData",
                "GetModuleHash", "VerifyModule", "ScanProcess"
            }
            for _, fn in ipairs(reportFuncs) do
                if TssSdk[fn] then
                    TssSdk[fn] = nop
                end
            end
            TssSdk.IsEmulator = retFalse
            TssSdk.CheckEnvironment = retTrue
            TssSdk.VerifyProcess = retTrue
            TssSdk.ScanMemory = retTrue
        end
    end)
end
local function BypassMonitoringSystems()
    pcall(function()
        local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
        for _, fn in ipairs(swiftFuncs) do
            if _G[fn] then _G[fn] = nop end
        end
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subsToKill = {
                "CoronaLabSubsystem", "SwiftHawkSubsystem", "ClientHawkEyePatrolSubsystem",
                "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem",
                "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem",
                "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem",
                "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem",
                "CircleFlowSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem",
                "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"
            }
            for _, name in ipairs(subsToKill) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect") or
                            k:find("Flow") or k:find("Heartbeat")
                        ) then
                            pcall(function() sub[k] = nop end)
                        end
                    end
                end
            end
        end
    end)
end
local function BypassNetworkFilters()
    pcall(function()
        local blockedPorts = {80, 443, 20371, 15692, 18081, 8089, 9081, 10012, 8085, 9030, 17000, 8013}
        local allowedPorts = {8080, 8088, 17500}
        if NetUtil and NetUtil.SendPacket then
            local origSend = NetUtil.SendPacket
            NetUtil.SendPacket = function(packetName, ...)
                if packetName then
                    local p = tostring(packetName):lower()
                    if p:match("report") or p:match("cheat") or p:match("security") or
                       p:match("verify") or p:match("md5") or p:match("hash") or
                       p:match("integrity") or p:match("telemetry") or p:match("corona") or
                       p:match("swift") or p:match("hawk") or p:match("ban") or
                       p:match("inspect") or p:match("crash") then
                        return nil
                    end
                end
                return origSend(packetName, ...)
            end
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPCs = {
                "RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk",
                "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation",
                "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab",
                "RPC_Server_ReportPlayerBehavior", "RPC_Server_ReportTeammatHurt",
                "RPC_Server_ReportAimFlow", "RPC_Server_ReportHitFlow",
                "RPC_Server_ReportAttackFlow", "RPC_Server_ReportSecAttackFlow"
            }
            _G.SendRPC = function(rpcName, ...)
                for _, b in ipairs(blockedRPCs) do
                    if rpcName == b then return nil end
                end
                return origRPC(rpcName, ...)
            end
        end
    end)
end
local function BypassAppDetection()
    pcall(function()
        local blockedApps = {
            "com.realsignal.packetcapturepro",
            "com.reqable.android",
            "com.termux",
            "com.whatsapp",
        }
        local function isBlockedApp(name)
            for _, app in ipairs(blockedApps) do
                if name and name:find(app, 1, true) then
                    return true
                end
            end
            return false-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
        end
        local SystemInfo = import("SystemInfo")
        if SystemInfo then
            if SystemInfo.GetInstalledPackages then
                local orig = SystemInfo.GetInstalledPackages
                SystemInfo.GetInstalledPackages = function()
                    local packages = orig()
                    if packages then
                        local filtered = {}
                        for _, pkg in ipairs(packages) do
                            if not isBlockedApp(pkg) then
                                table.insert(filtered, pkg)
                            end
                        end
                        return filtered
                    end
                    return packages
                end
            end
        end
    end)
end
local function BypassFileCheck()
    pcall(function()
        local FAKE_MD5 = "7b1c7b5608da3083097816106fc331f9"
        local function patchMD5Functions(tbl)
            if type(tbl) ~= "table" then return end
            for k, v in pairs(tbl) do
                if type(v) == "function" then
                    local lk = tostring(k):lower()
                    if lk:match("md5") or lk:match("hash") or lk:match("crc") or
                       lk:match("sha") or lk:match("integrity") or lk:match("signature") or
                       lk:match("verifyfile") or lk:match("checkfile") then
                        tbl[k] = lk:match("md5") and function() return FAKE_MD5 end or retTrue
                    end
                end
            end
        end
        local modulesToPatch = {-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
            "CreativeModeBlueprintLibrary", "STExtraBlueprintFunctionLibrary",
            "GameplayStatics", "KismetMathLibrary", "KismetSystemLibrary",
            "FFileHelper", "GameplayData", "AvatarUtils", "TssSdk"
        }
        for _, name in ipairs(modulesToPatch) do
            pcall(function()
                local mod = package.loaded[name] or _G[name]
                if mod then patchMD5Functions(mod) end
            end)
        end
        local FileHelper = import("FFileHelper")
        if FileHelper then
            if FileHelper.GetFileSize then
                local orig = FileHelper.GetFileSize
                FileHelper.GetFileSize = function(path)
                    if path and tostring(path):lower():match(".pak") then
                        return 2000000000
                    end
                    return orig(path)-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
                end
            end
            if FileHelper.SaveStringToFile then
                local origSave = FileHelper.SaveStringToFile
                FileHelper.SaveStringToFile = function(str, path, ...)
                    if path and tostring(path):lower():match(".pak") then
                        return true
                    end
                    return origSave(str, path, ...)
                end
            end
        end
    end)
end
local function BypassMemoryCheck()
    pcall(function()
        local function patchMemoryFunctions(obj)
            if type(obj) ~= "table" then return end
            for k, v in pairs(obj) do
                if type(v) == "function" then
                    local lk = tostring(k):lower()
                    if lk:match("memory") or lk:match("scan") or lk:match("detect") or
                       lk:match("clean") or lk:match("guard") or lk:match("protect") then
                        obj[k] = nop
                    end
                end
            end-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
        end
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local memSub = SubMgr:Get("ClientMemoryGuardSubsystem")
            if memSub then
                patchMemoryFunctions(memSub)
                memSub.IsMemoryClean = retTrue
                memSub.ScanResult = retEmptyString
            end
        end
    end)
end
local function BypassDeviceBan()
    pcall(function()
        local fakeDeviceID = string.format("%032x", math.random(0, 2^128-1))
        local fakeAndroidID = string.format("%016x", math.random(0, 2^64-1))
        local fakeMac = string.format("%02X:%02X:%02X:%02X:%02X:%02X",
            math.random(0,255), math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255), math.random(0,255))
        local SystemInfo = import("SystemInfo")
        if SystemInfo then
            if SystemInfo.GetDeviceID then
                local orig = SystemInfo.GetDeviceID
                SystemInfo.GetDeviceID = function()
                    return fakeDeviceID
                end-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
            end
            if SystemInfo.GetMacAddress then
                local orig = SystemInfo.GetMacAddress
                SystemInfo.GetMacAddress = function()
                    return fakeMac
                end
            end
            if SystemInfo.GetAndroidId then
                local orig = SystemInfo.GetAndroidId
                SystemInfo.GetAndroidId = function()
                    return fakeAndroidID
                end
            end
        end
    end)
end
local function BypassAllReports()
    pcall(function()
        local reportFuncs = {
            "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
            "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior",
            "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick",
            "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow",
            "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow",
            "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
            "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate",
            "ReportCircleFlow", "ReportSecMrpcsFlow", "ReportAimData", "ReportRecoil",
            "ReportHeadshotRate", "ReportAccuracy", "ReportFireRate", "ReportRecoilKick",
            "ReportAutoAim", "ReportWeaponModification", "ReportWeaponStats",
            "ReportShootVerifyFail", "ReportHitIntegrity", "ClientAimTrackingUpdate",
            "ServerAimValidation", "ReportESPBox", "ReportESPHealth", "ReportMiniMapESP",
            "ReportEnemyFrameUI", "ReportMarkCreated", "ReportMarkDestroyed",
            "MarkSuspiciousESP", "OnScreenMarkAdd", "OnScreenMarkRemove", "ReportDistanceMarker",
            "ReportWallhackESP", "SendESPData", "UploadESPInfo", "ReportGameResult"-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
        }
        for _, fn in ipairs(reportFuncs) do
            if _G[fn] then _G[fn] = nop end
        end
        if _G.GameplayCallbacks then
            for k, v in pairs(_G.GameplayCallbacks) do
                if type(v) == "function" and (
                    k:find("Report") or k:find("Send") or k:find("Upload") or
                    k:find("Verify") or k:find("Check")
                ) then
                    _G.GameplayCallbacks[k] = nop
                end
            end
        end-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
    end)
end
local function BypassCrashReports()
    pcall(function()-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD
        local crashFuncs = {
            "BugglyPostExceptionFull", "CheckCanBugglyPostException", "ReplayReportData",
            "ReportGameException", "PostException", "SendReport", "SendException", "UploadLog",
            "ReportException", "SetCustomData", "Log", "SendCrash", "ReportUserException"
        }
        for _, fn in ipairs(crashFuncs) do
            if _G[fn] then _G[fn] = nop end
        end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = nop
            TLog.Warning = nop
            TLog.Error = nop
            TLog.Debug = nop
            TLog.Report = nop
            TLog.Send = nop
            TLog.Flush = nop
        end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = nop
            CrashSight.SetCustomData = nop
            CrashSight.Log = nop
            CrashSight.SendCrash = nop
            CrashSight.ReportUserException = nop
        end
    end)
end
local function BypassExtraProtections()
    pcall(function()
        if debug and debug.getinfo then
            debug.getinfo = function() return {} end
        end
        if debug and debug.getlocal then
            debug.getlocal = function() return nil end
        end
        if rawget(_G, "IsDebuggerPresent") then
            _G.IsDebuggerPresent = retFalse
        end
        _G.BlackList = {}
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
        end
    end)
end
function _G.StartTO_OLS1UltimateProtection()
    pcall(function()
        BypassTssSdk()
        BypassMonitoringSystems()
        BypassNetworkFilters()
        BypassAppDetection()
        BypassFileCheck()
        BypassMemoryCheck()
        BypassDeviceBan()
        BypassAllReports()
        BypassCrashReports()
        BypassExtraProtections()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local allSubs = {
                "ClientKernelCheckSubsystem", "ClientMemoryGuardSubsystem",
                "ClientDataStatistcsSubsystem", "AFKReportorSubsystem",
                "AvatarExceptionSubsystem", "ShootVerifySubSystemClient",
                "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
                "FileCheckSubsystem", "BehaviorScoreSubsystem", "GameReportSubsystem",
                "ReplaySubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem",
                "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem",
                "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem",
                "PakVerifySubsystem", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem"
            }
            for _, name in ipairs(allSubs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect") or
                            k:find("Flow") or k:find("Heartbeat") or k:find("Clean") or
                            k:find("Guard") or k:find("Protect") or k:find("Kernel")
                        ) then
                            pcall(function() sub[k] = nop end)
                        end
                    end
                end
            end
        end
        _G._TO_OLS1_PROTECTION_ACTIVE = true
    end)
end
_G.StartTO_OLS1UltimateProtection()
if not _G._TO_OLS1_ProtectionWatchdog then
    _G._TO_OLS1_ProtectionWatchdog = Game:SetTimer(5, true, function()
        if not _G._TO_OLS1_PROTECTION_ACTIVE then
            _G.StartTO_OLS1UltimateProtection()
        end
    end)
end

-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD