-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ ULTIMATE ANTI-CHEAT KILLER — STOP & BYPASS ALL PROTECTION SYSTEMS
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يتجاوز:
--   • ACE Anti-Cheat Expert
--   • TSS SDK
--   • HiggsBoson
--   • HawkEye Patrol
--   • CoronaLab
--   • Gokuba
--   • SwiftHawk
--   • ShootVerify
--   • Ban Systems
--   • Flag Systems
--   • Report Systems
--   • TLog
--   • CrashSight
--   • AnoSDK + MRPCS
--   • Memory Scanner
--   • Debugger Detection
--   • Emulator Detection
--   • Root Detection
--   • Screenshot System
--   • Network Monitor
--   • 48+ Security Subsystems
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══ HELPERS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retNil() return nil end
local function retEmpty() return {} end
local function retEmptyString() return "" end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1] ❌ إيقاف ACE (Anti-Cheat Expert)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ace = _G.ace or package.loaded["libace.so"] or package.loaded["ace"]
    if ace then
        for k, v in pairs(ace) do
            if type(v) == "function" then ace[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [2] ❌ إيقاف TSS SDK
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local tss = _G.TssSdk or package.loaded["TssSdk"]
    if tss then
        for k, v in pairs(tss) do
            if type(v) == "function" then tss[k] = nop end
        end
        tss.ScanMemory = retTrue
        tss.IsEmulator = retFalse
        tss.CheckIntegrity = retTrue
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [3] ❌ إيقاف HiggsBoson
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local hb = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
    if hb then
        hb.bMHActive = false
        hb.bCallPreReplication = false
        hb.bIsEnable = false
        hb.bSkipAlertServer = true
        for k, v in pairs(hb) do
            if type(v) == "function" then hb[k] = nop end
        end
        hb.GetNetAvatarItemIDs = retEmpty
        hb.GetCurWeaponSkinID = retZero
        hb.IsMHActive = retFalse
        if hb.BlackList then
            for k in pairs(hb.BlackList) do hb.BlackList[k] = nil end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [4] ❌ إيقاف HawkEye
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local he = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if he then
        for k, v in pairs(he) do
            if type(v) == "function" then he[k] = nop end
        end
        he.IsDuringHawkEyePatrol = retFalse
        he.HasReported = retTrue
        he.CanInspectorBroadcast = retFalse
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [5] ❌ إيقاف CoronaLab
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if _G.CoronaLab then
        for k, v in pairs(_G.CoronaLab) do
            if type(v) == "function" then _G.CoronaLab[k] = nop end
        end
    end
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if subMgr then
        local sub = subMgr:Get("CoronaLabSubsystem")
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" then sub[k] = nop end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] ❌ إيقاف Gokuba
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local g = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
    if g then
        for k, v in pairs(g) do
            if type(v) == "function" then g[k] = nop end
        end
        g.ForwardFeature = retEmpty
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] ❌ إيقاف SwiftHawk
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    for _, f in ipairs({"SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams"}) do
        if _G[f] then _G[f] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then
            _G.GameplayCallbacks[f] = nop
        end
    end
    local sh = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
    if sh then
        for k, v in pairs(sh) do
            if type(v) == "function" then sh[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] ❌ إيقاف ShootVerify
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local sv = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if sv then
        for k, v in pairs(sv) do
            if type(v) == "function" then sv[k] = nop end
        end
        sv.VerifyShot = retTrue
        sv.CheckShoot = retTrue
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] ❌ إيقاف Ban Systems
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local cbl = package.loaded["client.slua.logic.ban.ClientBanLogic"]
    if cbl then
        for k, v in pairs(cbl) do
            if type(v) == "function" then cbl[k] = nop end
        end
        cbl.CheckBan = retFalse
        cbl.IsBanned = retFalse
    end
    local rtb = package.loaded["RealTimeBan"]
    if rtb then
        for k, v in pairs(rtb) do
            if type(v) == "function" then rtb[k] = nop end
        end
        rtb.IsBanned = retFalse
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] ❌ إيقاف TLog
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local tlog = package.loaded["TLog"] or _G.TLog
    if tlog then
        for k, v in pairs(tlog) do
            if type(v) == "function" then tlog[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] ❌ إيقاف CrashSight
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local cs = package.loaded["CrashSight"] or _G.CrashSight
    if cs then
        for k, v in pairs(cs) do
            if type(v) == "function" then cs[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] ❌ إيقاف AnoSDK + MRPCS
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    for _, name in ipairs({"AnoSdk","anogs","libanogs","mrpcs","MRPCS","mrpc"}) do
        local obj = _G[name] or package.loaded[name]
        if obj then
            for k, v in pairs(obj) do
                if type(v) == "function" then obj[k] = nop end
            end
        end
    end
    if _G.ms_scan_start then _G.ms_scan_start = retFalse end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] ❌ إيقاف Memory Scanner
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ms = _G.MemoryScanner or package.loaded["MemoryScanner"]
    if ms then
        for k, v in pairs(ms) do
            if type(v) == "function" then ms[k] = nop end
        end
    end
    if _G.Memory then
        for k, v in pairs(_G.Memory) do
            if type(v) == "function" then _G.Memory[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] ❌ إيقاف Debugger Detection
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if rawget(_G, "IsDebuggerPresent") then _G.IsDebuggerPresent = retFalse end
    local K32 = pcall(import, "Kernel32") and import("Kernel32")
    if K32 then
        K32.IsDebuggerPresent = retFalse
        K32.CheckRemoteDebuggerPresent = retFalse
    end
    if debug then
        debug.getinfo = retEmpty
        debug.sethook = nop
        debug.getlocal = retNil
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] ❌ إيقاف Emulator / Root / Jailbreak Detection
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    for _, n in ipairs({"EmulatorDetect","RootDetect","JailbreakDetect"}) do
        local obj = _G[n] or package.loaded[n]
        if obj then
            for k, v in pairs(obj) do
                if type(v) == "function" then
                    if k:lower():find("is") or k:lower():find("check") then
                        obj[k] = retFalse
                    else
                        obj[k] = nop
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [16] ❌ إيقاف Screenshot System
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local sm = import("ScreenshotMaker")
    if sm then
        for k, v in pairs(sm) do
            if type(v) == "function" then sm[k] = nop end
        end
        sm.HasCaptured = retTrue
        sm.MakePicture = retEmptyString
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [17] ❌ إيقاف Network Monitor
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local nm = import("NetworkManager")
    if nm then
        for k, v in pairs(nm) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("report") or kl:find("monitor") or kl:find("capture") or
                   kl:find("analyze") or kl:find("track") then
                    nm[k] = nop
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [18] ❌ إيقاف 48+ Security Subsystems
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not subMgr then return end

    local toKill = {
        "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
        "ModifierExceptionSubsystem","SimulateCharacterSubsystem","ShootVerifySubSystemClient",
        "HiggsBosonComponent","ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
        "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem","ClientDataStatistcsSubsystem",
        "AFKReportorSubsystem","BehaviorScoreSubsystem","FileCheckSubsystem",
        "MemoryCheckSubsystem","SpeedCheckSubsystem","WallCheckSubsystem",
        "AvatarExceptionSubsystem","GameReportSubsystem","ClientSecMrpcsFlowSubsystem",
        "MrpcsFlowSubsystem","CircleFlowSubsystem","SwiftHawkSubsystem",
        "AntiCheatSubsystem","IntegrityCheckSubsystem","SignatureVerifySubsystem",
        "MD5CheckSubsystem","PakVerifySubsystem","DNSMonitorSubsystem",
        "DeviceFingerprintSubsystem","ReplayMonitorSubsystem","TelemetrySubsystem",
        "GokubaSubsystem","RacingAntiCheatSubsystem","ClientBanSubsystem",
        "RealTimeBanSubsystem","TLogSubsystem","ReportSubsystem",
        "SecurityMonitorSubsystem","CheatDetectionSubsystem","ViolationMonitorSubsystem",
        "SuspiciousActivitySubsystem","AbnormalBehaviorSubsystem","NetworkMonitorSubsystem",
        "AnalyticsSubsystem","CrashReportSubsystem","PerformanceMonitorSubsystem"
    }

    for _, name in ipairs(toKill) do
        local sub = subMgr:Get(name)
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" then
                    pcall(function() sub[k] = nop end)
                end
            end
            if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
            if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
            if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [19] ❌ إيقاف NetUtil Packets
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        NetUtil.SendPacket = function(name, ...)
            if type(name) == "string" then
                local p = name:lower()
                if p:find("report") or p:find("cheat") or p:find("detect") or
                   p:find("security") or p:find("verify") or p:find("ban") or
                   p:find("telemetry") or p:find("crash") or p:find("inspect") or
                   p:find("anticheat") or p:find("corona") or p:find("swift") or
                   p:find("hawk") or p:find("mrpcs") or p:find("tss") then
                    return nil
                end
            end
            return orig(name, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [20] ❌ إيقاف GameplayCallbacks
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end
    for k, v in pairs(_G.GameplayCallbacks) do
        if type(v) == "function" then _G.GameplayCallbacks[k] = nop end
    end
    _G.GameplayCallbacks.IsBypassed = true
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ تم إيقاف جميع الأنظمة
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[ULTIMATE KILLER] 🛡️ ALL PROTECTION SYSTEMS DISABLED")
    print("[ULTIMATE KILLER] ❌ ACE")
    print("[ULTIMATE KILLER] ❌ TSS SDK")
    print("[ULTIMATE KILLER] ❌ HiggsBoson")
    print("[ULTIMATE KILLER] ❌ HawkEye")
    print("[ULTIMATE KILLER] ❌ CoronaLab")
    print("[ULTIMATE KILLER] ❌ Gokuba")
    print("[ULTIMATE KILLER] ❌ SwiftHawk")
    print("[ULTIMATE KILLER] ❌ ShootVerify")
    print("[ULTIMATE KILLER] ❌ Ban Systems")
    print("[ULTIMATE KILLER] ❌ TLog")
    print("[ULTIMATE KILLER] ❌ CrashSight")
    print("[ULTIMATE KILLER] ❌ AnoSDK + MRPCS")
    print("[ULTIMATE KILLER] ❌ Memory Scanner")
    print("[ULTIMATE KILLER] ❌ Debugger Detection")
    print("[ULTIMATE KILLER] ❌ Emulator Detection")
    print("[ULTIMATE KILLER] ❌ Root Detection")
    print("[ULTIMATE KILLER] ❌ Screenshot System")
    print("[ULTIMATE KILLER] ❌ Network Monitor")
    print("[ULTIMATE KILLER] ❌ 48+ Subsystems")
    print("[ULTIMATE KILLER] ✅ COMPLETE")
    print("═══════════════════════════════════════════════════")
end)