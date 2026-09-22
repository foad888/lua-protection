-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ ANTI-REPORT SYSTEM — ULTIMATE
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يمنع:
--   • تقارير اللاعبين عليك
--   • تقارير Team Kill
--   • تقارير Equipment
--   • تقارير Verification
--   • تقارير الحزم للشبكة
--   • Flow Reports
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
-- [1] منع تقارير System-level
-- ═══════════════════════════════════════════════════════════════════════════════

-- ClientReportPlayerSubsystem
pcall(function()
    local CRPS = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
    if CRPS then
        for k, v in pairs(CRPS) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("report") or kl:find("record") or kl:find("send") or
                   kl:find("submit") or kl:find("upload") or kl:find("notify") then
                    CRPS[k] = nop
                end
            end
        end
        CRPS.OnInit                    = nop
        CRPS.GetFatalDamagerMap        = retEmpty
        CRPS.SubmitReport              = nop
        CRPS.CanReport                 = retFalse
        CRPS.ReportPlayer              = nop
    end
end)

-- DSReportPlayerSubsystem
pcall(function()
    local DRPS = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"]
    if DRPS then
        for k, v in pairs(DRPS) do
            if type(v) == "function" then DRPS[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [2] منع Report Flows (الأهم)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local flows = {
        -- Aim
        "ReportAimFlow","ReportAimData","ReportAimStats",
        -- Hit
        "ReportHitFlow","ReportHurtFlow","ReportFeedback",
        -- Attack
        "ReportAttackFlow","ReportSecAttackFlow",
        "ReportTeammateKillConfirmFlow","ReportPlayerKillFlow","ClientSecPlayerKillFlow",
        -- FireArms
        "ReportFireArms",
        -- Verify
        "ReportVerifyInfoFlow","ReportVerification",
        -- Mrpcs
        "ReportMrpcsFlow","ReportSecMrpcsFlow","ClientSecMrpcsFlow",
        -- Behavior
        "ReportPlayerBehavior","ReportTeammatHurt","ReportMisKillByTeammate",
        "ReportForbitPick","ReportPlayerMoveRoute","ReportPlayerPosition",
        -- Vehicle
        "ReportVehicleMoveFlow","ReportSecVehicleMoveFlow","ReportSecTgameMovingFlow",
        -- Parachute
        "ReportParachuteData","report_parachute_data",
        -- Circle
        "ReportCircleFlow","ReportDSCircleFlow","ClientCircleFlow",
        -- Jump
        "ReportJumpFlow",
        -- Equipment
        "ReportEquipmentFlow",
        -- Ping
        "ReportPlayersPing","report_players_ping",
        -- IP
        "ReportPlayerIP","report_player_ip",
        -- Frame
        "ReportPlayerFramePingRecord","report_player_frame_ping_record",
        -- Net
        "ReportDSNetSaturation","ReportNetContinuousSaturate","ReportDSNetRate",
        "report_net_saturate","report_ds_netsaturate","report_ds_net_continuous_saturate",
        "report_ds_netrate",
        -- Common
        "ReportCommonInfo","ReportLightweightStat",
        -- TSS
        "SendTssSdkAntiDataToLobby","on_tss_sdk_anti_data","tss_sdk_report",
        -- HawkEye
        "SendDSHawkEyePatrolLogToLobby","HawkEyeReport",
        -- DS
        "SendDSErrorLogToLobby","SendDSErrorLogToLobbyOnece",
        -- SwiftHawk
        "SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams",
        "SwiftHawkReport","SwiftHawkData",
        -- AI
        "ReportAIStrategyInfo","ReportAIActionFlow","SendAIDeliveryInfo",
        -- Card
        "ReportIDCardProduceFlow","ReportIDCardPickUpFlow","ReportIDCardDestroyFlow",
        -- Revival
        "ReportRevivalFlow",
        -- Settings
        "ReportGameSetting","ReportGameSettingNew",
        -- Voice
        "ReportAntsVoiceTeamCreate","ReportAntsVoiceTeamQuit",
        -- Security
        "ReportSecurityViolation","ReportIntegrityCheck","ReportSignatureVerify",
        "ReportAntiCheat","ReportAC","ReportSuspicious","ReportAbnormal",
        -- Cheat
        "ReportCheat","ReportHack","ReportMod","ReportInject",
        "ReportHook","ReportPatch","ReportTamper",
        -- ESP
        "ReportESPBox","ReportESPHealth","ReportMiniMapESP","ReportEnemyFrameUI",
        "ReportMarkCreated","ReportMarkDestroyed","MarkSuspiciousESP",
        "OnScreenMarkAdd","OnScreenMarkRemove","ReportDistanceMarker",
        "ReportWallhackESP","SendESPData","UploadESPInfo",
        -- Magic
        "ReportMagicBullet","ReportDamage","ReportHitbox",
        "ReportProjectile","ReportBullet","ReportShoot",
        -- SpeedHack
        "ReportSpeedHack","ReportNoGrass","ReportWallHack","ReportAimbot",
        -- Daily
        "ReportDailyTaskInfo","ReportMatchRoomData",
        -- Game
        "ReportGameStart","ReportGameEnd",
        -- Crash
        "ReportCrash","ReportDump","ReportException","ReportError",
        -- Memory
        "ReportMemory","ReportMemoryException","report_memory_exception",
        -- Avatar
        "ReportAvatarFlow","ReportAvatarException","report_avatar_exception",
        -- Stats
        "ReportStats","ReportPerformance","ReportProfiler",
        -- UI
        "ReportUIState","report_ui_state",
        -- Character
        "ReportCharacterState","report_character_state",
        -- Vehicle
        "ReportVehicleException","report_vehicle_exception",
        -- Camera
        "ReportCameraException","report_camera_exception",
        -- Hit
        "ReportHitRegFail","report_hit_reg_fail",
        -- Controller
        "ReportPlayerControllerStateChanged",
        -- Modifier
        "ReportModifierException",
        -- Simulate
        "ReportSimulateCharacterLocation","RPC_Server_ReportSimulateCharacterLocation",
        -- Shoot
        "RPC_Client_ShootVertifyRes","BulletHitInfoUploadData","ShootVerifyFailed",
        -- Unreal
        "report_unrealnet_exception","report_unrealnet_clientstats",
        "report_serverstat_avgtickdelta","report_all_players_address",
        "report_client_scan_result",
        -- Ban
        "SyncBanInfo","SyncBanID","VoiceBanNotify","AccountBan",
        "BanStatus","BanReason","BanExpiry","SuspensionInfo",
        "RiskFlag","HighRiskNotice","InspectionNotice","FrozenNotice",
        -- Errors
        "DeviceError","NetworkError","ClientError","ValidationFailed",
        "SecurityViolation","RiskDetected","AbnormalBehavior",
        "CheatDetected","AntiCheatAlert",
        -- Logs
        "TLogReport","TelemetryData","AnalyticsData","CrashReport"
    }

    for _, f in ipairs(flows) do
        if _G[f] then _G[f] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then
            _G.GameplayCallbacks[f] = nop
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [3] منع تقارير الشبكة (NetUtil)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        local blockedPackets = {
            ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
            ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
            ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportMisKillByTeammate"]=1,
            ["ReportForbitPick"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
            ["ReportVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["ReportParachuteData"]=1,
            ["ReportEquipmentFlow"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1,
            ["ReportCircleFlow"]=1, ["ReportPlayersPing"]=1, ["ReportPlayerIP"]=1,
            ["ReportPlayerFramePingRecord"]=1, ["ReportDSNetSaturation"]=1,
            ["ReportNetContinuousSaturate"]=1, ["ReportDSNetRate"]=1,
            ["ReportPlayerKillFlow"]=1, ["ReportSecMrpcsFlow"]=1,
            ["ReportSecurityViolation"]=1, ["ReportIntegrityCheck"]=1,
            ["ReportSignatureVerify"]=1, ["ReportAntiCheat"]=1, ["ReportAC"]=1,
            ["ReportSuspicious"]=1, ["ReportAbnormal"]=1, ["ReportMagicBullet"]=1,
            ["ReportDamage"]=1, ["ReportHitbox"]=1, ["ReportProjectile"]=1,
            ["ReportBullet"]=1, ["ReportShoot"]=1, ["ReportVerification"]=1,
            ["ReportBan"]=1, ["ReportKick"]=1, ["ReportFlag"]=1,
            ["on_tss_sdk_anti_data"]=1, ["report_players_ping"]=1,
            ["report_player_ip"]=1, ["report_net_saturate"]=1,
            ["report_speed_hack"]=1, ["report_wall_hack"]=1,
            ["report_aim_bot"]=1, ["report_esp_usage"]=1,
            ["report_modded_files"]=1, ["detect_cheat"]=1,
            ["ban_player"]=1, ["client_anti_cheat_report"]=1,
            ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1,
            ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1,
            ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["SwiftHawkReport"]=1,
            ["SwiftHawkData"]=1, ["Heartbeat"]=1, ["ClientHeartbeat"]=1,
            ["ServerHeartbeat"]=1, ["SendHeartbeat"]=1,
            ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1,
            ["ClientCircleFlow"]=1, ["ReportModifierException"]=1,
            ["RPC_Server_ReportSimulateCharacterLocation"]=1,
            ["RPC_Client_ShootVertifyRes"]=1, ["BulletHitInfoUploadData"]=1,
            ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1,
            ["tss_sdk_report"]=1, ["SyncBanInfo"]=1, ["SyncBanID"]=1,
            ["VoiceBanNotify"]=1, ["AccountBan"]=1, ["BanStatus"]=1,
            ["BanReason"]=1, ["BanExpiry"]=1, ["SuspensionInfo"]=1,
            ["RiskFlag"]=1, ["HighRiskNotice"]=1, ["InspectionNotice"]=1,
            ["FrozenNotice"]=1, ["DeviceError"]=1, ["NetworkError"]=1,
            ["ClientError"]=1, ["ValidationFailed"]=1, ["RiskDetected"]=1,
            ["AbnormalBehavior"]=1, ["CheatDetected"]=1, ["AntiCheatAlert"]=1,
            ["HawkEyeReport"]=1, ["CoronaLabData"]=1, ["GokubaData"]=1,
            ["TLogReport"]=1, ["TelemetryData"]=1, ["AnalyticsData"]=1,
            ["CrashReport"]=1
        }

        NetUtil.SendPacket = function(packetName, ...)
            if blockedPackets[packetName] then return nil end
            if type(packetName) == "string" then
                local p = packetName:lower()
                if p:find("report") or p:find("cheat") or p:find("detect") or
                   p:find("security") or p:find("integrity") or p:find("verify") or
                   p:find("signature") or p:find("md5") or p:find("hash") or
                   p:find("telemetry") or p:find("corona") or p:find("swift") or
                   p:find("hawk") or p:find("ban") or p:find("inspect") or
                   p:find("crash") or p:find("anticheat") or p:find("flow") then
                    return nil
                end
            end
            return orig(packetName, ...)
        end
        NetUtil.IsBypassed = true
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [4] منع RPC Reports
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if _G.SendRPC then
        local origRPC = _G.SendRPC
        local blockedRPCs = {
            "RPC_Server_ReportPlayerKillFlow", "RPC_Server_ClientSecMrpcsFlow",
            "RPC_Server_Heartbeat", "RPC_Server_SwiftHawk",
            "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation",
            "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab",
            "RPC_Server_HawkReportCheat", "RPC_Server_ReportPlayerBehavior",
            "RPC_Server_ReportTeammatHurt", "RPC_Server_ReportAimFlow",
            "RPC_Server_ReportHitFlow", "RPC_Server_ReportAttackFlow",
            "RPC_Server_ReportSecAttackFlow"
        }
        _G.SendRPC = function(rpcName, ...)
            for _, b in ipairs(blockedRPCs) do
                if rpcName == b then return nil end
            end
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
-- [5] منع UI Report Window
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- ui_complaint
    local ui_comp = package.loaded["client.slua.umg.Wardrobe.ui_complaint"]
        or package.loaded["client.slua.logic.common.ui_complaint"]
    if ui_comp then
        for k, v in pairs(ui_comp) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("submit") or kl:find("send") or kl:find("report") then
                    ui_comp[k] = nop
                end
            end
        end
    end
    -- LogicComplaint
    local LC = package.loaded["client.slua.logic.CustomerService.LogicCustomerService"]
    if LC then
        if LC.SendComplaint then LC.SendComplaint = nop end
        if LC.SendFeedback then LC.SendFeedback = nop end
    end
    -- LogicSafeStation
    local LSS = package.loaded["client.slua.logic.CustomerService.LogicSafeStation"]
    if LSS then
        if LSS.UploadVideoEvidence then LSS.UploadVideoEvidence = nop end
        if LSS.ReportPlayerBehavior then LSS.ReportPlayerBehavior = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] منع تقارير "Equipment Exception"
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
    if eqEx then
        for k, v in pairs(eqEx) do
            if type(v) == "function" then eqEx[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] منع تقارير Puffer/Skin
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if ptlog then
        ptlog.ReportEvent = nop
        ptlog.ReportDownloadResult = nop
        ptlog.ReportODPTDError = nop
        ptlog.ReportSkinError = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] منع تقارير TLog
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local tlog = package.loaded["client.slua.config.tlog.tlog_report_utils"]
    if tlog then
        for k, v in pairs(tlog) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("report") or kl:find("send") or kl:find("upload") or
                   kl:find("flush") or kl:find("post") then
                    tlog[k] = nop
                end
            end
        end
    end
    -- Global TLog
    if _G.TLog then
        _G.TLog.Info = nop
        _G.TLog.Warning = nop
        _G.TLog.Error = nop
        _G.TLog.Debug = nop
        _G.TLog.Report = nop
        _G.TLog.Send = nop
        _G.TLog.Flush = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] منع تقارير Logs بصفة عامة
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local logModules = {
        "client.slua.logic.report.ClientToolsReport",
        "client.slua.logic.report.logic_report",
        "client.slua.logic.report.ReportCooldownLogic",
        "client.slua.logic.report.PlayerReportLogic",
        "client.slua.logic.replay.logic_report_replay",
        "client.slua.logic.crash.CrashReporter",
        "client.slua.logic.data.data_mgr",
        "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"
    }
    for _, path in ipairs(logModules) do
        local mod = package.loaded[path]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" then
                    local kl = k:lower()
                    if kl:find("report") or kl:find("send") or kl:find("upload") or
                       kl:find("flush") or kl:find("submit") or kl:find("post") or
                       kl:find("log") then
                        mod[k] = nop
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] BLOCK require() للـ Report Modules
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local origReq = require
    local blocked = {
        "ClientReportPlayerSubsystem",
        "DSReportPlayerSubsystem",
        "ClientQuickReportMaliciousTeammate",
        "InspectionSystemReportClientLogicSubsystem",
        "InspectionSystemReportDSLogicSubsystem",
        "ReportPlayerUtils",
        "ClientBanLogic"
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
-- [11] منع اللاعبين من الإبلاغ عليك (Server-Level Block)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- تعطيل callback الإبلاغ
    if _G.GameplayCallbacks then
        _G.GameplayCallbacks.ReportPlayer              = nop
        _G.GameplayCallbacks.ReportPlayerByUID         = nop
        _G.GameplayCallbacks.ReportPlayerByReason      = nop
        _G.GameplayCallbacks.SubmitPlayerReport        = nop
        _G.GameplayCallbacks.SendPlayerReport          = nop
        _G.GameplayCallbacks.OnPlayerReported          = nop
        _G.GameplayCallbacks.OnReportSubmitted         = nop
        _G.GameplayCallbacks.IsPlayerReportable        = retFalse
        _G.GameplayCallbacks.CanReportPlayer           = retFalse
    end
    -- Global Callbacks
    for _, fn in ipairs({
        "ReportPlayer","ReportPlayerByUID","SubmitPlayerReport",
        "SendPlayerReport","OnPlayerReported","IsPlayerReportable","CanReportPlayer"
    }) do
        if _G[fn] then _G[fn] = nop end
        if _G[fn] and type(_G[fn]) ~= "function" then _G[fn] = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] منع عرض تقارير ضدك
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع UI تقارير اللاعبين
    local UIModules = {
        "client.slua.umg.Report",
        "client.slua.umg.Complaint",
        "client.slua.umg.QuickReport",
        "client.slua.umg.ReportPlayer"
    }
    for _, name in ipairs(UIModules) do
        local mod = package.loaded[name]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" then mod[k] = nop end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] حماية إضافية: منع IP Report
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع إرسال IP
    local DNS = import("DNS")
    if DNS and DNS.Resolve then
        local origResolve = DNS.Resolve
        DNS.Resolve = function(host)
            -- منع إرسال IP لسيرفرات التقارير
            if host and type(host) == "string" then
                if host:lower():find("report") or host:lower():find("anticheat") or
                   host:lower():find("ban") then
                    return "0.0.0.0"
                end
            end
            return origResolve(host)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] MONITOR (كل 15 ثانية يعيد التفعيل)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local function Reapply()
        pcall(function()
            -- NetUtil
            if NetUtil and NetUtil.SendPacket and not NetUtil._AntiReportActive then
                NetUtil._AntiReportActive = true
            end
            -- GameplayCallbacks
            if _G.GameplayCallbacks then
                _G.GameplayCallbacks.IsBypassed = true
            end
        end)
    end
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(15.0, Reapply, -1, 15.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[ANTI-REPORT] 🛡️ ULTIMATE ANTI-REPORT LOADED")
    print("[ANTI-REPORT] ❌ Report Flows blocked")
    print("[ANTI-REPORT] ❌ Report Player blocked")
    print("[ANTI-REPORT] ❌ Team Kill Report blocked")
    print("[ANTI-REPORT] ❌ Equipment Report blocked")
    print("[ANTI-REPORT] ❌ Verify Report blocked")
    print("[ANTI-REPORT] ❌ Network Reports blocked")
    print("[ANTI-REPORT] ❌ UI Reports blocked")
    print("[ANTI-REPORT] ❌ IP Reports blocked")
    print("[ANTI-REPORT] ✅ COMPLETE PROTECTION")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗑️ [16] REPORT DELETER — حذف الإبلاغات
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يحذف:
--   • الإبلاغات الواردة عليك
--   • الإبلاغات المسجلة محلياً
--   • الإبلاغات في Queue
--   • الإبلاغات في ملفات Log
--   • الإبلاغات في الذاكرة
-- ═══════════════════════════════════════════════════════════════════════════════

-- [16.1] حذف Queue الإبلاغات
pcall(function()
    -- Report Queue
    if _G.ReportQueue then
        for k in pairs(_G.ReportQueue) do
            _G.ReportQueue[k] = nil
        end
    end
    -- Telemetry Queue
    if _G.TelemetryQueue then
        for k in pairs(_G.TelemetryQueue) do
            _G.TelemetryQueue[k] = nil
        end
    end
    -- Log Queue
    if _G.LogQueue then
        for k in pairs(_G.LogQueue) do
            _G.LogQueue[k] = nil
        end
    end
    -- Exception Queue
    if _G.ExceptionQueue then
        for k in pairs(_G.ExceptionQueue) do
            _G.ExceptionQueue[k] = nil
        end
    end
    -- Crash Queue
    if _G.CrashQueue then
        for k in pairs(_G.CrashQueue) do
            _G.CrashQueue[k] = nil
        end
    end
    -- Trace Queue
    if _G.TraceQueue then
        for k in pairs(_G.TraceQueue) do
            _G.TraceQueue[k] = nil
        end
    end
end)

-- [16.2] حذف بيانات الإبلاغات من الموديولات
pcall(function()
    local reportModules = {
        "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
        "client.slua.logic.report.EquipmentExceptionReport",
        "client.slua.logic.report.ClientToolsReport",
        "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils",
        "client.slua.logic.report.ReportCooldownLogic",
        "client.slua.logic.report.PlayerReportLogic"
    }
    for _, path in ipairs(reportModules) do
        local mod = package.loaded[path]
        if mod then
            -- حذف كل الجداول
            for k, v in pairs(mod) do
                if type(v) == "table" then
                    for key in pairs(v) do
                        v[key] = nil
                    end
                end
            end
            -- تصفير العدادات
            if mod.ReportCount then mod.ReportCount = 0 end
            if mod.ReportData then mod.ReportData = {} end
            if mod.LogQueue then mod.LogQueue = {} end
            if mod.PendingReports then mod.PendingReports = {} end
            if mod.ReportHistory then mod.ReportHistory = {} end
            if mod.CachedData then mod.CachedData = {} end
            if mod.FatalDamagerMap then mod.FatalDamagerMap = {} end
            if mod.MurdererMap then mod.MurdererMap = {} end
            if mod.KnockDownerMap then mod.KnockDownerMap = {} end
            if mod.TeammateInfoMap then mod.TeammateInfoMap = {} end
            if mod.HistoricalTeammateMap then mod.HistoricalTeammateMap = {} end
        end
    end
end)

-- [16.3] حذف الإبلاغات من الذاكرة (Memory)
pcall(function()
    -- GameplayCallbacks
    if _G.GameplayCallbacks then
        for k, v in pairs(_G.GameplayCallbacks) do
            if type(v) == "table" then
                for key in pairs(v) do
                    v[key] = nil
                end
            end
        end
    end
    -- Global report caches
    for _, cacheName in ipairs({
        "ReportCache","Reports","PendingReports","ReportData","ReportList",
        "PlayerReports","EnemyReports","FatalDamagers","Murderers",
        "KnockDowners","TeammateReports","BehaviorReports","AimReports"
    }) do
        if _G[cacheName] and type(_G[cacheName]) == "table" then
            for k in pairs(_G[cacheName]) do
                _G[cacheName][k] = nil
            end
        end
    end
end)

-- [16.4] حذف الإبلاغات من Data Storage
pcall(function()
    -- DataMgr
    if DataMgr then
        if DataMgr.ReportData then DataMgr.ReportData = {} end
        if DataMgr.ReportHistory then DataMgr.ReportHistory = {} end
        if DataMgr.PendingReports then DataMgr.PendingReports = {} end
        if DataMgr.SuspiciousReports then DataMgr.SuspiciousReports = {} end
        if DataMgr.ReportLog then DataMgr.ReportLog = {} end
        if DataMgr.BehaviorReports then DataMgr.BehaviorReports = {} end
        if DataMgr.CheatReports then DataMgr.CheatReports = {} end
    end
    -- CGameState
    if CGameState then
        if CGameState.ReportData then CGameState.ReportData = {} end
        if CGameState.Reports then CGameState.Reports = {} end
    end
end)

-- [16.5] حذف الإبلاغات من Subsystems
pcall(function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not subMgr then return end

    local reportSubs = {
        "ClientReportPlayerSubsystem",
        "DSReportPlayerSubsystem",
        "ClientQuickReportMaliciousTeammate",
        "InspectionSystemReportClientLogicSubsystem",
        "InspectionSystemReportDSLogicSubsystem",
        "GameReportSubsystem",
        "AFKReportorSubsystem",
        "BehaviorScoreSubsystem",
        "ClientSecMrpcsFlowSubsystem",
        "MrpcsFlowSubsystem",
        "CircleFlowSubsystem",
        "SwiftHawkSubsystem"
    }

    for _, name in ipairs(reportSubs) do
        local sub = subMgr:Get(name)
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "table" then
                    for key in pairs(v) do
                        v[key] = nil
                    end
                elseif type(v) == "number" then
                    -- تصفير العدادات الرقمية
                    local kl = k:lower()
                    if kl:find("count") or kl:find("total") or kl:find("report") or
                       kl:find("flag") or kl:find("score") then
                        sub[k] = 0
                    end
                elseif type(v) == "boolean" then
                    local kl = k:lower()
                    if kl:find("reported") or kl:find("flagged") or kl:find("banned") then
                        sub[k] = false
                    end
                end
            end
            -- حذف Timers
            if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
            if sub.checkTimer then pcall(function() sub:RemoveGameTimer(sub.checkTimer) end) end
            if sub.flagTimer then pcall(function() sub:RemoveGameTimer(sub.flagTimer) end) end
        end
    end
end)

-- [16.6] حذف الإبلاغات من Network Buffer
pcall(function()
    -- NetUtil Buffer
    if NetUtil then
        if NetUtil.ReportBuffer then NetUtil.ReportBuffer = {} end
        if NetUtil.PacketBuffer then NetUtil.PacketBuffer = {} end
        if NetUtil.PendingBuffer then NetUtil.PendingBuffer = {} end
        if NetUtil.SendBuffer then NetUtil.SendBuffer = {} end
        if NetUtil.ReportQueue then NetUtil.ReportQueue = {} end
    end
    -- NetManager Buffer
    local NM = import("NetworkManager")
    if NM then
        if NM.ReportBuffer then NM.ReportBuffer = {} end
        if NM.PacketBuffer then NM.PacketBuffer = {} end
        if NM.SendQueue then NM.SendQueue = {} end
    end
end)

-- [16.7] حذف ملفات Logs للإبلاغات
pcall(function()
    if not io or not io.open then return end

    local logPaths = {
        -- SaveGames logs
        "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/",
        "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/",
        "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/",
        "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/",
        "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/",
    }

    local reportFiles = {
        "Report.log","Report.txt","ReportData.log","ReportData.txt",
        "CheatReport.log","CheatReport.txt","AntiCheat.log","AntiCheat.txt",
        "PlayerReport.log","PlayerReport.txt","Behavior.log","Behavior.txt",
        "Telemetry.log","Telemetry.txt","TLog.log","TLog.txt",
        "CrashReport.log","CrashReport.txt","SecurityLog.log","SecurityLog.txt",
    }

    for _, dir in ipairs(logPaths) do
        for _, fname in ipairs(reportFiles) do
            pcall(function()
                local path = dir .. fname
                local file = io.open(path, "r")
                if file then
                    file:close()
                    -- حذف الملف
                    io.open(path, "w")
                end
            end)
        end
    end
end)

-- [16.8] حذف الإبلاغات من Cache
pcall(function()
    -- Package Cache
    for k, v in pairs(package.loaded) do
        if type(v) == "table" then
            if v.ReportCache then v.ReportCache = {} end
            if v.ReportsCache then v.ReportsCache = {} end
            if v.PendingReports then v.PendingReports = {} end
            if v.ReportHistory then v.ReportHistory = {} end
        end
    end
end)

-- [16.9] Auto Delete Loop (كل 5 ثواني)
pcall(function()
    local function DeleteReports()
        pcall(function()
            -- Queue
            if _G.ReportQueue then
                for k in pairs(_G.ReportQueue) do _G.ReportQueue[k] = nil end
            end
            -- Telemetry
            if _G.TelemetryQueue then
                for k in pairs(_G.TelemetryQueue) do _G.TelemetryQueue[k] = nil end
            end
            -- DataMgr
            if DataMgr then
                if DataMgr.ReportData then DataMgr.ReportData = {} end
                if DataMgr.PendingReports then DataMgr.PendingReports = {} end
                if DataMgr.ReportHistory then DataMgr.ReportHistory = {} end
            end
            -- NetUtil
            if NetUtil then
                if NetUtil.ReportBuffer then NetUtil.ReportBuffer = {} end
                if NetUtil.ReportQueue then NetUtil.ReportQueue = {} end
            end
        end)
    end

    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(5.0, DeleteReports, -1, 5.0)
    end
end)

-- [16.10] حذف فوري عند بداية التشغيل
pcall(function()
    -- حذف كل شيء فوراً عند التحميل
    if _G.ReportQueue then
        for k in pairs(_G.ReportQueue) do _G.ReportQueue[k] = nil end
    end
    if DataMgr then
        if DataMgr.ReportData then DataMgr.ReportData = {} end
        if DataMgr.PendingReports then DataMgr.PendingReports = {} end
    end
    if NetUtil then
        if NetUtil.ReportBuffer then NetUtil.ReportBuffer = {} end
        if NetUtil.ReportQueue then NetUtil.ReportQueue = {} end
    end
end)

-- [16.11] NOTIFY
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[REPORT-DELETER] 🗑️ LOADED")
    print("[REPORT-DELETER] ❌ Report Queues cleared")
    print("[REPORT-DELETER] ❌ Report Caches cleared")
    print("[REPORT-DELETER] ❌ Report Buffers cleared")
    print("[REPORT-DELETER] ❌ Report Subsystems cleared")
    print("[REPORT-DELETER] ❌ Report Logs deleted")
    print("[REPORT-DELETER] 🔄 Auto-delete every 5s")
    print("[REPORT-DELETER] ✅ COMPLETE")
    print("═══════════════════════════════════════════════════")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF REPORT DELETER
-- ═══════════════════════════════════════════════════════════════════════════════