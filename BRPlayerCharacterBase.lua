
-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 GITHUB PROTECTION LOADER - iip44323-lab 🔥
-- ═══════════════════════════════════════════════════════════════════════
-- يُحمّل الحمايتين تلقائياً من GitHub
-- ═══════════════════════════════════════════════════════════════════════

local GITHUB_USERNAME = "iip44323-lab"
local GITHUB_REPO = "DevClayBypas"
local GITHUB_BRANCH = "main"

local GITHUB_BASE = "https://raw.githubusercontent.com/" ..
                    GITHUB_USERNAME .. "/" ..
                    GITHUB_REPO .. "/" ..
                    GITHUB_BRANCH .. "/"

local PROTECTION_FILES = {
    { name = "ClayBypass", path = "ClayBypass.lua" },
    { name = "CharacterBase", path = "CharacterBase.lua" },
}

local function LoadProtection(name, path)
    local url = GITHUB_BASE .. path
    if _G.HttpRequest then
        _G.HttpRequest(url, function(success, data)
            if success and data and #data > 0 then
                local fn, err = loadstring(data)
                if fn then
                    local ok, result = pcall(fn)
                    if ok then
                        print("[CLAY] ✅ " .. name .. " loaded")
                        return
                    else
                        print("[CLAY] ❌ " .. name .. " error: " .. tostring(result))
                    end
                else
                    print("[CLAY] ❌ " .. name .. " syntax: " .. tostring(err))
                end
            end
            print("[CLAY] ❌ " .. name .. " failed")
        end)
    end
end

local function LoadAllProtections()
    for _, protection in ipairs(PROTECTION_FILES) do
        LoadProtection(protection.name, protection.path)
    end
end

pcall(LoadAllProtections)

-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 SERO VIP MOD - Original Code Starts Here 🔥
-- ═══════════════════════════════════════════════════════════════════════

local Class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")
-- ═══ (باقي الكود كما هو بدون تغيير) ═══
--~~~~~~~~~~~
local Class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local LegalMsg = require("client.slua.logic.common.logic_common_legal_msg")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")

local SharedVisualAssistOwner = nil
local COLOR_HP_GREEN = FLinearColor(0, 1, 0, 0.95)
local COLOR_HP_YELLOW = FLinearColor(1, 1, 0, 0.95)
local COLOR_HP_RED = FLinearColor(1, 0, 0, 0.95)
local COLOR_BG = FLinearColor(0, 0, 0, 0.55)
local VEC_Z85, VEC_Z90, VEC_ZERO = FVector(0, 0, 85), FVector(0, 0, 90), FVector(0, 0, 0)
local StaticMeshClass = import("StaticMeshComponent")
local SkelMeshClass   = import("SkeletalMeshComponent")
local KismetSystemLib = import("KismetSystemLibrary")

local BOT_BEHIND_COLOR = {R=25.0, G=25.0, B=0.0, A=1.0, r=25.0, g=25.0, b=0.0, a=1.0}
local COLOR_VISIBLE = {R=25.0, G=0.0, B=0.0, A=1.0, r=25.0, g=0.0, b=0.0, a=1.0}
local COLOR_YELLOW_LINE = FLinearColor(1, 1, 0, 1)

local function IsPawnAlive(p)
    if not slua.isValid(p) then return false end
    if p.HealthStatus then return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus) end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local function GetPawnHealthRatio(p)
    -- HealthStatus أدق ويدعم البوتات واللاعبين معاً
    if p.HealthStatus then
        local hs = p.HealthStatus
        local hp    = hs.CurHp or hs.CurHP or hs.Health or hs.hp
        local maxHp = hs.MaxHp or hs.MaxHP or hs.MaxHealth or hs.maxHp
        if type(hp) == "number" and type(maxHp) == "number" then
            return math.max(0, math.min(1, hp / (maxHp <= 0 and 100 or maxHp)))
        end
    end
    local hp = p.GetHealth and p:GetHealth() or 100
    local maxHp = p.GetHealthMax and p:GetHealthMax() or 100
    return math.max(0, math.min(1, hp / (maxHp <= 0 and 100 or maxHp)))
end

local MOD_EXPIRY = {
    year = 2026,
    month = 10,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0
}
local MOD_EXPIRY_TS = os.time(MOD_EXPIRY)

_G.VIPConfig = _G.VIPConfig or {
    CountdownEnabled = true,
    CountdownEndTime = MOD_EXPIRY_TS,
}

local lastExpDialog = 0
local function IsExpired() return os.time() > MOD_EXPIRY_TS end
local function ShowExp()
    local ct = os.clock()
    if ct - lastExpDialog < 5 then return end
    lastExpDialog = ct
    pcall(function()
        LegalMsg.ShowOnePopUI({
            tabType = 999,
            title = "SERO VIP MOD",
            content = " WARNING !!!\n\nSTATUS : EXPIRED\n\nContact @urrzv",
            btnOKText = "",
            btnCancleText = ""
        })
    end)
end

-- ======= Countdown Widget (وقت انتهاء الملف) =======
local COUNTDOWN_BP = "/Game/UMG/UI_BP/Common/Tab/Vertical/LevelOne/LevelOne_Text/Item/Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP.Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP"
local CountdownWidgetInstance = nil

local function CreateCountdownWidget()
    if CountdownWidgetInstance then
        if slua.isValid(CountdownWidgetInstance) then
            return CountdownWidgetInstance
        else
            CountdownWidgetInstance = nil
        end
    end
    pcall(function()
        local widget = slua.loadUI(COUNTDOWN_BP)
        if not widget or not slua.isValid(widget) then return end
        local hud_mod = require("game_frontend_hud")
        local container = UIContainers and UIContainers.Top
        if container and hud_mod.AddToContainer then
            hud_mod.AddToContainer(container, widget, 10600)
        end
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 52))
            slot:SetSize(FVector2D(200, 36))
        end
        if widget.Image_Time then
            widget.Image_Time:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
        end
        if widget.TextBlock_Time then
            widget.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
            local fontInfo = widget.TextBlock_Time.Font
            if fontInfo then
                fontInfo.Size = 15
                widget.TextBlock_Time:SetFont(fontInfo)
            end
        end
        widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        CountdownWidgetInstance = widget
    end)
    return CountdownWidgetInstance
end

local function _M_UpdateMenuCountdown()
    local cfg = _G.VIPConfig
    if not cfg or not cfg.CountdownEnabled then
        if CountdownWidgetInstance and slua.isValid(CountdownWidgetInstance) then
            CountdownWidgetInstance:RemoveFromParent()
            CountdownWidgetInstance = nil
        end
        return
    end
    local widget = CreateCountdownWidget()
    if not widget or not slua.isValid(widget) then return end
    pcall(function()
        -- الوقت الحالي من الخادم أو النظام
        local now = 0
        local ok, tk = pcall(function()
            return require("client.common.time_util") or require("common.time_util")
        end)
        if ok and tk and tk.GetServerTimeInSec then
            now = tk.GetServerTimeInSec()
        else
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if pc and pc.GetServerTime then now = pc:GetServerTime() else now = os.time() end
        end

        local leftTime = math.max(0, math.floor(cfg.CountdownEndTime - now))

        if leftTime <= 0 then
            cfg.CountdownEnabled = false
            widget:RemoveFromParent()
            CountdownWidgetInstance = nil
            return
        end

        if widget.TextBlock_Time then
            local timeStr = ""
            local ok2, tk2 = pcall(function()
                return require("client.common.time_util") or require("common.time_util")
            end)
            if ok2 and tk2 and tk2.FormatCountDownTime_D_or_HMS then
                timeStr = tk2.FormatCountDownTime_D_or_HMS(leftTime, 1)
            else
                local d = math.floor(leftTime / 86400)
                local h = math.floor((leftTime % 86400) / 3600)
                local m = math.floor((leftTime % 3600) / 60)
                local s = leftTime % 60
                if d > 0 then
                    timeStr = string.format("%dد %02d:%02d:%02d", d, h, m, s)
                else
                    timeStr = string.format("%02d:%02d:%02d", h, m, s)
                end
            end
            widget.TextBlock_Time:SetText(timeStr)
        end
    end)
end
-- ======= نهاية Countdown Widget =======

_G.SERO = _G.SERO or {
    car_detect    = false,
    weapon_detect = false,
    player_detect = false,
    distance      = false,
    aim_assist    = false,
    headshot      = false,
    headshot_power = 40,       -- قوة الهيدشوت (0-100)
    magic_bullet  = false,
    ipad_view     = false,
    aim_power     = 35,
    magic_head    = 15,
    magic_body    = 15,
    magic_legs    = 15,
    ipad_fov      = 100,
    fps_limit     = 60,
    weapon_red    = false,
    weapon_yellow = false,
    weapon_green  = false,
    weapon_purple = false,
    weapon_blue   = false,
    car_green     = false,
    car_red       = false,
    car_yellow    = false,
    car_purple    = false,
    player_green  = false,
    player_yellow = false,
    player_sky    = true,      -- اللون السمائي (الافتراضي كما كان في الكود الأصلي)
    player_purple = false,
    player_orange = false,
    bot_detect    = false,     -- كشف البوتات (مستقل عن player_detect)
    bot_green     = false,
    bot_yellow    = true,      -- الافتراضي: أصفر
    bot_sky       = false,
    bot_purple    = false,
    bot_orange    = false,
    rgb_hue       = 0,         -- الهيو الحالي للألوان القزحية (0-360)
    box_esp       = true,      -- كشف المربع (Box ESP)
    show_health   = true,      -- كشف الصحه
    show_name     = true,      -- كشف الاسم
    show_counts   = true,
    small_crosshair = false,
    black_sky     = false,     -- السماء السوداء
    map_marker    = true,      -- ماركت اللاعبين على الخريطة
    detect_freeze = true,      -- نظام الكشف الكامل (true=يعمل، false=متوقف)
    remove_fog    = true,      -- ازالة الضباب
    remove_water  = true,      -- ازالة الماء
}

local function clearWeaponColors()
    _G.SERO.weapon_red    = false
    _G.SERO.weapon_yellow = false
    _G.SERO.weapon_green  = false
    _G.SERO.weapon_purple = false
    _G.SERO.weapon_blue   = false
end

local function clearCarColors()
    _G.SERO.car_green  = false
    _G.SERO.car_red    = false
    _G.SERO.car_yellow = false
    _G.SERO.car_purple = false
end

local function clearPlayerColors()
    _G.SERO.player_green  = false
    _G.SERO.player_yellow = false
    _G.SERO.player_sky    = false
    _G.SERO.player_purple = false
    _G.SERO.player_orange = false
end

local function clearBotColors()
    _G.SERO.bot_green  = false
    _G.SERO.bot_yellow = false
    _G.SERO.bot_sky    = false
    _G.SERO.bot_purple = false
    _G.SERO.bot_orange = false
end

-- حساب لون RGB القزحي الحالي (HSV→RGB، سطوع عالٍ، انتقال سلس)
-- تحويل HSV إلى RGB (v وs ثابتان عند 1.0)
local function HSVtoRGB(h)
    local v = 25.0
    local c = v
    local x = c * (1.0 - math.abs((h / 60.0) % 2.0 - 1.0))
    local r, g, b
    if     h < 60  then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else                r, g, b = c, 0, x end
    return {R=r, G=g, B=b, A=1.0, r=r, g=g, b=b, a=1.0}
end

-- ألوان قزحية للسيارات والأسلحة (الهيو الأصلي)
local function GetRGBColor()
    return HSVtoRGB(_G.SERO.rgb_hue)
end

-- ألوان قزحية للاعبين: تتجنب الأحمر (0°-30° و330°-360°) لأنه مخصص للعدو المرئي
-- يتم تعيين الهيو في النطاق 30°-330° فقط (300 درجة متاحة من أصل 360)
local function GetPlayerRGBColor()
    local h = (_G.SERO.rgb_hue * (300 / 360) + 30) % 360
    return HSVtoRGB(h)
end

-- هل يوجد لون ثابت مختار للأسلحة؟
local function HasActiveWeaponColor()
    return _G.SERO.weapon_red or _G.SERO.weapon_yellow or _G.SERO.weapon_green
        or _G.SERO.weapon_purple or _G.SERO.weapon_blue
end

-- هل يوجد لون ثابت مختار للسيارات؟
local function HasActiveCarColor()
    return _G.SERO.car_green or _G.SERO.car_red
        or _G.SERO.car_yellow or _G.SERO.car_purple
end

-- هل يوجد لون ثابت مختار للاعبين؟
local function HasActivePlayerColor()
    return _G.SERO.player_green or _G.SERO.player_yellow or _G.SERO.player_sky
        or _G.SERO.player_purple or _G.SERO.player_orange
end

local PLAYER_COLORS = {
    player_sky    = {R=0.0,  G=25.0, B=25.0, A=1.0, r=0.0,  g=25.0, b=25.0, a=1.0},
    player_green  = {R=0.0,  G=25.0, B=0.0,  A=1.0, r=0.0,  g=25.0, b=0.0,  a=1.0},
    player_yellow = {R=25.0, G=25.0, B=0.0,  A=1.0, r=25.0, g=25.0, b=0.0,  a=1.0},
    player_purple = {R=15.0, G=0.0,  B=25.0, A=1.0, r=15.0, g=0.0,  b=25.0, a=1.0},
    player_orange = {R=25.0, G=8.0,  B=0.0,  A=1.0, r=25.0, g=8.0,  b=0.0,  a=1.0},
}

local function GetActivePlayerBehindColor()
    -- لون ثابت مختار → استخدمه مباشرة
    for key, color in pairs(PLAYER_COLORS) do
        if _G.SERO[key] then return color end
    end
    -- لا يوجد لون ثابت → ألوان قزحية خاصة باللاعبين (إزاحة 120° عن السيارات والأسلحة)
    return GetPlayerRGBColor()
end

local BOT_COLORS = {
    bot_sky    = {R=0.0,  G=25.0, B=25.0, A=1.0, r=0.0,  g=25.0, b=25.0, a=1.0},
    bot_green  = {R=0.0,  G=25.0, B=0.0,  A=1.0, r=0.0,  g=25.0, b=0.0,  a=1.0},
    bot_yellow = {R=25.0, G=25.0, B=0.0,  A=1.0, r=25.0, g=25.0, b=0.0,  a=1.0},
    bot_purple = {R=15.0, G=0.0,  B=25.0, A=1.0, r=15.0, g=0.0,  b=25.0, a=1.0},
    bot_orange = {R=25.0, G=8.0,  B=0.0,  A=1.0, r=25.0, g=8.0,  b=0.0,  a=1.0},
}

local function HasActiveBotColor()
    return _G.SERO.bot_green or _G.SERO.bot_yellow or _G.SERO.bot_sky
        or _G.SERO.bot_purple or _G.SERO.bot_orange
end

-- ألوان قزحية للبوتات: إزاحة 240° لتميزها عن اللاعبين والأسلحة
local function GetBotRGBColor()
    local h = (_G.SERO.rgb_hue + 240) % 360
    return HSVtoRGB(h)
end

local function GetActiveBotColor()
    for key, color in pairs(BOT_COLORS) do
        if _G.SERO[key] then return color end
    end
    return GetBotRGBColor()
end

local ColorNames = {
    "Color", "BaseColor", "BodyColor", "MainColor", "Tint",
    "Para_Color", "Para_ColorTint", "Para_Color_1",
    "DiffuseColor", "EmissiveColor", "GlowColor", "TintColor",
    "SelectionColor", "颜色", "主体颜色", "附加颜色",
    "Extra Light Color"
}

local WEAPON_COLOR_MAP = {
    weapon_red    = {R=20.0, G=0.0,  B=0.0,  A=1.0, r=20.0, g=0.0,  b=0.0,  a=1.0},
    weapon_yellow = {R=20.0, G=20.0, B=0.0,  A=1.0, r=20.0, g=20.0, b=0.0,  a=1.0},
    weapon_green  = {R=0.0,  G=20.0, B=0.0,  A=1.0, r=0.0,  g=20.0, b=0.0,  a=1.0},
    weapon_purple = {R=15.0, G=0.0,  B=20.0, A=1.0, r=15.0, g=0.0,  b=20.0, a=1.0},
    weapon_blue   = {R=0.0,  G=0.0,  B=20.0, A=1.0, r=0.0,  g=0.0,  b=20.0, a=1.0},
}

local CAR_COLOR_MAP = {
    car_green  = {R=0.0,  G=20.0, B=0.0,  A=1.0, r=0.0,  g=20.0, b=0.0,  a=1.0},
    car_red    = {R=20.0, G=0.0,  B=0.0,  A=1.0, r=20.0, g=0.0,  b=0.0,  a=1.0},
    car_yellow = {R=20.0, G=20.0, B=0.0,  A=1.0, r=20.0, g=20.0, b=0.0,  a=1.0},
    car_purple = {R=15.0, G=0.0,  B=20.0, A=1.0, r=15.0, g=0.0,  b=20.0, a=1.0},
}

local function GetAllMeshes(actor)
    local meshes = {}
    if not slua.isValid(actor) then return meshes end
    pcall(function()
        if slua.isValid(actor.Mesh) then table.insert(meshes, actor.Mesh) end
        if StaticMeshClass then
            local comps = actor:GetComponentsByClass(StaticMeshClass)
            if comps then
                local count = type(comps.Num) == "function" and comps:Num() or #comps
                for i = 1, math.min(count, 10) do
                    local comp = type(comps.Get) == "function" and comps:Get(i-1) or comps[i]
                    if slua.isValid(comp) then table.insert(meshes, comp) end
                end
            end
        end
        if SkelMeshClass then
            local comps = actor:GetComponentsByClass(SkelMeshClass)
            if comps then
                local count = type(comps.Num) == "function" and comps:Num() or #comps
                for i = 1, math.min(count, 10) do
                    local comp = type(comps.Get) == "function" and comps:Get(i-1) or comps[i]
                    if slua.isValid(comp) and comp ~= actor.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    return meshes
end

local function ApplyActorWallhack(actor, color, emissive)
    if not slua.isValid(actor) then return end
    local meshes = GetAllMeshes(actor)
    local scale = {R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0}
    local blendMode = 2
    actor.WH_MIDs = actor.WH_MIDs or {}
    for _, comp in ipairs(meshes) do
        if slua.isValid(comp) then
            pcall(function()
                comp.UseScopeDistanceCulling = false
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
                local s, matInterface = pcall(function() return comp:GetMaterial(0) end)
                if s and slua.isValid(matInterface) then
                    local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                    if s2 and slua.isValid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= blendMode then baseMat.BlendMode = blendMode end
                    end
                end
            end)
            local compKey = tostring(comp)
            actor.WH_MIDs[compKey] = actor.WH_MIDs[compKey] or {}
            for i = 0, 10 do
                local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                if not s or not slua.isValid(matInterface) then break end
                local currentCached = actor.WH_MIDs[compKey][i]
                if not slua.isValid(currentCached) then
                    local s2, newMid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                    if s2 and slua.isValid(newMid) then
                        actor.WH_MIDs[compKey][i] = newMid
                        currentCached = newMid
                    end
                end
                if slua.isValid(currentCached) then
                    pcall(function()
                        for _, name in ipairs(ColorNames) do
                            currentCached:SetVectorParameterValue(name, color)
                        end
                        currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                        currentCached:SetScalarParameterValue("Emissive", emissive or 3.0)
                        currentCached:SetScalarParameterValue("EmissiveStrength", emissive or 3.0)
                        currentCached:SetScalarParameterValue("GlowIntensity", emissive or 3.0)
                    end)
                end
            end
        end
    end
end

local function ApplyWeaponColor()
    if not _G.SERO.weapon_detect then return end
    local activeColor = nil
    if HasActiveWeaponColor() then
        -- لون ثابت مختار
        for key, color in pairs(WEAPON_COLOR_MAP) do
            if _G.SERO[key] then activeColor = color; break end
        end
    else
        -- لا يوجد لون ثابت → ألوان قزحية تلقائياً
        activeColor = GetRGBColor()
    end
    if not activeColor then return end
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponMgr = player.WeaponManagerComponent
        if not slua.isValid(weaponMgr) then return end
        local weapon = weaponMgr.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end
        ApplyActorWallhack(weapon, activeColor, 3.0)
    end)
end

local function ApplyVehicleColor()
    if not _G.SERO.car_detect then return end
    local activeColor = nil
    if HasActiveCarColor() then
        -- لون ثابت مختار
        for key, color in pairs(CAR_COLOR_MAP) do
            if _G.SERO[key] then activeColor = color; break end
        end
    else
        -- لا يوجد لون ثابت → ألوان قزحية تلقائياً
        activeColor = GetRGBColor()
    end
    if not activeColor then return end
    pcall(function()
        local allVehicles = Game:GetAllVehicles() or {}
        for _, vehicle in pairs(allVehicles) do
            if slua.isValid(vehicle) then
                ApplyActorWallhack(vehicle, activeColor, 3.0)
            end
        end
    end)
end

local function ApplyWallhack(enemy, pc, behindColor)
    if not slua.isValid(enemy) then return end
    -- اللون يُمرَّر من الخارج مباشرة (بوت أو لاعب) بدون استدعاء Game:IsAI()
    local finalBehindColor = behindColor
    pcall(function()
        local meshes = GetAllMeshes(enemy)
        local isVisible = false
        if slua.isValid(pc) and type(pc.LineOfSightTo) == "function" then
            pcall(function() isVisible = pc:LineOfSightTo(enemy) end)
        end
        local finalColor = isVisible and COLOR_VISIBLE or finalBehindColor
        local scale = {R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0}
        local blendMode = 2
        enemy.WH_MIDs = enemy.WH_MIDs or {}
        local stateChanged = (enemy.WH_LastColorR ~= finalColor.R)
            or (enemy.WH_LastColorG ~= finalColor.G)
            or (enemy.WH_LastColorB ~= finalColor.B)
            or (enemy.WH_LastBlendMode ~= blendMode)
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                pcall(function()
                    comp.UseScopeDistanceCulling = false
                    comp.PrimitiveShadingStrategy = 1
                    comp.ShadingRate = 6
                    local s, matInterface = pcall(function() return comp:GetMaterial(0) end)
                    if s and slua.isValid(matInterface) then
                        local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                        if s2 and slua.isValid(baseMat) then
                            if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                            if baseMat.BlendMode ~= blendMode then baseMat.BlendMode = blendMode end
                        end
                    end
                end)
                local compKey = tostring(comp)
                enemy.WH_MIDs[compKey] = enemy.WH_MIDs[compKey] or {}
                for i = 0, 10 do
                    local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                    if not s or not slua.isValid(matInterface) then break end
                    local currentCached = enemy.WH_MIDs[compKey][i]
                    local isNewMID = false
                    local needCacheUpdate = false
                    if not slua.isValid(currentCached) then
                        local s2, newMid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                        if s2 and slua.isValid(newMid) then
                            enemy.WH_MIDs[compKey][i] = newMid
                            currentCached = newMid
                            isNewMID = true
                            needCacheUpdate = true
                        end
                    else
                        if matInterface ~= currentCached then
                            pcall(function() comp:SetMaterial(i, currentCached) end)
                            needCacheUpdate = true
                        end
                    end
                    if slua.isValid(currentCached) and (stateChanged or isNewMID or needCacheUpdate) then
                        pcall(function()
                            for _, name in ipairs(ColorNames) do
                                currentCached:SetVectorParameterValue(name, finalColor)
                            end
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            currentCached:SetScalarParameterValue("Emissive", 3.0)
                            currentCached:SetScalarParameterValue("EmissiveStrength", 3.0)
                            currentCached:SetScalarParameterValue("GlowIntensity", 3.0)
                        end)
                    end
                end
            end
        end
        if stateChanged then
            enemy.WH_LastColorR   = finalColor.R
            enemy.WH_LastColorG   = finalColor.G
            enemy.WH_LastColorB   = finalColor.B
            enemy.WH_LastBlendMode = blendMode
        end
    end)
end

-- ================ إعداد ماركت الخريطة (type 9999) ================
local mapMarkConfigDone = false
local function SetupMapMarkConfig()
    if mapMarkConfigDone then return end
    mapMarkConfigDone = true
    pcall(function()
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        if not ScreenMarkConfig then return end
        ScreenMarkConfig[9999] = {
            UIPathName             = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
            MaxWidgetNum           = 99,
            MaxShowDistance        = 6000000.0,
            bBindOutScreen         = true,
            bBindBlocked           = true,
            bIsBindingActor        = true,
            BindSocketName         = "head",
            bUseLuaWorldSocketName = true,
            WorldPositionOffset    = FVector(0, 0, 50),
            bNeedPreLoad           = true,
            Priority               = 2,
        }
    end)
end

-- ======================== نظام الحماية المتكامل ========================
local function CompleteAntiBanSystem()
    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            TssSdk.OnRecvData = function() end
            TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = function() return true end
            TssSdk.IsEmulator = function() return false end
            TssSdk.GetTssSdkReportInfo = function() return "" end
            TssSdk.ReportException = function() end
            TssSdk.ReportData = function() end
            TssSdk.CheckIntegrity = function() return true end
            TssSdk.VerifySignature = function() return true end
            TssSdk.CollectEvidence = function() return nil end
            TssSdk.UploadLog = function() end
            TssSdk.SendAntiData = function() end
            TssSdk.ReportGameStart = function() end
            TssSdk.ReportGameEnd = function() end
            TssSdk.ReportCrash = function() end
            TssSdk.ReportViolation = function() end
            TssSdk.ReportSuspicious = function() end
            TssSdk.ReportBan = function() end
            TssSdk.ReportKick = function() end
            TssSdk.ReportWarning = function() end
            TssSdk.ReportInfo = function() end
            TssSdk.ReportDebug = function() end
            TssSdk.ReportError = function() end
            TssSdk.ReportFatal = function() end
            TssSdk.ReportMemory = function() end
            TssSdk.ReportProcess = function() end
            TssSdk.ReportModule = function() end
            TssSdk.ReportThread = function() end
            TssSdk.ReportFile = function() end
            TssSdk.ReportNetwork = function() end
            TssSdk.ReportDevice = function() end
            TssSdk.ReportSystem = function() end
            TssSdk.ReportGame = function() end
            TssSdk.ReportUser = function() end
            TssSdk.ReportAccount = function() end
            TssSdk.ReportSession = function() end
            TssSdk.ReportPerformance = function() end
            TssSdk.ReportBattery = function() end
            TssSdk.ReportTemperature = function() end
            TssSdk.ReportFPS = function() end
            TssSdk.ReportPing = function() end
            TssSdk.ReportPacket = function() end
            TssSdk.ReportCheat = function() end
            TssSdk.ReportHack = function() end
            TssSdk.ReportMod = function() end
            TssSdk.ReportInject = function() end
            TssSdk.ReportDebugger = function() end
            TssSdk.ReportEmulator = function() end
            TssSdk.ReportRoot = function() end
            TssSdk.ReportJailbreak = function() end
            TssSdk.ReportVM = function() end
            TssSdk.ReportHook = function() end
            TssSdk.ReportPatch = function() end
            TssSdk.ReportTamper = function() end
            TssSdk.ReportCorrupt = function() end
            TssSdk.ReportInvalid = function() end
            TssSdk.ReportSpoof = function() end
            TssSdk.ReportFake = function() end
            TssSdk.ReportClone = function() end
            TssSdk.ReportDuplicate = function() end
            TssSdk.ReportConflict = function() end
            TssSdk.ReportOverlap = function() end
            TssSdk.ReportMismatch = function() end
            TssSdk.ReportInconsistent = function() end
            TssSdk.ReportUnexpected = function() end
            TssSdk.ReportUnknown = function() end
        end

        local ace = _G.ace or package.loaded["libace.so"]
        if ace then
            ace.ReportData = function() end
            ace.CheckIntegrity = function() return true end
            ace.ScanMemory = function() return false end
            ace.VerifyProcess = function() return true end
            ace.CheckModule = function() return true end
            ace.ReportViolation = function() end
            ace.KickPlayer = function() end
            ace.BanPlayer = function() end
            ace.CollectInfo = function() return {} end
            ace.SendReport = function() end
            ace.ValidateClient = function() return true end
            ace.CheckDebugger = function() return false end
            ace.CheckEmulator = function() return false end
            ace.CheckRoot = function() return false end
            ace.ReportCheat = function() end
            ace.ReportHack = function() end
            ace.ReportMod = function() end
            ace.ReportInject = function() end
            ace.ReportHook = function() end
            ace.ReportPatch = function() end
            ace.ReportTamper = function() end
            ace.ReportCorrupt = function() end
            ace.ReportInvalid = function() end
            ace.ReportSpoof = function() end
            ace.ReportFake = function() end
        end

        local XignCode = _G.XignCode or package.loaded["xigncode"]
        if XignCode then
            XignCode.SendReport = function() end
            XignCode.CheckProcess = function() return true end
            XignCode.VerifyIntegrity = function() return true end
            XignCode.ScanModules = function() return {} end
            XignCode.ReportException = function() end
            XignCode.ValidateMemory = function() return true end
            XignCode.CheckDebugger = function() return false end
            XignCode.KickPlayer = function() end
            XignCode.BanPlayer = function() end
            XignCode.EncryptData = function(data) return data end
            XignCode.DecryptData = function(data) return data end
            XignCode.ReportCheat = function() end
            XignCode.ReportHack = function() end
            XignCode.ReportMod = function() end
            XignCode.ReportInject = function() end
            XignCode.ReportHook = function() end
            XignCode.ReportPatch = function() end
            XignCode.ReportTamper = function() end
        end

        local BattlEye = _G.BattlEye or package.loaded["BattlEye"]
        if BattlEye then
            BattlEye.SendReport = function() end
            BattlEye.KickPlayer = function() end
            BattlEye.ValidatePlayer = function() return true end
            BattlEye.CheckMemory = function() return true end
            BattlEye.VerifyIntegrity = function() return true end
            BattlEye.ReportViolation = function() end
            BattlEye.ScanProcess = function() return true end
            BattlEye.BanPlayer = function() end
            BattlEye.CollectEvidence = function() return {} end
            BattlEye.ReportCheat = function() end
            BattlEye.ReportHack = function() end
            BattlEye.ReportMod = function() end
            BattlEye.ReportInject = function() end
            BattlEye.ReportHook = function() end
        end

        local HiggsBosonComponent = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if HiggsBosonComponent then
            HiggsBosonComponent.bIsEnable = false
            HiggsBosonComponent.bMHActive = false
            HiggsBosonComponent.bCallPreReplication = false
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
            HiggsBosonComponent.CheckClientConfig = function() return false end
            HiggsBosonComponent.GetSecurityInfo = function() return {} end
            HiggsBosonComponent.ReportSecurityAlert = function() end
            HiggsBosonComponent.ValidateClient = function() return true end
            HiggsBosonComponent.CheckIntegrity = function() return true end
            HiggsBosonComponent.BlackList = {}
        end

        local reportPaths = {
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
        for _, path in ipairs(reportPaths) do
            local module = package.loaded[path]
            if module then
                if module.Report then module.Report = function() end end
                if module.SendReport then module.SendReport = function() end end
                if module.ReportEvent then module.ReportEvent = function() end end
                if module.ReportException then module.ReportException = function() end end
                if module.ReportData then module.ReportData = function() end end
                if module.ReportTLogEvent then module.ReportTLogEvent = function() end end
                if module.OnInit then module.OnInit = function() end end
                if module._OnPlayerKilledOtherPlayer then module._OnPlayerKilledOtherPlayer = function() end end
                if module._RecordFatalDamager then module._RecordFatalDamager = function() end end
                if module._OnBattleResult then module._OnBattleResult = function() end end
            end
        end

        if _G.GameplayCallbacks then
            local GC = _G.GameplayCallbacks
            local noop = function() end
            local empty = function() return {} end
            GC.ReportAttackFlow = noop
            GC.ReportSecAttackFlow = noop
            GC.ReportHurtFlow = noop
            GC.ReportFireArms = noop
            GC.ReportVerifyInfoFlow = noop
            GC.ReportMrpcsFlow = noop
            GC.ReportPlayerBehavior = noop
            GC.ReportTeammatHurt = noop
            GC.ReportMisKillByTeammate = noop
            GC.ReportForbitPick = noop
            GC.ReportPlayerMoveRoute = noop
            GC.ReportPlayerPosition = noop
            GC.ReportVehicleMoveFlow = noop
            GC.ReportSecTgameMovingFlow = noop
            GC.ReportParachuteData = noop
            GC.SendTssSdkAntiDataToLobby = noop
            GC.SendDSErrorLogToLobby = noop
            GC.SendDSErrorLogToLobbyOnece = noop
            GC.SendDSHawkEyePatrolLogToLobby = noop
            GC.ReportEquipmentFlow = noop
            GC.ReportAimFlow = noop
            GC.ReportHitFlow = noop
            GC.GetWeaponReport = empty
            GC.GetOneWeaponReport = empty
            GC.ReportHeavyWeaponBoxSpawnFlow = noop
            GC.ReportHeavyWeaponBoxActivationFlow = noop
            GC.ReportHeavyWeaponBoxOpenPlayerFlow = noop
            GC.ReportHeavyWeaponBoxItemFlow = noop
            GC.ReportPlayersPing = noop
            GC.ReportPlayerIP = noop
            GC.ReportPlayerFramePingRecord = noop
            GC.OnDSConnectionSaturated = noop
            GC.ReportDSNetSaturation = noop
            GC.ReportNetContinuousSaturate = noop
            GC.ReportDSNetRate = noop
            GC.SendClientStats = noop
            GC.SendServerAvgTickDelta = noop
            GC.ReportCircleFlow = noop
            GC.ReportDSCircleFlow = noop
            GC.ReportJumpFlow = noop
            GC.ReportAIStrategyInfo = noop
            GC.SendAIDeliveryInfo = noop
            GC.ReportDailyTaskInfo = noop
            GC.ReportMatchRoomData = noop
            GC.SendPlayerSpectatingLog = noop
            GC.ReportIDCardProduceFlow = noop
            GC.ReportIDCardPickUpFlow = noop
            GC.ReportIDCardDestroyFlow = noop
            GC.ReportRevivalFlow = noop
            GC.ReportGameSetting = noop
            GC.ReportGameSettingNew = noop
            GC.ReportAntsVoiceTeamCreate = noop
            GC.ReportAntsVoiceTeamQuit = noop
            GC.ReportCommonInfo = noop
            GC.ReportLightweightStat = noop
            GC.SendSecTLog = noop
            GC.SendDataMiningTLog = noop
            GC.SendActivityTLog = noop
            GC.GetGeneralTLogData = empty
            GC.OnDSPlayerStateChanged = function(UID, InPlayerState, ...)
                if InPlayerState then
                    local state = string.lower(tostring(InPlayerState))
                    if string.find(state, "cheat") or string.find(state, "ban") or string.find(state, "kick") then return end
                end
            end
            GC.OnPlayerNetConnectionClosed = noop
            GC.OnPlayerActorChannelError = noop
            GC.OnPlayerRPCValidateFailed = noop
            GC.OnPlayerSpectateException = noop
            GC.OnShutdownAfterError = noop
            GC.IsBypassed = true
        end

        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["log_shooting_miss"]=1,
                ["ReportCircleFlow"]=1, ["report_ds_player_circle_flow"]=1,
                ["ReportJumpFlow"]=1, ["ReportGameStartFlow"]=1, ["ReportGameEndFlow"]=1,
                ["report_players_ping"]=1, ["report_player_ip"]=1, ["report_player_frame_ping_record"]=1,
                ["report_net_saturate"]=1, ["report_ds_netsaturate"]=1, ["report_ds_net_continuous_saturate"]=1,
                ["report_ds_netrate"]=1, ["report_unrealnet_clientstats"]=1, ["report_serverstat_avgtickdelta"]=1,
                ["report_all_players_address"]=1, ["report_ai_strategyinfo"]=1, ["ReportAIActionFlow"]=1,
                ["ReportGenerateMonsterFlow"]=1, ["report_ds_match_room_data"]=1, ["SendSpectatingLog"]=1,
                ["ReportIDCardProduceFlow"]=1, ["ReportIDCardPickUpFlow"]=1, ["ReportIDCardDestroyFlow"]=1,
                ["ReportRevivalFlow"]=1, ["ReportGameSetting"]=1, ["ReportGameSettingNew"]=1,
                ["ReportAntsVoiceTeamCreate"]=1, ["ReportAntsVoiceTeamQuit"]=1, ["report_common_info"]=1,
                ["report_common_battle_info"]=1, ["report_client_scan_result"]=1, ["tss_sdk_report"]=1,
                ["ReportSecurityAlert"]=1, ["ReportAntiCheat"]=1, ["ReportSuspiciousActivity"]=1,
                ["ReportViolation"]=1, ["ReportBan"]=1, ["ReportKick"]=1,
                ["ReportCheat"]=1, ["ReportHack"]=1, ["ReportMod"]=1,
                ["ReportInject"]=1, ["ReportHook"]=1, ["ReportPatch"]=1,
                ["ReportTamper"]=1, ["ReportCorrupt"]=1, ["ReportInvalid"]=1,
                ["ReportSpoof"]=1, ["ReportFake"]=1, ["ReportClone"]=1,
                ["ReportDuplicate"]=1, ["ReportConflict"]=1, ["ReportOverlap"]=1,
                ["ReportMismatch"]=1, ["ReportInconsistent"]=1, ["ReportUnexpected"]=1,
                ["ReportUnknown"]=1,
            }
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return end
                return originalSend(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end

        local CrashSight = _G.CrashSight or package.loaded["CrashSight"]
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end
            CrashSight.Log = function() end
            CrashSight.UploadLog = function() end
            CrashSight.SendReport = function() end
            CrashSight.CollectInfo = function() return {} end
            CrashSight.ReportCrash = function() end
            CrashSight.ReportError = function() end
            CrashSight.ReportFatal = function() end
            CrashSight.ReportWarning = function() end
            CrashSight.ReportInfo = function() end
            CrashSight.ReportDebug = function() end
            CrashSight.ReportMemory = function() end
            CrashSight.ReportPerformance = function() end
        end

        _G.print = function() end
        _G.log = function() end
        _G.warn = function() end
        _G.error = function() end
    end)
end

-- ==================== السماء السوداء ====================
local function ApplyBlackSky(uPlayerController)
    pcall(function()
        if not slua.isValid(uPlayerController) then
            uPlayerController = GameplayData.GetPlayerController()
        end
        if not slua.isValid(uPlayerController) then return end
        if _G.SERO.black_sky then
            KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.CylinderMaxDrawHeight 9999")
        else
            KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.CylinderMaxDrawHeight 0")
        end
    end)
end

local function InitModMenuTab()
    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end

    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then return id end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")

    if not SettingPageDefine.SERO_VIP then
        SettingPageDefine.SERO_VIP = {
            Key = "SERO_VIP",
            loc = "SERO VIP MENU",
            UIKey = "Setting_Page_Privacy",
            Category = {
                {
                    Key = "Cat_ColorDetect",
                    loc = "قسم الكشف بالالوان",
                    Stack = {
                        { UI = AliasMap.Title, Text = "قسم الكشف بالالوان" },

                        -- كشف السيارات
                        {
                            Key = "SERO_CarDetect",
                            UI = AliasMap.TitleSwitcher,
                            Text = "كشف السيارات",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.car_detect end,
                            SetFunc = function(_, value) _G.SERO.car_detect = value; return true end
                        },
                        { Key = "SERO_CarGreen", UI = AliasMap.Switcher, Text = "لون سيارات اخضر",
                            ExpandHandle = "SERO_CarDetect",
                            GetFunc = function() return _G.SERO.car_green end,
                            SetFunc = function(_, value) clearCarColors(); _G.SERO.car_green = value; return true end },
                        { Key = "SERO_CarRed", UI = AliasMap.Switcher, Text = "لون سيارات احمر",
                            ExpandHandle = "SERO_CarDetect",
                            GetFunc = function() return _G.SERO.car_red end,
                            SetFunc = function(_, value) clearCarColors(); _G.SERO.car_red = value; return true end },
                        { Key = "SERO_CarYellow", UI = AliasMap.Switcher, Text = "لون سيارات اصفر",
                            ExpandHandle = "SERO_CarDetect",
                            GetFunc = function() return _G.SERO.car_yellow end,
                            SetFunc = function(_, value) clearCarColors(); _G.SERO.car_yellow = value; return true end },
                        { Key = "SERO_CarPurple", UI = AliasMap.Switcher, Text = "لون سيارات بنفسجي",
                            ExpandHandle = "SERO_CarDetect",
                            GetFunc = function() return _G.SERO.car_purple end,
                            SetFunc = function(_, value) clearCarColors(); _G.SERO.car_purple = value; return true end },

                        -- كشف اللاعبين
                        {
                            Key = "SERO_PlayerDetect",
                            UI = AliasMap.TitleSwitcher,
                            Text = "كشف اللاعبين",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.player_detect end,
                            SetFunc = function(_, value) _G.SERO.player_detect = value; return true end
                        },
                        { Key = "SERO_PlayerGreen", UI = AliasMap.Switcher, Text = "لون لاعب اخضر",
                            ExpandHandle = "SERO_PlayerDetect",
                            GetFunc = function() return _G.SERO.player_green end,
                            SetFunc = function(_, value) clearPlayerColors(); _G.SERO.player_green = value; return true end },
                        { Key = "SERO_PlayerYellow", UI = AliasMap.Switcher, Text = "لون لاعب اصفر",
                            ExpandHandle = "SERO_PlayerDetect",
                            GetFunc = function() return _G.SERO.player_yellow end,
                            SetFunc = function(_, value) clearPlayerColors(); _G.SERO.player_yellow = value; return true end },
                        { Key = "SERO_PlayerSky", UI = AliasMap.Switcher, Text = "لون لاعب سمائي",
                            ExpandHandle = "SERO_PlayerDetect",
                            GetFunc = function() return _G.SERO.player_sky end,
                            SetFunc = function(_, value) clearPlayerColors(); _G.SERO.player_sky = value; return true end },
                        { Key = "SERO_PlayerPurple", UI = AliasMap.Switcher, Text = "لون لاعب بنفسجي",
                            ExpandHandle = "SERO_PlayerDetect",
                            GetFunc = function() return _G.SERO.player_purple end,
                            SetFunc = function(_, value) clearPlayerColors(); _G.SERO.player_purple = value; return true end },
                        { Key = "SERO_PlayerOrange", UI = AliasMap.Switcher, Text = "لون لاعب برتقالي",
                            ExpandHandle = "SERO_PlayerDetect",
                            GetFunc = function() return _G.SERO.player_orange end,
                            SetFunc = function(_, value) clearPlayerColors(); _G.SERO.player_orange = value; return true end },

                        -- كشف البوتات
                        {
                            Key = "SERO_BotDetect",
                            UI = AliasMap.TitleSwitcher,
                            Text = "كشف البوتات",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.bot_detect end,
                            SetFunc = function(_, value) _G.SERO.bot_detect = value; return true end
                        },
                        { Key = "SERO_BotGreen", UI = AliasMap.Switcher, Text = "لون بوت اخضر",
                            ExpandHandle = "SERO_BotDetect",
                            GetFunc = function() return _G.SERO.bot_green end,
                            SetFunc = function(_, value) clearBotColors(); _G.SERO.bot_green = value; return true end },
                        { Key = "SERO_BotYellow", UI = AliasMap.Switcher, Text = "لون بوت اصفر",
                            ExpandHandle = "SERO_BotDetect",
                            GetFunc = function() return _G.SERO.bot_yellow end,
                            SetFunc = function(_, value) clearBotColors(); _G.SERO.bot_yellow = value; return true end },
                        { Key = "SERO_BotSky", UI = AliasMap.Switcher, Text = "لون بوت سمائي",
                            ExpandHandle = "SERO_BotDetect",
                            GetFunc = function() return _G.SERO.bot_sky end,
                            SetFunc = function(_, value) clearBotColors(); _G.SERO.bot_sky = value; return true end },
                        { Key = "SERO_BotPurple", UI = AliasMap.Switcher, Text = "لون بوت بنفسجي",
                            ExpandHandle = "SERO_BotDetect",
                            GetFunc = function() return _G.SERO.bot_purple end,
                            SetFunc = function(_, value) clearBotColors(); _G.SERO.bot_purple = value; return true end },
                        { Key = "SERO_BotOrange", UI = AliasMap.Switcher, Text = "لون بوت برتقالي",
                            ExpandHandle = "SERO_BotDetect",
                            GetFunc = function() return _G.SERO.bot_orange end,
                            SetFunc = function(_, value) clearBotColors(); _G.SERO.bot_orange = value; return true end },

                        -- كشف الاسلحة
                        {
                            Key = "SERO_WeaponDetect",
                            UI = AliasMap.TitleSwitcher,
                            Text = "كشف الاسلحة",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.weapon_detect end,
                            SetFunc = function(_, value) _G.SERO.weapon_detect = value; return true end
                        },
                        { Key = "SERO_WeaponRed", UI = AliasMap.Switcher, Text = "سلاح احمر",
                            ExpandHandle = "SERO_WeaponDetect",
                            GetFunc = function() return _G.SERO.weapon_red end,
                            SetFunc = function(_, value) clearWeaponColors(); _G.SERO.weapon_red = value; return true end },
                        { Key = "SERO_WeaponYellow", UI = AliasMap.Switcher, Text = "سلاح اصفر",
                            ExpandHandle = "SERO_WeaponDetect",
                            GetFunc = function() return _G.SERO.weapon_yellow end,
                            SetFunc = function(_, value) clearWeaponColors(); _G.SERO.weapon_yellow = value; return true end },
                        { Key = "SERO_WeaponGreen", UI = AliasMap.Switcher, Text = "سلاح اخضر",
                            ExpandHandle = "SERO_WeaponDetect",
                            GetFunc = function() return _G.SERO.weapon_green end,
                            SetFunc = function(_, value) clearWeaponColors(); _G.SERO.weapon_green = value; return true end },
                        { Key = "SERO_WeaponPurple", UI = AliasMap.Switcher, Text = "سلاح بنفسجي",
                            ExpandHandle = "SERO_WeaponDetect",
                            GetFunc = function() return _G.SERO.weapon_purple end,
                            SetFunc = function(_, value) clearWeaponColors(); _G.SERO.weapon_purple = value; return true end },
                        { Key = "SERO_WeaponBlue", UI = AliasMap.Switcher, Text = "سلاح ازرق",
                            ExpandHandle = "SERO_WeaponDetect",
                            GetFunc = function() return _G.SERO.weapon_blue end,
                            SetFunc = function(_, value) clearWeaponColors(); _G.SERO.weapon_blue = value; return true end },

                        -- تفعيلات الكشف العامة
                        { Key = "SERO_BoxESP", UI = AliasMap.Switcher, Text = "كشف المربع",
                            GetFunc = function() return _G.SERO.box_esp end,
                            SetFunc = function(_, value) _G.SERO.box_esp = value; return true end },
                        { Key = "SERO_ShowHealth", UI = AliasMap.Switcher, Text = "كشف الصحه",
                            GetFunc = function() return _G.SERO.show_health end,
                            SetFunc = function(_, value) _G.SERO.show_health = value; return true end },
                        { Key = "SERO_ShowName", UI = AliasMap.Switcher, Text = "كشف الاسم",
                            GetFunc = function() return _G.SERO.show_name end,
                            SetFunc = function(_, value) _G.SERO.show_name = value; return true end },
                        { Key = "SERO_MapMarker", UI = AliasMap.Switcher, Text = "ماركت الخريطة",
                            GetFunc = function() return _G.SERO.map_marker end,
                            SetFunc = function(_, value) _G.SERO.map_marker = value; return true end },
                        { Key = "SERO_Distance", UI = AliasMap.Switcher, Text = "كشف المسافه",
                            GetFunc = function() return _G.SERO.distance end,
                            SetFunc = function(_, value) _G.SERO.distance = value; return true end },
                        { Key = "SERO_ShowCounts", UI = AliasMap.Switcher, Text = "عداد اللاعبين والبوتات",
                            GetFunc = function() return _G.SERO.show_counts end,
                            SetFunc = function(_, value) _G.SERO.show_counts = value; return true end },
                        -- ── نظام الكشف الكامل ──
                        { UI = AliasMap.Title, Text = "نظام الكشف الكامل" },
                        { Key = "SERO_DetectFreeze",
                            UI = AliasMap.Switcher,
                            Text = "نظام الكشف الكامل",
                            GetFunc = function() return _G.SERO.detect_freeze end,
                            SetFunc = function(_, value)
                                local DETECT_KEYS = {
                                    "car_detect", "player_detect", "bot_detect", "weapon_detect",
                                    "box_esp", "show_health", "show_name",
                                    "map_marker", "distance", "show_counts",
                                }
                                if value then
                                    -- تشغيل النظام: استعادة الحالات المحفوظة
                                    if _G.SERO._saved_detect then
                                        for _, k in ipairs(DETECT_KEYS) do
                                            _G.SERO[k] = _G.SERO._saved_detect[k]
                                        end
                                        _G.SERO._saved_detect = nil
                                    end
                                    _G.SERO.detect_freeze = true
                                else
                                    -- إيقاف النظام: حفظ الحالات ثم إيقاف الكشف
                                    _G.SERO._saved_detect = {}
                                    for _, k in ipairs(DETECT_KEYS) do
                                        _G.SERO._saved_detect[k] = _G.SERO[k]
                                        _G.SERO[k] = false
                                    end
                                    _G.SERO.detect_freeze = false
                                end
                                return true
                            end },
                    }
                },
                {
                    Key = "Cat_HackMod",
                    loc = "التفعيلات",
                    Stack = {
                        -- ── ايم اسست ──
                        { UI = AliasMap.Title, Text = "ايم اسست" },
                        { Key = "SERO_AimAssist", UI = AliasMap.Switcher, Text = "ايم اسست",
                            GetFunc = function() return _G.SERO.aim_assist end,
                            SetFunc = function(_, value) _G.SERO.aim_assist = value; return true end },
                        { Key = "SERO_AimPower", UI = AliasMap.Slider, Text = "قوة الايم اسست",
                            GetFunc = function() return _G.SERO.aim_power end,
                            SetFunc = function(_, v) _G.SERO.aim_power = v; return true end,
                            Min = 0, Max = 100, Step = 5 },

                        -- ── هيدشوت ──
                        { UI = AliasMap.Title, Text = "هيدشوت" },
                        { Key = "SERO_Headshot", UI = AliasMap.Switcher, Text = "هيدشوت",
                            GetFunc = function() return _G.SERO.headshot end,
                            SetFunc = function(_, value) _G.SERO.headshot = value; return true end },
                        { Key = "SERO_HeadshotPower", UI = AliasMap.Slider, Text = "قوة الهيدشوت",
                            GetFunc = function() return _G.SERO.headshot_power end,
                            SetFunc = function(_, v) _G.SERO.headshot_power = math.max(0, math.min(100, v)); return true end,
                            Min = 0, Max = 100, Step = 5 },

                        -- ── ماجك بولت ──
                        {
                            Key = "SERO_MagicBullet",
                            UI = AliasMap.TitleSwitcher,
                            Text = "ماجك بولت",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.magic_bullet end,
                            SetFunc = function(_, value) _G.SERO.magic_bullet = value; return true end
                        },
                        { Key = "SERO_MagicHead", UI = AliasMap.Slider, Text = "   قوة ماجك الرأس",
                            ExpandHandle = "SERO_MagicBullet",
                            GetFunc = function() return _G.SERO.magic_head end,
                            SetFunc = function(_, v) _G.SERO.magic_head = v; return true end,
                            Min = 0, Max = 100, Step = 1 },
                        { Key = "SERO_MagicBody", UI = AliasMap.Slider, Text = "   قوة ماجك الجسم",
                            ExpandHandle = "SERO_MagicBullet",
                            GetFunc = function() return _G.SERO.magic_body end,
                            SetFunc = function(_, v) _G.SERO.magic_body = v; return true end,
                            Min = 0, Max = 100, Step = 1 },
                        { Key = "SERO_MagicLegs", UI = AliasMap.Slider, Text = "   قوة ماجك الأرجل",
                            ExpandHandle = "SERO_MagicBullet",
                            GetFunc = function() return _G.SERO.magic_legs end,
                            SetFunc = function(_, v) _G.SERO.magic_legs = v; return true end,
                            Min = 0, Max = 100, Step = 1 },

                        -- ── الاطارات ──
                        { UI = AliasMap.Title, Text = "الاطارات" },
                        { Key = "SERO_FPSLimit", UI = AliasMap.Slider, Text = "حد الإطارات (FPS)",
                            GetFunc = function() return _G.SERO.fps_limit end,
                            SetFunc = function(_, v)
                                _G.SERO.fps_limit = math.max(60, math.min(165, v))
                                pcall(function()
                                    local uCon = GameplayData.GetPlayerController()
                                    if slua.isValid(uCon) then
                                        KismetSystemLib.ExecuteConsoleCommand(uCon, "t.MaxFPS " .. _G.SERO.fps_limit)
                                    end
                                end)
                                return true
                            end,
                            Min = 60, Max = 165, Step = 5 },

                        -- ── منظور ايباد ──
                        {
                            Key = "SERO_IpadScope",
                            UI = AliasMap.TitleSwitcher,
                            Text = "منظور ايباد",
                            ExpandIndex = 0,
                            GetFunc = function() return _G.SERO.ipad_view end,
                            SetFunc = function(_, value) _G.SERO.ipad_view = value; return true end
                        },
                        { Key = "SERO_IpadFOV", UI = AliasMap.Slider, Text = "   درجة الرؤية",
                            ExpandHandle = "SERO_IpadScope",
                            GetFunc = function() return _G.SERO.ipad_fov end,
                            SetFunc = function(_, v) _G.SERO.ipad_fov = math.max(90, math.min(150, v)); return true end,
                            Min = 90, Max = 150, Step = 5 },

                        -- ── مؤثرات بصرية ──
                        { UI = AliasMap.Title, Text = "مؤثرات بصرية" },
                        { Key = "SERO_SmallCrosshair", UI = AliasMap.Switcher, Text = "تصغير المؤشر",
                            GetFunc = function() return _G.SERO.small_crosshair end,
                            SetFunc = function(_, value) _G.SERO.small_crosshair = value; return true end },
                        { Key = "SERO_BlackSky", UI = AliasMap.Switcher, Text = "السماء السوداء",
                            GetFunc = function() return _G.SERO.black_sky end,
                            SetFunc = function(_, value)
                                _G.SERO.black_sky = value
                                ApplyBlackSky()
                                return true
                            end },
                    }
                },
                {
                    Key = "Cat_Graphics",
                    loc = "الجرافيك",
                    Stack = {
                        { UI = AliasMap.Title, Text = "تفعيلات اخرى" },
                        { Key = "SERO_RemoveFog", UI = AliasMap.Switcher, Text = "ازالة الضباب",
                            GetFunc = function() return _G.SERO.remove_fog end,
                            SetFunc = function(_, value)
                                _G.SERO.remove_fog = value
                                local uCon = GameplayData.GetPlayerController()
                                if slua.isValid(uCon) then
                                    local cmd = value and "r.Fog 0" or "r.Fog 1"
                                    KismetSystemLib.ExecuteConsoleCommand(uCon, cmd)
                                end
                                return true
                            end },
                        { Key = "SERO_RemoveWater", UI = AliasMap.Switcher, Text = "ازالة الماء",
                            GetFunc = function() return _G.SERO.remove_water end,
                            SetFunc = function(_, value)
                                _G.SERO.remove_water = value
                                local uCon = GameplayData.GetPlayerController()
                                if slua.isValid(uCon) then
                                    if value then
                                        KismetSystemLib.ExecuteConsoleCommand(uCon, "r.Water.SingleLayer.Reflection 0")
                                        KismetSystemLib.ExecuteConsoleCommand(uCon, "r.Water 0")
                                    else
                                        KismetSystemLib.ExecuteConsoleCommand(uCon, "r.Water.SingleLayer.Reflection 1")
                                        KismetSystemLib.ExecuteConsoleCommand(uCon, "r.Water 1")
                                    end
                                end
                                return true
                            end },
                    }
                },
            }
        }

        table.insert(SettingCatalog, SettingPageDefine.SERO_VIP)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if catalog and (type(catalog) == "table" or type(catalog) == "userdata") then
                    local hasModMenu = false
                    local newCatalog = {}
                    for _, page in ipairs(catalog) do
                        table.insert(newCatalog, page)
                        if page.Key == "SERO_VIP" then hasModMenu = true end
                    end
                    if not hasModMenu then
                        table.insert(newCatalog, SettingPageDefine.SERO_VIP)
                        args[1] = newCatalog
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args))
        end
        UIManager._IsModMenuHooked = true
    end
end

InitModMenuTab()

local function SetFPSLimit()
    local fps = _G.SERO.fps_limit or 60
    pcall(function()
        local uCon = GameplayData.GetPlayerController()
        if slua.isValid(uCon) then
            KismetSystemLib.ExecuteConsoleCommand(uCon, "t.MaxFPS " .. fps)
        end
    end)
end

local function SetFOV(self)
    if not _G.SERO.ipad_view then return end
    local fov = _G.SERO.ipad_fov or 100
    local cam = self.ThirdPersonCameraComponent
    if cam then cam:SetFieldOfView(fov) end
    local fpsCam = self.FirstPersonCameraComponent
    if fpsCam then fpsCam:SetFieldOfView(fov) end
end

local EAvatarDamagePosition = import("EAvatarDamagePosition")

local function ApplyAutoAimHead(self)
    if not _G.SERO.headshot then return end
    local autoComp = self.AutoAimComp
    if not autoComp then return end
    local power = math.max(0, math.min(100, _G.SERO.headshot_power or 40))
    -- bOnlyHitHead يُفعَّل فقط عند قوة >= 25؛ أقل من ذلك مساعدة خفيفة فقط
    autoComp.bOnlyHitHead  = (power >= 25)
    autoComp.HeadBoneName  = "Head"
    autoComp.Bones         = {"Head","Head","Head","Head","Head"}
    autoComp.ChestBoneName  = (power < 25) and "spine_03" or ""
    autoComp.PelvisBoneName = (power < 25) and "pelvis"   or ""
    if autoComp.AimAssistConfig then
        autoComp.AimAssistConfig.HeadPriority   = math.floor(power * 0.7)        -- 0→0 .. 100→70
        autoComp.AimAssistConfig.ChestPriority  = math.floor(math.max(0, 20 - power * 0.2))
        autoComp.AimAssistConfig.PelvisPriority = 0
    end
end

function GetHitBodyType(ImpactResult, InImpactVec)
    -- يُجبر على الرأس فقط عند قوة >= 25
    if _G.SERO.headshot and (_G.SERO.headshot_power or 50) >= 25 then
        return EAvatarDamagePosition.BigHead
    end
    return nil
end

function GetHitBodyTypeByHitPos(InImpactVec)
    if _G.SERO.headshot and (_G.SERO.headshot_power or 50) >= 25 then
        return EAvatarDamagePosition.BigHead
    end
    return nil
end

local lastAimAssistTime = 0

local function ApplyAimAssist(self)
    if not _G.SERO.aim_assist then return end
    local now = os.clock()
    if now - lastAimAssistTime < 1.0 then return end
    lastAimAssistTime = now
    local weapon = self.WeaponManagerComponent
    if not weapon then return end
    local currentWeapon = weapon.CurrentWeaponReplicated
    if not currentWeapon then return end
    local entity = currentWeapon.ShootWeaponEntityComp
    if not slua.isValid(entity) or not entity.AutoAimingConfig then return end
    local power = math.max(0, math.min(100, _G.SERO.aim_power or 35)) / 100.0
    for _, rangeName in ipairs({"OuterRange", "InnerRange"}) do
        local cfg = entity.AutoAimingConfig[rangeName]
        if cfg then
            -- تدرّج حقيقي: عند 0 لا يوجد تأثير، عند 100 أقصى قوة
            cfg.Speed          = power * 8.0
            cfg.adsorbMaxRange = power * 1000.0
            cfg.adsorbMinRange = power * 1000.0
        end
    end
end

local BONE_GROUPS = {
    head = {"head"},
    body = {"neck_01", "pelvis", "spine_01", "spine_02", "spine_03", "upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r", "hand_l", "hand_r"},
    legs = {"thigh_l", "thigh_r", "calf_l", "calf_r", "foot_l", "foot_r"}
}

local function GetBoneGroupPercent(boneName)
    local name = string.lower(boneName)
    for group, bones in pairs(BONE_GROUPS) do
        for _, pattern in ipairs(bones) do
            if name:find(pattern) then
                return group
            end
        end
    end
    return nil
end

local magicTick = 0
local function ApplyMagicBullet(self)
    if not _G.SERO.magic_bullet then return end
    magicTick = magicTick + 1
    if magicTick % 20 ~= 0 then return end
    pcall(function()
        local mesh = self.Object.Mesh or self:getAvatarComponent2()
        if not slua.isValid(mesh) then return end
        local physAsset = mesh.PhysicsAssetOverride
        if not slua.isValid(physAsset) and mesh.SkeletalMesh then
            physAsset = mesh.SkeletalMesh.PhysicsAsset
        end
        if not slua.isValid(physAsset) or not physAsset.SkeletalBodySetups then return end
        local assetName = physAsset.GetName and physAsset:GetName() or tostring(physAsset)
        if _G.LNModScaledAssets and _G.LNModScaledAssets[assetName] then return end
        local bodySetups = physAsset.SkeletalBodySetups
        local headScale = 1.0 + (_G.SERO.magic_head or 0) / 100.0 * 1.5
        local bodyScale = 1.0 + (_G.SERO.magic_body or 0) / 100.0 * 1.5
        local legsScale = 1.0 + (_G.SERO.magic_legs or 0) / 100.0 * 1.5
        local scaledCount = 0
        for i = 1, 80 do
            local setup = nil
            pcall(function()
                if type(bodySetups.Get) == "function" then setup = bodySetups:Get(i-1) else setup = bodySetups[i] end
            end)
            if not setup or not slua.isValid(setup) then break end
            local boneName = tostring(setup.BoneName)
            local group = GetBoneGroupPercent(boneName)
            if group then
                local scale = 1.0
                if group == "head" then scale = headScale
                elseif group == "body" then scale = bodyScale
                elseif group == "legs" then scale = legsScale end
                if scale > 1.0 then
                    local aggGeom = setup.AggGeom
                    pcall(function()
                        local boxes = (aggGeom and aggGeom.BoxElems) or setup.BoxElems
                        if boxes then
                            local box = (type(boxes.Get) == "function") and boxes:Get(0) or boxes[1]
                            if box then
                                if box.X then box.X = box.X * scale end
                                if box.Y then box.Y = box.Y * scale end
                                if box.Z then box.Z = box.Z * scale end
                                if type(boxes.Set) == "function" then boxes:Set(0, box) else boxes[1] = box end
                                scaledCount = scaledCount + 1
                            end
                        end
                    end)
                    pcall(function()
                        local sphyls = (aggGeom and aggGeom.SphylElems) or setup.SphylElems
                        if sphyls then
                            local sphyl = (type(sphyls.Get) == "function") and sphyls:Get(0) or sphyls[1]
                            if sphyl then
                                if sphyl.Radius then sphyl.Radius = sphyl.Radius * scale end
                                if sphyl.Length then sphyl.Length = sphyl.Length * scale end
                                if type(sphyls.Set) == "function" then sphyls:Set(0, sphyl) else sphyls[1] = sphyl end
                                scaledCount = scaledCount + 1
                            end
                        end
                    end)
                end
            end
        end
        if scaledCount > 0 then
            _G.LNModScaledAssets = _G.LNModScaledAssets or {}
            _G.LNModScaledAssets[assetName] = true
            if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
        end
    end)
end

-- ✅ تم تعديل هذه الدالة لتتحقق من حالة المفتاح
local function ApplySmallCrosshair(self)
    if not _G.SERO.small_crosshair then
        return  -- لا تفعل شيئاً إذا كانت الميزة معطلة
    end
    pcall(function()
        local wm = self.Object and self.Object.WeaponManagerComponent
        if not wm then return end
        local weapon = wm.CurrentWeaponReplicated
        if not weapon then return end
        local entity = weapon.ShootWeaponEntityComp
        if not slua.isValid(entity) then return end
        entity.GameDeviationFactor = 0.15
    end)
end

local PlayerModule = {}

function PlayerModule:ctor()
    self.ActiveForceMark = nil
    self.LastMarkUpdate = 0
    self._nFrameUIRefreshTimerID = nil
    self._AssistTimer = nil
end

function PlayerModule:postConstruct()
    CharacterBase._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
end

-- ===== دالة بدء الحماية المتكررة (عشوائية 10-15 ثانية) =====
function PlayerModule:StartPeriodicProtection()
    -- تشغيل الحماية فوراً
    pcall(CompleteAntiBanSystem)

    -- دالة جدولة التكرار
    local function schedule()
        if not slua.isValid(self.Object) then
            return
        end
        local delay = math.random(5, 10) -- اختيار عشوائي بين 5 و 10 ثوانٍ
        self:AddGameTimer(delay, false, function()
            pcall(CompleteAntiBanSystem)
            schedule() -- إعادة الجدولة
        end)
    end

    schedule()
end

function PlayerModule:receiveBeginPlay()
    CharacterBase.ReceiveBeginPlay(self)
    self:SetActorTickEnabled(true)
    EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)

    if IsExpired() then
        ShowExp()
    else
        if not _G.MatchLegalShown then
            _G.MatchLegalShown = true
            pcall(function()
                local now_ts = os.time()
                local remaining = math.max(0, MOD_EXPIRY_TS - now_ts)
                local days    = math.floor(remaining / 86400)
                local hours   = math.floor((remaining % 86400) / 3600)
                local minutes = math.floor((remaining % 3600) / 60)
                local timeLine = string.format("الوقت المتبقي (%d يوم) (و %d ساعات) و %d دقيقة", days, hours, minutes)
                LegalMsg.ShowOnePopUI({
                    tabType = 999,
                    title = "تنبيه مهم من سيرو",
                    content = "اهلا بك عزيزي انت مشترك بالمدفوع\n\n" .. timeLine,
                    btnOKText = "شكراً",
                    acceptFunc = function()
                        pcall(function()
                            local t1 = "نصيحة 1: لا تفعل جميع المميزات دفعة واحدة"
                            local t2 = "نصيحة 2: استخدم الايم اسست بقوة معتدلة 50-60"
                            local t3 = "نصيحة 3: لا تفعل ماجك بولت واذا مصر على تفعيله يفضل 20% وأقل"
                            local t4 = "نصيحة 4: استخدم الهيدشوت بنسبة 20% - 40%"
                            local t5 = "نصيحة 5: لا تقتل اكثر من 15"
                            local sep = "\n\n"
                            local tips = t1 .. sep .. t2 .. sep .. t3 .. sep .. t4 .. sep .. t5
                            LegalMsg.ShowOnePopUI({
                                tabType = 999,
                                title = "نصائح مهمة",
                                content = tips,
                                btnOKText = "حسناً",
                                acceptFunc = function() end,
                            })
                        end)
                    end,
                })
            end)
        end
    end

    SetFPSLimit()
    SetupMapMarkConfig()
    self:_StartFrameUIRefreshTimer()
    self:InitVisualAssistance()
    self:RemoveGraphics()
    if not self.AutoAimComp then
        self.AutoAimComp = self:GetComponentByClass(import("AutoAimComponent"))
    end

    -- بدء الحماية المتكررة (10-15 ثانية عشوائياً)
    self:StartPeriodicProtection()
end

function PlayerModule:receiveTick(ds)
    if IsExpired() then ShowExp(); return end
    if _G.SERO.ipad_view    then SetFOV(self)            end
    if _G.SERO.headshot      then ApplyAutoAimHead(self)  end
    if _G.SERO.aim_assist    then ApplyAimAssist(self)    end
    if _G.SERO.magic_bullet  then ApplyMagicBullet(self)  end
    ApplySmallCrosshair(self)   -- الدالة تتحقق من الحالة بنفسها
end

function PlayerModule:receiveEndPlay(reason)
    if self._nFrameUIRefreshTimerID then
        self:RemoveGameTimer(self._nFrameUIRefreshTimerID)
        self._nFrameUIRefreshTimerID = nil
    end
    if self._AssistTimer then
        self:RemoveGameTimer(self._AssistTimer)
        self._AssistTimer = nil
        if SharedVisualAssistOwner == self then SharedVisualAssistOwner = nil end
    end
    if self.ActiveForceMark and InGameMarkTools then
        InGameMarkTools.HideMapMark(self.ActiveForceMark)
        self.ActiveForceMark = nil
    end
    CharacterBase.ReceiveEndPlay(self, reason)
end

function PlayerModule:RemoveGraphics()
    if self.bGraphicsRemoved then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.Atmosphere 0")
    KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.LightShafts 0")
    if _G.SERO.remove_fog then
        KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.Fog 0")
    end
    if _G.SERO.remove_water then
        KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.Water.SingleLayer.Reflection 0")
        KismetSystemLib.ExecuteConsoleCommand(uPlayerController, "r.Water 0")
    end
    ApplyBlackSky(uPlayerController)
    self.bGraphicsRemoved = true
end

function PlayerModule:_StartFrameUIRefreshTimer()
    if self._nFrameUIRefreshTimerID then return end

    self._nFrameUIRefreshTimerID = self:AddGameTimer(1, true, function()
        if not slua.isValid(self.Object) then return end

        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end

        local localLocation = localPlayer:K2_GetActorLocation()
        local allPlayers = Game:GetAllPlayerPawns()

        for _, playerChar in pairs(allPlayers) do
            if slua.isValid(playerChar)
                and playerChar.Replay_CreateEnemyFrameUI
                and playerChar.Replay_SetVisiableOfFrameUI
                and playerChar.Replay_IsEnemyFrameUIExisted
                and SecurityCommonUtils.IsHealthStatusAlive(playerChar.HealthStatus) then

                local shouldShow = true

                if playerChar.TeamID == localPlayer.TeamID then
                    shouldShow = false
                end

                local charLocation = playerChar:K2_GetActorLocation()
                if charLocation.Z >= 150000 then
                    shouldShow = false
                end

                if FVector.Dist2D(localLocation, charLocation) > 100000 then
                    shouldShow = false
                end

                if shouldShow then
                    if not playerChar:Replay_IsEnemyFrameUIExisted() then
                        playerChar:Replay_CreateEnemyFrameUI(true, true)
                    end
                    playerChar:Replay_SetVisiableOfFrameUI(true)
                else
                    playerChar:Replay_SetVisiableOfFrameUI(false)
                end
            end
        end

    end)
end

function PlayerModule:InitVisualAssistance()
    if not Client or self._AssistTimer or (SharedVisualAssistOwner and SharedVisualAssistOwner ~= self) then return end

    SharedVisualAssistOwner = self
    local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
    local cachedMarks, cachedMapMarks, cachedPawns, lastPawnRefresh = {}, {}, {}, 0
    local botCache = {}  -- {[pawn] = true/false} يُبنى مرة واحدة عند تحديث القائمة
    local now_time = os.time()
    local _timerTick = 0  -- عداد للـ tick لتقليل عمليات os.time المكثفة

    self._AssistTimer = self:AddGameTimer(0.1, true, function()
        _timerTick = _timerTick + 1

        -- تحديث الوقت الحالي كل ثانية (كل 10 ticks × 0.1s = 1s)
        if _timerTick % 10 == 0 then
            now_time = os.time()
            -- تحديث الـ Countdown Widget كل ثانية
            pcall(_M_UpdateMenuCountdown)
        end

        -- تحديث هيو الألوان القزحية (كل 0.1 ثانية → دورة كاملة كل 10 ثوانٍ، انتقال سلس)
        _G.SERO.rgb_hue = (_G.SERO.rgb_hue + 3.6) % 360
        -- تحديث لون السلاح في نفس المؤقت لضمان سلاسة RGB
        ApplyWeaponColor()

        if now_time > MOD_EXPIRY_TS then ShowExp(); return end

        if not slua.isValid(self.Object) then
            for _, markId in pairs(cachedMarks) do
                if type(markId) ~= "table" and markId then InGameMarkTools.HideMapMark(markId) end
            end
            for _, markId in pairs(cachedMapMarks) do
                if markId then InGameMarkTools.HideMapMark(markId) end
            end
            cachedMarks, cachedMapMarks, SharedVisualAssistOwner = {}, {}, nil
            return
        end

        local uCon = slua_GameFrontendHUD:GetPlayerController()
        if not (slua.isValid(uCon) and Game:IsClassOf(uCon, ASTExtraPlayerController)) then return end

        local currentPawn = uCon:GetCurPawn()
        if not slua.isValid(currentPawn) then return end

        local myTeamId, myPos = currentPawn.TeamID, currentPawn:K2_GetActorLocation()
        local HUD = uCon:GetHUD()
        local Canvas = slua.isValid(HUD) and HUD.Canvas or nil
        local now = os.clock()

        if slua.isValid(HUD) and slua.isValid(currentPawn) then
            -- احسب عدد الأعداء دائماً (بغض النظر عن show_counts)
            local botCount, playerCount = 0, 0
            for _, tPawn in pairs(cachedPawns) do
                if slua.isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId and IsPawnAlive(tPawn) then
                    -- يستخدم botCache بدل Game:IsAI() المتكرر
                    if botCache[tPawn] then botCount = botCount + 1 else playerCount = playerCount + 1 end
                end
            end

            local hasEnemies = (botCount > 0) or (playerCount > 0)

            pcall(function()
                -- نص الحقوق وانتهاء الصلاحية: يظهر فقط عند عدم وجود أعداء (هدوء)
                if not hasEnemies then
                    local remaining = math.max(0, MOD_EXPIRY_TS - now_time)
                    local hours   = math.floor(remaining / 3600)
                    local minutes = math.floor((remaining % 3600) / 60)
                    local seconds = remaining % 60
                    local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                    HUD:AddDebugText("SERO @urrzv", currentPawn, 1.2, {X=0,Y=0,Z=185}, {X=0,Y=0,Z=185}, {R=0,G=255,B=0,A=255}, true, false, true, nil, 1, true)
                    HUD:AddDebugText("EXPIRED IN : " .. timeStr, currentPawn, 1.2, {X=0,Y=0,Z=165}, {X=0,Y=0,Z=165}, {R=255,G=255,B=0,A=255}, true, false, true, nil, 1, true)
                end

                -- عدادات الأعداء والبوتات (تظهر فقط عند وجود أعداء)
                if _G.SERO.show_counts and hasEnemies then
                    local enemyText  = string.format("ENEMY: %d", playerCount)
                    local enemyColor = {R=255,G=0,B=0,A=255}
                    HUD:AddDebugText(enemyText, currentPawn, 0.11, {X=0,Y=0,Z=145}, {X=0,Y=0,Z=145}, enemyColor, true, false, true, nil, 1.3, true)
                    local botText  = string.format("BOT: %d", botCount)
                    local botColor = {R=255,G=0,B=0,A=255}
                    HUD:AddDebugText(botText, currentPawn, 0.11, {X=0,Y=0,Z=125}, {X=0,Y=0,Z=125}, botColor, true, false, true, nil, 1.3, true)
                end
            end)
        end

        if now - lastPawnRefresh > 1.0 then
            lastPawnRefresh = now
            now_time        = os.time()
            cachedPawns     = Game:GetAllPlayerPawns() or {}
            -- بناء botCache: يُحسب Game:IsAI() مرة واحدة لكل pawn عند التحديث فقط
            botCache = {}
            for _, p in pairs(cachedPawns) do
                local isB = false
                pcall(function() isB = Game:IsAI(p) end)
                botCache[p] = isB
            end
            local pawnSet   = {}
            for _, p in pairs(cachedPawns) do pawnSet[p] = true end
            for pawnPtr, markId in pairs(cachedMarks) do
                if pawnPtr ~= "_time" and not pawnSet[pawnPtr] then
                    if markId then InGameMarkTools.HideMapMark(markId) end
                    cachedMarks[pawnPtr] = nil
                end
            end
            for pawnPtr, markId in pairs(cachedMapMarks) do
                if not pawnSet[pawnPtr] then
                    if markId then InGameMarkTools.HideMapMark(markId) end
                    cachedMapMarks[pawnPtr] = nil
                end
            end
        end

        if _G.SERO.car_detect then
            local activeCarColor = nil
            if HasActiveCarColor() then
                for key, color in pairs(CAR_COLOR_MAP) do
                    if _G.SERO[key] then activeCarColor = color; break end
                end
            else
                activeCarColor = GetRGBColor()
            end
            local allVehicles = Game:GetAllVehicles() or {}
            for _, vehicle in pairs(allVehicles) do
                if slua.isValid(vehicle) then
                    if activeCarColor then
                        ApplyActorWallhack(vehicle, activeCarColor, 3.0)
                    end
                    if _G.SERO.distance and slua.isValid(HUD) then
                        local vehPos = vehicle:K2_GetActorLocation()
                        local dist = FVector.Dist(myPos, vehPos)
                        local distM = math.floor(dist / 100)
                        if distM > 70 then
                            HUD:AddDebugText("CAR: " .. distM .. "m", vehicle, 0.85,
                                {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100},
                                {R=255, G=255, B=0, A=255},
                                true, false, true, nil, 1.0, true)
                        end
                    end
                end
            end
        end

        local behindColor    = _G.SERO.player_detect and GetActivePlayerBehindColor() or nil
        local botBehindColor = _G.SERO.bot_detect    and GetActiveBotColor()           or nil
        for _, tPawn in pairs(cachedPawns) do
            if slua.isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
                if IsPawnAlive(tPawn) then
                    local enemyPos = tPawn:K2_GetActorLocation()
                    local dx, dy, dz = enemyPos.X - myPos.X, enemyPos.Y - myPos.Y, enemyPos.Z - myPos.Z
                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                    if dist < 100000 then
                        -- isBot من الـ cache (لا استدعاء إضافي لـ Game:IsAI)
                        local isBot = botCache[tPawn] or false

                        -- الاسم يظهر للاعبين البشريين فقط (البوتات أسماؤها غير مفيدة)
                        if tPawn.SetPlayerNameVisible then
                            tPawn:SetPlayerNameVisible(_G.SERO.show_name == true and not isBot)
                        end

                        local headPos, rootPos
                        -- dist < 100000 دائماً هنا؛ نستخدم fallback فقط فوق 50000 وحدة (500 متر)
                        if dist > 50000 then
                            headPos, rootPos = enemyPos + VEC_Z85, enemyPos - VEC_Z85
                        else
                            local realHead = tPawn:GetHeadLocation(false)
                            headPos = realHead or (enemyPos + VEC_Z85)
                            rootPos = realHead and (enemyPos - VEC_Z90) or (enemyPos - VEC_Z85)
                        end

                        cachedMarks._time = cachedMarks._time or {}
                        if now - (cachedMarks._time[tPawn] or 0) > 1.5 then
                            cachedMarks._time[tPawn] = now
                            if cachedMarks[tPawn] then
                                InGameMarkTools.UpdateMapMarkLocation(cachedMarks[tPawn], headPos)
                            else
                                cachedMarks[tPawn] = InGameMarkTools.ClientAddMapMark(1006, headPos, 0, "", 4, tPawn)
                            end
                        end

                        -- ماركت الخريطة (type 9999)
                        pcall(function()
                            if _G.SERO.map_marker then
                                if not cachedMapMarks[tPawn] then
                                    cachedMapMarks[tPawn] = InGameMarkTools.ClientAddMapMark(9999, VEC_ZERO, 0, "", 4, tPawn)
                                end
                            else
                                if cachedMapMarks[tPawn] then
                                    InGameMarkTools.HideMapMark(cachedMapMarks[tPawn])
                                    cachedMapMarks[tPawn] = nil
                                end
                            end
                        end)

                        if _G.SERO.box_esp and isBot and Canvas then
                            local headScreen, rootScreen = FVector2D(0,0), FVector2D(0,0)
                            if uCon:ProjectWorldLocationToScreen(headPos, false, headScreen) and
                               uCon:ProjectWorldLocationToScreen(rootPos, false, rootScreen) then
                                local screenHeight = math.abs(headScreen.Y - rootScreen.Y)
                                local boxWidth = screenHeight * 0.5
                                local topLeft = FVector2D(headScreen.X - boxWidth/2, headScreen.Y)
                                local bottomRight = FVector2D(headScreen.X + boxWidth/2, rootScreen.Y)
                                Canvas:K2_DrawLine(topLeft, FVector2D(bottomRight.X, topLeft.Y), 2, COLOR_YELLOW_LINE)
                                Canvas:K2_DrawLine(FVector2D(topLeft.X, bottomRight.Y), bottomRight, 2, COLOR_YELLOW_LINE)
                                Canvas:K2_DrawLine(topLeft, FVector2D(topLeft.X, bottomRight.Y), 2, COLOR_YELLOW_LINE)
                                Canvas:K2_DrawLine(FVector2D(bottomRight.X, topLeft.Y), bottomRight, 2, COLOR_YELLOW_LINE)
                            end
                        end

                        -- شريط الصحة يظهر للجميع (بوتات ولاعبين)
                        if _G.SERO.box_esp and _G.SERO.show_health and Canvas then
                            local headScreen, rootScreen = FVector2D(0,0), FVector2D(0,0)
                            if uCon:ProjectWorldLocationToScreen(headPos, false, headScreen) and
                               uCon:ProjectWorldLocationToScreen(rootPos, false, rootScreen) then
                                local screenHeight = math.max(25, math.abs(headScreen.Y - rootScreen.Y))
                                local scaleFactor = math.max(0.3, math.min(1.5, 15000 / math.max(10000, dist)))
                                local barWidth, barHeight = 4 * scaleFactor, screenHeight * scaleFactor
                                local barX, barY = headScreen.X - (barWidth * 1.5), headScreen.Y
                                local hp = GetPawnHealthRatio(tPawn)
                                local color = hp < 0.3 and COLOR_HP_RED or (hp < 0.6 and COLOR_HP_YELLOW or COLOR_HP_GREEN)
                                Canvas:K2_DrawBox(FVector2D(barX, barY), FVector2D(barWidth, barHeight), 1, COLOR_BG)
                                Canvas:K2_DrawBox(FVector2D(barX, barY + barHeight * (1 - hp)), FVector2D(barWidth, barHeight * hp), 1, color)
                            end
                        end

                        if _G.SERO.distance and slua.isValid(HUD) then
                            pcall(function()
                                local distMeters = math.floor(dist / 100)
                                if distMeters > 30 then
                                    HUD:AddDebugText(
                                        string.format("%dm", distMeters),
                                        tPawn, 0.85,
                                        {X=0, Y=0, Z=125}, {X=0, Y=0, Z=125},
                                        {R=255, G=255, B=255, A=255},
                                        true, false, true, nil, 0.95, true
                                    )
                                end
                            end)
                        end

                        -- wallhack مستقل: player_detect للاعبين، bot_detect للبوتات
                        local wh = isBot and botBehindColor or behindColor
                        if wh then
                            ApplyWallhack(tPawn, uCon, wh)
                        end
                    end
                else
                    if cachedMarks[tPawn] then
                        InGameMarkTools.HideMapMark(cachedMarks[tPawn])
                        cachedMarks[tPawn] = nil
                    end
                    if cachedMapMarks[tPawn] then
                        InGameMarkTools.HideMapMark(cachedMapMarks[tPawn])
                        cachedMapMarks[tPawn] = nil
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- WATERMARK PERMANEN "@FUFUMOD"  RAINBOW RGB
-- ==========================================
local function GetRainbowLinearColor()
    local time = os.clock()
    local r = math.sin(time * 0.8) * 0.5 + 0.5
    local g = math.sin(time * 0.8 + 2.094) * 0.5 + 0.5
    local b = math.sin(time * 0.8 + 4.188) * 0.5 + 0.5
    return FLinearColor(r, g, b, 1.0)
end

pcall(function()
    local IPS = require("GameLua.Mod.Library.Client.UI.IngamePhoneStateUI")
    if IPS and IPS.__inner_impl then
        local o = IPS.__inner_impl.UpdateArtQualityUI
        IPS.__inner_impl.UpdateArtQualityUI = function(self, _, _)
            if self.UIRoot and self.UIRoot.TextBlock_quality then
                self.UIRoot.TextBlock_quality:SetText("SERO")
                local color = GetRainbowLinearColor()
                self.UIRoot.TextBlock_quality:SetColorAndOpacity(FSlateColor(color))
            end
        end
    end
end)
-- ==========================================

local RPCDefinitions = {
    ServerRPC = {
        ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} },
        ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } },
        RPC_Server_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
    },
    MulticastRPC = {
        MulticastRPC_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
    },
    ClientRPC = {
        RPC_Client_SetShouldCheckPassWall = { Reliable = true, Params = { UEnums.EPropertyClass.Bool } }
    }
}

_G.ServerRPC = RPCDefinitions.ServerRPC
_G.ClientRPC = RPCDefinitions.ClientRPC
_G.MulticastRPC = RPCDefinitions.MulticastRPC

local BRPlayerCharacterBase = Class(CharacterBase, nil, {
    ServerRPC = RPCDefinitions.ServerRPC,
    ClientRPC = RPCDefinitions.ClientRPC,
    MulticastRPC = RPCDefinitions.MulticastRPC,
    ctor = PlayerModule.ctor,
    _PostConstruct = PlayerModule.postConstruct,
    ReceiveBeginPlay = PlayerModule.receiveBeginPlay,
    ReceiveEndPlay = PlayerModule.receiveEndPlay,
    ReceiveTick = PlayerModule.receiveTick,
    RemoveGraphics = PlayerModule.RemoveGraphics,
    _StartFrameUIRefreshTimer = PlayerModule._StartFrameUIRefreshTimer,
    InitVisualAssistance = PlayerModule.InitVisualAssistance,
    GetHitBodyType = GetHitBodyType,
    GetHitBodyTypeByHitPos = GetHitBodyTypeByHitPos,
    StartPeriodicProtection = PlayerModule.StartPeriodicProtection,
})

return CombineClass.DeclareFeature(BRPlayerCharacterBase, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" }
}, "BRPlayerCharacterBase")