-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ FILE: ANTI-PROTECTION KILLER — ULTIMATE
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يعطّل:
--   • ACE Anti-Cheat
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
--   • Network Reports
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══ [1] HELPERS ═══
local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retNil() return nil end
local function retEmpty() return {} end
local function retEmptyString() return "" end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [2] KILL ACE (Anti-Cheat Expert)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ace = _G.ace or package.loaded["libace.so"] or package.loaded["ace"]
    if ace then
        for k, v in pairs(ace) do
            if type(v) == "function" then
                ace[k] = nop
            end
        end
        -- دوال محددة
        ace.ReportData          = nop
        ace.ReportViolation     = nop
        ace.KickPlayer          = nop
        ace.BanPlayer           = nop
        ace.SendReport          = nop
        ace.ReportCheat         = nop
        ace.ReportHack          = nop
        ace.ReportMod           = nop
        ace.ReportInject        = nop
        ace.ReportHook          = nop
        ace.ReportPatch         = nop
        ace.ReportTamper        = nop
        ace.CheckIntegrity      = retTrue
        ace.VerifyProcess       = retTrue
        ace.CheckModule         = retTrue
        ace.ValidateClient      = retTrue
        ace.ScanMemory          = retFalse
        ace.CheckDebugger       = retFalse
        ace.CheckEmulator       = retFalse
        ace.CheckRoot           = retFalse
        ace.CollectInfo         = retEmpty
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [3] KILL TSS SDK
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local tss = _G.TssSdk or package.loaded["TssSdk"]
    if tss then
        local funcs = {
            "OnRecvData","SendReportInfo","ReportException","ReportData",
            "UploadLog","SendAntiData","ReportGameStart","ReportGameEnd",
            "ReportCrash","ReportViolation","ReportSuspicious","ReportBan",
            "ReportKick","ReportWarning","ReportInfo","ReportDebug",
            "ReportError","ReportFatal","ReportMemory","ReportProcess",
            "ReportModule","ReportThread","ReportFile","ReportNetwork",
            "ReportDevice","ReportSystem","ReportGame","ReportUser",
            "ReportAccount","ReportSession","ReportPerformance","ReportBattery",
            "ReportTemperature","ReportFPS","ReportPing","ReportPacket",
            "ReportCheat","ReportHack","ReportMod","ReportInject",
            "ReportDebugger","ReportEmulator","ReportRoot","ReportJailbreak",
            "ReportVM","ReportHook","ReportPatch","ReportTamper",
            "ReportCorrupt","ReportInvalid","ReportSpoof","ReportFake",
            "ScanMemory","GetTssSdkReportInfo","CheckEnvironment",
            "VerifyProcess","VerifySignature","CollectEvidence",
            "GetFileMD5","VerifyFileSignature","GetModuleHash",
            "VerifyModule","ScanProcess"
        }
        for _, f in ipairs(funcs) do
            if tss[f] then tss[f] = nop end
        end
        tss.ScanMemory          = retTrue
        tss.IsEmulator          = retFalse
        tss.CheckIntegrity      = retTrue
        tss.GetTssSdkReportInfo = retEmptyString
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [4] KILL HiggsBoson
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local hb = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
    if hb then
        hb.bMHActive = false
        hb.bCallPreReplication = false
        hb.bIsEnable = false
        hb.bSkipAlertServer = true

        local funcs = {
            "ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck",
            "StartAvatarCheck","ReportItemID","OnReportItemID","ReceiveAnyDamage",
            "OnWeaponHitRecord","ShowSecurityAlert","StaticShowSecurityAlertInDev",
            "SendHisarData","OnLogin","ValidateSecurityData","CheckMemoryIntegrity",
            "ReportAbnormalMemory","OnMemoryScanComplete","SendDetectionResult",
            "TriggerClientScan","SendAntiDataFlow","SendHitFireBtnFlow","SkipAlertServer",
            "CheckWeaponIntegrity","CheckAvatarIntegrity","CheckBulletIntegrity",
            "OnGameModeType","OnBattleResult","RPC_Client_ShowSecurityAlertWindow",
            "RPC_Server_TellServerName","RecordStrategyTimestampInReplay",
            "SetClientAlertWindowEnabled","_ReportChatRobot","_ClientShowSecurityAlertWindow",
            "ShowABCD","ReceiveBeginPlay","_ProcessReportChatRobotQueue",
            "LuaNotifySecurityAbnormalJump","DisableHiggsBoson","CheckMHActive",
            "ReportViolation","ProcessSecurityEvent","ValidatePlayer","CheckIntegrity"
        }
        for _, f in ipairs(funcs) do
            if hb[f] then hb[f] = nop end
        end
        hb.GetNetAvatarItemIDs   = retEmpty
        hb.GetCurWeaponSkinID    = retZero
        hb.IsMHActive            = retFalse
        hb.IsCharacterOwnerWerewolf = retFalse
        hb.IsCharacterOwnerButcher  = retFalse
        if hb.BlackList then
            for k in pairs(hb.BlackList) do hb.BlackList[k] = nil end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [5] KILL HawkEye
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local he = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if he then
        for k, v in pairs(he) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("report") or kl:find("hawk") or kl:find("send") or
                   kl:find("request") or kl:find("try") or kl:find("show") or
                   kl:find("start") or kl:find("mark") or kl:find("imprison") or
                   kl:find("collect") or kl:find("flag") then
                    he[k] = nop
                end
            end
        end
        he.IsDuringHawkEyePatrol = retFalse
        he.HasReported           = retTrue
        he.CanInspectorBroadcast = retFalse
        he.IsCharacterLocationShouldDraw = retFalse
    end
    local ds = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSHawkEyePatrolSubsystem"]
    if ds then
        ds.OnInit = nop
        ds.ReportCheat = nop
        ds.RequestImprison = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] KILL CoronaLab
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if _G.CoronaLab then
        _G.CoronaLab.ReportData      = nop
        _G.CoronaLab.SendData        = nop
        _G.CoronaLab.CollectData     = nop
        _G.CoronaLab.Telemetry       = nop
        _G.CoronaLab.SendTelemetry   = nop
        _G.CoronaLab.ReportException = nop
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
-- [7] KILL Gokuba
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local g = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
    if g then
        g.ForwardFeature = function() return {0,0,0,0,0} end
        g.InitGokubaLogic = nop
        if g.TimerHandle then
            local ticker = require("common.time_ticker")
            if ticker then ticker.RemoveTimer(g.TimerHandle) end
            g.TimerHandle = nil
        end
        for k, v in pairs(g) do
            if type(v) == "function" then g[k] = nop end
        end
    end
    if _G.GokubaLogic then
        _G.GokubaLogic.ForwardFeature = retEmpty
        _G.GokubaLogic.InitGokubaLogic = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] KILL SwiftHawk
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local funcs = {"SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams","SendSwiftHawkData","SwiftHawkReport"}
    for _, f in ipairs(funcs) do
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
-- [9] KILL ShootVerify
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local sv = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if sv then
        sv.OnShootVerifyFailed = nop
        sv.SendVerifyData      = nop
        sv.ReportBulletHit     = nop
        sv.UploadHitInfo       = nop
        sv.VerifyShot          = retTrue
        sv.CheckShoot          = retTrue
        sv.ValidateShoot       = retTrue
        sv.IsShootValid        = retTrue
    end
    if _G.BulletHitInfoUploadData then
        _G.BulletHitInfoUploadData.Report = nop
        _G.BulletHitInfoUploadData.Send   = nop
        _G.BulletHitInfoUploadData.Upload = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] KILL Ban Systems
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local cbl = package.loaded["client.slua.logic.ban.ClientBanLogic"]
    if cbl then
        cbl.ReqBanInfo                  = nop
        cbl.OnVoiceSwitchNotify         = nop
        cbl.OnVoiceBanNotify            = nop
        cbl.OnRealTimeVoiceBanNotify    = nop
        cbl.OnVoiceBanSuccess           = nop
        cbl.IsVoiceReportEnable         = retFalse
        cbl.OnSyncMicSuspicious         = nop
        cbl.OnSyncMicPreFilter          = nop
        cbl.OnSyncBanInfo               = nop
        cbl.OnNotifyWarningTips         = nop
        cbl.CheckBan                    = retFalse
        cbl.IsBanned                    = retFalse
        cbl.VoiceBanEndTime             = 0
        cbl.bEnableVoiceReport          = false
        cbl.SuspiciousFlag              = 0
    end
    local rtb = package.loaded["RealTimeBan"]
    if rtb then
        rtb.Init                          = nop
        rtb.OnPlayerWithRealTimeBan       = nop
        rtb.OnSyncPlayerInfo              = nop
        rtb.HandleEnterGameModeFightingState = nop
        rtb.ShowAlias                     = nop
        rtb.SetOnRankInspectorUID         = nop
        rtb.IsUIDOnRankInspector          = retFalse
        rtb.GetUIDInspectorRank           = function() return -1 end
        rtb.SetInspectorBroadcastCountUID = nop
        rtb.GetUIDInspectorBroadcastCount = function() return -1 end
        rtb.GetTipsIDOffset               = retZero
        rtb.IsBanned                      = retFalse
        rtb.GetBanTime                    = retZero
        rtb.GetBanReason                  = retEmptyString
    end
    local bs = package.loaded["BanSystem"]
    if bs then
        bs.CheckBan     = retFalse
        bs.IsBanned     = retFalse
        bs.GetBanReason = retEmptyString
        bs.GetBanTime   = retZero
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] KILL TLog
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local tlog = package.loaded["TLog"] or _G.TLog
    if tlog then
        tlog.Info    = nop
        tlog.Warning = nop
        tlog.Error   = nop
        tlog.Debug   = nop
        tlog.Report  = nop
        tlog.Send    = nop
        tlog.Flush   = nop
        tlog.Log     = nop
        tlog.Trace   = nop
        tlog.Verbose = nop
    end
    local tr = package.loaded["client.slua.config.tlog.tlog_report_utils"]
    if tr then
        for k, v in pairs(tr) do
            if type(v) == "function" then tr[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] KILL CrashSight
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local cs = package.loaded["CrashSight"] or _G.CrashSight
    if cs then
        for k, v in pairs(cs) do
            if type(v) == "function" then cs[k] = nop end
        end
        cs.ReportException      = nop
        cs.SetCustomData        = nop
        cs.Log                  = nop
        cs.SendCrash            = nop
        cs.ReportUserException  = nop
        cs.CollectInfo          = retEmpty
    end
    local cr = package.loaded["client.slua.logic.crash.CrashReporter"]
    if cr then
        cr.SendReport = nop
        cr.SaveDump   = nop
        cr.UploadDump = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] KILL AnoSDK + MRPCS
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ano = _G.AnoSdk or package.loaded["AnoSdk"]
    if ano then
        for k, v in pairs(ano) do
            if type(v) == "function" then ano[k] = nop end
        end
    end
    for _, name in ipairs({"mrpcs","MRPCS","mrpc","libanogs","anogs","libmrpcs"}) do
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
-- [14] KILL GameplayCallbacks
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end

    local gc = _G.GameplayCallbacks
    for k, v in pairs(gc) do
        if type(v) == "function" then
            local kl = k:lower()
            if kl:find("report") or kl:find("send") or kl:find("upload") or
               kl:find("verify") or kl:find("check") or kl:find("validate") or
               kl:find("detect") or kl:find("scan") or kl:find("monitor") or
               kl:find("flag") or kl:find("ban") or kl:find("kick") then
                gc[k] = nop
            end
        end
    end
    gc.IsBypassed = true
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] KILL NetUtil Packets
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        NetUtil.SendPacket = function(name, ...)
            if type(name) == "string" then
                local p = name:lower()
                if p:find("report") or p:find("cheat") or p:find("detect") or
                   p:find("security") or p:find("integrity") or p:find("verify") or
                   p:find("ban") or p:find("telemetry") or p:find("crash") or
                   p:find("inspect") or p:find("anticheat") or p:find("corona") or
                   p:find("swift") or p:find("hawk") or p:find("mrpcs") or
                   p:find("tss_sdk") or p:find("on_anti") or p:find("packet") then
                    return nil
                end
            end
            return orig(name, ...)
        end
        NetUtil.IsBypassed = true
    end
    if _G.SendRPC then
        local origRPC = _G.SendRPC
        _G.SendRPC = function(rpcName, ...)
            if type(rpcName) == "string" then
                local r = rpcName:lower()
                if r:find("report") or r:find("ban") or r:find("cheat") or
                   r:find("verify") or r:find("security") or r:find("swift") or
                   r:find("hawk") or r:find("corona") or r:find("mrpcs") then
                    return nil
                end
            end
            return origRPC(rpcName, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [16] KILL All Security Subsystems
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
                    local kl = k:lower()
                    if kl:find("report") or kl:find("send") or kl:find("upload") or
                       kl:find("verify") or kl:find("check") or kl:find("validate") or
                       kl:find("scan") or kl:find("detect") or kl:find("collect") or
                       kl:find("flow") or kl:find("heartbeat") or kl:find("monitor") or
                       kl:find("track") or kl:find("record") or kl:find("log") or
                       kl:find("alert") or kl:find("notify") or kl:find("ban") or
                       kl:find("kick") or kl:find("suspend") or kl:find("flag") then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
            if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
            if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
            if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            if sub.checkTimer then pcall(function() sub:RemoveGameTimer(sub.checkTimer) end) end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [17] BLOCK require() للأنظمة الخطيرة
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local origReq = require
    local blocked = {
        "HiggsBosonComponent","PlayerSecurityInfoSubsystem","CoronaLabSubsystem",
        "ClientCircleFlowSubsystem","ModifierExceptionSubsystem","ShootVerifySubSystemClient",
        "ClientReportPlayerSubsystem","DSReportPlayerSubsystem","Gokuba",
        "SwiftHawkSubsystem","ClientBanLogic","RealTimeBan","RacingAntiCheatLogic"
    }
    _G.require = function(m)
        if type(m) == "string" then
            for _, b in ipairs(blocked) do
                if m:find(b) then return {} end
            end
        end
        return origReq(m)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [18] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[ANTI-PROTECTION KILLER] 🛡️ LOADED")
    print("[ANTI-PROTECTION KILLER] ❌ ACE disabled")
    print("[ANTI-PROTECTION KILLER] ❌ TSS SDK disabled")
    print("[ANTI-PROTECTION KILLER] ❌ HiggsBoson disabled")
    print("[ANTI-PROTECTION KILLER] ❌ HawkEye disabled")
    print("[ANTI-PROTECTION KILLER] ❌ CoronaLab disabled")
    print("[ANTI-PROTECTION KILLER] ❌ Gokuba disabled")
    print("[ANTI-PROTECTION KILLER] ❌ SwiftHawk disabled")
    print("[ANTI-PROTECTION KILLER] ❌ ShootVerify disabled")
    print("[ANTI-PROTECTION KILLER] ❌ Ban Systems disabled")
    print("[ANTI-PROTECTION KILLER] ❌ TLog disabled")
    print("[ANTI-PROTECTION KILLER] ❌ CrashSight disabled")
    print("[ANTI-PROTECTION KILLER] ❌ AnoSDK + MRPCS disabled")
    print("[ANTI-PROTECTION KILLER] ❌ 48+ Subsystems disabled")
    print("[ANTI-PROTECTION KILLER] ✅ Complete")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF FILE
-- ═══════════════════════════════════════════════════════════════════════════════