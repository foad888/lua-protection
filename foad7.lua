-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛡️ ANTI-MONITORING + ANTI-HAWKEYE — ULTIMATE
-- @Nixnaymar
-- ═══════════════════════════════════════════════════════════════════════════════
-- يمنع:
--   • عين الصقر (HawkEye Patrol)
--   • المراقبة (Spectating)
--   • تسجيل الشاشة (Screen Recording)
--   • التقاط الشاشة (Screenshot)
--   • Replay Recording
--   • Live Monitoring
--   • Stream Monitoring
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
-- [1] ❌ منع عين الصقر (HawkEye Patrol) — النظام الكامل
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local HE = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if HE then
        -- تعطيل كل الدوال
        for k, v in pairs(HE) do
            if type(v) == "function" then HE[k] = nop end
        end

        -- دوال محددة
        HE._OnHawkSync                         = nop
        HE._OnHawkReportSuccess                = nop
        HE._OnRecvInspectorBroadcastCount      = nop
        HE.ReportCheat                         = nop
        HE.RequestImprison                     = nop
        HE.SendReportTLog                      = nop
        HE._CollectBeWatchedPlayerInfo         = nop
        HE._OnPlayerKilledOtherPlayer          = nop
        HE._StartFrameUIRefreshTimer           = nop
        HE.ExitWatching                        = nop
        HE.WantMatchNextPatrol                 = nop
        HE.InitHawkEyePatrolSubsystem          = nop
        HE._StartHideUITimer                   = nop
        HE._StartShowDistanceUITimer           = nop
        HE._StartCloseBattleEndedTipsTimer     = nop
        HE._StartBattleTimeUsageTimer          = nop
        HE._StartQuitVoiceRoomTimer            = nop
        HE._StartExitGameTimer                 = nop
        HE._CloseExitGameTimer                 = nop
        HE._CreateOvertimerTimerForNextPatrol  = nop
        HE.ClearNextPatrolOvertimeTimer        = nop
        HE.ReturnLobbyAndOpenH5                = nop
        HE.ForceNeverCloseBattleEndedTips      = nop
        HE.TryShowReportedTips                 = nop
        HE.ShowWatchEndedTips                  = nop
        HE.OnShowWatchEndedTips                = nop
        HE.OnClickLowerLeftExitWatching        = nop
        HE.OnClickBottomRightOpenReportWindow  = nop
        HE._MarkHasReported                    = nop
        HE.OnRelease                           = nop
        HE.ServerRPC_HawkReportCheat           = nop
        HE.RequestFlagPlayer                   = nop
        HE.SendFlagReport                      = nop
        HE._OnHawkFlag                         = nop
        HE.ReportPlayerFlag                    = nop

        -- Flags
        HE.IsDuringHawkEyePatrol               = retFalse
        HE.HasReported                         = retTrue
        HE.GetBeWatchedPlayerInfo              = retEmpty
        HE.CheckShowReportedTips               = retFalse
        HE.HasShownWatchEndedTips              = retTrue
        HE.GetForbidNextPatrolRemainingTimeInSeconds = retZero
        HE.GetUsedDailyTimeInSeconds           = retZero
        HE.GetInspectorBroadcastCount          = retZero
        HE.GetMaxInspectorBroadcastCount       = retZero
        HE.CanInspectorBroadcast               = retFalse
        HE.IsCharacterLocationShouldDraw       = retFalse
        HE._bHasInitialized                    = true
        HE._bHasReported                       = true
        HE._bHasShownWatchEndedTips            = true
        HE.bShowBeReportedTips                 = true
        HE.nInspectorBroadcastCount            = -1
    end

    -- DS Version
    local DS = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSHawkEyePatrolSubsystem"]
    if DS then
        for k, v in pairs(DS) do
            if type(v) == "function" then DS[k] = nop end
        end
    end

    -- HawkEye Spectate
    for _, name in ipairs({
        "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem",
        "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeDistanceUI",
        "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeNextPatrolWindow",
        "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeReportWindow",
        "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeSpectatorState",
    }) do
        local mod = package.loaded[name]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" then mod[k] = nop end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [2] ❌ منع المراقبة (Spectating System)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local SS = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem"]
    if SS then
        for k, v in pairs(SS) do
            if type(v) == "function" then SS[k] = nop end
        end
    end

    -- Inspector System
    for _, name in ipairs({
        "GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem",
        "GameLua.Mod.BaseMod.Client.Security.ClientInspectionSubsystem",
    }) do
        local mod = package.loaded[name]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" then mod[k] = nop end
            end
        end
    end

    -- منع المراقبين
    _G.IsBeingWatched = false
    _G.bIsInspector = false
    _G.IsInspector = retFalse
    _G.IsSpectator = retFalse
    _G.IsMonitored = retFalse
    _G.IsUnderObservation = retFalse
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [3] ❌ منع Screenshot (التقاط الشاشة)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local SM = import("ScreenshotMaker")
    if SM then
        for k, v in pairs(SM) do
            if type(v) == "function" then SM[k] = nop end
        end
        SM.MakePicture      = retEmptyString
        SM.ReMakePicture    = retEmptyString
        SM.HasCaptured      = retTrue
        SM.TakeScreenshot   = nop
        SM.CaptureScreen    = nop
        SM.RecordScreen     = nop
        SM.SaveScreenshot   = nop
        SM.GetScreenshotData = retEmptyString
    end

    local SMTD = import("ScreenshotMTDer")
    if SMTD then
        for k, v in pairs(SMTD) do
            if type(v) == "function" then SMTD[k] = nop end
        end
        SMTD.MTDePicture    = retEmptyString
        SMTD.ReMTDePicture  = retEmptyString
        SMTD.HasCaptured    = retTrue
        SMTD.TakeScreenshot = nop
    end

    -- منع Screenshot Detection
    local SD = package.loaded["ScreenshotDetect"] or _G.ScreenshotDetect
    if SD then
        SD.OnScreenshotTaken = nop
        SD.ReportScreenshot  = nop
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [4] ❌ منع Screen Recording (تسجيل الشاشة)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- Screen Recorder
    if _G.ScreenRecorder then
        _G.ScreenRecorder.Start = nop
        _G.ScreenRecorder.Stop  = nop
        _G.ScreenRecorder.Save  = nop
        _G.ScreenRecorder.IsRecording = retFalse
    end

    -- MediaRecorder (Android)
    if _G.MediaRecorder then
        _G.MediaRecorder = nil
    end

    -- Replay System
    if _G.Replay then
        _G.Replay.Record       = nop
        _G.Replay.StopRecord   = nop
        _G.Replay.Save         = nop
        _G.Replay.Upload       = nop
        _G.Replay.Report       = nop
        _G.Replay.IsRecording  = retFalse
        _G.Replay.IsActive     = retFalse
    end

    -- ClientReplayDataReporter
    local CRDR = package.loaded["client.slua.logic.replay.ClientReplayDataReporter"]
    if CRDR then
        for k, v in pairs(CRDR) do
            if type(v) == "function" then CRDR[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [5] ❌ منع Replay System
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- Replay Subsystem
    local RS = package.loaded["ReplaySubsystem"]
    if RS then
        for k, v in pairs(RS) do
            if type(v) == "function" then RS[k] = nop end
        end
    end

    -- SubsystemMgr
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if subMgr then
        for _, name in ipairs({"ReplaySubsystem", "ReplayMonitorSubsystem", "SpectateAndReplaySubsystem"}) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" then sub[k] = nop end
                end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
            end
        end
    end

    -- logic_report_replay
    local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
    if logRep then
        for k, v in pairs(logRep) do
            if type(v) == "function" then logRep[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [6] ❌ منع Live Monitoring
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع Live Stream
    if _G.LiveStream then
        _G.LiveStream.Start   = nop
        _G.LiveStream.Stop    = nop
        _G.LiveStream.IsLive  = retFalse
    end

    -- منع Screen Share
    if _G.ScreenShare then
        _G.ScreenShare.Start  = nop
        _G.ScreenShare.Stop   = nop
        _G.ScreenShare.IsActive = retFalse
    end

    -- منع إرسال الفيديو
    for _, fn in ipairs({
        "SendVideo","UploadVideo","StreamVideo","ReportVideo",
        "SendScreenData","UploadScreen","CaptureAndSend"
    }) do
        if _G[fn] then _G[fn] = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [7] ❌ منع Observers (المراقبين)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع Spectator
    if _G.Spectator then
        _G.Spectator.Start       = nop
        _G.Spectator.Stop        = nop
        _G.Spectator.IsWatching  = retFalse
    end

    -- منع Monitor
    if _G.Monitor then
        _G.Monitor.Start         = nop
        _G.Monitor.Stop          = nop
        _G.Monitor.IsActive      = retFalse
    end

    -- منع Observer
    if _G.Observer then
        _G.Observer.Start        = nop
        _G.Observer.Stop         = nop
        _G.Observer.IsActive     = retFalse
    end

    -- منع Player Watcher
    for _, fn in ipairs({
        "WatchPlayer","StartWatching","MonitorPlayer",
        "ObservePlayer","TrackPlayer","FollowPlayer"
    }) do
        if _G[fn] then _G[fn] = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [8] ❌ منع المراقبة من الدعم الفني (Support)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- Support System
    local supportModules = {
        "client.slua.logic.CustomerService.LogicSafeStation",
        "client.slua.logic.CustomerService.LogicCustomerService",
        "client.slua.logic.CustomerService.SupportTools",
    }
    for _, name in ipairs(supportModules) do
        local mod = package.loaded[name]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" then mod[k] = nop end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [9] ❌ منع Network Monitoring
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local NM = import("NetworkManager")
    if NM then
        for k, v in pairs(NM) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("monitor") or kl:find("track") or kl:find("capture") or
                   kl:find("analyze") or kl:find("report") then
                    NM[k] = nop
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [10] ❌ منع Gameplay Monitoring
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if _G.GameplayCallbacks then
        for k, v in pairs(_G.GameplayCallbacks) do
            if type(v) == "function" then
                local kl = k:lower()
                if kl:find("spectate") or kl:find("monitor") or kl:find("watch") or
                   kl:find("observe") or kl:find("inspect") then
                    _G.GameplayCallbacks[k] = nop
                end
            end
        end
    end

    -- Global
    for _, fn in ipairs({
        "StartSpectating","StopSpectating","StartMonitoring","StopMonitoring",
        "StartWatching","StopWatching","StartObserving","StopObserving"
    }) do
        if _G[fn] then _G[fn] = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [11] ❌ منع التبليغ عن السلوك (Behavior Report)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local BS = package.loaded["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"]
    if BS then
        for k, v in pairs(BS) do
            if type(v) == "function" then BS[k] = nop end
        end
    end

    -- Behavior Report
    for _, fn in ipairs({
        "ReportBehavior","ReportBehaviorScore","SendBehaviorData",
        "ReportBadBehavior","ReportToxicBehavior"
    }) do
        if _G[fn] then _G[fn] = nop end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [12] ❌ منع AI Watching (البوتات تراقبك)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    -- منع AI من تسجيلك
    if _G.AIWatch then
        _G.AIWatch.Start = nop
        _G.AIWatch.Stop  = nop
    end

    -- AI Replay
    local AIR = package.loaded["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"]
    if AIR then
        for k, v in pairs(AIR) do
            if type(v) == "function" then AIR[k] = nop end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [13] ❌ منع كل تقارير المراقبة عبر الشبكة
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        NetUtil.SendPacket = function(packetName, ...)
            if type(packetName) == "string" then
                local p = packetName:lower()
                if p:find("spectat") or p:find("watch") or p:find("monitor") or
                   p:find("observ") or p:find("inspect") or p:find("hawk") or
                   p:find("replay") or p:find("screenshot") or p:find("screen") then
                    return nil
                end
            end
            return orig(packetName, ...)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [14] 🔄 MONITOR (كل 10 ثواني يعيد التفعيل)
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    local function Reapply()
        pcall(function()
            -- منع المراقبة
            _G.IsBeingWatched   = false
            _G.bIsInspector     = false
            _G.IsMonitored      = false
            _G.IsSpectator      = false

            -- HawkEye
            local HE = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
            if HE then
                HE.IsDuringHawkEyePatrol = retFalse
                HE.HasReported           = retTrue
                HE.CanInspectorBroadcast = retFalse
            end
        end)
    end

    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(10.0, Reapply, -1, 10.0)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- [15] NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════════
pcall(function()
    print("═══════════════════════════════════════════════════")
    print("[ANTI-MONITORING] 🛡️ LOADED")
    print("[ANTI-MONITORING] ❌ HawkEye (عين الصقر) DISABLED")
    print("[ANTI-MONITORING] ❌ Spectating DISABLED")
    print("[ANTI-MONITORING] ❌ Screenshot BLOCKED")
    print("[ANTI-MONITORING] ❌ Screen Recording BLOCKED")
    print("[ANTI-MONITORING] ❌ Replay BLOCKED")
    print("[ANTI-MONITORING] ❌ Live Monitoring BLOCKED")
    print("[ANTI-MONITORING] ❌ Observers BLOCKED")
    print("[ANTI-MONITORING] ❌ AI Watching BLOCKED")
    print("[ANTI-MONITORING] ❌ Behavior Report BLOCKED")
    print("[ANTI-MONITORING] ✅ COMPLETE")
    print("═══════════════════════════════════════════════════")
end)