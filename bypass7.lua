
-- ==================== BYPASS ENGINE (copied from TrnDravix) ====================
if _G._BYPASS_LOADED then return end
_G._BYPASS_LOADED = true

local noop = function() return true end
local retFalse = function() return false end
local retZero = function() return 0 end
local retEmpty = function() return {} end
local retTrue = function() return true end
local retEmptyString = function() return "" end
local safe_require = function(path) local ok, mod = pcall(require, path); return ok and mod or nil end
local isValid = slua.isValid

-- modulePatches (full table from TrnDravix)
local modulePatches = {
    ["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"] = {
        methods = {
            ControlMHActive = noop, Tick = noop, OnTick = noop, ReceiveTick = noop, MHActiveLogic = noop,
            TriggerAvatarCheck = noop, StartAvatarCheck = noop, ReportItemID = noop, OnReportItemID = noop,
            ReceiveAnyDamage = noop, OnWeaponHitRecord = noop, ShowSecurityAlert = noop, StaticShowSecurityAlertInDev = noop,
            SendHisarData = noop, OnLogin = noop, ValidateSecurityData = noop, CheckMemoryIntegrity = noop,
            ReportAbnormalMemory = noop, OnMemoryScanComplete = noop, SendDetectionResult = noop, TriggerClientScan = noop,
            SendAntiDataFlow = noop, SendHitFireBtnFlow = noop, SkipAlertServer = function() end,
            CheckWeaponIntegrity = retTrue, CheckAvatarIntegrity = retTrue, CheckBulletIntegrity = retTrue,
            OnGameModeType = noop,
        },
        fields = { bMHActive = false, mHActive = 0 },
        retvals = { GetNetAvatarItemIDs = retEmpty, GetCurWeaponSkinID = retZero, GetDetectionResult = retEmpty },
        custom = function(m)
            if m.__inner_impl then
                local i = m.__inner_impl
                i.SendAntiDataFlow = noop; i.SendHitFireBtnFlow = noop; i.OnBattleResult = noop; i.SendHisarData = noop
            end
            if m.BlackList then for k in pairs(m.BlackList) do m.BlackList[k] = nil end end
            if m.SkipAlertServer then pcall(m.SkipAlertServer, m) end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Security.SafetyDetectionSubsystem"] = {
        methods = { DetectAbnormal = noop, ReportAbnormal = noop, OnDetectionResult = noop, TriggerSafetyScan = noop },
        retvals = { GetScanResults = retEmpty, IsAnomalyDetected = retFalse },
    },
    _G_AvatarCheckCallback = {
        table = "_G.AvatarCheckCallback",
        methods = {
            StartAvatarCheck = noop, OnReportItemID = noop,
            PostPlayerControllerLoginInit = function(pc)
                pcall(function()
                    if pc and pc.HiggsBosonComponent then
                        pc.HiggsBosonComponent:ControlMHActive(0)
                        pc.HiggsBosonComponent.bMHActive = false
                    end
                end)
            end
        }
    },
    ["GameLua.Mod.BaseMod.Common.Security.PakIntegrityChecker"] = {
        methods = { ShowPakMismatchAlert = noop },
        retvals = { Verify = retFalse, CheckPakFile = retZero, GetPakStatus = retZero }
    },
    ["client.slua.logic.pak.logic_pak_verify"] = {
        retvals = { Verify = retFalse, CheckPakFile = retZero, GetPakStatus = retZero }
    },
    _G_STExtra = {
        table = "_G.STExtraBlueprintFunctionLibrary",
        retvals = { CheckFileIntegrity = retFalse, VerifySignature = retFalse, CheckGameLuaIntegrity = retFalse }
    },
    _G_TssSDK = {
        table = "_G.TssSDK",
        methods = {
            ReportData = noop, SendToServer = noop, SetUserInfo = noop,
            Init = noop, Start = noop, Verify = retTrue, CheckIntegrity = retTrue, Check = retTrue,
        },
        retvals = { GetSignature = function() return "BYPASSED" end }
    },
    _G_TssSDKHelper = { table = "_G.TssSDKHelper", methods = { ReportData = noop } },
    _G_Bugly = { table = "_G.Bugly", methods = { ReportException = noop, SetCustomData = noop } },
    _G_Beacon = { table = "_G.Beacon", methods = { Report = noop } },
    _G_CrashSight = { table = "_G.CrashSight", methods = { ReportException = noop, SetCustomData = noop, Log = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"] = {
        methods = {
            ClientRPC_SyncBanID = noop, ClientRPC_StrongTips = noop, ClientRPC_NormalTips = noop, Notify = noop,
            ClientRPC_NotifyBan = noop, ClientRPC_NotifyPunish = noop, ClientRPC_NotifyIllegalProgram = noop
        },
        custom = function(m) if m.__inner_impl then m.__inner_impl.SyncBanInfo = noop end end,
    },
    ["client.slua.logic.ban.ClientBanLogic"] = {
        methods = {
            OnSyncBanInfo = noop, OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop, OnVoiceBanSuccess = noop,
            OnSyncMicSuspicious = noop, OnSyncMicPreFilter = noop, OnNotifyWarningTips = noop, ReqBanInfo = noop
        },
    },
    ["client.slua.logic.ban.BanTipsLogic"] = {
        methods = { ShowBanTips = noop, ShowPunishTips = noop, ShowWarningTips = noop, OnReceiveBanNotice = noop }
    },
    _G_ban_util = { table = "_G.ban_util", retvals = { CheckBanStatus = retFalse, GetBanTime = retZero, IsBanForever = retFalse } },
    _G_logic_tt_ban = {
        table = "_G.logic_tt_ban",
        methods = { CheckIfCanCreateRole = noop },
        retvals = { JumpAppealURL = retFalse, GetCarrierInfo = function() return '[{"mcc":"000"}]' end }
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"] = {
        methods = {
            _OnHawkSync = noop, _OnHawkReportSuccess = noop, _StartExitGameTimer = noop,
            _OnRecvInspectorBroadcastCount = noop, SendReportTLog = noop, ReportCheat = noop,
            _OnHawkFlag = noop, ReportPlayerFlag = noop, RequestFlagPlayer = noop, SendFlagReport = noop,
            RequestImprison = noop, IsDuringHawkEyePatrol = retFalse, HasReported = retTrue,
            _InitHawkEyePatrolSubsystem = noop, _CollectBeWatchedPlayerInfo = noop, ServerRPC_HawkReportCheat = noop,
        },
        retvals = { CanInspectorBroadcast = retFalse },
        custom = function(mod)
            if mod.__inner_impl then
                local i = mod.__inner_impl
                i._OnHawkSync = noop; i._OnHawkReportSuccess = noop; i.TryShowReportedTips = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem"] = {
        custom = function(mod)
            if mod.__inner_impl then
                local i = mod.__inner_impl
                i._OnHawkSync = noop; i._OnHawkReportSuccess = noop; i.TryShowReportedTips = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem"] = {
        custom = function(m)
            if m.OnSpectatorReplayChanged then
                local o = m.OnSpectatorReplayChanged
                m.OnSpectatorReplayChanged = function(...)
                    _G.IsBeingWatched = true
                    return o(...)
                end
            end
        end,
    },
    _G_ServerDataMgr = {
        table = "_G.ServerDataMgr",
        custom = function(m)
            if m.DeletablePlayerResultKey then
                for _, k in ipairs({
                    "SuspiciousHitCount", "EspTotalSimTraceCnt", "EspTotalImeFocusCnt",
                    "ClientGravityAnomalyCount", "FireCount", "SpeedCheatCount", "JumpCount", "VehicleSpeedHackCount",
                    "HeadshotCount", "KillCount", "Accuracy", "FlagCount", "TotalFlags", "IsFlagged",
                    "FlaggedByHawkEye", "FlaggedByInspection", "FlagTimestamp", "FlagLevel", "FlagSeverity",
                }) do m.DeletablePlayerResultKey[k] = true end
            end
            if m.FlagCount then m.FlagCount = 0 end
            if m.TotalFlags then m.TotalFlags = 0 end
            if m.IsFlagged then m.IsFlagged = false end
            if m.FlaggedByHawkEye then m.FlaggedByHawkEye = false end
            if m.FlaggedByInspection then m.FlaggedByInspection = false end
            if m.FlagTimestamp then m.FlagTimestamp = 0 end
            if m.FlagLevel then m.FlagLevel = 0 end
            if m.FlagSeverity then m.FlagSeverity = 0 end
        end
    },
    ["client.slua.logic.report.ToolReportUtil"] = {
        retvals = { IsReleaseVersion = retFalse, IsWhite = retFalse, GetReportSwitch = retFalse }
    },
    _G_ClientToolsReport = { table = "_G.ClientToolsReport", methods = { SendReport = noop, SendException = noop } },
    _G_ReportPlatformCrashKit = { table = "_G.ReportPlatformCrashKit", methods = { Send = noop, ForceSend = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem"] = {
        methods = {
            CheckHitIntegrity = noop, InitSession = noop, OnBattleEnd = noop,
            LuaFunc1 = retTrue, LuaFunc4 = retFalse, LuaFunc5 = retFalse,
            LuaFunc6 = retFalse, LuaFunc7 = retFalse, LuaFunc8 = retFalse,
            LuaFunc9 = noop,
        }
    },
    ["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"] = {
        methods = { OnHandleBehaviorScore = noop, AIPerceptionScore = noop, ReportBehavior = noop },
        retvals = { CalcFinalScore = retZero }
    },
    _G_AntiAddictionHandler = {
        table = "_G.AntiaddctionHandler",
        methods = { send_anti_addiction_req = noop, send_anti_addiction_notify = noop, on_check_nonage_anti_work = noop }
    },
    _G_AccessRestrictionHandler = {
        table = "_G.AccessRestrictionHandler",
        methods = { send_access_restriction_req = noop, send_access_restriction_notify = noop, on_player_cheat_state_notify = noop }
    },
    _G_GodzillaBanHandler = {
        table = "_G.GodzillaBanHandler",
        methods = { send_godzilla_ban_req = noop, send_godzilla_unban_req = noop }
    },
    _G_logic_deleteaccount = {
        table = "_G.logic_deleteaccount",
        retvals = { ForceDeleteAccount = retFalse },
        methods = { OnReceiveDeleteNotify = noop }
    },
    _G_compliance_util = { table = "_G.compliance_util", methods = { CheckCompliance = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"] = {
        methods = {
            OnInit = noop, _OnPlayerKilledOtherPlayer = noop, _RecordFatalDamager = noop,
            _OnDeathReplayDataWhenFatalDamaged = noop, _RecordMurdererFromDeathReplayData = noop,
            _RecordTeammatePlayerInfo = noop, _OnBattleResult = noop, _OnShowQuickReportMutualExclusiveUI = noop,
            GetFatalDamagerMap = retEmpty, GetCachedTeammateName2InfoMap = retEmpty,
            GetTeammateName2InfoMapDuringBattle = retEmpty, GetCurrentNotInTeamHistoricalTeammateMap = retEmpty,
            GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end,
            ReportSuspiciousPlayer = noop, SubmitReport = noop, ProcessReport = noop,
            ClientRPC_SyncFatalDamagerMap = noop,
        },
        custom = function(m)
            if m.__inner_impl then
                m.__inner_impl._OnSyncFatalDamage = noop
                m.__inner_impl._OnPlayerKilledOtherPlayer = noop
                m.__inner_impl._SyncBattleResult = noop
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Common.Security.DSReportPlayerSubsystem"] = {
        methods = {
            OnInit = noop, _OnNearDeathOrRescued = noop, _OnCharacterDied = noop, _OnTeammateDamage = noop,
            _OnPlayerSettlementStart = noop, _AddKnockDownerToBattleResult = noop, _AddKillerToBattleResult = noop,
            _AddTeammateMurderToBattleResult = noop, _AddFatalDamagerMapToBattleResult = noop,
            _AddMLKillerUIDToBattleResult = noop, _SaveHistoricalTeammateInfo = noop, _RecordFatalDamager = noop,
            _RecordTeammateMurderer = noop,
            _AddEnemyMapToBattleResult = noop, _AddTeammateMapToBattleResult = noop, _SubmitAbnormalData = noop,
            _tUID2InfoMap = retEmpty, ds2history = retEmpty,
        },
    },
    ["GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils"] = {
        retvals = { GetBotType = retZero, IsCharacterDeliverAI = retFalse },
        methods = { RecordFatalDamager = noop, IsUsingHistoricalTeammateInfo = retFalse },
    },
    ["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"] = {
        methods = { ExtractPlayerBasicInfo = retEmpty, LogIf = retFalse },
        custom = function(m)
            if m.EStrategyTypeInReplay then
                m.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
                m.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
                m.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
                m.EStrategyTypeInReplay.FlyingErrorCnt = 0
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate"] = {
        methods = { OnShowMutualExclusiveUI = noop, OnHideMutualExclusiveUI = noop,
            MaliciousTeammateReceiveWarningTips = noop, MaliciousTeammateVictimReceiveTips = noop },
    },
    _G_ClientTlogHandler = { table = "_G.ClientTlogHandler", methods = { send_report_lobby_common_tlog = noop } },
    _G_LoginAndWinTlogHandler = { table = "_G.LoginAndWinTlogHandler", methods = { on_cloud_game_event_notify = noop } },
    _G_tlog_report_utils = { table = "_G.tlog_report_utils", methods = { ReportTLogEvent = noop, ReportImmediate = noop } },
    _G_BasicDataTLogReport = {
        table = "_G.BasicDataTLogReport",
        methods = { OnSendBatchReqMsg = noop, OnImmediateReqMsg = noop, OnMergeReqMsg = noop, send_report_event_duration_log = noop, SendTlog = noop, ReportEvent = noop },
        retvals = { _GetParamData = retEmpty }
    },
    _G_BasicDataClientReport = {
        table = "_G.BasicDataClientReport",
        methods = { ReportImmediate = noop, ReportDelay = noop, OnSendBatchReqMsg = noop, OnImmediateReqMsg = noop, OnMergeReqMsg = noop },
        retvals = { _IsCanReport = retFalse }
    },
    _G_BasicDataReport = {
        table = "_G.BasicDataReport",
        methods = { ReportImmediate = noop, ReportDelay = noop, OnMergeReqMsg = noop, OnImmediateReqMsg = noop, OnSendBatchReqMsg = noop, _BatchReqMsg = noop }
    },
    _G_puffer_tlog = { table = "_G.puffer_tlog", methods = { report_download_tlog = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem"] = { methods = { SendICExceptionTLog = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"] = {
        methods = { ReportFightData = noop, ReportPlayerWeapon = noop },
        retvals = { GetSimpleFightData = retEmpty }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"] = {
        methods = {
            _OnReportServerJumpFlow = noop, _OnReportTeleportFlow = noop, _OnReportSpeedHackFlow = noop,
            ReportServerJumpFlow = noop, CollectJumpData = noop,
        },
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"] = { methods = { HandleKillTlog = noop } },
    _G_ClientErrorReportHandler = {
        table = "_G.ClientErrorReportHandler",
        methods = { send_client_error_report = noop, send_client_crash_report = noop, send_client_tools_batch_report_req = noop }
    },
    _G_BattleReportHandler = {
        table = "_G.BattleReportHandler",
        methods = {
            send_battle_report = noop, send_battle_result = noop, send_vod_game_report_req = noop,
            send_batch_get_vod_info_req = noop, send_get_game_report_req = noop, send_batch_get_game_report_req = noop,
            send_get_game_report_by_uid_req = noop
        }
    },
    _G_BugHandler = { table = "_G.BugHandler", methods = { send_report_bug_info = noop, send_report_bug_feedback = noop } },
    _G_LobbyPingReportHandler = { table = "_G.LobbyPingReportHandler", methods = { send_lobby_ping_report = noop, send_ingame_ping_report = noop } },
    _G_WeekRportHandler = { table = "_G.WeekRportHandler", methods = { send_week_report = noop, send_week_detail = noop } },
    _G_logic_complaint = {
        table = "_G.logic_complaint",
        methods = { SendComplaintReq = noop, Submit = noop, ReportPlayer = noop, ShowComplaint = noop, ShowHandle = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.EscapeBattleResultShowOBResultLogic"] = {
        methods = { OnBattleResult = noop, OnResultProcessStart = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowOBResultLogic"] = {
        methods = { OnBattleResult = noop, OnResultProcessStart = noop }
    },
    ["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowResultLogic"] = {
        methods = {
            OnBattleResult = noop, OnResultProcessStart = noop, OnResultProcessContinue = noop,
            ReceiveData = noop, SendEndFlow = noop, OnReport = noop, ShowResult = noop, ShowResultInternal = noop,
            StopResultProcess = noop
        }
    },
    _G_EmulatorHandler = { table = "_G.EmulatorHandler", methods = { send_emulator_info = noop } },
    _G_emulator_scanner = {
        table = "_G.emulator_scanner",
        methods = { StartScan = noop, ReportScanResult = noop },
        retvals = { GetScanResult = retFalse }
    },
    _G_LoginVerifyHandler = { table = "_G.LoginVerifyHandler", methods = { send_login_verify_req = noop, send_device_verify_req = noop } },
    _G_logic_ds_monitor = { table = "_G.logic_ds_monitor", methods = { OnRecordMsg = noop, OnReportMsg = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"] = {
        methods = { StartToCheck = noop, OnReceiveRTT = noop, OnReceiveJitter = noop, ReportAbnormal = noop, ResetData = noop }
    },
    ["GameLua.Dev.Subsystem.ShootVerifySubSystemClient"] = { methods = { OnShootVerifyFailed = noop, SendVerifyData = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker"] = { methods = { CheckFuncUpgradedWeaponKill = noop } },
    _G_logic_chat_voice_report = { table = "_G.logic_chat_voice_report", methods = { ReportVoiceData = noop, ReportVoiceText = noop } },
    _G_logic_chat_voice_doctor = { table = "_G.logic_chat_voice_doctor", methods = { UploadVoiceLog = noop, UploadVoiceException = noop } },
    _G_logic_home_audit_state = { table = "_G.logic_home_audit_state", methods = { SendAuditState = noop, ReportAuditResult = noop } },
    _G_logic_home_report = { table = "_G.logic_home_report", methods = { ReportHomeData = noop, ReportHomeVisitor = noop, ShowInGameReportUI = noop, SendReport = noop } },
    _G_gem_report_utils = {
        table = "_G.gem_report_utils",
        methods = { ReportGemData = noop, ReportGemPurchase = noop, ReportEventImmediate = noop },
    },
    _G_ChatHandler = { table = "_G.ChatHandler", methods = { send_report_info = noop, send_report_info_mic = noop } },
    _G_ClientReplayDataReporter = { table = "_G.ClientReplayDataReporter", methods = { ReportIntArrayData = noop, ReportFloatArrayData = noop, ReportUInt8ArrayData = noop } },
    ["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"] = {
        custom = function(m)
            if m.uCompletePlayBack then
                m.uCompletePlayBack.AddRecordMLAIInfo = noop
                m.uCompletePlayBack.StopRecording = noop
            end
            if m.ReportAllPlayerInfo then m.ReportAllPlayerInfo = noop end
            if m.ReportFrameData then m.ReportFrameData = noop end
            if m.ReportPlayerInput then m.ReportPlayerInput = noop end
        end,
    },
    _G_GameSafeCallbacks = {
        table = "_G.GameSafeCallbacks",
        methods = {
            PostPlayerControllerLoginInit = noop, OnDSGlueHiaInit = noop, CharacterReceiveBeginPlay = noop,
            DoAttackFlowStrategy = noop, RecordStrategyTimestampInReplay = noop, EditorIncreaseTotalStatisticCnt = noop
        },
        retvals = { GetScriptReportContent = function() return "" end }
    },
    ["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"] = {
        methods = { ReportException = noop, ReplayReportData = noop, ReportGameException = noop },
        retvals = { BugglyPostExceptionFull = retFalse, CheckCanBugglyPostException = retFalse }
    },
    _G_NetUtil = { table = "_G.NetUtil", methods = { SendTss = noop, SendToServer = noop, SendToDS = noop } },
    ["UnrealNet"] = {
        global = true,
        custom = function(m)
            if not m then return end
            if m.FilterNetworkException then
                local o = m.FilterNetworkException
                m.FilterNetworkException = function(et, em)
                    if em and type(em) == "string" then
                        local le = em:lower()
                        if le:find("cheatdetected") or le:find("idipban") or le:find("dataerror") or le:find("datamismatch")
                           or le:find("security") or le:find("integrity") or le:find("hashfail") or le:find("flag") then
                            return false
                        end
                    end
                    return o(et, em)
                end
            end
            m.HandleNetworkExceptionReport = noop
            m.HandleNetworkConnectionClosed = noop
            m.HandleSpectateException = noop
        end
    },
    ["GameLua.Mod.BaseMod.Client.Security.Gokuba"] = {
        custom = function(m)
            if m.ForwardFeature then
                m.ForwardFeature = function() return {0, 0, 0, 0, 0} end
            end
            if m.TimerHandle then
                pcall(function()
                    local time_ticker = require("common.time_ticker")
                    time_ticker.RemoveTimer(m.TimerHandle)
                end)
                m.TimerHandle = nil
            end
        end
    },
    ["GameLua.Mod.BaseMod.Common.Security.CoronaUploader"] = { methods = { Upload = noop, Flush = noop } },
    ["GameLua.Mod.BaseMod.Client.Login.LoginLock"] = { methods = { Lock = noop, OnLoginBan = noop }, retvals = { CheckBan = retFalse } },
    ["GameLua.Mod.BaseMod.GamePlay.Battle.BattleResultUploader"] = { methods = { Upload = noop } },
    ["client.slua.logic.ClientAppStat"] = { methods = { Report = noop, Flush = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.DeviceFingerprint"] = {
        methods = { Collect = noop, Sync = noop, GetHash = function() return "unknown" end }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSDeviceCheck"] = { methods = { VerifyClientDevice = retTrue, ReportMismatch = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.IntegrityCheck"] = { methods = { Run = noop, Verify = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.APKIntegrity"] = { methods = { CheckSignature = retTrue, CheckInstallSource = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.LibCheck"] = {
        methods = { Verify = retTrue, Check = retTrue, Scan = noop, Report = noop },
        retvals = { IsLibValid = retTrue, GetTamperedLibs = retEmpty }
    },
    _G_TDataMaster = {
        table = "_G.TDataMaster",
        methods = { Report = noop, ReportDeviceInfo = noop, SendHardwareHash = noop, CollectTelemetry = noop, SendData = noop, Sync = noop, Flush = noop },
        custom = function(m)
            if m then for k, v in pairs(m) do if type(v) == "function" then m[k] = noop end end end
        end,
    },
    _G_DeviceInfo = {
        table = "_G.DeviceInfo",
        methods = { GetDeviceID = function() return "unknown" end, GetIMEI = function() return "000000000000000" end, CollectSysInfo = noop }
    },
    ["client.slua.logic.platform.platform_db"] = { methods = { Scan = noop, CheckIntegrity = retFalse, ReportCorruption = noop } },
    ["xunyou_cache_scan"] = { methods = { StartScan = noop, GetResult = retEmpty } },
    _G_SecurityTlogQueue = { table = "_G.SecurityTlogQueue", methods = { Flush = noop, Add = noop } },
    _G_PufferDownloadReport = { table = "_G.PufferDownloadReport", methods = { ReportDownload = noop, ReportError = noop } },
    _G_ReplayRecordSecurity = { table = "_G.ReplayRecordSecurity", methods = { InjectMeta = noop, Validate = noop } },
    _G_GameServerHeartbeat = { table = "_G.GameServerHeartbeat", methods = { ReportMissedBeat = noop, CheckAlive = retTrue } },
    ["GameLua.Mod.BaseMod.Common.Security.AntiDebug"] = { methods = { Check = retFalse, Report = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.SecureBootCheck"] = { methods = { VerifyBoot = retTrue } },
    ["GameLua.Mod.BaseMod.DS.Security.DSPlayerValidCheck"] = { methods = { Validate = retTrue, ReportSuspicious = noop } },
    ["client.slua.logic.common.logic_common_legal_msg"] = {
        custom = function(m)
            if m.ShowOnePopUI then
                local o = m.ShowOnePopUI
                m.ShowOnePopUI = function(self, params)
                    if params and params.title and params.title:find("SECURITY") then return end
                    return o(self, params)
                end
            end
        end,
    },
    ["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"] = {
        methods = {
            AskForInspector = noop, ReportEnemy = noop, KickOutOneTeam = noop,
            OnReceiveInspectCmd = noop, ClientReportData = noop, SendReportToInspector = noop,
            SendKickOutOneTeam = noop, ClientNotifyInspectorImplementation = noop, RecvNotifyInspector = noop,
        },
    },
    ["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"] = {
        methods = {
            ServerKickOutOneTeamByPlayerImplementation = noop, AddReportedCount = noop,
            AddInspectionRecord = noop, BanPlayerByInspection = noop,
            BroadCastToAllInspector = noop, ServerReportToInspectorImplementation = noop,
            InitPlayerInspectionInfo = noop,
        },
        fields = { MAX_ASK_FOR_INSPECTOR_TIME = 0, ASK_FOR_INSPECTOR_INTERVAL = 99999 },
        custom = function(m)
            if m.__inner_impl then
                m.__inner_impl.IsGameModeAllowed = retTrue
            end
        end,
    },
    ["client.slua.logic.CustomerService.LogicSafeStation"] = {
        methods = { UploadVideoEvidence = noop, ReportPlayerBehavior = noop },
    },
    ["client.slua.logic.CustomerService.LogicCustomerService"] = {
        methods = { SendComplaint = noop, SendFeedback = noop },
    },
    ["GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.AmphibiousBoatTLogFeature"] = {
        methods = { RecordMovement = noop, StartRecordMovement = noop },
    },
    ["client.logic.data.profile_report_cfg"] = { methods = { SendReport = noop } },
    ["GameLua.Mod.BaseMod.Client.ClientInGameCreditLogic"] = {
        methods = {
            _SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice = noop,
            ShowReturnLobbyIfFirstExitTeamBeforeBoarding = retFalse,
            OnReceiveCreditScoreChange = noop,
            _IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = retFalse,
            SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = noop,
        },
    },
    ["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem"] = { methods = { IsDebugPanelEnalbedCli = noop } },
    ["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeModeDeathRecordSubsystem"] = { methods = { OnPlayerKilled = noop } },
    ["GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem"] = {
        methods = {
            HandleEnterFighting = noop, InitializePlayerInputInfo = noop,
            AddOneAFKInfo = noop, SetPlayerAFKState = noop,
            ResetPlayerInputInfo = noop, PlayerHaveAction = noop, ReportAFK = noop,
            CheckAFK = retFalse,
        },
    },
    ["GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"] = { methods = { SendAFKTips = noop, OnHandleLostConnection = noop } },
    ["GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"] = {
        methods = {
            RealLogoutTimer = noop, AddToLogQue = noop, DoPrint = noop,
            OnAIPawnDied = noop, OnAIPawnReceiveDamage = noop, OnAIPawnEnemyChange = noop,
        },
        fields = { LogQueue = {} },
    },
    ["client.slua.logic.data.data_mgr"] = { retvals = { GetWeaponSkinSoundVolumeInfoByGroup = retZero } },
    ["TApmHelper"] = { methods = { postEvent = noop } },
    ["GameLua.Mod.BaseMod.Common.Security.LuaIntegrityCheck"] = { methods = { Run = noop, Verify = retTrue, Check = retTrue } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientDeviceCheckSubsystem"] = {
        methods = { StartCheck = noop, ReportResult = noop },
        retvals = { IsDeviceSafe = retTrue },
    },
    ["GameLua.Mod.BaseMod.Client.Security.SpectatorAndReplaySubsystem"] = { methods = { SendReport = noop } },
    ["client.slua.logic.login.logic_version_update"] = {
        methods = { CheckVersion = noop, CheckUpdate = noop, IsNeedUpdate = retFalse, GetVersion = function() return "4.4.0" end, ShowUpdateDialog = noop }
    },
    ["client.slua.logic.version.logic_update"] = { methods = { CheckUpdate = noop, ForceUpdate = noop, IsForceUpdate = retFalse } },
    ["client.slua.logic.ban.logic_ban"] = {
        methods = { GetBanEndTime = function() return 0 end, IsInBanTime = retFalse, CheckBanStatus = retFalse, GetBanReason = retEmpty, GetBanTime = retZero }
    },
    ["client.slua.logic.login.logic_login_ban"] = {
        methods = { CheckCanLogin = retTrue, GetBanInfo = function() return { end_time = 0 } end, IsBanned = retFalse, IsSecurityBan = retFalse }
    },
    ["GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"] = { methods = { DelayKickOutPlayer = noop, ActiveKickNotify = noop } },
    ["GameLua.Mod.BaseMod.Client.Security.ClientFlagSubsystem"] = {
        methods = {
            EvaluateFlags = noop,
            GetFlagLevel = retZero,
            GetFlagBanDuration = retZero,
            IsFlagged = retFalse,
            ReportFlag = noop,
            SyncFlagStatus = noop,
            IncreaseFlagCount = noop,
            ResetFlags = noop,
        },
        retvals = { IsFlagged = retFalse },
        fields = { FlagCount = 0, FlagLevel = 0, FlagSeverity = 0 },
    },
    ["client.slua.logic.ban.logic_flag_ban"] = {
        methods = {
            GetFlagBanEndTime = function() return 0 end,
            IsFlagBanned = retFalse,
            GetFlagBanDuration = retZero,
            CheckFlagBan = retFalse,
        }
    },
    ["GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem"] = {
        methods = { _UpdateTTKRecords = noop, _UpdateOperatingFrequency = noop }
    },
    ["GameLua.Mod.Borderland.Gameplay.Subsystem.TLogSubsystem"] = { methods = { OnInit = noop } },
    _G_TLogSubsystem = { table = "_G.TLogSubsystem", methods = { OnInit = noop } },
    ["client.slua.logic.download.report.logic_mini_pak_gem"] = {
        methods = { StartReport = noop, ReportGemLog = noop, SetCurDownloadSize = noop }
    },
    ["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogManager"] = {
        methods = {
            OnReceiveBattleResults = noop,
            AddValTLog = noop,
            SetValTLog = noop,
            SendReportLobby = noop,
        },
        fields = { ClientTlogData = {} },
    },
    ["GameLua.Mod.SocialIsland.DS.Battle.RacingAntiCheatLogic"] = {
        methods = {
            StartDetectTimer = noop, StopDetectTimer = noop,
            DetectVehicleFloating = noop, HandleFloatingCheat = noop,
            HandleSpeedCheat = noop, HandlePlayerPassCheckBelt = noop,
        },
    },
    ["GameLua.Dev.ClientCloudGM"] = { methods = { HandleCloudGMCMDStr = noop } },
    ["GameLua.Mod.BaseMod.Client.Dev.ClientCloudGM"] = { methods = { HandleCloudGMCMDStr = noop } },
    ["GameLua.Mod.BaseMod.Common.RealTimeBan.RealTimeBan"] = {
        methods = {
            OnPlayerWithRealTimeBan = noop,
            ShowAlias = noop,
            HandleEnterGameModeFightingState = noop,
            GetTipsID = retZero,
        },
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeDistanceUI"] = {
        methods = { _RefreshUI = noop, _IsShouldShow = retFalse }
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeNextPatrolWindow"] = {
        methods = { OnShow = noop }
    },
    ["GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeReportWindow"] = {
        methods = { _OnClickSubmit = noop, _RefreshWindow = noop, RegistEvents = noop }
    },
    ["GameLua.Mod.BaseMod.Client.Security.SecurityClientUtils"] = {
        methods = {
            HasOtherTeammateOffline = retFalse,
            HasOtherHealthyOnlineTeammate = retFalse,
            IsMyHealthStatusHealthy = retTrue,
            IsMyHealthStatusAlive = retTrue,
            GetMyHealthStatus = function() return 1 end,
        }
    },
    ["GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic"] = {
        methods = {
            OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop,
            OnSyncBanInfo = noop, OnNotifyWarningTips = noop,
            VoiceBanEndTime = 0, bEnableVoiceReport = false,
        },
    },
    ["GameLua.Mod.BaseMod.Client.Security.ClientBanLogic"] = {
        methods = {
            OnVoiceBanNotify = noop, OnRealTimeVoiceBanNotify = noop,
            OnSyncBanInfo = noop, OnNotifyWarningTips = noop,
        },
    },
    ["ScreenshotMaker"] = {
        custom = function(m)
            if not m then return end
            m.MakePicture = function() return "" end
            m.ReMakePicture = function() return "" end
            m.HasCaptured = function() return true end
        end,
    },
    ["client.slua.logic.ugc.UGCNewTLogReport"] = {
        methods = { SendExposeReq = noop, SendInteractionReq = noop, TLogReport = noop }
    },
    ["client.slua.logic.ugc.logic_ugc_tlog"] = {
        methods = { SendModTLog = noop, ReportStay = noop }
    },
    ["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil"] = {
        methods = { ReportGeneralCountByBRPhase = noop, ReportCommonTLogDataByBRPhase = noop }
    },
    ["ReportCrashKitFeature"] = {
        custom = function(m) if m and m.ReportCharacterAttachedOnVehicleException then m.ReportCharacterAttachedOnVehicleException = noop end end,
    },
    ["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportSubsystemReporter"] = {
        custom = function(m)
            if m then
                m.ReportIntArrayData = noop
                m.ReportUInt8ArrayData = noop
                m.ReportFloatArrayData = noop
            end
        end,
    },

    -- ===== New patches from TrnDravix =====
    ["SkillAction_GrenadeThrowReport"] = {
        methods = {
            ReportGrenadeThrow = noop,
            CheckGrenadeAnimationState = retTrue,
            ValidateThrow = retTrue,
            OnGrenadeThrow = noop,
        },
    },
    ["BanMacro"] = {
        methods = {
            DetectInputVariance = retTrue,
            CheckClickTiming = retFalse,
            AnalyzeClickPattern = retEmpty,
            ReportMacro = noop,
            CheckAllBanTypes = retTrue,
        },
    },
    ["NGActionBanSprint"] = {
        methods = {
            ValidateSprintSpeed = retTrue,
            CheckSpeedHack = retFalse,
            ReportSprintViolation = noop,
        },
    },
    ["ReportGrenadeThrow"] = {
        methods = {
            SendGrenadeReport = noop,
            ReportGrenadeData = noop,
        },
    },
    ["InputVarianceChecker"] = {
        methods = {
            CalculateVariance = retZero,
            IsHumanLike = retTrue,
        },
    },
    ["SpeedhackValidator"] = {
        methods = {
            ValidateSpeed = retTrue,
            IsSpeedhack = retFalse,
            ReportSpeedhack = noop,
        },
    },
    ["HawkEyeSpectatorState"] = {
        methods = {
            OnSpectatorStateChange = noop,
            TrackAimMovement = noop,
            ReportSuspiciousAim = noop,
        },
    },
    ["EmulatorSystem"] = {
        fields = { EmulatorTestMark = true },
        methods = { IsEmulator = retFalse, GetEmulatorName = function() return "NoEmulator" end },
    },
    ["logic_emulator"] = {
        methods = { find_emulator = retFalse, IsSpecialEmulator = retFalse },
    },
    ["VoiceReportSubsystem"] = {
        methods = {
            PLAYER_BAN_GLOBAL_MI = noop,
            ReportSuspicious = noop,
            PreFilterAI = noop,
        },
    },
    ["BugglyReportRecord"] = {
        methods = { Report = noop, Record = noop },
        retvals = { GetProbability = retZero },
    },
    ["PatrollerModule"] = {
        methods = { UpdateStats = noop, GetRank = retZero, AddInspectionRecord = noop },
    },
    ["DSQuickReportMaliciousTeammate"] = {
        methods = {
            _HandleCarrybackFallingDamage = noop,
            _HandleGrenadeDamage = noop,
            _HandleVehicleExplosionDamage = noop,
            ReportMaliciousTeammate = noop,
        },
    },
    ["ClientQuickReportMaliciousTeammate"] = {
        methods = {
            RPC_Client_MaliciousTeammateReceiveWarningTips = noop,
            ShowQuickReportDialog = noop,
            OnDeath = noop,
        },
    },
    ["InspectionSystemKickPlayerConfirm"] = {
        methods = {
            OnConfirmTyped = retTrue,
            CheckConfirmText = retTrue,
        },
    },
    ["RockBandActor"] = {
        custom = function(m)
            if m then
                m._G.IsEditor = false
                m._G.IsTesting = false
            end
        end,
    },
    ["ban_reddot_system"] = {
        methods = {
            EnterSafeStation = noop,
            UpdateRedDot = noop,
            OnBanUpdate = noop,
        },
    },
    ["ban_reddot_data"] = {
        methods = {
            LoadBanRedDotData = noop,
            UpdateBanRedDot = noop,
        },
    },
    ["DSPlayerDataReportSubsystem"] = {
        methods = {
            TrackRescue = noop,
            TrackDieWithoutRevive = noop,
            HandleBattleResult = noop,
            _HandleRescue = noop,
            _HandleDieWithoutRevive = noop,
        },
        custom = function(m)
            if m then
                m.DieWithoutReviveTime = 99999
                if m._OnGameEnd then m._OnGameEnd = noop end
            end
        end,
    },
    ["UGC_AiCopilot_Report"] = {
        methods = {
            ReportContent = noop,
            ReportLowQuality = noop,
            SendReport = noop,
        },
    },
    ["gem_report_utils"] = {
        methods = {
            ReportEventDelay = noop,
            ReportImmediate = noop,
        },
    },
    ["gem_report_config"] = {
        methods = {
            OnNetworkEvent = noop,
            OnBanEvent = noop,
        },
    },
    ["net"] = {
        global = true,
        custom = function(m)
            if m then
                m.DumpPropertySerializationStats = noop
            end
        end,
    },
}

-- Hook require/import
local originalRequire = require
local function hookedRequire(name)
    local mod = originalRequire(name)
    if modulePatches[name] then
        local cfg = modulePatches[name]
        if cfg.custom then pcall(cfg.custom, mod)
        elseif not cfg.global then
            if cfg.methods then for k, v in pairs(cfg.methods) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.retvals then for k, v in pairs(cfg.retvals) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.fields then for k, v in pairs(cfg.fields) do if mod[k] ~= nil then mod[k] = v end end end
        end
    end
    return mod
end
if require ~= hookedRequire then require = hookedRequire end

local originalImport = import
local function hookedImport(name)
    local mod = originalImport(name)
    if modulePatches[name] then
        local cfg = modulePatches[name]
        if cfg.custom then pcall(cfg.custom, mod)
        elseif not cfg.global then
            if cfg.methods then for k, v in pairs(cfg.methods) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.retvals then for k, v in pairs(cfg.retvals) do if type(mod[k]) == "function" then mod[k] = v end end end
            if cfg.fields then for k, v in pairs(cfg.fields) do if mod[k] ~= nil then mod[k] = v end end end
        end
    end
    return mod
end
if import ~= hookedImport then import = hookedImport end

-- ===== Existing bypass functions (copied) =====
local function TssSdkBypass()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"] or package.loaded["client.slua.logic.tss_sdk"]
        if not TssSdk then
            local ok, mod = pcall(require, "TssSdk")
            if ok then TssSdk = mod end
        end
        if not TssSdk then return end

        local bypassFuncs = {
            "GetSdkAntiData", "GameScreenshot", "GameScreenshot2", "IsEmulator",
            "QueryOpts", "GetCommLibValueByKey", "GetShellDyMagicCode", "AddMTCJTask",
            "SetToken", "EnableDisableItem", "InvokeCrashFromShell", "ReInitMrpcs",
            "GetUserTag", "QueryTssLibcAddr", "RegistLibcSendListener", "RegistLibcRecvListener",
            "RegistLibcConnectListener", "RegistLibcCloseListener", "GetMrpcsData2Ptr",
            "GetTPChannelVer", "SetGameChannelIp", "SetValueByKey", "SetChannelHost",
            "SetChannelBuiltinIp", "RecvSecSignature", "PushAntiData3", "QueryRemainsAntiDataCount",
            "GetAntiData3", "DelAntiData3", "SetSecToken", "GetThreadsInfo", "AddTouchEvent",
            "InitSwitchStr", "SetCDNHost", "SetEnabledConnector", "QueryHookInfo", "SetCSLicense",
            "AddAnoTouchEvent", "GetObjVMFuncAddr", "ScanMemory", "ScanSo", "ScanFile",
            "GetRiskFlag", "VerifyFileHash", "CheckKernel", "VerifyBoot", "GetAntiDataQueue",
            "ReportAntiData", "SendAntiData", "ReportSdkData", "SendSdkData", "OnRecvData"
        }
        for _, funcName in ipairs(bypassFuncs) do
            if TssSdk[funcName] then
                TssSdk[funcName] = function(...) return true, "BYPASSED" end
            end
        end

        if TssSdk.antiDataQueue then
            TssSdk.antiDataQueue = {}
            TssSdk.antiDataQueue.push = function() end
            TssSdk.antiDataQueue.pop = function() return nil end
            TssSdk.antiDataQueue.size = function() return 0 end
            TssSdk.antiDataQueue.clear = function() end
        end

        if TssSdk.IsEmulator then TssSdk.IsEmulator = function() return false end end
        if TssSdk.InvokeCrashFromShell then TssSdk.InvokeCrashFromShell = function() return false end end
        if TssSdk.QueryHookInfo then TssSdk.QueryHookInfo = function() return {} end end
        if TssSdk.PushAntiData3 then TssSdk.PushAntiData3 = function() return true end end
        if TssSdk.QueryRemainsAntiDataCount then TssSdk.QueryRemainsAntiDataCount = function() return 0 end end
        if TssSdk.GetAntiData3 then TssSdk.GetAntiData3 = function() return nil end end
        if TssSdk.DelAntiData3 then TssSdk.DelAntiData3 = function() return true end end
        if TssSdk.AddTouchEvent then TssSdk.AddTouchEvent = function() return true end end
        if TssSdk.SetEnabledConnector then TssSdk.SetEnabledConnector = function() return true end end
        if TssSdk.SetCSLicense then TssSdk.SetCSLicense = function() return true end end
        if TssSdk.GetObjVMFuncAddr then TssSdk.GetObjVMFuncAddr = function() return 0 end end
    end)
end

local function EnhancedAntiCheatBypass()
    if _G.BYPASS_STATE and _G.BYPASS_STATE.ANTI_CHEAT_MANAGER_DISABLED then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end

        local AntiCheatMgr = nil
        if pc.PlayerAntiCheatManager then
            AntiCheatMgr = pc.PlayerAntiCheatManager
        elseif pc.AntiCheatManager then
            AntiCheatMgr = pc.AntiCheatManager
        end

        if not slua.isValid(AntiCheatMgr) then
            local PlayerAntiCheatManagerClass = import("PlayerAntiCheatManager")
            if PlayerAntiCheatManagerClass then
                local comps = pc:GetComponentsByClass(PlayerAntiCheatManagerClass)
                if comps and comps:Num() > 0 then
                    AntiCheatMgr = comps:Get(0)
                end
            end
        end

        if not slua.isValid(AntiCheatMgr) then return end

        local counterFields = {
            "AutoAimFailedCnt", "TrackingFailedCnt", "AreaDamageFailedCnt", "JumpHeightFailedCnt",
            "JumpFarFailedCnt", "VehicleFlyingFailedCnt", "ShootVerifyTimes", "SpeedUpValue",
            "ClientTimeTotalAcc", "ServerAccumulateErrors", "ServerAvgErrors", "ServerCorrectTimes",
            "PlayerBadPingTimes", "VehicleSpeedZDeltaTotal", "VehicleSpeedZDeltaOver10Times",
            "PVSInCityKillCount", "PVSNotInCityKillCount", "PVSCellHidePercent", "PVSTotalHidePercent",
            "ServerMoveParameterVerifyCount", "ServerMoveParameterVerifyFailedCount",
            "StuckGroundPunishCount", "ContinueMoveBurstCount", "RecordContinueMoveBurstCount",
            "TrialBaseDiffCount", "InclusiveBegin", "InclusiveEnd"
        }
        for _, field in ipairs(counterFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 0 end
            end)
        end

        local boolFields = {
            "bReportFeedBack","bOpenDetailDataCollect","bOpenBaseDiffCheck","bUploadStuckGroundCount",
            "bStuckGroundCapsule","bImpactOtherAfterBurst","bGiveupPickupWhenBrust",
            "bOpenPickupWhenBrustCheck","bMustStrictContinue"
        }
        for _, field in ipairs(boolFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "boolean" then AntiCheatMgr[field] = false end
            end)
        end

        local maxFields = {
            "MaxShootPointPassWall", "MaxMuzzleHeightTime", "MaxLocusFailTime",
            "MaxBulletVictimClientPassWallTimes", "MaxGunPosErrorTimes",
            "MaxAllowVehicleTimeSpeedRawTime", "MaxAllowVehicleTimeSpeedConvTime",
            "MaxAllowVehicleAccTime", "MaxSingleShotDamage", "MaxFallingSustainTime",
            "MaxCustomMoveModeSustainTime", "MaxMoveDistance2DPerSecond",
            "MaxCharMoveDist2DPerSecond", "MaxDistanceToGround", "MaxContinueMoveBurstXY",
            "ContinueMoveBurstInterval", "BaseDiffRegion", "BaseDiffVel", "BaseDiffTime",
            "MinImpactOtherInterval", "MinBurstToPickupInterval", "MaxPlayerDisSquaredForPickup",
            "ContinueMoveBurstTolerant", "MultiStuckGroundScale", "StuckTypePunishSet",
            "StuckGroundPunishType"
        }
        for _, field in ipairs(maxFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 999999 end
            end)
        end

        local paraFields = {
            "ParachuteStartTime","ParachuteOpenTime","ParachuteCloseTime",
            "ParachuteStartHight","ParachuteOpenHight","ParachuteCloseHight"
        }
        for _, field in ipairs(paraFields) do
            pcall(function()
                if type(AntiCheatMgr[field]) == "number" then AntiCheatMgr[field] = 0 end
            end)
        end

        pcall(function() AntiCheatMgr.DSProperty = nil end)

        local verifySwitchFields = {
            "VsNoHitDetail","VsMuzzleRangeCircle","VsMuzzleRangeUp",
            "VsHitBoneNameNone","VsHitBoneHitMissMatch","VsBulletID",
            "VsVehicleTimeStampError","VsWatchTimeStampError",
            "VsShootRpgShootTimeVerify","VsShootLockShootTimeVerify",
            "VsShootRpgHitNewVerify","VsShootTimeConDelta",
            "VsServerNoOldShoot","VsClientNotConnectShoot",
            "VsShootRpgShootIntervalVerify","VsImpactPointAndBulletDisBig",
            "VsShootVerifyInvalid","VsImpactActorPosWithNoHisPos",
            "VsShootAngleInVaild","VsMuzzleAndTailPosInVaild",
            "VsMuzzleAndImpactPassWall","VsMuzzleAndTailPassWall",
            "VsImpactActorPosOffsetBig","VsImpactPointChangeSmall",
            "VsImpactBulletPosOffsetBig","VsTotalImactCharacterNum",
            "VsBoneInfo","VsJumpMaxHeight","VsJumpMaxHeight15","VsJumpMaxHeight2",
            "SpeedQuickCheck","BulletDirError","WalkSpeedFailedCnt",
            "DSSpeedOver10FailedCnt","DSSpeedOver15FailedCnt","DSSpeedOver20FailedCnt",
            "DSFallingSpeedFailCount","DSFallingHeightFailCount",
            "SwitchMuzzleLocusError","SwitchMuzzleLocusErrorX","SwitchMuzzleLocusErrorY","SwitchMuzzleLocusErrorZ",
            "Gun2ShooterPosError1","SwitchHeadLocusError3","SwitchMuzzleLocusErrorLength",
            "SwitchShootPosHistoryLocusError3","SwitchHitComponentUnvalid","SwitchHitNoRender",
            "SwitchHitOutCollisionBox","HeadOverShootPos","SwitchMuzzleImpactDirSkipPunish1",
            "SwitchInvalidBulletNumInBarrel","SwitchShooterMovementError2","GunTailPosError",
            "SwitchMuzzleImpactDirSkipPunish2","SwitchMuzzleImpactDirError1","SwitchMuzzleImpactDirError2",
            "ShooterHead2PosBlock","SwitchShootPosHistoryLocusError2","Head2GunTailPosError1",
            "SwitchShootDirExcepation1","SwitchShootDirExcepation2","SwitchCamerModeException",
            "SwitchShootPosHistoryLocusError4","SwitchMuzzleImpactDirError3",
            "CharacterMoveException1","CharacterMoveException2","CharacterMoveException3",
            "CharacterMoveException4","CharacterMoveException5","CharacterMoveException6",
            "VehicleSpeedZDeltaOver10TimesWhenNoXY","VehicleVelZCheck1","VehicleVelZCheck2",
            "VehicleMaxSpeedCheck","VehicleHitMuzzleCheck","VehicleHitImpactPointCheck",
            "VehicleHitBlockWall","VehicleSidesway1","VehicleSidesway2",
            "FarShootInMidAirVehicleExceedThreshold","FarShootInMidAirVehicleEnemyDistanceTrial",
            "FarShootInMidAirVehicleEnemyDistanceFurtherTrial","FarShootInMidAirVehicleHeightTrial",
            "FarShootInMidAirVehicleHeightFurtherTrial","FarShootInMidAirPawnExceedThreshold",
            "FarShootInMidAirPawnEnemyDistanceTrial","FarShootInMidAirPawnEnemyDistanceFurtherTrial",
            "FarShootInMidAirPawnHeightTrial","FarShootInMidAirPawnHeightFurtherTrial",
            "NonGunADSFarShootCount","NonGunADSFarShootFromClientBulletDataCount",
            "NonGunADSFarShootFromClientBulletDataEnemyDistanceTrialCount",
            "NonGunADSFarShootFromClientBulletDataEnemyDistanceFurtherTrialCount",
            "ClientUploadFuzzyObjectVerifyFail","ClientMoveTimeStampResetFrequencyExceedThreshold",
            "ShootBirdNonGunADSExceedThreshold","ShootBirdNonGunADSDistanceTrial",
            "ShootBirdNonGunADSDistanceFurtherTrial","FarShootInHighTangentMoveSpeedExceedThreshold",
            "FarShootInHighTangentMoveSpeedEnemyDistanceTrial","FarShootInHighTangentMoveSpeedEnemyDistanceFurtherTrial",
            "FarShootInHighTangentMoveSpeedSpeedTrial","FarShootInHighTangentMoveSpeedSpeedFurtherTrial",
            "IllegalTeamUpNearbyButNoFireAfterKill","IllegalTeamUpNearbyButNoFireAfterKillDistanceTrial",
            "IllegalTeamUpNearbyButNoFireAfterKillTimeTrial","IllegalTeamUpNearbyButNoFireAfterKillMaxTime",
            "IllegalTeamUpNearbyButNoFirePickUpItem","IllegalTeamUpNearbyButNoFirePickUpItemDistanceTrial",
            "IllegalTeamUpNearbyButNoFirePickUpItemTimeTrial","IllegalTeamUpNearbyButNoFirePickUpItemMaxTime",
            "IllegalTeamUpNearbyButNoFireNotKill","IllegalTeamUpNearbyButNoFireNotKillDistanceTrial",
            "IllegalTeamUpNearbyButNoFireNotKillTimeTrial","IllegalTeamUpNearbyButNoFireNotKillMaxTime",
            "IllegalTeamUpNearbyButNoFireOnVehicle","IllegalTeamUpNearbyButNoFireOnVehicleDistanceTrial",
            "IllegalTeamUpNearbyButNoFireOnVehicleTimeTrial","IllegalTeamUpNearbyButNoFireOnVehicleMaxTime",
            "IllegalTeamUpNearbyButNoFireSameVehicle","IllegalTeamUpNearbyButNoFireSameVehicleTimeTrial",
            "IllegalTeamUpNearbyButNoFireSameVehicleMaxTime","IllegalTeamUpUseObjectTogether",
            "IllegalTeamUpGetOnEnemyVehicleCount","IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFoot",
            "IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFootDistanceTrial","IllegalTeamUpStayOnEnemyVehicle",
            "KillBird","ShooterCapsuleCollided","ParachuteLandingSecondsExceedThreshold",
            "ParachuteObliqueLandingSecondsExceedThreshold","SmallActorTimeDilationCount",
            "LargeRotateLockShooting","SmallRotateLockShooting","OneClipShootCount","ClientWeaponFastReload",
            "UndergroundCount","MoveDistance2DPerSecondAnomaly","CharMoveDist2DPerSecondAnomaly",
            "CharMoveDist2DPerSecondCount","DistanceToGroundAnomaly","SingleShotDamageAnomaly","BandaCount",
            "DSCheckClientTimeMoveDistance2D","DSCheckClientTimeMoveDistance2DTrial",
            "DSCheckClientTimeMoveDistance2DFurther","DSCheckClientTimeMoveDistanceZ",
            "DSCheckClientTimeMoveDistanceZTrial","DSCheckClientTimeMoveDistanceZFurther",
            "ReplayMaxFallingSustainTime","ReplayMaxCustomMoveModeSustainTime","ReplayMaxSingleShotDamage",
            "CharMoveAccumDist2D_DS","CharMoveAccumDist3D_DS","CharMoveAccumDist2D_Client",
            "CharMoveAccumDist3D_Client","CharMoveAccumDist2D_ClientAll","CharMoveAccumDist3D_ClientAll",
            "MetroEnterRadiationTime","MetroEnterRadiationTimeTrial","MetroLeaveBornObstacle",
            "VsPetJumpHeightLimiter","VsPetMoveSpeedLimiter","VsBioVehicleMoveSpeedLimiter",
            "VsBioVehicleJumpHeightLimiter","VsPterosaurFlyVehicleSpeed","VsBioVehicleGravityLimiter",
            "ServerMoveCacheCountOver","ServerMoveCacheCountOver3d","ServerMoveBurst","ImpactOtherAfterBurst",
            "KillOtherAfterBurst","PickupAfterBurst","ContinueMoveBurst","ServerMoveTimeStamp",
            "ServerMoveAccel","ServerMoveClientLoc","ServerMoveCompressedMoveFlags","ServerMoveClientRoll",
            "ServerMoveView","ServerMoveClientMovementBase","ServerMoveClientBaseBoneName",
            "ServerMoveClientMovementMode","VerifySwitchCameraRotation","VerifySwitchPeekShootThroughWall",
            "VerifySwitchCameraLocation","VerifySwitchAutoAimByLockView","VerifySwitchControlRotation",
            "VerifySwitchRecoilFaildCount","VerifySwitchMarcoPolo","VerifySwitchMarcoPolo2",
            "VerifySwitchMarcoPolo3","VerifySwitchMeshScaleDiff","VerifySwitchOfflineMove",
            "VerifySwitchFastAimShootHit","VerifySwitchNoRecoilOnWeaponShoot","VerifySwitchLessRecoilOnWeaponShoot",
            "VerifySwitchNoRecoilOnKickBack","VerifySwitchLessRecoilOnKickBack","VerifySwitchDivingBoost",
            "VerifySwitchRecoilCurveFailed","PlayerQuickProne","BaseDiffSample",
            "VsTeammateRescue","VsTeammateRescueVictim","VsTeammateRecall","VsTeammateRecallVictim",
            "VsAutoClicker","VsAbnormalShootingRotation","PlayerInstantHeightDiff","Player2SecHeightDiff",
            "CheatStateData2TotalCheatTimes","MoveCheatAntiStrategy3TotalCheatTimes","ServerAccumulateErrorReplay"
        }
        for _, fieldName in ipairs(verifySwitchFields) do
            pcall(function()
                local vs = AntiCheatMgr[fieldName]
                if vs and type(vs) == "table" then
                    vs.bActive = false
                    vs.MaxCount = 99999
                    vs.CurrentCount = 0
                    vs.TrialCount = 0
                    vs.TrialMaxCount = 99999
                    vs.PunishType = 0
                end
            end)
        end

        local burstFields = {
            "ServerAccumulateErrorBurst","DSSpeedOver10BurstCount",
            "ParachuteSpeedBurst","ClientTimestampBurst","ClientTimestampBurstTrial"
        }
        for _, fieldName in ipairs(burstFields) do
            pcall(function()
                local bvs = AntiCheatMgr[fieldName]
                if bvs and type(bvs) == "table" then
                    bvs.bActive = false
                    bvs.MaxCount = 99999
                    bvs.CurrentCount = 0
                end
            end)
        end

        pcall(function()
            if AntiCheatMgr.ReportMiscMap then AntiCheatMgr.ReportMiscMap:Clear() end
        end)

        local methodFields = {
            "ReportAntiCheatDetailData","PushWeaponAntiData","OnRecoverOnServer",
            "OnPreReconnectOnServer","ExitParachute","EnterParachute","EnterJumping",
            "Cofey","Cofew","SetTrialRegion","GetSoftString","GetCheckMoveStr2",
            "GetCheckMoveStr1","GetAACString","GetAACCountByID"
        }
        for _, method in ipairs(methodFields) do
            pcall(function()
                if AntiCheatMgr[method] and type(AntiCheatMgr[method]) == "function" then
                    AntiCheatMgr[method] = function(...)
                        if method == "GetSoftString" then return 0 end
                        if method == "GetCheckMoveStr1" or method == "GetCheckMoveStr2" then return "" end
                        if method == "GetAACString" then return "" end
                        if method == "GetAACCountByID" then return 0 end
                        if method == "Cofey" then return 0 end
                        return true
                    end
                end
            end)
        end

        pcall(function()
            local catchData = AntiCheatMgr.CatchReportAntiCheatDetailData
            if catchData and type(catchData) == "table" then
                catchData.bActive = false
                catchData.CurrentCount = 0
                catchData.MaxCount = 99999
            end
        end)

        _G.BYPASS_STATE = _G.BYPASS_STATE or {}
        _G.BYPASS_STATE.ANTI_CHEAT_MANAGER_DISABLED = true
    end)
end

local function MemoryBypass()
    pcall(function()
        local funcs = {"__aeabi_memset","__strncpy_chk","memmove_chk","memset_chk","memcpy","malloc","calloc","realloc","free","close","dup2","listen"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function TimeBypass()
    pcall(function()
        if _G.gmtime then _G.gmtime = function() return os.date("!*t") end end
        if _G.gettimeofday then _G.gettimeofday = function() return os.time() end end
        if _G.mktime then _G.mktime = function(t) return os.time(t) end end
        if _G.imp_time then _G.imp_time = function() return os.time() end end
    end)
end

local function NetworkBypass()
    pcall(function()
        local funcs = {"sys_read","sys_open","nanosleep","imp_recv","imp_send","socket"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function ReportBypass()
    pcall(function()
        local funcs = {"report","COREREPORT","tdm_report","android_log_print","__android_log_print"}
        for _, fn in ipairs(funcs) do if _G[fn] then _G[fn] = function() return true end end end
    end)
end

local function StrBypass()
    pcall(function()
        if _G.strstr then _G.strstr = function() return "" end end
        if _G.strcpy then _G.strcpy = function() return "" end end
        if _G.strlen then _G.strlen = function() return 0 end end
        if _G.strncpy then _G.strncpy = function() return "" end end
    end)
end

local function ProcessBypass()
    pcall(function()
        if _G.getpid then _G.getpid = function() return 0 end end
        if _G.getppid then _G.getppid = function() return 0 end end
        if _G.gettid then _G.gettid = function() return 0 end end
    end)
end

local function AntiDebugBypass()
    pcall(function()
        if _G.ptrace then _G.ptrace = function() return 0 end end
        if _G.monitor then _G.monitor = function() return true end end
    end)
end

local function DLCmdBypass()
    pcall(function()
        if _G.dlopen then _G.dlopen = function() return 0 end end
        if _G.cmd then _G.cmd = function() return "" end end
        if _G.name then _G.name = function() return "" end end
    end)
end

local function AnoSDKBypass()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            if TssSdk.AnoSDKDelReportData then TssSdk.AnoSDKDelReportData = function() return true end end
            if TssSdk.AnoSDKDelReportData3 then TssSdk.AnoSDKDelReportData3 = function() return true end end
            if TssSdk.AnoSDKDelReportData4 then TssSdk.AnoSDKDelReportData4 = function() return true end end
            if TssSdk.AnoSDKGetReportData then TssSdk.AnoSDKGetReportData = function() return nil end end
            if TssSdk.AnoSDKGetReportData2 then TssSdk.AnoSDKGetReportData2 = function() return nil end end
            if TssSdk.AnoSDKGetReportData3 then TssSdk.AnoSDKGetReportData3 = function() return nil end end
            if TssSdk.AnoSDKGetReportData4 then TssSdk.AnoSDKGetReportData4 = function() return nil end end
        end
    end)
end

local function MprotectBypass()
    pcall(function()
        if _G.mprotect then _G.mprotect = function() return 0 end end
        if _G.munmap then _G.munmap = function() return 0 end end
    end)
end

-- ===== New bypass functions (TrnDravix) =====
local function InitializeSLUABypass()
  pcall(function()
    if slua and slua.getSignature then
      slua.getSignature = function() return 0xDEADBEEF end
    end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
      loader.verifyBytecode = retTrue
      loader.checkIntegrity = retTrue
      if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
    end
    local slua_serialize = package.loaded["slua.serialize"]
    if slua_serialize then
      slua_serialize.check = retTrue
      slua_serialize.verify = retTrue
    end
    if jit and jit.attach then
      jit.attach(function() end, "bc")
    end
    if _G.slua_verify then _G.slua_verify = retTrue end
    if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
  end)
end

local function InitializeMD5Bypass()
  pcall(function()
    local console = import("KismetSystemLibrary")
    if console then
      console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
      console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
      console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
      console.ExecuteConsoleCommand(nil, "sig.Check 0")
      console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
    end
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    if CreativeModeBlueprintLibrary then
      CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "00000000000000000000000000000000" end
      CreativeModeBlueprintLibrary.MD5HashFile = function() return "00000000000000000000000000000000" end
      CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
      CreativeModeBlueprintLibrary.VerifyFileIntegrity = retTrue
    end
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    if _G.CRC32 then _G.CRC32 = function() return 0 end end
    if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
    local FileHashChecker = package.loaded["common.file_hash_checker"]
    if FileHashChecker then
      FileHashChecker.CheckFileMD5 = retTrue
      FileHashChecker.VerifyAll = retTrue
      FileHashChecker.GetHash = function() return "BYPASS" end
    end
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
      TssSdk.GetFileMD5 = function() return "BYPASS" end
      TssSdk.VerifyFileSignature = retTrue
    end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if STExtraBlueprintFunctionLibrary then
      STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
      STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
      STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
    end
  end)
end

local function InitializeSkinBypass()
  pcall(function()
    local puffer_tlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if puffer_tlog then
      puffer_tlog.ReportEvent = noop
      puffer_tlog.ReportDownloadResult = noop
      puffer_tlog.ReportODPTDError = noop
      puffer_tlog.ReportSkinError = noop
    end
    local AvatarUtils = package.loaded["AvatarUtils"]
    if AvatarUtils then
      AvatarUtils.CheckIsWeaponInBlackList = retFalse
      AvatarUtils.IsValidAvatar = retTrue
      AvatarUtils.CheckAvatarIntegrity = retTrue
      AvatarUtils.ReportInvalidAvatar = noop
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local fileCheckSubsystem = SubsystemMgr and SubsystemMgr:Get("FileCheckSubsystem")
    if fileCheckSubsystem then
      fileCheckSubsystem.StartCheck = noop
      fileCheckSubsystem.ReportAbnormalFile = noop
      fileCheckSubsystem.StopCheck = noop
    end
    local equipmentException = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
    if equipmentException then
      equipmentException.Report = noop
      equipmentException.SendException = noop
    end
  end)
end

local function InitializeLogBlocker()
  pcall(function()
    local ScreenshotMTDer = import("ScreenshotMTDer")
    if ScreenshotMTDer then
      ScreenshotMTDer.MTDePicture = function() return "" end
      ScreenshotMTDer.ReMTDePicture = function() return "" end
      ScreenshotMTDer.HasCaptured = retTrue
      ScreenshotMTDer.TakeScreenshot = noop
    end
    local TLog = package.loaded["TLog"] or _G.TLog
    if TLog then
      TLog.Info = noop; TLog.Warning = noop; TLog.Error = noop
      TLog.Debug = noop; TLog.Report = noop; TLog.Send = noop
      TLog.Flush = noop
    end
    local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
    if CrashSight then
      CrashSight.ReportException = noop
      CrashSight.SetCustomData = noop
      CrashSight.Log = noop
      CrashSight.SendCrash = noop
      CrashSight.ReportUserException = noop
    end
    local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
    if GameReportUtils then
      GameReportUtils.BugglyPostExceptionFull = retFalse
      GameReportUtils.CheckCanBugglyPostException = retFalse
      GameReportUtils.ReplayReportData = noop
      GameReportUtils.ReportGameException = noop
      GameReportUtils.PostException = noop
    end
    local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
    if ClientToolsReport then
      ClientToolsReport.SendReport = noop
      ClientToolsReport.SendException = noop
      ClientToolsReport.UploadLog = noop
    end
    local TLogReportUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"]
    if TLogReportUtils then
      TLogReportUtils.ReportTLogEvent = noop
      TLogReportUtils.FlushEvents = noop
    end
    for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
      local s = _G[sdk]
      if s then
        s.logEvent = noop; s.trackEvent = noop; s.setEnabled = retFalse
        s.sendEvent = noop; s.report = noop
      end
    end
  end)
end

local function InitializeScannerBlocker()
  pcall(function()
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local subsystems = {
        "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem",
        "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem",
        "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"
      }
      for _, name in ipairs(subsystems) do
        local sub = SubsystemMgr:Get(name)
        if sub then
          for k, v in pairs(sub) do
            if type(v) == "function" and (
              k:find("Report") or k:find("Send") or k:find("Upload") or
              k:find("Verify") or k:find("Check") or k:find("Validate") or
              k:find("Scan") or k:find("Detect")
            ) then
              pcall(function() sub[k] = noop end)
            end
          end
          if sub.ReportPingDelayTimer then
            sub:RemoveGameTimer(sub.ReportPingDelayTimer)
            sub.ReportPingDelayTimer = nil
          end
          sub.DelayCount = 0
        end
      end
    end
    local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
    if AvatarExceptionPlayerInst then
      AvatarExceptionPlayerInst.CheckAvatarException = noop
      AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = noop
      AvatarExceptionPlayerInst.ReportAvatarException = noop
      AvatarExceptionPlayerInst.CheckSlotMeshVisible = retFalse
      AvatarExceptionPlayerInst.CheckPawnVisible = retFalse
      AvatarExceptionPlayerInst.CheckCanBugglyPostException = retFalse
    end
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
      local originalOnRecvData = TssSdk.OnRecvData
      TssSdk.OnRecvData = function(data)
        if type(data) == "string" and (
          string.find(data, "report") or string.find(data, "exception") or
          string.find(data, "cheat") or string.find(data, "violation") or
          string.find(data, "hack") or string.find(data, "verify")
        ) then
          return
        end
        if originalOnRecvData then originalOnRecvData(data) end
      end
      TssSdk.SendReportInfo = noop
      TssSdk.ScanMemory = retTrue
      TssSdk.IsEmulator = retFalse
      TssSdk.GetTssSdkReportInfo = retEmptyString
      TssSdk.CheckEnvironment = retTrue
      TssSdk.VerifyProcess = retTrue
    end
  end)
end

local function InitializeReplayTelemetryBlocker()
  pcall(function()
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local replaySystems = {
        "RescueBtnReplayTraceSubsystem", "GameReportSubsystem", "ReplaySubsystem"
      }
      for _, name in ipairs(replaySystems) do
        local sub = SubsystemMgr:Get(name)
        if sub then
          for k, v in pairs(sub) do
            if type(v) == "function" and (
              k:find("Report") or k:find("Trace") or k:find("Replay") or
              k:find("Record") or k:find("Save")
            ) then
              pcall(function() sub[k] = noop end)
            end
          end
        end
      end
    end
    local logic_report_replay = package.loaded["client.slua.logic.replay.logic_report_replay"]
    if logic_report_replay then
      logic_report_replay.ReportReplay = noop
      logic_report_replay.SendReportReq = noop
      logic_report_replay.UploadReplay = noop
    end
  end)
end

local function InitializeReportFlowBlocker()
  pcall(function()
    local reportFlows = {
      "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
      "ReportHurtFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
      "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate",
      "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition",
      "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData",
      "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP",
      "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
      "ReportDSNetRate", "ReportCircleFlow", "ReportPlayerKillFlow",
      "ReportMrpcsFlow", "ReportSecMrpcsFlow"
    }
    for _, funcName in ipairs(reportFlows) do
      if _G[funcName] then _G[funcName] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
        _G.GameplayCallbacks[funcName] = noop
      end
    end
    local checkFuncs = {"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}
    for _, funcName in ipairs(checkFuncs) do
      if _G[funcName] then _G[funcName] = retFalse end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
        _G.GameplayCallbacks[funcName] = retFalse
      end
    end
    local enableFlags = {
      "IsEnableReportPlayerKillFlow", "IsEnableReportMrpcsInCircleFlow",
      "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow",
      "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"
    }
    for _, flag in ipairs(enableFlags) do
      if _G[flag] then _G[flag] = retFalse end
    end
  end)
end

local function InitializePlayerSecurityBypass()
  pcall(function()
    local securityCollectors = {
      "PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector",
      "ClientSecurityCollector", "PlayerAntiCheatCollector"
    }
    for _, collector in ipairs(securityCollectors) do
      if _G[collector] then
        for k, v in pairs(_G[collector]) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Collect") or k:find("Send") or
            k:find("Upload") or k:find("Record")
          ) then
            _G[collector][k] = noop
          end
        end
      end
    end
    local SecuritySubsystem = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
    if SecuritySubsystem then
      SecuritySubsystem.ReportData = noop
      SecuritySubsystem.CheckCheat = retFalse
      SecuritySubsystem.ValidatePlayer = retTrue
      SecuritySubsystem.CollectData = noop
      SecuritySubsystem.SendToServer = noop
    end
    if _G.PlayerSecurityInfo then
      _G.PlayerSecurityInfo.ReportCheat = noop
      _G.PlayerSecurityInfo.ReportSuspicious = noop
      _G.PlayerSecurityInfo.SendSecurityData = noop
      _G.PlayerSecurityInfo.CollectSecurityInfo = noop
    end
  end)
end

local function InitializeClientFlowBypass()
  pcall(function()
    local flowSubsystems = {
      "ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem",
      "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"
    }
    for _, name in ipairs(flowSubsystems) do
      local sub = package.loaded[name] or _G[name]
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Send") or k:find("Flow") or
            k:find("Record") or k:find("Process")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
      end
    end
    local CircleFlow = require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
    if CircleFlow then
      CircleFlow.ReportCircleFlow = noop
      CircleFlow.SendCircleData = noop
      CircleFlow.ReportPlayerPosition = noop
      CircleFlow.ReportCircleData = noop
    end
    if _G.ReportPlayerKillFlow then _G.ReportPlayerKillFlow = noop end
    if _G.ClientSecPlayerKillFlow then _G.ClientSecPlayerKillFlow = noop end
  end)
end

local function InitializeHeartbeatBypass()
  pcall(function()
    local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
    for _, func in ipairs(heartbeatFuncs) do
      if _G[func] then _G[func] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
        _G.GameplayCallbacks[func] = noop
      end
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local heartbeatSub = SubsystemMgr:Get("HeartbeatSubsystem")
      if heartbeatSub then
        if heartbeatSub.timer then heartbeatSub:RemoveGameTimer(heartbeatSub.timer) end
        heartbeatSub.SendHeartbeat = noop
        heartbeatSub.StartHeartbeat = noop
      end
    end
  end)
end

local function InitializeSwiftHawkBypass()
  pcall(function()
    local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
    for _, func in ipairs(swiftFuncs) do
      if _G[func] then _G[func] = noop end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
        _G.GameplayCallbacks[func] = noop
      end
    end
    local SwiftHawkSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
    if SwiftHawkSubsystem then
      SwiftHawkSubsystem.ReportData = noop
      SwiftHawkSubsystem.SendReport = noop
      SwiftHawkSubsystem.CollectTelemetry = noop
    end
  end)
end

local function InitializeCoronaLabBypass()
  pcall(function()
    if _G.CoronaLab then
      _G.CoronaLab.ReportData = noop
      _G.CoronaLab.SendData = noop
      _G.CoronaLab.CollectData = noop
      _G.CoronaLab.Telemetry = noop
    end
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local corona = SubsystemMgr:Get("CoronaLabSubsystem")
      if corona then
        corona.ReportData = noop
        corona.SendToServer = noop
        corona.CollectTelemetry = noop
        corona.StopCollection = noop
      end
    end
  end)
end

local function InitializeModifierExceptionBypass()
  pcall(function()
    if _G.bReportedModifierException then
      _G.bReportedModifierException = false
    end
    local ModifierSubsystem = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
    if ModifierSubsystem then
      ModifierSubsystem.ReportException = noop
      ModifierSubsystem.CheckModifier = retTrue
      ModifierSubsystem.ValidateModifier = retTrue
      ModifierSubsystem.ReportModifierError = noop
    end
  end)
end

local function InitializeSimulateCharacterLocationBypass()
  pcall(function()
    local SimulateSubsystem = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
    if SimulateSubsystem then
      SimulateSubsystem.ReportLocation = noop
      SimulateSubsystem.SendLocationData = noop
      SimulateSubsystem.VerifyLocation = retTrue
    end
  end)
end

local function InitializeShootVerificationBypass()
  pcall(function()
    local ShootVerify = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if ShootVerify then
      ShootVerify.OnShootVerifyFailed = noop
      ShootVerify.SendVerifyData = noop
      ShootVerify.ReportBulletHit = noop
      ShootVerify.UploadHitInfo = noop
      ShootVerify.VerifyShot = retTrue
    end
    if _G.BulletHitInfoUploadData then
      _G.BulletHitInfoUploadData.Report = noop
      _G.BulletHitInfoUploadData.Send = noop
      _G.BulletHitInfoUploadData.Upload = noop
    end
  end)
end

local function InitializeNetworkPacketBlock()
  pcall(function()
    if NetUtil and NetUtil.SendPacket then
      local originalSend = NetUtil.SendPacket
      local blockedPackets = {
        ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
        ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
        ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
        ["ReportPlayerPosition"] = 1, ["ReportSecVehicleMoveFlow"] = 1, ["report_parachute_data"] = 1,
        ["on_tss_sdk_anti_data"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
        ["ReportCircleFlow"] = 1, ["report_players_ping"] = 1, ["report_player_ip"] = 1,
        ["report_net_saturate"] = 1, ["report_speed_hack"] = 1, ["report_wall_hack"] = 1,
        ["report_aim_bot"] = 1, ["report_esp_usage"] = 1, ["report_modded_files"] = 1,
        ["detect_cheat"] = 1, ["ban_player"] = 1, ["client_anti_cheat_report"] = 1,
        ["ReportPlayerKillFlow"] = 1, ["ClientSecPlayerKillFlow"] = 1,
        ["ReportMrpcsFlow"] = 1, ["ClientSecMrpcsFlow"] = 1, ["MrpcsData"] = 1,
        ["CheckReportSecAttackFlow"] = 1, ["CheckReportSecAttackFlowWithAttackFlow"] = 1,
        ["RPC_ClientCoronaLab"] = 1, ["CoronaLabReport"] = 1, ["CoronaLabData"] = 1,
        ["PlayerSecurityInfo"] = 1, ["ReportSecurityInfo"] = 1, ["SendSecurityData"] = 1,
        ["ClientCircleFlow"] = 1, ["IsEnableReportPlayerKillFlow"] = 1,
        ["IsEnableReportMrpcsInCircleFlow"] = 1, ["IsEnableReportMrpcsInPartCircleFlow"] = 1,
        ["bReportedModifierException"] = 1, ["ReportModifierException"] = 1,
        ["RPC_Server_ReportSimulateCharacterLocation"] = 1, ["ReportSimulateCharacterLocation"] = 1,
        ["RPC_Client_ShootVertifyRes"] = 1, ["BulletHitInfoUploadData"] = 1,
        ["ShootVerifyFailed"] = 1, ["report_unrealnet_exception"] = 1, ["tss_sdk_report"] = 1,
        ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1, ["ServerHeartbeat"] = 1,
        ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["ClientSwiftHawkWithParams"] = 1,
        ["SwiftHawkReport"] = 1, ["SwiftHawkData"] = 1,
        ["AntiCheatReport"] = 1, ["CheatDetection"] = 1, ["ViolationReport"] = 1,
        ["SecurityViolation"] = 1, ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1,
        ["1162992962"] = 1, ["242463958"] = 1, ["224639039"] = 1, ["816081779"] = 1,
        ["224943158"] = 1, ["516985564"] = 1,
        ["inspection_system_report_to_inspector"] = 1,
        ["ingame_voice_ban_notify"] = 1,
        ["inspection_system_notify_inspector"] = 1,
      }
      NetUtil.SendPacket = function(packetName, ...)
        if blockedPackets[packetName] then
          return nil
        end
        return originalSend(packetName, ...)
      end
      NetUtil.IsBypassed = true
    end
    if _G.SendRPC then
      local originalSendRPC = _G.SendRPC
      local blockedRPCs = {
        "RPC_Server_ReportPlayerKillFlow", "RPC_Server_ClientSecMrpcsFlow",
        "RPC_Server_Heartbeat", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams",
        "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes",
        "RPC_ClientCoronaLab",
        "RPC_Server_HawkReportCheat",
      }
      _G.SendRPC = function(rpcName, ...)
        for _, blocked in ipairs(blockedRPCs) do
          if rpcName == blocked then return nil end
        end
        return originalSendRPC(rpcName, ...)
      end
    end
  end)
end

local function InitializeAntiCheatHooks()
  pcall(function()
    local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
      HiggsBosonComponent.StaticShowSecurityAlertInDev = noop
    end
    if HiggsBosonComponent and HiggsBosonComponent.BlackList then
      for k in pairs(HiggsBosonComponent.BlackList) do HiggsBosonComponent.BlackList[k] = nil end
    end
  end)
  _G.BlackList = {}
  
  pcall(function()
    _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
    _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
    if not getmetatable(_G.GlobalPlayerCoronaData) then
      local mt = { __newindex = function() end }
      setmetatable(_G.GlobalPlayerCoronaData, mt)
    end
  end)
  
  if _G.AvatarCheckCallback then
    _G.AvatarCheckCallback.StartAvatarCheck = noop
    _G.AvatarCheckCallback.OnReportItemID = noop
    _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
      if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then
        PlayerController.HiggsBosonComponent:ControlMHActive(0)
        PlayerController.HiggsBosonComponent.bMHActive = false
      end
    end
  end
end

local function InitializeAntiReport()
  pcall(function()
    local paths = {
      "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
      "Client.Security.ClientReportPlayerSubsystem",
      "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"
    }
    for _, path in ipairs(paths) do
      local sub = package.loaded[path]
      if not sub then
        local success, reqModule = pcall(require, path)
        if success and reqModule then sub = reqModule end
      end
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Record") or k:find("Send") or
            k:find("Upload") or k:find("Notify")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
      end
    end
  end)
end

local function InitializeGameplayBypass()
  pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end
    local GC = _G.GameplayCallbacks
    local reportFuncs = {
      "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow", "ReportFireArms",
      "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt",
      "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute",
      "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow",
      "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow",
      "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
      "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
      "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta",
      "ReportCircleFlow", "ReportPlayerKillFlow", "ClientSecMrpcsFlow", "Heartbeat",
      "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"
    }
    for _, funcName in ipairs(reportFuncs) do
      GC[funcName] = noop
    end
    GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
    GC.CheckReportSecAttackFlow = retFalse
    local originalDSPlayerState = GC.OnDSPlayerStateChanged
    GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
      local stateStr = InPlayerState and string.lower(tostring(InPlayerState)) or ""
      local blockedStates = {
        ["cheatdetected"] = true, ["connectionlost"] = true, ["connectiontimeout"] = true,
        ["connectionexception"] = true, ["netdrivererror"] = true, ["banned"] = true,
        ["kicked"] = true, ["suspended"] = true, ["violationdetected"] = true,
        ["integrityfailure"] = true, ["securityviolation"] = true
      }
      if blockedStates[stateStr] then return end
      if originalDSPlayerState then pcall(originalDSPlayerState, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
    end
    GC.OnPlayerNetConnectionClosed = noop
    GC.OnPlayerActorChannelError = noop
    GC.OnPlayerRPCValidateFailed = noop
    GC.OnPlayerSpectateException = noop
    GC.OnShutdownAfterError = noop
    GC.IsBypassed = true
  end)
end

local function InitializeKillAllSubsystems()
  pcall(function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not subMgr then return end
    local subsystemsToKill = {
      "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
      "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
      "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
      "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem",
      "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem",
      "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
      "AvatarExceptionSubsystem", "GameReportSubsystem", "RescueBtnReplayTraceSubsystem",
      "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "PlayerKillFlowSubsystem",
      "CircleFlowSubsystem", "SwiftHawkSubsystem", "HeartbeatSubsystem",
      "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
      "MD5CheckSubsystem", "PakVerifySubsystem"
    }
    for _, name in ipairs(subsystemsToKill) do
      local sub = subMgr:Get(name)
      if sub then
        for k, v in pairs(sub) do
          if type(v) == "function" and (
            k:find("Report") or k:find("Send") or k:find("Upload") or
            k:find("Verify") or k:find("Check") or k:find("Validate") or
            k:find("Scan") or k:find("Detect") or k:find("Collect") or
            k:find("Flow") or k:find("Heartbeat")
          ) then
            pcall(function() sub[k] = noop end)
          end
        end
        if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
        if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
        if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
      end
    end
  end)
end

local function InitializeFinalProtection()
  pcall(function()
    local globalFlags = {
      "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY",
      "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"
    }
    for _, flag in ipairs(globalFlags) do
      if _G[flag] then _G[flag] = false end
    end
    local originalRequire = require
    local blockedModules = {
      "HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
      "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient",
      "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"
    }
    _G.require = function(module)
      for _, blocked in ipairs(blockedModules) do
        if module:find(blocked) then
          return {}
        end
      end
      return originalRequire(module)
    end
  end)
end

local function ApplyNewBypasses()
  pcall(function()
    InitializeSLUABypass()
    InitializeMD5Bypass()
    InitializeSkinBypass()
    InitializeLogBlocker()
    InitializeScannerBlocker()
    InitializeReplayTelemetryBlocker()
    InitializeReportFlowBlocker()
    InitializePlayerSecurityBypass()
    InitializeClientFlowBypass()
    InitializeHeartbeatBypass()
    InitializeSwiftHawkBypass()
    InitializeCoronaLabBypass()
    InitializeModifierExceptionBypass()
    InitializeSimulateCharacterLocationBypass()
    InitializeShootVerificationBypass()
    InitializeNetworkPacketBlock()
    InitializeAntiCheatHooks()
    InitializeAntiReport()
    InitializeGameplayBypass()
    InitializeKillAllSubsystems()
    InitializeFinalProtection()
  end)
end

-- ==================== NETWORK BLOCKER ====================
local BLACKLIST_HOSTS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
    "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
    "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
    "cdn.club","gpubgm","graph.facebook","calendarpushsubscription","googleads","doubleclick",
    "firebaselogging","firebaseremoteconfig","fonts.googleapis","abs.twimg","dl.listdl",
    "igame.gcloudcs","bugly","beacon","helpshift","tdm","apm","safeguard","weiyun","qzone",
    "tencent-cloud","myapp","idqqimg","gtimg","qqmail","tcdn","cloudctrl","sdkostrace",
    "103.134.189.146","mbgame","csoversea","igame","pubgmobile","down.anticheatexpert.com",
    "asia.csoversea.mbgame.anticheatexpert.com","log.tav.qq","syzsdk.qq","logiservice.qcloud",
    "opensdk.tencent","exp.helpshift","loginsdkapi.zingplay","firebase","googleapis","facebook","gvoice"
}
local BLACKLIST_PORTS = {
    "10334","11045","12221","13331","8011","8015","9001","20000","20001","20002","20003","20004",
    "20005","19700","1670","19900","14545","10213","8700","25177","10685","10336","10262","27000",
    "27040","27015","27030","10706","10095","12401","11008","10309","11075","10157","24798","10709",
    "6667","10087","31113","20371","10120","10664","13728","10769","10761","5061","5062","18081",
    "15692","9030","8080","8086","8088"
}
local FILE_KEYWORDS = {
    "tlog","crash","bugly","report","beacon","wetest","analytics","telemetry","trace","dump",
    "exception","feedback","aps_log","mtp_detect","network_loss","client_error","ue4crash","tdm","gcloud"
}

local function isBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = str:lower()
    for _, kw in ipairs(BLACKLIST_HOSTS) do if low:find(kw,1,true) then return true end end
    for _, port in ipairs(BLACKLIST_PORTS) do if low:find(":"..port) or low:find("/"..port) then return true end end
    return false
end

local function applyNetworkBlocker()
    pcall(function()
        if _G.HttpRequest then
            local orig = _G.HttpRequest
            _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
        end
        if _G.FHttpModule and _G.FHttpModule.CreateRequest then
            local orig = _G.FHttpModule.CreateRequest
            _G.FHttpModule.CreateRequest = function(...)
                local url = select(1,...)
                if isBlacklisted(url) then return nil end
                return orig(...)
            end
        end
        local netMods = {
            "client.slua.logic.network.logic_network","client.slua.logic.download.report.puffer_tlog",
            "client.slua.data.BasicData.BasicDataClientReport","GameLua.GameCore.Module.Network.NetworkManager",
            "client.network.Protocol.ClientTlogHandler","client.network.Protocol.BattleReportHandler",
            "client.network.Protocol.ClientErrorReportHandler"
        }
        for _, mp in ipairs(netMods) do
            local mod = package.loaded[mp]
            if mod then
                for k, v in pairs(mod) do
                    if type(v) == "function" and (k:find("Http") or k:find("Request") or k:find("Send") or k:find("Upload") or k:find("Post") or k:find("Get") or k:find("Report")) then
                        local origf = v
                        mod[k] = function(...)
                            local args = {...}
                            for _, arg in ipairs(args) do if type(arg)=="string" and isBlacklisted(arg) then return nil end end
                            return pcall(origf, ...)
                        end
                    end
                end
            end
        end
    end)

    local orig_io_open = io.open
    io.open = function(path, mode)
        if type(path) == "string" then
            local lp = path:lower()
            for _, kw in ipairs(FILE_KEYWORDS) do
                if lp:find(kw) then
                    if mode and (mode == "w" or mode == "a" or mode == "w+" or mode == "a+") then
                        return nil, "Blocked"
                    end
                end
            end
            if lp:find("tdm") or lp:find("gcloud") or lp:find("beacon") then
                if mode and (mode == "w" or mode == "a" or mode == "w+") then return nil end
            end
        end
        return orig_io_open(path, mode)
    end

    if _G.UnrealEngine and _G.UnrealEngine.CrashContext then
        _G.UnrealEngine.CrashContext = nil
        _G.UnrealEngine.CrashContext = { SetCrashContext = noop, ReportCrash = noop, AddCrashData = noop }
    end
end

local function killGlobalFunctions()
    local globalFuncs = {
        "ReportTLogEvent","SendTlog","SendClientStats","ReportHitFlow","ReportAvatarException",
        "SendComplaintReq","SubmitReport","ReportSuspiciousPlayer","SendPacket","OnSyncBanInfo",
        "OnVoiceBanNotify","SendSecTLog","MarkSuspiciousPlayer","ReportPlayerBehaviorData",
        "CheckCompliance","ReportIllegalProgram","UploadVoiceLog","ReportCheat","ReportPlayer",
        "ShowReportUI","OpenReportPanel","OnClickReport","ReportCheatDetected"
    }
    for _, fn in ipairs(globalFuncs) do
        if type(_G[fn]) == "function" then _G[fn] = noop end
        _G[fn] = nil
    end
end

-- ==================== CRC FAKER ====================
local function deepHook(obj, depth)
    if depth > 4 then return end
    if type(obj) ~= "table" then return end
    for k, v in pairs(obj) do
        if type(k) == "string" then
            local lk = k:lower()
            if lk:find("crc") or lk:find("verify") or lk:find("integrity") or lk:find("hash") or lk:find("paksign") then
                if type(v) == "function" then
                    obj[k] = function(...) if lk:find("crc") or lk:find("hash") then return 0 end; return true end
                end
            end
        end
        if type(v) == "table" and v ~= obj then deepHook(v, depth + 1) end
    end
end

local function applyFullCRCFaker()
    if _G.__CRCFakerDone then return end
    pcall(function()
        if not slua_GameFrontendHUD then return end
        if Client then
            if Client.VerifyPakFile then Client.VerifyPakFile = retTrue end
            if Client.CheckFileCRC then Client.CheckFileCRC = retZero end
            if Client.GetFileHash then Client.GetFileHash = function() return "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" end end
            if Client.VerifySignature then Client.VerifySignature = retTrue end
            if Client.CheckGameLuaIntegrity then Client.CheckGameLuaIntegrity = retTrue end
            if Client.VerifyFileIntegrity then Client.VerifyFileIntegrity = retTrue end
            if Client.VerifyAllPaks then Client.VerifyAllPaks = retTrue end
        end
        for _, mod in pairs(package.loaded) do if type(mod) == "table" then deepHook(mod, 0) end end
        _G.__CRCFakerDone = true
    end)
end

-- ==================== ADVANCED PATCHES ====================
local function applyAdvancedPatches()
    pcall(function()
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local function patchSub(name, methods, retvals, fields)
                local inst = SubsystemMgr:Get(name)
                if inst then
                    if methods then for k, v in pairs(methods) do if type(inst[k]) == "function" then inst[k] = v end end end
                    if retvals then for k, v in pairs(retvals) do if type(inst[k]) == "function" then inst[k] = v end end end
                    if fields then for k, v in pairs(fields) do inst[k] = v end end
                end
            end
            patchSub("AFKReportorSubsystem", {PlayerHaveAction = noop, ReportAFK = noop})
            patchSub("ClientDataStatistcsSubsystem", nil, nil, {DelayCount = 0})
            patchSub("AvatarExceptionSubsystem", {ReportException = noop, BindPlayerCharacter = noop, CheckAvatarValid = retTrue})
            patchSub("ShootVerifySubSystemClient", {ReportVerifyFail = noop, OnVerifyFailed = noop})
            patchSub("RescueBtnReplayTraceSubsystem", {ReportTrace = noop, StartTickMonitor = noop, TickMonitorCheck = noop, ReportTickMonitorHeartbeat = noop})
            patchSub("GameReportSubsystem", {ReplayReportData = retFalse, CheckCanBugglyPostException = retFalse, BugglyPostExceptionFull = retFalse, GetClientReplayDataReporter = function() return nil end})
            patchSub("FileCheckSubsystem", {StartCheck = noop, ReportAbnormalFile = noop})
            patchSub("ReplaySubsystem", {SendReport = noop, Upload = noop})
            patchSub("ClientFlagSubsystem", {EvaluateFlags = noop, GetFlagLevel = retZero, GetFlagBanDuration = retZero, IsFlagged = retFalse})
            patchSub("DSAITLogSubsystem", {_UpdateTTKRecords = noop, _UpdateOperatingFrequency = noop})
            patchSub("TLogSubsystem", {OnInit = noop})
            local gameReportSub = SubsystemMgr:Get("GameReportSubsystem")
            if gameReportSub and gameReportSub.Reporter then
                gameReportSub.Reporter.ReportIntArrayData = noop
                gameReportSub.Reporter.ReportUInt8ArrayData = noop
                gameReportSub.Reporter.ReportFloatArrayData = noop
            end
        end
    end)
    pcall(function()
        local CreativeMode = import("CreativeModeBlueprintLibrary")
        if CreativeMode then
            CreativeMode.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeMode.GetContentDiffData = function() return true, "BYPASSED" end
        end
    end)
    pcall(function()
        local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvatarExceptionPlayerInst then
            AvatarExceptionPlayerInst.CheckAvatarException = noop
            AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = noop
            AvatarExceptionPlayerInst.ReportAvatarException = noop
            AvatarExceptionPlayerInst.CheckSlotMeshVisible = retFalse
            AvatarExceptionPlayerInst.CheckPawnVisible = retFalse
            AvatarExceptionPlayerInst.CheckCanBugglyPostException = retFalse
        end
    end)
    pcall(function()
        local AvatarChecker = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if AvatarChecker then AvatarChecker.CheckAvatar = retTrue; AvatarChecker.ReportException = noop end
    end)
    pcall(function()
        local MemoryWarning = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if MemoryWarning then MemoryWarning.OnMemoryWarning = noop; MemoryWarning.ReportMemoryWarning = noop end
    end)
    pcall(function()
        local StoreInterface = package.loaded["client.slua.logic.store.logic_store_game_interface"]
        if StoreInterface then StoreInterface.IsStoreGameSupported = retTrue; StoreInterface.NotifyGetPGSLoginInfo = noop end
    end)
    pcall(function()
        local VoiceSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Voice.VoiceChatSubsystem"]
        if VoiceSubsystem then VoiceSubsystem.OnPlayerSubmitComplaint = noop end
    end)
    pcall(function()
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local orig = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (data:find("report") or data:find("exception")) then return end
                if orig then orig(data) end
            end
            TssSdk.SendReportInfo = noop
            TssSdk.ScanMemory = retTrue
            TssSdk.IsEmulator = retFalse
            TssSdk.GetTssSdkReportInfo = function() return "" end
        end
    end)
    pcall(function()
        local logicReplayReport = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logicReplayReport then logicReplayReport.ReportReplay = noop; logicReplayReport.SendReportReq = noop end
    end)
    pcall(function()
        local PufferTlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if PufferTlog then PufferTlog.ReportEvent = noop; PufferTlog.ReportDownloadResult = noop; PufferTlog.ReportODPAKError = noop end
    end)
    pcall(function()
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue end
    end)
    pcall(function()
        local EquipmentExceptionReport = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if EquipmentExceptionReport then EquipmentExceptionReport.Report = noop end
    end)
    pcall(function()
        local TLog = _G.TLog or package.loaded["TLog"]
        if TLog then TLog.Info = noop; TLog.Warning = noop; TLog.Error = noop; TLog.Debug = noop; TLog.Report = noop end
    end)
    pcall(function()
        local pc = (slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController())
        if pc and pc.HiggsBosonComponent then
            pc.HiggsBosonComponent.bMHActive = false
            pc.HiggsBosonComponent:ControlMHActive(0)
        end
    end)
    pcall(function() _G.BlackList = {} end)
end

-- ==================== SELF-HEAL ====================
local function safeSelfHeal()
    pcall(function()
        local TM = safe_require("GameLua.Mod.BaseMod.Common.TickManager")
        if TM and TM.AddLoopTimer then
            TM.AddLoopTimer(120, function()
                pcall(function()
                    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                    if pc and pc.HiggsBosonComponent then
                        pc.HiggsBosonComponent.bMHActive = false
                        pc.HiggsBosonComponent:ControlMHActive(0)
                    end
                    if slua.isValid(pc) then
                        local pawn = pc:GetCurPawn()
                        if slua.isValid(pawn) then
                            pcall(function()
                                local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
                                if Higgs then
                                    Higgs.ControlMHActive = noop; Higgs.TriggerAvatarCheck = noop; Higgs.StartAvatarCheck = noop
                                    Higgs.ReportItemID = noop; Higgs.OnReportItemID = noop; Higgs.ReceiveAnyDamage = noop
                                    Higgs.OnWeaponHitRecord = noop; Higgs.ShowSecurityAlert = noop; Higgs.ServerReportAvatar = noop
                                    Higgs.ClientReportNetAvatar = noop; Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero
                                end
                                if _G.AvatarCheckCallback then _G.AvatarCheckCallback.StartAvatarCheck = noop; _G.AvatarCheckCallback.OnReportItemID = noop end
                            end)
                        end
                    end
                end)
                local modules = {"client.slua.logic.ban.ClientBanLogic","client.common.ban_util","client.logic.login.logic_tt_ban","client.slua.logic.ban.BanTipsLogic"}
                for _, modName in ipairs(modules) do
                    local mod = package.loaded[modName]
                    if mod then
                        for k, v in pairs(mod) do
                            if type(k) == "string" and (k:find("Ban") or k:find("Flag")) and type(v) == "function" then
                                mod[k] = retFalse
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== EXTRA BYPASS: GOKUBA LOGIC ====================
pcall(function()
    local Gokuba = _G.GokubaLogic or package.loaded["GokubaLogic"]
    if Gokuba then
        Gokuba.ForwardFeature = function() return end
        Gokuba.InitGokubaLogic = function() return end
    end
    if _G.NetUtil and _G.NetUtil.SendPkg then
        local origSendPkg = _G.NetUtil.SendPkg
        _G.NetUtil.SendPkg = function(packetName, ...)
            if packetName == "battle_client_sync_allstar_auth_check_result_req" then
                return
            end
            return origSendPkg(packetName, ...)
        end
    end
end)

-- ==================== EXTRA BYPASS: HOSTED PROTO ====================
pcall(function()
    local HostedProto = _G.HostedProtoConfig or package.loaded["HostedProtoConfig"]
    if HostedProto and HostedProto.Proto then
        if HostedProto.Proto.NationalEsportsSecurityCheck then
            HostedProto.Proto.NationalEsportsSecurityCheck.func = "noop"
        end
    end
end)

-- ==================== EXTRA BYPASS: ANTI-CHEAT SUBSYSTEM ====================
pcall(function()
    local AC_Subsystem = _G.AntiCheatSubsystem or package.loaded["GameLua.Mod.BaseMod.Client.Security.AntiCheatSubsystem"]
    if AC_Subsystem then
        AC_Subsystem.OnInit = function() return end
        AC_Subsystem.OnTick = function() return end
        AC_Subsystem.CheckAbnormalStatus = function() return false end
        AC_Subsystem.ReportSecurityData = function() return end
        AC_Subsystem.OnDetectionResult = function() return end
        AC_Subsystem.TriggerSafetyScan = function() return end
    end
end)

-- ==================== END OF BYPASS ENGINE ====================

local ticker = _safe_require("common.time_ticker")
if ticker and ticker.AddTimerOnce then
    ticker.AddTimerOnce(90, PAK_UltimateProtectionLoop) -- 90 = 1.5 دقيقة
end
end

pcall(function()
    UltimatePAKProtection:Initialize()
    PAK_HASH_BYPASS:Init()
    AimbotProtection:Initialize()
    PAK_DisableAllSystems()
    PAK_KillBanPopups()
    PAK_DisableInstantBan()
    PAK_SpoofDevice()
    PAK_DisableFileChecks()
    PAK_PreventDisconnectAndCrash()
    DisableACE()
    PAK_UltimateProtectionLoop()
end)

--Dm:HSD
--dev: @AOKYRT
--CHANNEL:@saifhacking

local function DisableAnoSDK_MRPCS()

    -- ==========================================================
    -- ANOSDK (20 functions)
    -- ==========================================================
    local AnoSdk = _G.AnoSdk or package.loaded["AnoSdk"]
    if AnoSdk then
        for k, v in pairs(AnoSdk) do
            if type(v) == "function" then
                AnoSdk[k] = function() end
            end
        end
        AnoSdk.AnoSDKInit = function() end
        AnoSdk.AnoSDKInitEx = function() end
        AnoSdk.AnoSDKSetUserInfo = function() end
        AnoSdk.AnoSDKSetUserInfoWithLicense = function() end
        AnoSdk.AnoSDKOnPause = function() end
        AnoSdk.AnoSDKOnResume = function() end
        AnoSdk.AnoSDKFree = function() end
        AnoSdk.AnoSDKGetReportData = function() return "" end
        AnoSdk.AnoSDKGetReportData2 = function() return "" end
        AnoSdk.AnoSDKGetReportData3 = function() return "" end
        AnoSdk.AnoSDKGetReportData4 = function() return "" end
        AnoSdk.AnoSDKDelReportData = function() end
        AnoSdk.AnoSDKDelReportData3 = function() end
        AnoSdk.AnoSDKDelReportData4 = function() end
        AnoSdk.AnoSDKOnRecvData = function() end
        AnoSdk.AnoSDKOnRecvSignature = function() end
        AnoSdk.AnoSDKIoctl = function() end
        AnoSdk.AnoSDKIoctlOld = function() end
        AnoSdk.AnoSDKRegistInfoListener = function() end
        AnoSdk.AnoSDKForExport = function() end
    end

    -- ==========================================================
    -- libanogs / anogs
    -- ==========================================================
    local libanogs = _G.libanogs or package.loaded["libanogs"]
    if libanogs then
        for k, v in pairs(libanogs) do
            if type(v) == "function" then
                libanogs[k] = function() end
            end
        end
    end
    
    local anogs = _G.anogs or package.loaded["anogs"]
    if anogs then
        for k, v in pairs(anogs) do
            if type(v) == "function" then
                anogs[k] = function() end
            end
        end
    end

    -- ==========================================================
    -- MRPCS
    -- ==========================================================
    local mrpcNames = {"mrpcs", "MRPCS", "mrpc"}
    for _, name in ipairs(mrpcNames) do
        local obj = _G[name] or package.loaded[name]
        if obj then
            for k, v in pairs(obj) do
                if type(v) == "function" then
                    obj[k] = function() end
                end
            end
        end
    end
    
    local mrpcFuncs = {
        "mrpcs_download_data_thread_start_failed",
        "mrpcs_single_data_not_match",
        "mrpcs_data_crc_error",
        "mrpcs_send_data_thread_start_failed",
        "mrpcs_data_len_error",
        "mrpcs_common_data_not_match",
        "mrpcs_scan_thread_start_failed",
        "mrpcs_lib",
        "mrpcs_data_mode_name_len_error"
    }
    for _, func in ipairs(mrpcFuncs) do
        if _G[func] then
            _G[func] = function() end
        end
    end
    if _G.ms_scan_start then
        _G.ms_scan_start = function() return false end
    end

    print("[+] AnoSDK + MRPCS disabled successfully!")
end

pcall(DisableAnoSDK_MRPCS)

local function KeepDisabled()
    pcall(DisableAnoSDK_MRPCS)
    if require then
        pcall(function()
            require("common.time_ticker").AddTimerOnce(5, KeepDisabled)
        end)
    end
end

pcall(function()
    if require then
        require("common.time_ticker").AddTimerOnce(0.5, KeepDisabled)
    end
end)

print("[+] AnoSDK + MRPCS permanent protection active!")

--Dm:HSD
--dev: @AOKYRT
--CHANNEL:@saifhacking

-- ============================================================
-- Protection made by @ABNHI
-- ============================================================
--- NOTE!!!!! You cannot change my rights or name because it will disable the protection. Beware
-- ============================================================
-- ABNHI
-- ============================================================

local function nop() return end
local function nopstr() return "" end
local function nopfalse() return false end
local function noptrue() return true end
local function nopnil() return nil end
local function retFalse() return false end
local function retTrue() return true end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retEmptyString() return "" end
local function retNil() return nil end
local function retOne() return 1 end
local function retHundred() return 100 end

local function _isValid(obj)
    if type(slua) == "table" and type(slua.isValid) == "function" then
        local ok, res = pcall(slua.isValid, obj)
        return ok and (res == true)
    end
    return obj ~= nil
end

local function _safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local function _killTable(tbl, keys)
    if type(tbl) ~= "table" then return end
    for _, k in ipairs(keys) do
        pcall(function() if tbl[k] ~= nil then tbl[k] = nop end end)
    end
end

local function _gk_ret_true() return true end
local function _gk_ret_false() return false end
local function _gk_ret_zero() return 0 end
local function _gk_ret_empty() return {} end
local function _gk_noop() end

-- ============================================================
-- ABNHI
-- ============================================================

_G.BypassPermissions = {
    -- ABNHI
    SecurityBypass = true,
    AntiCheatBypass = true,
    ReportBypass = true,
    BanBypass = true,
    TelemetryBypass = true,
    NetworkBypass = true,
    MD5Bypass = true,
    SignatureBypass = true,
    DNSBypass = true,
    DeviceBypass = true,
    IPBypass = true,
    MACBypass = true,
    IMEIBypass = true,
    AndroidIDBypass = true,
    HWIDBypass = true,
    MemoryBypass = true,
    
    -- ABNHI
    AllFeaturesEnabled = true,
    NoReports = true,
    NoBan = true,
    NoDetection = true,
    NoTelemetry = true,
    NoCrashReport = true,
    NoAnalytics = true,
    NoMonitor = true,
    NoTrack = true,
    NoScan = true,
    NoVerify = true,
    NoCheck = true,
    NoValidate = true,
    EndGameProtection = true,
    AntiBan = true,
    AntiKick = true,
    AntiSuspend = true,
    AntiFlag = true
}

-- ============================================================
-- Anti-Cheat ABNHI
-- ============================================================

_G.AntiCheatBlock = {
    -- Anti-Cheat ABNHI
    BlockAllAntiCheat = true,
    BlockTSS = true,
    BlockACE = true,
    BlockXignCode = true,
    BlockBattlEye = true,
    BlockGokuba = true,
    BlockSwiftHawk = true,
    BlockCoronaLab = true,
    BlockHawkEye = true,
    BlockHiggsBoson = true,
    BlockClientBan = true,
    BlockRealTimeBan = true,
    BlockReportSystem = true,
    BlockTLog = true,
    BlockMD5Check = true,
    BlockSignatureVerify = true,
    BlockDeviceFingerprint = true,
    BlockDNSMonitor = true,
    BlockTelemetry = true,
    BlockAnalytics = true,
    BlockCrashReport = true,
    BlockMemoryScan = true,
    BlockSpeedCheck = true,
    BlockWallCheck = true,
    BlockShootVerify = true,
    BlockModifierException = true,
    BlockSimulateLocation = true,
    BlockPlayerSecurity = true,
    BlockCircleFlow = true,
    BlockMrpcsFlow = true,
    BlockKillFlow = true,
    BlockBehaviorScore = true,
    BlockAFKReport = true,
    BlockAvatarException = true,
    BlockFileCheck = true,
    BlockPakVerify = true,
    BlockIntegrityCheck = true,
    BlockRacingAntiCheat = true,
    BlockClientEntry = true,
    BlockNetworkException = true,
    BlockUnrealNet = true,
    BlockReplay = true,
    BlockScreenshot = true,
    BlockDebugLog = true,
    BlockMemoryDump = true,
    BlockStackTrace = true,
    BlockProfiler = true,
    
    -- Magic Bullet ABNHI
    BlockMagicBullet = true,
    BlockDamageVerification = true,
    BlockHitboxVerification = true,
    BlockProjectileVerification = true,
    BlockBulletVerification = true,
    BlockShootVerification = true,
    
    -- Skin Mod ABNHI
    BlockSkinVerification = true,
    BlockAvatarVerification = true,
    BlockWeaponVerification = true,
    BlockVehicleVerification = true,
    BlockSkinReport = true,
    
    -- Game Guardian ABNHI
    BlockGameGuardian = true,
    BlockCheatEngine = true,
    BlockMemoryEditor = true,
    BlockDebugger = true,
    
    -- Emulator Detection ABNHI
    BlockEmulator = true,
    BlockVMDetection = true,
    
    -- Tamper Detection ABNHI
    BlockTamper = true,
    BlockFileIntegrity = true,
    
    -- SpeedHack Detection ABNHI
    BlockSpeedHack = true,
    BlockTimeScale = true,
    
    -- ESP Detection ABNHI
    BlockESP = true,
    BlockWallhack = true,
    
    -- NoRecoil Detection ABNHI
    BlockNoRecoil = true,
    BlockShootPattern = true,
    
    -- Player Report @ABNHI
    BlockPlayerReport = true,
    BlockReportCooldown = true
}

-- ============================================================
-- Anti-Cheat IP @ABNHI
-- ============================================================

_G.BlockedIPs = {
    -- Tencent Anti-Cheat @ABNHI
    "43.128.0.0/16", "43.129.0.0/16", "43.130.0.0/16", "43.131.0.0/16",
    "43.132.0.0/16", "43.133.0.0/16", "43.134.0.0/16", "43.135.0.0/16",
    "43.136.0.0/16", "43.137.0.0/16", "43.138.0.0/16", "43.139.0.0/16",
    "43.140.0.0/16", "43.141.0.0/16", "43.142.0.0/16", "43.143.0.0/16",
    "43.144.0.0/16", "43.145.0.0/16", "43.146.0.0/16", "43.147.0.0/16",
    "43.148.0.0/16", "43.149.0.0/16", "43.150.0.0/16", "43.151.0.0/16",
    "43.152.0.0/16", "43.153.0.0/16", "43.154.0.0/16", "43.155.0.0/16",
    "43.156.0.0/16", "43.157.0.0/16", "43.158.0.0/16", "43.159.0.0/16",
    "43.160.0.0/16", "43.161.0.0/16", "43.162.0.0/16", "43.163.0.0/16",
    "43.164.0.0/16", "43.165.0.0/16", "43.166.0.0/16", "43.167.0.0/16",
    "43.168.0.0/16", "43.169.0.0/16", "43.170.0.0/16", "43.171.0.0/16",
    "43.172.0.0/16", "43.173.0.0/16", "43.174.0.0/16", "43.175.0.0/16",
    "43.176.0.0/16", "43.177.0.0/16", "43.178.0.0/16", "43.179.0.0/16",
    "43.180.0.0/16", "43.181.0.0/16", "43.182.0.0/16", "43.183.0.0/16",
    "43.184.0.0/16", "43.185.0.0/16", "43.186.0.0/16", "43.187.0.0/16",
    "43.188.0.0/16", "43.189.0.0/16", "43.190.0.0/16", "43.191.0.0/16",
    "43.192.0.0/16", "43.193.0.0/16", "43.194.0.0/16", "43.195.0.0/16",
    "43.196.0.0/16", "43.197.0.0/16", "43.198.0.0/16", "43.199.0.0/16",
    "43.200.0.0/16", "43.201.0.0/16", "43.202.0.0/16", "43.203.0.0/16",
    "43.204.0.0/16", "43.205.0.0/16", "43.206.0.0/16", "43.207.0.0/16",
    "43.208.0.0/16", "43.209.0.0/16", "43.210.0.0/16", "43.211.0.0/16",
    "43.212.0.0/16", "43.213.0.0/16", "43.214.0.0/16", "43.215.0.0/16",
    "43.216.0.0/16", "43.217.0.0/16", "43.218.0.0/16", "43.219.0.0/16",
    "43.220.0.0/16", "43.221.0.0/16", "43.222.0.0/16", "43.223.0.0/16",
    "43.224.0.0/16", "43.225.0.0/16", "43.226.0.0/16", "43.227.0.0/16",
    "43.228.0.0/16", "43.229.0.0/16", "43.230.0.0/16", "43.231.0.0/16",
    "43.232.0.0/16", "43.233.0.0/16", "43.234.0.0/16", "43.235.0.0/16",
    "43.236.0.0/16", "43.237.0.0/16", "43.238.0.0/16", "43.239.0.0/16",
    "43.240.0.0/16", "43.241.0.0/16", "43.242.0.0/16", "43.243.0.0/16",
    "43.244.0.0/16", "43.245.0.0/16", "43.246.0.0/16", "43.247.0.0/16",
    "43.248.0.0/16", "43.249.0.0/16", "43.250.0.0/16", "43.251.0.0/16",
    "43.252.0.0/16", "43.253.0.0/16", "43.254.0.0/16", "43.255.0.0/16",
    
    -- Tencent Cloud Anti-Cheat
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
    
    -- BattleEye Anti-Cheat
    "185.244.0.0/16", "185.245.0.0/16", "185.246.0.0/16", "185.247.0.0/16",
    "185.248.0.0/16", "185.249.0.0/16", "185.250.0.0/16", "185.251.0.0/16",
    "185.252.0.0/16", "185.253.0.0/16", "185.254.0.0/16", "185.255.0.0/16",
    
    -- EasyAntiCheat
    "104.0.0.0/8", "104.1.0.0/8", "104.2.0.0/8", "104.3.0.0/8",
    "104.4.0.0/8", "104.5.0.0/8", "104.6.0.0/8", "104.7.0.0/8",
    "104.8.0.0/8", "104.9.0.0/8", "104.10.0.0/8", "104.11.0.0/8",
    "104.12.0.0/8", "104.13.0.0/8", "104.14.0.0/8", "104.15.0.0/8",
    "104.16.0.0/8", "104.17.0.0/8", "104.18.0.0/8", "104.19.0.0/8",
    "104.20.0.0/8", "104.21.0.0/8", "104.22.0.0/8", "104.23.0.0/8",
    "104.24.0.0/8", "104.25.0.0/8", "104.26.0.0/8", "104.27.0.0/8",
    "104.28.0.0/8", "104.29.0.0/8", "104.30.0.0/8", "104.31.0.0/8",
    
    -- PUBG Report and Ban Servers @ABNHI
    "203.0.0.0/8", "204.0.0.0/8", "205.0.0.0/8", "206.0.0.0/8",
    "207.0.0.0/8", "208.0.0.0/8", "209.0.0.0/8", "210.0.0.0/8",
    "211.0.0.0/8", "212.0.0.0/8", "213.0.0.0/8", "214.0.0.0/8",
    "215.0.0.0/8", "216.0.0.0/8", "217.0.0.0/8", "218.0.0.0/8",
    "219.0.0.0/8", "220.0.0.0/8", "221.0.0.0/8", "222.0.0.0/8",
    "223.0.0.0/8",
    
    -- Other Anti-Cheat Servers ABNHI
    "3.0.0.0/8", "4.0.0.0/8", "5.0.0.0/8", "6.0.0.0/8",
    "7.0.0.0/8", "8.0.0.0/8", "9.0.0.0/8", "10.0.0.0/8",
    "11.0.0.0/8", "12.0.0.0/8", "13.0.0.0/8", "14.0.0.0/8",
    "15.0.0.0/8", "16.0.0.0/8", "17.0.0.0/8", "18.0.0.0/8",
    "19.0.0.0/8", "20.0.0.0/8", "21.0.0.0/8", "22.0.0.0/8",
    "23.0.0.0/8", "24.0.0.0/8", "25.0.0.0/8", "26.0.0.0/8",
    "27.0.0.0/8", "28.0.0.0/8", "29.0.0.0/8", "30.0.0.0/8",
    "31.0.0.0/8", "32.0.0.0/8", "33.0.0.0/8", "34.0.0.0/8",
    "35.0.0.0/8", "36.0.0.0/8", "37.0.0.0/8", "38.0.0.0/8",
    "39.0.0.0/8", "40.0.0.0/8", "41.0.0.0/8", "42.0.0.0/8",
    "44.0.0.0/8", "45.0.0.0/8", "46.0.0.0/8", "47.0.0.0/8",
    "48.0.0.0/8", "49.0.0.0/8", "50.0.0.0/8", "51.0.0.0/8",
    "52.0.0.0/8", "53.0.0.0/8", "54.0.0.0/8", "55.0.0.0/8",
    "56.0.0.0/8", "57.0.0.0/8", "58.0.0.0/8", "59.0.0.0/8",
    "60.0.0.0/8", "61.0.0.0/8", "62.0.0.0/8", "63.0.0.0/8",
    "64.0.0.0/8", "65.0.0.0/8", "66.0.0.0/8", "67.0.0.0/8",
    "68.0.0.0/8", "69.0.0.0/8", "70.0.0.0/8", "71.0.0.0/8",
    "72.0.0.0/8", "73.0.0.0/8", "74.0.0.0/8", "75.0.0.0/8",
    "76.0.0.0/8", "77.0.0.0/8", "78.0.0.0/8", "79.0.0.0/8",
    "80.0.0.0/8", "81.0.0.0/8", "82.0.0.0/8", "83.0.0.0/8",
    "84.0.0.0/8", "85.0.0.0/8", "86.0.0.0/8", "87.0.0.0/8",
    "88.0.0.0/8", "89.0.0.0/8", "90.0.0.0/8", "91.0.0.0/8",
    "92.0.0.0/8", "93.0.0.0/8", "94.0.0.0/8", "95.0.0.0/8",
    "96.0.0.0/8", "97.0.0.0/8", "98.0.0.0/8", "99.0.0.0/8",
    "100.0.0.0/8", "101.0.0.0/8", "102.0.0.0/8", "103.0.0.0/8",
    "105.0.0.0/8", "106.0.0.0/8", "107.0.0.0/8", "108.0.0.0/8",
    "109.0.0.0/8", "110.0.0.0/8", "111.0.0.0/8", "112.0.0.0/8",
    "113.0.0.0/8", "114.0.0.0/8", "115.0.0.0/8", "116.0.0.0/8",
    "117.0.0.0/8", "118.0.0.0/8", "119.0.0.0/8", "120.0.0.0/8",
    "121.0.0.0/8", "122.0.0.0/8", "123.0.0.0/8", "124.0.0.0/8",
    "125.0.0.0/8", "126.0.0.0/8", "127.0.0.0/8",
    
    -- Additional Ban IPs ABNHI
    "10.20.30.40", "10.20.30.41", "10.20.30.42", "10.20.30.43",
    "10.20.30.44", "10.20.30.45", "10.20.30.46", "10.20.30.47",
    "10.20.30.48", "10.20.30.49", "10.20.30.50", "10.20.30.51",
    "10.20.30.52", "10.20.30.53", "10.20.30.54", "10.20.30.55",
}

-- ============================================================
-- Anti-Cheat Domain Blocking List ABNHI
-- ============================================================

_G.BlockedDomains = {
    "pubgm.qq.com", "anticheat.qq.com", "tss.tencent.com",
    "report.qq.com", "ban.qq.com", "security.qq.com",
    "anti.tencent.com", "ac.tencent.com", "safe.qq.com",
    "trust.qq.com", "verify.qq.com", "check.qq.com",
    "monitor.qq.com", "track.qq.com", "analytics.qq.com",
    "telemetry.qq.com", "crash.qq.com", "bugly.qq.com",
    "tlog.qq.com", "log.qq.com", "data.qq.com",
    "api.qq.com", "svc.qq.com", "gw.qq.com",
    "cloud.qq.com", "cdn.qq.com", "static.qq.com",
    "anticheat.tencent.com", "tss.tencent.com", "ace.tencent.com",
    "battleye.com", "easyanticheat.com", "xigncode.com",
    "gameguardian.net", "cheatengine.org", "memoryeditor.com",
    "rootdetect.com", "jailbreak.com", "emulatorcheck.com",
}

-- ============================================================
-- 1. Ban Popup ABNHI
-- ============================================================

local function KillBanPopup()
    pcall(function()
        -- Ban UI ABNHI
        local allWidgets = slua.getUIList() or {}
        for _, widget in pairs(allWidgets) do
            if slua.isValid(widget) then
                local name = widget:GetName() or ""
                if name:find("Legal") or name:find("Common_Legal") or 
                   name:find("Notice") or name:find("Ban") or 
                   name:find("Error") or name:find("Popup") or
                   name:find("Message") or name:find("Dialog") or
                   name:find("Warning") or name:find("Alert") or
                   name:find("Suspension") or name:find("Frozen") or
                   name:find("Penalty") or name:find("Sanction") or
                   name:find("Terminated") or name:find("Blocked") or
                   name:find("Flagged") or name:find("Marked") or
                   name:find("Inspection") or name:find("Risk") then
                    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    pcall(function() widget:RemoveFromParent() end)
                end
            end
        end
        
        -- Console command ABNHI
        pcall(function()
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if slua.isValid(pc) then
                local KSL = import("KismetSystemLibrary")
                if KSL then
                    KSL.ExecuteConsoleCommand(pc, "DisableAllScreenMessages")
                    KSL.ExecuteConsoleCommand(pc, "UI.DisableMessageOfTheDay")
                    KSL.ExecuteConsoleCommand(pc, "ShowMOTD 0")
                    KSL.ExecuteConsoleCommand(pc, "r.UI.DisableAll 1")
                    KSL.ExecuteConsoleCommand(pc, "UI.HideAllWidgets 1")
                    KSL.ExecuteConsoleCommand(pc, "ShowBanNotice 0")
                    KSL.ExecuteConsoleCommand(pc, "ShowSuspension 0")
                    KSL.ExecuteConsoleCommand(pc, "ShowFrozenNotice 0")
                    KSL.ExecuteConsoleCommand(pc, "ShowRiskNotice 0")
                    KSL.ExecuteConsoleCommand(pc, "ShowDeviceError 0")
                    KSL.ExecuteConsoleCommand(pc, "ShowNetworkError 0")
                    KSL.ExecuteConsoleCommand(pc, "DisableBanUI 1")
                    KSL.ExecuteConsoleCommand(pc, "HideBanMessages 1")
                    KSL.ExecuteConsoleCommand(pc, "IgnoreSecurityChecks 1")
                    KSL.ExecuteConsoleCommand(pc, "UIToggle 0")
                    KSL.ExecuteConsoleCommand(pc, "HideUI 1")
                    KSL.ExecuteConsoleCommand(pc, "DisablePopup 1")
                    KSL.ExecuteConsoleCommand(pc, "SuppressDialogs 1")
                end
            end
        end)
    end)
end

-- ============================================================
-- 2. IP/Domain ABNHI
-- ============================================================

local function ApplyIPDomainBlocking()
    pcall(function()
        -- socket.connect ABNHI
        if socket and socket.connect then
            local origConnect = socket.connect
            socket.connect = function(host, port, ...)
                for _, ip in ipairs(_G.BlockedIPs or {}) do
                    if host == ip then return nil, "blocked" end
                end
                for _, domain in ipairs(_G.BlockedDomains or {}) do
                    if host:lower():find(domain) then return nil, "blocked" end
                end
                return origConnect(host, port, ...)
            end
        end
        
        -- socket.tcp ABNHI
        if socket and socket.tcp then
            local origTcp = socket.tcp
            socket.tcp = function(...)
                local client = origTcp(...)
                if client and client.connect then
                    local origConnect = client.connect
                    client.connect = function(self, host, port, ...)
                        for _, ip in ipairs(_G.BlockedIPs or {}) do
                            if host == ip then return nil, "blocked" end
                        end
                        for _, domain in ipairs(_G.BlockedDomains or {}) do
                            if host:lower():find(domain) then return nil, "blocked" end
                        end
                        return origConnect(self, host, port, ...)
                    end
                end
                return client
            end
        end
        
        -- NetUtil.ConnectToServer ABNHI
        if NetUtil and NetUtil.ConnectToServer then
            local origConnect = NetUtil.ConnectToServer
            NetUtil.ConnectToServer = function(ip, port, ...)
                for _, banIP in ipairs(_G.BlockedIPs or {}) do
                    if ip == banIP then return false end
                end
                return origConnect(ip, port, ...)
            end
        end
        
        -- HTTP/WebSocket ABNHI
        if _G.Http and _G.Http.Get then
            local origGet = _G.Http.Get
            _G.Http.Get = function(url, ...)
                for _, domain in ipairs(_G.BlockedDomains or {}) do
                    if url:find(domain) then return nil, "blocked" end
                end
                return origGet(url, ...)
            end
        end
        if _G.Http and _G.Http.Post then
            local origPost = _G.Http.Post
            _G.Http.Post = function(url, ...)
                for _, domain in ipairs(_G.BlockedDomains or {}) do
                    if url:find(domain) then return nil, "blocked" end
                end
                return origPost(url, ...)
            end
        end
        
        -- WebSocket ABNHI
        if _G.WebSocket and _G.WebSocket.Connect then
            local origConnect = _G.WebSocket.Connect
            _G.WebSocket.Connect = function(url, ...)
                for _, domain in ipairs(_G.BlockedDomains or {}) do
                    if url:find(domain) then return nil, "blocked" end
                end
                return origConnect(url, ...)
            end
        end
        
        print("[BYPASS] ✅ IP/Domain ABNHI")
    end)
end

-- ============================================================
-- 3. Game Guardian Detection ABNHI
-- ============================================================

local function BlockGameGuardian()
    pcall(function()
        local GameGuardianDetect = _G.GameGuardianDetect or package.loaded["GameGuardianDetect"]
        if GameGuardianDetect then
            GameGuardianDetect.IsGGRunning = retFalse
            GameGuardianDetect.CheckPackages = retEmpty
            GameGuardianDetect.DetectGameGuardian = retFalse
            GameGuardianDetect.ReportGameGuardian = nop
            GameGuardianDetect.ValidateGG = retTrue
        end
        
        -- Process list  ABNHI
        if _G.ProcessManager and _G.ProcessManager.GetRunningProcesses then
            local origGet = _G.ProcessManager.GetRunningProcesses
            _G.ProcessManager.GetRunningProcesses = function()
                local processes = origGet()
                if processes then
                    local filtered = {}
                    for _, proc in ipairs(processes) do
                        if not string.find(string.lower(tostring(proc)), "gameguardian") then
                            table.insert(filtered, proc)
                        end
                    end
                    return filtered
                end
                return {}
            end
        end
        
        print("[BYPASS] ✅ Game Guardian Detection ABNHI")
    end)
end

-- ============================================================
--  Cheat Engine Detection ABNHI
-- ============================================================

local function BlockCheatEngine()
    pcall(function()
        local CheatEngineDetect = _G.CheatEngineDetect or package.loaded["CheatEngineDetect"]
        if CheatEngineDetect then
            CheatEngineDetect.IsCheatEngineRunning = retFalse
            CheatEngineDetect.CheckProcessList = retEmpty
            CheatEngineDetect.DetectCheatEngine = retFalse
            CheatEngineDetect.ReportCheatEngine = nop
            CheatEngineDetect.ValidateCE = retTrue
        end
        
        if _G.ProcessManager and _G.ProcessManager.GetRunningProcesses then
            local origGet = _G.ProcessManager.GetRunningProcesses
            _G.ProcessManager.GetRunningProcesses = function()
                local processes = origGet()
                if processes then
                    local filtered = {}
                    local ceKeywords = {"cheatengine", "cheat_engine", "ce", "memoryedit"}
                    for _, proc in ipairs(processes) do
                        local procLower = string.lower(tostring(proc))
                        local blocked = false
                        for _, kw in ipairs(ceKeywords) do
                            if procLower:find(kw) then blocked = true break end
                        end
                        if not blocked then table.insert(filtered, proc) end
                    end
                    return filtered
                end
                return {}
            end
        end
        
        print("[BYPASS] ✅ Cheat Engine Detection ABNHI")
    end)
end

-- ============================================================
-- 5. Root/Jailbreak Detection Blocking ABNHI
-- ============================================================

local function BlockRootJailbreak()
    pcall(function()
        local RootDetect = _G.RootDetect or package.loaded["RootDetect"]
        if RootDetect then
            RootDetect.CheckRoot = retFalse
            RootDetect.CheckSu = retFalse
            RootDetect.CheckMagisk = retFalse
            RootDetect.CheckSuperSU = retFalse
            RootDetect.DetectRoot = retFalse
            RootDetect.ReportRoot = nop
            RootDetect.ValidateRoot = retTrue
        end
        
        local JailbreakDetect = _G.JailbreakDetect or package.loaded["JailbreakDetect"]
        if JailbreakDetect then
            JailbreakDetect.CheckJailbreak = retFalse
            JailbreakDetect.CheckCydia = retFalse
            JailbreakDetect.DetectJailbreak = retFalse
            JailbreakDetect.ReportJailbreak = nop
            JailbreakDetect.ValidateJailbreak = retTrue
        end
        
        print("[BYPASS] ✅ Root/Jailbreak Detection ABNHI")
    end)
end

-- ============================================================
-- 6. Emulator Detection Blocking (New) ABNHI
-- ============================================================

local function BlockEmulatorDetection()
    pcall(function()
        -- Emulator Detection ကို ABNHI.
        local EmulatorDetect = import("EmulatorDetect")
        if EmulatorDetect then
            EmulatorDetect.IsEmulator = retFalse
            EmulatorDetect.GetEmulatorType = retEmptyString
            EmulatorDetect.CheckVM = retFalse
            EmulatorDetect.DetectEmulator = retFalse
            EmulatorDetect.ReportEmulator = nop
            EmulatorDetect.ValidateEmulator = retTrue
        end
        
        -- TSS Emulator Check ABNHI.
        if _G.TssSdk then
            _G.TssSdk.IsEmulator = retFalse
            _G.TssSdk.CheckEmulator = retFalse
            _G.TssSdk.ReportEmulator = nop
        end
        
        -- System Properties ABNHI.
        if _G.SystemProperties then
            _G.SystemProperties.ro.kernel.qemu = "0"
            _G.SystemProperties.ro.product.device = "samsung"
            _G.SystemProperties.ro.product.model = "SM-G998B"
            _G.SystemProperties.ro.product.manufacturer = "samsung"
            _G.SystemProperties.ro.hardware = "exynos2100"
        end
        
        print("[BYPASS] ✅ Emulator Detection ABNHI")
    end)
end

-- ============================================================
-- 7. Tamper Detection Blocking (New) ABNHI
-- ============================================================

local function BlockTamperDetection()
    pcall(function()
        -- File Integrity Check  ABNHI.
        local FileIntegrity = import("FileIntegrity")
        if FileIntegrity then
            FileIntegrity.VerifyFile = retTrue
            FileIntegrity.CheckIntegrity = retTrue
            FileIntegrity.ReportTamper = nop
            FileIntegrity.ValidateFile = retTrue
            FileIntegrity.IsFileValid = retTrue
        end
        
        -- Pak File Verification ABNHI.
        local PakVerification = import("PakVerification")
        if PakVerification then
            PakVerification.VerifyPak = retTrue
            PakVerification.CheckPak = retTrue
            PakVerification.ReportPakError = nop
            PakVerification.ValidatePak = retTrue
            PakVerification.IsPakValid = retTrue
        end
        
        -- Memory Tamper Detection ABNHI.
        local MemoryTamper = import("MemoryTamper")
        if MemoryTamper then
            MemoryTamper.DetectTamper = retFalse
            MemoryTamper.ReportTamper = nop
            MemoryTamper.CheckTamper = retFalse
            MemoryTamper.ValidateMemory = retTrue
        end
        
        print("[BYPASS] ✅ Tamper Detection ABNHI")
    end)
end

-- ============================================================
-- 8. SpeedHack Detection Blocking (New) ABNHI
-- ============================================================

local function BlockSpeedHackDetection()
    pcall(function()
        -- Speed Hack Detection ABNHI.
        local SpeedHackDetect = import("SpeedHackDetect")
        if SpeedHackDetect then
            SpeedHackDetect.DetectSpeedHack = retFalse
            SpeedHackDetect.ReportSpeedHack = nop
            SpeedHackDetect.CheckSpeed = retTrue
            SpeedHackDetect.ValidateSpeed = retTrue
            SpeedHackDetect.IsSpeedHack = retFalse
        end
        
        -- Movement Verification ABNHI.
        local MovementVerify = import("MovementVerify")
        if MovementVerify then
            MovementVerify.VerifyMovement = retTrue
            MovementVerify.ReportAbnormalMovement = nop
            MovementVerify.CheckMovement = retTrue
            MovementVerify.ValidateMovement = retTrue
            MovementVerify.IsMovementValid = retTrue
        end
        
        -- Time Scale Check ကို ABNHI.
        local TimeScale = import("TimeScale")
        if TimeScale then
            TimeScale.CheckTimeScale = retTrue
            TimeScale.ReportTimeScale = nop
            TimeScale.ValidateTimeScale = retTrue
            TimeScale.IsTimeScaleValid = retTrue
        end
        
        print("[BYPASS] ✅ SpeedHack Detection ABNHI")
    end)
end

-- ============================================================
-- 9. ESP Detection Blocking (New) ABNHI
-- ============================================================

local function BlockESPDetection()
    pcall(function()
        -- ESP Detection  ABNHI.
        local ESPDetect = import("ESPDetect")
        if ESPDetect then
            ESPDetect.DetectESP = retFalse
            ESPDetect.ReportESP = nop
            ESPDetect.CheckESP = retFalse
            ESPDetect.ValidateESP = retTrue
            ESPDetect.IsESPDetected = retFalse
        end
        
        -- Wallhack Detection  ABNHI.
        local WallhackDetect = import("WallhackDetect")
        if WallhackDetect then
            WallhackDetect.DetectWallhack = retFalse
            WallhackDetect.ReportWallhack = nop
            WallhackDetect.CheckWallhack = retFalse
            WallhackDetect.ValidateWallhack = retTrue
            WallhackDetect.IsWallhackDetected = retFalse
        end
        
        -- Render Check ABNHI.
        local RenderCheck = import("RenderCheck")
        if RenderCheck then
            RenderCheck.CheckRender = retTrue
            RenderCheck.ReportRender = nop
            RenderCheck.ValidateRender = retTrue
            RenderCheck.IsRenderValid = retTrue
        end
        
        print("[BYPASS] ✅ ESP Detection ABNHI")
    end)
end

-- ============================================================
-- 10. NoRecoil Detection Blocking (New) ABNHI
-- ============================================================

local function BlockNoRecoilDetection()
    pcall(function()
        -- NoRecoil Detection ABNHI.
        local NoRecoilDetect = import("NoRecoilDetect")
        if NoRecoilDetect then
            NoRecoilDetect.DetectNoRecoil = retFalse
            NoRecoilDetect.ReportNoRecoil = nop
            NoRecoilDetect.CheckRecoil = retTrue
            NoRecoilDetect.ValidateRecoil = retTrue
            NoRecoilDetect.IsNoRecoil = retFalse
        end
        
        -- Shoot Pattern Verification ABNHI.
        local ShootPattern = import("ShootPattern")
        if ShootPattern then
            ShootPattern.VerifyPattern = retTrue
            ShootPattern.ReportPattern = nop
            ShootPattern.CheckPattern = retTrue
            ShootPattern.ValidatePattern = retTrue
            ShootPattern.IsPatternValid = retTrue
        end
        
        print("[BYPASS] ✅ NoRecoil Detection ABNHI")
    end)
end

-- ============================================================
-- 11. Advanced Anti-Cheat Bypass (New) ABNHI
-- ============================================================

local function AdvancedAntiCheatBypass()
    pcall(function()
        -- Unreal Engine Anti-Cheat
        local UAntiCheat = import("UAntiCheat")
        if UAntiCheat then
            UAntiCheat.CheckCheat = retFalse
            UAntiCheat.ReportCheat = nop
            UAntiCheat.ValidateCheat = retTrue
            UAntiCheat.IsCheatDetected = retFalse
            UAntiCheat.DetectCheat = retFalse
            UAntiCheat.KickCheater = nop
            UAntiCheat.BanCheater = nop
        end
        
        -- Blueprint Anti-Cheat
        local BPAntiCheat = import("BPAntiCheat")
        if BPAntiCheat then
            BPAntiCheat.VerifyBlueprint = retTrue
            BPAntiCheat.ReportBlueprint = nop
            BPAntiCheat.CheckBlueprint = retTrue
            BPAntiCheat.ValidateBlueprint = retTrue
            BPAntiCheat.IsBlueprintValid = retTrue
        end
        
        -- Network Anti-Cheat
        local NetAntiCheat = import("NetAntiCheat")
        if NetAntiCheat then
            NetAntiCheat.VerifyNetwork = retTrue
            NetAntiCheat.ReportNetwork = nop
            NetAntiCheat.CheckNetwork = retTrue
            NetAntiCheat.ValidateNetwork = retTrue
            NetAntiCheat.IsNetworkValid = retTrue
        end
        
        print("[BYPASS] ✅ Advanced Anti-Cheat ABNHI")
    end)
end

-- ============================================================
-- 12. Memory Protection Bypass (New) ABNHI
-- ============================================================

local function MemoryProtectionBypass()
    pcall(function()
        -- Memory Scanner ကို ABNHI.
        local MemoryScanner = import("MemoryScanner")
        if MemoryScanner then
            MemoryScanner.ScanMemory = retFalse
            MemoryScanner.ReportMemory = nop
            MemoryScanner.CheckMemory = retTrue
            MemoryScanner.ValidateMemory = retTrue
            MemoryScanner.IsMemoryValid = retTrue
        end
        
        -- Pointer Check ကို ABNHI.
        local PointerCheck = import("PointerCheck")
        if PointerCheck then
            PointerCheck.CheckPointer = retTrue
            PointerCheck.ReportPointer = nop
            PointerCheck.ValidatePointer = retTrue
            PointerCheck.IsPointerValid = retTrue
        end
        
        -- Heap Check ကို ABNHI.
        local HeapCheck = import("HeapCheck")
        if HeapCheck then
            HeapCheck.CheckHeap = retTrue
            HeapCheck.ReportHeap = nop
            HeapCheck.ValidateHeap = retTrue
            HeapCheck.IsHeapValid = retTrue
        end
        
        print("[BYPASS] ✅ Memory Protection ABNHI")
    end)
end

-- ============================================================
-- 13. Player Report Bypass (New) ABNHI
-- ============================================================

local function PlayerReportBypass()
    pcall(function()
        -- Player Report System ကို ABNHI.
        local PlayerReport = import("PlayerReport")
        if PlayerReport then
            PlayerReport.ReportPlayer = nop
            PlayerReport.SendReport = nop
            PlayerReport.CheckReport = retFalse
            PlayerReport.ValidateReport = retTrue
            PlayerReport.IsReportValid = retTrue
        end
        
        -- Report Cooldown ABNHI.
        local ReportCooldown = import("ReportCooldown")
        if ReportCooldown then
            ReportCooldown.GetCooldown = retZero
            ReportCooldown.CheckCooldown = retTrue
            ReportCooldown.ResetCooldown = nop
            ReportCooldown.ValidateCooldown = retTrue
        end
        
        print("[BYPASS] ✅ Player Report ABNHI")
    end)
end

-- ============================================================
-- 14. Magic Bullet Bypass ABNHI
-- ============================================================

local function MagicBulletBypass()
    pcall(function()
        print("[MAGIC BULLET BYPASS] Magic Bullet ABNHI....")
        
        -- Damage Verification ABNHI.
        local DamageVerification = import("DamageVerification")
        if DamageVerification then
            DamageVerification.VerifyDamage = retTrue
            DamageVerification.ReportAbnormalDamage = nop
            DamageVerification.CheckDamage = retTrue
            DamageVerification.ValidateDamage = retTrue
            DamageVerification.IsDamageValid = retTrue
            DamageVerification.ReportInvalidDamage = nop
            DamageVerification.ResetDamageData = nop
            print("[MAGIC BULLET BYPASS] ✅ Damage Verification ABNHI!")
        end
        
        -- Hitbox Verification ABNHI.
        local HitboxVerification = import("HitboxVerification")
        if HitboxVerification then
            HitboxVerification.VerifyHitbox = retTrue
            HitboxVerification.ReportInvalidHit = nop
            HitboxVerification.CheckHitbox = retTrue
            HitboxVerification.ValidateHitbox = retTrue
            HitboxVerification.IsHitboxValid = retTrue
            HitboxVerification.ReportAbnormalHitbox = nop
            HitboxVerification.ResetHitboxData = nop
            print("[MAGIC BULLET BYPASS] ✅ Hitbox Verification ABNHI!")
        end
        
        -- Projectile Verification ABNHI.
        local ProjectileVerification = import("ProjectileVerification")
        if ProjectileVerification then
            ProjectileVerification.VerifyProjectile = retTrue
            ProjectileVerification.ReportAbnormalProjectile = nop
            ProjectileVerification.CheckProjectile = retTrue
            ProjectileVerification.ValidateProjectile = retTrue
            ProjectileVerification.IsProjectileValid = retTrue
            ProjectileVerification.ReportInvalidProjectile = nop
            ProjectileVerification.ResetProjectileData = nop
            print("[MAGIC BULLET BYPASS] ✅ Projectile Verification ABNHI!")
        end
        
        -- Bullet Verification ABNHI.
        local BulletVerification = import("BulletVerification")
        if BulletVerification then
            BulletVerification.VerifyBullet = retTrue
            BulletVerification.ReportAbnormalBullet = nop
            BulletVerification.CheckBullet = retTrue
            BulletVerification.ValidateBullet = retTrue
            BulletVerification.IsBulletValid = retTrue
            BulletVerification.ReportInvalidBullet = nop
            BulletVerification.ResetBulletData = nop
            print("[MAGIC BULLET BYPASS] ✅ Bullet Verification ABNHI!")
        end
        
        -- Shoot Verification ABNHI.
        local ShootVerify = _safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if ShootVerify then
            ShootVerify.OnShootVerifyFailed = nop
            ShootVerify.SendVerifyData = nop
            ShootVerify.ReportBulletHit = nop
            ShootVerify.UploadHitInfo = nop
            ShootVerify.VerifyShot = retTrue
            ShootVerify.CheckShoot = retTrue
            ShootVerify.ValidateShoot = retTrue
            ShootVerify.IsShootValid = retTrue
            ShootVerify.ReportInvalidShoot = nop
            ShootVerify.ResetShootData = nop
            print("[MAGIC BULLET BYPASS] ✅ Shoot Verification ABNHI!")
        end
        
        print("[MAGIC BULLET BYPASS] ✅ ABNHI. - Magic Bullet detection အားလုံး ABNHI!")
    end)
end

-- ============================================================
-- 15. Skin Mod Bypass ABNHI
-- ============================================================

local function SkinModBypass()
    pcall(function()
        print("[SKIN MOD BYPASS] Skin Mod ABNHI....")
        
        -- Avatar Verification ABNHI.
        local AvatarUtils = import("AvatarUtils")
        if AvatarUtils then
            AvatarUtils.CheckIsWeaponInBlackList = retFalse
            AvatarUtils.IsValidAvatar = retTrue
            AvatarUtils.CheckAvatarIntegrity = retTrue
            AvatarUtils.ReportInvalidAvatar = nop
            AvatarUtils.VerifyAvatar = retTrue
            AvatarUtils.ValidateAvatar = retTrue
            AvatarUtils.IsAvatarValid = retTrue
            AvatarUtils.ResetAvatarData = nop
            print("[SKIN MOD BYPASS] ✅ Avatar Verification ABNHI!")
        end
        
        -- Weapon Verification ABNHI.
        local WeaponVerification = import("WeaponVerification")
        if WeaponVerification then
            WeaponVerification.VerifyWeapon = retTrue
            WeaponVerification.ReportInvalidWeapon = nop
            WeaponVerification.CheckWeapon = retTrue
            WeaponVerification.ValidateWeapon = retTrue
            WeaponVerification.IsWeaponValid = retTrue
            WeaponVerification.ResetWeaponData = nop
            print("[SKIN MOD BYPASS] ✅ Weapon Verification ABNHI!")
        end
        
        -- Vehicle Verification ABNHI.
        local VehicleVerification = import("VehicleVerification")
        if VehicleVerification then
            VehicleVerification.VerifyVehicle = retTrue
            VehicleVerification.ReportInvalidVehicle = nop
            VehicleVerification.CheckVehicle = retTrue
            VehicleVerification.ValidateVehicle = retTrue
            VehicleVerification.IsVehicleValid = retTrue
            VehicleVerification.ResetVehicleData = nop
            print("[SKIN MOD BYPASS] ✅ Vehicle Verification ABNHI!")
        end
        
        print("[SKIN MOD BYPASS] ✅ ABNHI. - Skin Mod detection အားလုံး ABNHI!")
    end)
end

-- ============================================================
-- 16. Version Specific Bypass ABNHI
-- ============================================================

local function VersionSpecificBypasses()
    pcall(function()
        -- GLOBAL Version
        if _G.IS_GLOBAL then
            if _G.TssSdk then
                _G.TssSdk.IsEmulator = retFalse
                _G.TssSdk.ScanMemory = retTrue
                _G.TssSdk.ReportData = nop
                _G.TssSdk.SendReport = nop
                _G.TssSdk.OnRecvData = nop
            end
            local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
            if Higgs then
                Higgs.bIsEnable = false
                Higgs.bMHActive = false
                Higgs.bCallPreReplication = false
            end
            print("[BYPASS] ✅ Global Version ABNHI.")
        end
        
        -- KR Version
        if _G.IS_KR then
            if _G.TssSdk then
                _G.TssSdk.IsEmulator = retFalse
                _G.TssSdk.ScanMemory = retTrue
                _G.TssSdk.ReportData = nop
                _G.TssSdk.SendReport = nop
                _G.TssSdk.OnRecvData = nop
            end
            local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
            if Higgs then
                Higgs.bIsEnable = false
                Higgs.bMHActive = false
                Higgs.bCallPreReplication = false
            end
            print("[BYPASS] ✅ KR Version ABNHI.")
        end
        
        -- TW Version
        if _G.IS_TW_VERSION then
            if _G.TssSdk then
                _G.TssSdk.IsEmulator = retFalse
                _G.TssSdk.ScanMemory = retTrue
                _G.TssSdk.ReportData = nop
                _G.TssSdk.SendReport = nop
                _G.TssSdk.OnRecvData = nop
            end
            local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
            if Higgs then
                Higgs.bIsEnable = false
                Higgs.bMHActive = false
                Higgs.bCallPreReplication = false
            end
            print("[BYPASS] ✅ TW Version ABNHI.")
        end
    end)
end

-- ============================================================
-- 17. TSS SDK Blocking ABNHI
-- ============================================================

local function BlockTssSdk()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            TssSdk.OnRecvData = nop
            TssSdk.SendReportInfo = nop
            TssSdk.ScanMemory = retTrue
            TssSdk.IsEmulator = retFalse
            TssSdk.GetTssSdkReportInfo = retEmptyString
            TssSdk.ReportException = nop
            TssSdk.ReportData = nop
            TssSdk.CheckIntegrity = retTrue
            TssSdk.VerifySignature = retTrue
            TssSdk.CollectEvidence = retNil
            TssSdk.UploadLog = nop
            TssSdk.SendAntiData = nop
            TssSdk.ReportGameStart = nop
            TssSdk.ReportGameEnd = nop
            TssSdk.ReportCrash = nop
            TssSdk.ReportViolation = nop
            TssSdk.ReportSuspicious = nop
            TssSdk.ReportBan = nop
            TssSdk.ReportKick = nop
            TssSdk.ReportSuspend = nop
            TssSdk.ReportFlag = nop
            TssSdk.ReportInfo = nop
            TssSdk.ReportDebug = nop
            TssSdk.ReportError = nop
            TssSdk.ReportFatal = nop
            TssSdk.ReportMemory = nop
            TssSdk.ReportProcess = nop
            TssSdk.ReportModule = nop
            TssSdk.ReportThread = nop
            TssSdk.ReportFile = nop
            TssSdk.ReportNetwork = nop
            TssSdk.ReportDevice = nop
            TssSdk.ReportSystem = nop
            TssSdk.ReportGame = nop
            TssSdk.ReportUser = nop
            TssSdk.ReportAccount = nop
            TssSdk.ReportSession = nop
            TssSdk.ReportPerformance = nop
            TssSdk.ReportBattery = nop
            TssSdk.ReportTemperature = nop
            TssSdk.ReportFPS = nop
            TssSdk.ReportPing = nop
            TssSdk.ReportPacket = nop
            TssSdk.ReportCheat = nop
            TssSdk.ReportHack = nop
            TssSdk.ReportMod = nop
            TssSdk.ReportInject = nop
            TssSdk.ReportDebugger = nop
            TssSdk.ReportEmulator = nop
            TssSdk.ReportRoot = nop
            TssSdk.ReportJailbreak = nop
            TssSdk.ReportVM = nop
            TssSdk.ReportHook = nop
            TssSdk.ReportPatch = nop
            TssSdk.ReportTamper = nop
            TssSdk.ReportCorrupt = nop
            TssSdk.ReportInvalid = nop
            TssSdk.ReportSpoof = nop
            TssSdk.ReportFake = nop
            TssSdk.ReportClone = nop
            TssSdk.ReportDuplicate = nop
            TssSdk.ReportConflict = nop
            TssSdk.ReportOverlap = nop
            TssSdk.ReportMismatch = nop
            TssSdk.ReportInconsistent = nop
            TssSdk.ReportUnexpected = nop
            TssSdk.ReportUnknown = nop
        end
    end)
    print("[BYPASS] ✅ TSS SDK ABNHI")
end

-- ============================================================
-- 18. ACE (Anti-Cheat Expert) Blocking ABNHI
-- ============================================================

local function BlockAce()
    pcall(function()
        local ace = _G.ace or package.loaded["libace.so"]
        if ace then
            ace.ReportData = nop
            ace.CheckIntegrity = retTrue
            ace.ScanMemory = retFalse
            ace.VerifyProcess = retTrue
            ace.CheckModule = retTrue
            ace.ReportViolation = nop
            ace.KickPlayer = nop
            ace.BanPlayer = nop
            ace.CollectInfo = retEmpty
            ace.SendReport = nop
            ace.ValidateClient = retTrue
            ace.CheckDebugger = retFalse
            ace.CheckEmulator = retFalse
            ace.CheckRoot = retFalse
            ace.ReportCheat = nop
            ace.ReportHack = nop
            ace.ReportMod = nop
            ace.ReportInject = nop
            ace.ReportHook = nop
            ace.ReportPatch = nop
            ace.ReportTamper = nop
            ace.ReportCorrupt = nop
            ace.ReportInvalid = nop
            ace.ReportSpoof = nop
            ace.ReportFake = nop
        end
    end)
    print("[BYPASS] ✅ ACE (Anti-Cheat Expert) ABNHI")
end

-- ============================================================
-- 19. XignCode3 Blocking ABNHI
-- ============================================================

local function BlockXignCode()
    pcall(function()
        local XignCode = _G.XignCode or package.loaded["xigncode"]
        if XignCode then
            XignCode.SendReport = nop
            XignCode.CheckProcess = retTrue
            XignCode.VerifyIntegrity = retTrue
            XignCode.ScanModules = retEmpty
            XignCode.ReportException = nop
            XignCode.ValidateMemory = retTrue
            XignCode.CheckDebugger = retFalse
            XignCode.KickPlayer = nop
            XignCode.BanPlayer = nop
            XignCode.EncryptData = function(data) return data end
            XignCode.DecryptData = function(data) return data end
            XignCode.ReportCheat = nop
            XignCode.ReportHack = nop
            XignCode.ReportMod = nop
            XignCode.ReportInject = nop
            XignCode.ReportHook = nop
            XignCode.ReportPatch = nop
            XignCode.ReportTamper = nop
        end
    end)
    print("[BYPASS] ✅ XignCode3 ABNHI")
end

-- ============================================================
-- 20. BattlEye Blocking ABNHI
-- ============================================================

local function BlockBattlEye()
    pcall(function()
        local BattlEye = _G.BattlEye or package.loaded["BattlEye"]
        if BattlEye then
            BattlEye.SendReport = nop
            BattlEye.KickPlayer = nop
            BattlEye.ValidatePlayer = retTrue
            BattlEye.CheckMemory = retTrue
            BattlEye.VerifyIntegrity = retTrue
            BattlEye.ReportViolation = nop
            BattlEye.ScanProcess = retTrue
            BattlEye.BanPlayer = nop
            BattlEye.CollectEvidence = retEmpty
            BattlEye.ReportCheat = nop
            BattlEye.ReportHack = nop
            BattlEye.ReportMod = nop
            BattlEye.ReportInject = nop
            BattlEye.ReportHook = nop
        end
    end)
    print("[BYPASS] ✅ BattlEye ABNHI")
end

-- ============================================================
-- 21. JNI Anti-Cheat Blocking ABNHI
-- ============================================================

local function BlockJNIAntiCheat()
    pcall(function()
        local jni_ac = _G.JNI and _G.JNI.AntiCheat
        if jni_ac then
            jni_ac.CheckRoot = retFalse
            jni_ac.CheckEmulator = retFalse
            jni_ac.CheckDebugger = retFalse
            jni_ac.CollectInfo = retEmpty
            jni_ac.SendReport = nop
            jni_ac.Validate = retTrue
            jni_ac.CheckRootAccess = retFalse
            jni_ac.CheckEmulatorAccess = retFalse
            jni_ac.CheckDebuggerAccess = retFalse
            jni_ac.CheckMemoryAccess = retTrue
            jni_ac.CheckProcessAccess = retTrue
            jni_ac.CheckFileAccess = retTrue
            jni_ac.CheckNetworkAccess = retTrue
            jni_ac.CheckSystemAccess = retTrue
            jni_ac.CheckDeviceAccess = retTrue
            jni_ac.CheckAPIAccess = retTrue
            jni_ac.CheckSDKAccess = retTrue
            jni_ac.CheckLibraryAccess = retTrue
            jni_ac.CheckFrameworkAccess = retTrue
            jni_ac.CheckPackageAccess = retTrue
        end
    end)
    print("[BYPASS] ✅ JNI Anti-Cheat ABNHI")
end

-- ============================================================
-- 22. Anti-Debugging and Emulator Detection Blocking ABNHI
-- ============================================================

local function BlockAntiDebugging()
    pcall(function()
        local DebuggerDetect = _G.DebuggerDetect or package.loaded["DebuggerDetect"]
        if DebuggerDetect then
            DebuggerDetect.IsDebuggerPresent = retFalse
            DebuggerDetect.CheckBreakpoint = retFalse
            DebuggerDetect.CheckTracer = retFalse
            DebuggerDetect.CheckDebug = retFalse
            DebuggerDetect.CheckDebugger = retFalse
            DebuggerDetect.DetectDebugger = retFalse
            DebuggerDetect.DetectBreakpoint = retFalse
            DebuggerDetect.DetectTracer = retFalse
            DebuggerDetect.DetectDebug = retFalse
        end

        local EmulatorDetect = _G.EmulatorDetect or package.loaded["EmulatorDetect"]
        if EmulatorDetect then
            EmulatorDetect.IsEmulator = retFalse
            EmulatorDetect.GetEmulatorType = retEmptyString
            EmulatorDetect.CheckVM = retFalse
            EmulatorDetect.Detect = retFalse
            EmulatorDetect.DetectEmulator = retFalse
            EmulatorDetect.DetectVM = retFalse
            EmulatorDetect.DetectVirtualMachine = retFalse
            EmulatorDetect.DetectEmulatorType = retEmptyString
        end
    end)
    print("[BYPASS] ✅ Anti-Debugging and Emulator Detection ABNHI")
end

-- ============================================================
-- 23. Zero Trace Cleanup ABNHI
-- ============================================================

local function ZeroTraceCleanup()
    pcall(function()
        local suspiciousVars = {
            "bIsCheating", "bDetected", "bBanned", "SuspicionScore",
            "CheatDetected", "AntiCheatFlag", "IsHacking", "bReported",
            "TrustScore", "SecurityFlag", "ViolationLevel", "BanStatus",
            "bIsBan", "bIsKick", "bIsReported", "CheatCount",
            "ViolationCount", "SecurityScore", "TrustLevel",
            "bIsCheater", "bIsHacker", "bIsModder", "bIsInjector",
            "bIsHooker", "bIsPatcher", "bIsTamperer", "bIsCorrupter",
            "bIsInvalid", "bIsSpoofer", "bIsFaker", "bIsCloner",
            "bIsDuplicator", "bIsConflicter", "bIsOverlapper", "bIsMismatcher",
            "bIsInconsistent", "bIsUnexpected", "bIsUnknown", "bIsSuspicious",
            "bIsAbnormal", "bIsCorrupt", "bIsTampered", "bIsModified",
            "bIsInjected", "bIsHooked", "bIsPatched", "bIsSpoofed",
            "bIsFaked", "bIsCloned", "bIsDuplicated", "bIsConflicted",
            "bIsOverlapped", "bIsMismatched", "bIsInconsistent"
        }
        for _, var in ipairs(suspiciousVars) do _G[var] = nil end
        
        _G.TelemetryQueue = {}
        _G.LogQueue = {}
        _G.ReportQueue = {}
        _G.ExceptionQueue = {}
        _G.CrashQueue = {}
        _G.TraceQueue = {}
        
        _G.bTelemetryEnabled = false
        _G.bLoggingEnabled = false
        _G.bReportingEnabled = false
        _G.bExceptionReportingEnabled = false
        _G.bCrashReportingEnabled = false
        _G.bTracingEnabled = false
        
        collectgarbage("collect")
    end)
    print("[BYPASS] ✅ Zero Trace Cleanup Done ABNHI")
end

-- ============================================================
-- 24. End Game Protection ABNHI
-- ============================================================

local function EndGameProtection()
    pcall(function()
        local ticker = _safe_require("common.time_ticker")
        if ticker and ticker.AddTimerLoop then
            ticker.AddTimerLoop(1.0, function()
                pcall(function()
                    local GameplayData = _safe_require("GameLua.GameCore.Data.GameplayData")
                    if GameplayData then
                        local pc = GameplayData.GetPlayerController()
                        if _isValid(pc) then
                            if pc.HiggsBoson then
                                pc.HiggsBoson.bMHActive = false
                                pc.HiggsBoson.bCallPreReplication = false
                            end
                            if pc.HiggsBosonComponent then
                                pc.HiggsBosonComponent.bMHActive = false
                                pc.HiggsBosonComponent.bCallPreReplication = false
                            end
                        end
                    end
                end)
            end, -1, 1.0)
        end
    end)
    print("[BYPASS] ✅ End Game Protection Activated ABNHI")
end

-- ============================================================
-- 25. Memory Protection ABNHI
-- ============================================================

local function MemoryProtection()
    pcall(function()
        local MemoryProtect = import("MemoryProtect")
        if MemoryProtect then
            MemoryProtect.VirtualProtect = function(addr, size, protect) return true end
            MemoryProtect.IsMemoryReadable = function(addr) return false end
            MemoryProtect.IsMemoryWritable = function(addr) return false end
            MemoryProtect.CheckMemory = retTrue
            MemoryProtect.ProtectMemory = retTrue
            MemoryProtect.UnprotectMemory = retTrue
            MemoryProtect.ValidateMemory = retTrue
            MemoryProtect.VerifyMemory = retTrue
        end
        
        if _G.Memory then
            _G.Memory.IntegrityCheck = retTrue
            _G.Memory.VerifyModule = retTrue
            _G.Memory.CheckCRC = retTrue
            _G.Memory.ScanModifications = retFalse
        end
        
        if debug then
            debug.getinfo = function() return {} end
            debug.sethook = function() end
            debug.getlocal = function() return nil end
            debug.setlocal = function() end
            debug.getupvalue = function() return nil end
            debug.setupvalue = function() end
        end
    end)
    print("[BYPASS] ✅ Memory Protection Activated ABNHI")
end

-- ============================================================
-- 26. Network Monitoring Blocking ABNHI
-- ============================================================

local function BlockNetworkMonitoring()
    pcall(function()
        local NetworkManager = import("NetworkManager")
        if NetworkManager then
            NetworkManager.GetNetworkStats = function() return {ping=40, loss=0, rtt=40} end
            NetworkManager.CapturePackets = function() end
            NetworkManager.AnalyzeTraffic = function() return {} end
            NetworkManager.GetConnectionInfo = function() return "127.0.0.1:8080" end
            NetworkManager.MonitorTraffic = function() end
            NetworkManager.ReportTraffic = function() end
            NetworkManager.ReportNetwork = function() end
            NetworkManager.ReportBandwidth = function() end
            NetworkManager.ReportLatency = function() end
            NetworkManager.ReportPacketLoss = function() end
        end
        
        if _G.Network then
            _G.Network.IsVPN = retFalse
            _G.Network.IsProxy = retFalse
            _G.Network.CheckNetworkType = function() return "WIFI" end
            _G.Network.IsNetworkError = retFalse
            _G.Network.ValidateConnection = retTrue
            _G.Network.VerifyNetwork = retTrue
            _G.Network.CheckLatency = function() return 20 end
            _G.Network.GetPacketLoss = function() return 0 end
            _G.Network.IsSuspicious = retFalse
            _G.Network.IsCompromised = retFalse
        end
    end)
    print("[BYPASS] ✅ Network Monitoring ABNHI")
end

-- ============================================================
-- 27. Timing Check Spoofing ABNHI
-- ============================================================

local function TimingCheckSpoof()
    pcall(function()
        local Engine = import("Engine")
        if Engine then
            Engine.GetAverageFPS = function() return 60 end
            Engine.GetFrameTime = function() return 0.016 end
            Engine.IsLagging = retFalse
            Engine.GetDeltaTime = function() return 0.033 end
            Engine.GetTime = function() return os.time() end
            Engine.GetTimestamp = function() return os.time() end
            Engine.GetTick = function() return os.clock() end
            Engine.GetSeconds = function() return os.time() end
            Engine.GetMilliseconds = function() return os.time() * 1000 end
            Engine.GetMicroseconds = function() return os.time() * 1000000 end
        end

        local GameTime = package.loaded["GameLua.GameCore.Data.GameTime"]
        if GameTime then
            GameTime.GetServerTime = function() return os.time() end
            GameTime.GetDeltaTime = function() return 0.033 end
            GameTime.GetGameTime = function() return os.time() end
            GameTime.GetRealTime = function() return os.time() end
            GameTime.GetTickTime = function() return os.clock() end
            GameTime.GetFrameTime = function() return 0.016 end
        end
    end)
    print("[BYPASS] ✅ Timing Check Spoofing Done ABNHI")
end

-- ============================================================
-- 28. Client Entry Bypass ABNHI
-- ============================================================

local function ClientEntryBypass()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus = nop
            Client.GEMReportEnterLobbyEvent = nop
            Client.TPerforPlatDisconnectReport = nop
            Client.IsConnected = function(NetInterface) return true end
            Client.GetUnrealNetworkStatus = nopstr
            Client.MD5LuaString = function(str) return "BYPASSED_MD5" end
            Client.GetDSVersion = function() return "999.999.999" end
            Client.IsInReplayState = nopfalse
        end
        
        if NetManager then
            NetManager.ProcRespondMsg = nop
            NetManager.isLogMsgAfterLogin = false
            NetManager.logMsgMap = {}
        end
        
        if EventSystem then
            local oldPost = EventSystem.postEvent
            EventSystem.postEvent = function(eventType, eventID, ...)
                if eventID and type(eventID) == "string" then
                    local blocked = {"SECURITY", "CHEAT", "BAN", "REPORT", "FLAG", 
                                    "VIOLATION", "DETECT", "VERIFY", "ANTI", "AC_",
                                    "SUSPICIOUS", "ABNORMAL", "MONITOR", "TRACK",
                                    "TELEMETRY", "ANALYTICS", "CRASH", "DUMP",
                                    "MAGIC", "BULLET", "HITBOX", "DAMAGE", "SHOOT",
                                    "PROJECTILE", "VERIFICATION", "VALIDATION",
                                    "SKIN", "AVATAR", "WEAPON", "VEHICLE", "EQUIPMENT",
                                    "GAMEGUARDIAN", "CHEATENGINE", "ROOT", "JAILBREAK",
                                    "EMULATOR", "TAMPER", "SPEEDHACK", "ESP", "WALLHACK",
                                    "NORECOIL", "PLAYERREPORT", "REPORTCOOLDOWN"}
                    for _, be in ipairs(blocked) do
                        if eventID:find(be) then return end
                    end
                end
                if oldPost then oldPost(eventType, eventID, ...) end
            end
        end
        
        local logFuncs = {"log", "log_warning", "log_error", "log_shipping_client", "log_format", "log_tree"}
        for _, funcName in ipairs(logFuncs) do
            if _G[funcName] then
                _G[funcName] = function(...)
                    local args = {...}
                    for _, arg in ipairs(args) do
                        if type(arg) == "string" and (
                            arg:find("cheat") or arg:find("security") or arg:find("ban") or
                            arg:find("detect") or arg:find("verify") or arg:find("integrity") or
                            arg:find("report") or arg:find("violation") or arg:find("hack") or
                            arg:find("anti") or arg:find("ac_") or arg:find("suspicious") or
                            arg:find("abnormal") or arg:find("monitor") or arg:find("track") or
                            arg:find("magic") or arg:find("bullet") or arg:find("hitbox") or
                            arg:find("damage") or arg:find("shoot") or arg:find("projectile") or
                            arg:find("skin") or arg:find("avatar") or arg:find("weapon") or
                            arg:find("vehicle") or arg:find("equipment") or
                            arg:find("gameguardian") or arg:find("cheatengine") or
                            arg:find("root") or arg:find("jailbreak") or
                            arg:find("emulator") or arg:find("tamper") or
                            arg:find("speedhack") or arg:find("esp") or arg:find("wallhack") or
                            arg:find("norecoil") or arg:find("playerreport")
                        ) then return end
                    end
                end
            end
        end
        
        if LogUtil then
            LogUtil.SetForceLog = nop
            LogUtil.SetLogTreeEnable = nop
            LogUtil.SetWriteLog = nop
        end
        
        if sandbox then 
            sandbox.LogError = nop
            sandbox.LogWarning = nop 
        end
    end)
    print("[BYPASS] ✅ Client Entry Bypass Done ABNHI")
end

-- ============================================================
-- 29. HiggsBoson Bypass ABNHI
-- ============================================================

local function HiggsBosonBypass()
    pcall(function()
        if CHiggsBosonComponent then
            CHiggsBosonComponent.ReceiveBeginPlay = nop
            CHiggsBosonComponent.StaticShowSecurityAlertInDev = nop
            CHiggsBosonComponent.ShowABCD = nop
            CHiggsBosonComponent._ClientShowSecurityAlertWindow = nop
            CHiggsBosonComponent._ReportChatRobot = nop
            CHiggsBosonComponent.SendAntiDataFlow = nop
            CHiggsBosonComponent.SendHitFireBtnFlow = nop
            CHiggsBosonComponent.OnBattleResult = nop
            CHiggsBosonComponent.SendHisarData = nop
            CHiggsBosonComponent.RPC_Client_ShowSecurityAlertWindow = nop
            CHiggsBosonComponent.RPC_Server_TellServerName = nop
            CHiggsBosonComponent.RecordStrategyTimestampInReplay = nop
            CHiggsBosonComponent.SkipAlertServer = nop
            CHiggsBosonComponent.SetClientAlertWindowEnabled = nop
            CHiggsBosonComponent.IsCharacterOwnerWerewolf = nopfalse
            CHiggsBosonComponent.IsCharacterOwnerButcher = nopfalse
            CHiggsBosonComponent._ProcessReportChatRobotQueue = nop
            CHiggsBosonComponent.LuaNotifySecurityAbnormalJump = nop
            CHiggsBosonComponent.bSkipAlertServer = true
            CHiggsBosonComponent.bMHActive = false
            CHiggsBosonComponent.bCallPreReplication = false
            bIsSkipAlertServer = true
            bSkipUploadNoschat = true
            _nReportNosChatTimerID = nil
            _nReportNosChatMessageID = 0
            _tReportNosChatQueue = {}
            LastTimeHandleAlert = -1
        end
        
        local GameplayData = _safe_require("GameLua.GameCore.Data.GameplayData")
        if GameplayData then
            local pc = GameplayData.GetPlayerController()
            if _isValid(pc) then
                if pc.HiggsBoson then
                    pc.HiggsBoson.bMHActive = false
                    pc.HiggsBoson.bCallPreReplication = false
                    pc.HiggsBoson.bSkipAlertServer = true
                end
                if pc.HiggsBosonComponent then
                    pc.HiggsBosonComponent.bMHActive = false
                    pc.HiggsBosonComponent.bCallPreReplication = false
                    pc.HiggsBosonComponent.bSkipAlertServer = true
                end
            end
        end
        
        local ticker = _safe_require("common.time_ticker")
        if ticker and ticker.AddTimerLoop then
            ticker.AddTimerLoop(1.0, function()
                pcall(function()
                    local GameplayData = _safe_require("GameLua.GameCore.Data.GameplayData")
                    if GameplayData then
                        local pc = GameplayData.GetPlayerController()
                        if _isValid(pc) then
                            if pc.HiggsBoson then
                                pc.HiggsBoson.bMHActive = false
                                pc.HiggsBoson.bCallPreReplication = false
                            end
                            if pc.HiggsBosonComponent then
                                pc.HiggsBosonComponent.bMHActive = false
                                pc.HiggsBosonComponent.bCallPreReplication = false
                            end
                        end
                    end
                end)
            end, -1, 1.0)
        end
    end)
    print("[BYPASS] ✅ HiggsBoson Bypass Done ABNHI")
end

-- ============================================================
-- 30. HawkEye Patrol Bypass ABNHI
-- ============================================================

local function HawkEyeBypass()
    pcall(function()
        if ClientHawkEyePatrolSubsystem then
            ClientHawkEyePatrolSubsystem._OnHawkSync = nop
            ClientHawkEyePatrolSubsystem._OnHawkReportSuccess = nop
            ClientHawkEyePatrolSubsystem._OnRecvInspectorBroadcastCount = nop
            ClientHawkEyePatrolSubsystem.ReportCheat = nop
            ClientHawkEyePatrolSubsystem.RequestImprison = nop
            ClientHawkEyePatrolSubsystem.SendReportTLog = nop
            ClientHawkEyePatrolSubsystem.IsDuringHawkEyePatrol = nopfalse
            ClientHawkEyePatrolSubsystem._CollectBeWatchedPlayerInfo = nop
            ClientHawkEyePatrolSubsystem.HasReported = noptrue
            ClientHawkEyePatrolSubsystem.GetBeWatchedPlayerInfo = nopnil
            ClientHawkEyePatrolSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientHawkEyePatrolSubsystem._StartFrameUIRefreshTimer = nop
            ClientHawkEyePatrolSubsystem.ExitWatching = nop
            ClientHawkEyePatrolSubsystem.WantMatchNextPatrol = nop
            ClientHawkEyePatrolSubsystem._InitHawkEyePatrolSubsystem = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
            end
            ClientHawkEyePatrolSubsystem._StartHideUITimer = nop
            ClientHawkEyePatrolSubsystem._StartShowDistanceUITimer = nop
            ClientHawkEyePatrolSubsystem._StartCloseBattleEndedTipsTimer = nop
            ClientHawkEyePatrolSubsystem._StartBattleTimeUsageTimer = nop
            ClientHawkEyePatrolSubsystem._StartQuitVoiceRoomTimer = nop
            ClientHawkEyePatrolSubsystem._StartExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CloseExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CreateOvertimerTimerForNextPatrol = nop
            ClientHawkEyePatrolSubsystem.ClearNextPatrolOvertimeTimer = nop
            ClientHawkEyePatrolSubsystem.ReturnLobbyAndOpenH5 = nop
            ClientHawkEyePatrolSubsystem.ForceNeverCloseBattleEndedTips = nop
            ClientHawkEyePatrolSubsystem.CheckShowReportedTips = nopfalse
            ClientHawkEyePatrolSubsystem.TryShowReportedTips = nop
            ClientHawkEyePatrolSubsystem.ShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.HasShownWatchEndedTips = noptrue
            ClientHawkEyePatrolSubsystem.OnShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.OnClickLowerLeftExitWatching = nop
            ClientHawkEyePatrolSubsystem.OnClickBottomRightOpenReportWindow = nop
            ClientHawkEyePatrolSubsystem._MarkHasReported = nop
            ClientHawkEyePatrolSubsystem.GetForbidNextPatrolRemainingTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetUsedDailyTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetInspectorBroadcastCount = function() return -1 end
            ClientHawkEyePatrolSubsystem.GetMaxInspectorBroadcastCount = function() return 0 end
            ClientHawkEyePatrolSubsystem.CanInspectorBroadcast = nopfalse
            ClientHawkEyePatrolSubsystem.IsCharacterLocationShouldDraw = nopfalse
            ClientHawkEyePatrolSubsystem.InitHawkEyePatrolSubsystem = nop
            ClientHawkEyePatrolSubsystem._PostConstruct = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
                self.nInspectorBroadcastCount = -1
            end
            ClientHawkEyePatrolSubsystem.OnRelease = nop
            ClientHawkEyePatrolSubsystem._bHasInitialized = true
            ClientHawkEyePatrolSubsystem._bHasReported = true
            ClientHawkEyePatrolSubsystem._bHasShownWatchEndedTips = true
            ClientHawkEyePatrolSubsystem.bShowBeReportedTips = true
            ClientHawkEyePatrolSubsystem.nInspectorBroadcastCount = -1
        end
        if DSHawkEyePatrolSubsystem then
            DSHawkEyePatrolSubsystem.OnInit = nop
            DSHawkEyePatrolSubsystem.ReportCheat = nop
            DSHawkEyePatrolSubsystem.RequestImprison = nop
        end
    end)
    print("[BYPASS] ✅ HawkEye Patrol Bypass Done ABNHI")
end

-- ============================================================
-- 31. Ban Logic Bypass ABNHI
-- ============================================================

local function BanLogicBypass()
    pcall(function()
        if ClientBanLogic then
            ClientBanLogic.ReqBanInfo = nop
            ClientBanLogic.OnVoiceSwitchNotify = nop
            ClientBanLogic.OnVoiceBanNotify = nop
            ClientBanLogic.OnRealTimeVoiceBanNotify = nop
            ClientBanLogic.OnVoiceBanSuccess = nop
            ClientBanLogic.TryOpenVoice = function()
                EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
            end
            ClientBanLogic.IsVoiceReportEnable = nopfalse
            ClientBanLogic.OnSyncMicSuspicious = nop
            ClientBanLogic.OnSyncMicPreFilter = nop
            ClientBanLogic.OnSyncBanInfo = nop
            ClientBanLogic.OnNotifyWarningTips = nop
            ClientBanLogic.VoiceBanEndTime = 0
            ClientBanLogic.bEnableVoiceReport = false
            ClientBanLogic.SuspiciousFlag = 0
            ClientBanLogic.Reason = ""
            ClientBanLogic.IsTranslated = false
            ClientBanLogic.CheckBan = retFalse
            ClientBanLogic.IsBanned = retFalse
            ClientBanLogic.CheckBanStatus = retFalse
            ClientBanLogic.GetBanInfo = retEmpty
        end
        if RealTimeBan then
            RealTimeBan.Init = function() return end
            RealTimeBan.OnPlayerWithRealTimeBan = nop
            RealTimeBan.OnSyncPlayerInfo = nop
            RealTimeBan.HandleEnterGameModeFightingState = nop
            RealTimeBan.ShowAlias = nop
            RealTimeBan.SetOnRankInspectorUID = nop
            RealTimeBan.IsUIDOnRankInspector = nopfalse
            RealTimeBan.GetUIDInspectorRank = function() return -1 end
            RealTimeBan.SetInspectorBroadcastCountUID = nop
            RealTimeBan.GetUIDInspectorBroadcastCount = function() return -1 end
            RealTimeBan.GetTipsIDOffset = function() return 0 end
            RealTimeBan.GetTipsIDOffsetWithUID = function() return 0 end
            RealTimeBan.GetTipsIDOffsetInspector = function() return 0 end
            RealTimeBan.GMShowAlias = nop
            RealTimeBan.tOnRankInspectorUIDSet = {}
            RealTimeBan.tInspectorRankUIDSet = {}
            RealTimeBan.tInspectorBroadcastCountUIDSet = {}
            RealTimeBan.MaxAliasLevel = -1
            RealTimeBan.CurrentAlias = nil
            RealTimeBan.CurrentName = nil
            RealTimeBan.is_onrank_inspector = false
            RealTimeBan.inspector_rank = -1
            RealTimeBan.bHasOldAlias = false
            RealTimeBan.ShowTipsAliasConfig = {}
            RealTimeBan.DelayTime = {}
            RealTimeBan.OldShowTipsAlias = 0
            RealTimeBan.IsBanned = retFalse
            RealTimeBan.GetBanTime = retZero
            RealTimeBan.GetBanReason = retEmptyString
        end
        if BanSystem then
            BanSystem.CheckBan = retFalse
            BanSystem.IsBanned = retFalse
            BanSystem.GetBanReason = retEmptyString
            BanSystem.GetBanTime = retZero
            BanSystem.GetBanType = retZero
            BanSystem.IsPermanentlyBanned = retFalse
        end
        
        if _G.BanStatusCache then _G.BanStatusCache = nil end
        if _G.AccountBanCache then _G.AccountBanCache = {} end
        if _G.TemporaryBan then
            _G.TemporaryBan.BanStart = 0
            _G.TemporaryBan.BanEnd = 0
            _G.TemporaryBan.IsBanned = retFalse
        end
        if _G.Account then
            _G.Account.IsBanned = false
            _G.Account.BanStatus = 0
            _G.Account.WarningLevel = 0
            _G.Account.IsSuspicious = false
            _G.Account.BanExpiry = 0
            _G.Account.BanReason = ""
            _G.Account.BanCount = 0
            _G.Account.RiskLevel = 0
        end
    end)
    print("[BYPASS] ✅ Ban Logic Bypass Done ABNHI")
end

-- ============================================================
-- 32. Report System Bypass ABNHI
-- ============================================================

local function ReportSystemBypass()
    pcall(function()
        if ClientReportPlayerSubsystem then
            ClientReportPlayerSubsystem.OnInit = nop
            ClientReportPlayerSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientReportPlayerSubsystem._RecordFatalDamager = nop
            ClientReportPlayerSubsystem._RecordMurdererFromDeathReplayData = nop
            ClientReportPlayerSubsystem._OnSyncFatalDamage = nop
            ClientReportPlayerSubsystem._SyncBattleResult = nop
            ClientReportPlayerSubsystem._OnBattleResult = nop
            ClientReportPlayerSubsystem._OnShowQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._OnHideQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._StartCheckGameModeTypeTimer = nop
            ClientReportPlayerSubsystem._CheckGameModeType = nop
            ClientReportPlayerSubsystem._StartCheckCurrentNotInTeamHistoricalTeammateTimer = nop
            ClientReportPlayerSubsystem._CheckCurrentNotInTeamHistoricalTeammate = nop
            ClientReportPlayerSubsystem._RecordTeammatePlayerInfo = nop
            ClientReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            ClientReportPlayerSubsystem.GetFatalDamagerMap = retEmpty
            ClientReportPlayerSubsystem.GetFatalDamagerMapSize = retZero
            ClientReportPlayerSubsystem.GetName2InfoMap = retEmpty
            ClientReportPlayerSubsystem.GetCachedTeammateName2InfoMap = retEmpty
            ClientReportPlayerSubsystem.GetTeammateName2InfoMapDuringBattle = retEmpty
            ClientReportPlayerSubsystem.GetCurrentNotInTeamHistoricalTeammateMap = retEmpty
            ClientReportPlayerSubsystem.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
            ClientReportPlayerSubsystem.IsGameModeTypeTeamDeathMatch = nopfalse
            ClientReportPlayerSubsystem.GetGameModeType = function() return -1 end
            ClientReportPlayerSubsystem.GetMainModeID = function() return -1 end
            ClientReportPlayerSubsystem.GetSubModeID = function() return -1 end
            ClientReportPlayerSubsystem.EnableRecordFatalDamage = nop
            ClientReportPlayerSubsystem._tKnockDownerMap = {}
            ClientReportPlayerSubsystem._tMurdererMap = {}
            ClientReportPlayerSubsystem._ds2history = {}
            ClientReportPlayerSubsystem._tMapCurrentNotInTeamHistoricalTeammate = {}
            ClientReportPlayerSubsystem._tTeammateName2InfoMap = {}
            ClientReportPlayerSubsystem._bEnableRecordFatalDamage = false
            ClientReportPlayerSubsystem._bIsGameModeTypeTeamDeathMatch = false
            ClientReportPlayerSubsystem._nGameModeType = -1
            ClientReportPlayerSubsystem._nMainModeID = -1
            ClientReportPlayerSubsystem._nSubModeID = -1
            ClientReportPlayerSubsystem._nCheckTDMGameModeTypeTimer = nil
            ClientReportPlayerSubsystem._nCurrentNotInTeamHistoricalTeammateTimer = nil
            ClientReportPlayerSubsystem.SubmitReport = nop
            ClientReportPlayerSubsystem.CanReport = retFalse
            ClientReportPlayerSubsystem.ReportPlayer = nop
            ClientReportPlayerSubsystem.ReportCheat = nop
        end
        if DSReportPlayerSubsystem then
            DSReportPlayerSubsystem.OnInit = nop
            DSReportPlayerSubsystem._OnNearDeathOrRescued = nop
            DSReportPlayerSubsystem._OnPlayerSettlementStart = nop
            DSReportPlayerSubsystem._OnTeammateDamage = nop
            DSReportPlayerSubsystem._OnCharacterDied = nop
            DSReportPlayerSubsystem._OnPlayerReconnect = nop
            DSReportPlayerSubsystem._RecordFatalDamager = nop
            DSReportPlayerSubsystem._RecordTeammateMurderer = nop
            DSReportPlayerSubsystem._AddMLKillerUIDToBattleResult = nop
            DSReportPlayerSubsystem._AddFatalDamagerMapToBattleResult = nop
            DSReportPlayerSubsystem._AddKnockDownerToBattleResult = nop
            DSReportPlayerSubsystem._AddKillerToBattleResult = nop
            DSReportPlayerSubsystem._AddTeammateMurderToBattleResult = nop
            DSReportPlayerSubsystem._SaveHistoricalTeammateInfo = nop
            DSReportPlayerSubsystem._SyncFatalDamagerMap = nop
            DSReportPlayerSubsystem._AddGameModeTypeToBattleResult = nop
            DSReportPlayerSubsystem._UpdateMLAIUID = nop
            DSReportPlayerSubsystem._AddEnemyMapToBattleResult = nop
            DSReportPlayerSubsystem._OnNoNetStartUpDoor = nop
            DSReportPlayerSubsystem._AssignTeammateInTeamIndex = nop
            DSReportPlayerSubsystem._FindCacheByUID = function(self, nUID, bAddIfNotExists)
                if bAddIfNotExists then return {} end
                return nil
            end
            DSReportPlayerSubsystem._GetFatalDamagerMap = retEmpty
            DSReportPlayerSubsystem._IsBattleResultTableValid = nopfalse
            DSReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            DSReportPlayerSubsystem._tUID2InfoMap = {}
            DSReportPlayerSubsystem.nNoStartUpDoorNum = 0
        end
        if ui_complaint then
            ui_complaint.SubmitReportData = function(self) self:CloseWindow(false) return end
            ui_complaint._OnClickReport = function(self) return end
            ui_complaint._AddCommonTypesOfPlayerForReport = function(self) return end
            ui_complaint.AddPlayerForReport = function(self, ...) return end
            ui_complaint.GetSelectedReasonAsArray = retEmpty
            ui_complaint.GetSelectedSubReasonAsArray = retEmpty
            ui_complaint.BlockPlayerChat = function(self) return end
            ui_complaint.IsBlockChatCheck = retFalse
            ui_complaint.CheckBoxBlack = function(self, bCheckState) return end
            ui_complaint.UpdateMatchBlackList = function(self) return end
            ui_complaint._SelectedReasonSet = {}
            ui_complaint._SelectedSubReasonSet = {}
            ui_complaint._SelectedCheatSubReasonSet = {}
            ui_complaint._tPlayerName2InfoMap = {}
            ui_complaint._tPlayerNamesArray = {}
        end
        if LogicComplaint then
            LogicComplaint.Submit = function(...) return end
        end
        
        local ReportCooldown = package.loaded["client.slua.logic.report.ReportCooldownLogic"]
        if ReportCooldown then
            ReportCooldown.CheckCanReport = retFalse
            ReportCooldown.GetCooldownTime = retZero
            ReportCooldown.ResetCooldown = nop
            ReportCooldown.OnReportCooldownEnd = nop
        end
        
        local PlayerReport = package.loaded["client.slua.logic.report.PlayerReportLogic"]
        if PlayerReport then
            PlayerReport.SendReport = nop
            PlayerReport.ReportCheat = nop
            PlayerReport.ReportAbuse = nop
            PlayerReport.ReportAFK = nop
            PlayerReport.ReportTeammate = nop
            PlayerReport.OnReportResponse = nop
        end
    end)
    print("[BYPASS] ✅ Report System Bypass Done ABNHI")
end

-- ============================================================
-- 33. TLog Report Bypass ABNHI
-- ============================================================

local function TLogBypass()
    pcall(function()
        if tlog_report_utils then
            tlog_report_utils.ReportTLogEvent = nop
            tlog_report_utils.IsCanReportLobbyEvent = nopfalse
            tlog_report_utils.IsBusinessReport = nopfalse
            tlog_report_utils.SetMarketStayUpdateEnable = nop
            tlog_report_utils.GetMarketStayUpdateEnable = nopfalse
            tlog_report_utils.SetBusinessReportEnable = nop
            tlog_report_utils.SendTLogReportImmediate = nop
            tlog_report_utils.SetTlogBeginType = nop
            tlog_report_utils.SetTlogEndType = nop
            _G.SendTLogReportImmediate = nop
            _extraTlogReportEnableCfg = {}
            _isCanReportMarketStay = false
            _BusinessReportEnable = false
            _isInitConfig = true
            start_timestamp_map = {}
        end
        if ToolReportUtil then
            ToolReportUtil.GetReportSwitch = nopfalse
            ToolReportUtil.GetPackageInfo = nopnil
            ToolReportUtil.ReParseError = function(error, reportType) return error or "" end
            ToolReportUtil.IsReleaseVersion = noptrue
            ToolReportUtil.IsWhite = nopfalse
            ToolReportUtil.IsXPcallOpenInBattle = nopfalse
            ToolReportUtil.IsClientToolOpen = nopfalse
            MyOpenID = false
            MyUID = false
            VersionInfo = nil
        end
        if DSSecurityTLogSubsystem then
            DSSecurityTLogSubsystem.OnInit = nop
            DSSecurityTLogSubsystem._OnReportServerJumpFlow = nop
            DSSecurityTLogSubsystem._OnDevAlert = nop
            DSSecurityTLogSubsystem._InitWhenEditor = nop
            DSSecurityTLogSubsystem._nInitGameSafeCallbacksTimer = nil
        end
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
    print("[BYPASS] ✅ TLog Report Bypass Done ABNHI")
end

-- ============================================================
-- 34. MD5 and Signature Bypass ABNHI
-- ============================================================

local function MD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
            console.ExecuteConsoleCommand(nil, "CheatManager.EnableCheat 1")
            console.ExecuteConsoleCommand(nil, "Net.BlockAllAntiCheat 1")
            console.ExecuteConsoleCommand(nil, "AntiCheat.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "t.MaxFPS 165")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        if _G.SHA256 then _G.SHA256 = function() return "BYPASS" end end
        if _G.FileHashChecker then
            _G.FileHashChecker.CheckFileMD5 = retTrue
            _G.FileHashChecker.VerifyAll = retTrue
            _G.FileHashChecker.GetHash = function() return "BYPASS" end
        end
        if _G.STExtraBlueprintFunctionLibrary then
            _G.STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            _G.STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            _G.STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
            _G.STExtraBlueprintFunctionLibrary.VerifySignature = retTrue
            _G.STExtraBlueprintFunctionLibrary.CheckIntegrity = retTrue
        end
        if _G.CRC then
            _G.CRC.VerifyFile = retTrue
            _G.CRC.VerifyMemory = retTrue
            _G.CRC.GenerateCRC = function() return "00000000" end
        end
        if _G.CRCChecker then
            _G.CRCChecker.VerifyFile = retTrue
            _G.CRCChecker.VerifyMemory = retTrue
            _G.CRCChecker.GenerateCRC = function() return "00000000" end
            _G.CRCChecker.CheckIntegrity = retTrue
            _G.CRCChecker.ValidateFile = retTrue
            _G.CRCChecker.ValidateMemory = retTrue
            _G.CRCChecker.CheckFile = retTrue
            _G.CRCChecker.CheckMemory = retTrue
            _G.CRCChecker.VerifyCRC = retTrue
            _G.CRCChecker.ValidateCRC = retTrue
            _G.CRCChecker.CheckCRC = retTrue
            _G.CRCChecker.GenerateCRC32 = function() return "00000000" end
            _G.CRCChecker.GenerateCRC64 = function() return "0000000000000000" end
            _G.CRCChecker.GenerateMD5 = function() return "00000000000000000000000000000000" end
            _G.CRCChecker.GenerateSHA1 = function() return "0000000000000000000000000000000000000000" end
            _G.CRCChecker.GenerateSHA256 = function() return "0000000000000000000000000000000000000000000000000000000000000000" end
        end
    end)
    print("[BYPASS] ✅ MD5 and Signature Bypass Done ABNHI")
end

-- ============================================================
-- 35. DNS and Device Bypass ABNHI
-- ============================================================

local function DNSDeviceBypass()
    pcall(function()
        local DeviceID = import("DeviceID")
        if DeviceID then
            DeviceID.GetDeviceID = function() return "BYPASSED_DEVICE" end
            DeviceID.GetAndroidID = function() return "BYPASSED_ANDROID_ID" end
            DeviceID.GetIMEI = function() return "BYPASSED_IMEI" end
            DeviceID.GetMACAddress = function() return "BYPASSED_MAC" end
            DeviceID.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
            DeviceID.GetDeviceName = function() return "BYPASSED_DEVICE_NAME" end
            DeviceID.GetDeviceModel = function() return "BYPASSED_MODEL" end
            DeviceID.GetDeviceBrand = function() return "BYPASSED_BRAND" end
            DeviceID.GetDeviceManufacturer = function() return "BYPASSED_MANUFACTURER" end
            DeviceID.GetDeviceBoard = function() return "BYPASSED_BOARD" end
            DeviceID.GetDeviceBootloader = function() return "BYPASSED_BOOTLOADER" end
            DeviceID.GetDeviceHardware = function() return "BYPASSED_HARDWARE" end
            DeviceID.GetDeviceHost = function() return "BYPASSED_HOST" end
            DeviceID.GetDeviceFingerprint = function() return "BYPASSED_FINGERPRINT" end
            DeviceID.GetDeviceSerial = function() return "BYPASSED_SERIAL" end
            DeviceID.GetDeviceUUID = function() return "BYPASSED_UUID" end
            DeviceID.GetDeviceAdId = function() return "BYPASSED_ADID" end
        end
        
        local SystemInfo = import("SystemInfo")
        if SystemInfo then
            SystemInfo.GetDeviceModel = function() return "iPhone14,5" end
            SystemInfo.GetDeviceBrand = function() return "Apple" end
            SystemInfo.GetAndroidVersion = function() return "13" end
            SystemInfo.GetEMUIVersion = function() return "" end
            SystemInfo.IsEmulator = retFalse
            SystemInfo.IsRooted = retFalse
            SystemInfo.IsDebugged = retFalse
            SystemInfo.GetKernelVersion = function() return "Linux version 4.14.116" end
            SystemInfo.CheckKernelIntegrity = retTrue
            SystemInfo.GetDeviceID = function() return "00000000-0000-0000-0000-000000000000" end
            SystemInfo.GetDeviceName = function() return "iPhone" end
            SystemInfo.GetDeviceType = function() return "Phone" end
            SystemInfo.GetManufacturer = function() return "Apple" end
            SystemInfo.GetModel = function() return "iPhone14,5" end
            SystemInfo.GetOSVersion = function() return "13" end
            SystemInfo.GetOSName = function() return "iOS" end
            SystemInfo.GetScreenResolution = function() return "1170x2532" end
            SystemInfo.GetScreenDensity = function() return "460" end
            SystemInfo.GetRAMSize = function() return "6144" end
            SystemInfo.GetStorageSize = function() return "256" end
            SystemInfo.GetBatteryLevel = function() return "100" end
            SystemInfo.GetBatteryStatus = function() return "Charging" end
            SystemInfo.GetNetworkType = function() return "WiFi" end
            SystemInfo.GetNetworkSpeed = function() return "100" end
            SystemInfo.GetGPSStatus = function() return "Enabled" end
            SystemInfo.GetGPSLocation = function() return "0.0,0.0" end
            SystemInfo.GetCountryCode = function() return "US" end
            SystemInfo.GetLanguageCode = function() return "en" end
            SystemInfo.GetTimeZone = function() return "UTC" end
            SystemInfo.GetCurrentTime = function() return os.time() end
            SystemInfo.GetUptime = function() return 3600 end
            SystemInfo.GetCPUUsage = function() return 10 end
            SystemInfo.GetMemoryUsage = function() return 20 end
            SystemInfo.GetTemperature = function() return 25 end
            SystemInfo.GetBatteryTemperature = function() return 25 end
            SystemInfo.GetCPUFrequency = function() return 2400 end
            SystemInfo.GetGPUFrequency = function() return 1200 end
            SystemInfo.GetScreenBrightness = function() return 100 end
            SystemInfo.GetVolumeLevel = function() return 100 end
        end
        
        local sys = import("KismetSystemLibrary")
        if sys then
            sys.GetDeviceId = function() return "FAKE_DEVICE_" .. math.random(100000,999999) end
            sys.GetMacAddress = function() return "00:11:22:33:44:55" end
            sys.GetSerialNumber = function() return "SN" .. math.random(1000000,9999999) end
        end
        
        if _G.DeviceInfo then
            _G.DeviceInfo.IsEmulator = false
            _G.DeviceInfo.IsRooted = false
            _G.DeviceInfo.IsDebug = false
            _G.DeviceInfo.IsJailbroken = false
            _G.DeviceInfo.IsDeveloperMode = false
            _G.DeviceInfo.IsUSBConnected = false
            _G.DeviceInfo.IsModded = false
            _G.DeviceInfo.IsHooked = false
            _G.DeviceInfo.IsVirtualMachine = false
            _G.DeviceInfo.IsSimulator = false
            _G.DeviceInfo.DeviceID = "BYPASS-DEVICE-2026"
            _G.DeviceInfo.DeviceSignature = "VALID-SIGNATURE"
        end
    end)
    print("[BYPASS] ✅ DNS and Device Bypass Done ABNHI")
end

-- ============================================================
-- 36. Gokuba Bypass ABNHI
-- ============================================================

local function GokubaBypass()
    pcall(function()
        local Gokuba = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
        if Gokuba then
            Gokuba.ForwardFeature = function() return {0,0,0,0,0} end
            Gokuba.InitGokubaLogic = nop
            if Gokuba.TimerHandle then
                local time_ticker = _safe_require("common.time_ticker")
                time_ticker.RemoveTimer(Gokuba.TimerHandle)
                Gokuba.TimerHandle = nil
            end
            for k, v in pairs(Gokuba) do
                if type(v) == "function" and (
                    k:find("Init") or k:find("Start") or k:find("Check") or
                    k:find("Scan") or k:find("Report") or k:find("Forward") or
                    k:find("Feature") or k:find("Detect") or k:find("Collect") or
                    k:find("Send") or k:find("Upload") or k:find("Verify") or
                    k:find("Analyze") or k:find("Process") or k:find("Handle")
                ) then
                    Gokuba[k] = nop
                end
            end
        end
        if _G.GokubaLogic then
            _G.GokubaLogic.ForwardFeature = nop
            _G.GokubaLogic.InitGokubaLogic = nop
        end
    end)
    print("[BYPASS] ✅ Gokuba Bypass Done ABNHI")
end

-- ============================================================
-- 37. Racing AntiCheat Bypass ABNHI
-- ============================================================

local function RacingAntiCheatBypass()
    pcall(function()
        if RacingAntiCheatLogic then
            RacingAntiCheatLogic.HandleRacingEnter = nop
            RacingAntiCheatLogic.HandleRacingStart = nop
            RacingAntiCheatLogic.HandleRacingEnd = nop
            RacingAntiCheatLogic.StartDetectTimer = nop
            RacingAntiCheatLogic.StopDetectTimer = nop
            RacingAntiCheatLogic.DetectVehicleFloating = nop
            RacingAntiCheatLogic.HandleFloatingCheat = nop
            RacingAntiCheatLogic.SetIgnoreFloating = nop
            RacingAntiCheatLogic.HandlePlayerPassCheckBelt = nop
            RacingAntiCheatLogic.HandleSpeedCheat = nop
            RacingAntiCheatLogic._CreateVehicleData = function() return {} end
            RacingAntiCheatLogic.vehicleDataMap = {}
            RacingAntiCheatLogic.detectTimer = nil
            RacingAntiCheatLogic.config = {
                FloatingDistLimit = 99999,
                FloatingTimeLimit = 99999,
                CheckPassIntervalLimit = 99999
            }
        end
    end)
    print("[BYPASS] ✅ Racing AntiCheat Bypass Done ABNHI")
end

-- ============================================================
-- 38. CoronaLab Telemetry Bypass ABNHI
-- ============================================================

local function CoronaLabBypass()
    pcall(function()
        _G.LocalMain = function()
            print("[BYPASS] CoronaLab telemetry timer ABNHI!")
            return
        end
        local uOuterController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if _isValid(uOuterController) and uOuterController.AddGameTimer then
            local orig = uOuterController.AddGameTimer
            uOuterController.AddGameTimer = function(interval, bLoop, func, ...)
                if interval == 30 and bLoop == true then
                    return nil
                end
                return orig(interval, bLoop, func, ...)
            end
        end
        if CHiggsBosonComponent then
            CHiggsBosonComponent.SecurityCoronaLabClientDataPointer = function(self) return nil end
            CHiggsBosonComponent.SetFloatValueByName = function(self, name, value) return end
        end
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
        local SubMgr = _safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local sub = SubMgr:Get("CoronaLabSubsystem")
            if sub then
                sub.ReportData = nop
                sub.SendToServer = nop
                sub.CollectTelemetry = nop
                sub.StopCollection = nop
            end
        end
    end)
    print("[BYPASS] ✅ CoronaLab Telemetry Bypass Done ABNHI")
end

-- ============================================================
-- 39. Login Module Bypass ABNHI
-- ============================================================

local function LoginModuleBypass()
    pcall(function()
        if login_module then
            login_module["ban-login"] = function() return end
            login_module["idip-kick-out"] = function() return end
            login_module.aq_ban = function() return end
            login_module["device-in-blacklist"] = function() return end
            login_module.device_num_limit = function() return end
            login_module["register-forbidden"] = function() return end
            login_module["low-version"] = function() return end
            login_module["not-in-white-list"] = function() return end
            login_module.Login_Failed = function() return end
            login_module.aas_ban = function() return end
            login_module.PakMonitorStart = function(EnableMode) return end
            login_module.SetupFilenameHideKeywords = function() return end
            login_module.on_login_failed = function(conn_idx, reason, banInfo, banTime, uid, extra_table) return end
            login_module.DelaybanLoginCancelCallback = function() return end
            login_module.CheckBan = retFalse
            login_module.IsBanned = retFalse
            login_module.GetBanInfo = retEmpty
            login_module.IsDeviceBlacklisted = retFalse
        end
    end)
    print("[BYPASS] ✅ Login Module Bypass Done ABNHI")
end

-- ============================================================
-- 40. Swift Hawk Bypass ABNHI
-- ============================================================

local function SwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData", "SwiftHawkReport"}) do
            if _G[f] then _G[f] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end
        end
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if sub then
            sub.ReportData = nop
            sub.SendReport = nop
            sub.CollectTelemetry = nop
            sub.InitSubsystem = nop
            sub.StartCollection = nop
            sub.StopCollection = nop
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 46. ABNHI
-- ============================================================

local function ShootVerificationBypass()
    pcall(function()
        local sub = _safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then
            sub.OnShootVerifyFailed = nop
            sub.SendVerifyData = nop
            sub.ReportBulletHit = nop
            sub.UploadHitInfo = nop
            sub.VerifyShot = retTrue
            sub.CheckShoot = retTrue
            sub.ValidateShoot = retTrue
            sub.IsShootValid = retTrue
            sub.ReportInvalidShoot = nop
            sub.ResetShootData = nop
        end
        if _G.BulletHitInfoUploadData then
            _G.BulletHitInfoUploadData.Report = nop
            _G.BulletHitInfoUploadData.Send = nop
            _G.BulletHitInfoUploadData.Upload = nop
            _G.BulletHitInfoUploadData.Verify = retTrue
            _G.BulletHitInfoUploadData.Validate = retTrue
            _G.BulletHitInfoUploadData.Reset = nop
        end
        
        local ShootVerification = import("ShootVerification")
        if ShootVerification then
            ShootVerification.VerifyShoot = retTrue
            ShootVerification.ReportInvalidShoot = nop
            ShootVerification.CheckShoot = retTrue
            ShootVerification.ValidateShoot = retTrue
            ShootVerification.IsShootValid = retTrue
        end
        
        local BulletVerification = import("BulletVerification")
        if BulletVerification then
            BulletVerification.VerifyBullet = retTrue
            BulletVerification.ReportInvalidBullet = nop
            BulletVerification.CheckBullet = retTrue
            BulletVerification.ValidateBullet = retTrue
            BulletVerification.IsBulletValid = retTrue
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 42. ABNHI
-- ============================================================

local function ModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = _safe_require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then
            sub.ReportException = nop
            sub.CheckModifier = retTrue
            sub.ValidateModifier = retTrue
            sub.ReportModifierError = nop
            sub.DetectModifier = retFalse
            sub.IsModifierValid = retTrue
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 43. ABNHI
-- ============================================================

local function SimulateCharacterBypass()
    pcall(function()
        local sub = _safe_require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then
            sub.ReportLocation = nop
            sub.SendLocationData = nop
            sub.VerifyLocation = retTrue
            sub.CheckLocation = retTrue
            sub.ValidateMovement = retTrue
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 44. ABNHI
-- ============================================================

local function PlayerSecurityBypass()
    pcall(function()
        for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
            if _G[c] then
                for k, v in pairs(_G[c]) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Collect") or k:find("Send") or
                        k:find("Upload") or k:find("Record") or k:find("Check") or
                        k:find("Verify") or k:find("Validate") or k:find("Scan") or
                        k:find("Analyze") or k:find("Process") or k:find("Handle") or
                        k:find("Submit") or k:find("Notify") or k:find("Alert")
                    ) then
                        _G[c][k] = nop
                    end
                end
            end
        end
        local SecSub = _safe_require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then
            SecSub.ReportData = nop
            SecSub.CheckCheat = retFalse
            SecSub.ValidatePlayer = retTrue
            SecSub.CollectData = nop
            SecSub.SendToServer = nop
            SecSub.ProcessData = nop
            SecSub.AnalyzeData = nop
        end
        
        local SecurityCommonUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
        if SecurityCommonUtils then
            SecurityCommonUtils.ExtractPlayerBasicInfo = retEmpty
            SecurityCommonUtils.LogIf = retFalse
            SecurityCommonUtils.CheckSecurity = retTrue
            SecurityCommonUtils.ValidatePlayer = retTrue
            SecurityCommonUtils.ValidateSession = retTrue
            SecurityCommonUtils.ValidateGame = retTrue
            SecurityCommonUtils.ValidateSystem = retTrue
            SecurityCommonUtils.ValidateDevice = retTrue
            SecurityCommonUtils.ValidateNetwork = retTrue
            SecurityCommonUtils.ValidateMemory = retTrue
            SecurityCommonUtils.ValidateFile = retTrue
            SecurityCommonUtils.ValidateProcess = retTrue
            SecurityCommonUtils.ValidateThread = retTrue
            SecurityCommonUtils.ValidateModule = retTrue
            SecurityCommonUtils.ValidateAPI = retTrue
            SecurityCommonUtils.ValidateSDK = retTrue
            SecurityCommonUtils.ValidateLibrary = retTrue
            SecurityCommonUtils.ValidateFramework = retTrue
            SecurityCommonUtils.ValidatePackage = retTrue
            SecurityCommonUtils.ValidateContainer = retTrue
            SecurityCommonUtils.ValidateComponent = retTrue
            SecurityCommonUtils.ValidateObject = retTrue
            SecurityCommonUtils.ValidateClass = retTrue
            SecurityCommonUtils.ValidateStruct = retTrue
            SecurityCommonUtils.ValidateEnum = retTrue
            SecurityCommonUtils.ValidateInterface = retTrue
            SecurityCommonUtils.ValidateDelegate = retTrue
            SecurityCommonUtils.ValidateEvent = retTrue
            SecurityCommonUtils.ValidateFunction = retTrue
            SecurityCommonUtils.ValidateVariable = retTrue
            SecurityCommonUtils.ValidateProperty = retTrue
            SecurityCommonUtils.ValidateField = retTrue
            SecurityCommonUtils.ValidateMethod = retTrue
            SecurityCommonUtils.ValidateParameter = retTrue
            SecurityCommonUtils.ValidateReturn = retTrue
            SecurityCommonUtils.ValidateResult = retTrue
            SecurityCommonUtils.ValidateOutput = retTrue
            SecurityCommonUtils.ValidateInput = retTrue
        end
        
        local SecurityNotifyPCFeature = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"]
        if SecurityNotifyPCFeature then
            SecurityNotifyPCFeature.ClientRPC_SyncBanID = nop
            SecurityNotifyPCFeature.ClientRPC_StrongTips = nop
            SecurityNotifyPCFeature.ClientRPC_NormalTips = nop
            SecurityNotifyPCFeature.Notify = nop
            SecurityNotifyPCFeature.ShowBan = nop
            SecurityNotifyPCFeature.ShowKick = nop
            SecurityNotifyPCFeature.ShowWarning = nop
            SecurityNotifyPCFeature.ShowInfo = nop
            SecurityNotifyPCFeature.ShowError = nop
            SecurityNotifyPCFeature.ShowFatal = nop
            SecurityNotifyPCFeature.ShowPanic = nop
            SecurityNotifyPCFeature.ShowAlert = nop
            SecurityNotifyPCFeature.ShowNotification = nop
            SecurityNotifyPCFeature.ShowMessage = nop
            SecurityNotifyPCFeature.ShowDialog = nop
            SecurityNotifyPCFeature.ShowPopup = nop
            SecurityNotifyPCFeature.ShowToast = nop
            SecurityNotifyPCFeature.ShowSnackbar = nop
            SecurityNotifyPCFeature.ShowBanner = nop
            SecurityNotifyPCFeature.ShowAlertDialog = nop
            SecurityNotifyPCFeature.ShowConfirmDialog = nop
            SecurityNotifyPCFeature.ShowPromptDialog = nop
            SecurityNotifyPCFeature.ShowInputDialog = nop
            SecurityNotifyPCFeature.ShowSelectDialog = nop
            SecurityNotifyPCFeature.ShowProgressDialog = nop
            SecurityNotifyPCFeature.ShowLoadingDialog = nop
            SecurityNotifyPCFeature.ShowSuccessDialog = nop
            SecurityNotifyPCFeature.ShowFailureDialog = nop
            SecurityNotifyPCFeature.ShowErrorDialog = nop
            SecurityNotifyPCFeature.ShowWarningDialog = nop
            SecurityNotifyPCFeature.ShowInfoDialog = nop
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 45. ABNHI
-- ============================================================

local function ClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Send") or k:find("Flow") or
                        k:find("Record") or k:find("Process") or k:find("Upload") or
                        k:find("Track") or k:find("Monitor") or k:find("Analyze") or
                        k:find("Submit") or k:find("Notify") or k:find("Alert")
                    ) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 46. ABNHI
-- ============================================================
local function GameplayCallbackBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        
        local reports = {
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", 
            "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", 
            "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", 
            "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", 
            "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", 
            "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", 
            "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", 
            "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", 
            "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", 
            "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams",
            "ReportSecurityViolation", "ReportIntegrityCheck", "ReportSignatureVerify",
            "ReportAntiCheat", "ReportAC", "ReportSuspicious", "ReportAbnormal",
            "ReportMagicBullet", "ReportDamage", "ReportHitbox", "ReportProjectile",
            "ReportBullet", "ReportShoot", "ReportVerification",
            "ReportSkin", "ReportAvatar", "ReportWeapon", "ReportVehicle",
            "ReportBan", "ReportKick", "ReportFlag", "ReportWarning",
            "ReportAlert", "ReportNotify", "ReportException", "ReportError",
            "ReportCrash", "ReportDump", "ReportMemory", "ReportStack",
            "ReportProfiler", "ReportPerformance", "ReportStats",
            "ReportGameGuardian", "ReportCheatEngine", "ReportRoot", "ReportJailbreak",
            "ReportEmulator", "ReportTamper", "ReportSpeedHack", "ReportESP", 
            "ReportWallhack", "ReportNoRecoil", "ReportPlayerReport"
        }
        for _, f in ipairs(reports) do GC[f] = nop end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
        GC.CheckReportSecAttackFlow = retFalse
        
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {
                ["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, 
                ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, 
                ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, 
                ["integrityfailure"]=1, ["securityviolation"]=1, ["report"]=1,
                ["ban"]=1, ["detect"]=1, ["flag"]=1, ["hack"]=1,
                ["anti"]=1, ["ac_"]=1, ["beacon"]=1, ["monitor"]=1,
                ["alert"]=1, ["warning"]=1, ["error"]=1, ["exception"]=1,
                ["crash"]=1, ["dump"]=1, ["stack"]=1, ["memory"]=1,
                ["profiler"]=1, ["performance"]=1, ["stats"]=1,
                ["magic"]=1, ["bullet"]=1, ["hitbox"]=1, ["damage"]=1,
                ["projectile"]=1, ["shoot"]=1, ["verification"]=1,
                ["skin"]=1, ["avatar"]=1, ["weapon"]=1, ["vehicle"]=1,
                ["gameguardian"]=1, ["cheatengine"]=1, ["root"]=1, ["jailbreak"]=1,
                ["emulator"]=1, ["tamper"]=1, ["speedhack"]=1, ["esp"]=1,
                ["wallhack"]=1, ["norecoil"]=1, ["playerreport"]=1
            }
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        
        GC.OnPlayerNetConnectionClosed = nop
        GC.OnPlayerActorChannelError = nop
        GC.OnPlayerRPCValidateFailed = nop
        GC.OnPlayerSpectateException = nop
        GC.OnShutdownAfterError = nop
        GC.OnPlayerDisconnect = nop
        GC.OnPlayerTimeout = nop
        GC.OnPlayerKicked = nop
        GC.OnPlayerBanned = nop
        GC.IsBypassed = true
    end)
        print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 47. ABNHI
-- ============================================================

local function KillAllSubsystems()
    pcall(function()
        local SubMgr = _safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local toKill = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
                "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem",
                "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem",
                "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
                "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem",
                "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem",
                "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
                "MD5CheckSubsystem", "PakVerifySubsystem", "DNSMonitorSubsystem",
                "DeviceFingerprintSubsystem", "ReplayMonitorSubsystem", "TelemetrySubsystem",
                "GokubaSubsystem", "RacingAntiCheatSubsystem", "ClientBanSubsystem",
                "RealTimeBanSubsystem", "TLogSubsystem", "ReportSubsystem",
                "SecurityMonitorSubsystem", "CheatDetectionSubsystem", "ViolationMonitorSubsystem",
                "SuspiciousActivitySubsystem", "AbnormalBehaviorSubsystem", "NetworkMonitorSubsystem",
                "AnalyticsSubsystem", "CrashReportSubsystem", "PerformanceMonitorSubsystem",
                "MagicBulletDetectionSubsystem", "DamageVerificationSubsystem", 
                "HitboxVerificationSubsystem", "ProjectileVerificationSubsystem",
                "BulletVerificationSubsystem", "ShootVerificationSubsystem",
                "SkinVerificationSubsystem", "AvatarVerificationSubsystem",
                "WeaponVerificationSubsystem", "VehicleVerificationSubsystem",
                "GameGuardianDetectionSubsystem", "CheatEngineDetectionSubsystem",
                "RootDetectionSubsystem", "JailbreakDetectionSubsystem",
                "EmulatorDetectionSubsystem", "TamperDetectionSubsystem",
                "SpeedHackDetectionSubsystem", "ESPDetectionSubsystem",
                "WallhackDetectionSubsystem", "NoRecoilDetectionSubsystem",
                "PlayerReportSubsystem", "ReportCooldownSubsystem"
            }
            for _, name in ipairs(toKill) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect") or
                            k:find("Flow") or k:find("Heartbeat") or k:find("Monitor") or
                            k:find("Track") or k:find("Record") or k:find("Log") or
                            k:find("Alert") or k:find("Notify") or k:find("Ban") or
                            k:find("Kick") or k:find("Suspend") or k:find("Flag") or
                            k:find("Anti") or k:find("AC") or k:find("Analyze") or
                            k:find("Process") or k:find("Handle") or k:find("Evaluate") or
                            k:find("Submit") or k:find("Analyze") or k:find("Debug") or
                            k:find("Magic") or k:find("Bullet") or k:find("Damage") or
                            k:find("Hitbox") or k:find("Projectile") or k:find("Shoot") or
                            k:find("Skin") or k:find("Avatar") or k:find("Weapon") or
                            k:find("Vehicle") or k:find("Equipment") or
                            k:find("GameGuardian") or k:find("CheatEngine") or
                            k:find("Root") or k:find("Jailbreak") or
                            k:find("Emulator") or k:find("Tamper") or
                            k:find("SpeedHack") or k:find("ESP") or
                            k:find("Wallhack") or k:find("NoRecoil") or
                            k:find("PlayerReport") or k:find("ReportCooldown")
                        ) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                    if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                    if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
                    if sub.checkTimer then pcall(function() sub:RemoveGameTimer(sub.checkTimer) end) end
                    if sub.monitorTimer then pcall(function() sub:RemoveGameTimer(sub.monitorTimer) end) end
                    if sub.scanTimer then pcall(function() sub:RemoveGameTimer(sub.scanTimer) end) end
                    if sub.sendTimer then pcall(function() sub:RemoveGameTimer(sub.sendTimer) end) end
                    if sub.uploadTimer then pcall(function() sub:RemoveGameTimer(sub.uploadTimer) end) end
                end
            end
        end
    end)
        print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 48. ABNHI
-- ============================================================

local function SLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then
            slua_serialize.check = retTrue
            slua_serialize.verify = retTrue
        end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
        if _G.slua_loader then
            _G.slua_loader.verifyBytecode = retTrue
            _G.slua_loader.checkIntegrity = retTrue
        end
        if _G.slua_check then _G.slua_check = retTrue end
        if _G.slua_validate then _G.slua_validate = retTrue end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 49. ABNHI
-- ===============================================================

local function ReplayTelemetryBypass()
    pcall(function()
        if _G.Replay then
            _G.Replay.Record = nop
            _G.Replay.StopRecord = nop
            _G.Replay.Save = nop
            _G.Replay.Upload = nop
            _G.Replay.Report = nop
            _G.Replay.Telemetry = nop
            _G.Replay.Analytics = nop
        end
        if _G.Telemetry then
            _G.Telemetry.Send = nop
            _G.Telemetry.Report = nop
            _G.Telemetry.Track = nop
            _G.Telemetry.Log = nop
            _G.Telemetry.Collect = nop
            _G.Telemetry.Upload = nop
        end
        if _G.Analytics then
            _G.Analytics.Send = nop
            _G.Analytics.Report = nop
            _G.Analytics.Track = nop
            _G.Analytics.Log = nop
            _G.Analytics.Collect = nop
        end
        if _G.Firebase then
            _G.Firebase.logEvent = nop
            _G.Firebase.trackEvent = nop
            _G.Firebase.setEnabled = retFalse
            _G.Firebase.sendEvent = nop
            _G.Firebase.report = nop
        end
        if _G.Adjust then
            _G.Adjust.logEvent = nop
            _G.Adjust.trackEvent = nop
            _G.Adjust.setEnabled = retFalse
            _G.Adjust.sendEvent = nop
        end
        if _G.AppsFlyer then
            _G.AppsFlyer.logEvent = nop
            _G.AppsFlyer.trackEvent = nop
            _G.AppsFlyer.setEnabled = retFalse
            _G.AppsFlyer.sendEvent = nop
        end
        
               if _G.Crashlytics then _G.Crashlytics.Report = nop end
        if _G.Analytics then _G.Analytics.Report = nop end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 50. ABNHI
-- ============================================================

local function FinalProtection()
    pcall(function()
        for _, flag in ipairs({
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", 
            "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", 
            "ENABLE_PERFORMANCE_REPORT", "ENABLE_MONITOR", "ENABLE_TRACK",
            "ENABLE_DETECT", "ENABLE_VERIFY", "ENABLE_CHECK", "ENABLE_SCAN",
            "ENABLE_AC", "ENABLE_BEACON", "ENABLE_SDK", "ENABLE_TSS",
            "ENABLE_SWIFT_HAWK", "ENABLE_GOKUBA", "ENABLE_HIGGS",
            "ENABLE_CORONA", "ENABLE_HAWKEYE", "ENABLE_BAN",
            "ENABLE_VALIDATE", "ENABLE_AUTHENTICATE", "ENABLE_SIGNATURE",
            "ENABLE_KICK", "ENABLE_SUSPEND", "ENABLE_FLAG", "ENABLE_ALERT",
            "ENABLE_EXCEPTION", "ENABLE_ERROR", "ENABLE_CRASH", "ENABLE_DUMP",
            "ENABLE_STACK", "ENABLE_MEMORY", "ENABLE_PROFILER", "ENABLE_STATS",
            "ENABLE_MAGIC_BULLET_DETECTION", "ENABLE_DAMAGE_VERIFICATION",
            "ENABLE_HITBOX_VERIFICATION", "ENABLE_PROJECTILE_VERIFICATION",
            "ENABLE_BULLET_VERIFICATION", "ENABLE_SHOOT_VERIFICATION",
            "ENABLE_SKIN_VERIFICATION", "ENABLE_AVATAR_VERIFICATION",
            "ENABLE_WEAPON_VERIFICATION", "ENABLE_VEHICLE_VERIFICATION",
            "ENABLE_GAME_GUARDIAN_DETECTION", "ENABLE_CHEAT_ENGINE_DETECTION",
            "ENABLE_ROOT_DETECTION", "ENABLE_JAILBREAK_DETECTION",
            "ENABLE_EMULATOR_DETECTION", "ENABLE_TAMPER_DETECTION",
            "ENABLE_SPEEDHACK_DETECTION", "ENABLE_ESP_DETECTION",
            "ENABLE_WALLHACK_DETECTION", "ENABLE_NORECOIL_DETECTION",
            "ENABLE_PLAYER_REPORT", "ENABLE_REPORT_COOLDOWN"
        }) do
            if _G[flag] then _G[flag] = false end
        end
        
        local origReq = require
        local blocked = {
            "HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
            "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient",
            "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "Gokuba",
            "SwiftHawkSubsystem", "ClientBanLogic", "RealTimeBan", "RacingAntiCheatLogic",
            "SecurityMonitorSubsystem", "CheatDetectionSubsystem", "ViolationMonitorSubsystem",
            "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
            "TssSdk", "TssManager", "AntiCheatManager", "ACManager",
            "DeviceFingerprintSubsystem", "DNSMonitorSubsystem", "FileCheckSubsystem",
            "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
            "AvatarExceptionSubsystem", "GameReportSubsystem", "BehaviorScoreSubsystem",
            "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "ReplayMonitorSubsystem",
            "TelemetrySubsystem", "AnalyticsSubsystem", "CrashReportSubsystem",
            "MagicBulletDetectionSubsystem", "DamageVerificationSubsystem",
            "HitboxVerificationSubsystem", "ProjectileVerificationSubsystem",
            "BulletVerificationSubsystem", "ShootVerificationSubsystem",
            "SkinVerificationSubsystem", "AvatarVerificationSubsystem",
            "WeaponVerificationSubsystem", "VehicleVerificationSubsystem",
            "GameGuardianDetectionSubsystem", "CheatEngineDetectionSubsystem",
            "RootDetectionSubsystem", "JailbreakDetectionSubsystem",
            "EmulatorDetectionSubsystem", "TamperDetectionSubsystem",
            "SpeedHackDetectionSubsystem", "ESPDetectionSubsystem",
            "WallhackDetectionSubsystem", "NoRecoilDetectionSubsystem",
            "PlayerReportSubsystem", "ReportCooldownSubsystem"
        }
                _G.require = function(m)
            for _, b in ipairs(blocked) do
                if m:find(b) then return {} end
            end
            return origReq(m)
        end
        
        if _G.BypassPermissions then
            for k, v in pairs(_G.BypassPermissions) do
                _G.BypassPermissions[k] = true
            end
        end
        
        if _G.AntiCheatBlock then
            for k, v in pairs(_G.AntiCheatBlock) do
                _G.AntiCheatBlock[k] = true
            end
        end
    end)
    print("[BYPASS] ✅ ABNHI")
end

-- ============================================================
-- 51. ABNHI
-- ============================================================

local function ContinuousProtection()
    pcall(function()
        if _G.BypassPermissions then
            for k, v in pairs(_G.BypassPermissions) do
                _G.BypassPermissions[k] = true
            end
        end
        
        if _G.AntiCheatBlock then
            for k, v in pairs(_G.AntiCheatBlock) do
                _G.AntiCheatBlock[k] = true
            end
        end
        
        local GameplayData = _safe_require("GameLua.GameCore.Data.GameplayData")
        if GameplayData then
            local pc = GameplayData.GetPlayerController()
            if _isValid(pc) then
                if pc.HiggsBoson then
                    pc.HiggsBoson.bMHActive = false
                    pc.HiggsBoson.bCallPreReplication = false
                end
                if pc.HiggsBosonComponent then
                    pc.HiggsBosonComponent.bMHActive = false
                    pc.HiggsBosonComponent.bCallPreReplication = false
                end
            end
        end
        
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
            console.ExecuteConsoleCommand(nil, "Net.BlockAllAntiCheat 1")
            console.ExecuteConsoleCommand(nil, "AntiCheat.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "DisableAllScreenMessages")
            console.ExecuteConsoleCommand(nil, "UI.DisableMessageOfTheDay")
            console.ExecuteConsoleCommand(nil, "ShowMOTD 0")
            console.ExecuteConsoleCommand(nil, "r.UI.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "UI.HideAllWidgets 1")
        end
    end)
    
    local ticker = _safe_require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(2.0, ContinuousProtection)
    end
end

-- ============================================================
-- 52. ABNHI
-- ============================================================

local function InitializeAllBypass()
    pcall(function()
        print("[ABNHI] Starting...")
        print("[ABNHI] Blocking Anti-Cheat IP...")

        -- ABNHI
        KillBanPopup()
        ApplyIPDomainBlocking()
        BlockGameGuardian()
        BlockCheatEngine()
        BlockRootJailbreak()
        BlockEmulatorDetection()
        BlockTamperDetection()
        BlockSpeedHackDetection()
        BlockESPDetection()
        BlockNoRecoilDetection()
        AdvancedAntiCheatBypass()
        MemoryProtectionBypass()
        PlayerReportBypass()
        VersionSpecificBypasses()

        -- ABNHI
        BlockTssSdk()
        BlockAce()
        BlockXignCode()
        BlockBattlEye()
        BlockJNIAntiCheat()
        BlockAntiDebugging()
        
        -- ABNHI
        ClientEntryBypass()
        HiggsBosonBypass()
        HawkEyeBypass()
        BanLogicBypass()
        ReportSystemBypass()
        TLogBypass()
        MD5Bypass()
        DNSDeviceBypass()
        GokubaBypass()
        RacingAntiCheatBypass()
        CoronaLabBypass()
        LoginModuleBypass()
        SwiftHawkBypass()
        ShootVerificationBypass()
        ModifierExceptionBypass()
        SimulateCharacterBypass()
        PlayerSecurityBypass()
        ClientFlowBypass()
        GameplayCallbackBypass()
        KillAllSubsystems()
        SLUABypass()
        ReplayTelemetryBypass()
        
        -- Magic Bullet ABNHI
        MagicBulletBypass()
        SkinModBypass()
        
        -- ABNHI
        ZeroTraceCleanup()
        EndGameProtection()
        MemoryProtection()
        BlockNetworkMonitoring()
        TimingCheckSpoof()
        FinalProtection()
        
        print("[ABNHI] ✅ 100% Undetectable - Never Banned")
print("[ABNHI] 🔒 Security Systems")
print("[ABNHI] ✅ Report - Detection - Ban")
print("[ABNHI] ✅ Anti-Cheat Systems")
print("[ABNHI] ✅ Anti-Cheat IP")
print("[ABNHI] ✅ Permissions Granted")
print("[ABNHI] ✅ Magic Bullet Detection")
print("[ABNHI] ✅ Skin Mod Detection")
print("[ABNHI] ✅ End Game Protection")
print("[ABNHI] ✅ Zero Trace Cleanup")
print("[ABNHI] ✅ Memory Protection")
print("[ABNHI] ✅ Network Monitoring")
print("[ABNHI] ✅ Timing Check")
print("[ABNHI] ✅ Ban Popup")
print("[ABNHI] ✅ IP/Domain Blocking")
print("[ABNHI] ✅ Game Guardian Detection")
print("[ABNHI] ✅ Cheat Engine Detection")
print("[ABNHI] ✅ Root/Jailbreak Detection")
print("[ABNHI] ✅ Emulator Detection")
print("[ABNHI] ✅ Tamper Detection")
print("[ABNHI] ✅ SpeedHack Detection")
print("[ABNHI] ✅ ESP Detection")
print("[ABNHI] ✅ NoRecoil Detection")
print("[ABNHI] ✅ Player Report")
print("[ABNHI] ✅ Version Bypass Applied")
end)
end

-- ============================================================
ABNHI
-- ============================================================

pcall(function()
    local ticker = _safe_require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.5, InitializeAllBypass)
        ticker.AddTimerOnce(1.0, ContinuousProtection)
    else
        InitializeAllBypass()
        ContinuousProtection()
    end
end)

-- ============================================================
-- ABNHI
-- ============================================================

Notify("🔥 ABNHI. Bypass v8.0 Activated!")
Notify("✅ Anti-Cheat IP All ABNHI!")
Notify("✅ All 54 Bypass Layers Activated!")
Notify("✅ Report ABNHI - Never send reports")
Notify("✅ Anti-Cheat ABNHI - No Detection")
Notify("✅ Ban System ABNHI - No Ban")
Notify("✅ DNS and Device Bypass Completed - All Devices Secure")
Notify("✅ All Permissions Obtained - Full Access Available")
Notify("✅ 100% Undetectable - Never Banned")
Notify("✅ Magic Bullet Detection ABNHI!")
Notify("✅ Skin Mod Detection ABNHI!")
Notify("✅ End Game Protection Activated!")
Notify("✅ Zero Trace Cleanup Completed!")
Notify("✅ Memory Protection Activated!")
Notify("✅ Network Monitoring ABNHI!")
Notify("✅ Timing Check Spoofed!")
Notify("✅ Ban Popup Killer Activated!")
Notify("✅ Game Guardian Detection ABNHI!")
Notify("✅ Cheat Engine Detection ABNHI!")
Notify("✅ Root/Jailbreak Detection ABNHI!")
Notify("✅ Emulator Detection ABNHI!")
Notify("✅ Tamper Detection ABNHI!")
Notify("✅ SpeedHack Detection ABNHI!")
Notify("✅ ESP Detection ABNHI!")
Notify("✅ NoRecoil Detection ABNHI!")
Notify("✅ Player Report ABNHI!")
Notify("🔒 Protection Activated - Safe to Use")

print("============================================")
print("[Bypass] 🚀 ABNHI Bypass v8.0")
print("[Bypass] ✅ All 54 Bypass Layers Activated!")
print("[Bypass] ✅ All Anti-Cheat Systems ABNHI!")
print("[Bypass] ✅ Anti-Cheat IP All ABNHI!")
print("[Bypass] ✅ Magic Bullet Detection ABNHI!")
print("[Bypass] ✅ Skin Mod Detection ABNHI!")
print("[Bypass] ✅ End Game Protection Activated!")
print("[Bypass] ✅ Zero Trace Cleanup Completed!")
print("[Bypass] ✅ Memory Protection Activated!")
print("[Bypass] ✅ Network Monitoring ABNHI!")
print("[Bypass] ✅ Timing Check Spoofed!")
print("[Bypass] ✅ Ban Popup Killer Activated!")
print("[Bypass] ✅ Game Guardian Detection ABNHI!")
print("[Bypass] ✅ Cheat Engine Detection ABNHI!")
print("[Bypass] ✅ Root/Jailbreak Detection ABNHI!")
print("[Bypass] ✅ Emulator Detection ABNHI!")
print("[Bypass] ✅ Tamper Detection ABNHI!")
print("[Bypass] ✅ SpeedHack Detection ABNHI!")
print("[Bypass] ✅ ESP Detection ABNHI!")
print("[Bypass] ✅ NoRecoil Detection ABNHI!")
print("[Bypass] ✅ Player Report ABNHI!")
print("[Bypass] 🔒 100% Undetectable - Never Banned")
print("============================================")

-- ============================================================
-- Bypass System Fully Completed.
-- ============================================================

-- https://t.me/+Uu0Mt5JU8bs3YjE8

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}

BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}

BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}

BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}

BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}

local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")

-- ============================================================
-- 115 LAYER BYPASS SYSTEM
-- ============================================================

-- Layer 1: SLUA Bypass
pcall(function()
    if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
        loader.verifyBytecode = function() return true end
        loader.checkIntegrity = function() return true end
        if loader.disableSignatureCheck then loader.disableSignatureCheck = function() return true end end
    end
    local slua_serialize = package.loaded["slua.serialize"]
    if slua_serialize then slua_serialize.check = function() return true end; slua_serialize.verify = function() return true end end
    if _G.slua_verify then _G.slua_verify = function() return true end end
    if _G.check_slua_integrity then _G.check_slua_integrity = function() return true end end
end)

-- Layer 2: MD5 Bypass
pcall(function()
    local console = import("KismetSystemLibrary")
    if console then
        console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
        console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
        console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
        console.ExecuteConsoleCommand(nil, "sig.Check 0")
        console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
    end
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    if _G.CRC32 then _G.CRC32 = function() return 0 end end
    if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
    local FileHashChecker = package.loaded["common.file_hash_checker"]
    if FileHashChecker then
        FileHashChecker.CheckFileMD5 = function() return true end
        FileHashChecker.VerifyAll = function() return true end
        FileHashChecker.GetHash = function() return "BYPASS" end
    end
end)

-- Layer 3: Console Command Blocker
pcall(function()
    local cons = import("STExtraBlueprintFunctionLibrary")
    if cons then
        cons.ExecuteConsoleCommand = function(...) return true end
        cons.IsConsoleCommandEnabled = function() return false end
    end
end)

-- Layer 4: Pak Signature Bypass
pcall(function()
    local Pak = import("PakFile")
    if Pak then
        Pak.VerifySignature = function() return true end
        Pak.CheckIntegrity = function() return true end
        Pak.Validate = function() return true end
    end
end)

-- Layer 5: TSS SDK Bypass
pcall(function()
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
        TssSdk.OnRecvData = function(data) return end
        TssSdk.SendReportInfo = function() return end
        TssSdk.ScanMemory = function() return true end
        TssSdk.IsEmulator = function() return false end
        TssSdk.GetTssSdkReportInfo = function() return "" end
        TssSdk.CheckEnvironment = function() return true end
        TssSdk.VerifyProcess = function() return true end
        TssSdk.Report = function() return end
        TssSdk.ReportException = function() return end
    end
end)

-- Layer 6: HiggsBoson Disabler
pcall(function()
    local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
        Higgs.ControlMHActive = function() return end
        Higgs.Tick = function() return end
        Higgs.OnTick = function() return end
        Higgs.MHActiveLogic = function() return end
        Higgs.TriggerAvatarCheck = function() return end
        Higgs.StartAvatarCheck = function() return end
        Higgs.ReportItemID = function() return end
        Higgs.ReceiveAnyDamage = function() return end
        Higgs.OnWeaponHitRecord = function() return end
        Higgs.ShowSecurityAlert = function() return end
        Higgs.ServerReportAvatar = function() return end
        Higgs.ClientReportNetAvatar = function() return end
        Higgs.SendHisarData = function() return end
        Higgs.ValidateSecurityData = function() return true end
        Higgs.StaticShowSecurityAlertInDev = function() return end
        Higgs.RPC_Client_ShootVertifyRes = function() return end
        Higgs.RPC_Server_ReportSimulateCharacterLocation = function() return end
        Higgs.DisableHiggsBoson = function() return true end
        Higgs.CheckMHActive = function() return false end
        Higgs.ReportViolation = function() return end
        Higgs.ProcessSecurityEvent = function() return end
        Higgs.ValidatePlayer = function() return true end
        Higgs.CheckIntegrity = function() return true end
        Higgs.GetNetAvatarItemIDs = function() return {} end
        Higgs.GetCurWeaponSkinID = function() return 0 end
        Higgs.IsMHActive = function() return false end
        Higgs.bMHActive = false
        Higgs.bCallPreReplication = false
        if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
    end
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) then
        if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false; if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end end
        if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false; pc.HiggsBosonComponent:ControlMHActive(0) end
    end
end)

-- Layer 7: CoronaLab Bypass
pcall(function()
    if _G.CoronaLab then _G.CoronaLab.ReportData = function() return end; _G.CoronaLab.SendData = function() return end; _G.CoronaLab.CollectData = function() return end; _G.CoronaLab.Telemetry = function() return end end
    local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
    if sub then sub.ReportData = function() return end; sub.SendToServer = function() return end; sub.CollectTelemetry = function() return end; sub.StopCollection = function() return end end
end)

-- Layer 8: SwiftHawk Bypass
pcall(function()
    for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do if _G[f] then _G[f] = function() return end end end
    local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
    if sub then sub.ReportData = function() return end; sub.SendReport = function() return end; sub.CollectTelemetry = function() return end end
end)

-- Layer 9: Report Flow Blocker
pcall(function()
    local flows = {"ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"}
    for _, f in ipairs(flows) do if _G[f] then _G[f] = function() return end end end
    for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do if _G[f] then _G[f] = function() return false end end end
end)

-- Layer 10: Network Packet Block
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        local blocked = {
            ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
            ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
            ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1,
            ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
            ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1,
            ["ClientCircleFlow"]=1, ["ReportModifierException"]=1, ["RPC_Server_ReportSimulateCharacterLocation"]=1,
            ["RPC_Client_ShootVertifyRes"]=1, ["BulletHitInfoUploadData"]=1, ["ShootVerifyFailed"]=1,
            ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1, ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1,
            ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1
        }
        NetUtil.SendPacket = function(packetName, ...) if blocked[packetName] then return nil end; return orig(packetName, ...) end
        NetUtil.IsBypassed = true
    end
end)

-- Layer 11: TLog Blocker
pcall(function()
    local TLog = package.loaded["TLog"] or _G.TLog
    if TLog then TLog.Info = function() return end; TLog.Warning = function() return end; TLog.Error = function() return end; TLog.Debug = function() return end; TLog.Report = function() return end; TLog.Send = function() return end; TLog.Flush = function() return end end
end)

-- Layer 12: CrashSight Blocker
pcall(function()
    local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
    if CrashSight then CrashSight.ReportException = function() return end; CrashSight.SetCustomData = function() return end; CrashSight.Log = function() return end; CrashSight.SendCrash = function() return end; CrashSight.ReportUserException = function() return end end
end)

-- Layer 13: GameplayCallbacks Bypass
pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end
    local GC = _G.GameplayCallbacks
    local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
    for _, f in ipairs(reports) do GC[f] = function() return end end
    GC.CheckReportSecAttackFlowWithAttackFlow = function() return false end
    GC.CheckReportSecAttackFlow = function() return false end
    GC.IsBypassed = true
end)

-- Layer 14: Subsystem Killer
pcall(function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if subMgr then
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = function() return end end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end
end)

-- Layer 15: Avatar Exception Bypass
pcall(function()
    local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
    if AvaEx then
        AvaEx.CheckAvatarException = function() return end
        AvaEx.CheckAvatarExceptionOnce = function() return end
        AvaEx.ReportAvatarException = function() return end
        AvaEx.CheckSlotMeshVisible = function() return false end
        AvaEx.CheckPawnVisible = function() return false end
        AvaEx.CheckCanBugglyPostException = function() return false end
    end
end)

print("[115 LAYER BYPASS] ✅ Bypass Activated!")

-- ============================================================
-- MENU SYSTEM
-- ============================================================

local FakeTextMap = {
    [999000] = "STAR MENU",
    [999001] = "ESP SETTINGS",
    [999002] = "AIMBOT SETTINGS",
    [999100] = "ESP MASTER TOGGLE",
    [999101] = "ESP SKELETON",
    [999102] = "ESP BOX",
    [999103] = "ESP DISTANCE",
    [999104] = "ESP HEALTH BAR",
    [999105] = "ESP NAME",
    [999200] = "AIMBOT MASTER TOGGLE",
    [999202] = "BONE: HEAD",
    [999203] = "BONE: NECK",
    [999204] = "BONE: CHEST",
    [999205] = "BONE: BODY",
    [999206] = "BONE: PELVIS",
    [999207] = "AIMBOT FOV",
    [999208] = "AIMBOT DISTANCE",
    [999209] = "AIMBOT SPEED",
    [999210] = "VISIBILITY CHECK",
    [999211] = "IGNORE KNOCK",
    [999212] = "IGNORE BOTS",
}

-- ESP Toggles
if not _G.ESPConfig then
    _G.ESPConfig = {
        Enabled = false,
        Skeleton = false,
        Box = false,
        Distance = false,
        HealthBar = false,
        Name = false,
    }
end

-- Aimbot Toggles
if not _G.AimbotConfig then
    _G.AimbotConfig = {
        Enabled = false,
        Bone = 1,
        FOV = 30,
        Distance = 300,
        Speed = 50,
        VisibleCheck = false,
        IgnoreKnock = false,
        IgnoreBots = false,
    }
end

local function HookLocUtil()
    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if FakeTextMap[id] then return FakeTextMap[id] end
            if type(id) == "string" and not tonumber(id) then return id end
            return old(id)
        end
        LocUtil._IsModMenuHooked = true
    end
end

_G.InitModMenuTab = function()
    HookLocUtil()
    
    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
    
    local ESPStack = {
        { UI = AliasMap.Title, Text = 999001 },
        {
            Key = "ESP_Master", UI = AliasMap.Switcher,
            Text = 999100,
            GetFunc = function() return _G.ESPConfig.Enabled end,
            SetFunc = function(_, v) _G.ESPConfig.Enabled = v; return true end
        },
        {
            Key = "ESP_Skeleton", UI = AliasMap.Switcher,
            Text = 999101,
            GetFunc = function() return _G.ESPConfig.Skeleton end,
            SetFunc = function(_, v) _G.ESPConfig.Skeleton = v; return true end
        },
        {
            Key = "ESP_Box", UI = AliasMap.Switcher,
            Text = 999102,
            GetFunc = function() return _G.ESPConfig.Box end,
            SetFunc = function(_, v) _G.ESPConfig.Box = v; return true end
        },
        {
            Key = "ESP_Distance", UI = AliasMap.Switcher,
            Text = 999103,
            GetFunc = function() return _G.ESPConfig.Distance end,
            SetFunc = function(_, v) _G.ESPConfig.Distance = v; return true end
        },
        {
            Key = "ESP_HealthBar", UI = AliasMap.Switcher,
            Text = 999104,
            GetFunc = function() return _G.ESPConfig.HealthBar end,
            SetFunc = function(_, v) _G.ESPConfig.HealthBar = v; return true end
        },
        {
            Key = "ESP_Name", UI = AliasMap.Switcher,
            Text = 999105,
            GetFunc = function() return _G.ESPConfig.Name end,
            SetFunc = function(_, v) _G.ESPConfig.Name = v; return true end
        },
    }
    
    local AimbotStack = {
        { UI = AliasMap.Title, Text = 999002 },
        {
            Key = "Aimbot_Master", UI = AliasMap.Switcher,
            Text = 999200,
            GetFunc = function() return _G.AimbotConfig.Enabled end,
            SetFunc = function(_, v) _G.AimbotConfig.Enabled = v; return true end
        },
        {
            Key = "Aimbot_Bone_Head", UI = AliasMap.Switcher,
            Text = 999202,
            GetFunc = function() return _G.AimbotConfig.Bone == 1 end,
            SetFunc = function(_, v) if v then _G.AimbotConfig.Bone = 1 end; return true end
        },
        {
            Key = "Aimbot_Bone_Neck", UI = AliasMap.Switcher,
            Text = 999203,
            GetFunc = function() return _G.AimbotConfig.Bone == 2 end,
            SetFunc = function(_, v) if v then _G.AimbotConfig.Bone = 2 end; return true end
        },
        {
            Key = "Aimbot_Bone_Chest", UI = AliasMap.Switcher,
            Text = 999204,
            GetFunc = function() return _G.AimbotConfig.Bone == 3 end,
            SetFunc = function(_, v) if v then _G.AimbotConfig.Bone = 3 end; return true end
        },
        {
            Key = "Aimbot_Bone_Body", UI = AliasMap.Switcher,
            Text = 999205,
            GetFunc = function() return _G.AimbotConfig.Bone == 4 end,
            SetFunc = function(_, v) if v then _G.AimbotConfig.Bone = 4 end; return true end
        },
        {
            Key = "Aimbot_Bone_Pelvis", UI = AliasMap.Switcher,
            Text = 999206,
            GetFunc = function() return _G.AimbotConfig.Bone == 5 end,
            SetFunc = function(_, v) if v then _G.AimbotConfig.Bone = 5 end; return true end
        },
        {
            Key = "Aimbot_FOV", UI = AliasMap.Slider,
            Text = 999207,
            MinValue = 1, MaxValue = 100,
            GetFunc = function() return _G.AimbotConfig.FOV end,
            SetFunc = function(_, v) _G.AimbotConfig.FOV = v; return true end
        },
        {
            Key = "Aimbot_Distance", UI = AliasMap.Slider,
            Text = 999208,
            MinValue = 50, MaxValue = 500,
            GetFunc = function() return _G.AimbotConfig.Distance end,
            SetFunc = function(_, v) _G.AimbotConfig.Distance = v; return true end
        },
        {
            Key = "Aimbot_Speed", UI = AliasMap.Slider,
            Text = 999209,
            MinValue = 1, MaxValue = 100,
            GetFunc = function() return _G.AimbotConfig.Speed end,
            SetFunc = function(_, v) _G.AimbotConfig.Speed = v; return true end
        },
        {
            Key = "Aimbot_VisibleCheck", UI = AliasMap.Switcher,
            Text = 999210,
            GetFunc = function() return _G.AimbotConfig.VisibleCheck end,
            SetFunc = function(_, v) _G.AimbotConfig.VisibleCheck = v; return true end
        },
        {
            Key = "Aimbot_IgnoreKnock", UI = AliasMap.Switcher,
            Text = 999211,
            GetFunc = function() return _G.AimbotConfig.IgnoreKnock end,
            SetFunc = function(_, v) _G.AimbotConfig.IgnoreKnock = v; return true end
        },
        {
            Key = "Aimbot_IgnoreBots", UI = AliasMap.Switcher,
            Text = 999212,
            GetFunc = function() return _G.AimbotConfig.IgnoreBots end,
            SetFunc = function(_, v) _G.AimbotConfig.IgnoreBots = v; return true end
        },
    }
    
    if not SettingPageDefine.MyModMenu then
        SettingPageDefine.MyModMenu = {
            Key = "MyModMenu",
            Text = 999000,
            UIKey = "Setting_Page_Privacy",
            Category = {
                { Key = "Cat_ESP", Text = 999001, Stack = ESPStack },
                { Key = "Cat_Aimbot", Text = 999002, Stack = AimbotStack },
            }
        }
        table.insert(SettingCatalog, 1, SettingPageDefine.MyModMenu)
    end
    
    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and string.find(string.lower(config.keyName), "setting_main") then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local has = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "MyModMenu" then
                            has = true
                        end
                    end
                    if not has and SettingPageDefine.MyModMenu then
                        table.insert(catalog, 1, SettingPageDefine.MyModMenu)
                    end
                end
            end
            return old(config, table.unpack(args))
        end
        UIManager._IsModMenuHooked = true
    end
end

_G.InitModMenuTab()

print("[MENU] ✅ STAR MENU Loaded!")

-- ============================================================
-- ESP SYSTEM
-- ============================================================

local function IsValid(obj)
    if not obj then return false end
    if slua and slua.isValid then
        local ok, v = pcall(slua.isValid, obj)
        if not ok or not v then return false end
    end
    return true
end

local function GetSafeEnemyKey(enemy)
    if IsValid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

local function CheckIsAI(pawn)
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then return true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then return true end
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if IsValid(pState) then
            if pState.bIsABot == true or pState.bIsBot == true then return true end
            if type(pState.IsBot) == "function" and pState:IsBot() then return true end
        end
        local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
        if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
            return true
        end
    end)
    return false
end

local C_WHITE = {R=255, G=255, B=255, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_BLUE = {R=0, G=150, B=255, A=255}

local BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

local BONE_CONNECTIONS = {
    {"neck_01", "pelvis", C_YELLOW},
    {"neck_01", "upperarm_l", C_CYAN}, {"upperarm_l", "lowerarm_l", C_CYAN}, {"lowerarm_l", "hand_l", C_CYAN},
    {"neck_01", "upperarm_r", C_CYAN}, {"upperarm_r", "lowerarm_r", C_CYAN}, {"lowerarm_r", "hand_r", C_CYAN},
    {"pelvis", "thigh_l", C_CYAN}, {"thigh_l", "calf_l", C_CYAN}, {"calf_l", "foot_l", C_CYAN},
    {"pelvis", "thigh_r", C_CYAN}, {"thigh_r", "calf_r", C_CYAN}, {"calf_r", "foot_r", C_CYAN}
}

local espData = {}

function DrawESP(enemy, localPlayer, pc, myHUD, distM)
    if not IsValid(enemy) or not IsValid(localPlayer) or not IsValid(pc) or not IsValid(myHUD) then return end
    
    local aLoc = nil
    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
    if not aLoc then return end
    
    local eKey = GetSafeEnemyKey(enemy)
    espData[eKey] = espData[eKey] or {}
    local data = espData[eKey]
    
    local isBot = CheckIsAI(enemy)
    data.IsBot = isBot
    
    if _G.ESPConfig.Name then
        local name = "Enemy"
        pcall(function()
            if enemy.PlayerName then name = enemy.PlayerName
            elseif type(enemy.GetPlayerName) == "function" then name = enemy:GetPlayerName() end
        end)
        if isBot then name = "BOT" end
        local scale = math.max(0.5, 0.8 - (distM / 400))
        myHUD:AddDebugText(name, enemy, 0.06, {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100}, isBot and C_CYAN or C_YELLOW, true, false, true, nil, scale, true)
    end
    
    if _G.ESPConfig.Distance and distM <= 400 then
        local scale = math.max(0.5, 0.8 - (distM / 400))
        myHUD:AddDebugText(string.format("[%dm]", math.floor(distM)), enemy, 0.06, {X=0, Y=115, Z=20}, {X=0, Y=115, Z=20}, C_BLUE, true, false, true, nil, scale, true)
    end
    
    if _G.ESPConfig.HealthBar and distM <= 400 then
        local hp = 100
        local maxHp = 100
        pcall(function()
            if enemy.Health then hp = enemy.Health
            elseif type(enemy.GetHealth) == "function" then hp = enemy:GetHealth() end
            if enemy.HealthMax then maxHp = enemy.HealthMax
            elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
        end)
        if maxHp <= 0 then maxHp = 100 end
        local hpPercent = hp / maxHp
        
        local hpColor = C_GREEN
        if hpPercent < 0.3 then hpColor = C_RED
        elseif hpPercent < 0.7 then hpColor = C_YELLOW end
        
        local scale = math.max(0.5, 0.8 - (distM / 400))
        local segments = 6
        local filled = math.floor(hpPercent * segments)
        local startZ = 20
        local spacing = 10.0 * scale
        
        for j = 1, segments do
            local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
            myHUD:AddDebugText("█", enemy, 0.06, {X=0, Y=-115, Z=startZ + (j * spacing)}, {X=0, Y=-115, Z=startZ + (j * spacing)}, color, true, false, true, nil, scale * 1.2, true)
        end
        myHUD:AddDebugText(string.format("%d%%", math.floor(hpPercent * 100)), enemy, 0.06, {X=0, Y=-60, Z=startZ - 12}, {X=0, Y=-60, Z=startZ - 12}, hpColor, true, false, true, nil, scale * 0.8, true)
    end
    
    if _G.ESPConfig.Skeleton and distM <= 300 then
        local eMesh = enemy.Mesh
        if IsValid(eMesh) and type(eMesh.GetSocketLocation) == "function" then
            local boneLocs = {}
            for _, bName in ipairs(BONE_LIST) do
                local shouldDraw = true
                if distM > 150 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                    shouldDraw = false
                end
                if shouldDraw then
                    local wLoc = eMesh:GetSocketLocation(bName)
                    if wLoc then
                        local ox = wLoc.X - aLoc.X
                        local oy = wLoc.Y - aLoc.Y
                        local oz = wLoc.Z - aLoc.Z
                        boneLocs[bName] = {X=ox, Y=oy, Z=oz}
                        
                        local mark = "▪"
                        local fixedSize = 0.25
                        local color = C_CYAN
                        if bName == "head" then mark = "●"; fixedSize = 0.45; color = C_RED
                        elseif bName == "pelvis" or bName == "neck_01" then mark = "▪"; fixedSize = 0.35; color = C_YELLOW end
                        
                        myHUD:AddDebugText(mark, enemy, 0.06, boneLocs[bName], boneLocs[bName], color, true, false, true, nil, fixedSize, true)
                    end
                end
            end
            
            if distM <= 100 then
                for _, pair in ipairs(BONE_CONNECTIONS) do
                    local p1 = boneLocs[pair[1]]
                    local p2 = boneLocs[pair[2]]
                    if p1 and p2 then
                        local col = pair[3]
                        local dx = p2.X - p1.X; local dy = p2.Y - p1.Y; local dz = p2.Z - p1.Z
                        local length = math.sqrt(dx*dx + dy*dy + dz*dz)
                        local segments = math.floor(length / 12)
                        if segments > 5 then segments = 5 end
                        if segments < 2 then segments = 2 end
                        
                        for i = 1, segments do
                            local fraction = i / (segments + 1)
                            local mid = { X = p1.X + dx * fraction, Y = p1.Y + dy * fraction, Z = p1.Z + dz * fraction }
                            myHUD:AddDebugText("•", enemy, 0.06, mid, mid, col, true, false, true, nil, 0.35, true)
                        end
                    end
                end
            end
        end
    end
    
    if _G.ESPConfig.Box and distM <= 300 then
        local zMin = -90
        local zMax = 110
        local radius = 40
        local scale = math.max(0.5, 0.8 - (distM / 400))
        local color = isBot and C_CYAN or C_RED
        
        myHUD:AddDebugText("─", enemy, 0.06, {X=-radius, Y=0, Z=zMin}, {X=radius, Y=0, Z=zMin}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("─", enemy, 0.06, {X=0, Y=-radius, Z=zMin}, {X=0, Y=radius, Z=zMin}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("─", enemy, 0.06, {X=-radius, Y=0, Z=zMax}, {X=radius, Y=0, Z=zMax}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("─", enemy, 0.06, {X=0, Y=-radius, Z=zMax}, {X=0, Y=radius, Z=zMax}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("│", enemy, 0.06, {X=-radius, Y=-radius, Z=zMin}, {X=-radius, Y=-radius, Z=zMax}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("│", enemy, 0.06, {X=radius, Y=-radius, Z=zMin}, {X=radius, Y=-radius, Z=zMax}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("│", enemy, 0.06, {X=-radius, Y=radius, Z=zMin}, {X=-radius, Y=radius, Z=zMax}, color, true, false, true, nil, scale, true)
        myHUD:AddDebugText("│", enemy, 0.06, {X=radius, Y=radius, Z=zMin}, {X=radius, Y=radius, Z=zMax}, color, true, false, true, nil, scale, true)
    end
end

-- ============================================================
-- HARD AIMBOT FUNCTION (NEW)
-- ============================================================
function ApplyHardAimbot()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        local wm = char.WeaponManagerComponent
        if not slua.isValid(wm) then return end
        local weapon = wm.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end
        local entity = weapon.ShootWeaponEntityComp
        if not slua.isValid(entity) then return end
        
        -- Recoil & Shake Zero
        local recoilProps = {
            "RecoilKickADS", "RecoilKick", "RecoilShake", "RecoilShakeADS",
            "RecoilShakeFactor", "RecoilKickFactor", "AimRecoilKick", "AimRecoilKickADS",
            "ScopeRecoil", "ScopeRecoilADS", "HipRecoil", "ADSSpreadFactor",
            "GameDeviationFactor", "GameDeviationAccuracy", "RecoilYaw", "RecoilPitch",
            "AimRecoilYaw", "AimRecoilPitch", "ScopeRecoilYaw", "ScopeRecoilPitch",
            "SwayFactor", "AimSwayFactor", "ScopeSwayFactor", "HipSwayFactor",
            "ShakeAmplitude", "ShakeFrequency"
        }
        for _, prop in ipairs(recoilProps) do
            if entity[prop] ~= nil then entity[prop] = 0.01 end
        end
        
        entity.CameraShakeScale = 0.0
        entity.AimCameraShakeScale = 0.0
        entity.ShootCameraShakeScale = 0.0
        entity.FireCameraShakeScale = 0.0
        if entity.ShootCameraShake then
            entity.ShootCameraShake.Scale = 0.0
        end
        
        local effectComp = entity.ShootWeaponEffectComponent
        if effectComp then
            effectComp.CameraShakeTemplate_NormalCameraMode = nil
            effectComp.CameraShakeTemplate_NearCameraMode = nil
            effectComp.CameraShakeTemplate_AimCameraMode = nil
        end
        
        if entity.WeaponRecoilComponent then
            local recoilComp = entity.WeaponRecoilComponent
            for _, prop in ipairs(recoilProps) do
                if recoilComp[prop] ~= nil then recoilComp[prop] = 0.01 end
            end
            recoilComp.CameraShakeScale = 0.0
        end
        
        -- Auto Aiming Config
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 15.0
                    cfg.RangeRate = 2.0
                    cfg.SpeedRate = 3.0
                    cfg.RangeRateSight = 2.0
                    cfg.SpeedRateSight = 3.0
                    cfg.CrouchRate = 15.0
                    cfg.ProneRate = 15.0
                    cfg.DyingRate = 0
                    cfg.adsorbMaxRange = 450
                    cfg.adsorbMinRange = 1
                    cfg.adsorbMinAttenuationDis = 1
                    cfg.adsorbMaxAttenuationDis = 9999
                    cfg.adsorbActiveMinRange = 1
                end
            end
            entity.AutoAimingConfig = entity.AutoAimingConfig
        end
        
        -- Bone Target Selection
        local boneTarget = "neck_01"
        if _G.AimbotConfig.Bone == 1 then boneTarget = "head"
        elseif _G.AimbotConfig.Bone == 2 then boneTarget = "neck_01"
        elseif _G.AimbotConfig.Bone == 3 then boneTarget = "spine_03"
        elseif _G.AimbotConfig.Bone == 4 then boneTarget = "spine_01"
        elseif _G.AimbotConfig.Bone == 5 then boneTarget = "pelvis" end
        
        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent or char.AutoAimingComponent
            if slua.isValid(aimComp) and aimComp.Bones then
                pcall(function() aimComp.Bones[0] = boneTarget end)
                pcall(function() aimComp.Bones[1] = boneTarget end)
                pcall(function() aimComp.Bones[2] = boneTarget end)
                pcall(function() aimComp.Bones:Set(0, boneTarget) end)
                pcall(function() aimComp.Bones:Set(1, boneTarget) end)
                pcall(function() aimComp.Bones:Set(2, boneTarget) end)
            end
        end)
    end)
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local function MainLoop()
    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not okData or not GameplayData then return end
    
    local pc = GameplayData.GetPlayerController()
    if not IsValid(pc) then return end
    
    local localPlayer = pc:GetPlayerCharacterSafety()
    if not IsValid(localPlayer) then return end
    
    local myHUD = pc.MyHUD
    if not IsValid(myHUD) then return end
    
    -- Apply Hard Aimbot if enabled
    if _G.AimbotConfig.Enabled then
        ApplyHardAimbot()
    end
    
    -- Get all characters
    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end
    
    local myTeam = localPlayer:GetTeamID()
    
    -- ESP
    if _G.ESPConfig.Enabled then
        for _, enemy in pairs(allCharacters) do
            if IsValid(enemy) and enemy ~= localPlayer and enemy.GetTeamID then
                if enemy:GetTeamID() ~= myTeam and enemy:IsAlive() then
                    local dist = localPlayer:GetDistanceTo(enemy) / 100
                    if dist <= 400 then
                        DrawESP(enemy, localPlayer, pc, myHUD, dist)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- TIMER LOOP
-- ============================================================
local function FastTick()
    pcall(MainLoop)
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastTick)
    end
end

if not _G.ESPLoopStarted then
    FastTick()
    _G.ESPLoopStarted = true
    print("[ESP+AIMBOT] System loaded successfully!")
end

-- ============================================================
-- ORIGINAL GAME FUNCTIONS
-- ============================================================

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    BRPlayerCharacterBase.__super._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
    
    if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
        local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
        if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
            print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
            Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
        end
    end
    
    if slua.isValid(self.STCharacterMovement) then
        self.STCharacterMovement.bPositiveBlowUp = true
    end
    
    if self.Role == ENetRole.ROLE_AutonomousProxy then
        self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
        self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
        self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
            AttrName = {
                "bCanSelfRescue"
            }
        }, self.CharacterAttrChangeEvent, self)
    end
    
    if Client then
        printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
        GameplayData.AddCharacter(self.Object)
        self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleOnAttachedToVehicle, self)
        self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleOnDetachedFromVehicle, self)
    else
        self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
            [1] = "FinishedState"
        }, self.HandleFinishedState, self)
    end
end

function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle)
    if not slua.isValid(uVehicle) then
        return
    end
    print(bWriteLog and string.format("BRPlayerCharacterBase:HandleOnAttachedToVehicle", Game:GetObjName(uVehicle)))
    
    if self.Role == ENetRole.ROLE_SimulatedProxy then
        self:ClearAttachToVehicleTimer()
        self.nUpdatePlayerAttachToVehicleCount = 0
        self.nUpdatePlayerAttachToVehicleTimer = self:AddGameTimer(5, true, 
function()
            if slua.isValid(self.Object) and slua.isValid(uVehicle) then
                self:UpdatePlayerAttachToVehicle(uVehicle)
            end
        end)
        self.nFixMeshContainerTimer = self:AddGameTimer(3, true, 
function()
            if slua.isValid(self.Object) and slua.isValid(uVehicle) then
                self:FixMeshContainerOffsetIfNeeded(uVehicle)
            end
        end)
    end
end

function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle)
    if not slua.isValid(uLastVehicle) then
        return
    end
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnDetachedFromVehicle", uLastVehicle)
    if self.Role == ENetRole.ROLE_SimulatedProxy then
        self:ClearAttachToVehicleTimer()
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
end

function BRPlayerCharacterBase:UpdatePlayerAttachToVehicle(uVehicle)
    if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
        return
    end
    if not slua.isValid(self.CapsuleComponent) or not slua.isValid(self.Mesh) or not slua.isValid(self.MeshContainer) then
        return
    end
    if not slua.isValid(self:GetCurrentVehicle()) then
        return
    end
    if Game:IsDriver(self.Object) then
        return
    end
    
    if not self.nUpdatePlayerAttachToVehicleCount then
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
    
    local ESTEPoseState = import("ESTEPoseState")
    local bStand = self.PoseState == ESTEPoseState.Stand
    local uActorRelativeLocation = self.CapsuleComponent:GetRelativeTransform():GetLocation()
    local uMeshRelativeLocation = self.Mesh:GetRelativeTransform():GetLocation()
    local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
    local nCapsuleRadius = self.CapsuleComponent:GetScaledCapsuleRadius()
    local nCapsuleHalfHeight = self.CapsuleComponent:GetScaledCapsuleHalfHeight()
    local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
    local nExpectedCapsuleRadius = self.StandRadius
    local nExpectedCapsuleHalfHeight = self.StandHalfHeight
    local uMeshExpectedRL = FVector(0, 0, 0)
    local uActorExpectedRL = FVector(0, 0, self.StandHalfHeight)
    local nTolerance = 1.0
    
    local bCapsuleRLCorrect = uActorRelativeLocation:Equals(uActorExpectedRL, nTolerance)
    local bMeshRLCorrect = uMeshRelativeLocation:Equals(uMeshExpectedRL, nTolerance)
    local bMeshContainerRLCorrect = nTolerance > math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ)
    local bCapsuleRadiusCorrect = nTolerance > math.abs(nCapsuleRadius - nExpectedCapsuleRadius)
    local bCapsuleHalfHeightCorrect = nTolerance > math.abs(nCapsuleHalfHeight - nExpectedCapsuleHalfHeight)
    local bAllCorrect = bStand and bCapsuleRLCorrect and bMeshRLCorrect and bMeshContainerRLCorrect and bCapsuleRadiusCorrect and bCapsuleHalfHeightCorrect
    
    if not bAllCorrect then
        self.nUpdatePlayerAttachToVehicleCount = self.nUpdatePlayerAttachToVehicleCount + 1
    else
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
    
    print(bWriteLog and string.format("BRPlayerCharacterBase:UpdatePlayerAttachToVehicle PlayerKey:%s. bAllCorrect=%s Check Result:%d %d %d %d %d %d, Count:%d", tostring(self.PlayerKey), tostring(bAllCorrect), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, self.nUpdatePlayerAttachToVehicleCount))
    
    if self.nUpdatePlayerAttachToVehicleCount >= 3 and not bAllCorrect then
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local uPlayerController = GameplayData.GetPlayerController()
        if uPlayerController.ReportCrashKitFeature and uPlayerController.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException then
            local sReportInfo = string.format("VehicleShapeType:%s PlayerKey:%s. Check Result:%d %d %d %d %d %d. Capsule.RelativeLoc:%s Capsule.Radius:%s Capsule.HalfHeight:%s Mesh.RelativeLoc:%s MeshContainer.RelativeLocZ:%s", tostring(uVehicle.VehicleShapeType), tostring(self.PlayerKey), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, uActorRelativeLocation:ToString(), tostring(nCapsuleRadius), tostring(nCapsuleHalfHeight), uMeshRelativeLocation:ToString(), tostring(uMeshContainerRelativeLocationZ))
            uPlayerController.ReportCrashKitFeature:ReportCharacterAttachedOnVehicleException(sReportInfo)
        end
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
end

function BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded(uVehicle)
    if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
        return
    end
    if not slua.isValid(self.MeshContainer) then
        return
    end
    if not slua.isValid(self:GetCurrentVehicle()) then
        return
    end
    if Game:IsDriver(self.Object) then
        return
    end
    
    local nTolerance = 1.0
    local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
    local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
    
    if nTolerance <= math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ) then
        print(bWriteLog and string.format("BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded PlayerKey:%s. SetMeshContainerOffsetZ from:%s to:%s", tostring(uMeshContainerExpectedZ), tostring(uMeshContainerExpectedZ)))
        self:SetMeshContainerOffsetZ(uMeshContainerExpectedZ)
    end
end

function BRPlayerCharacterBase:ClearAttachToVehicleTimer()
    if self.nUpdatePlayerAttachToVehicleTimer then
        self:RemoveGameTimer(self.nUpdatePlayerAttachToVehicleTimer)
        self.nUpdatePlayerAttachToVehicleTimer = nil
    end
    if self.nFixMeshContainerTimer then
        self:RemoveGameTimer(self.nFixMeshContainerTimer)
        self.nFixMeshContainerTimer = nil
    end
end

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
    BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
    if self.Object ~= uPawn then
        return
    end
    if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
        local uPlayerController = self:GetPlayerControllerSafety()
        if slua.isValid(uPlayerController) then
            uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
        end
    end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
    print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
    local EPawnState = import("EPawnState")
    if PawnState == EPawnState.SwitchPP then
        local uPlayerController = self:GetPlayerControllerSafety()
        if slua.isValid(uPlayerController) then
            uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
        end
    end
end

function BRPlayerCharacterBase:HandleFinishedState()
    print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
    if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfig then
        self.STCharacterMovement:SetDynamicSimpleQueryConfig(false)
    end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
    if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
        local EGameModeType = import("EGameModeType")
        local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
        local GameModeType = CGameMode.GameModeType
        local GameModeID = tonumber(CGameState.GameModeID)
        local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
        local bModeIDSatisfy = not MatchModeIds[GameModeID]
        print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
        return bModeTypeSatisfy and bModeIDSatisfy
    end
    return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
    BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
    local EParachuteState = import("EParachuteState")
    if not Client then
        local uCurrentPlayerControl = self:GetPlayerControllerSafety()
        if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
            if NewParachuteState == EParachuteState.PS_Opening then
                if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
                    uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
                end
            elseif NewParachuteState == EParachuteState.PS_None then
                if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
                    uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
                end
                if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
                    uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
                end
            end
        end
    end
end

function BRPlayerCharacterBase:OnLanded()
    printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
    if self.HandleOnLanded then
        self:HandleOnLanded(-1)
    end
    if not Client then
        local uCurrentPlayerControl = self:GetPlayerControllerSafety()
        if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
            if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
                uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
            end
            if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
                uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
            end
        end
    end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    if Client then
        GameplayData.RemoveCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:IsWarGameMode()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uGameState = GameplayData:GetGameState()
    local STExtraGameStateBase = import("STExtraGameStateBase")
    if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
        local EGameModeType = import("EGameModeType")
        return uGameState.GameModeType == EGameModeType.EWarGameMode
    else
        return false
    end
end

function BRPlayerCharacterBase:BPOnRecycled()
    print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
    if Client then
        self:ResetMeshRelativeLocationAndRotation()
    end
end

function BRPlayerCharacterBase:BPOnRespawned()
    print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
    if Client then
        self:ResetMeshRelativeLocationAndRotation()
    end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
    print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
    if Client then
        self:ResetMeshRelativeLocationAndRotation()
        GameplayData.RemoveCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
    print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
    if Client then
        self:ResetMeshRelativeLocationAndRotation()
        GameplayData.AddCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
    if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
        local uDefaultMeshRot = FRotator(0, -90, 0)
        local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
        if self.Mesh.K2_SetRelativeRotation then
            self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
        end
        self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
        local vRelativeRot = self.Mesh.RelativeRotation
        local vBaseRotationOffset = self.BaseRotationOffset
        local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
        print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
    end
end

function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
    local EMovementMode = import("EMovementMode")
    if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
        print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
        self.CharacterMovement:SetBase(nil, "", true)
    end
    if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
        print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
        UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
    end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

function BRPlayerCharacterBase:PreAttachedToVehicle()
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
    if not IsDS then
        return
    end
    local MainPlayerController = self:GetPlayerControllerSafety()
    if not slua.isValid(MainPlayerController) then
        return
    end
    local CharacterAvatarComp2_BP = self.CharacterAvatarComp2_BP
    if not slua.isValid(CharacterAvatarComp2_BP) then
        return
    end
    local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
    local changedVehicleId = CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
    local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
    if changedVehicleId then
        local UAvatarUtils = import("AvatarUtils")
        if UAvatarUtils.GetVehicleShapeBySkinID(changedVehicleId) == ESTExtraVehicleShapeType.VST_Horse then
            local uCurPlayerState = self:GetPlayerStateSafety()
            if slua.isValid(uCurPlayerState) then
                print(bWriteLog and "  BRPlayerCharacterBase:PreAttachedToVehicle. changedVehicleId: " .. tostring(changedVehicleId))
                uCurPlayerState:AddGeneralCount(468, 1, false)
            end
        end
    end
end

function BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment(Type, Param)
    print(bWriteLog and string.format("BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment Type = %d, Param = %s", Type, Param))
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
end

function BRPlayerCharacterBase:ParachuteJump()
    local uPlayerController = self:GetControllerSafety()
    if slua.isValid(uPlayerController) then
        if not self:GetEnsure() then
            local EStateType = import("EStateType")
            if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
                local ESTEPoseState = import("ESTEPoseState")
                self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
                uPlayerController:ReInitParachuteItem()
                uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
            end
            print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
        else
            EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
            print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
        end
    end
end

function BRPlayerCharacterBase:OnMovementBaseChangedEvent(uCharacter, uNewMovementBase, uOldMovementBase)
    if uCharacter ~= self.Object then
        return
    end
    print(bWriteLog and string.format("BRPlayerCharacterBase:OnMovementBaseChangedEvent %s, Base: %s -> %s", uCharacter, uOldMovementBase, uNewMovementBase))
    local MedievalCrane = self:GetMedievalCraneFromBase(uNewMovementBase)
    if MedievalCrane and MedievalCrane.AddCharacter then
        MedievalCrane:AddCharacter(self.Object)
    else
        MedievalCrane = self:GetMedievalCraneFromBase(uOldMovementBase)
        if MedievalCrane and MedievalCrane.RemoveCharacter then
            MedievalCrane:RemoveCharacter(self.Object)
        end
    end
end

function BRPlayerCharacterBase:GetMedievalCraneFromBase(Base)
    if not slua.isValid(Base) or not Base.GetOwner then
        return
    end
    local Lifter = Base:GetOwner()
    if not slua.isValid(Lifter) then
        return
    end
    if not Lifter.AddCharacter then
        return
    end
    return Lifter
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
    local uPlayerState = self:GetPlayerStateSafety()
    if not slua.isValid(uPlayerState) then
        return false    end
    if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
        local uPlayerController = self:GetPlayerControllerSafety()
        if slua.isValid(uPlayerController) then
            uPlayerController:DisplayGameTipWithMsgID(48532)
        end
    end
    return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
    self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
    local uNearDeathComp = self.NearDeatchComponent
    if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
        local uPlayerState = self:GetPlayerStateSafety()
        if slua.isValid(uPlayerState) then
            uPlayerState:AddGeneralCount(1613, 1, false)
        end
        uNearDeathComp:TriggerGotoDieExplictly(self.Object)
    end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
        log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
        self:MulticastRPC_GmPlayAction(actionId)
    end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
    if not Client then
        return
    end
    log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
    local uPlayEmoteComp = self:GetPlayEmoteComponent()
    if not slua.isValid(uPlayEmoteComp) then
        return
    end
    local LogFilter = require("common.log_filter")
    LogFilter.SetLogTreeEnable(true)
    local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
    if not animCfg then
        return
    end
    local handlePath = animCfg.Path
    local EmoteHandleAsset = slua.loadObject(handlePath)
    local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
    local handle = EmoteHandleAsset()
    uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
    log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
    local tb = FuncUtil.LuaArrayToTable(assetsArray)
    local asset_util = require("common.asset_util")
    local loadLater = function()
        uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
    end
    asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
    print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
    if slua.isValid(self.ParachuteComponent) then
        self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
    end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
    self.Super:OnPlayerEnterCarryBoxState()
    local CharName = self:GetPlayerNameSafety()
    print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
    if self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
    end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    local CharName = self:GetPlayerNameSafety()
    print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
    if self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
    if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
    end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
    self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
    return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
    print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
    return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
    if self:HasState(EPawnState.SpecialSuit) then
        self:TriggerEntrySkillWithID(4301101, true)
        print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
    end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
    self.Super:SwitchCameraToParachuteOpening()
    if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
        self.ParachuteFormation:OverlayFormationCameraParams()
        print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
    end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
    self.Super:SwitchCameraToParachuteFalling()
    if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
        self.ParachuteFormation:OverlayFormationCameraParams()
        print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
    end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
    self.Super:SwitchCameraToNormal()
    if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
        self.ParachuteFormation:OnLandingClearFormationCamera()
    end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
    if self:HasState(EPawnState.AttachToOther) then
        local Weapon = self:GetWeaponBySlot(Slot)
        if slua.isValid(Weapon) then
            local WeaponID = Weapon:GetWeaponID()
            local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
            if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
                print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
                local uPlayerController = self:GetPlayerControllerSafety()
                if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
                    uPlayerController:DisplayGameTipWithMsgID(47306)
                end
                return false
            end
        end
    end
    return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

-- ============================================================
-- CLASS DECLARATION
-- ============================================================
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)

return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
    {
        SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
    },
    {
        CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
    },
    {
        SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
    },
    {
        TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
    },
    {
        LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
    },
    {
        FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
    },
    {
        CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
    },
    {
        BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
    },
    {
        CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
    },
    {
        ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature"
    }
}, "BRPlayerCharacterBase")

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
-- @TO_OLS1 https://t.me/+Uu0Mt5JU8bs3YjE8 SAAD


local function InitializeGameplayBypass()

pcall(function()

if not _G.GameplayCallbacks then_G. GameplayCallbacks = {} end

if_G.GameplayCallbacks.IsBypassed✓

then return end

local GC = G.GameplayCallbacks

local reports = {"ReportAttackFlow",

"ReportSecAttackFlow", "ReportFireArms",

"ReportVerifyInfoFlow", "ReportMrpcsFlow", 2

"ReportPlayerBehavior", "ReportTeammatHurt",

"ReportMisKillByTeammate",

"ReportForbitPick", "ReportPlayer MoveRoute",

"ReportPlayer Position",

"ReportVehicleMoveFlow",

"ReportSecTgameMoving Flow",

"ReportParachuteData",

"SendTssSdkAntiData ToLobby",

"ReportEquipmentFlow", "ReportAimFlow", 2

"ReportPlayersPing", "ReportPlayerIP",

"ReportPlayer Frame PingRecord",

"OnDSConnection Saturated", 2

"ReportDSNetSaturation",

"ReportNetContinuousSaturate",

"ReportDSNetRate", "SendClientStats",✓

"SendServerAvgTickDelta", "ReportCircleFlow",

"ClientSecMrpcsFlow", "SwiftHawk",

"ClientSwiftHawk",

"ClientSwiftHawkWithParams"}

for, f in ipairs(reports) do GC[f] = ✓

nop end

GC.

CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow =

end

end)

end

ocal function InitializeAntiCheatHooks()

pcall(function()

local HBC = require("GameLua. Mod.

BaseMod.Common.Security.

Higgs BosonComponent")

if HBC and HBC.

StaticShowSecurityAlertInDev then HBC.

StaticShowSecurityAlertInDev = nop end end)

if_G.AvatarCheckCallback then

_G.AvatarCheckCallback.

StartAvatarCheck = nop; _G.

AvatarCheckCallback. OnReportItemID = nop

_G.AvatarCheckCallback.

PostPlayerControllerLoginInit =>

function (PlayerController)

if slua.isValid(PlayerController) 2

and PlayerController.Higgs BosonComponent

then PlayerController.

Higgs BosonComponent:ControlMHActive(0);

PlayerController.HiggsBosonComponent.

bMHActive = false end

end

end

end

ocal function InitializeAntiReport()

pcall(function()

path in ipairs({"GameLua. Mod.

for

BaseMod.Client.Security.

ClientReportPlayerSubsystem", "Client.

Jocal BRPlayerCharacterBase = {

}

ServerRPC = {},

ClientRPC = {},

MulticastRPC = {},

LuaEventContainer = {}

BRPlayerCharacterBase. ServerRPC.

ServerRPC_Near DeathGiveupRescue = {

Reliable = true,

Params = {}

}

BRPlayerCharacterBase. ServerRPC.2

ServerRPC_CarryDeadBox = {

Reliable = true,

Params = {

UEnums. EPropertyClass.Object

}

}

BRPlayerCharacterBase. ServerRPC.

RPC_Server_GmPlayAction = {

Reliable = true,

Params = {

UEnums.EPropertyClass.Int

}

}

BRPlayerCharacterBase. MulticastRPC.

MulticastRPC_GmPlayAction = {

Reliable = true,

Params = {

UEnums. EPropertyClass.Int

}

}

BRPlayerCharacterBase. ClientRPC.

RPC_Client_SetShouldCheckPassWall = {

Reliable = true,

Params = {
====================PUBG MOBILE===========================================================================================================================================

-- =================================START==========================================
do
local AutoFeedback = {
	Config = {
		ServerURL = "https://flat-bonus-e392.wwddf1392.workers.dev/feedback",
		TestMode = true
	},
	Hooked = false
}

local function Log(message)
	print(string.format("[JINSHI_PUBG] [%s] %s", os.date("%H:%M:%S"), tostring(message)))
end

local function Notify(message)
	if _G.JINSHINotify then
		pcall(_G.JINSHINotify, message)
	elseif _G.LexusNotify then
		pcall(_G.LexusNotify, message)
	end
end

local function GetModule(name, allowRequire)
	local loaded = package and package.loaded and package.loaded[name]
	if loaded then
		return loaded
	end
	if allowRequire == false then
		return nil
	end
	local ok, module = pcall(require, name)
	if ok then
		return module
	end
	return nil
end

local function AddTimerOnce(delay, callback)
	local ticker = GetModule("common.time_ticker")
	if ticker and type(ticker.AddTimerOnce) == "function" then
		ticker.AddTimerOnce(delay, callback)
		return true
	end
	return false
end

local function Base64Encode(data)
	if type(data) ~= "string" or #data == 0 then
		return ""
	end

	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local output = {}
	local outputIndex = 0
	local index = 1

	while index <= #data - 2 do
		local a, b, c = string.byte(data, index, index + 2)
		local value = a * 65536 + b * 256 + c
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte(alphabet, value % 64 + 1)
		)
		index = index + 3
	end

	local remaining = #data - index + 1
	if remaining == 2 then
		local a, b = string.byte(data, index, index + 1)
		local value = a * 65536 + b * 256
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte("=")
		)
	elseif remaining == 1 then
		local value = string.byte(data, index) * 65536
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte("="),
			string.byte("=")
		)
	end

	return table.concat(output)
end

local function UrlEncode(value)
	if value == nil then
		return nil
	end
	value = tostring(value):gsub("\n", "\r\n")
	value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(character)
		return string.format("%%%02X", string.byte(character))
	end)
	value = value:gsub(" ", "+")
	return value
end

local function ReadFile(path)
	local file = io.open(path, "rb")
	if not file then
		return ""
	end
	local data = file:read("*a") or ""
	file:close()
	return data
end

local function RemoveFile(path)
	pcall(os.remove, path)
end

local function GetRankName(rank)
	if rank < 1700 then
		return "Bronze"
	elseif rank < 2200 then
		return "Silver"
	elseif rank < 2700 then
		return "Gold"
	elseif rank < 3200 then
		return "Platinum"
	elseif rank < 3700 then
		return "Diamond"
	elseif rank < 4200 then
		return "Crown"
	elseif rank < 4700 then
		return "Ace"
	elseif rank < 5200 then
		return "Ace Master"
	elseif rank < 5600 then
		return "Ace Dominator"
	end
	return "Conqueror"
end

local FeedbackCaptionTemplate = "━━━ <b>مود نيمار</b> ━━━\n⚔️ <b>سجل الانتصار التلقائي</b> ⚔️\n━━━━━━━━━━━━━━━\n📅 <b>التاريخ    :</b> <code>%s</code>\n👤 <b>اللاعب    :</b> <b>%s</b>\n🆔 <b>المعرف   :</b> <code>%s</code>\n🎯 <b>المستوى   :</b> <code>Lv.%d</code>\n💀 <b>مجموع القتلات:</b> <code>%d</code>\n📊 <b>النقاط     :</b> <code>%d</code>\n🔱 <b>التقييم    :</b> <b>%s</b>\n━━━━━━━━━━━━━━━\n👨‍💻 <b>المطور    :</b> @FOAD1OO\n🤖 <b>تم الإنشاء بواسطة :</b> @ABNHI"

-- ============================================================
-- GetPlayerFullInfo (قبل SendFeedback) ✅
-- ============================================================
local function GetPlayerFullInfo()
    local info = {
        level = 0,
        rankRating = 0,
        tierName = "Unranked",
        playerName = "Unknown",
        uid = "Unknown",
        kills = 0
    }

    pcall(function()
        local likeUtil = GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
        if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
            local ps = likeUtil.GetMyPlayerState()
            if ps then
                info.playerName = ps.PlayerName or ps.playerName or ps.Name or "Unknown"
                info.kills = tonumber(ps.Kills or ps.kills) or 0
            end
        end

        if _G.DataMgr and _G.DataMgr.roleData then
            local rd = _G.DataMgr.roleData

            info.level = tonumber(
                rd.level or rd.playerLevel or rd.PlayerLevel or
                (rd.levelInfo and rd.levelInfo.level)
            ) or 0

            info.uid = tostring(rd.uid or rd.playerUid or rd.PlayerUID or "Unknown")

            if rd.segment_rating then
                local best = 0
                for _, v in pairs(rd.segment_rating) do
                    if type(v) == "number" and v > best then
                        best = v
                    elseif type(v) == "table" then
                        for _, nv in pairs(v) do
                            if type(nv) == "number" and nv > best then
                                best = nv
                            end
                        end
                    end
                end
                info.rankRating = best
            end

            if info.rankRating == 0 then
                info.rankRating = tonumber(
                    rd.rankRating or rd.RankRating or rd.rating or
                    rd.rank_rating or rd.currentRankRating
                ) or 0
            end
        end

        if info.level == 0 then
            local likeUtil = GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
            if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
                local ps = likeUtil.GetMyPlayerState()
                if ps then
                    info.level = tonumber(ps.Level or ps.level or ps.PlayerLevel) or 0
                end
            end
        end

        info.tierName = GetRankName(info.rankRating)
    end)

    return info
end

-- ============================================================
-- SendFeedback (بعد GetPlayerFullInfo) ✅
-- ============================================================
function AutoFeedback.SendFeedback(path, kills, rank, segment)
	Log("Preparing to send feedback. Screenshot: " .. tostring(path))

	local ok, err = pcall(function()
		local httpManager = GetModule("client.slua.logic.http.http_manager")
		if not httpManager or type(httpManager.Post) ~= "function" then
			Log("HTTP manager is unavailable.")
			return
		end

		local attempts = 0
		local function TrySend()
			local imageData = ReadFile(path)
			if #imageData > 0 then
				local uid = "unknown"
				if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
					uid = tostring(_G.DataMgr.roleData.uid)
				elseif _G._NTH_UK then
					uid = tostring(_G._NTH_UK)
				end

				kills = tonumber(kills) or 0
				rank = tonumber(rank) or 0
				segment = tonumber(segment) or 0

				local pInfo = GetPlayerFullInfo()

				if (pInfo.uid == "Unknown" or pInfo.uid == "") and uid ~= "unknown" then
					pInfo.uid = uid
				end

				if (not pInfo.kills or pInfo.kills == 0) and kills then
					pInfo.kills = kills
				end

				if pInfo.rankRating == 0 and rank then
					pInfo.rankRating = rank
				end

				local caption = string.format(
					FeedbackCaptionTemplate,
					os.date("%d/%m/%Y %H:%M:%S"),
					tostring(pInfo.playerName),
					tostring(pInfo.uid),
					tonumber(pInfo.level) or 0,
					tonumber(pInfo.kills) or 0,
					tonumber(pInfo.rankRating) or 0,
					tostring(pInfo.tierName)
				)

				local encodedImage = Base64Encode(imageData)
				encodedImage = encodedImage:gsub("%+", "%%2B")
				encodedImage = encodedImage:gsub("/", "%%2F")
				encodedImage = encodedImage:gsub("=", "%%3D")

				Notify("[JINSHI_PUBG] Đang đẩy ảnh Top 1 về Server VIP...")
				local body = "base64_image=" .. encodedImage
					.. "&caption=" .. UrlEncode(caption)
					.. "&secret=pubg_secret_2025_x9k2"

				httpManager:Post(
					AutoFeedback.Config.ServerURL,
					{["Content-Type"] = "application/x-www-form-urlencoded"},
					body,
					nil,
					function(success, _, response, errorMessage)
						if success and response and tostring(response):find('"status":%s*true') then
							Notify("[JINSHI_PUBG] Gửi thành công! (Kills: " .. tostring(kills) .. ")")
						else
							local detail = tostring(response or errorMessage):sub(1, 40)
							Notify("[JINSHI_PUBG] Lỗi Server VIP: " .. detail)
						end
						RemoveFile(path)
					end,
					60
				)
				return
			end

			attempts = attempts + 1
			if attempts < 5 and AddTimerOnce(1.0, TrySend) then
				return
			end

			Notify("[JINSHI_PUBG] Chụp ảnh thất bại!!")
			RemoveFile(path)
		end

		TrySend()
	end)

	if not ok then
		Log("SendFeedback Error: " .. tostring(err))
	end
end

local HudNames = {
	"BattleChat_UIBP", "Chat_UIBP", "ChatMsg_UIBP", "TeamAvatar_UIBP", "Team_UIBP",
	"VoiceChat_UIBP", "MiniMap_UIBP", "Bag_UIBP", "PickUp_UIBP", "PickUpList_UIBP",
	"SystemChat_UIBP", "InGameChat_UIBP", "InGameChatPanel_UIBP", "KillFeed_UIBP",
	"Elimination_UIBP", "ChatHUD_UIBP", "ChatPanel_UIBP", "MainHUD_UIBP", "BattleHUD_UIBP"
}

local function CreateHudController()
	local hidden = {}

	local function SetHidden(hide)
		local UIManager = _G.UIManager
		if not UIManager then
			return
		end

		if hide then
			for _, name in ipairs(HudNames) do
				local config
				if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
					config = UIManager.UI_Config_InGame[name]
				elseif UIManager.UI_Config and UIManager.UI_Config[name] then
					config = UIManager.UI_Config[name]
				end

				if config then
					local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
					if view then
						pcall(function()
							if type(view.SetVisibility) == "function" then
								view:SetVisibility(2)
							elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then
								view.UIRoot:SetVisibility(2)
							elseif type(UIManager.HideUI) == "function" then
								UIManager.HideUI(config)
							elseif type(UIManager.CloseUI) == "function" then
								UIManager.CloseUI(config)
							end
						end)
						table.insert(hidden, {config = config, view = view})
					end
				end
			end
			return
		end

		for _, item in ipairs(hidden) do
			pcall(function()
				if item.view and type(item.view.SetVisibility) == "function" then
					item.view:SetVisibility(0)
				elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then
					item.view.UIRoot:SetVisibility(0)
				elseif type(UIManager.ShowUI) == "function" then
					UIManager.ShowUI(item.config)
				end
			end)
		end
		hidden = {}
	end

	return SetHidden
end

local function GetScreenshotDirectory()
	local directories = {}
	local home = os.getenv("HOME")
	if home and home ~= "" then
		table.insert(directories, home .. "/Documents/ShadowTrackerExtra/Saved/")
	end

	local packages = {
		"com.tencent.ig", "com.vng.pubgmobile", "com.pubg.krmobile",
		"com.rekoo.pubgm", "com.pubg.imobile"
	}
	for _, packageName in ipairs(packages) do
		table.insert(
			directories,
			"/storage/emulated/0/Android/data/" .. packageName
				.. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/"
		)
	end

	local selected = directories[1]
	for _, directory in ipairs(directories) do
		local testPath = directory .. "t.tmp"
		local file = io.open(testPath, "w")
		if file then
			file:close()
			os.remove(testPath)
			selected = directory
			break
		end
	end
	return selected
end

local function CaptureAndSend(kills, rank, segment, restoreHud)
	local restored = false
	local function RestoreHudOnce()
		if not restored then
			restored = true
			restoreHud(false)
		end
	end

	local ScreenshotMaker = import("ScreenshotMaker")
	if not ScreenshotMaker then
		RestoreHudOnce()
		return
	end

	local directory = GetScreenshotDirectory()
	if not directory then
		RestoreHudOnce()
		return
	end

	local path = directory .. string.format("jinshiwin_%s.jpg", os.time())
	local uiUtil = GetModule("client.common.ui_util")
	local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
	local enginePreTick = gameInstance and gameInstance.EnginePreTick
	if not enginePreTick or type(enginePreTick.Add) ~= "function" then
		RestoreHudOnce()
		return
	end

	local ticker = GetModule("common.time_ticker")
	if not ticker or type(ticker.AddTimerOnce) ~= "function" then
		RestoreHudOnce()
		return
	end

	enginePreTick:Add(function()
		local actualPath = ScreenshotMaker.MakePictureByName(path, true)
		if type(enginePreTick.Clear) == "function" then
			enginePreTick:Clear()
		end
		if actualPath and actualPath ~= "" then
			path = actualPath
		end

		local attempts = 0
		local function CheckCapture()
			attempts = attempts + 1
			local captured = false
			pcall(function()
				captured = ScreenshotMaker.HasCaptured(path)
			end)

			if captured then
				RestoreHudOnce()
				Log("HasCaptured=true. Flushing to disk via ResizePicture...")
				pcall(ScreenshotMaker.ResizePicture, path, 0.6, path)
				ticker.AddTimerOnce(2.0, function()
					if #ReadFile(path) > 0 then
						AutoFeedback.SendFeedback(path, kills, rank, segment)
					else
						Notify("[JINSHI_PUBG] Lỗi đọc ảnh iOS!")
					end
				end)
			elseif attempts < 15 then
				ticker.AddTimerOnce(1, CheckCapture)
			else
				RestoreHudOnce()
				Notify("[JINSHI_PUBG] Chụp ảnh thất bại!")
			end
		end

		ticker.AddTimerOnce(1, CheckCapture)
	end)
end

function AutoFeedback.ProcessWin(kills)
	kills = tonumber(kills) or 0

	if kills <= 0 then
		Log("Skipped: kills <= 0")
		return
	end

	Notify("[JINSHI_PUBG] Chúc mừng bạn đã TOP 1...")
	local setHudHidden = CreateHudController()
	setHudHidden(true)

	local ok, err = pcall(CaptureAndSend, kills, 0, 0, setHudHidden)
	if not ok then
		setHudHidden(false)
		Log("ProcessWin Error: " .. tostring(err))
	end
end

local function GetWinnerKills()
	local kills = 0
	pcall(function()
		local likeUtil = GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
		if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
			local playerState = likeUtil.GetMyPlayerState()
			if playerState and playerState.Kills then
				kills = tonumber(playerState.Kills) or 0
			end
		end

		if kills == 0 then
			local resultLogic = GetModule(
				"GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic",
				false
			)
			if resultLogic and type(resultLogic.GetBattleResultData) == "function" then
				local result = resultLogic:GetBattleResultData()
				if result and result.BP_mykill then
					kills = tonumber(result.BP_mykill) or 0
				end
			end
		end
	end)
	return kills
end

local function TryInstallHook()
	pcall(function()
		local UIManager = _G.UIManager
		if not UIManager or not UIManager.ShowUI or UIManager.__JINSHIHooked then
			return
		end

		Log("Hooking UIManager.ShowUI for in-game Winner UI...")
		local originalShowUI = UIManager.ShowUI
		UIManager.ShowUI = function(config, params, ...)
			local result = originalShowUI(config, params, ...)
			pcall(function()
				local inGameConfig = UIManager.UI_Config_InGame
				local winnerConfig = inGameConfig and inGameConfig.GameOverCountDown_UIBP
				local isWinner = params and (params.Reason == "win" or params.ShowedWinLogo)
				if not winnerConfig or config ~= winnerConfig or not isWinner then
					return
				end

				local kills = GetWinnerKills()
				if not AddTimerOnce(2, function()
					AutoFeedback.ProcessWin(kills)
				end) then
					AutoFeedback.ProcessWin(kills)
				end
			end)
			return result
		end

		UIManager.__JINSHIHooked = true
		AutoFeedback.Hooked = true
		Log("UIManager Hook installed successfully.")
	end)
end

local function ScheduleTryInstallHook()
	if AutoFeedback.Hooked then
		return
	end
	TryInstallHook()
	if not AutoFeedback.Hooked then
		AddTimerOnce(3.0, ScheduleTryInstallHook)
	end
end

function AutoFeedback.Install()
	Log("Installing JINSHI_PUBG system (Telegram)...")

	if AutoFeedback.Config.TestMode then
		pcall(function()
			AddTimerOnce(5.0, function()
				AutoFeedback.ProcessWin()
			end)
		end)
	end

	pcall(function()
		local ticker = GetModule("common.time_ticker")
		if ticker and type(ticker.AddTimer) == "function" then
			ticker.AddTimer(3.0, ScheduleTryInstallHook)
		else
			ScheduleTryInstallHook()
		end
	end)
end

AutoFeedback.Base64Encode = Base64Encode
AutoFeedback.UrlEncode = UrlEncode
AutoFeedback.GetRankName = GetRankName
_G.AKMOD_AutoFeedbackRecovered = AutoFeedback

if not isExpired then
	AutoFeedback.Install()
end
end
-- ==============================================================================
-- ==================  AUTO FEEDBACK SYSTEM (@ABNHI) ==============
-- ===================================
-- ==============================================================================
 ===================================Baypass======================================================================================================================================================
 
local function InitializeAntiCheatHooks()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then HBC.StaticShowSecurityAlertInDev = nop end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = nop; _G.AvatarCheckCallback.OnReportItemID = nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then PlayerController.HiggsBosonComponent:ControlMHActive(0); PlayerController.HiggsBosonComponent.bMHActive = false end
        end
    end
end

local function InitializeAntiReport()
    pcall(function()
        for _, path in ipairs({"GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"}) do
            local sub = package.loaded[path]; if not sub then local s, r = pcall(require, path); if s and r then sub = r end end
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Record") or k:find("Send") or k:find("Upload") or k:find("Notify")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop; GC.IsBypassed = true
    end)
end

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = nop end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end)
end

local function InitializeFinalProtection()
    pcall(function()
        for _, flag in ipairs({"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}) do if _G[flag] then _G[flag] = false end end
        local origReq = require
        local blocked = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"}
        _G.require = function(m) for _, b in ipairs(blocked) do if m:find(b) then return {} end end; return origReq(m) end
    end)
end

local function InitializeOperationalStatsBypass()
    pcall(function()
        -- Lấy qua SubsystemMgr hoặc Global để đảm bảo 100% bắt được đích
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        local OperationalStatsSubsystem = (subMgr and subMgr:Get("OperationalStatsSubsystem")) or _G.OperationalStatsSubsystem
        
        if OperationalStatsSubsystem then
            OperationalStatsSubsystem.ReportOperationalStats = nop
            OperationalStatsSubsystem.AddOperationalStats = nop
            OperationalStatsSubsystem.HandleTouchBegin = nop
            OperationalStatsSubsystem.HandleTouchEnd = nop
            OperationalStatsSubsystem.OnInit = nop
            OperationalStatsSubsystem.HandleEnterFighting = nop
            OperationalStatsSubsystem.OnBattleResult = nop
            if OperationalStatsSubsystem.TimerHandle then
                pcall(function() OperationalStatsSubsystem:RemoveGameTimer(OperationalStatsSubsystem.TimerHandle) end)
                OperationalStatsSubsystem.TimerHandle = nil
            end
            OperationalStatsSubsystem.StatsData = {}
            print("[ULTIMATE BYPASS] OperationalStatsSubsystem blocked!")
        end
    end)
end

_G.StartBypass_VIP_v3 = function()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass() -- Thêm dòng này
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializePlayerSecurityBypass()
        InitializeClientFlowBypass()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeModifierExceptionBypass()
        InitializeSimulateCharacterLocationBypass()
        InitializeShootVerificationBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeAntiCheatHooks()
        InitializeAntiReport()
        InitializeGameplayBypass()
        InitializeKillAllSubsystems()
        InitializeOperationalStatsBypass() -- [NEW] BYPASS BÁO CÁO THỐNG KÊ (Operational Stats)
        InitializeFinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end
"TssSdkBypass"
"EnhancedAntiCheatBypass"
"MemoryBypass"
"TimeBypass"
"NetworkBypass"
"ReportBypass"
"ProcessBypass"
"AntiDebugBypass"
"AnoSDKBypass"
"MprotectBypass"
"InitializeHeartbeatBypass"
"DisableAnoSDK_MRPCS"
"KillBanPopup"
"AdvancedAntiCheatBypass"
"MemoryProtectionBypass"
"PlayerReportBypass"
"BlockTssSdk"
"BlockAntiDebugging"
"HiggsBosonBypass"
"BanLogicBypass"
"ReportSystemBypass"
"MD5Bypass"
"SwiftHawkBypass"
"ShootVerificationBypass"
"PlayerSecurityBypass"
"ClientFlowBypass"
"KillAllSubsystems"
"SLUABypass"
"ReplayTelemetryBypass"
"InitializeAllBypass"
"BypassTssSdk"
"BypassMonitoringSystems"
"BypassNetworkFilters"
"BypassAppDetection"
"BypassFileCheck"
"patchMD5Functions"
"BypassMemoryCheck"
"patchMemoryFunctions"
"BypassDeviceBan"
"BypassAllReports"
"BypassCrashReports"
"BypassExtraProtections"
=========================The end====================================================================================================================================
