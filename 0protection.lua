-- ============================================================================
--  BypassOnly.lua  —  البايباس فقط (مستخرج من 5 دفعات، بدون تكرار)
--  يعمل لوحده عبر: require("BypassOnly")
-- ============================================================================

-- ============================================================================
--  SECTION 1 — HELPERS
-- ============================================================================
local function nop()         return true  end
local function retTrue()     return true  end
local function retFalse()    return false end
local function retZero()     return 0     end
local function retEmpty()    return {}    end
local function retNil()      return nil   end
local function retEmptyStr() return ""    end

local function safeRequire(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local function safeGetSubsystem(name)
    local subMgr = safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not subMgr then return nil end
    local ok, sub = pcall(function() return subMgr:Get(name) end)
    return ok and sub or nil
end

local function hookFunctions(tbl, names, fn)
    if not tbl then return end
    for _, name in ipairs(names) do
        pcall(function()
            if type(tbl[name]) == "function" then tbl[name] = fn end
        end)
    end
end

local function blockByKeywords(mod, keywords, fn)
    if not mod then return end
    for k, v in pairs(mod) do
        if type(v) == "function" and type(k) == "string" then
            local low = string.lower(k)
            for _, kw in ipairs(keywords) do
                if string.find(low, kw, 1, true) then
                    pcall(function() mod[k] = fn end)
                    break
                end
            end
        end
    end
end

local function SafeCall(func, ...)
    local s, r = pcall(func, ...)
    return s, r
end

local function IsValid(obj)
    return obj and slua and slua.isValid and slua.isValid(obj)
end

local function GetPlayerController()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not IsValid(pc) then
        local GD = package.loaded["GameLua.GameCore.Data.GameplayData"]
        if GD and GD.GetPlayerController then
            pc = GD.GetPlayerController()
        end
    end
    return pc
end

-- ============================================================================
--  SECTION 2 — STATE
-- ============================================================================
_G.REGER_BYPASS = _G.REGER_BYPASS or {
    Version = "5.0",
    Active = true,
    ProtectionLevel = "ULTIMATE",
    BypassLayers = {},
    BlockedSystems = {},
    Permissions = {
        SecurityBypass=true, AntiCheatBypass=true, ReportBypass=true,
        BanBypass=true, TelemetryBypass=true, NetworkBypass=true,
        MD5Bypass=true, SignatureBypass=true, DNSBypass=true,
        DeviceBypass=true, HawkEyeBypass=true, HiggsBosonBypass=true,
        CoronaLabBypass=true, GokubaBypass=true, SwiftHawkBypass=true,
        RacingBypass=true, ShootVerifyBypass=true, FileCheckBypass=true,
        MemoryScanBypass=true, ReplayBypass=true, ScreenshotBypass=true,
        LoggingBypass=true, CrashReportBypass=true, AnalyticsBypass=true,
        TLogBypass=true, PacketBypass=true, ConsoleBypass=true,
        SluaBypass=true, JNIBypass=true
    }
}

_G.UBypass = _G.UBypass or { state = {}, version = 1, ready = false }
local STATE = _G.UBypass.state
STATE.SLUA_BYPASSED     = STATE.SLUA_BYPASSED     or false
STATE.MD5_BYPASSED      = STATE.MD5_BYPASSED      or false
STATE.HIGGS_BYPASSED    = STATE.HIGGS_BYPASSED    or false
STATE.SUBSYSTEMS_KILLED = STATE.SUBSYSTEMS_KILLED or false
STATE.NETWORK_BLOCKED   = STATE.NETWORK_BLOCKED   or false
STATE.ANOSDK_DISABLED   = STATE.ANOSDK_DISABLED   or false
STATE.FINAL_APPLIED     = STATE.FINAL_APPLIED     or false

_G.AntiCheatBlock = _G.AntiCheatBlock or {
    BlockTSS=true, BlockGokuba=true, BlockSwiftHawk=true, BlockCoronaLab=true,
    BlockHawkEye=true, BlockHiggsBoson=true, BlockClientBan=true,
    BlockRealTimeBan=true, BlockReportSystem=true, BlockTLog=true,
    BlockMD5Check=true, BlockSignatureVerify=true, BlockDeviceFingerprint=true,
    BlockDNSMonitor=true, BlockTelemetry=true, BlockAnalytics=true,
    BlockCrashReport=true, BlockMemoryScan=true, BlockSpeedCheck=true,
    BlockWallCheck=true, BlockShootVerify=true, BlockModifierException=true,
    BlockSimulateLocation=true, BlockPlayerSecurity=true, BlockCircleFlow=true,
    BlockMrpcsFlow=true, BlockKillFlow=true, BlockBehaviorScore=true,
    BlockAFKReport=true, BlockAvatarException=true, BlockFileCheck=true,
    BlockPakVerify=true, BlockIntegrityCheck=true, BlockRacingAntiCheat=true,
    BlockClientEntry=true, BlockNetworkException=true, BlockUnrealNet=true,
    BlockReplay=true, BlockScreenshot=true, BlockDebugLog=true,
    BlockJNI=true, BlockXignCode=true, BlockBattlEye=true, BlockAce=true,
    BlockTDataMaster=true, BlockCrashSight=true, BlockScreenshots=true
}

-- ============================================================================
--  SECTION 3 — SLUA / MD5 / Higgs / TSS / ACE / XignCode / BattlEye / AnoSdk
-- ============================================================================
local function BypassSLUA()
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
        local sluaSerialize = package.loaded["slua.serialize"]
        if sluaSerialize then
            sluaSerialize.check  = retTrue
            sluaSerialize.verify = retTrue
        end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify        then _G.slua_verify        = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
    STATE.SLUA_BYPASSED = true
end

local function BypassMD5()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray   = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile        = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity= retTrue
            CMode.VerifyContent      = retTrue
            CMode.ValidateContent    = retTrue
            CMode.CheckContent       = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32   then _G.CRC32   = function() return 0 end end
        if _G.SHA1    then _G.SHA1    = function() return "BYPASS" end end
        local FHC = package.loaded["common.file_hash_checker"]
        if FHC then
            FHC.CheckFileMD5 = retTrue
            FHC.VerifyAll    = retTrue
            FHC.GetHash      = function() return "BYPASS" end
        end
        if _G.FileHashChecker then
            _G.FileHashChecker.CheckFileMD5 = retTrue
            _G.FileHashChecker.VerifyAll    = retTrue
            _G.FileHashChecker.GetHash      = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            TssSdk.GetFileMD5 = function() return "BYPASS" end
            TssSdk.VerifyFileSignature = retTrue
        end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then
            STExtra.CheckMD5   = retTrue
            STExtra.GetMD5     = function() return "BYPASS" end
            STExtra.VerifyFile = retTrue
        end
        if _G.STExtraBlueprintFunctionLibrary then
            _G.STExtraBlueprintFunctionLibrary.CheckMD5   = retTrue
            _G.STExtraBlueprintFunctionLibrary.GetMD5     = function() return "BYPASS" end
            _G.STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
        end
    end)
    STATE.MD5_BYPASSED = true
end

local function BypassHiggsBoson()
    pcall(function()
        local Higgs = safeRequire("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            hookFunctions(Higgs, {
                "ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck",
                "StartAvatarCheck","ReportItemID","ReceiveAnyDamage","OnWeaponHitRecord",
                "ShowSecurityAlert","ServerReportAvatar","ClientReportNetAvatar",
                "SendHisarData","ValidateSecurityData","StaticShowSecurityAlertInDev",
                "RPC_Client_ShootVertifyRes","RPC_Server_ReportSimulateCharacterLocation",
                "DisableHiggsBoson","CheckMHActive","ReportViolation","ProcessSecurityEvent",
                "ValidatePlayer","CheckIntegrity",
            }, nop)
            Higgs.GetNetAvatarItemIDs   = retEmpty
            Higgs.GetCurWeaponSkinID    = retZero
            Higgs.GetCurItemIDs         = retEmpty
            Higgs.IsMHActive            = retFalse
            Higgs.bMHActive             = false
            Higgs.bCallPreReplication   = false
            Higgs.bIsEnable             = false
            Higgs.bSkipAlertServer      = true
            Higgs.CheckClientConfig     = retFalse
            Higgs.GetSecurityInfo       = retEmpty
            Higgs.ReportSecurityAlert   = nop
            Higgs.ValidateClient        = retTrue
            Higgs._ProcessReportChatRobotQueue = nop
            Higgs.LuaNotifySecurityAbnormalJump = nop
            Higgs.SendAntiDataFlow      = nop
            Higgs.SendHitFireBtnFlow    = nop
            Higgs.OnBattleResult        = nop
            Higgs.RPC_Client_ShowSecurityAlertWindow = nop
            Higgs.RPC_Server_TellServerName = nop
            Higgs.RecordStrategyTimestampInReplay = nop
            Higgs.SkipAlertServer       = nop
            Higgs.SetClientAlertWindowEnabled = nop
            Higgs.IsCharacterOwnerWerewolf = retFalse
            Higgs.IsCharacterOwnerButcher  = retFalse
            Higgs._ReportChatRobot       = nop
            Higgs._ClientShowSecurityAlertWindow = nop
            Higgs.ShowABCD               = nop
            Higgs.ReceiveBeginPlay       = nop
            if Higgs.BlackList then
                for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end
            end
        end
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                pc.HiggsBoson.bIsEnable = false
                if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
                pc.HiggsBosonComponent.bIsEnable = false
                if pc.HiggsBosonComponent.ControlMHActive then
                    pc.HiggsBosonComponent:ControlMHActive(0)
                end
            end
        end
        _G.BlackList = {}
        _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
        local mt = getmetatable(_G.GlobalPlayerCoronaData) or {}
        mt.__newindex = function() end
        setmetatable(_G.GlobalPlayerCoronaData, mt)
        if _G.AvatarCheckCallback then
            _G.AvatarCheckCallback.StartAvatarCheck = nop
            _G.AvatarCheckCallback.OnReportItemID = nop
            _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(pc2)
                if slua.isValid(pc2) and pc2.HiggsBosonComponent then
                    pc2.HiggsBosonComponent:ControlMHActive(0)
                    pc2.HiggsBosonComponent.bMHActive = false
                end
            end
        end
    end)
    STATE.HIGGS_BYPASSED = true
end

local function BypassAnoSdk()
    pcall(function()
        local AnoSdk = _G.AnoSdk or package.loaded["AnoSdk"]
        if AnoSdk then
            for k, v in pairs(AnoSdk) do
                if type(v) == "function" then AnoSdk[k] = nop end
            end
            AnoSdk.AnoSDKGetReportData  = retEmptyStr
            AnoSdk.AnoSDKGetReportData2 = retEmptyStr
            AnoSdk.AnoSDKGetReportData3 = retEmptyStr
            AnoSdk.AnoSDKGetReportData4 = retEmptyStr
        end
        for _, name in ipairs({"libanogs","anogs","mrpcs","MRPCS","mrpc"}) do
            local obj = _G[name] or package.loaded[name]
            if obj then
                for k, v in pairs(obj) do
                    if type(v) == "function" then obj[k] = nop end
                end
            end
        end
        for _, func in ipairs({
            "mrpcs_download_data_thread_start_failed","mrpcs_single_data_not_match",
            "mrpcs_data_crc_error","mrpcs_send_data_thread_start_failed",
            "mrpcs_data_len_error","mrpcs_common_data_not_match",
            "mrpcs_scan_thread_start_failed","mrpcs_lib",
            "mrpcs_data_mode_name_len_error",
        }) do
            if _G[func] then _G[func] = nop end
        end
        if _G.ms_scan_start then _G.ms_scan_start = retFalse end
    end)
    STATE.ANOSDK_DISABLED = true
end

local function BypassTSS()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            for k, v in pairs(TssSdk) do
                if type(v) == "function" then TssSdk[k] = nop end
            end
            TssSdk.OnRecvData            = nop
            TssSdk.SendReportInfo        = nop
            TssSdk.ScanMemory            = retTrue
            TssSdk.IsEmulator            = retFalse
            TssSdk.GetTssSdkReportInfo   = retEmptyStr
            TssSdk.CheckIntegrity        = retTrue
            TssSdk.VerifySignature       = retTrue
            TssSdk.CollectEvidence       = retEmpty
            TssSdk.UploadLog             = nop
            TssSdk.SendAntiData          = nop
            TssSdk.CheckEnvironment      = retTrue
            TssSdk.VerifyProcess         = retTrue
            TssSdk.GetFileMD5            = function() return "BYPASS" end
            TssSdk.VerifyFileSignature   = retTrue
            TssSdk.ScanSo                = function() return true, {code=0,msg="clean"} end
            TssSdk.ScanFile              = function() return true, {code=0} end
            TssSdk.GetRiskFlag           = retZero
            TssSdk.VerifyFileHash        = retTrue
            TssSdk.CheckKernel           = function() return true, {status="verified",tampered=false} end
            TssSdk.VerifyBoot            = function() return true, {locked=true,verified=true} end
        end
        if NetUtil and NetUtil.SendPacket then
            local origSend = NetUtil.SendPacket
            NetUtil.SendPacket = function(packetName, ...)
                local tssPackets = {
                    "tss_sdk_report","TSSHeartBeat","tss_heart_beat",
                    "on_tss_sdk_anti_data","tss_report","tss_anti_data",
                    "tss_scan_result","tss_memory_scan","tss_integrity"
                }
                for _, p in ipairs(tssPackets) do
                    if packetName == p then return nil end
                end
                return origSend(packetName, ...)
            end
        end
    end)
end

local function BypassAce()
    pcall(function()
        local ace = _G.ace or package.loaded["libace.so"]
        if ace then
            hookFunctions(ace, {
                "ReportData","CheckIntegrity","ScanMemory","VerifyProcess",
                "CheckModule","ReportViolation","KickPlayer","BanPlayer",
                "CollectInfo","SendReport","ValidateClient","CheckDebugger",
                "CheckEmulator","CheckRoot","ReportCheat","ReportHack",
                "ReportMod","ReportInject","ReportHook","ReportPatch",
                "ReportTamper","ReportCorrupt","ReportInvalid","ReportSpoof","ReportFake",
            }, nop)
            ace.CheckIntegrity = retTrue
            ace.ScanMemory     = retFalse
            ace.VerifyProcess  = retTrue
            ace.CheckModule    = retTrue
            ace.ValidateClient = retTrue
            ace.CheckDebugger  = retFalse
            ace.CheckEmulator  = retFalse
            ace.CheckRoot      = retFalse
            ace.CollectInfo    = retEmpty
        end
    end)
end

local function BypassXignCode()
    pcall(function()
        local XC = _G.XignCode or package.loaded["xigncode"]
        if XC then
            hookFunctions(XC, {
                "SendReport","ReportException","KickPlayer","BanPlayer",
                "ReportCheat","ReportHack","ReportMod","ReportInject",
                "ReportHook","ReportPatch","ReportTamper",
            }, nop)
            XC.CheckProcess    = retTrue
            XC.VerifyIntegrity = retTrue
            XC.ScanModules     = retEmpty
            XC.ValidateMemory  = retTrue
            XC.CheckDebugger   = retFalse
            XC.EncryptData     = function(d) return d end
            XC.DecryptData     = function(d) return d end
        end
    end)
end

local function BypassBattlEye()
    pcall(function()
        local BE = _G.BattlEye or package.loaded["BattlEye"]
        if BE then
            hookFunctions(BE, {
                "SendReport","KickPlayer","ReportViolation","BanPlayer",
                "CollectEvidence","ReportCheat","ReportHack","ReportMod",
                "ReportInject","ReportHook",
            }, nop)
            BE.ValidatePlayer  = retTrue
            BE.CheckMemory     = retTrue
            BE.VerifyIntegrity = retTrue
            BE.ScanProcess     = retTrue
            BE.CollectEvidence = retEmpty
        end
    end)
end

-- ============================================================================
--  SECTION 4 — LOG / SCANNER / REPORT / NETWORK / ANTI-REPORT / REPLAY
-- ============================================================================
local function BlockLogs()
    pcall(function()
        local Screenshot = import("ScreenshotMTDer") or import("ScreenshotMaker")
        if Screenshot then
            Screenshot.MTDePicture    = retEmptyStr
            Screenshot.ReMTDePicture  = retEmptyStr
            Screenshot.MakePicture    = retEmptyStr
            Screenshot.ReMakePicture  = retEmptyStr
            Screenshot.HasCaptured    = retTrue
            Screenshot.TakeScreenshot = nop
            Screenshot.SaveScreenshot = nop
            Screenshot.CaptureScreen  = nop
            Screenshot.RecordScreen   = nop
        end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            hookFunctions(TLog, {
                "Info","Warning","Error","Debug","Report","Send","Flush",
                "Log","LogWarning","LogError","LogVerbose"
            }, nop)
        end
        local CS = package.loaded["CrashSight"] or _G.CrashSight
        if CS then
            hookFunctions(CS, {
                "ReportException","SetCustomData","Log","SendCrash",
                "ReportUserException","UploadLog","SendReport","ReportCrash",
                "ReportError","ReportFatal","ReportWarning","ReportInfo",
                "ReportDebug","ReportMemory","ReportPerformance",
            }, nop)
            CS.CollectInfo = retEmpty
        end
        local GRU = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRU then
            GRU.BugglyPostExceptionFull     = retFalse
            GRU.CheckCanBugglyPostException = retFalse
            GRU.ReplayReportData            = nop
            GRU.ReportGameException         = nop
            GRU.PostException               = nop
        end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then
            CTR.SendReport    = nop
            CTR.SendException = nop
            CTR.UploadLog     = nop
        end
        local tlogU = package.loaded["client.slua.config.tlog.tlog_report_utils"]
        if tlogU then
            tlogU.ReportTLogEvent = nop
            tlogU.SendTlog        = nop
        end
        local ugc = package.loaded["client.slua.logic.ugc.UGCNewTLogReport"]
                 or package.loaded["client.slua.data.BasicData.BasicDataTLogReport"]
        if ugc then
            ugc.SendExposeReq      = nop
            ugc.SendInteractionReq = nop
            ugc.TLogReport         = nop
        end
        local ugcL = package.loaded["client.slua.logic.ugc.logic_ugc_tlog"]
        if ugcL then
            ugcL.SendModTLog = nop
            ugcL.ReportStay  = nop
        end
        local CTU = safeRequire("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
        if CTU then
            CTU.ReportGeneralCountByBRPhase    = nop
            CTU.ReportCommonTLogDataByBRPhase  = nop
        end
        _G.print   = nop
        _G.printf  = nop
        _G.log     = nop
        _G.warn    = nop
        _G.error   = nop
        _G.debug   = nop
        _G.trace   = nop
        _G.info    = nop
        _G.verbose = nop
        _G.fatal   = nop
        _G.panic   = nop
        _G.recover = nop
        _G.assert  = nop
    end)
end

local function BlockScanners()
    pcall(function()
        local afk = safeGetSubsystem("AFKReportorSubsystem")
        if afk then afk.PlayerHaveAction = nop; afk.ReportAFK = nop end
        local cds = safeGetSubsystem("ClientDataStatistcsSubsystem")
        if cds then
            cds.StartToCheck = nop
            cds.DelayCount = 0
            if cds.ReportPingDelayTimer then
                pcall(function() cds:RemoveGameTimer(cds.ReportPingDelayTimer) end)
                cds.ReportPingDelayTimer = nil
            end
        end
        local aes = safeGetSubsystem("AvatarExceptionSubsystem")
        if aes then
            aes.ReportException      = nop
            aes.BindPlayerCharacter  = nop
            aes.CheckAvatarValid     = retTrue
            aes.ValidateAvatar       = retTrue
            aes.ReportAvatarException= nop
            aes.ReportInvalidAvatar  = nop
            aes.ReportCorruptAvatar  = nop
        end
        local svs = safeGetSubsystem("ShootVerifySubSystemClient")
        if svs then
            svs.ReportVerifyFail = nop
            svs.OnVerifyFailed   = nop
            svs.CheckShoot       = retTrue
            svs.ValidateHit      = retTrue
            svs.VerifyShoot      = retTrue
            svs.ValidateShoot    = retTrue
            svs.CheckHit         = retTrue
            svs.VerifyHit        = retTrue
        end
        local memc = safeGetSubsystem("MemoryCheckSubsystem")
        if memc then blockByKeywords(memc, {"check","scan","report","validate","detect"}, nop) end
        local spc = safeGetSubsystem("SpeedCheckSubsystem")
        if spc then blockByKeywords(spc, {"check","report","validate","scan"}, nop) end
        local wc = safeGetSubsystem("WallCheckSubsystem")
        if wc then blockByKeywords(wc, {"check","report","validate","scan"}, nop) end
        local fc = safeGetSubsystem("FileCheckSubsystem")
        if fc then
            fc.StartCheck          = nop
            fc.ReportAbnormalFile  = nop
            fc.StopCheck           = nop
            fc.VerifyFile          = retTrue
            fc.CheckIntegrity      = retTrue
            fc.ValidateFile        = retTrue
            fc.CheckFile           = retTrue
            fc.VerifyHash          = retTrue
            fc.ValidateHash        = retTrue
            fc.CheckHash           = retTrue
        end
        local bs = safeGetSubsystem("BehaviorScoreSubsystem")
        if bs then
            bs.OnHandleBehaviorScore = nop
            bs.AIPerceptionScore     = nop
        end
        local AEPI = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AEPI then
            AEPI.CheckAvatarException        = nop
            AEPI.CheckAvatarExceptionOnce    = nop
            AEPI.ReportAvatarException       = nop
            AEPI.CheckSlotMeshVisible        = retFalse
            AEPI.CheckPawnVisible            = retFalse
            AEPI.CheckCanBugglyPostException = retFalse
        end
        local ACM = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if ACM then
            ACM.CheckAvatar      = retTrue
            ACM.ReportException  = nop
        end
        local mw = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if mw then
            mw.OnMemoryWarning      = nop
            mw.ReportMemoryWarning  = nop
        end
    end)
end

local function BlockReportFlows()
    pcall(function()
        local function blockGlobal(names)
            for _, name in ipairs(names) do
                if _G[name] then _G[name] = nop end
                if _G.GameplayCallbacks and _G.GameplayCallbacks[name] then
                    _G.GameplayCallbacks[name] = nop
                end
            end
        end
        blockGlobal({
            "ReportAimFlow","ReportHitFlow","ReportAttackFlow","ReportSecAttackFlow",
            "ReportFireArms","ReportVerifyInfoFlow","ReportMrpcsFlow","ReportPlayerBehavior",
            "ReportTeammatHurt","ReportMisKillByTeammate","ReportForbitPick","ReportPlayerMoveRoute",
            "ReportPlayerPosition","ReportVehicleMoveFlow","ReportSecTgameMovingFlow","ReportParachuteData",
            "ReportEquipmentFlow","ReportPlayersPing","ReportPlayerIP","ReportPlayerFramePingRecord",
            "ReportDSNetSaturation","ReportNetContinuousSaturate","ReportDSNetRate","ReportCircleFlow",
            "ReportSecMrpcsFlow","SendDSErrorLogToLobby","SendDSHawkEyePatrolLogToLobby",
            "SendSecTLog","SendDataMiningTLog","SendActivityTLog","ReportMatchRoomData",
            "ReportPlayerControllerStateChanged","ReportAvatarFlow","ReportSecurityAlert",
            "ReportAntiCheat","ReportSuspiciousActivity","ReportHeavyWeaponBoxSpawnFlow",
            "ReportHeavyWeaponBoxActivationFlow","ReportHeavyWeaponBoxOpenPlayerFlow",
            "ReportHeavyWeaponBoxItemFlow","ReportDSCircleFlow","ReportJumpFlow",
            "ReportGameStartFlow","ReportGameEndFlow","ReportAIActionFlow","ReportGenerateMonsterFlow",
            "ReportRevivalFlow","ReportGameSetting","ReportGameSettingNew",
            "ReportAntsVoiceTeamCreate","ReportAntsVoiceTeamQuit","ReportCommonInfo",
            "ReportLightweightStat","ReportIDCardProduceFlow","ReportIDCardPickUpFlow",
            "ReportIDCardDestroyFlow","ReportTeammateKillConfirmFlow","ReportForbiddenPickupFlow",
            "ReportPlayerEquipmentInfo","OnDSConnectionSaturated","SendClientStats",
            "SendServerAvgTickDelta","SendClientMemUsage","SendClientFPS",
            "ReportWallHack","ReportNoGrass","ReportAimbot","ReportSpeedHack","ReportMagicBullet",
        })
        for _, name in ipairs({
            "IsEnableReportMrpcsInCircleFlow","IsEnableReportMrpcsInPartCircleFlow",
            "IsEnableReportMrpcsFlow","IsEnableReportAttackFlow",
            "IsEnableReportHitFlow","IsEnableReportCircleFlow",
            "CheckReportSecAttackFlow","CheckReportSecAttackFlowWithAttackFlow",
        }) do
            if _G[name] then _G[name] = retFalse end
        end
        if _G.bReportedModifierException ~= nil then _G.bReportedModifierException = false end
        if _G.GameplayCallbacks then
            local GC = _G.GameplayCallbacks
            local origDS = GC.OnDSPlayerStateChanged
            GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
                local s = InPlayerState and string.lower(tostring(InPlayerState)) or ""
                local block = {
                    ["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1,
                    ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1,
                    ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1,
                    ["integrityfailure"]=1, ["securityviolation"]=1,
                }
                if block[s] then return end
                if origDS then pcall(origDS, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
            end
            GC.OnPlayerNetConnectionClosed = nop
            GC.OnPlayerActorChannelError   = nop
            GC.OnPlayerRPCValidateFailed   = nop
            GC.OnPlayerSpectateException   = nop
            GC.OnShutdownAfterError        = nop
            GC.IsBypassed = true
        end
        local cl = safeGetSubsystem("CoronaLabSubsystem")
        if cl then
            cl.ReportData       = nop
            cl.SendToServer     = nop
            cl.CollectTelemetry = nop
            cl.StopCollection   = nop
        end
        if _G.CoronaLab then
            _G.CoronaLab.ReportData  = nop
            _G.CoronaLab.SendData    = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry   = nop
        end
        local psi = package.loaded["GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem"]
        if psi then
            psi.ReportData     = nop
            psi.CheckCheat     = retFalse
            psi.ValidatePlayer = retTrue
            psi.CollectData    = nop
            psi.SendToServer   = nop
        end
        local ccf = safeGetSubsystem("ClientCircleFlowSubsystem")
        if ccf then blockByKeywords(ccf, {"report","send","flow"}, nop) end
        local mes = safeRequire("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if mes then
            mes.ReportException     = nop
            mes.CheckModifier       = retTrue
            mes.ValidateModifier    = retTrue
            mes.ReportModifierError = nop
        end
        local scs = safeRequire("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if scs then
            scs.ReportLocation   = nop
            scs.SendLocationData = nop
            scs.VerifyLocation   = retTrue
        end
        local svs2 = safeRequire("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if svs2 then
            svs2.OnShootVerifyFailed = nop
            svs2.SendVerifyData      = nop
            svs2.ReportBulletHit     = nop
            svs2.UploadHitInfo       = nop
            svs2.VerifyShot          = retTrue
        end
        if _G.BulletHitInfoUploadData then
            _G.BulletHitInfoUploadData.Report = nop
            _G.BulletHitInfoUploadData.Send   = nop
            _G.BulletHitInfoUploadData.Upload = nop
        end
        blockGlobal({"SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams","SendSwiftHawkData"})
        local sw = safeRequire("GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem")
        if sw then
            sw.ReportData       = nop
            sw.SendReport       = nop
            sw.CollectTelemetry = nop
        end
        local oss = safeGetSubsystem("OperationalStatsSubsystem") or _G.OperationalStatsSubsystem
        if oss then
            hookFunctions(oss, {
                "ReportOperationalStats","AddOperationalStats","HandleTouchBegin",
                "HandleTouchEnd","OnInit","HandleEnterFighting","OnBattleResult",
            }, nop)
            if oss.TimerHandle then
                pcall(function() oss:RemoveGameTimer(oss.TimerHandle) end)
                oss.TimerHandle = nil
            end
            oss.StatsData = {}
        end
    end)
end

local function BlockReplay()
    pcall(function()
        local rr = safeGetSubsystem("RescueBtnReplayTraceSubsystem")
        if rr then
            rr.ReportTrace                = nop
            rr.StartTickMonitor           = nop
            rr.TickMonitorCheck           = nop
            rr.ReportTickMonitorHeartbeat = nop
        end
        local gr = safeGetSubsystem("GameReportSubsystem")
        if gr then
            gr.ReplayReportData            = retFalse
            gr.CheckCanBugglyPostException = retFalse
            gr.BugglyPostExceptionFull     = retFalse
            gr.GetClientReplayDataReporter = retNil
            if gr.Reporter then
                gr.Reporter.ReportIntArrayData   = nop
                gr.Reporter.ReportUInt8ArrayData = nop
                gr.Reporter.ReportFloatArrayData = nop
            end
        end
        local rp = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if rp then
            rp.ReportReplay  = nop
            rp.SendReportReq = nop
            rp.UploadReplay  = nop
        end
        local hr = package.loaded["client.slua.logic.home.logic_home_report"]
        if hr then
            hr.ShowInGameReportUI = nop
            hr.SendReport         = nop
        end
        if _G.ClientReplayDataReporter then
            _G.ClientReplayDataReporter.ReportIntArrayData   = nop
            _G.ClientReplayDataReporter.ReportFloatArrayData = nop
        end
        if _G.Replay then
            _G.Replay.Record     = nop
            _G.Replay.StopRecord = nop
            _G.Replay.Save       = nop
            _G.Replay.Upload     = nop
            _G.Replay.Report     = nop
        end
    end)
end

local function BlockAntiReport()
    pcall(function()
        local clientPaths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "Client.Security.ClientReportPlayerSubsystem",
        }
        local clientRep
        for _, p in ipairs(clientPaths) do
            clientRep = package.loaded[p] or safeRequire(p)
            if clientRep then break end
        end
        if clientRep then
            hookFunctions(clientRep, {
                "OnInit","_OnPlayerKilledOtherPlayer","_RecordFatalDamager",
                "_OnDeathReplayDataWhenFatalDamaged","_RecordMurdererFromDeathReplayData",
                "_RecordTeammatePlayerInfo","_OnBattleResult","_OnShowQuickReportMutualExclusiveUI",
                "SendPacket","ReportSuspiciousPlayer","SubmitReport",
            }, nop)
            clientRep.GetFatalDamagerMap                       = retEmpty
            clientRep.GetCachedTeammateName2InfoMap            = retEmpty
            clientRep.GetTeammateName2InfoMapDuringBattle      = retEmpty
            clientRep.GetCurrentNotInTeamHistoricalTeammateMap = retEmpty
            clientRep.GetInTeamIndexFromHistoricalTeammateInfo = retZero
        end
        local dsPaths = {
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem",
        }
        local dsRep
        for _, p in ipairs(dsPaths) do
            dsRep = package.loaded[p] or safeRequire(p)
            if dsRep then break end
        end
        if dsRep then
            hookFunctions(dsRep, {
                "OnInit","_OnNearDeathOrRescued","_OnCharacterDied","_OnTeammateDamage",
                "_OnPlayerSettlementStart","_AddKnockDownerToBattleResult","_AddKillerToBattleResult",
                "_AddTeammateMurderToBattleResult","_AddFatalDamagerMapToBattleResult",
                "_AddMLKillerUIDToBattleResult","_SaveHistoricalTeammateInfo",
                "_RecordFatalDamager","_RecordTeammateMurderer","_AddEnemyMapToBattleResult",
                "_AddTeammateMapToBattleResult","_SubmitAbnormalData",
            }, nop)
        end
        local rpu = safeRequire("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if rpu then
            rpu.RecordFatalDamager            = nop
            rpu.IsUsingHistoricalTeammateInfo = retFalse
            rpu.IsCharacterDeliverAI          = retFalse
            rpu.GetBotType                    = retZero
        end
        local scu = safeRequire("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if scu then
            scu.ExtractPlayerBasicInfo = retEmpty
            scu.LogIf                  = retFalse
            scu.CheckSecurity          = retTrue
            scu.ValidatePlayer         = retTrue
        end
        local qr = safeRequire("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
        if qr then
            qr.OnShowMutualExclusiveUI = nop
            qr.OnHideMutualExclusiveUI = nop
        end
        local dsh = safeGetSubsystem("DSHawkEyePatrolSubsystem")
        if dsh then dsh.MarkSuspiciousPlayer = nop end
        if _G.DSHawkEyePatrolSubsystem then
            _G.DSHawkEyePatrolSubsystem._OnHawkReport     = nop
            _G.DSHawkEyePatrolSubsystem._OnHawkImprison   = nop
            _G.DSHawkEyePatrolSubsystem.CheckPunishPlayer = nop
        end
        local ch = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
        if ch then
            hookFunctions(ch, {
                "_OnHawkSync","_OnHawkReportSuccess","_StartExitGameTimer",
                "_OnRecvInspectorBroadcastCount","SendReportTLog","ReportCheat",
            }, nop)
            ch.CanInspectorBroadcast = retFalse
        end
        local ic = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"]
        if ic then
            hookFunctions(ic, {
                "AskForInspector","ReportEnemy","KickOutOneTeam","OnReceiveInspectCmd",
                "ClientReportData","SendReportToInspector","SendKickOutOneTeam",
                "ClientNotifyInspectorImplementation","RecvNotifyInspector",
            }, nop)
        end
        local id = package.loaded["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"]
        if id then
            hookFunctions(id, {
                "ServerKickOutOneTeamByPlayerImplementation","AddReportedCount",
                "AddInspectionRecord","BanPlayerByInspection","BroadCastToAllInspector",
                "ServerReportToInspectorImplementation","InitPlayerInspectionInfo",
            }, nop)
        end
    end)
end

local function BlockNetwork()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local orig = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"]=1,["ReportSecAttackFlow"]=1,["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1,["ReportVerifyInfoFlow"]=1,["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1,["ReportTeammatHurt"]=1,["ReportPlayerMoveRoute"]=1,
                ["ReportPlayerPosition"]=1,["ReportSecVehicleMoveFlow"]=1,["ReportSecTgameMovingFlow"]=1,
                ["ReportAimFlow"]=1,["ReportHitFlow"]=1,["ReportCircleFlow"]=1,
                ["ReportEquipmentFlow"]=1,["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1,["ReportPlayerEquipmentInfo"]=1,
                ["report_parachute_data"]=1,["on_tss_sdk_anti_data"]=1,
                ["report_unrealnet_exception"]=1,["tss_sdk_report"]=1,
                ["report_players_ping"]=1,["report_player_ip"]=1,
                ["report_player_frame_ping_record"]=1,["report_net_saturate"]=1,
                ["report_ds_netsaturate"]=1,["report_ds_net_continuous_saturate"]=1,
                ["report_ds_netrate"]=1,["report_unrealnet_clientstats"]=1,
                ["report_serverstat_avgtickdelta"]=1,["report_all_players_address"]=1,
                ["report_ai_strategyinfo"]=1,["report_ds_match_room_data"]=1,
                ["report_common_info"]=1,["report_common_battle_info"]=1,
                ["report_client_scan_result"]=1,["report_memory_exception"]=1,
                ["report_avatar_exception"]=1,["report_ui_state"]=1,
                ["report_hit_reg_fail"]=1,["report_character_state"]=1,
                ["report_vehicle_exception"]=1,["report_camera_exception"]=1,
                ["report_heavy_weapon_box_activation_flow"]=1,
                ["report_heavy_weapon_box_item_flow"]=1,
                ["report_ds_player_circle_flow"]=1,["log_shooting_miss"]=1,
                ["ClientSecMrpcsFlow"]=1,["MrpcsData"]=1,
                ["CheckReportSecAttackFlow"]=1,["CheckReportSecAttackFlowWithAttackFlow"]=1,
                ["CoronaLabReport"]=1,["CoronaLabData"]=1,
                ["PlayerSecurityInfo"]=1,["ReportSecurityInfo"]=1,
                ["SendSecurityData"]=1,["ClientCircleFlow"]=1,
                ["IsEnableReportMrpcsInCircleFlow"]=1,["IsEnableReportMrpcsInPartCircleFlow"]=1,
                ["bReportedModifierException"]=1,["ReportModifierException"]=1,
                ["RPC_Server_ReportSimulateCharacterLocation"]=1,
                ["ReportSimulateCharacterLocation"]=1,["RPC_Client_ShootVertifyRes"]=1,
                ["BulletHitInfoUploadData"]=1,["ShootVerifyFailed"]=1,
                ["RPC_ClientCoronaLab"]=1,["SwiftHawk"]=1,
                ["ClientSwiftHawk"]=1,["ClientSwiftHawkWithParams"]=1,
                ["AntiCheatReport"]=1,["CheatDetection"]=1,["ViolationReport"]=1,
                ["SecurityViolation"]=1,["IntegrityCheck"]=1,["SignatureVerify"]=1,
                ["send_ugc_report_uni_mod_expose_req"]=1,
                ["send_ugc_report_uni_mod_interactive_req"]=1,
                ["report_speed_hack"]=1,["report_wall_hack"]=1,
                ["report_aim_bot"]=1,["report_esp_usage"]=1,["report_modded_files"]=1,
                ["detect_cheat"]=1,["ban_player"]=1,["client_anti_cheat_report"]=1,
                ["SyncBanInfo"]=1,["SyncBanID"]=1,["VoiceBanNotify"]=1,
                ["AccountBan"]=1,["BanStatus"]=1,["BanReason"]=1,["BanExpiry"]=1,
                ["SuspensionInfo"]=1,["RiskFlag"]=1,["HighRiskNotice"]=1,
                ["InspectionNotice"]=1,["FrozenNotice"]=1,["RealTimeBan"]=1,
                ["HawkEyeReport"]=1,["HawkSync"]=1,["HawkReportSuccess"]=1,
                ["SpectatorReport"]=1,["CheatReport"]=1,["HackReport"]=1,
                ["ModReport"]=1,["InjectReport"]=1,["HookReport"]=1,
                ["PatchReport"]=1,["TamperReport"]=1,["CorruptReport"]=1,
                ["InvalidReport"]=1,["SpoofReport"]=1,["FakeReport"]=1,
            }
            NetUtil.SendPacket = function(name, ...)
                if blocked[name] then return nil end
                return orig(name, ...)
            end
            NetUtil.IsBypassed = true
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPC = {
                ["RPC_Server_ClientSecMrpcsFlow"]=1,
                ["RPC_Server_SwiftHawk"]=1,
                ["RPC_Server_ClientSwiftHawkWithParams"]=1,
                ["RPC_Server_ReportSimulateCharacterLocation"]=1,
                ["RPC_Client_ShootVertifyRes"]=1,
                ["RPC_ClientCoronaLab"]=1,
                ["RPC_Server_HawkReportCheat"]=1,
                ["RPC_Server_ReportPlayerKillFlow"]=1,
                ["RPC_Server_RequestImprison"]=1,
                ["RPC_Server_ReportSecurityViolation"]=1,
                ["RPC_Server_CheckIntegrity"]=1,
            }
            _G.SendRPC = function(name, ...)
                if blockedRPC[name] then return nil end
                return origRPC(name, ...)
            end
        end
    end)
    STATE.NETWORK_BLOCKED = true
end

local function BypassBan()
    pcall(function()
        local Ban = package.loaded["client.slua.logic.ban.ClientBanLogic"]
        if Ban then
            hookFunctions(Ban, {
                "OnSyncBanInfo","OnVoiceBanNotify","OnRealTimeVoiceBanNotify",
                "OnVoiceBanSuccess","OnSyncMicSuspicious","OnSyncMicPreFilter",
                "OnNotifyWarningTips","ReqBanInfo","TryOpenVoice",
            }, nop)
            Ban.IsVoiceReportEnable = retFalse
            Ban.bEnableVoiceReport  = false
            Ban.VoiceBanEndTime     = 0
            Ban.SuspiciousFlag      = 0
            Ban.Reason              = ""
            Ban.IsTranslated        = false
        end
        local BanUtil = package.loaded["client.common.ban_util"] or _G.ban_util
        if BanUtil then
            BanUtil.CheckBanStatus = retFalse
            BanUtil.GetBanTime     = retZero
            BanUtil.IsBanForever   = retFalse
        end
        local TTBan = package.loaded["client.logic.login.logic_tt_ban"] or _G.logic_tt_ban
        if TTBan then
            TTBan.CheckIfCanCreateRole = nop
            TTBan.GetCarrierInfo = function() return '[{"mcc":"000"}]' end
            TTBan.CheckBan = retFalse
            TTBan.GetBanStatus = retFalse
        end
        local Godzilla = package.loaded["client.network.Protocol.GodzillaBanHandler"]
        if Godzilla then
            Godzilla.send_godzilla_ban_req   = nop
            Godzilla.send_godzilla_unban_req = nop
        end
        local AntiAdd = package.loaded["client.network.Protocol.AntiaddctionHandler"]
        if AntiAdd then
            AntiAdd.send_anti_addiction_req    = nop
            AntiAdd.send_anti_addiction_notify = nop
        end
        local ARest = package.loaded["client.network.Protocol.AccessRestrictionHandler"]
        if ARest then
            ARest.send_access_restriction_req    = nop
            ARest.send_access_restriction_notify = nop
            ARest.on_player_cheat_state_notify   = nop
        end
        local DelAcc = package.loaded["client.slua.logic.gdpr.logic_deleteaccount"]
        if DelAcc then
            DelAcc.ForceDeleteAccount    = retFalse
            DelAcc.OnReceiveDeleteNotify = nop
        end
        local CU = package.loaded["client.slua.logic.gdpr.compliance_util"]
        if CU then CU.CheckCompliance = nop end
    end)
end

local function BypassDevice()
    pcall(function()
        local KS = import("KismetSystemLibrary")
        if KS then
            KS.IsDevelopment = retFalse
            KS.IsShipping    = retTrue
            KS.IsDebug       = retFalse
            KS.IsEditor      = retFalse
            KS.IsGame        = retTrue
            KS.IsClient      = retTrue
            KS.IsServer      = retFalse
            KS.IsStandalone  = retFalse
        end
        local SI = import("SystemInfo")
        if SI then
            SI.GetDeviceModel       = function() return "iPhone14,5" end
            SI.GetDeviceBrand       = function() return "Apple" end
            SI.GetAndroidVersion    = function() return "13" end
            SI.IsEmulator           = retFalse
            SI.IsRooted             = retFalse
            SI.IsDebugged           = retFalse
            SI.GetKernelVersion     = function() return "Linux version 4.14.116" end
            SI.CheckKernelIntegrity = retTrue
            SI.GetDeviceID          = function() return "00000000-0000-0000-0000-000000000000" end
            SI.GetDeviceName        = function() return "iPhone" end
            SI.GetDeviceType        = function() return "Phone" end
            SI.GetManufacturer      = function() return "Apple" end
            SI.GetModel             = function() return "iPhone14,5" end
            SI.GetOSVersion         = function() return "13" end
            SI.GetOSName            = function() return "iOS" end
        end
        local DID = import("DeviceID")
        if DID then
            DID.GetDeviceID       = function() return "BYPASSED_DEVICE" end
            DID.GetAndroidID      = function() return "BYPASSED_ANDROID_ID" end
            DID.GetIMEI           = function() return "BYPASSED_IMEI" end
            DID.GetMACAddress     = function() return "BYPASSED_MAC" end
            DID.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
        end
        local ES = package.loaded["client.logic.login.emulator_scanner"]
        if ES then
            ES.StartScan        = nop
            ES.GetScanResult    = retFalse
            ES.ReportScanResult = nop
        end
        local EH = package.loaded["client.network.Protocol.EmulatorHandler"]
        if EH then EH.send_emulator_info = nop end
        local LV = package.loaded["client.network.Protocol.LoginVerifyHandler"]
        if LV then
            LV.send_login_verify_req  = nop
            LV.send_device_verify_req = nop
        end
        local MP = import("MemoryProtect")
        if MP then
            MP.VirtualProtect    = retTrue
            MP.IsMemoryReadable  = retFalse
            MP.IsMemoryWritable  = retFalse
            MP.CheckMemory       = retTrue
            MP.ProtectMemory     = retTrue
            MP.UnprotectMemory   = retTrue
            MP.ValidateMemory    = retTrue
            MP.VerifyMemory      = retTrue
            MP.ProtectRegion     = function(addr, size) return true end
            MP.UnprotectRegion   = function(addr, size) return true end
            MP.IsMemoryProtected = function(addr) return true end
        end
        local DD = _G.DebuggerDetect or package.loaded["DebuggerDetect"]
        if DD then
            hookFunctions(DD, {
                "IsDebuggerPresent","CheckBreakpoint","CheckTracer","CheckDebug",
                "CheckDebugger","DetectDebugger","DetectBreakpoint","DetectTracer","DetectDebug",
            }, retFalse)
        end
        local ED = _G.EmulatorDetect or package.loaded["EmulatorDetect"]
        if ED then
            hookFunctions(ED, {
                "IsEmulator","CheckVM","Detect","DetectEmulator","DetectVM",
                "DetectVirtualMachine",
            }, retFalse)
            ED.GetEmulatorType = retEmptyStr
        end
    end)
end

local function BypassExternalSDK()
    pcall(function()
        local td = _G.TDataMaster or package.loaded["libTDataMaster.so"]
        if td then
            hookFunctions(td, {
                "ReportEvent","ReportException","FlushData","SendReport",
                "ReportTelemetry","ReportAnalytics","ReportMetrics",
                "ReportStatistics","ReportPerformance","ReportBattery",
                "ReportTemperature","ReportFPS","ReportPing","ReportNetwork",
            }, nop)
            td.CollectData = retEmpty
        end
        for _, sdkName in ipairs({
            "Firebase","Adjust","AppsFlyer","FacebookAnalytics","GameAnalytics",
        }) do
            local sdk = _G[sdkName]
            if sdk then
                sdk.logEvent   = nop
                sdk.trackEvent = nop
                sdk.setEnabled = retFalse
                sdk.sendEvent  = nop
                sdk.report     = nop
            end
        end
    end)
end

local function BypassCrashHandlers()
    pcall(function()
        local CEH = package.loaded["client.network.Protocol.ClientErrorReportHandler"]
        if CEH then
            CEH.send_client_error_report           = nop
            CEH.send_client_crash_report           = nop
            CEH.send_client_tools_batch_report_req = nop
        end
        local BR = package.loaded["client.network.Protocol.BattleReportHandler"]
        if BR then
            hookFunctions(BR, {
                "send_battle_report","send_battle_result","send_vod_game_report_req",
                "send_batch_get_vod_info_req","send_get_game_report_req",
                "send_batch_get_game_report_req","send_get_game_report_by_uid_req",
            }, nop)
        end
        local Bug = package.loaded["client.network.Protocol.BugHandler"]
        if Bug then
            Bug.send_report_bug_info     = nop
            Bug.send_report_bug_feedback = nop
        end
        local Ping = package.loaded["client.network.Protocol.LobbyPingReportHandler"]
        if Ping then
            Ping.send_lobby_ping_report  = nop
            Ping.send_ingame_ping_report = nop
        end
        local Week = package.loaded["client.network.Protocol.WeekRportHandler"]
        if Week then
            Week.send_week_report = nop
            Week.send_week_detail = nop
        end
        local LC = package.loaded["client.logic.battle.logic_complaint"]
        if LC then
            LC.SendComplaintReq = nop
            LC.Submit           = nop
            LC.ReportPlayer     = nop
            LC.ShowComplaint    = nop
            LC.ShowHandle       = nop
        end
        for _, path in ipairs({
            "GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.EscapeBattleResultShowOBResultLogic",
            "GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowOBResultLogic",
        }) do
            local m = package.loaded[path]
            if m then
                m.OnBattleResult       = nop
                m.OnResultProcessStart = nop
            end
        end
        local ShowResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowResultLogic"]
        if ShowResult then
            hookFunctions(ShowResult, {
                "OnBattleResult","OnResultProcessStart","OnResultProcessContinue",
                "ReceiveData","SendEndFlow","OnReport","ShowResult",
                "ShowResultInternal","StopResultProcess",
            }, nop)
        end
        if _G.UnrealEngine and _G.UnrealEngine.CrashContext then
            _G.UnrealEngine.CrashContext = {
                SetCrashContext = nop,
                ReportCrash     = nop,
                AddCrashData    = nop,
            }
        end
    end)
end

local function KillSubsystems()
    pcall(function()
        local subMgr = safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local names = {
            "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem","SimulateCharacterSubsystem","ShootVerifySubSystemClient",
            "HiggsBosonComponent","AntiCheatSubsystem","IntegrityCheckSubsystem",
            "SignatureVerifySubsystem","MD5CheckSubsystem","PakVerifySubsystem",
            "ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem",
            "ClientDataStatistcsSubsystem","AFKReportorSubsystem","BehaviorScoreSubsystem",
            "GameReportSubsystem","ClientSecMrpcsFlowSubsystem","MrpcsFlowSubsystem",
            "CircleFlowSubsystem","SwiftHawkSubsystem","ReplaySubsystem",
            "FileCheckSubsystem","MemoryCheckSubsystem","SpeedCheckSubsystem",
            "WallCheckSubsystem","AvatarExceptionSubsystem","DNSMonitorSubsystem",
            "DeviceFingerprintSubsystem","ReplayMonitorSubsystem","TelemetrySubsystem",
            "GokubaSubsystem","RacingAntiCheatSubsystem","ClientBanSubsystem",
            "RealTimeBanSubsystem","TLogSubsystem","ReportSubsystem",
            "SecurityMonitorSubsystem","CheatDetectionSubsystem","ViolationMonitorSubsystem",
            "SuspiciousActivitySubsystem","AbnormalBehaviorSubsystem","NetworkMonitorSubsystem",
            "AnalyticsSubsystem","CrashReportSubsystem","PerformanceMonitorSubsystem",
            "InspectionSystemReportClientLogicSubsystem","SpectateAndReplaySubsystem",
            "AITrackingLogSubsystem","TDMAFKReportorSubsystem","OperationalStatsSubsystem",
            "HeartbeatSubsystem","DSActiveSubsystem","RescueBtnReplayTraceSubsystem",
        }
        local keywords = {
            "report","send","upload","verify","check","validate","scan",
            "detect","collect","flow","heartbeat","monitor","track","record",
            "log","alert","notify","ban","kick","suspend","flag","anti",
            "ac","analyze","process","handle","evaluate",
        }
        for _, name in ipairs(names) do
            local sub = subMgr:Get(name)
            if sub then
                blockByKeywords(sub, keywords, nop)
                for _, t in ipairs({"timer","heartbeatTimer","reportTimer",
                                     "checkTimer","monitorTimer","scanTimer",
                                     "detectTimer","uploadTimer","sendTimer"}) do
                    if sub[t] then
                        pcall(function() sub:RemoveGameTimer(sub[t]) end)
                        sub[t] = nil
                    end
                end
                sub.bIsActive = false
                sub.bMHActive = false
                sub.bIsEnabled = false
                sub.bIsRunning = false
                sub.bIsDetected = false
                sub.bIsBanned = false
                sub.bIsCheatDetected = false
                sub.bIsSuspicious = false
                if sub.StatsData then sub.StatsData = {} end
                if sub.ReportData then sub.ReportData = {} end
                if sub.QueueData then sub.QueueData = {} end
                if sub.CacheData then sub.CacheData = {} end
                if sub.LogQueue then sub.LogQueue = {} end
            end
        end
        local gk = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
        if gk then
            gk.ForwardFeature  = retEmpty
            gk.InitGokubaLogic = nop
            if gk.TimerHandle then
                local tk = require("common.time_ticker")
                if tk and tk.RemoveTimer then tk.RemoveTimer(gk.TimerHandle) end
                gk.TimerHandle = nil
            end
        end
    end)
    STATE.SUBSYSTEMS_KILLED = true
end

-- ============================================================================
--  SECTION 5 — HOST / URL BLACKLIST
-- ============================================================================
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
    "opensdk.tencent","exp.helpshift","loginsdkapi.zingplay","firebase","googleapis",
    "facebook","gvoice",
}
local BLACKLIST_PORTS = {
    "10334","11045","12221","13331","8011","8015","9001","20000","20001","20002","20003","20004",
    "20005","19700","1670","19900","14545","10213","8700","25177","10685","10336","10262","27000",
    "27040","27015","27030","10706","10095","12401","11008","10309","11075","10157","24798","10709",
    "6667","10087","31113","20371","10120","10664","13728","10769","10761","5061","5062","18081",
    "15692","9030","8080","8086","8088",
}

local function isHostBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = string.lower(str)
    for _, kw in ipairs(BLACKLIST_HOSTS) do
        if string.find(low, kw, 1, true) then return true end
    end
    for _, port in ipairs(BLACKLIST_PORTS) do
        if string.find(low, ":" .. port, 1, true) or string.find(low, "/" .. port, 1, true) then
            return true
        end
    end
    return false
end
_G.isHostBlacklisted = isHostBlacklisted

local function BlockHosts()
    pcall(function()
        if _G.HttpRequest then
            local orig = _G.HttpRequest
            _G.HttpRequest = function(url, ...)
                if isHostBlacklisted(url) then return nil end
                return orig(url, ...)
            end
        end
        if _G.FHttpModule and _G.FHttpModule.CreateRequest then
            local orig = _G.FHttpModule.CreateRequest
            _G.FHttpModule.CreateRequest = function(...)
                local url = select(1, ...)
                if isHostBlacklisted(url) then return nil end
                return orig(...)
            end
        end
        local netMods = {
            "client.slua.logic.network.logic_network",
            "client.slua.logic.download.report.puffer_tlog",
            "client.slua.data.BasicData.BasicDataClientReport",
            "GameLua.GameCore.Module.Network.NetworkManager",
            "client.network.Protocol.ClientTlogHandler",
            "client.network.Protocol.BattleReportHandler",
            "client.network.Protocol.ClientErrorReportHandler",
        }
        for _, path in ipairs(netMods) do
            local mod = package.loaded[path]
            if mod then
                for k, v in pairs(mod) do
                    if type(v) == "function" and type(k) == "string" then
                        local low = string.lower(k)
                        if string.find(low, "http", 1, true)
                        or string.find(low, "request", 1, true)
                        or string.find(low, "send", 1, true)
                        or string.find(low, "upload", 1, true)
                        or string.find(low, "post", 1, true)
                        or string.find(low, "report", 1, true) then
                            local origf = v
                            mod[k] = function(...)
                                local args = {...}
                                for _, a in ipairs(args) do
                                    if type(a) == "string" and isHostBlacklisted(a) then
                                        return nil
                                    end
                                end
                                return pcall(origf, ...)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================================
--  SECTION 6 — FINAL PROTECTION + CLEANUP + CONSOLE + TIMING + JNI + SPOOFS
-- ============================================================================
local function FinalProtection()
    pcall(function()
        for _, flag in ipairs({
            "ENABLE_REPORT","ENABLE_ANTI_CHEAT","ENABLE_SECURITY",
            "ENABLE_TELEMETRY","ENABLE_ANALYTICS","ENABLE_CRASH_REPORT",
            "ENABLE_PERFORMANCE_REPORT","ENABLE_TLOG","ENABLE_BAN_CHECK",
            "ENABLE_HAWKEYE","ENABLE_INSPECTION","ENABLE_BEHAVIOR_SCORE",
            "ENABLE_MONITOR","ENABLE_TRACK","ENABLE_DETECT","ENABLE_VERIFY",
            "ENABLE_CHECK","ENABLE_SCAN","ENABLE_AC","ENABLE_BEACON",
            "ENABLE_SDK","ENABLE_TSS","ENABLE_SWIFT_HAWK","ENABLE_GOKUBA",
            "ENABLE_HIGGS","ENABLE_CORONA","ENABLE_BAN",
            "ENABLE_VALIDATE","ENABLE_AUTHENTICATE","ENABLE_SIGNATURE",
        }) do
            if _G[flag] ~= nil then _G[flag] = false end
        end
        local origRequire = require
        local blockedModules = {
            "HiggsBosonComponent","PlayerSecurityInfoSubsystem","CoronaLabSubsystem",
            "ClientCircleFlowSubsystem","ModifierExceptionSubsystem",
            "ShootVerifySubSystemClient","ClientReportPlayerSubsystem",
            "DSReportPlayerSubsystem","ClientHawkEyePatrolSubsystem",
            "DSHawkEyePatrolSubsystem","ClientDataStatistcsSubsystem",
            "AFKReportorSubsystem","BehaviorScoreSubsystem","FileCheckSubsystem",
            "MemoryCheckSubsystem","SpeedCheckSubsystem","WallCheckSubsystem",
            "AvatarExceptionSubsystem","GameReportSubsystem","ClientSecMrpcsFlowSubsystem",
            "MrpcsFlowSubsystem","CircleFlowSubsystem","SwiftHawkSubsystem",
            "AntiCheatSubsystem","IntegrityCheckSubsystem","SignatureVerifySubsystem",
            "MD5CheckSubsystem","PakVerifySubsystem","OperationalStatsSubsystem",
            "HeartbeatSubsystem","ClientBanSubsystem","RealTimeBanSubsystem",
            "TLogSubsystem","ReportSubsystem","SecurityMonitorSubsystem",
            "CheatDetectionSubsystem","ViolationMonitorSubsystem",
            "SuspiciousActivitySubsystem","AbnormalBehaviorSubsystem",
            "NetworkMonitorSubsystem","AnalyticsSubsystem","CrashReportSubsystem",
            "PerformanceMonitorSubsystem","DNSMonitorSubsystem",
            "DeviceFingerprintSubsystem","ReplayMonitorSubsystem","TelemetrySubsystem",
        }
        if not _G._REGER_REQUIRE_HOOKED then
            _G._REGER_REQUIRE_HOOKED = true
            _G.require = function(m)
                if type(m) == "string" then
                    for _, b in ipairs(blockedModules) do
                        if string.find(m, b, 1, true) then return {} end
                    end
                end
                return origRequire(m)
            end
        end
        _G.TelemetryQueue = {}
        _G.bTelemetryEnabled = false
        _G.LogQueue = {}
        _G.bLoggingEnabled = false
        _G.ReportQueue = {}
        _G.bReportingEnabled = false
        _G.ExceptionQueue = {}
        _G.bExceptionReportingEnabled = false
        _G.CrashQueue = {}
        _G.bCrashReportingEnabled = false
        _G.TraceQueue = {}
        _G.bTracingEnabled = false
    end)
    STATE.FINAL_APPLIED = true
end

local function SuspiciousFlagsCleanup()
    pcall(function()
        local suspiciousVars = {
            "bIsCheating","bDetected","bBanned","SuspicionScore",
            "CheatDetected","AntiCheatFlag","IsHacking","bReported",
            "TrustScore","SecurityFlag","ViolationLevel","BanStatus",
            "bIsBan","bIsKick","bIsReported","CheatCount",
            "ViolationCount","SecurityScore","TrustLevel",
            "bIsCheater","bIsHacker","bIsModder","bIsInjector",
            "bIsHooker","bIsPatcher","bIsTamperer","bIsCorrupter",
            "bIsInvalid","bIsSpoofer","bIsFaker","bIsCloner",
            "bIsDuplicator","bIsConflicter","bIsOverlapper","bIsMismatcher",
            "bIsInconsistent","bIsUnexpected","bIsUnknown","bIsSuspicious",
            "bIsAbnormal","bIsCorrupt","bIsTampered","bIsModified",
            "bIsInjected","bIsHooked","bIsPatched","bIsSpoofed",
            "bIsFaked","bIsCloned","bIsDuplicated","bIsConflicted",
            "bIsOverlapped","bIsMismatched",
        }
        for _, var in ipairs(suspiciousVars) do _G[var] = nil end
        _G.BanStatus = { IsBanned=false, BanType=0, BanDuration=0, BanReason="", BanTime=0 }
        _G.bIsBanned = false
        _G.bIsSystemBanned = false
        _G.BanDuration = 0
        _G.BanType = 0
        _G.bDSKick = false
        _G.DSKickReason = nil
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
        local meta = getmetatable(_G) or {}
        local oldNewIndex = meta.__newindex
        meta.__newindex = function(t, k, v)
            local ks = tostring(k)
            for _, var in ipairs(suspiciousVars) do
                if string.find(ks, var, 1, true) then return end
            end
            if oldNewIndex then oldNewIndex(t, k, v) else rawset(t, k, v) end
        end
        setmetatable(_G, meta)
    end)
end

local function ConsoleCommandBypass()
    pcall(function()
        local pc = GetPlayerController()
        if IsValid(pc) then
            local KSL = import("KismetSystemLibrary")
            if KSL then
                local commands = {
                    "pak.DisablePakSignatureCheck 1","pakchunk.EnableSignatureCheck 0",
                    "s.VerifyPak 0","sig.Check 0","security.DisableChecks 1",
                    "CheatManager.EnableCheat 1","Net.BlockAllAntiCheat 1",
                    "AntiCheat.DisableAll 1","t.MaxFPS 165",
                    "DisableAllScreenMessages","UI.DisableMessageOfTheDay","ShowMOTD 0",
                    "r.UI.DisableAll 1","UI.HideAllWidgets 1","ShowBanNotice 0",
                    "ShowSuspension 0","ShowFrozenNotice 0","ShowRiskNotice 0",
                    "DisableBanUI 1","HideBanMessages 1","IgnoreSecurityChecks 1",
                    "UIToggle 0","HideUI 1","DisablePopup 1","SuppressDialogs 1",
                    "DisableHawkEye 1","DisableCoronaLab 1","DisableTSS 1",
                    "DisableGokuba 1","DisableSwiftHawk 1","DisableReport 1",
                    "DisableTLog 1","DisableTelemetry 1","DisableAnalytics 1",
                    "DisableCrashReport 1",
                }
                for _, cmd in ipairs(commands) do
                    pcall(function() KSL.ExecuteConsoleCommand(pc, cmd) end)
                end
            end
        end
        local KSL = import("KismetSystemLibrary")
        if KSL then
            KSL.IsDevelopment = retFalse
            KSL.IsShipping    = retTrue
            KSL.IsDebug       = retFalse
            KSL.IsEditor      = retFalse
            KSL.IsGame        = retTrue
            KSL.IsClient      = retTrue
            KSL.IsServer      = retFalse
            KSL.IsStandalone  = retFalse
        end
    end)
end

local function ClientEntryBypass()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus        = nop
            Client.GEMReportEnterLobbyEvent   = nop
            Client.TPerforPlatDisconnectReport= nop
            Client.IsConnected                = function(NetInterface) return true end
            Client.GetUnrealNetworkStatus     = retEmptyStr
            Client.MD5LuaString               = function(str) return "BYPASSED_MD5" end
            Client.GetDSVersion               = function() return "999.999.999" end
            Client.IsInReplayState            = retFalse
        end
        if NetManager then
            NetManager.ProcRespondMsg         = nop
            NetManager.isLogMsgAfterLogin     = false
            NetManager.logMsgMap              = {}
        end
        if EventSystem and not _G._REGER_EVENT_HOOKED then
            _G._REGER_EVENT_HOOKED = true
            local oldPost = EventSystem.postEvent
            EventSystem.postEvent = function(eventType, eventID, ...)
                if eventID and type(eventID) == "string" then
                    local blocked = {
                        "SECURITY","CHEAT","BAN","REPORT","FLAG",
                        "VIOLATION","DETECT","VERIFY","ANTI","AC_",
                        "SUSPICIOUS","ABNORMAL","MONITOR","TRACK",
                        "TELEMETRY","ANALYTICS","CRASH","DUMP",
                        "HAWKEYE","HIGGS","CORONA","GOKUBA","SWIFT",
                        "KICK","FROZEN","SUSPENSION","RISK","WARNING"
                    }
                    for _, be in ipairs(blocked) do
                        if eventID:find(be) then return end
                    end
                end
                if oldPost then oldPost(eventType, eventID, ...) end
            end
        end
    end)
end

local function TimingCheckBypass()
    pcall(function()
        local Engine = import("Engine")
        if Engine then
            Engine.GetAverageFPS = function() return 60 end
            Engine.GetFrameTime   = function() return 0.016 end
            Engine.IsLagging      = retFalse
            Engine.GetDeltaTime   = function() return 0.033 end
            Engine.GetTime        = function() return os.time() end
            Engine.GetTimestamp   = function() return os.time() end
            Engine.GetTick        = function() return os.clock() end
            Engine.GetSeconds     = function() return os.time() end
            Engine.GetMilliseconds= function() return os.time() * 1000 end
        end
        local GT = package.loaded["GameLua.GameCore.Data.GameTime"]
        if GT then
            GT.GetServerTime = function() return os.time() end
            GT.GetDeltaTime  = function() return 0.033 end
            GT.GetGameTime   = function() return os.time() end
            GT.GetRealTime   = function() return os.time() end
            GT.GetTickTime   = function() return os.clock() end
            GT.GetFrameTime  = function() return 0.016 end
        end
    end)
end

local function PacketEncryptionBypass()
    pcall(function()
        local PE = _G.PacketEncrypt or package.loaded["PacketEncrypt"]
        if PE then
            PE.Encrypt          = function(d) return d end
            PE.Decrypt          = function(d) return d end
            PE.VerifyChecksum   = retTrue
            PE.Validate         = retTrue
            PE.ValidatePacket   = retTrue
            PE.VerifyPacket     = retTrue
            PE.CheckPacket      = retTrue
            PE.EncryptPacket    = function(d) return d end
            PE.DecryptPacket    = function(d) return d end
            PE.ValidateChecksum = retTrue
            PE.CheckChecksum    = retTrue
        end
    end)
end

local function JNIBypass()
    pcall(function()
        local jni_ac = _G.JNI and _G.JNI.AntiCheat
        if jni_ac then
            jni_ac.CheckRoot          = retFalse
            jni_ac.CheckEmulator      = retFalse
            jni_ac.CheckDebugger      = retFalse
            jni_ac.CollectInfo        = retEmpty
            jni_ac.SendReport         = nop
            jni_ac.Validate           = retTrue
            jni_ac.CheckRootAccess    = retFalse
            jni_ac.CheckEmulatorAccess= retFalse
            jni_ac.CheckDebuggerAccess= retFalse
            jni_ac.CheckMemoryAccess  = retTrue
            jni_ac.CheckProcessAccess = retTrue
            jni_ac.CheckFileAccess    = retTrue
            jni_ac.CheckNetworkAccess = retTrue
            jni_ac.CheckSystemAccess  = retTrue
            jni_ac.CheckDeviceAccess  = retTrue
            jni_ac.CheckAPIAccess     = retTrue
            jni_ac.CheckSDKAccess     = retTrue
            jni_ac.CheckLibraryAccess = retTrue
            jni_ac.CheckFrameworkAccess = retTrue
            jni_ac.CheckPackageAccess = retTrue
        end
        local RD = _G.RootDetect or package.loaded["RootDetect"]
        if RD then
            RD.CheckRoot     = retFalse
            RD.CheckSu       = retFalse
            RD.CheckMagisk   = retFalse
            RD.CheckSuperSU  = retFalse
        end
        local JD = _G.JailbreakDetect or package.loaded["JailbreakDetect"]
        if JD then
            JD.CheckJailbreak = retFalse
            JD.CheckCydia     = retFalse
        end
    end)
end

local function SystemInfoSpoof()
    pcall(function()
        local SI = import("SystemInfo")
        if SI then
            SI.GetDeviceModel       = function() return "iPhone14,5" end
            SI.GetDeviceBrand       = function() return "Apple" end
            SI.GetAndroidVersion    = function() return "13" end
            SI.IsEmulator           = retFalse
            SI.IsRooted             = retFalse
            SI.IsDebugged           = retFalse
            SI.GetKernelVersion     = function() return "Linux version 4.14.116" end
            SI.CheckKernelIntegrity = retTrue
            SI.GetDeviceID          = function() return "00000000-0000-0000-0000-000000000000" end
        end
        local sys = import("KismetSystemLibrary")
        if sys then
            sys.GetDeviceId     = function() return "FAKE_DEVICE_" .. math.random(100000,999999) end
            sys.GetMacAddress   = function() return "00:11:22:33:44:55" end
            sys.GetSerialNumber = function() return "SN" .. math.random(1000000,9999999) end
        end
    end)
end

-- ============================================================================
--  نهاية الدفعة 1/2
-- ============================================================================
-- ============================================================================
--  SECTION 7 — MASTER INIT (يجمع كل الدوال)
-- ============================================================================
function _G.ApplyAllBypasses()
    pcall(BypassSLUA)
    pcall(BypassMD5)
    pcall(BypassHiggsBoson)
    pcall(BypassTSS)
    pcall(BypassAce)
    pcall(BypassXignCode)
    pcall(BypassBattlEye)
    pcall(BypassAnoSdk)
    pcall(BlockLogs)
    pcall(BlockScanners)
    pcall(BlockReportFlows)
    pcall(BlockReplay)
    pcall(BlockAntiReport)
    pcall(BlockNetwork)
    pcall(BypassBan)
    pcall(BypassDevice)
    pcall(BypassExternalSDK)
    pcall(BypassCrashHandlers)
    pcall(KillSubsystems)
    pcall(BlockHosts)
    pcall(FinalProtection)
    pcall(SuspiciousFlagsCleanup)
    pcall(ConsoleCommandBypass)
    pcall(ClientEntryBypass)
    pcall(TimingCheckBypass)
    pcall(PacketEncryptionBypass)
    pcall(JNIBypass)
    pcall(SystemInfoSpoof)
end

-- Aliases (توافق مع الأسماء القديمة)
_G.StartBypass_VIP_v3    = _G.ApplyAllBypasses
_G.CompleteAntiBanSystem = _G.ApplyAllBypasses
_G.RunAdditionalBypass   = _G.ApplyAllBypasses
_G.StartBypass           = _G.ApplyAllBypasses

_G.ForceReapplyBypass = function()
    STATE.HIGGS_BYPASSED    = false
    STATE.SUBSYSTEMS_KILLED = false
    STATE.NETWORK_BLOCKED   = false
    STATE.ANOSDK_DISABLED   = false
    STATE.FINAL_APPLIED     = false
    _G.ApplyAllBypasses()
end

function _G.GetBypassStatus()
    return {
        slua       = STATE.SLUA_BYPASSED,
        md5        = STATE.MD5_BYPASSED,
        higgs      = STATE.HIGGS_BYPASSED,
        subsystems = STATE.SUBSYSTEMS_KILLED,
        network    = STATE.NETWORK_BLOCKED,
        anosdk     = STATE.ANOSDK_DISABLED,
        final      = STATE.FINAL_APPLIED,
    }
end

-- ============================================================================
--  SECTION 8 — INITIAL RUN + PERSISTENT REAPPLY
-- ============================================================================
pcall(_G.ApplyAllBypasses)

local function startPersistentLoop()
    local ticker = safeRequire("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        -- Loop 1: سريع (2 ثانية) — Higgs + Network
        ticker.AddTimerLoop(0, function()
            pcall(BypassHiggsBoson)
            pcall(BlockNetwork)
        end, -1, 2.0)
        -- Loop 2: متوسط (5 ثواني) — Subsystems + AnoSdk
        ticker.AddTimerLoop(0, function()
            pcall(KillSubsystems)
            pcall(BypassAnoSdk)
        end, -1, 5.0)
        -- Loop 3: بطيء (30 ثانية) — إعادة كاملة
        ticker.AddTimerLoop(0, function()
            pcall(_G.ApplyAllBypasses)
        end, -1, 30.0)
        return true
    end
    return false
end

if not startPersistentLoop() then
    local function tryAttach()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(2.0, true, function()
                pcall(BypassHiggsBoson)
                pcall(BlockNetwork)
                pcall(KillSubsystems)
                pcall(BypassAnoSdk)
            end)
            return true
        end
        return false
    end
    if not tryAttach() then
        local ticker = safeRequire("common.time_ticker")
        if ticker and ticker.AddTimerOnce then
            local function retry()
                if not tryAttach() then
                    ticker.AddTimerOnce(1.5, retry)
                end
            end
            ticker.AddTimerOnce(1.5, retry)
        end
    end
end

_G.UBypass.ready = true

-- ============================================================================
--  SECTION 9 — STARTUP NOTICE
-- ============================================================================
print("========================================")
print("[BYPASS-ONLY] Anti-Cheat Bypass Loaded")
print("[BYPASS-ONLY] Version: 1.0")
print("[BYPASS-ONLY] Status: ACTIVE")
print("[BYPASS-ONLY] Layers: SLUA / MD5 / Higgs / TSS / ACE / XignCode / BattlEye")
print("[BYPASS-ONLY]         Scanners / Reports / Network / Ban / Device / Hosts")
print("[BYPASS-ONLY]         Final Protection + Persistent Loop (2s / 5s / 30s)")
print("[BYPASS-ONLY] API: _G.ApplyAllBypasses() / _G.GetBypassStatus()")
print("========================================")

-- ============================================================================
--  RETURN
-- ============================================================================
return _G.ApplyAllBypasses
