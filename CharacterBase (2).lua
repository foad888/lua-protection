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
-- Blocked IPs (Tencent Cloud ranges + more)
--=============================================================================
_G.BlockedIPs = {
    "43.128.0.0/16", "43.129.0.0/16", "43.130.0.0/16", "43.131.0.0/16",
    "43.132.0.0/16", "43.133.0.0/16", "43.134.0.0/16", "43.135.0.0/16",
    -- (بقية 43.x.y.0/16 — من 43.136 إلى 43.255)
    -- مختصر هنا للإيجاز، الأصلي يحتوي 128 مدخل
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
-- [1] Block UI Popups (Ban/Warning/etc.)
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
-- [2] Block Network Traffic (socket / NetUtil / Http / WebSocket)
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

        -- socket.connect
        if socket and socket.connect then
            local origConnect = socket.connect
            socket.connect = function(host, ...)
                if isBlocked(host) then
                    return nil, "Blocked by MAHDI_BYPASS"
                end
                return origConnect(host, ...)
            end
        end

        -- socket.tcp
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

        -- NetUtil.ConnectToServer
        if NetUtil and NetUtil.ConnectToServer then
            local origConnect = NetUtil.ConnectToServer
            NetUtil.ConnectToServer = function(host, ...)
                if isBlocked(host) then
                    return false, "Blocked by MAHDI_BYPASS"
                end
                return origConnect(host, ...)
            end
        end

        -- NetUtil.SendPacket — block reports
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

        -- Http.Get / Http.Post
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

        -- WebSocket.Connect
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
-- [5] Bypass ACE (Tencent Anti-Cheat Expert)
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
            -- Neuter all detection functions
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
-- [11] Bypass CoronaLab + Patches HiggsBoson C++
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
-- [12] Bypass Ban Systems (ClientBanLogic + RealTimeBan + TT Ban)
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
            CBL.TryOpenVoice = function()
                EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
            end
            CBL.IsVoiceReportEnable = returnFalse
            CBL.OnSyncMicSuspicious = noOp
            CBL.OnSyncMicPreFilter = noOp
            CBL.OnSyncBanInfo = noOp
            CBL.OnNotifyWarningTips = noOp
            CBL.VoiceBanEndTime = 0
            CBL.bEnableVoiceReport = false
            CBL.SuspiciousFlag = 0
            CBL.Reason = ""
            CBL.IsTranslated = false
        end

        local RTB = package.loaded.RealTimeBan
        if RTB then
            RTB.Init = noOp
            RTB.OnPlayerWithRealTimeBan = noOp
            RTB.OnSyncPlayerInfo = noOp
            RTB.HandleEnterGameModeFightingState = noOp
            RTB.ShowAlias = noOp
            RTB.SetOnRankInspectorUID = noOp
            RTB.IsUIDOnRankInspector = returnFalse
            RTB.GetUIDInspectorRank = function() return -1 end
            RTB.SetInspectorBroadcastCountUID = noOp
            RTB.GetUIDInspectorBroadcastCount = function() return -1 end
            RTB.GetTipsIDOffset = function() return 0 end
            RTB.GetTipsIDOffsetWithUID = function() return 0 end
            RTB.GetTipsIDOffsetInspector = function() return 0 end
            RTB.GMShowAlias = noOp
            RTB.tOnRankInspectorUIDSet = {}
            RTB.tInspectorRankUIDSet = {}
            RTB.tInspectorBroadcastCountUIDSet = {}
            RTB.MaxAliasLevel = -1
            RTB.CurrentAlias = nil
            RTB.CurrentName = nil
            RTB.is_onrank_inspector = false
            RTB.inspector_rank = -1
            RTB.bHasOldAlias = false
            RTB.ShowTipsAliasConfig = {}
            RTB.DelayTime = {}
            RTB.OldShowTipsAlias = 0
        end

        local BS = package.loaded.BanSystem
        if BS then
            BS.CheckBan = returnFalse
            BS.IsBanned = returnFalse
            BS.GetBanReason = returnEmptyString
            BS.GetBanTime = function() return 0 end
        end

        local TTBan = package.loaded["client.slua.logic.login.logic_tt_ban"]
        if TTBan then
            TTBan.GetCarrierInfo = function() return '[{"mcc":"000"}]' end
            TTBan.CheckIfCanCreateRole = returnTrue
            TTBan.CheckBan = returnFalse
            TTBan.GetBanStatus = returnFalse
        end
    end)
end

--=============================================================================
-- [13] Bypass Report Systems
--=============================================================================
local function BypassReportSystems()
    pcall(function()
        local REPORT_MODULES = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "client.slua.logic.report.EquipmentExceptionReport",
            "client.slua.logic.report.ClientToolsReport",
            "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils",
            "client.slua.logic.download.report.puffer_tlog",
            "GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem",
            "GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils",
            "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature",
            "client.slua.logic.ban.ClientBanLogic",
            "client.slua.logic.login.logic_tt_ban",
            "GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem",
            "GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem",
            "GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem",
            "GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem",
            "GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem",
            "GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem",
            "GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem",
        }

        local REPORT_FUNCTIONS = {
            "Report", "SendReport", "ReportEvent", "ReportException",
            "ReportData", "ReportTLogEvent", "OnInit",
            "_OnPlayerKilledOtherPlayer", "_RecordFatalDamager", "_OnBattleResult",
            "_OnShowQuickReportMutualExclusiveUI", "_AddEnemyMapToBattleResult",
            "_AddKnockDownerToBattleResult", "_AddKillerToBattleResult",
            "_AddTeammateMurderToBattleResult", "_AddFatalDamagerMapToBattleResult",
            "_AddMLKillerUIDToBattleResult", "_SaveHistoricalTeammateInfo",
            "_RecordTeammateMurderer", "_OnNearDeathOrRescued", "_OnCharacterDied",
            "_OnTeammateDamage", "_OnPlayerSettlementStart", "_OnHawkSync",
            "_OnHawkReportSuccess", "_StartExitGameTimer", "OnHandleBehaviorScore",
            "AIPerceptionScore", "ReportAllPlayerInfo", "AddRecordMLAIInfo",
            "ReportAI", "RealLogoutTimer", "SendAFKTips", "OnHandleLostConnection",
            "ClientRPC_SyncBanID", "ClientRPC_StrongTips", "ClientRPC_NormalTips",
            "Notify", "OnSyncBanInfo", "OnVoiceBanNotify", "DelayKickOutPlayer",
            "ActiveKickNotify", "_UpdateTTKRecords", "_UpdateOperatingFrequency",
            "_OnReportServerJumpFlow", "HandleKillTlog", "AskForInspector",
            "ReportEnemy", "KickOutOneTeam", "AddReportedCount",
            "RequestGotoSpectatingImp", "RequestGotoSpectating",
        }

        for _, path in ipairs(REPORT_MODULES) do
            local mod = package.loaded[path]
            if mod then
                for _, fnName in ipairs(REPORT_FUNCTIONS) do
                    if mod[fnName] then
                        mod[fnName] = noOp
                    end
                end
                if mod.LogQueue then mod.LogQueue = {} end
                if mod.GetSimpleFightData then mod.GetSimpleFightData = returnEmptyTable end
            end
        end
    end)
end

--=============================================================================
-- [14] Bypass TLog + Crash Reports
--=============================================================================
local function BypassTLog()
    pcall(function()
        local TLOG_MODULES = {
            "client.slua.config.tlog.tlog_report_utils",
            "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "client.slua.logic.replay.logic_report_replay",
            "client.slua.logic.crash.CrashReporter",
        }

        for _, path in ipairs(TLOG_MODULES) do
            local mod = package.loaded[path]
            if mod then
                for _, fnName in ipairs({
                    "ReportTLogEvent", "SendTlog", "ReportTLog",
                    "_UpdateTTKRecords", "_UpdateOperatingFrequency",
                    "_OnReportServerJumpFlow", "HandleKillTlog",
                    "ReportReplay", "SendReportReq", "SendReport",
                    "SaveDump", "UploadDump",
                }) do
                    if mod[fnName] then mod[fnName] = noOp end
                end
                if mod.GetSimpleFightData then mod.GetSimpleFightData = returnEmptyTable end
            end
        end

        if _G.TLog then
            _G.TLog.Info = noOp
            _G.TLog.Warning = noOp
            _G.TLog.Error = noOp
            _G.TLog.Debug = noOp
            _G.TLog.Report = noOp
            _G.TLog.Send = noOp
            _G.TLog.Flush = noOp
        end

        if tlog_report_utils then
            tlog_report_utils.ReportTLogEvent = noOp
            tlog_report_utils.IsCanReportLobbyEvent = returnFalse
            tlog_report_utils.IsBusinessReport = returnFalse
            tlog_report_utils.SetMarketStayUpdateEnable = noOp
            tlog_report_utils.GetMarketStayUpdateEnable = returnFalse
            tlog_report_utils.SetBusinessReportEnable = noOp
            tlog_report_utils.SendTLogReportImmediate = noOp
            tlog_report_utils.SetTlogBeginType = noOp
            tlog_report_utils.SetTlogEndType = noOp
            _G.SendTLogReportImmediate = noOp
            _extraTlogReportEnableCfg = {}
            _isCanReportMarketStay = false
            _BusinessReportEnable = false
            _isInitConfig = true
            start_timestamp_map = {}
        end
    end)
end

--=============================================================================
-- [15] Bypass CrashSight / CrashReports
--=============================================================================
local function BypassCrashSight()
    pcall(function()
        local CS = _G.CrashSight or package.loaded.CrashSight
        if CS then
            for _, name in ipairs({
                "ReportException", "SetCustomData", "Log", "UploadLog",
                "SendReport", "ReportCrash", "ReportError", "ReportFatal",
                "ReportWarning", "ReportInfo", "ReportDebug", "ReportMemory",
                "ReportPerformance",
            }) do
                CS[name] = noOp
            end
            CS.CollectInfo = returnEmptyTable
        end

        local CR = package.loaded["client.slua.logic.crash.CrashReporter"]
        if CR then
            CR.SendReport = noOp
            CR.SaveDump = noOp
            CR.UploadDump = noOp
        end
    end)
end

--=============================================================================
-- [16] Bypass Screenshot
--=============================================================================
local function BypassScreenshot()
    pcall(function()
        local SM = import("ScreenshotMaker")
        if SM then
            SM.MakePicture = returnEmptyString
            SM.ReMakePicture = returnEmptyString
            SM.HasCaptured = returnTrue
            SM.TakeScreenshot = noOp
            SM.SaveScreenshot = noOp
            SM.CaptureScreen = noOp
            SM.RecordScreen = noOp
        end

        local SD = package.loaded.ScreenshotDetect or _G.ScreenshotDetect
        if SD then
            SD.OnScreenshotTaken = noOp
            SD.ReportScreenshot = noOp
        end
    end)
end

--=============================================================================
-- [17] Bypass Memory Scanner
--=============================================================================
local function BypassMemoryScanner()
    pcall(function()
        local MS = _G.MemoryScanner or package.loaded.MemoryScanner
        if MS then
            MS.StartScan = noOp
            MS.StopScan = noOp
            MS.GetResults = returnEmptyTable
            MS.ReportViolation = noOp
            MS.CheckIntegrity = returnTrue
            MS.VerifyMemory = returnTrue
            MS.ScanProcess = noOp
            MS.ScanModule = noOp
            MS.ScanThread = noOp
            MS.ScanFile = noOp
            MS.ScanNetwork = noOp
        end

        if _G.Memory then
            _G.Memory.Scan = noOp
            _G.Memory.FindPattern = noOp
            _G.Memory.Read = function() return 0 end
            _G.Memory.Write = noOp
            _G.Memory.IntegrityCheck = returnTrue
            _G.Memory.VerifyModule = returnTrue
            _G.Memory.CheckCRC = returnTrue
            _G.Memory.ScanModifications = returnFalse
        end
    end)
end

--=============================================================================
-- [18] Bypass File Check + CRC/MD5/SHA
--=============================================================================
local function BypassFileCheck()
    pcall(function()
        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]
        if SubsystemMgr then
            local FC = SubsystemMgr.Get(SubsystemMgr, "FileCheckSubsystem")
            if FC then
                FC.StartCheck = noOp
                FC.ReportAbnormalFile = noOp
                FC.VerifyFile = returnTrue
                FC.CheckIntegrity = returnTrue
                FC.ValidateFile = returnTrue
                FC.CheckFile = returnTrue
                FC.VerifyHash = returnTrue
                FC.ValidateHash = returnTrue
                FC.CheckHash = returnTrue
            end
        end

        local CRC = _G.CRCChecker or package.loaded.CRCChecker
        if CRC then
            CRC.VerifyFile = returnTrue
            CRC.VerifyMemory = returnTrue
            CRC.GenerateCRC = function() return "00000000" end
            CRC.CheckIntegrity = returnTrue
            CRC.ValidateFile = returnTrue
            CRC.ValidateMemory = returnTrue
            CRC.CheckFile = returnTrue
            CRC.CheckMemory = returnTrue
            CRC.VerifyCRC = returnTrue
            CRC.ValidateCRC = returnTrue
            CRC.CheckCRC = returnTrue
            CRC.GenerateCRC32 = function() return "00000000" end
            CRC.GenerateCRC64 = function() return "0000000000000000" end
            CRC.GenerateMD5 = function() return "00000000000000000000000000000000" end
            CRC.GenerateSHA1 = function() return "0000000000000000000000000000000000000000" end
            CRC.GenerateSHA256 = function() return string.rep("0", 64) end
            CRC.GenerateSHA512 = function() return string.rep("0", 128) end
        end
    end)
end

--=============================================================================
-- [19] Bypass Avatar Validation
--=============================================================================
local function BypassAvatarValidation()
    pcall(function()
        local AU = package.loaded.AvatarUtils
        if AU then
            AU.CheckIsWeaponInBlackList = returnFalse
            AU.IsValidAvatar = returnTrue
            AU.ValidateAvatar = returnTrue
            AU.CheckAvatar = returnTrue
            AU.VerifySkin = returnTrue
            AU.ValidateSkin = returnTrue
            AU.CheckSkin = returnTrue
            AU.VerifyWeapon = returnTrue
            AU.ValidateWeapon = returnTrue
            AU.CheckWeapon = returnTrue
            AU.VerifyVehicle = returnTrue
            AU.ValidateVehicle = returnTrue
            AU.CheckVehicle = returnTrue
        end

        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]
        if SubsystemMgr then
            local AV = SubsystemMgr.Get(SubsystemMgr, "AvatarExceptionSubsystem")
            if AV then
                AV.ReportException = noOp
                AV.BindPlayerCharacter = noOp
                AV.CheckAvatarValid = returnTrue
                AV.ValidateAvatar = returnTrue
                AV.ReportAvatarException = noOp
                AV.ReportInvalidAvatar = noOp
                AV.ReportCorruptAvatar = noOp
            end
        end
    end)
end

--=============================================================================
-- [20] Bypass Shoot Verify
--=============================================================================
local function BypassShootVerify()
    pcall(function()
        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]
        if SubsystemMgr then
            local SV = SubsystemMgr.Get(SubsystemMgr, "ShootVerifySubSystemClient")
            if SV then
                SV.ReportVerifyFail = noOp
                SV.OnVerifyFailed = noOp
                SV.CheckShoot = returnTrue
                SV.ValidateHit = returnTrue
                SV.VerifyShoot = returnTrue
                SV.ValidateShoot = returnTrue
                SV.CheckHit = returnTrue
                SV.VerifyHit = returnTrue
            end
        end
    end)
end

--=============================================================================
-- [21] Bypass AFK Report
--=============================================================================
local function BypassAFKReport()
    pcall(function()
        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]
        if SubsystemMgr then
            local AFK = SubsystemMgr.Get(SubsystemMgr, "AFKReportorSubsystem")
            if AFK then
                AFK.PlayerHaveAction = noOp
                AFK.ReportAFK = noOp
                AFK.CheckAFK = returnFalse
                AFK.ReportAFKData = noOp
                AFK.ReportIdle = noOp
                AFK.ReportInactive = noOp
            end
        end
    end)
end

--=============================================================================
-- [22] Bypass GameplayCallbacks
--=============================================================================
local function BypassGameplayCallbacks()
    pcall(function()
        if not _G.GameplayCallbacks then
            _G.GameplayCallbacks = {}
        end
        local GC = _G.GameplayCallbacks
        if GC.IsBypassed then return end

        for _, name in ipairs({
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow",
            "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
            "ReportPlayerBehavior", "ReportTeammatHurt",
            "ReportMisKillByTeammate", "ReportForbitPick",
            "ReportPlayerMoveRoute", "ReportPlayerPosition",
            "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow",
            "ReportParachuteData", "SendTssSdkAntiDataToLobby",
            "SendDSErrorLogToLobby", "SendDSErrorLogToLobbyOnece",
            "SendDSHawkEyePatrolLogToLobby", "ReportEquipmentFlow",
            "ReportAimFlow", "ReportHitFlow",
            "ReportHeavyWeaponBoxSpawnFlow", "ReportHeavyWeaponBoxActivationFlow",
            "ReportHeavyWeaponBoxOpenPlayerFlow", "ReportHeavyWeaponBoxItemFlow",
            "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
            "OnDSConnectionSaturated", "ReportDSNetSaturation",
            "ReportNetContinuousSaturate", "ReportDSNetRate",
            "SendClientStats", "SendServerAvgTickDelta",
            "ReportCircleFlow", "ReportDSCircleFlow", "ReportJumpFlow",
            "ReportAIStrategyInfo", "SendAIDeliveryInfo",
            "ReportDailyTaskInfo", "ReportMatchRoomData", "SendPlayerSpectatingLog",
            "ReportIDCardProduceFlow", "ReportIDCardPickUpFlow",
            "ReportIDCardDestroyFlow", "ReportRevivalFlow",
            "ReportGameSetting", "ReportGameSettingNew",
            "ReportAntsVoiceTeamCreate", "ReportAntsVoiceTeamQuit",
            "ReportCommonInfo", "ReportLightweightStat",
            "SendSecTLog", "SendDataMiningTLog", "SendActivityTLog",
            "ReportWallHack", "ReportNoGrass", "ReportAimbot",
            "ReportSpeedHack", "ReportMagicBullet",
            "OnPlayerNetConnectionClosed", "OnPlayerActorChannelError",
            "OnPlayerRPCValidateFailed", "OnPlayerSpectateException",
            "OnShutdownAfterError",
        }) do
            GC[name] = noOp
        end

        GC.GetWeaponReport = returnEmptyTable
        GC.GetOneWeaponReport = returnEmptyTable
        GC.GetGeneralTLogData = returnEmptyTable

        GC.OnDSPlayerStateChanged = function(uid, state)
            if state then
                local s = string.lower(tostring(state))
                for _, keyword in ipairs({"cheat", "ban", "kick", "violation", "suspicious", "abnormal", "invalid"}) do
                    if s:find(keyword) then return end
                end
            end
        end

        GC.IsBypassed = true
    end)
end

--=============================================================================
-- [23] Spoof Device Info
--=============================================================================
local function SpoofDeviceInfo()
    pcall(function()
        local SI = import("SystemInfo")
        if SI then
            SI.GetDeviceModel = function() return "iPhone14,5" end
            SI.GetDeviceBrand = function() return "Apple" end
            SI.GetAndroidVersion = function() return "13" end
            SI.GetEMUIVersion = function() return "" end
            SI.IsEmulator = returnFalse
            SI.IsRooted = returnFalse
            SI.IsDebugged = returnFalse
            SI.GetKernelVersion = function() return "Linux version 4.14.116" end
            SI.CheckKernelIntegrity = returnTrue
            SI.GetDeviceID = function() return "00000000-0000-0000-0000-000000000000" end
            SI.GetDeviceName = function() return "iPhone" end
            SI.GetDeviceType = function() return "Phone" end
            SI.GetManufacturer = function() return "Apple" end
            SI.GetModel = function() return "iPhone14,5" end
            SI.GetOSVersion = function() return "13" end
            SI.GetOSName = function() return "iOS" end
            SI.GetScreenResolution = function() return "1170x2532" end
            SI.GetScreenDensity = function() return "460" end
            SI.GetRAMSize = function() return "6144" end
            SI.GetStorageSize = function() return "256" end
            SI.GetBatteryLevel = function() return "100" end
            SI.GetBatteryStatus = function() return "Charging" end
            SI.GetNetworkType = function() return "WiFi" end
            SI.GetNetworkSpeed = function() return "100" end
            SI.GetGPSStatus = function() return "Enabled" end
            SI.GetGPSLocation = function() return "0.0,0.0" end
            SI.GetCountryCode = function() return "US" end
            SI.GetLanguageCode = function() return "en" end
            SI.GetTimeZone = function() return "UTC" end
            SI.GetCurrentTime = function() return os.time() end
            SI.GetUptime = function() return 3600 end
            SI.GetCPUUsage = function() return 10 end
            SI.GetMemoryUsage = function() return 20 end
            SI.GetTemperature = function() return 25 end
            SI.GetBatteryTemperature = function() return 25 end
            SI.GetCPUFrequency = function() return 2400 end
            SI.GetGPUFrequency = function() return 1200 end
            SI.GetScreenBrightness = function() return 100 end
            SI.GetVolumeLevel = function() return 100 end
        end

        local DI = import("DeviceID")
        if DI then
            DI.GetDeviceID = function() return "BYPASSED_DEVICE" end
            DI.GetAndroidID = function() return "BYPASSED_ANDROID_ID" end
            DI.GetIMEI = function() return "BYPASSED_IMEI" end
            DI.GetMACAddress = function() return "BYPASSED_MAC" end
            DI.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
            DI.GetDeviceName = function() return "BYPASSED_DEVICE_NAME" end
            DI.GetDeviceModel = function() return "BYPASSED_MODEL" end
            DI.GetDeviceBrand = function() return "BYPASSED_BRAND" end
            DI.GetDeviceManufacturer = function() return "BYPASSED_MANUFACTURER" end
            DI.GetDeviceBoard = function() return "BYPASSED_BOARD" end
            DI.GetDeviceBootloader = function() return "BYPASSED_BOOTLOADER" end
            DI.GetDeviceHardware = function() return "BYPASSED_HARDWARE" end
            DI.GetDeviceHost = function() return "BYPASSED_HOST" end
            DI.GetDeviceFingerprint = function() return "BYPASSED_FINGERPRINT" end
            DI.GetDeviceSerial = function() return "BYPASSED_SERIAL" end
        end

        local KSL = import("KismetSystemLibrary")
        if KSL then
            KSL.GetDeviceId = function()
                local n = math.random(100000, 999999)
                return "FAKE_DEVICE_" .. n
            end
            KSL.GetMacAddress = function() return "00:11:22:33:44:55" end
            KSL.GetSerialNumber = function()
                local n = math.random(1000000, 9999999)
                return "SN" .. n
            end
        end
    end)
end

--=============================================================================
-- [24] Bypass DNS
--=============================================================================
local function BypassDNS()
    pcall(function()
        local DNS = import("DNS")
        if DNS then
            DNS.Resolve = function() return "127.0.0.1" end
            DNS.GetHostName = function() return "BYPASSED_HOST" end
            DNS.GetIPAddress = function() return "0.0.0.0" end
        end

        local Net = import("Network")
        if Net then
            Net.GetIPAddress = function() return "0.0.0.0" end
            Net.GetMACAddress = function() return "BYPASSED_MAC" end
            Net.GetSSID = function() return "BYPASSED_SSID" end
            Net.GetBSSID = function() return "BYPASSED_BSSID" end
        end
    end)
end

--=============================================================================
-- [25] Bypass JNI Anti-Cheat
--=============================================================================
local function BypassJNI()
    pcall(function()
        if _G.JNI and _G.JNI.AntiCheat then
            local JNI = _G.JNI.AntiCheat
            JNI.CheckRoot = returnFalse
            JNI.CheckEmulator = returnFalse
            JNI.CheckDebugger = returnFalse
            JNI.CollectInfo = returnEmptyTable
            JNI.SendReport = noOp
            JNI.Validate = returnTrue
            JNI.CheckRootAccess = returnFalse
            JNI.CheckEmulatorAccess = returnFalse
            JNI.CheckDebuggerAccess = returnFalse
            JNI.CheckMemoryAccess = returnTrue
            JNI.CheckProcessAccess = returnTrue
            JNI.CheckFileAccess = returnTrue
            JNI.CheckNetworkAccess = returnTrue
            JNI.CheckSystemAccess = returnTrue
            JNI.CheckDeviceAccess = returnTrue
            JNI.CheckAPIAccess = returnTrue
            JNI.CheckSDKAccess = returnTrue
            JNI.CheckLibraryAccess = returnTrue
            JNI.CheckFrameworkAccess = returnTrue
            JNI.CheckPackageAccess = returnTrue
        end
    end)
end

--=============================================================================
-- [26] Disable All Logging
--=============================================================================
local function DisableLogging()
    pcall(function()
        _G.print = noOp
        _G.printf = noOp
        _G.log = noOp
        _G.warn = noOp
        _G.error = noOp
        _G.debug = noOp
        _G.trace = noOp
        _G.info = noOp
        _G.verbose = noOp
        _G.fatal = noOp
        _G.panic = noOp
        _G.recover = noOp
        _G.assert = noOp

        local Logging = import("Logging")
        if Logging then
            Logging.Log = noOp
            Logging.LogWarning = noOp
            Logging.LogError = noOp
            Logging.LogVerbose = noOp
            Logging.SetLogLevel = noOp
            Logging.LogInfo = noOp
            Logging.LogDebug = noOp
            Logging.LogTrace = noOp
            Logging.LogFatal = noOp
            Logging.LogPanic = noOp
        end

        for _, name in ipairs({
            "log", "log_warning", "log_error", "log_shipping_client",
            "log_format", "log_tree",
        }) do
            if _G[name] then _G[name] = noOp end
        end

        if LogUtil then
            LogUtil.SetForceLog = noOp
            LogUtil.SetLogTreeEnable = noOp
            LogUtil.SetWriteLog = noOp
        end

        if sandbox then
            sandbox.LogError = noOp
            sandbox.LogWarning = noOp
        end
    end)
end

--=============================================================================
-- [27] Bypass TDataMaster + Telemetry
--=============================================================================
local function BypassTDataMaster()
    pcall(function()
        local TDM = _G.TDataMaster or package.loaded["libTDataMaster.so"]
        if TDM then
            for _, name in ipairs({
                "ReportEvent", "ReportException", "FlushData", "SendReport",
                "ReportTelemetry", "ReportAnalytics", "ReportMetrics",
                "ReportStatistics", "ReportPerformance", "ReportBattery",
                "ReportTemperature", "ReportFPS", "ReportPing", "ReportNetwork",
            }) do
                TDM[name] = noOp
            end
            TDM.CollectData = returnEmptyTable
        end

        _G.TelemetryQueue = {}
        _G.bTelemetryEnabled = false

        if _G.Replay then
            _G.Replay.Record = noOp
            _G.Replay.StopRecord = noOp
            _G.Replay.Save = noOp
            _G.Replay.Upload = noOp
            _G.Replay.Report = noOp
        end

        if _G.Telemetry then
            _G.Telemetry.Send = noOp
            _G.Telemetry.Report = noOp
            _G.Telemetry.Track = noOp
            _G.Telemetry.Log = noOp
        end

        if _G.Analytics then
            _G.Analytics.Send = noOp
            _G.Analytics.Report = noOp
            _G.Analytics.Track = noOp
        end

        for _, framework in ipairs({"Firebase", "Adjust", "AppsFlyer"}) do
            if _G[framework] then
                _G[framework].logEvent = noOp
                _G[framework].trackEvent = noOp
                _G[framework].setEnabled = returnFalse
                _G[framework].sendEvent = noOp
                if _G[framework].report then _G[framework].report = noOp end
            end
        end
    end)
end

--=============================================================================
-- [28] Bypass Racing Anti-Cheat
--=============================================================================
local function BypassRacing()
    pcall(function()
        if RacingAntiCheatLogic then
            RacingAntiCheatLogic.HandleRacingEnter = noOp
            RacingAntiCheatLogic.HandleRacingStart = noOp
            RacingAntiCheatLogic.HandleRacingEnd = noOp
            RacingAntiCheatLogic.StartDetectTimer = noOp
            RacingAntiCheatLogic.StopDetectTimer = noOp
            RacingAntiCheatLogic.DetectVehicleFloating = noOp
            RacingAntiCheatLogic.HandleFloatingCheat = noOp
            RacingAntiCheatLogic.SetIgnoreFloating = noOp
            RacingAntiCheatLogic.HandlePlayerPassCheckBelt = noOp
            RacingAntiCheatLogic.HandleSpeedCheat = noOp
            RacingAntiCheatLogic._CreateVehicleData = returnEmptyTable
            RacingAntiCheatLogic.vehicleDataMap = {}
            RacingAntiCheatLogic.detectTimer = nil
            RacingAntiCheatLogic.config = {
                FloatingDistLimit = 99999,
                FloatingTimeLimit = 99999,
                CheckPassIntervalLimit = 99999,
            }
        end
    end)
end

--=============================================================================
-- [29] Bypass Slua Signature Verification
--=============================================================================
local function BypassSluaVerify()
    pcall(function()
        if slua and slua.getSignature then
            slua.getSignature = function() return 3735928559 end
        end

        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = returnTrue
            loader.checkIntegrity = returnTrue
            if loader.disableSignatureCheck then
                loader.disableSignatureCheck = returnTrue
            end
        end

        local serialize = package.loaded["slua.serialize"]
        if serialize then
            serialize.check = returnTrue
            serialize.verify = returnTrue
        end

        if _G.slua_verify then _G.slua_verify = returnTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = returnTrue end
        if _G.slua_loader then
            _G.slua_loader.verifyBytecode = returnTrue
            _G.slua_loader.checkIntegrity = returnTrue
        end
    end)
end

--=============================================================================
-- [30] Patch Client / NetManager / EventSystem
--=============================================================================
local function PatchClient()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus = noOp
            Client.GEMReportEnterLobbyEvent = noOp
            Client.TPerforPlatDisconnectReport = noOp
            Client.IsConnected = function() return true end
            Client.GetUnrealNetworkStatus = returnEmptyString
            Client.MD5LuaString = function() return "BYPASSED_MD5" end
            Client.GetDSVersion = function() return "999.999.999" end
            Client.IsInReplayState = returnFalse
        end

        if NetManager then
            NetManager.ProcRespondMsg = noOp
            NetManager.isLogMsgAfterLogin = false
            NetManager.logMsgMap = {}
        end

        if EventSystem then
            local origPost = EventSystem.postEvent
            EventSystem.postEvent = function(self, eventType, ...)
                if eventType then
                    local typeStr = type(eventType)
                    if typeStr == "string" then
                        local BLOCKED = {
                            "SECURITY", "CHEAT", "BAN", "REPORT", "FLAG", "VIOLATION",
                            "DETECT", "VERIFY", "ANTI", "AC_", "SUSPICIOUS", "ABNORMAL",
                            "MONITOR", "TRACK", "TELEMETRY", "ANALYTICS", "CRASH",
                            "DUMP", "HAWKEYE", "HIGGS", "CORONA", "GOKUBA", "SWIFT",
                            "KICK", "FROZEN", "SUSPENSION", "RISK", "WARNING",
                        }
                        for _, kw in ipairs(BLOCKED) do
                            if eventType:find(kw) then return end
                        end
                    end
                end
                if origPost then
                    return origPost(self, eventType, ...)
                end
            end
        end
    end)
end

--=============================================================================
-- [31] Bypass Login Module
--=============================================================================
local function BypassLoginModule()
    pcall(function()
        if login_module then
            login_module["ban-login"] = noOp
            login_module["idip-kick-out"] = noOp
            login_module.aq_ban = noOp
            login_module["device-in-blacklist"] = noOp
            login_module.device_num_limit = noOp
            login_module["register-forbidden"] = noOp
            login_module["low-version"] = noOp
            login_module["not-in-white-list"] = noOp
            login_module.Login_Failed = noOp
            login_module.aas_ban = noOp
            login_module.PakMonitorStart = noOp
            login_module.SetupFilenameHideKeywords = noOp
            login_module.on_login_failed = noOp
            login_module.DelaybanLoginCancelCallback = noOp
            login_module.CheckBan = returnFalse
            login_module.IsBanned = returnFalse
        end
    end)
end

--=============================================================================
-- [32] Kill All Security Subsystems
--=============================================================================
local function KillSecuritySubsystems()
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not SubsystemMgr then return end

        local TARGET_SUBSYSTEMS = {
            "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
            "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem",
            "ClientDataStatistcsSubsystem", "AFKReportorSubsystem",
            "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem",
            "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem",
            "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem",
            "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem",
            "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem",
            "PakVerifySubsystem", "DNSMonitorSubsystem", "DeviceFingerprintSubsystem",
            "ReplayMonitorSubsystem", "TelemetrySubsystem", "GokubaSubsystem",
            "RacingAntiCheatSubsystem", "ClientBanSubsystem", "RealTimeBanSubsystem",
            "TLogSubsystem", "ReportSubsystem", "SecurityMonitorSubsystem",
            "CheatDetectionSubsystem", "ViolationMonitorSubsystem",
            "SuspiciousActivitySubsystem", "AbnormalBehaviorSubsystem",
            "NetworkMonitorSubsystem", "AnalyticsSubsystem", "CrashReportSubsystem",
            "PerformanceMonitorSubsystem", "InspectionSystemReportClientLogicSubsystem",
            "SpectateAndReplaySubsystem", "AITrackingLogSubsystem", "TDMAFKReportorSubsystem",
        }

        local KILL_KEYWORDS = {
            "Report", "Send", "Upload", "Verify", "Check", "Validate", "Scan",
            "Detect", "Collect", "Flow", "Heartbeat", "Monitor", "Track", "Record",
            "Log", "Alert", "Notify", "Ban", "Kick", "Suspend", "Flag", "Anti",
            "AC", "Analyze", "Process", "Handle", "Evaluate",
        }

        for _, subName in ipairs(TARGET_SUBSYSTEMS) do
            local sub = SubsystemMgr.Get(SubsystemMgr, subName)
            if sub then
                for name, fn in pairs(sub) do
                    if type(fn) == "function" then
                        for _, kw in ipairs(KILL_KEYWORDS) do
                            if name:find(kw) then
                                pcall(function() sub[name] = noOp end)
                                break
                            end
                        end
                    end
                end

                -- Kill known timer handles
                for _, timerField in ipairs({"timer", "heartbeatTimer", "reportTimer", "checkTimer", "monitorTimer", "scanTimer"}) do
                    if sub[timerField] then
                        pcall(function() sub:RemoveGameTimer(sub[timerField]) end)
                    end
                end
            end
        end
    end)
end

--=============================================================================
-- [33] Apply Console Commands
--=============================================================================
local function ApplyConsoleCommands()
    pcall(function()
        local pc = getPlayerController()
        if not isValidObject(pc) then return end

        local KSL = import("KismetSystemLibrary")
        if not KSL then return end

        local COMMANDS = {
            "pak.DisablePakSignatureCheck 1",
            "pakchunk.EnableSignatureCheck 0",
            "s.VerifyPak 0",
            "sig.Check 0",
            "security.DisableChecks 1",
            "CheatManager.EnableCheat 1",
            "Net.BlockAllAntiCheat 1",
            "AntiCheat.DisableAll 1",
            "t.MaxFPS 165",
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
            "DisableHawkEye 1",
            "DisableCoronaLab 1",
            "DisableTSS 1",
            "DisableGokuba 1",
            "DisableSwiftHawk 1",
            "DisableReport 1",
            "DisableTLog 1",
            "DisableTelemetry 1",
            "DisableAnalytics 1",
            "DisableCrashReport 1",
        }
        for _, cmd in ipairs(COMMANDS) do
            KSL.ExecuteConsoleCommand(pc, cmd)
        end

        -- Force engine flags
        KSL.IsDevelopment = returnFalse
        KSL.IsShipping = returnTrue
        KSL.IsDebug = returnFalse
        KSL.IsEditor = returnFalse
        KSL.IsGame = returnTrue
        KSL.IsClient = returnTrue
        KSL.IsServer = returnFalse
        KSL.IsStandalone = returnFalse
    end)
end

--=============================================================================
-- [34] Bypass MD5 / Hash Verification
--=============================================================================
local function BypassMD5()
    pcall(function()
        local CMB = import("CreativeModeBlueprintLibrary")
        if CMB then
            CMB.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CMB.GetContentDiffData = function() return true, "BYPASSED" end
            CMB.VerifyContent = returnTrue
            CMB.ValidateContent = returnTrue
            CMB.CheckContent = returnTrue
        end

        if _G.MD5Hash then
            _G.MD5Hash = function() return "00000000000000000000000000000000" end
        end
        if _G.CRC32 then
            _G.CRC32 = function() return 0 end
        end
        if _G.SHA1 then
            _G.SHA1 = function() return "BYPASS" end
        end

        if _G.FileHashChecker then
            _G.FileHashChecker.CheckFileMD5 = returnTrue
            _G.FileHashChecker.VerifyAll = returnTrue
            _G.FileHashChecker.GetHash = function() return "BYPASS" end
        end

        if _G.STExtraBlueprintFunctionLibrary then
            _G.STExtraBlueprintFunctionLibrary.CheckMD5 = returnTrue
            _G.STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            _G.STExtraBlueprintFunctionLibrary.VerifyFile = returnTrue
        end
    end)
end

--=============================================================================
-- [35] Global Metatable Protection (auto-block new globals with bad names)
--=============================================================================
local function InstallGlobalProtection()
    pcall(function()
        local BLOCKED_GLOBALS = {
            "bIsCheating", "bDetected", "bBanned", "SuspicionScore", "CheatDetected",
            "AntiCheatFlag", "IsHacking", "bReported", "TrustScore", "SecurityFlag",
            "ViolationLevel", "BanStatus", "bIsBan", "bIsKick", "bIsReported",
            "CheatCount", "ViolationCount", "SecurityScore", "TrustLevel",
            "bIsCheater", "bIsHacker", "bIsModder", "bIsInjector", "bIsHooker",
            "bIsPatcher", "bIsTamperer", "bIsCorrupter", "bIsInvalid", "bIsSpoofer",
            "bIsFaker", "bIsCloner", "bIsDuplicator", "bIsConflicter",
            "bIsOverlapper", "bIsMismatcher", "bIsInconsistent", "bIsUnexpected",
            "bIsUnknown", "bIsSuspicious", "bIsAbnormal", "bIsCorrupt",
            "bIsTampered", "bIsModified", "bIsInjected", "bIsHooked", "bIsPatched",
            "bIsSpoofed", "bIsFaked", "bIsCloned", "bIsDuplicated",
            "bIsMismatched", "bIsConflicted", "bIsOverlapped",
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY",
            "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT",
            "ENABLE_PERFORMANCE_REPORT", "ENABLE_MONITOR", "ENABLE_TRACK",
            "ENABLE_DETECT", "ENABLE_VERIFY", "ENABLE_CHECK", "ENABLE_SCAN",
            "ENABLE_AC", "ENABLE_BEACON", "ENABLE_SDK", "ENABLE_TSS",
            "ENABLE_SWIFT_HAWK", "ENABLE_GOKUBA", "ENABLE_HIGGS",
            "ENABLE_CORONA", "ENABLE_HAWKEYE", "ENABLE_BAN", "ENABLE_VALIDATE",
            "ENABLE_AUTHENTICATE", "ENABLE_SIGNATURE",
        }

        for _, name in ipairs(BLOCKED_GLOBALS) do
            _G[name] = nil
        end

        local mt = getmetatable(_G) or {}
        local origNewIndex = mt.__newindex

        mt.__newindex = function(t, k, v)
            local keyStr = tostring(k)
            for _, blocked in ipairs(BLOCKED_GLOBALS) do
                if keyStr:find(blocked, 1, true) then
                    return
                end
            end
            if origNewIndex then
                origNewIndex(t, k, v)
            else
                rawset(t, k, v)
            end
        end

        setmetatable(_G, mt)
    end)
end

--=============================================================================
-- [36] Bypass Memory Protection
--=============================================================================
local function BypassMemoryProtection()
    pcall(function()
        local MP = import("MemoryProtect")
        if MP then
            MP.VirtualProtect = function() return true end
            MP.IsMemoryReadable = function() return false end
            MP.IsMemoryWritable = function() return false end
            MP.CheckMemory = returnTrue
            MP.ProtectMemory = returnTrue
            MP.UnprotectMemory = returnTrue
            MP.ValidateMemory = returnTrue
            MP.VerifyMemory = returnTrue
            MP.ProtectRegion = function() return true end
            MP.UnprotectRegion = function() return true end
            MP.IsMemoryProtected = function() return true end
        end

        if _G.MemoryScanner then
            _G.MemoryScanner.StartScan = noOp
            _G.MemoryScanner.StopScan = noOp
            _G.MemoryScanner.GetResults = returnEmptyTable
        end
    end)
end

--=============================================================================
-- [37] Spoof Engine Timing
--=============================================================================
local function SpoofEngineTiming()
    pcall(function()
        local Engine = import("Engine")
        if Engine then
            Engine.GetAverageFPS = function() return 60 end
            Engine.GetFrameTime = function() return 0.016 end
            Engine.IsLagging = returnFalse
            Engine.GetDeltaTime = function() return 0.033 end
            Engine.GetTime = function() return os.time() end
            Engine.GetTimestamp = function() return os.time() end
            Engine.GetTick = function() return os.clock() end
            Engine.GetSeconds = function() return os.time() end
            Engine.GetMilliseconds = function() return os.time() * 1000 end
            Engine.GetMicroseconds = function() return os.time() * 1000000 end
            Engine.GetNanoseconds = function() return os.time() * 1000000000 end
        end

        local GT = package.loaded["GameLua.GameCore.Data.GameTime"]
        if GT then
            GT.GetServerTime = function() return os.time() end
            GT.GetDeltaTime = function() return 0.033 end
            GT.GetGameTime = function() return os.time() end
            GT.GetRealTime = function() return os.time() end
            GT.GetTickTime = function() return os.clock() end
            GT.GetFrameTime = function() return 0.016 end
        end
    end)
end

--=============================================================================
-- [38] Spoof Network Stats
--=============================================================================
local function SpoofNetworkStats()
    pcall(function()
        local NM = import("NetworkManager")
        if NM then
            NM.GetNetworkStats = function()
                return { ping = 40, loss = 0, rtt = 40 }
            end
            NM.CapturePackets = noOp
            NM.AnalyzeTraffic = returnEmptyTable
            NM.GetConnectionInfo = function() return "127.0.0.1:8080" end
            NM.MonitorTraffic = noOp
            NM.ReportTraffic = noOp
            NM.ReportNetwork = noOp
            NM.ReportBandwidth = noOp
            NM.ReportLatency = noOp
            NM.ReportPacketLoss = noOp
        end

        local ND = import("NetworkDetect")
        if ND then
            ND.IsNetworkError = returnFalse
            ND.GetNetworkError = returnEmptyString
            ND.ReportNetworkError = noOp
        end
    end)
end

--=============================================================================
-- [39] Bypass Debugger Detection
--=============================================================================
local function BypassDebugger()
    pcall(function()
        local DD = _G.DebuggerDetect or package.loaded.DebuggerDetect
        if DD then
            DD.IsDebuggerPresent = returnFalse
            DD.CheckBreakpoint = returnFalse
            DD.CheckTracer = returnFalse
            DD.CheckDebug = returnFalse
            DD.CheckDebugger = returnFalse
            DD.DetectDebugger = returnFalse
            DD.DetectBreakpoint = returnFalse
            DD.DetectTracer = returnFalse
            DD.DetectDebug = returnFalse
        end

        if debug then
            if debug.getinfo then
                debug.getinfo = function() return {} end
            end
            debug.sethook = noOp
            if debug.getlocal then
                debug.getlocal = function() return nil end
            end
            debug.setlocal = noOp
            if debug.getupvalue then
                debug.getupvalue = function() return nil end
            end
            debug.setupvalue = noOp
        end
    end)
end

--=============================================================================
-- [40] Bypass Emulator / Root / Jailbreak Detection
--=============================================================================
local function BypassEmulatorRoot()
    pcall(function()
        local ED = _G.EmulatorDetect or package.loaded.EmulatorDetect
        if ED then
            ED.IsEmulator = returnFalse
            ED.GetEmulatorType = returnEmptyString
            ED.CheckVM = returnFalse
            ED.Detect = returnFalse
            ED.DetectEmulator = returnFalse
            ED.DetectVM = returnFalse
            ED.DetectVirtualMachine = returnFalse
            ED.DetectEmulatorType = returnEmptyString
        end

        local RD = _G.RootDetect or package.loaded.RootDetect
        if RD then
            RD.CheckRoot = returnFalse
            RD.CheckSu = returnFalse
            RD.CheckMagisk = returnFalse
            RD.CheckSuperSU = returnFalse
        end

        local JD = _G.JailbreakDetect or package.loaded.JailbreakDetect
        if JD then
            JD.CheckJailbreak = returnFalse
            JD.CheckCydia = returnFalse
        end
    end)
end

--=============================================================================
-- [41] Bypass Packet Encryption
--=============================================================================
local function BypassPacketEncrypt()
    pcall(function()
        local PE = _G.PacketEncrypt or package.loaded.PacketEncrypt
        if PE then
            PE.Encrypt = function(d) return d end
            PE.Decrypt = function(d) return d end
            PE.VerifyChecksum = returnTrue
            PE.Validate = returnTrue
            PE.ValidatePacket = returnTrue
            PE.VerifyPacket = returnTrue
            PE.CheckPacket = returnTrue
            PE.EncryptPacket = function(d) return d end
            PE.DecryptPacket = function(d) return d end
            PE.ValidateChecksum = returnTrue
            PE.VerifyChecksum = returnTrue
            PE.CheckChecksum = returnTrue
        end
    end)
end

--=============================================================================
-- [42] Bypass DS Validator
--=============================================================================
local function BypassDSValidator()
    pcall(function()
        local DV = _G.DSValidator or package.loaded.DSValidator
        if DV then
            DV.ValidateClient = returnTrue
            DV.CheckLatency = function() return 40 end
            DV.ReportCheat = noOp
            DV.KickPlayer = noOp
            DV.BanPlayer = noOp
            for _, name in ipairs({
                "ValidatePlayer", "ValidateSession", "ValidateGame",
                "ValidateSystem", "ValidateDevice", "ValidateNetwork",
                "ValidateMemory", "ValidateFile", "ValidateProcess",
                "ValidateThread", "ValidateModule", "ValidateAPI",
                "ValidateSDK", "ValidateLibrary", "ValidateFramework",
                "ValidatePackage", "ValidateContainer", "ValidateComponent",
                "ValidateObject", "ValidateClass", "ValidateStruct",
                "ValidateEnum", "ValidateInterface", "ValidateDelegate",
                "ValidateEvent", "ValidateFunction", "ValidateVariable",
                "ValidateProperty", "ValidateField", "ValidateMethod",
                "ValidateParameter", "ValidateReturn", "ValidateResult",
                "ValidateOutput", "ValidateInput",
            }) do
                DV[name] = returnTrue
            end
        end

        _G.bDSKick = false
        _G.DSKickReason = nil
        _G.bIsSystemBanned = false
        _G.BanDuration = 0
        _G.BanType = 0
    end)
end

--=============================================================================
-- [43] Clear Memory / Logs / Queues
--=============================================================================
local function ClearMemoryAndLogs()
    pcall(function()
        local MC = import("MemoryCleaner")
        if MC then
            MC.ClearCache = noOp
            MC.FreeUnusedMemory = noOp
            MC.CompactHeap = noOp
            MC.CleanTraces = noOp
            MC.ClearLogs = noOp
            MC.ClearTemp = noOp
            MC.ClearCacheFiles = noOp
            MC.ClearHistory = noOp
            MC.ClearData = noOp
        end

        _G.TelemetryQueue = {}
        _G.LogQueue = {}
        _G.ReportQueue = {}
        _G.ExceptionQueue = {}
        _G.CrashQueue = {}
        _G.TraceQueue = {}
        _G.bLoggingEnabled = false
        _G.bReportingEnabled = false
        _G.bExceptionReportingEnabled = false
        _G.bCrashReportingEnabled = false
        _G.bTracingEnabled = false
    end)
end

--=============================================================================
-- [44] Bypass SecurityCommonUtils
--=============================================================================
local function BypassSecurityCommonUtils()
    pcall(function()
        local SCU = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
        if SCU then
            SCU.ExtractPlayerBasicInfo = returnEmptyTable
            SCU.LogIf = returnFalse
            for _, name in ipairs({
                "CheckSecurity", "ValidatePlayer", "ValidateSession", "ValidateGame",
                "ValidateSystem", "ValidateDevice", "ValidateNetwork", "ValidateMemory",
                "ValidateFile", "ValidateProcess", "ValidateThread", "ValidateModule",
                "ValidateAPI", "ValidateSDK", "ValidateLibrary", "ValidateFramework",
                "ValidatePackage", "ValidateContainer", "ValidateComponent",
                "ValidateObject", "ValidateClass", "ValidateStruct", "ValidateEnum",
                "ValidateInterface", "ValidateDelegate", "ValidateEvent",
                "ValidateFunction", "ValidateVariable", "ValidateProperty",
                "ValidateField", "ValidateMethod", "ValidateParameter",
                "ValidateReturn", "ValidateResult", "ValidateOutput", "ValidateInput",
            }) do
                SCU[name] = returnTrue
            end
        end
    end)
end

--=============================================================================
-- [45] Bypass DataMgr Reporting
--=============================================================================
local function BypassDataMgr()
    pcall(function()
        local DM = package.loaded["client.slua.logic.data.data_mgr"] or _G.DataMgr
        if DM then
            DM.GetWeaponSkinSoundVolumeInfoByGroup = function() return 0 end
            for _, name in ipairs({
                "ReportData", "ReportStats", "ReportMetrics", "ReportAnalytics",
                "ReportTelemetry", "ReportPerformance", "ReportBattery",
                "ReportTemperature", "ReportFPS", "ReportPing", "ReportNetwork",
                "ReportDevice", "ReportSystem", "ReportGame", "ReportUser",
                "ReportAccount", "ReportSession",
            }) do
                DM[name] = noOp
            end
        end
    end)
end

--=============================================================================
-- [46] Master Initialization
--=============================================================================
local function InitializeBypass()
    if MAHDI_BYPASS.Initialized then return end

    BlockUIPopups()
    BlockNetworkTraffic()
    BypassHiggsBoson()
    BypassTssSdk()
    BypassACE()
    BypassXignCode()
    BypassBattlEye()
    BypassHawkEye()
    BypassGokuba()
    BypassSwiftHawk()
    BypassCoronaLab()
    BypassBanSystems()
    BypassReportSystems()
    BypassTLog()
    BypassCrashSight()
    BypassScreenshot()
    BypassMemoryScanner()
    BypassFileCheck()
    BypassAvatarValidation()
    BypassShootVerify()
    BypassAFKReport()
    BypassGameplayCallbacks()
    SpoofDeviceInfo()
    BypassDNS()
    BypassJNI()
    DisableLogging()
    BypassTDataMaster()
    BypassRacing()
    BypassSluaVerify()
    PatchClient()
    BypassLoginModule()
    KillSecuritySubsystems()
    ApplyConsoleCommands()
    BypassMD5()
    InstallGlobalProtection()
    BypassMemoryProtection()
    SpoofEngineTiming()
    SpoofNetworkStats()
    BypassDebugger()
    BypassEmulatorRoot()
    BypassPacketEncrypt()
    BypassDSValidator()
    ClearMemoryAndLogs()
    BypassSecurityCommonUtils()
    BypassDataMgr()

    MAHDI_BYPASS.Initialized = true
    MAHDI_BYPASS.Protected   = true
end

--=============================================================================
-- [47] Reapply Bypass (periodic re-hook)
--=============================================================================
local function ReapplyBypass()
    pcall(function()
        BlockUIPopups()

        local pc = getPlayerController()
        if isValidObject(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
            end
        end

        local KSL = import("KismetSystemLibrary")
        if KSL and isValidObject(pc) then
            KSL.ExecuteConsoleCommand(pc, "security.DisableChecks 1")
            KSL.ExecuteConsoleCommand(pc, "Net.BlockAllAntiCheat 1")
            KSL.ExecuteConsoleCommand(pc, "AntiCheat.DisableAll 1")
            KSL.ExecuteConsoleCommand(pc, "DisableBanUI 1")
            KSL.ExecuteConsoleCommand(pc, "HideBanMessages 1")
        end

        -- Re-enable all permissions
        if MAHDI_BYPASS.Permissions then
            for k in pairs(MAHDI_BYPASS.Permissions) do
                MAHDI_BYPASS.Permissions[k] = true
            end
        end
        if _G.AntiCheatBlock then
            for k in pairs(_G.AntiCheatBlock) do
                _G.AntiCheatBlock[k] = true
            end
        end
    end)
end

--=============================================================================
-- [48] Notify (with Lexus integration + print)
--=============================================================================
local function Notify(message)
    pcall(function()
        if _G.LexusNotify then
            _G.LexusNotify(message)
        end
    end)
    pcall(function()
        local SH = import("ScriptHelperClient")
        if SH and SH.AddOnScreenDebugMessage then
            SH.AddOnScreenDebugMessage(SH.AddOnScreenDebugMessage, -1, 3.0,
                {R=1, G=1, B=0, A=1}, {X=1.2, Y=1.2})
        end
    end)
    print("[MAHDI_BYPASS] " .. message)
end

--=============================================================================
-- [49] Bootstrap
--=============================================================================
local function StartBypass()
    local Timer = require("common.time_ticker")
    if not Timer then return end

    Timer.AddTimerOnce(0.5, InitializeBypass)
    Timer.AddTimerOnce(1.0, ReapplyBypass)
    Timer.AddTimerLoop(0.3, ReapplyBypass, -1, 0.3)
end

pcall(StartBypass)

-- Startup messages
print("========================================")
print("[MAHDI_BYPASS] ULTIMATE ANTI-CHEAT BYPASS")
print("[MAHDI_BYPASS] Version: 5.0")
print("[MAHDI_BYPASS] Author: MAHDI")
print("[MAHDI_BYPASS] Status: ACTIVE")
print("[MAHDI_BYPASS] Protection Level: ULTIMATE")
print("[MAHDI_BYPASS] All 24+ Bypass Layers Active!")
print("[MAHDI_BYPASS] 100% UNDETECTED - NEVER BANNED")
print("========================================")

--=============================================================================
-- [50] Player Character Registration (Feature Chain)
--=============================================================================
local Class         = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass  = require("combine_class")

-- Minimal player character wrapper (features only)
local MAHDIPlayerCharacterBase = Class(CharacterBase, nil, {})

--=============================================================================
-- [51] Feature Declarations
--=============================================================================
local FEATURES = {
    { SkyTransition                  = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature            = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature             = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature            = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl                  = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect                = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature                    = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature              = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation             = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" },
}

return CombineClass.DeclareFeature(MAHDIPlayerCharacterBase, FEATURES, "MAHDI_BRPlayerCharacterBase")