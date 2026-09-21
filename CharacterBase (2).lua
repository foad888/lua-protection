
--[[
    MAHDI_BYPASS.lua
    ULTIMATE Anti-Cheat Bypass
    Version: 5.0
    Author: MAHDI
    Deobfuscated & Renamed
]]

--=============================================================================
-- Imports
--=============================================================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

--=============================================================================
-- Bypass Metadata
--=============================================================================
local MAHDI_BYPASS = {
    Name = "MAHDI_BYPASS",
    Version = "5.0",
    Author = "MAHDI ",
    Initialized = false,
    Protected = false,
    BypassLevel = "ULTIMATE",
    BypassLayers = {},
    BlockedSystems = {},
    Permissions = {
        SecurityBypass = true, AntiCheatBypass = true, ReportBypass = true,
        BanBypass = true, TelemetryBypass = true, NetworkBypass = true,
        MD5Bypass = true, SignatureBypass = true, DNSBypass = true,
        DeviceBypass = true, HawkEyeBypass = true, HiggsBosonBypass = true,
        CoronaLabBypass = true, GokubaBypass = true, SwiftHawkBypass = true,
        RacingBypass = true, ShootVerifyBypass = true, FileCheckBypass = true,
        MemoryScanBypass = true, ReplayBypass = true, ScreenshotBypass = true,
        LoggingBypass = true, CrashReportBypass = true, AnalyticsBypass = true,
        TLogBypass = true, PacketBypass = true, ConsoleBypass = true,
        SluaBypass = true, JNIBypass = true,
    },
}
_G.MAHDI_BYPASS = MAHDI_BYPASS

--=============================================================================
-- Anti-Cheat Block Flags
--=============================================================================
_G.AntiCheatBlock = {
    BlockTSS = true, BlockGokuba = true, BlockSwiftHawk = true,
    BlockCoronaLab = true, BlockHawkEye = true, BlockHiggsBoson = true,
    BlockClientBan = true, BlockRealTimeBan = true, BlockReportSystem = true,
    BlockTLog = true, BlockMD5Check = true, BlockSignatureVerify = true,
    BlockDeviceFingerprint = true, BlockDNSMonitor = true, BlockTelemetry = true,
    BlockAnalytics = true, BlockCrashReport = true, BlockMemoryScan = true,
    BlockSpeedCheck = true, BlockWallCheck = true, BlockShootVerify = true,
    BlockModifierException = true, BlockSimulateLocation = true,
    BlockPlayerSecurity = true, BlockCircleFlow = true, BlockMrpcsFlow = true,
    BlockKillFlow = true, BlockBehaviorScore = true, BlockAFKReport = true,
    BlockAvatarException = true, BlockFileCheck = true, BlockPakVerify = true,
    BlockIntegrityCheck = true, BlockRacingAntiCheat = true, BlockClientEntry = true,
    BlockNetworkException = true, BlockUnrealNet = true, BlockReplay = true,
    BlockScreenshot = true, BlockDebugLog = true, BlockJNI = true,
    BlockXignCode = true, BlockBattlEye = true, BlockAce = true,
    BlockTDataMaster = true, BlockCrashSight = true, BlockScreenshots = true,
}

--=============================================================================
-- Blocked IPs
--=============================================================================
_G.BlockedIPs = {
    "43.128.0.0/16", "43.129.0.0/16", "43.130.0.0/16", "43.131.0.0/16",
    "43.132.0.0/16", "43.133.0.0/16", "43.134.0.0/16", "43.135.0.0/16",
    "129.204.0.0/16", "129.205.0.0/16", "129.206.0.0/16", "129.207.0.0/16",
    "129.208.0.0/16", "129.209.0.0/16", "129.210.0.0/16", "129.211.0.0/16",
    "129.212.0.0/16", "129.213.0.0/16", "129.214.0.0/16", "129.215.0.0/16",
    "129.216.0.0/16", "129.217.0.0/16", "129.218.0.0/16", "129.219.0.0/16",
    "129.220.0.0/16", "129.221.0.0/16", "129.222.0.0/16", "129.223.0.0/16",
    "129.224.0.0/16", "129.225.0.0/16", "129.226.0.0/16", "129.227.0.0/16",
    "129.228.0.0/16", "129.229.0.0/16", "129.230.0.0/16", "129.231.0.0/16",
    "129.232.0.0/16", "129.233.0.0/16", "129.234.0.0/16", "129.235.0.0/16",
    "129.236.0.0/16", "129.237.0.0/16", "129.238.0.0/16", "129.239.0.0/16",
    "129.240.0.0/16", "129.241.0.0/16", "129.242.0.0/16", "129.243.0.0/16",
    "129.244.0.0/16", "129.245.0.0/16", "129.246.0.0/16", "129.247.0.0/16",
    "129.248.0.0/16", "129.249.0.0/16", "129.250.0.0/16", "129.251.0.0/16",
    "129.252.0.0/16", "129.253.0.0/16", "129.254.0.0/16", "129.255.0.0/16",
    "185.244.0.0/16", "185.245.0.0/16", "185.246.0.0/16", "185.247.0.0/16",
    "185.248.0.0/16", "185.249.0.0/16", "185.250.0.0/16", "185.251.0.0/16",
    "185.252.0.0/16", "185.253.0.0/16", "185.254.0.0/16", "185.255.0.0/16",
    "203.0.0.0/8", "204.0.0.0/8", "205.0.0.0/8", "206.0.0.0/8",
    "207.0.0.0/8", "208.0.0.0/8", "209.0.0.0/8", "210.0.0.0/8",
    "211.0.0.0/8", "212.0.0.0/8", "213.0.0.0/8", "214.0.0.0/8",
    "215.0.0.0/8", "216.0.0.0/8", "217.0.0.0/8", "218.0.0.0/8",
    "219.0.0.0/8", "220.0.0.0/8", "221.0.0.0/8", "222.0.0.0/8",
    "223.0.0.0/8",
}

--=============================================================================
-- Blocked Domains
--=============================================================================
_G.BlockedDomains = {
    "anticheat.qq.com", "tss.tencent.com", "tss-sdk.qq.com",
    "report.qq.com", "ban.qq.com", "security.qq.com", "hawkeye.qq.com",
    "pubgm.qq.com", "pubgmobile.qq.com", "igame.qq.com",
    "tencent.com", "qq.com", "tlog.qq.com", "ds.qq.com",
    "lobby.qq.com", "match.qq.com", "login.qq.com", "account.qq.com",
    "device.qq.com", "fingerprint.qq.com", "telemetry.qq.com",
    "analytics.qq.com", "crash.qq.com", "bugly.qq.com", "tdm.qq.com",
    "gokuba.qq.com", "swifthawk.qq.com", "coronalab.qq.com",
    "higgsboson.qq.com", "battleye.com", "xigncode.com", "ace.qq.com",
    "tss-sdk.com", "antihack.com", "securitycheck.com",
    "validation.com", "verification.com", "monitor.com", "tracking.com",
    "igamecj.com", "pubgm.com", "gpubgm.com", "gjacky.com",
    "facebook.com", "googleusercontent.com", "hwclouds-dns.com",
    "gcloudcs.com", "googleapis.com", "vasdgame.com", "amsoveasea.com",
    "mbgame.anticheatexpert.com", "tdatamaster.com", "helpshift.com",
    "perfsight.wetest.net", "proximabeta.com", "onezapp.com",
    "adjust.com", "crashsight.wetest.net",
}

--=============================================================================
-- Helper functions
--=============================================================================
local function noOp() end
local function returnTrue() return true end
local function returnFalse() return false end
local function returnEmptyTable() return {} end
local function returnEmptyString() return "" end

-- ✅ [FIX] مرادفات الأسماء المستخدمة في الكود
local retTrue = returnTrue
local retFalse = returnFalse

local function safeCall(fn, ...)
    if not fn then return nil, nil end
    local ok, result = pcall(fn, ...)
    return ok, result
end

local function isValidObject(obj)
    if not obj then return false end
    if slua and slua.isValid then
        return slua.isValid(obj)
    end
    return true
end

local function getPlayerController()
    local pc
    if slua_GameFrontendHUD then
        pc = slua_GameFrontendHUD.GetPlayerController(slua_GameFrontendHUD)
    end
    if not isValidObject(pc) then
        local gd = package.loaded["GameLua.GameCore.Data.GameplayData"]
        if gd and gd.GetPlayerController then
            pc = gd.GetPlayerController()
        end
    end
    return pc
end

--=============================================================================
-- [1] Block UI Popups
--=============================================================================
local function BlockUIPopups()
    pcall(function()
        local uiList = slua.getUIList() or {}
        local BLOCKED_KEYWORDS = {
            "Legal", "Common_Legal", "Notice", "Ban", "Error", "Popup",
            "Message", "Dialog", "Warning", "Alert", "Notification",
            "Toast", "Snackbar", "Banner", "Confirm", "Prompt",
            "Input", "Select", "Progress", "Loading", "Success",
            "Failure", "Info", "Fatal", "Panic", "Kick",
            "Suspend", "Freeze", "Block",
        }

        for _, widget in pairs(uiList) do
            if isValidObject(widget) then
                local name = widget.GetName and widget:GetName() or ""
                for _, keyword in ipairs(BLOCKED_KEYWORDS) do
                    if name:find(keyword) then
                        widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                        pcall(function() widget:RemoveFromParent() end)
                        break
                    end
                end
            end
        end
    end)

    pcall(function()
        local BLOCKED_WIDGETS = {
            "Common_Legal_01_UIBP", "BanNotice_UIBP", "BanPopup_UIBP",
            "KickPopup_UIBP", "WarningPopup_UIBP", "AlertPopup_UIBP",
            "SecurityAlert_UIBP", "AntiCheatPopup_UIBP", "ReportPopup_UIBP",
        }
        for _, name in ipairs(BLOCKED_WIDGETS) do
            local w = slua.getUIByName(name)
            if isValidObject(w) then
                w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                pcall(function() w:RemoveFromParent() end)
            end
        end
    end)

    pcall(function()
        local pc = getPlayerController()
        if not isValidObject(pc) then return end

        local KismetSystemLibrary = import("KismetSystemLibrary")
        if not KismetSystemLibrary then return end

        local COMMANDS = {
            "DisableAllScreenMessages",
            "UI.DisableMessageOfTheDay",
            "ShowMOTD 0",
            "r.UI.DisableAll 1",
            "UI.HideAllWidgets 1",
            "ShowBanNotice 0",
            "ShowSuspension 0",
            "ShowFrozenNotice 0",
            "ShowRiskNotice 0",
            "DisableBanUI 1",
            "HideBanMessages 1",
            "IgnoreSecurityChecks 1",
            "UIToggle 0",
            "HideUI 1",
            "DisablePopup 1",
            "SuppressDialogs 1",
        }
        for _, cmd in ipairs(COMMANDS) do
            KismetSystemLibrary.ExecuteConsoleCommand(pc, cmd)
        end
    end)
end

--=============================================================================
-- [2] Block Network Traffic
--=============================================================================
local function BlockNetworkTraffic()
    pcall(function()
        local function isBlocked(target)
            if type(target) ~= "string" then return false end
            local lower = target:lower()
            for _, ip in ipairs(_G.BlockedIPs) do
                if lower:find(ip) then return true end
            end
            for _, domain in ipairs(_G.BlockedDomains) do
                if lower:find(domain) then return true end
            end
            return false
        end

        if socket and socket.connect then
            local origConnect = socket.connect
            socket.connect = function(host, ...)
                if isBlocked(host) then
                    return nil, "Blocked by MAHDI_BYPASS"
                end
                return origConnect(host, ...)
            end
        end

        if socket and socket.tcp then
            local origTcp = socket.tcp
            socket.tcp = function(...)
                local tcp = origTcp(...)
                if tcp and tcp.connect then
                    local origTCPConnect = tcp.connect
                    tcp.connect = function(self, host, port, ...)
                        if isBlocked(host) then
                            return nil, "Blocked by MAHDI_BYPASS"
                        end
                        return origTCPConnect(self, host, port, ...)
                    end
                end
                return tcp
            end
        end

        if NetUtil and NetUtil.ConnectToServer then
            local origConnect = NetUtil.ConnectToServer
            NetUtil.ConnectToServer = function(host, ...)
                if isBlocked(host) then
                    return false, "Blocked by MAHDI_BYPASS"
                end
                return origConnect(host, ...)
            end
        end

        if NetUtil and NetUtil.SendPacket then
            local BLOCKED_PACKETS = {}
            for _, name in ipairs({
                "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow",
                "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
                "ReportPlayerBehavior", "ReportTeammatHurt",
                "ReportTeammateKillConfirmFlow", "ReportForbiddenPickupFlow",
                "ReportPlayerMoveRoute", "ReportPlayerPosition",
                "ReportSecVehicleMoveFlow", "ReportSecTgameMovingFlow",
                "report_parachute_data", "on_tss_sdk_anti_data",
                "report_unrealnet_exception", "ReportPlayerEquipmentInfo",
                "ReportAimFlow", "ReportHitFlow", "log_shooting_miss",
                "report_heavy_weapon_box_activation_flow",
                "report_heavy_weapon_box_item_flow",
                "ReportCircleFlow", "report_ds_player_circle_flow",
                "ReportJumpFlow", "ReportGameStartFlow", "ReportGameEndFlow",
                "report_players_ping", "report_player_ip",
                "report_player_frame_ping_record", "report_net_saturate",
                "report_ds_netsaturate", "report_ds_net_continuous_saturate",
                "report_ds_netrate", "report_unrealnet_clientstats",
                "report_serverstat_avgtickdelta", "report_all_players_address",
                "report_ai_strategyinfo", "ReportAIActionFlow",
                "ReportGenerateMonsterFlow", "report_ds_match_room_data",
                "SendSpectatingLog", "ReportIDCardProduceFlow",
                "ReportIDCardPickUpFlow", "ReportIDCardDestroyFlow",
                "ReportRevivalFlow", "ReportGameSetting", "ReportGameSettingNew",
                "ReportAntsVoiceTeamCreate", "ReportAntsVoiceTeamQuit",
                "report_common_info", "report_common_battle_info",
                "report_client_scan_result", "tss_sdk_report",
                "report_memory_exception", "report_avatar_exception",
                "report_ui_state", "report_hit_reg_fail",
                "report_character_state", "report_vehicle_exception",
                "report_camera_exception", "ReportPlayerControllerStateChanged",
                "ReportAvatarFlow", "ReportSecurityAlert", "ReportAntiCheat",
                "ReportSuspiciousActivity", "ReportViolation", "ReportBan",
                "ReportKick", "ReportCheat", "ReportHack", "ReportMod",
                "ReportInject", "ReportHook", "ReportPatch", "ReportTamper",
                "ReportCorrupt", "ReportInvalid", "ReportSpoof", "ReportFake",
                "ReportClone", "ReportDuplicate", "ReportConflict",
                "ReportOverlap", "ReportMismatch", "ReportInconsistent",
                "ReportUnexpected", "ReportUnknown",
                "SyncBanInfo", "SyncBanID", "VoiceBanNotify", "AccountBan",
                "BanStatus", "BanReason", "BanExpiry", "SuspensionInfo",
                "RiskFlag", "HighRiskNotice", "InspectionNotice",
                "FrozenNotice", "DeviceError", "NetworkError", "ClientError",
                "ValidationFailed", "SecurityViolation", "RiskDetected",
                "AbnormalBehavior", "CheatDetected", "AntiCheatAlert",
                "HawkEyeReport", "SwiftHawkData", "CoronaLabData",
                "GokubaData", "TLogReport", "TelemetryData", "AnalyticsData",
                "CrashReport",
            }) do
                BLOCKED_PACKETS[name] = true
            end

            local origSend = NetUtil.SendPacket
            NetUtil.SendPacket = function(name, ...)
                if BLOCKED_PACKETS[name] then return end
                return origSend(name, ...)
            end
            NetUtil.IsBypassed = true
        end

        if _G.Http then
            if _G.Http.Get then
                local origGet = _G.Http.Get
                _G.Http.Get = function(url, ...)
                    if isBlocked(url) then
                        return nil, "Blocked by MAHDI_BYPASS"
                    end
                    return origGet(url, ...)
                end
            end
            if _G.Http.Post then
                local origPost = _G.Http.Post
                _G.Http.Post = function(url, ...)
                    if isBlocked(url) then
                        return nil, "Blocked by MAHDI_BYPASS"
                    end
                    return origPost(url, ...)
                end
            end
        end

        if _G.WebSocket and _G.WebSocket.Connect then
            local origWsConnect = _G.WebSocket.Connect
            _G.WebSocket.Connect = function(url, ...)
                if isBlocked(url) then
                    return nil, "Blocked by MAHDI_BYPASS"
                end
                return origWsConnect(url, ...)
            end
        end
    end)
end

--=============================================================================
-- [3] Bypass HiggsBoson
--=============================================================================
local function BypassHiggsBoson()
    pcall(function()
        local HiggsBoson = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if HiggsBoson then
            HiggsBoson.bIsEnable = false
            HiggsBoson.bMHActive = false
            HiggsBoson.bCallPreReplication = false
            HiggsBoson.bSkipAlertServer = true
            HiggsBoson.StaticShowSecurityAlertInDev = noOp
            HiggsBoson.CheckClientConfig = returnFalse
            HiggsBoson.GetSecurityInfo = returnEmptyTable
            HiggsBoson.ReportSecurityAlert = noOp
            HiggsBoson.ValidateClient = returnTrue
            HiggsBoson.CheckIntegrity = returnTrue
            HiggsBoson.BlackList = {}
            HiggsBoson._ProcessReportChatRobotQueue = noOp
            HiggsBoson.LuaNotifySecurityAbnormalJump = noOp
            HiggsBoson.SendAntiDataFlow = noOp
            HiggsBoson.SendHitFireBtnFlow = noOp
            HiggsBoson.OnBattleResult = noOp
            HiggsBoson.SendHisarData = noOp
            HiggsBoson.RPC_Client_ShowSecurityAlertWindow = noOp
            HiggsBoson.RPC_Server_TellServerName = noOp
            HiggsBoson.RecordStrategyTimestampInReplay = noOp
            HiggsBoson.SkipAlertServer = noOp
            HiggsBoson.SetClientAlertWindowEnabled = noOp
            HiggsBoson.IsCharacterOwnerWerewolf = returnFalse
            HiggsBoson.IsCharacterOwnerButcher = returnFalse
            HiggsBoson._ReportChatRobot = noOp
            HiggsBoson._ClientShowSecurityAlertWindow = noOp
            HiggsBoson.ShowABCD = noOp
            HiggsBoson.ReceiveBeginPlay = noOp
        end

        local pc = getPlayerController()
        if isValidObject(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                pc.HiggsBoson.bIsEnable = false
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
                pc.HiggsBosonComponent.bIsEnable = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
    end)
end

--=============================================================================
-- [4] Bypass TssSdk
--=============================================================================
local function BypassTssSdk()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded.TssSdk
        if not TssSdk then return end

        local NOOP_LIST = {
            "OnRecvData", "SendReportInfo", "ReportException", "ReportData",
            "UploadLog", "SendAntiData", "ReportGameStart", "ReportGameEnd",
            "ReportCrash", "ReportViolation", "ReportSuspicious", "ReportBan",
            "ReportKick", "ReportWarning", "ReportInfo", "ReportDebug",
            "ReportError", "ReportFatal", "ReportMemory", "ReportProcess",
            "ReportModule", "ReportThread", "ReportFile", "ReportNetwork",
            "ReportDevice", "ReportSystem", "ReportGame", "ReportUser",
            "ReportAccount", "ReportSession", "ReportPerformance", "ReportBattery",
            "ReportTemperature", "ReportFPS", "ReportPing", "ReportPacket",
            "ReportCheat", "ReportHack", "ReportMod", "ReportInject",
            "ReportDebugger", "ReportEmulator", "ReportRoot", "ReportJailbreak",
            "ReportVM", "ReportHook", "ReportPatch", "ReportTamper",
            "ReportCorrupt", "ReportInvalid", "ReportSpoof", "ReportFake",
            "ReportClone", "ReportDuplicate", "ReportConflict", "ReportOverlap",
            "ReportMismatch", "ReportInconsistent", "ReportUnexpected",
            "ReportUnknown",
        }
        for _, name in ipairs(NOOP_LIST) do
            TssSdk[name] = noOp
        end
        TssSdk.ScanMemory = returnTrue
        TssSdk.IsEmulator = returnFalse
        TssSdk.GetTssSdkReportInfo = returnEmptyString
        TssSdk.CheckIntegrity = returnTrue
        TssSdk.VerifySignature = returnTrue
        TssSdk.CollectEvidence = returnEmptyTable
    end)
end

--=============================================================================
-- [5] Bypass ACE
--=============================================================================
local function BypassACE()
    pcall(function()
        local ace = _G.ace or package.loaded["libace.so"]
        if not ace then return end

        for _, name in ipairs({
            "ReportData", "ReportViolation", "KickPlayer", "BanPlayer",
            "SendReport", "ReportCheat", "ReportHack", "ReportMod",
            "ReportInject", "ReportHook", "ReportPatch", "ReportTamper",
            "ReportCorrupt", "ReportInvalid", "ReportSpoof", "ReportFake",
        }) do
            ace[name] = noOp
        end
        ace.CheckIntegrity = returnTrue
        ace.VerifyProcess = returnTrue
        ace.CheckModule = returnTrue
        ace.ValidateClient = returnTrue
        ace.ScanMemory = returnFalse
        ace.CheckDebugger = returnFalse
        ace.CheckEmulator = returnFalse
        ace.CheckRoot = returnFalse
        ace.CollectInfo = returnEmptyTable
    end)
end

--=============================================================================
-- [6] Bypass XignCode
--=============================================================================
local function BypassXignCode()
    pcall(function()
        local XignCode = _G.XignCode or package.loaded.xigncode
        if not XignCode then return end

        for _, name in ipairs({
            "SendReport", "ReportException", "KickPlayer", "BanPlayer",
            "ReportCheat", "ReportHack", "ReportMod", "ReportInject",
            "ReportHook", "ReportPatch", "ReportTamper",
        }) do
            XignCode[name] = noOp
        end
        XignCode.CheckProcess = returnTrue
        XignCode.VerifyIntegrity = returnTrue
        XignCode.ScanModules = returnEmptyTable
        XignCode.ValidateMemory = returnTrue
        XignCode.CheckDebugger = returnFalse
        XignCode.EncryptData = function(d) return d end
        XignCode.DecryptData = function(d) return d end
    end)
end

--=============================================================================
-- [7] Bypass BattlEye
--=============================================================================
local function BypassBattlEye()
    pcall(function()
        local BE = _G.BattlEye or package.loaded.BattlEye
        if not BE then return end

        for _, name in ipairs({
            "SendReport", "KickPlayer", "BanPlayer", "ReportViolation",
            "ReportCheat", "ReportHack", "ReportMod", "ReportInject", "ReportHook",
        }) do
            BE[name] = noOp
        end
        BE.ValidatePlayer = returnTrue
        BE.CheckMemory = returnTrue
        BE.VerifyIntegrity = returnTrue
        BE.ScanProcess = returnTrue
        BE.CollectEvidence = returnEmptyTable
    end)
end

--=============================================================================
-- [8] Bypass HawkEye Patrol
--=============================================================================
local function BypassHawkEye()
    pcall(function()
        local HE = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
        if HE then
            for _, name in ipairs({
                "_OnHawkSync", "_OnHawkReportSuccess", "_OnRecvInspectorBroadcastCount",
                "ReportCheat", "RequestImprison", "SendReportTLog",
                "_CollectBeWatchedPlayerInfo", "_OnPlayerKilledOtherPlayer",
                "_StartFrameUIRefreshTimer", "ExitWatching", "WantMatchNextPatrol",
                "InitHawkEyePatrolSubsystem", "_StartHideUITimer",
                "_StartShowDistanceUITimer", "_StartCloseBattleEndedTipsTimer",
                "_StartBattleTimeUsageTimer", "_StartQuitVoiceRoomTimer",
                "_StartExitGameTimer", "_CloseExitGameTimer",
                "_CreateOvertimerTimerForNextPatrol", "ClearNextPatrolOvertimeTimer",
                "ReturnLobbyAndOpenH5", "ForceNeverCloseBattleEndedTips",
                "TryShowReportedTips", "ShowWatchEndedTips", "OnShowWatchEndedTips",
                "OnClickLowerLeftExitWatching", "OnClickBottomRightOpenReportWindow",
                "_MarkHasReported", "OnRelease",
            }) do
                HE[name] = noOp
            end
            HE.IsDuringHawkEyePatrol = returnFalse
            HE.HasReported = returnTrue
            HE.GetBeWatchedPlayerInfo = returnEmptyTable
            HE.CheckShowReportedTips = returnFalse
            HE.HasShownWatchEndedTips = returnTrue
            HE.GetForbidNextPatrolRemainingTimeInSeconds = function() return 0 end
            HE.GetUsedDailyTimeInSeconds = function() return 0 end
            HE.GetInspectorBroadcastCount = function() return -1 end
            HE.GetMaxInspectorBroadcastCount = function() return 0 end
            HE.CanInspectorBroadcast = returnFalse
            HE.IsCharacterLocationShouldDraw = returnFalse
            HE._PostConstruct = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
                self.nInspectorBroadcastCount = -1
            end
            HE._bHasInitialized = true
            HE._bHasReported = true
            HE._bHasShownWatchEndedTips = true
            HE.bShowBeReportedTips = true
            HE.nInspectorBroadcastCount = -1
        end

        local DS = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSHawkEyePatrolSubsystem"]
        if DS then
            DS.OnInit = noOp
            DS.ReportCheat = noOp
            DS.RequestImprison = noOp
        end
    end)
end

--=============================================================================
-- [9] Bypass Gokuba
--=============================================================================
local function BypassGokuba()
    pcall(function()
        local Gokuba = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
        if Gokuba then
            Gokuba.ForwardFeature = returnEmptyTable
            Gokuba.InitGokubaLogic = noOp
            if Gokuba.TimerHandle then
                local Timer = require("common.time_ticker")
                Timer.RemoveTimer(Gokuba.TimerHandle)
                Gokuba.TimerHandle = nil
            end
            for name, fn in pairs(Gokuba) do
                if type(fn) == "function" then
                    if name:find("Init") or name:find("Start") or name:find("Check")
                       or name:find("Scan") or name:find("Report") or name:find("Forward")
                       or name:find("Feature") or name:find("Detect") or name:find("Collect")
                       or name:find("Send") or name:find("Upload") or name:find("Verify")
                       or name:find("Analyze") or name:find("Process") or name:find("Handle") then
                        Gokuba[name] = noOp
                    end
                end
            end
        end
        if _G.GokubaLogic then
            _G.GokubaLogic.ForwardFeature = returnEmptyTable
            _G.GokubaLogic.InitGokubaLogic = noOp
        end
    end)
end

--=============================================================================
-- [10] Bypass SwiftHawk
--=============================================================================
local function BypassSwiftHawk()
    pcall(function()
        for _, name in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do
            if _G[name] then _G[name] = noOp end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[name] then
                _G.GameplayCallbacks[name] = noOp
            end
        end
        local SH = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if SH then
            SH.ReportData = noOp
            SH.SendReport = noOp
            SH.CollectTelemetry = noOp
        end
    end)
end

--=============================================================================
-- [11] Bypass CoronaLab
--=============================================================================
local function BypassCoronaLab()
    pcall(function()
        _G.LocalMain = noOp

        local pc = slua_GameFrontendHUD.GetPlayerController(slua_GameFrontendHUD)
        if isValidObject(pc) and pc.AddGameTimer then
            local origAddTimer = pc.AddGameTimer
            pc.AddGameTimer = function(self, interval, loop, fn, ...)
                if interval == 30 and loop == true then
                    return nil
                end
                return origAddTimer(self, interval, loop, fn, ...)
            end
        end

        local HiggsC = package.loaded.CHiggsBosonComponent
        if HiggsC then
            HiggsC.SecurityCoronaLabClientDataPointer = function() return nil end
            HiggsC.SetFloatValueByName = function() return nil end
        end

        if _G.CoronaLab then
            _G.CoronaLab.ReportData = noOp
            _G.CoronaLab.SendData = noOp
            _G.CoronaLab.CollectData = noOp
            _G.CoronaLab.Telemetry = noOp
        end

        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local CL = SubsystemMgr.Get(SubsystemMgr, "CoronaLabSubsystem")
            if CL then
                CL.ReportData = noOp
                CL.SendToServer = noOp
                CL.CollectTelemetry = noOp
                CL.StopCollection = noOp
            end
        end
    end)
end

--=============================================================================
-- [12] Bypass Ban Systems
--=============================================================================
local function BypassBanSystems()
    pcall(function()
        local CBL = package.loaded["client.slua.logic.ban.ClientBanLogic"]
        if CBL then
            CBL.ReqBanInfo = noOp
            CBL.OnVoiceSwitchNotify = noOp
            CBL.OnVoiceBanNotify = noOp
            CBL.OnRealTimeVoiceBanNotify = noOp
            CBL.OnVoiceBanSuccess = noOp
