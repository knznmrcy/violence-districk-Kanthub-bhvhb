-- ==============================================
--     BLUEHAVEN HUB - FIXED
-- ==============================================
-- Original note: SEMENTARA NO LIBRARY (KANTZY)
-- Original note: GABISA DI LOAD PUNG GAUSAH MALING

-- UI dependencies (Obsidian; compatible with this Linoria-style API)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
-- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local Workspace      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting       = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats          = game:GetService("Stats")
local TweenService   = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera



-- ============== HUB RUNTIME / CLEAN UNLOAD ==============
local HubRuntime = {
    Alive = true,
    Unloading = false,
    Connections = {},
    Artifacts = {},
    TrackTicks = 0,
}

local function PruneRuntimeRefs()
    for conn in pairs(HubRuntime.Connections) do
        local ok, connected = pcall(function() return conn.Connected end)
        if ok and connected == false then HubRuntime.Connections[conn] = nil end
    end
    for obj in pairs(HubRuntime.Artifacts) do
        local alive = false
        pcall(function() alive = obj.Parent ~= nil end)
        if not alive then HubRuntime.Artifacts[obj] = nil end
    end
end

local function TrackConnection(conn)
    if conn then
        HubRuntime.Connections[conn] = true
        HubRuntime.TrackTicks = HubRuntime.TrackTicks + 1
        if HubRuntime.TrackTicks % 48 == 0 then PruneRuntimeRefs() end
    end
    return conn
end

local function ForgetConnection(conn)
    if conn then HubRuntime.Connections[conn] = nil end
end

local function TrackArtifact(obj)
    if obj then
        HubRuntime.Artifacts[obj] = true
        HubRuntime.TrackTicks = HubRuntime.TrackTicks + 1
        if HubRuntime.TrackTicks % 48 == 0 then PruneRuntimeRefs() end
    end
    return obj
end

local function ForgetArtifact(obj)
    if obj then HubRuntime.Artifacts[obj] = nil end
end

local function DestroyArtifact(obj)
    if not obj then return end
    ForgetArtifact(obj)
    pcall(function()
        if obj.Parent then obj:Destroy() end
    end)
end

local function DisconnectTrackedConnections()
    for conn in pairs(HubRuntime.Connections) do
        pcall(function() conn:Disconnect() end)
        HubRuntime.Connections[conn] = nil
    end
end

local function DestroyTrackedArtifacts()
    for obj in pairs(HubRuntime.Artifacts) do
        pcall(function()
            if obj.Parent then obj:Destroy() end
        end)
        HubRuntime.Artifacts[obj] = nil
    end
end

local OriginalCamera = {
    MinZoom = LocalPlayer.CameraMinZoomDistance,
    MaxZoom = LocalPlayer.CameraMaxZoomDistance,
    Mode = LocalPlayer.CameraMode,
    Type = Camera.CameraType,
    FOV = Camera.FieldOfView
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackEvent = Remotes:WaitForChild("Attacks"):WaitForChild("BasicAttack")
local SkillCheckRemote = Remotes:WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
local ToFItems = Remotes:FindFirstChild("Items")
local ToFFolder = ToFItems and ToFItems:FindFirstChild("Twist of Fate")
local ToFFireRemote = ToFFolder and ToFFolder:FindFirstChild("Fire")
local FlashlightFolder = ToFItems and ToFItems:FindFirstChild("Flashlight")
local GotBlindedRemote = FlashlightFolder and FlashlightFolder:FindFirstChild("GotBlinded")

-- ============== NEW: HIDE NAME SYSTEM ==============
local HideName = {
    Enabled = false,
    Keybind = Enum.KeyCode.F3,
    Connection = nil
}

-- ============== NEW: SILENT AIM (Improved) ==============
local SilentAim = {
    Enabled = false,
    FOV = 200,
    Distance = 400,
    TargetPart = "HumanoidRootPart",
    Prediction = true,
    PredictStrength = 0.15,
    BulletSpeed = 800,
    TargetMode = "Killer",
    WallCheck = true
}
local silentHookActive = false
local silentOriginalCast = nil

-- ============== CONFIG =================
local ESP = {
    Survivor  = false,
    Killer    = false,
    Generator = false,
    Pallet    = false,
    Window    = false,
    SCP       = false,
    Distance  = 500
}

local ESPStatus = {
    ShowName     = false,
    ShowDistance = false,
    ShowHealth   = false,
    ShowItem     = false,
    Radius       = 500
}

local TeleportIndex = {
    Generator = 1,
    Hook = 1,
    Gate = 1,
    Pallet = 1,
    Window = 1
}

local ESPItems = {
    ["Twist of Fate"]   = true,
    ["Bandage"]         = true,
    ["Motion Tracker"]  = true,
    ["Gate"]            = true,
    ["Shadow Clone"]    = true,
    ["Parrying Dagger"] = true
}

local TeamColors = {
    Killer   = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 120)
}

local StatusDownColor = Color3.fromRGB(255, 80, 80)
local StatusColors = {
    Name     = Color3.fromRGB(255, 255, 255),
    Distance = Color3.fromRGB(90, 210, 255),
    Health   = Color3.fromRGB(100, 255, 130),
    Item     = Color3.fromRGB(255, 215, 90),
}

local Auto = {
    SkillCheck       = false,
    SkillCheckMode   = "Legit",
    Parry            = false,
    ParryDelay       = 0,
    ParryCooldown    = 1,
    ParryDistance    = 15,
    FaceSensitivity  = 0.7,
    RequireFacing    = true,
    PalletDrop       = false,
    PalletDropDist   = 6
}

local GenBypass = {
    Enabled     = false,
    Button      = nil,
    UI          = nil,
    Cache       = {},
    CacheTimer  = 0,
    Processed   = {},
    HotkeyCode  = Enum.KeyCode.G,
}

-- ============== GEN BYPASS SYSTEM ==============

function GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return GenBypass.Cache end
    pcall(function()
        for _, v in pairs(mapFolder:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local isReal = v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil
                or v:GetAttribute("ProgressRepair") ~= nil
            if isReal then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function GB_GetPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                table.insert(points, obj)
            end
        end
    end)
    return points
end

function GB_WaitRepairing(point, timeout)
    local start = tick()
    while tick() - start < (timeout or 1) do
        if point:GetAttribute("IsRepairing") == true then return true end
        task.wait(0.05)
    end
    return false
end

function GB_DoRepair(targetPoint)
    local genModel = targetPoint.Parent
    if GenBypass.Processed[genModel] then return end
    GenBypass.Processed[genModel] = true

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then GenBypass.Processed[genModel] = nil return end

    local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")

    if not RepairEvent then 
        GenBypass.Processed[genModel] = nil 
        return 
    end

    local originalCFrame = hrp.CFrame
    pcall(function()
        for _, point in pairs(GB_GetPoints(genModel)) do
            if not HubRuntime.Alive or not GenBypass.Enabled then break end
            if point ~= targetPoint and point.Parent then
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                pcall(function() RepairEvent:FireServer(point, true) end)
                if not GB_WaitRepairing(point, 0.8) then
                    pcall(function() RepairEvent:FireServer(point, false) end)
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    pcall(function() RepairEvent:FireServer(point, true) end)
                    GB_WaitRepairing(point, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        if hrp and hrp.Parent then
            hrp.Anchored = false
            hrp.CFrame = originalCFrame
        end
    end)
    task.wait(0.1)
    pcall(function() RepairEvent:FireServer(targetPoint, false) end)
    GenBypass.Processed[genModel] = nil
end

function GB_GetNearestPoint()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestPoint, bestDist = nil, math.huge
    for _, gen in pairs(GB_GetAllGenerators()) do
        for _, point in pairs(GB_GetPoints(gen)) do
            local d = (hrp.Position - point.Position).Magnitude
            if d < bestDist then bestDist = d; bestPoint = point end
        end
    end
    return bestPoint, bestDist
end

function GB_UpdateButton()
    if GenBypass.Button then
        GenBypass.Button.Visible = GenBypass.Enabled and UserInputService.TouchEnabled
    end
end

function GB_CreateButton()
    local oldUI = PlayerGui:FindFirstChild("BypassGenUI")
    if oldUI then oldUI:Destroy() end

    GenBypass.UI = TrackArtifact(Instance.new("ScreenGui"))
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = PlayerGui

    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0, 60, 0, 60)
    GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GenBypass.Button.BackgroundTransparency = 0.15
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = GenBypass.Button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = GenBypass.Button
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "BYPASS"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11
    lbl.Parent = GenBypass.Button

    TrackConnection(GenBypass.Button.MouseButton1Click:Connect(function()
        if not HubRuntime.Alive or not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then
            GB_DoRepair(bestPoint)
        end
    end))
end

-- Inisialisasi button
GB_CreateButton()

-- Recreate button saat karakter respawn
TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
    if not HubRuntime.Alive then return end
    task.wait(0.5)
    if not HubRuntime.Alive then return end
    GB_CreateButton()
    GB_UpdateButton()
end))

function setGenBypass(v)
    GenBypass.Enabled = v
    GB_UpdateButton()
end

local GenBoostConfig = {
    Enabled = false,
    LastBroadcast = 0
}


local FakeTag = {
    Enabled = false,
    Text = "[BLUEHAVEN]",
    Color = "#00BFFF"
}
local FakeParry = {
    Enabled   = false,
    Animation = "Enten",
    Keybind   = Enum.KeyCode.V
}

local FakeParryAnimations = {
    Enten     = "rbxassetid://127096285501517",
    Stopwatch = "rbxassetid://81793464499285",
    Fih       = "rbxassetid://123307242865945",
    BloodShield = "rbxassetid://75939529748815"
}

local AutoFlee = {
    Enabled        = false,
    DetectDistance = 50,
    Cooldown       = 0.1
}

local GunAim = {
    Enabled         = false,
    Holding         = false,
    TargetMode      = "Killer",
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    Target          = nil,
    AimPart         = "HumanoidRootPart"
}

local ToFAimConfig = {
    Enabled = false,
    TargetMode = "Killer",
    AimPart = "HumanoidRootPart",
    Predict = true,
    BulletSpeed = 200,
    Range = 90,
    DotThreshold = 0.5
}


-- ============== EXPERIMENTAL LIGHTWEIGHT TOOL AIM ASSIST ==============
-- Event-based: hanya mencari target saat Tool.Activated, tidak scan tiap frame.
local ToolAimAssist = {
    Enabled = false,
    Tracer = true,
    Prediction = true,
    WallCheck = true,
    UseFOV = true,
    FOVColor = Color3.fromRGB(255, 170, 0),
    Range = 180,
    FOV = 110,
    BulletSpeed = 200,
    PredictionScale = 1.0,
    TargetMode = "Killer",
    TargetPart = "HumanoidRootPart",
    ToolConnections = setmetatable({}, {__mode = "k"}),
    CharacterConn = nil,
    BackpackConn = nil,
    TracerPart = nil,
    LastTarget = nil,
}

local AimFOVVisual = {
    Gui = nil,
    Circle = nil,
    Stroke = nil,
}

local function ensureAimFOVVisual()
    if AimFOVVisual.Gui and AimFOVVisual.Gui.Parent
        and AimFOVVisual.Circle and AimFOVVisual.Circle.Parent then
        return
    end

    if AimFOVVisual.Gui then
        DestroyArtifact(AimFOVVisual.Gui)
    end

    local gui = TrackArtifact(Instance.new("ScreenGui"))
    gui.Name = "BluehavenAimFOV"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 30
    gui.Parent = PlayerGui

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.fromScale(0.5, 0.5)
    circle.BackgroundTransparency = 1
    circle.Visible = false
    circle.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = ToolAimAssist.FOVColor
    stroke.Parent = circle

    AimFOVVisual.Gui = gui
    AimFOVVisual.Circle = circle
    AimFOVVisual.Stroke = stroke
end

local function updateAimFOVVisual()
    ensureAimFOVVisual()

    local circle = AimFOVVisual.Circle
    local stroke = AimFOVVisual.Stroke
    if not circle or not stroke then return end

    local diameter = math.max(20, (tonumber(ToolAimAssist.FOV) or 220) * 2)
    circle.Size = UDim2.fromOffset(diameter, diameter)
    stroke.Color = ToolAimAssist.FOVColor
    circle.Visible = HubRuntime.Alive
        and ToolAimAssist.Enabled
        and ToolAimAssist.UseFOV
end


local AttackAim = {
    Enabled         = false,
    Holding         = false,
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    AimPart         = "HumanoidRootPart"
}

local SpearAim = {
    Enabled = false,
    Gravity = 50,
    Speed   = 100,
    FOV     = 250,
    AimPart = "HumanoidRootPart"
}

local Killer = {
    KillAll   = false,
    KillRange = 500,
    BypassCooldown = false,
    BypassLeap = false,
    ThirdPerson = false,
    ThirdPersonWasActive = false,
    OriginalCameraType = nil,
    OriginalCameraMode = nil,
    OriginalMinZoom = nil,
    OriginalMaxZoom = nil,
    AntiBlind = false,
    BlockVaults = false
}

local Masked = {
    Enabled      = false,
    CurrentPower = "Cobra"
}

local MaskedPowers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"}

local CameraZoom = {
    UnlimitedZoom = false,
    MaxDistance   = 1000,
    MinDistance   = 0,
    ZoomWasActive = false,
    SavedMinZoom  = nil,
    SavedMaxZoom  = nil,

    FOVEnabled    = false,
    FOV           = 70,
    FOVWasActive  = false,
    SavedFOV      = nil,
}

local AutoStalk = {
    Enabled    = false,
    StalkRange = 150,
    Target     = nil
}

local PlayerMods = {
    GodMode = false,
    AntiFall = false,
    AntiVault = false
}

local Movement = {
    JumpPowerEnabled       = false,
    JumpPowerValue         = 50,
    OriginalJumpPower      = 50,
    OriginalUseJumpPower   = nil,
    OriginalJumpState      = nil,
    ForceJumpEnabled       = false,
    ForceJumpConnection    = nil,
    BoostEnabled           = false,
    BoostValue             = 6,
    BoostKeybind           = Enum.KeyCode.B,
    OriginalWalkSpeed      = 16,
    NoClip                 = false
}

local FastVault = {
    Enabled              = false,
    Speed                = 1.85,
    Connection           = nil,
    CharacterConnection  = nil,
    VaultStateConnection = nil,
    DescendantConnection = nil,
    StateConnection      = nil,
    SyncConnection       = nil,
    LastAnimator         = nil,
    LastCharacter        = nil,
    VaultWindowUntil     = 0,
    WindowJumpUntil      = 0,
    BoostedTracks        = setmetatable({}, {__mode = "k"}),

    -- Known IDs are only hints now; feature no longer depends on them.
    KnownVaultIds = {
        ["83873880822918"] = true,
        ["136962284480779"] = true,
    }
}

local ParryRangeVisual = {
    Enabled      = false,
    Color        = Color3.fromRGB(255, 80, 80),
    Transparency = 0.9
}

local Crosshair = {
    Enabled   = false,
    Size      = 8,
    Thickness = 2,
    Color     = Color3.fromRGB(255, 255, 255),
    Style     = "Plus",
    OffsetX   = 0,
    OffsetY   = 0
}

local Visual = {
    Fullbright      = false,
    NoShadow        = false,
    Ambient         = false,
    AmbientColor    = Color3.fromRGB(255, 255, 255),
    ClockTimeEnabled = true,
    Brightness      = 2,
    ClockTime       = 14,
    LowGraphics     = false,
    LowRender       = false,
    NoFog           = false,
    CleanSky        = false,
    NoScreenEffects = false
}

local Emote = {
    Selected = "Mannrobics",
    Active = false,
}

local EmoteButton = {
    Show        = false,
    GuiInstance = nil
}

-- ============== GROUPED STATE / CONNECTIONS ==============

local Connections = {
    Boost         = nil,
    NoClip        = nil,
    NoClipAdded   = nil,
    GunAim        = nil,
    AttackAim     = nil,
    Stalk         = nil,
    SkillHeartbeat = nil,
    CooldownBypass = nil,
    LeapBypass    = nil
}

local Config = {
    Surv_AutoParry = false,
    Surv_ParrySafety = false,
    Surv_ParryAggressive = false,
    Surv_ParryCircle = true,
    Surv_ParryRadius = 15,
    Surv_ParryFace = 0.7,
    Surv_AutoCrouch = false,
    Ignored_Skills_List = {}
}

local State = { 
    ParryCooldown = false,
    ParryCooldownTime = 60,
    AutoParryAdornment = nil,
    
    FakeParryButton     = nil,
    FakeParryTrack      = nil,
    ParryCircle         = nil,
    KillerTarget        = nil,
    GunAimButtonConn    = nil,
    CurrentGunButton    = nil,
    CurrentAttackButton = nil,
    busy                = false,
    ParryActive         = false,
    AttackAimMode       = "Normal",
    LastFlee            = 0,
    lastParry           = 0,
    FPS                 = 0,
    Frames              = 0,
    LastTick            = tick(),
    created             = false,
    LastCrosshairStyle  = nil,
    UsedPallets         = {}
}

local Timers = {
    lastESPUpdate       = 0,
    lastPlayerESP       = 0,
    lastStatusESP       = 0,
    lastGeneratorESP    = 0,
    lastWindowESP       = 0,
    lastPalletESP       = 0,
    lastSCPEsp          = 0,
    lastKillerUpdate    = 0,
    lastGodMode         = 0,
    lastAutoFlee        = 0,
    lastFooterUpdate    = 0,
    lastTracerScan      = 0,
    lastPalletScan      = 0,
    lastPalletDrop      = 0,
    lastVaultBlock      = 0
}

-- ESP dibuat bertahap supaya map besar tidak discan penuh 10x/detik.
local ESPPerf = {
    PlayerInterval    = 0.18,
    StatusInterval    = 0.45,
    GeneratorInterval = 0.60,
    WindowInterval    = 0.35,
    PalletInterval    = 0.35,
    SCPInterval       = 0.50,
    MapBatchSize      = 40,
    WindowCursor      = 1,
    PalletCursor      = 1,
}

local ESPCache = {
    Objects      = {},
    Status       = {},
    SCP          = {},
    Generators   = {},
    Windows      = {},
    Pallets      = {},
    Hooks        = {},
    Gates        = {},
    WindowList   = {},
    PalletList   = {},
    SCPList      = {},
    HookList     = {},
    GateList     = {},
    WindowIndex  = {},
    PalletIndex  = {},
    SCPIndex     = {},
    HookIndex    = {},
    GateIndex    = {}
}

local ESPVisualState = {
    Generator = setmetatable({}, {__mode = "k"}),
    WindowPos = setmetatable({}, {__mode = "k"})
}

local OriginalLighting = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows  = Lighting.GlobalShadows,
    FogStart       = Lighting.FogStart,
    FogEnd         = Lighting.FogEnd
}

local NoClipOriginal = setmetatable({}, {__mode = "k"})
local MorphState = {
    Username = "",
    OriginalDescription = nil,
    Active = false,
}
local FakeTagHook = {
    Installed = false,
    Original = nil
}
local CrosshairGui = {
    Gui = nil,
    Horizontal = nil,
    Vertical = nil,
    Dot = nil,
    Circle = nil
}

local LastVisualState = {
    Fullbright  = nil,
    NoShadow    = nil,
    Ambient     = nil,
    AmbientColor = nil,
    Brightness  = nil,
    ClockTime   = nil
}

local LastOptimizationState = {
    LowGraphics = nil,
    LowRender   = nil,
    CleanSky    = nil
}

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"] = "Jeff Frenzy",
    ["78432063483146"] = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"] = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"] = "Hidden S1",
    ["80411309607666"] = "Abyssal S1"
}

local Attached = {}

-- ============== HIDE NAME FUNCTIONS ==============
local function shouldHideNameObject(object)
    local ok, isTextObj = pcall(function()
        return object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")
    end)
    if not ok or not isTextObj then return false end
    local text = ""
    pcall(function() text = tostring(object.Text or "") end)
    return text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil
end

local HideNameCharConn = nil

local function hideOverheadName(enabled)
    -- Hide overhead BillboardGui name tag di workspace
    local char = LocalPlayer.Character
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local t = child.Text or ""
                        if t == LocalPlayer.Name or t == LocalPlayer.DisplayName or t:find(LocalPlayer.Name, 1, true) then
                            child.Visible = not enabled
                        end
                    end
                end
                -- Sembunyikan seluruh BillboardGui kalau namanya adalah nama plate
                if obj.Name:lower():find("name") or obj.Name:lower():find("overhead") then
                    obj.Enabled = not enabled
                end
            end
        end
    end
    -- Juga sembunyikan Humanoid DisplayDistances
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.DisplayDistanceType = enabled and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
                hum.NameDisplayDistance = enabled and 0 or 100
                hum.HealthDisplayDistance = enabled and 0 or 100
            end)
        end
    end
end

local function enableHideName(enabled)
    if HideName.Connection then
        pcall(function() HideName.Connection:Disconnect() end)
        HideName.Connection = nil
    end
    if HideNameCharConn then
        pcall(function() HideNameCharConn:Disconnect() end)
        HideNameCharConn = nil
    end

    -- Hide di PlayerGui
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        local function process(object)
            if shouldHideNameObject(object) then
                object.Visible = not enabled
            end
        end
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            process(descendant)
        end
        if enabled then
            HideName.Connection = playerGui.DescendantAdded:Connect(function(object)
                task.defer(process, object)
            end)
        end
    end

    -- Hide overhead name tag
    hideOverheadName(enabled)

    -- Hook CharacterAdded agar apply setiap respawn
    if enabled then
        HideNameCharConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if HideName.Enabled then
                hideOverheadName(true)
            end
        end)
    end
end

-- ============== SILENT AIM FUNCTIONS ==============
local getRoot

local function getSilentTarget()
    local root = getRoot()
    if not root then return nil end

    local myPos = root.Position
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestScreenDist = nil, SilentAim.FOV

    local function consider(part, ignoreModel)
        if not part or not part:IsA("BasePart") then return end
        local targetPos = part.Position
        local worldDist = (targetPos - myPos).Magnitude
        if worldDist > SilentAim.Distance then return end

        if SilentAim.Prediction then
            local vel = Vector3.new()
            pcall(function() vel = part.AssemblyLinearVelocity end)
            local travelTime = worldDist / math.max(SilentAim.BulletSpeed, 1)
            targetPos = targetPos + vel * (SilentAim.PredictStrength * travelTime)
        end

        if SilentAim.WallCheck then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, ignoreModel}
            local hit = workspace:Raycast(myPos, targetPos - myPos, params)
            if hit then return end
        end

        local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
        if not onScreen or screenPos.Z <= 0 then return end
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist <= SilentAim.FOV and screenDist < bestScreenDist then
            bestScreenDist = screenDist
            best = part
        end
    end

    if SilentAim.TargetMode == "SCP" then
        for obj in pairs(ESPCache.SCP) do
            if obj and obj.Parent then
                local part
                if obj:IsA("Model") then
                    part = obj:FindFirstChild(SilentAim.TargetPart, true)
                        or obj:FindFirstChild("HumanoidRootPart", true)
                        or obj:FindFirstChild("Head", true)
                        or obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart", true)
                elseif obj:IsA("BasePart") then
                    part = obj
                end
                consider(part, obj)
            end
        end
        return best
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local valid = SilentAim.TargetMode == "All"
                    or (SilentAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer")
                    or (SilentAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors")
                if valid then
                    local part = p.Character:FindFirstChild(SilentAim.TargetPart, true)
                        or p.Character:FindFirstChild("HumanoidRootPart", true)
                        or p.Character:FindFirstChild("Head", true)
                    consider(part, p.Character)
                end
            end
        end
    end

    return best
end

local function setupSilentAimHook()
    -- Disabled in STABLE build to avoid getgc/namecall scanning and FPS spikes.
    SilentAim.Enabled = false
    return false
end

local function removeSilentAimHook()
    SilentAim.Enabled = false
    silentHookActive = false
    silentOriginalCast = nil
end

function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    
    local interactObj = char:FindFirstChild("CheckInterractable")
    
    if interactObj then
        if interactObj:GetAttribute("isVaulting") == true then return false end
        if interactObj:GetAttribute("isRepairing") == true then return false end
        if interactObj:GetAttribute("isUnhooking") == true then return false end
        if interactObj:GetAttribute("isHealing") == true then return false end
        if interactObj:GetAttribute("isSliding") == true then return false end
    end
    
    return true 
end

function TriggerCrouch()
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")

        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then
                b = b:FindFirstChild(segment)
            end
        end

        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent

            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click)
                task.wait(2)
                firesignal(btn.MouseButton1Click)
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

function isWeapon(obj)
    if obj:IsA("Tool") then return true end
    local name = obj.Name:lower()
    if name:match("weapon") or name:match("gun") or name:match("blade") then return true end
    return false
end

function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer"
    elseif name == "Survivors" then return "Survivor"
    else return "Spectator" end
end

function IsSurvivor(p) return p and p.Team and p.Team.Name == "Survivors" end
function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end

function IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true
end

function GetDistance(pos) 
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (pos - root.Position).Magnitude 
end

getRoot = function()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local KillerAnims = {
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"]  = true,
    ["rbxassetid://74968262036854"]  = true,
    ["rbxassetid://78432063483146"]  = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://80411309607666"]  = true,
    ["rbxassetid://98163597193511"]  = true,
    ["rbxassetid://82666958311998"]  = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true,
    ["rbxassetid://138720291317243"] = true
}

local CrosshairDrawings = {}

local EmoteList = {
    "Mannrobics", "Arm Swing", "Schadenfreude", "Kyoufuu",
    "Backflip", "Griddy", "Friday Night", "Floating Rest",
    "OnePlays", "Quick Combo", "WarCry", "Wave"
}

local GeneratorColor = Color3.fromRGB(255, 170, 0)
local PalletColor    = Color3.fromRGB(74, 255, 181)
local WindowColor    = Color3.fromRGB(74, 255, 181)
local SCPColor       = Color3.fromRGB(255, 0, 0)

local EmoteRemote = Remotes:FindFirstChild("EmoteHandler") or Remotes:WaitForChild("EmoteHandler", 5)

-- WINDOW
local Window = Library:CreateWindow({
    Title = "Bluehaven Hub",
    Footer = 'Violence District v0.0.1 | by Bluehaven',
    Icon = "96848424314690",
    IconSize = UDim2.fromOffset(50, 50),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(480, 380),
    CornerRadius = 20,
    AutoShow = true,
})

-- TABS
local Tabs = {
    Player     = Window:AddTab("Player",      "user","Ability Survivor & Killer"),
    ESP        = Window:AddTab("ESP",         "eye","Esp player, object, stats"),
    Misc       = Window:AddTab("Misc",        "sliders-horizontal","Emote, Chat, Fake Parry"),
    Visual     = Window:AddTab("Visual",      "sparkles","Graphics, MorphAva, Time"),
    UISettings = Window:AddTab("UI Settings", "settings-2","Config, Theme, UiSetting")
}

-- GROUPBOXES
local ESPBox       = Tabs.ESP:AddLeftGroupbox("ESP Cham", "scan-eye")
local ESPStatusBox = Tabs.ESP:AddRightGroupbox("ESP Status", "scan-eye")

local RightTabBox  = Tabs.Player:AddRightTabbox()
local AbilityTab   = RightTabBox:AddTab("Survivor", "user")
local KillerTab    = RightTabBox:AddTab("Killer", "skull")
local AimlockBox   = Tabs.Player:AddLeftGroupbox("AimBot", "crosshair")
local ToFBox       = Tabs.Player:AddLeftGroupbox("Twist of Fate", "target")
local ParryBox     = Tabs.Player:AddLeftGroupbox("Parry", "swords")
local CrosshairBox = Tabs.Player:AddLeftGroupbox("Crosshair", "crosshair")
local MovementBox  = Tabs.Player:AddRightGroupbox("Movement", "move")

-- Misc is split into small focused sections so nothing becomes too long.
local EmoteBox     = Tabs.Misc:AddLeftGroupbox("Emote", "music")
local FakeParryBox = Tabs.Misc:AddLeftGroupbox("Fake Parry", "shield")
local ChatNameBox  = Tabs.Misc:AddRightGroupbox("Chat & Name", "message-circle")

local VisualBox    = Tabs.Visual:AddLeftGroupbox("Graphics", "sun")
local MorphAvaBox  = Tabs.Visual:AddLeftGroupbox("Morph Avatar", "user")
local TimeBox      = Tabs.Visual:AddRightGroupbox("Clock & Ambient", "alarm-clock-check")
local ZoomBox      = Tabs.Visual:AddRightGroupbox("Zoom Out", "fullscreen")
local SettingBox   = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")
local ConfigBox    = Tabs.UISettings:AddRightGroupbox("Configuration", "save")

local function TeleportToPart(part)
    if not part then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local offset = Vector3.new(0, 3, 0)
        if part:IsA("BasePart") then
            hrp.CFrame = part.CFrame + offset
        elseif part:IsA("Model") then
            local p = part:FindFirstChildWhichIsA("BasePart")
            if p then hrp.CFrame = p.CFrame + offset end
        end
        Library:Notify({Title = "Teleport", Description = "Berhasil!", Time = 1})
    end
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function captureMovementOriginal(hum)
    if not hum then return end
    if Movement.OriginalHumanoid ~= hum then
        Movement.OriginalHumanoid = hum
        Movement.OriginalWalkSpeed = hum.WalkSpeed
        Movement.OriginalJumpPower = hum.JumpPower
        Movement.OriginalUseJumpPower = hum.UseJumpPower
        pcall(function()
            Movement.OriginalJumpState = hum:GetStateEnabled(Enum.HumanoidStateType.Jumping)
        end)
    end
end

local function applyJumpPower()
    -- Disabled intentionally.
    -- Bluehaven must not override VD's native jump rules.
    Movement.JumpPowerEnabled = false
end

local function doForceJump()
    -- Disabled intentionally.
    -- No Humanoid jump state / JumpPower / UseJumpPower modification.
    return
end

local function toggleForceJump(_state)
    Movement.ForceJumpEnabled = false

    if Movement.ForceJumpConnection then
        pcall(function()
            Movement.ForceJumpConnection:Disconnect()
        end)
        ForgetConnection(Movement.ForceJumpConnection)
        Movement.ForceJumpConnection = nil
    end
end


local function shouldDisableMovementBoost()
    local char = LocalPlayer.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local anim = track.Animation
                if anim and anim.AnimationId then
                    if anim.AnimationId == "rbxassetid://127096285501517" then return true end
                    if anim.AnimationId == "rbxassetid://112166042383605" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=126965695851149" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=135084204086504" then return true end
                    if anim.AnimationId == "rbxassetid://123047897844134" then return true end
                    local id = anim.AnimationId:match("%d+")
                    if id and KillerAnims["rbxassetid://" .. id] then return true end
                end
            end
        end

        if hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true then
            return true
        end
    end
    return false
end

local function applyMovementBoost()
    if Connections.Boost then
        pcall(function() Connections.Boost:Disconnect() end)
        ForgetConnection(Connections.Boost)
        Connections.Boost = nil
    end

    if not Movement.BoostEnabled then
        return
    end

    -- Physics-based movement boost:
    -- never writes Humanoid.WalkSpeed. It only adds a small horizontal impulse
    -- while the player is actively moving on the ground.
    Connections.Boost = TrackConnection(RunService.Heartbeat:Connect(function(dt)
        if not HubRuntime.Alive or not Movement.BoostEnabled then return end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end
        if shouldDisableMovementBoost() then return end

        -- Ground-only keeps it a movement boost instead of turning into air/fly movement.
        if hum.FloorMaterial == Enum.Material.Air then return end

        local move = hum.MoveDirection
        local flatMove = Vector3.new(move.X, 0, move.Z)
        if flatMove.Magnitude <= 0.05 then return end
        flatMove = flatMove.Unit

        local velocity = root.AssemblyLinearVelocity
        local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
        local forwardSpeed = horizontal:Dot(flatMove)

        -- BoostValue means "extra desired horizontal speed" above the game's own
        -- current WalkSpeed. WalkSpeed itself is read only and never modified.
        local targetSpeed = math.max(0, hum.WalkSpeed) + math.max(0, Movement.BoostValue)
        local deficit = targetSpeed - forwardSpeed
        if deficit <= 0.05 then return end

        local safeDt = math.clamp(tonumber(dt) or 0, 0, 0.05)
        local acceleration = math.max(20, Movement.BoostValue * 12)
        local deltaV = math.min(deficit, acceleration * safeDt)
        if deltaV <= 0 then return end

        pcall(function()
            root:ApplyImpulse(flatMove * root.AssemblyMass * deltaV)
        end)
    end))
end

-- ==================== AUTO PARRY SENSOR ====================
function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob
        and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")

    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        pcall(function()
            if mouse2click then
                mouse2click()
                return
            end
            if mouse2press and mouse2release then
                mouse2press()
                task.wait(0.01)
                mouse2release()
                return
            end
            if MouseButton2Click then
                MouseButton2Click()
                return
            end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then
            parryRemote:FireServer()
        end
        task.spawn(tapMobileParryButton)
    end)
end

function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
        
        if parryResultRemote then
            TrackConnection(parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                if not HubRuntime.Alive then return end
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end))
        end
    end)
end
ListenToParryResult()

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end

    TrackConnection(humanoid.ChildAdded:Connect(function(child)
        if not HubRuntime.Alive then return end
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end))

    TrackConnection(kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end))

    TrackConnection(animator.AnimationPlayed:Connect(function(track)
        if not HubRuntime.Alive then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end

            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if not myHRP or not kHRP then return end

            -- Abyssal S1 auto-crouch now follows the SAME Parry Distance slider.
            -- No more crouching just because an Abyssal used the skill across the map.
            local crouchRadius = math.clamp(tonumber(Config.Surv_ParryRadius) or 15, 5, 30)
            local dist = (myHRP.Position - kHRP.Position).Magnitude

            if dist <= crouchRadius then
                TriggerCrouch()
            end

            return
        end
        
        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end 
        if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end

        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        
        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if Config.Surv_ParryAggressive then
            local aggressiveRadius = 12
            local detectionRadius = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = TrackConnection(RunService.Heartbeat:Connect(function()
                    if not HubRuntime.Alive or os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end))
            end
        else
            if startDistance > Config.Surv_ParryRadius then return end
            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end))
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then 
        AttachParrySensor(p.Character) 
    end
end

function SetupPlayer(p)
    if p == LocalPlayer or not HubRuntime.Alive then return end
    TrackConnection(p.CharacterAdded:Connect(function()
        if HubRuntime.Alive then TryAttach(p) end
    end))
    TrackConnection(p:GetPropertyChangedSignal("Team"):Connect(function()
        if HubRuntime.Alive then TryAttach(p) end
    end))
    if p.Character then TryAttach(p) end
end

local function setNoClipPart(v)
    if not v or not v:IsA("BasePart") then return end
    if NoClipOriginal[v] == nil then NoClipOriginal[v] = v.CanCollide end
    if v.CanCollide then v.CanCollide = false end
end

local function applyNoClip()
    local char = LocalPlayer.Character
    if Movement.NoClip then
        if not char then return end
        -- Scan karakter hanya saat enable/respawn, bukan setiap frame.
        for _, v in ipairs(char:GetDescendants()) do
            setNoClipPart(v)
        end
    else
        for part, original in pairs(NoClipOriginal) do
            if part and part.Parent then
                pcall(function() part.CanCollide = original end)
            end
            NoClipOriginal[part] = nil
        end
    end
end

local function toggleNoClip(state)
    Movement.NoClip = state
    if Connections.NoClip then
        Connections.NoClip:Disconnect()
        Connections.NoClip = nil
    end
    if Connections.NoClipAdded then
        Connections.NoClipAdded:Disconnect()
        Connections.NoClipAdded = nil
    end

    if state then
        applyNoClip()
        local char = LocalPlayer.Character
        if char then
            Connections.NoClipAdded = char.DescendantAdded:Connect(function(obj)
                if Movement.NoClip then setNoClipPart(obj) end
            end)
        end

        -- Beberapa game mengubah CanCollide kembali. Cek part yang SUDAH tercatat
        -- 4x/detik, tanpa scan seluruh character hierarchy.
        local lastCheck = 0
        Connections.NoClip = RunService.Heartbeat:Connect(function()
            if not Movement.NoClip then return end
            local now = os.clock()
            if now - lastCheck < 0.25 then return end
            lastCheck = now
            for part in pairs(NoClipOriginal) do
                if part and part.Parent and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        applyNoClip()
    end
end

local function applyGodMode()
    if not PlayerMods.GodMode then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    local s = hum:GetState()
    if s == Enum.HumanoidStateType.Dead
    or s == Enum.HumanoidStateType.FallingDown
    or s == Enum.HumanoidStateType.Ragdoll then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

-- AntiFall is handled by the reversible main __namecall hook now.
local FallRemote = nil
pcall(function()
    local mechanics = Remotes:FindFirstChild("Mechanics")
    local candidate = mechanics and mechanics:FindFirstChild("Fall")
    if candidate and candidate:IsA("RemoteEvent") then FallRemote = candidate end
end)


-- ============= ESP SYSTEM ==============

local function addIndexed(list, indexMap, obj)
    if indexMap[obj] then return end
    list[#list + 1] = obj
    indexMap[obj] = #list
end

local function removeIndexed(list, indexMap, obj)
    local index = indexMap[obj]
    if not index then return end
    local lastIndex = #list
    local lastObj = list[lastIndex]
    list[index] = lastObj
    list[lastIndex] = nil
    indexMap[obj] = nil
    if lastObj and lastObj ~= obj then
        indexMap[lastObj] = index
    end
end

local function registerESPObject(obj)
    if not obj then return end
    local name = obj.Name
    local lowerName = string.lower(name)

    if string.find(lowerName, "scp", 1, true) and not ESPCache.SCP[obj] then
        ESPCache.SCP[obj] = true
        addIndexed(ESPCache.SCPList, ESPCache.SCPIndex, obj)
    end

    if name == "Generator" then
        ESPCache.Generators[obj] = true
    elseif name == "Window" then
        if not ESPCache.Windows[obj] then
            ESPCache.Windows[obj] = true
            addIndexed(ESPCache.WindowList, ESPCache.WindowIndex, obj)
        end
    elseif name == "Pallet" or name == "Palletwrong" then
        if not ESPCache.Pallets[obj] then
            ESPCache.Pallets[obj] = true
            addIndexed(ESPCache.PalletList, ESPCache.PalletIndex, obj)
        end
    elseif name == "Hook" and obj:IsA("Model") then
        if not ESPCache.Hooks[obj] then
            ESPCache.Hooks[obj] = true
            addIndexed(ESPCache.HookList, ESPCache.HookIndex, obj)
        end
    elseif name == "Gate" and obj:IsA("Model") then
        if not ESPCache.Gates[obj] then
            ESPCache.Gates[obj] = true
            addIndexed(ESPCache.GateList, ESPCache.GateIndex, obj)
        end
    end
end

-- Incremental workspace indexing. Hindari workspace:GetDescendants() sekali besar
-- karena pembuatan array-nya sendiri bisa bikin client nge-freeze di map besar.
local ESPScanState = { Running = false, Generation = 0, DelayTask = nil }
local function startIncrementalMapScan()
    if ESPScanState.Running then return end
    ESPScanState.Running = true
    ESPScanState.Generation = ESPScanState.Generation + 1
    local generation = ESPScanState.Generation

    task.spawn(function()
        local queue = {}
        local head = 1
        for _, child in ipairs(workspace:GetChildren()) do
            if child ~= workspace.CurrentCamera and child ~= workspace.Terrain then
                queue[#queue + 1] = child
            end
        end

        while head <= #queue and ESPScanState.Generation == generation do
            local frameStart = os.clock()
            local processed = 0
            while head <= #queue and processed < 100 and (os.clock() - frameStart) < 0.0025 do
                local obj = queue[head]
                head = head + 1
                processed = processed + 1

                if obj and obj.Parent then
                    registerESPObject(obj)
                    local ok, children = pcall(function() return obj:GetChildren() end)
                    if ok and children then
                        for _, child in ipairs(children) do
                            queue[#queue + 1] = child
                        end
                    end
                end
            end
            task.wait()
        end

        if ESPScanState.Generation == generation then
            ESPScanState.Running = false
        end
    end)
end

ESPScanState.DelayTask = task.delay(0.35, function()
    ESPScanState.DelayTask = nil
    if HubRuntime.Alive then startIncrementalMapScan() end
end)
TrackConnection(workspace.DescendantAdded:Connect(function(obj)
    if HubRuntime.Alive then registerESPObject(obj) end
end))

local function removeESP(obj)
    local h = ESPCache.Objects[obj]
    if h then
        DestroyArtifact(h)
        ESPCache.Objects[obj] = nil
    end
end

local function createESP(obj, color)
    if not obj or not obj.Parent then return end
    local h = ESPCache.Objects[obj]
    if h and h.Parent then
        -- Hindari property write kalau tidak berubah.
        if h.FillColor ~= color then h.FillColor = color end
        if h.OutlineColor ~= color then h.OutlineColor = color end
        return
    end

    local adornee = obj
    if not obj:IsA("Model") and not obj:IsA("BasePart") then
        adornee = obj:FindFirstChildWhichIsA("BasePart", true) or obj:FindFirstAncestorOfClass("Model")
    end
    if not adornee then return end

    h = TrackArtifact(Instance.new("Highlight"))
    h.Name = "BluehavenESP"
    h.Adornee = adornee
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    ESPCache.Objects[obj] = h
end

local function removeStatusESP(char)
    local billboard = ESPCache.Status[char]
    if billboard then
        DestroyArtifact(billboard)
        ESPCache.Status[char] = nil
    end
end

local function removeGeneratorVisual(generator)
    local state = ESPVisualState.Generator[generator]
    if state then
        if state.Billboard then DestroyArtifact(state.Billboard) end
        if state.Highlight then DestroyArtifact(state.Highlight) end
        ESPVisualState.Generator[generator] = nil
    else
        local old = generator and generator:FindFirstChild("GenESP")
        if old then old:Destroy() end
        local h = generator and generator:FindFirstChild("GenHighlight")
        if h then h:Destroy() end
    end
end

local function clearESPSet(set)
    for obj in pairs(set) do removeESP(obj) end
end

local function clearAllStatusESP()
    for char in pairs(ESPCache.Status) do removeStatusESP(char) end
end

local function clearPlayerTeamESP(teamName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == teamName and p.Character then
            removeESP(p.Character)
            removeStatusESP(p.Character)
        end
    end
end

local function clearGeneratorESP()
    for generator in pairs(ESPCache.Generators) do
        if generator then removeGeneratorVisual(generator) end
    end
end

local function GetHeldItem(char)
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if ESPItems[obj.Name] then return obj.Name end
    end
    return nil
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local ok, val = pcall(function() return child.Value end)
        if ok then return val end
    end
    return nil
end

local function distSq(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    local dz = a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

local function getObjectPosition(obj, cacheStatic)
    if not obj or not obj.Parent then return nil end
    if cacheStatic then
        local cached = ESPVisualState.WindowPos[obj]
        if cached then return cached end
    end

    local pos
    if obj:IsA("Model") then
        local ok, pivot = pcall(function() return obj:GetPivot() end)
        if ok and pivot then pos = pivot.Position end
    elseif obj:IsA("BasePart") then
        pos = obj.Position
    end

    if cacheStatic and pos then ESPVisualState.WindowPos[obj] = pos end
    return pos
end

local function ensureGeneratorState(generator)
    local state = ESPVisualState.Generator[generator]
    if state then return state end
    state = {LastPercent = nil, LastColor = nil}
    ESPVisualState.Generator[generator] = state
    return state
end

local function ensureGenHighlight(generator, state, color)
    local h = state.Highlight
    local created = false
    if not h or not h.Parent then
        h = TrackArtifact(Instance.new("Highlight"))
        h.Name = "GenHighlight"
        h.Adornee = generator
        h.FillTransparency = 0.9
        h.OutlineTransparency = 0.3
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = generator
        state.Highlight = h
        created = true
    end
    if created or state.LastColor ~= color then
        h.FillColor = color
        h.OutlineColor = color
    end
end

local function CreateBillboard(text, color)
    local billboard = TrackArtifact(Instance.new("BillboardGui"))
    billboard.Name = "GenESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    return billboard, label
end

local function UpdateGenerator(generator, root)
    if not ESP.Generator or not generator or not generator.Parent then return end

    local currentRoot = root or getRoot()
    local pos = getObjectPosition(generator, false)
    if not currentRoot or not pos
        or distSq(pos, currentRoot.Position) > (ESP.Distance * ESP.Distance) then
        removeGeneratorVisual(generator)
        return
    end

    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local rounded = math.floor((tonumber(percent) or 0) + 0.5)
    if rounded >= 100 then
        removeGeneratorVisual(generator)
        return
    end

    local color = GeneratorColor
    local state = ensureGeneratorState(generator)

    ensureGenHighlight(generator, state, color)

    if not state.Billboard or not state.Billboard.Parent then
        local billboard, label = CreateBillboard(string.format("[%d%%]", rounded), color)
        local adornee
        if generator:IsA("BasePart") then
            adornee = generator
        elseif generator:IsA("Model") then
            adornee = generator.PrimaryPart or generator:FindFirstChildWhichIsA("BasePart", true)
        else
            adornee = generator:FindFirstChildWhichIsA("BasePart", true)
        end
        if adornee then
            billboard.Adornee = adornee
            billboard.Parent = generator
            state.Billboard = billboard
            state.Label = label
        else
            DestroyArtifact(billboard)
        end
    elseif rounded ~= state.LastPercent or state.LastColor ~= color then
        local label = state.Label or state.Billboard:FindFirstChild("Value")
        if label then
            local newText = string.format("[%d%%]", rounded)
            if label.Text ~= newText then label.Text = newText end
            if label.TextColor3 ~= color then label.TextColor3 = color end
            state.Label = label
        end
    end

    state.LastPercent = rounded
    state.LastColor = color
end

local function UpdateMapESP(obj, root, kind)
    if not obj or not root or not obj.Parent then return end
    local enabled = (kind == "Window" and ESP.Window) or (kind == "Pallet" and ESP.Pallet)
    if not enabled then return end

    local pos = getObjectPosition(obj, kind == "Window")
    if not pos then return end
    local rangeSq = ESP.Distance * ESP.Distance
    if distSq(pos, root.Position) <= rangeSq then
        createESP(obj, kind == "Window" and WindowColor or PalletColor)
    else
        removeESP(obj)
    end
end

local function isStatusESPEnabled()
    return ESPStatus.ShowName
        or ESPStatus.ShowDistance
        or ESPStatus.ShowHealth
        or ESPStatus.ShowItem
end

local function colorToHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
        math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
        math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    )
end

local function escapeRichText(value)
    local s = tostring(value or "")
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    return s
end

local function richLine(color, value)
    return string.format('<font color="%s">%s</font>', colorToHex(color), escapeRichText(value))
end

local function createStatusESP(player, char, root)
    if not isStatusESPEnabled() or not root or not char then
        if char then removeStatusESP(char) end
        return
    end

    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then
        removeStatusESP(char)
        return
    end

    local isDown = hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true

    local d2 = distSq(head.Position, root.Position)
    if d2 > ESPStatus.Radius * ESPStatus.Radius then
        removeStatusESP(char)
        return
    end

    local lines = {}
    if isDown then
        lines[#lines + 1] = richLine(StatusDownColor, "DOWN")
    end
    if ESPStatus.ShowName then
        lines[#lines + 1] = richLine(StatusColors.Name, player.Name)
    end
    if ESPStatus.ShowDistance then
        lines[#lines + 1] = richLine(StatusColors.Distance, string.format("Dist: %.0f", math.sqrt(d2)))
    end
    if ESPStatus.ShowHealth then
        lines[#lines + 1] = richLine(
            isDown and StatusDownColor or StatusColors.Health,
            string.format("HP: %.0f", hum.Health)
        )
    end
    if ESPStatus.ShowItem then
        local item = GetHeldItem(char)
        if item then lines[#lines + 1] = richLine(StatusColors.Item, "Item: " .. item) end
    end

    if #lines == 0 then
        removeStatusESP(char)
        return
    end

    local textValue = table.concat(lines, "\n")
    local billboard = ESPCache.Status[char]

    if not billboard or not billboard.Parent then
        billboard = TrackArtifact(Instance.new("BillboardGui"))
        billboard.Name = "BluehavenStatusESP"
        billboard.Size = UDim2.new(0, 150, 0, 72)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)

        local label = Instance.new("TextLabel")
        label.Name = "Value"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.RichText = true
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = textValue
        label.Parent = billboard

        billboard.Parent = char
        ESPCache.Status[char] = billboard
    else
        local label = billboard:FindFirstChild("Value") or billboard:FindFirstChildOfClass("TextLabel")
        if label then
            label.RichText = true
            if label.Text ~= textValue then label.Text = textValue end
        end
    end
end

local function UpdateSCPEsp(root)
    if not ESP.SCP or not root then return end
    local rangeSq = ESP.Distance * ESP.Distance
    for _, obj in ipairs(ESPCache.SCPList) do
        if obj and ESPCache.SCP[obj] and obj.Parent then
            local pos = getObjectPosition(obj, false)
            if pos and distSq(pos, root.Position) <= rangeSq then
                createESP(obj, SCPColor)
            else
                removeESP(obj)
            end
        end
    end
end

local function processMapBatch(list, set, root, kind, cursorField)
    local count = #list
    if count == 0 then return end
    local cursor = ESPPerf[cursorField] or 1
    local processed = 0
    local batch = math.min(ESPPerf.MapBatchSize, count)

    while processed < batch and count > 0 do
        if cursor > count then cursor = 1 end
        local obj = list[cursor]
        cursor = cursor + 1
        processed = processed + 1
        if obj and set[obj] and obj.Parent then
            UpdateMapESP(obj, root, kind)
        end
    end

    ESPPerf[cursorField] = cursor
end

TrackConnection(workspace.DescendantRemoving:Connect(function(obj)
    if not HubRuntime.Alive then return end
    ESPVisualState.WindowPos[obj] = nil

    if ESPCache.SCP[obj] then
        ESPCache.SCP[obj] = nil
        removeIndexed(ESPCache.SCPList, ESPCache.SCPIndex, obj)
    end
    if ESPCache.Windows[obj] then
        ESPCache.Windows[obj] = nil
        removeIndexed(ESPCache.WindowList, ESPCache.WindowIndex, obj)
    end
    if ESPCache.Pallets[obj] then
        ESPCache.Pallets[obj] = nil
        removeIndexed(ESPCache.PalletList, ESPCache.PalletIndex, obj)
    end
    if ESPCache.Hooks[obj] then
        ESPCache.Hooks[obj] = nil
        removeIndexed(ESPCache.HookList, ESPCache.HookIndex, obj)
    end
    if ESPCache.Gates[obj] then
        ESPCache.Gates[obj] = nil
        removeIndexed(ESPCache.GateList, ESPCache.GateIndex, obj)
    end
    if ESPCache.Generators[obj] then
        ESPCache.Generators[obj] = nil
        removeGeneratorVisual(obj)
    end

    removeESP(obj)
    if ESPCache.Status[obj] then removeStatusESP(obj) end
end))

-- ============== TELEPORT MAP FUNCTIONS =================
local function TeleportToGenerator()
    local gens = {}
    for obj in pairs(ESPCache.Generators) do
        if obj and obj.Parent then
            table.insert(gens, obj)
        end
    end
    if #gens == 0 then 
        Library:Notify({Title = "TP Generator", Description = "Tidak ada generator!", Time = 2})
        return 
    end
    if TeleportIndex.Generator > #gens then TeleportIndex.Generator = 1 end
    
    local gen = gens[TeleportIndex.Generator]
    local part = gen:FindFirstChildWhichIsA("BasePart")
    if part then
        TeleportToPart(part)
        Library:Notify({Title = "TP Generator", Description = "Generator " .. TeleportIndex.Generator, Time = 1.2})
    end
    TeleportIndex.Generator = TeleportIndex.Generator + 1
end

local function nextCachedObject(list, set, indexName)
    local count = #list
    if count == 0 then return nil end
    local index = TeleportIndex[indexName] or 1
    for _ = 1, count do
        if index > count then index = 1 end
        local obj = list[index]
        index = index + 1
        if obj and set[obj] and obj.Parent then
            TeleportIndex[indexName] = index
            return obj
        end
    end
    TeleportIndex[indexName] = 1
    return nil
end

local function TeleportToHook()
    local hook = nextCachedObject(ESPCache.HookList, ESPCache.Hooks, "Hook")
    if not hook then
        Library:Notify({Title = "TP Hook", Description = "Hook belum ter-cache. Coba Refresh Map.", Time = 2})
        return
    end
    local part = hook:FindFirstChild("HookPoint") or hook:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
end

local function TeleportToGate()
    local gate = nextCachedObject(ESPCache.GateList, ESPCache.Gates, "Gate")
    if not gate then
        Library:Notify({Title = "TP Gate", Description = "Gate belum ter-cache. Coba Refresh Map.", Time = 2})
        return
    end
    local part = gate:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
end

local function TeleportToPallet()
    local pallets = {}
    for pal in pairs(ESPCache.Pallets) do
        if pal and pal.Parent then
            table.insert(pallets, pal)
        end
    end
    if #pallets == 0 then 
        Library:Notify({Title = "TP Pallet", Description = "Tidak ada pallet!", Time = 2})
        return 
    end
    if TeleportIndex.Pallet > #pallets then TeleportIndex.Pallet = 1 end
    
    local pallet = pallets[TeleportIndex.Pallet]
    local part = pallet:FindFirstChild("PrimaryPartPallet") or pallet:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Pallet = TeleportIndex.Pallet + 1
end

local function TeleportToWindow()
    local windows = {}
    for win in pairs(ESPCache.Windows) do
        if win and win.Parent then
            table.insert(windows, win)
        end
    end
    if #windows == 0 then 
        Library:Notify({Title = "TP Window", Description = "Tidak ada window!", Time = 2})
        return 
    end
    if TeleportIndex.Window > #windows then TeleportIndex.Window = 1 end
    
    local window = windows[TeleportIndex.Window]
    local part = window:FindFirstChild("Bottom") or window:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Window = TeleportIndex.Window + 1
end

local function RefreshMapForTeleport()
    -- Jangan scan GetDescendants secara sinkron; jalankan indexer bertahap.
    if not ESPScanState.Running then startIncrementalMapScan() end
    TeleportIndex.Generator = 1
    TeleportIndex.Hook = 1
    TeleportIndex.Gate = 1
    TeleportIndex.Pallet = 1
    TeleportIndex.Window = 1
    Library:Notify({Title = "Refresh Map", Description = "Refresh cache berjalan bertahap...", Time = 2})
end

-- ============== CLIENT FEATURE HELPERS ==============
local function notify(title, description, t)
    pcall(function()
        Library:Notify({Title = title, Description = description, Time = t or 2})
    end)
end

local function installFakeTagHook()
    if FakeTagHook.Installed then return true end
    local ok, err = pcall(function()
        FakeTagHook.Original = TextChatService.OnIncomingMessage
        TextChatService.OnIncomingMessage = function(message)
            local props
            if type(FakeTagHook.Original) == "function" then
                local okOld, oldProps = pcall(FakeTagHook.Original, message)
                if okOld then props = oldProps end
            end
            props = props or Instance.new("TextChatMessageProperties")

            if FakeTag.Enabled and message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                local oldPrefix = props.PrefixText
                if not oldPrefix or oldPrefix == "" then oldPrefix = message.PrefixText or "" end
                props.PrefixText = string.format("<font color='%s'>%s</font> %s", FakeTag.Color, FakeTag.Text, oldPrefix)
            end
            return props
        end
    end)
    FakeTagHook.Installed = ok
    if not ok then warn("Fake Chat Tag hook failed:", err) end
    return ok
end

local function stopFakeParryAnimation()
    local track = State.FakeParryTrack
    State.FakeParryTrack = nil

    if track then
        pcall(function()
            if track.IsPlaying then track:Stop(0.06) end
        end)
    end
end

local function playFakeParryAnimation(forcePlay)
    if not forcePlay and not FakeParry.Enabled then return false end

    local id = FakeParryAnimations[FakeParry.Animation]
    if not id then
        notify("Fake Parry", "Animation tidak ditemukan: " .. tostring(FakeParry.Animation), 2)
        return false
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then
        notify("Fake Parry", "Character belum siap.", 2)
        return false
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    stopFakeParryAnimation()

    local anim = Instance.new("Animation")
    anim.Name = "BluehavenFakeParry"
    anim.AnimationId = id

    local track = nil
    local loaded = pcall(function()
        track = animator:LoadAnimation(anim)
    end)

    -- Fallback for executors/game builds where Animator:LoadAnimation fails.
    if not loaded or not track then
        pcall(function()
            track = hum:LoadAnimation(anim)
        end)
    end

    if not track then
        pcall(function() anim:Destroy() end)
        notify("Fake Parry", "Animation gagal di-load.", 2)
        return false
    end

    State.FakeParryTrack = track

    pcall(function()
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = false
        track:Play(0.03, 1, 1)
        track:AdjustWeight(1, 0.03)
    end)

    -- Animation object is only needed for loading; the track keeps the asset.
    pcall(function() anim:Destroy() end)

    local stopConn
    stopConn = TrackConnection(track.Stopped:Connect(function()
        if State.FakeParryTrack == track then
            State.FakeParryTrack = nil
        end
        if stopConn then
            ForgetConnection(stopConn)
            pcall(function() stopConn:Disconnect() end)
            stopConn = nil
        end
    end))

    task.delay(2.8, function()
        if HubRuntime.Alive and State.FakeParryTrack == track then
            stopFakeParryAnimation()
        end
    end)

    return true
end

local function getCurrentDescription()
    local hum = getHumanoid()
    if not hum then return nil end
    local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
    return ok and desc or nil
end

local function applyMorphByUsername()
    local username = tostring(MorphState.Username or ""):match("^%s*(.-)%s*$")
    if username == "" then
        notify("Morph Avatar", "Isi username dulu.", 2)
        return
    end
    local hum = getHumanoid()
    if not hum then return end
    if not MorphState.OriginalDescription then MorphState.OriginalDescription = getCurrentDescription() end

    task.spawn(function()
        local ok, err = pcall(function()
            local userId = Players:GetUserIdFromNameAsync(username)
            local desc = Players:GetHumanoidDescriptionFromUserId(userId)
            hum:ApplyDescription(desc)
        end)

        if ok then
            MorphState.Active = true
        end

        notify("Morph Avatar", ok and ("Morph ke " .. username .. " berhasil.") or ("Gagal: " .. tostring(err)), 2)
    end)
end

local function resetMorph()
    local hum = getHumanoid()
    if not hum then return end
    if MorphState.OriginalDescription then
        local ok, err = pcall(function()
            hum:ApplyDescription(MorphState.OriginalDescription)
        end)

        if ok then
            MorphState.Active = false
        end

        notify("Morph Avatar", ok and "Avatar dikembalikan." or ("Reset gagal: " .. tostring(err)), 2)
    else
        notify("Morph Avatar", "Belum ada morph yang disimpan.", 2)
    end
end

local function destroyCrosshairGui()
    if CrosshairGui.Gui then pcall(function() CrosshairGui.Gui:Destroy() end) end
    CrosshairGui.Gui = nil
    CrosshairGui.Horizontal = nil
    CrosshairGui.Vertical = nil
    CrosshairGui.Dot = nil
    CrosshairGui.Circle = nil
end

local function ensureCrosshairGui()
    if CrosshairGui.Gui and CrosshairGui.Gui.Parent then return end
    local gui = TrackArtifact(Instance.new("ScreenGui"))
    gui.Name = "BluehavenCrosshair"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = PlayerGui

    local h = Instance.new("Frame")
    h.BorderSizePixel = 0
    h.AnchorPoint = Vector2.new(0.5, 0.5)
    h.Parent = gui

    local v = Instance.new("Frame")
    v.BorderSizePixel = 0
    v.AnchorPoint = Vector2.new(0.5, 0.5)
    v.Parent = gui

    local dot = Instance.new("Frame")
    dot.BorderSizePixel = 0
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = gui

    local circle = Instance.new("Frame")
    circle.BackgroundTransparency = 1
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.Parent = circle
    circle.Parent = gui

    CrosshairGui.Gui = gui
    CrosshairGui.Horizontal = h
    CrosshairGui.Vertical = v
    CrosshairGui.Dot = dot
    CrosshairGui.Circle = circle
end

local function updateCrosshairGui()
    if not Crosshair.Enabled then
        destroyCrosshairGui()
        return
    end
    ensureCrosshairGui()
    if not CrosshairGui.Gui then return end

    local pos = UDim2.new(0.5, Crosshair.OffsetX, 0.5, Crosshair.OffsetY)
    local size = math.max(2, Crosshair.Size)
    local thick = math.max(1, Crosshair.Thickness)
    local color = Crosshair.Color

    local h, v, dot, circle = CrosshairGui.Horizontal, CrosshairGui.Vertical, CrosshairGui.Dot, CrosshairGui.Circle
    h.Visible = Crosshair.Style == "Plus"
    v.Visible = Crosshair.Style == "Plus"
    dot.Visible = Crosshair.Style == "Dot"
    circle.Visible = Crosshair.Style == "Circle"

    h.Position = pos; v.Position = pos; dot.Position = pos; circle.Position = pos
    h.Size = UDim2.fromOffset(size * 2, thick)
    v.Size = UDim2.fromOffset(thick, size * 2)
    dot.Size = UDim2.fromOffset(math.max(thick + 2, 4), math.max(thick + 2, 4))
    circle.Size = UDim2.fromOffset(size * 2, size * 2)
    h.BackgroundColor3 = color; v.BackgroundColor3 = color; dot.BackgroundColor3 = color
    local stroke = circle:FindFirstChild("Stroke")
    if stroke then stroke.Color = color; stroke.Thickness = thick end
end

local function setToggleValue(id, value, fallback)
    local toggle = Toggles and Toggles[id]
    if toggle and type(toggle.SetValue) == "function" then
        toggle:SetValue(value)
    elseif fallback then
        fallback(value)
    end
end

-- Hotkeys used by features that previously only changed a variable.
TrackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not HubRuntime.Alive or gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == GenBypass.HotkeyCode and GenBypass.Enabled then
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then task.spawn(GB_DoRepair, bestPoint) end
    end

    if FakeParry.Enabled and input.KeyCode == FakeParry.Keybind then
        playFakeParryAnimation(false)
    end

    if input.KeyCode == Movement.BoostKeybind then
        local nextState = not Movement.BoostEnabled

        -- Prefer changing the UI toggle so config/autosave stays in sync.
        local boostToggle = Toggles["Movement Boost"]
        if boostToggle and type(boostToggle.SetValue) == "function" then
            boostToggle:SetValue(nextState)
        else
            Movement.BoostEnabled = nextState
            applyMovementBoost()
        end

        notify(
            "Movement Boost",
            nextState and "Enabled" or "Disabled",
            1.2
        )
    end

end))

installFakeTagHook()

-- ========== AUTO SYSTEM =================

-- NAMECALL HOOK - STABLE/LIGHT BUILD
-- One reversible hook handles light ToF Silent Aim + local defensive filters.
local oldNamecall
local mainNamecallHookInstalled = false
local rewriteToFFireArgs

local function installMainNamecallHook()
    if mainNamecallHookInstalled then return true end
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
        return false
    end

    local ok = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                local callerIsUs = type(checkcaller) == "function" and checkcaller() or false
                if not callerIsUs then
                    if PlayerMods.AntiFall and FallRemote and self == FallRemote then
                        return nil
                    end

                    local isToFFire = self == ToFFireRemote
                        or (self.Name == "Fire" and self.Parent and self.Parent.Name == "Twist of Fate")
                    if ToolAimAssist.Enabled and isToFFire and rewriteToFFireArgs then
                        local packed = table.pack(...)
                        local okRewrite, rewritten = pcall(rewriteToFFireArgs, packed)
                        if okRewrite and rewritten then
                            return oldNamecall(self, table.unpack(rewritten, 1, rewritten.n or #rewritten))
                        end
                    end

                    if Killer.AntiBlind and GotBlindedRemote and self == GotBlindedRemote then
                        local isKiller = LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
                        if isKiller then return nil end
                    end

                    if (Killer.BlockVaults or PlayerMods.AntiVault) and self.Name == "VaultEvent" then
                        return nil
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)

    mainNamecallHookInstalled = ok
    return ok
end

-- Intentionally NOT installed at script startup.
-- It will only install if Anti Blind / Block Vault is enabled.

local LeapBypassState = {
    Originals = {},
    Patched = {},
}

local function RestoreLeapBypass()
    for _, entry in ipairs(LeapBypassState.Originals) do
        pcall(function() debug.setupvalue(entry.fn, entry.index, entry.value) end)
    end
    table.clear(LeapBypassState.Originals)
    table.clear(LeapBypassState.Patched)
end

local function StopLeapBypass()
    Killer.BypassLeap = false
    if Connections.LeapBypass and type(task.cancel) == "function" then
        pcall(function() task.cancel(Connections.LeapBypass) end)
    end
    Connections.LeapBypass = nil
    RestoreLeapBypass()
end

local function StartLeapBypass()
    if type(getgc) ~= "function"
        or type(islclosure) ~= "function"
        or not debug
        or type(debug.getupvalues) ~= "function"
        or type(debug.setupvalue) ~= "function" then
        notify("Bypass Leap", "Executor tidak support fitur ini.", 2)
        Killer.BypassLeap = false
        return
    end

    RestoreLeapBypass()

    Connections.LeapBypass = task.spawn(function()
        local leapFunction, m2Function
        for _, v in pairs(getgc(true)) do
            if not Killer.BypassLeap or not HubRuntime.Alive then return end
            if type(v) == "function" and islclosure(v) then
                local okInfo, info = pcall(debug.getinfo, v)
                if okInfo and info then
                    if info.name == "tryActivate" then leapFunction = v end
                    if info.name == "playM2Animation" then m2Function = v end
                    if leapFunction and m2Function then break end
                end
            end
        end

        if not leapFunction and not m2Function then
            warn("Bypass Leap: function tidak ditemukan.")
            return
        end

        for _, fn in ipairs({leapFunction, m2Function}) do
            if fn and Killer.BypassLeap and HubRuntime.Alive then
                local okValues, values = pcall(debug.getupvalues, fn)
                if okValues and values then
                    for i, val in pairs(values) do
                        if type(val) == "table" then
                            local hasCooldown = false
                            pcall(function() hasCooldown = val.Cooldown ~= nil end)
                            if hasCooldown then
                                local key = tostring(fn) .. ":" .. tostring(i)
                                if not LeapBypassState.Patched[key] then
                                    LeapBypassState.Patched[key] = true
                                    LeapBypassState.Originals[#LeapBypassState.Originals + 1] = {
                                        fn = fn, index = i, value = val,
                                    }
                                    local proxy = setmetatable({}, {
                                        __index = function(_, k)
                                            if Killer.BypassLeap and k == "Cooldown" then
                                                return 0
                                            end
                                            return val[k]
                                        end,
                                        __newindex = function(_, k, v) val[k] = v end,
                                    })
                                    pcall(function() debug.setupvalue(fn, i, proxy) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local CooldownBypassState = {
    MT = nil,
    OriginalIndex = nil,
}

local function toggleBypassCooldown(state)
    if not state then
        if CooldownBypassState.MT and CooldownBypassState.OriginalIndex then
            pcall(function()
                CooldownBypassState.MT.__index = CooldownBypassState.OriginalIndex
            end)
        end
        CooldownBypassState.MT = nil
        CooldownBypassState.OriginalIndex = nil
        return
    end

    if CooldownBypassState.MT then return end

    if type(getgc) ~= "function" or type(getrawmetatable) ~= "function" then
        notify("Bypass Cooldown", "Executor tidak support fitur ini.", 2)
        return
    end

    local cooldownFunc
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "canUse") then
            local mt = getrawmetatable(v)
            if mt and mt.__index then
                local ok, check = pcall(function() return mt.__index(v, "canUse") end)
                if ok and check then
                    cooldownFunc = v
                    break
                end
            end
        end
    end

    if cooldownFunc then
        local mt = getrawmetatable(cooldownFunc)
        if mt and mt.__index then
            local old = mt.__index
            CooldownBypassState.MT = mt
            CooldownBypassState.OriginalIndex = old

            mt.__index = newcclosure(function(t, k)
                if Killer.BypassCooldown then
                    if k == "canUse" then return true end
                    if k == "Cooldown" then return 0 end
                end
                return old(t, k)
            end)
        end
    end
end

local function FV_NormalizeAnimationId(id)
    return tostring(id or ""):match("%d+")
end

local function FV_Disconnect()
    for _, key in ipairs({"Connection", "CharacterConnection", "VaultStateConnection", "DescendantConnection", "StateConnection", "SyncConnection"}) do
        local conn = FastVault[key]
        if conn then
            pcall(function() conn:Disconnect() end)
            ForgetConnection(conn)
            FastVault[key] = nil
        end
    end
    for track, originalSpeed in pairs(FastVault.BoostedTracks) do
        pcall(function() track:AdjustSpeed(tonumber(originalSpeed) or 1) end)
        FastVault.BoostedTracks[track] = nil
    end
    FastVault.VaultWindowUntil = 0
    FastVault.WindowJumpUntil = 0
    FastVault.LastAnimator = nil
    FastVault.LastCharacter = nil
end

local function FV_IsVaulting(char)
    if not char then return false end
    local interact = char:FindFirstChild("CheckInterractable", true)
    if not interact then return false end

    local ok, result = pcall(function()
        return interact:GetAttribute("isVaulting") == true
            or interact:GetAttribute("IsVaulting") == true
    end)
    return ok and result == true
end

local function FV_IsLikelyVaultTrack(track, char)
    if not track then return false end

    local anim = track.Animation
    local animId = anim and FV_NormalizeAnimationId(anim.AnimationId) or nil
    if animId and FastVault.KnownVaultIds[animId] then
        return true
    end

    local animName = ""
    pcall(function()
        animName = string.lower((anim and anim.Name) or track.Name or "")
    end)

    if animName:find("vault", 1, true)
        or animName:find("finesse", 1, true)
        or animName:find("window", 1, true) then
        return true
    end

    -- Window vaults often switch to a separate jump/leap animation after
    -- the main vault animation. Only treat those as vault tracks during
    -- the short window-jump phase, so normal jumping is untouched.
    if os.clock() <= FastVault.WindowJumpUntil then
        if animName:find("jump", 1, true)
            or animName:find("leap", 1, true)
            or animName:find("climb", 1, true)
            or animName:find("land", 1, true) then
            return true
        end
    end

    -- Most reliable fallback after game updates:
    -- while CheckInterractable says we're vaulting, boost the action track that starts.
    if FV_IsVaulting(char)
        or os.clock() <= FastVault.VaultWindowUntil
        or os.clock() <= FastVault.WindowJumpUntil then
        local priority = track.Priority
        return priority == Enum.AnimationPriority.Action
            or priority == Enum.AnimationPriority.Action2
            or priority == Enum.AnimationPriority.Action3
            or priority == Enum.AnimationPriority.Action4
            or priority == Enum.AnimationPriority.Movement
    end

    return false
end

local function FV_BoostTrack(track, char)
    if not FastVault.Enabled or not track or not FV_IsLikelyVaultTrack(track, char) then
        return
    end

    pcall(function()
        if FastVault.BoostedTracks[track] == nil then
            local original = 1
            pcall(function() original = track.Speed end)
            FastVault.BoostedTracks[track] = tonumber(original) or 1
        end
        track:AdjustSpeed(FastVault.Speed)
    end)
end

local function FV_BoostCurrentlyPlaying(animator, char)
    if not animator then return end
    local ok, tracks = pcall(function()
        return animator:GetPlayingAnimationTracks()
    end)
    if not ok or not tracks then return end

    for _, track in ipairs(tracks) do
        FV_BoostTrack(track, char)
    end
end

local function FV_StartAnimationSync(animator, char)
    if not FastVault.Enabled or not animator or not char then return end

    FastVault.LastAnimator = animator
    FastVault.LastCharacter = char

    if FastVault.SyncConnection then
        pcall(function() FastVault.SyncConnection:Disconnect() end)
        FastVault.SyncConnection = nil
    end

    local accumulator = 0

    -- Temporary sync only while a vault/window phase is active.
    -- Some game scripts call AdjustSpeed(1) again after AnimationPlayed;
    -- this reapplies the selected speed so the animation stays matched.
    FastVault.SyncConnection = RunService.Heartbeat:Connect(function(dt)
        if not FastVault.Enabled
            or not char.Parent
            or os.clock() > math.max(FastVault.VaultWindowUntil, FastVault.WindowJumpUntil) then

            if FastVault.SyncConnection then
                pcall(function() FastVault.SyncConnection:Disconnect() end)
                FastVault.SyncConnection = nil
            end
            return
        end

        accumulator = accumulator + dt
        if accumulator < 0.045 then return end
        accumulator = 0

        FV_BoostCurrentlyPlaying(animator, char)
    end)
end

local function FV_AttachVaultState(char, animator, interact)
    if FastVault.VaultStateConnection then
        pcall(function() FastVault.VaultStateConnection:Disconnect() end)
        FastVault.VaultStateConnection = nil
    end
    if not interact then return end

    local function onVaultState()
        if not FastVault.Enabled then return end

        local vaulting = false
        pcall(function()
            vaulting = interact:GetAttribute("isVaulting") == true
                or interact:GetAttribute("IsVaulting") == true
        end)

        if vaulting then
            -- short event window catches AnimationPlayed even if attribute/animation
            -- ordering changes between game versions.
            local now = os.clock()
            FastVault.VaultWindowUntil = now + 1.35
            FastVault.WindowJumpUntil = now + 2.10
            FV_StartAnimationSync(animator, char)

            task.defer(function()
                if FastVault.Enabled then
                    FV_BoostCurrentlyPlaying(animator, char)
                end
            end)
        end
    end

    FastVault.VaultStateConnection = interact:GetAttributeChangedSignal("isVaulting"):Connect(onVaultState)

    -- Some builds may use capitalized attribute.
    pcall(function()
        local second = interact:GetAttributeChangedSignal("IsVaulting"):Connect(onVaultState)
        -- keep secondary connection tied to character lifecycle through DescendantConnection cleanup
        local oldDesc = FastVault.DescendantConnection
        FastVault.DescendantConnection = {
            Disconnect = function()
                pcall(function() second:Disconnect() end)
                if oldDesc and type(oldDesc.Disconnect) == "function" then
                    pcall(function() oldDesc:Disconnect() end)
                end
            end
        }
    end)

    onVaultState()
end

local function FV_BindCharacter(char)
    if not FastVault.Enabled or not char then return end

    if FastVault.Connection then
        pcall(function() FastVault.Connection:Disconnect() end)
        FastVault.Connection = nil
    end
    if FastVault.VaultStateConnection then
        pcall(function() FastVault.VaultStateConnection:Disconnect() end)
        FastVault.VaultStateConnection = nil
    end
    if FastVault.DescendantConnection and type(FastVault.DescendantConnection.Disconnect) == "function" then
        pcall(function() FastVault.DescendantConnection:Disconnect() end)
        FastVault.DescendantConnection = nil
    end
    if FastVault.StateConnection then
        pcall(function() FastVault.StateConnection:Disconnect() end)
        FastVault.StateConnection = nil
    end

    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5)
    if not animator then return end

    FastVault.LastAnimator = animator
    FastVault.LastCharacter = char

    FastVault.Connection = animator.AnimationPlayed:Connect(function(track)
        if not FastVault.Enabled then return end

        -- If vault attribute is already active, open both main-vault and
        -- follow-up window-jump phases immediately.
        if FV_IsVaulting(char) then
            local now = os.clock()
            FastVault.VaultWindowUntil = now + 1.35
            FastVault.WindowJumpUntil = now + 2.10
            FV_StartAnimationSync(animator, char)
        end

        FV_BoostTrack(track, char)
    end)

    -- Catch the separate jump/freefall phase used by some window vaults.
    -- This does NOT affect normal jumps because it only runs inside
    -- WindowJumpUntil opened by an actual vault state.
    FastVault.StateConnection = hum.StateChanged:Connect(function(_, newState)
        if not FastVault.Enabled or os.clock() > FastVault.WindowJumpUntil then
            return
        end

        if newState == Enum.HumanoidStateType.Jumping
            or newState == Enum.HumanoidStateType.Freefall
            or newState == Enum.HumanoidStateType.Landed then

            -- Extend briefly so a late-starting jump/landing track also gets boosted.
            FastVault.WindowJumpUntil = math.max(FastVault.WindowJumpUntil, os.clock() + 0.80)
            FV_StartAnimationSync(animator, char)

            task.defer(function()
                if FastVault.Enabled then
                    FV_BoostCurrentlyPlaying(animator, char)
                end
            end)
        end
    end)

    local interact = char:FindFirstChild("CheckInterractable", true)
    if interact then
        FV_AttachVaultState(char, animator, interact)
    else
        -- Don't scan every frame. Wait only for the object to appear.
        FastVault.DescendantConnection = char.DescendantAdded:Connect(function(obj)
            if not FastVault.Enabled then return end
            if obj.Name == "CheckInterractable" then
                FV_AttachVaultState(char, animator, obj)
            end
        end)
    end
end

function toggleFastVault(state)
    FastVault.Enabled = state == true

    if FastVault.CharacterConnection then
        pcall(function() FastVault.CharacterConnection:Disconnect() end)
        FastVault.CharacterConnection = nil
    end

    if not FastVault.Enabled then
        FV_Disconnect()
        return
    end

    if LocalPlayer.Character then
        task.defer(FV_BindCharacter, LocalPlayer.Character)
    end

    FastVault.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        if not FastVault.Enabled then return end
        task.wait(0.35)
        if FastVault.Enabled then
            FV_BindCharacter(char)
        end
    end)
end


-- ============== EXPERIMENTAL TOOL ASSIST (LOW OVERHEAD) ==============

local function getCurrentToFFireRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local tof = items and items:FindFirstChild("Twist of Fate")
    local fire = tof and tof:FindFirstChild("Fire")
    return fire
end

local function isToFTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n = string.lower(tool.Name)
    return n:find("twist", 1, true) ~= nil and n:find("fate", 1, true) ~= nil
end

local function getToolMuzzle(tool)
    if not tool then return nil end

    local muzzle = tool:FindFirstChild("Muzzle", true)
    if muzzle then
        if muzzle:IsA("BasePart") then return muzzle end
        if muzzle:IsA("Attachment") and muzzle.Parent and muzzle.Parent:IsA("BasePart") then
            return muzzle.Parent
        end
    end

    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle end

    return tool:FindFirstChildWhichIsA("BasePart", true)
end

local function getNetworkPingSeconds()
    local seconds = 0
    pcall(function()
        local network = Stats:FindFirstChild("Network")
        local serverStats = network and network:FindFirstChild("ServerStatsItem")
        local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
        if dataPing and type(dataPing.GetValue) == "function" then
            seconds = math.clamp((tonumber(dataPing:GetValue()) or 0) / 1000, 0, 0.35)
        end
    end)
    return seconds
end

local function getAimAssistTarget(origin)
    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    if not cam or not myChar or not origin then return nil end

    local viewport = cam.ViewportSize
    local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    local bestPart, bestScreenDist, bestWorldDist = nil, math.huge, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local role = p:GetAttribute("Role")
                local teamName = p.Team and string.lower(p.Team.Name) or ""
                local isKiller = teamName:find("killer", 1, true) ~= nil or role == "Killer"
                local isSurvivor = teamName:find("survivor", 1, true) ~= nil or role == "Survivor"
                local validTarget = (ToolAimAssist.TargetMode == "Killer" and isKiller)
                    or (ToolAimAssist.TargetMode == "Survivor" and isSurvivor)

                if validTarget then
                    local part = p.Character:FindFirstChild(ToolAimAssist.TargetPart, true)
                        or p.Character:FindFirstChild("HumanoidRootPart", true)
                        or p.Character:FindFirstChild("Head", true)

                    if part and part:IsA("BasePart") then
                        local delta = part.Position - origin
                        local worldDist = delta.Magnitude

                        if worldDist <= ToolAimAssist.Range then
                            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                            if onScreen and screenPos.Z > 0 then
                                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                                local fovPass = (not ToolAimAssist.UseFOV)
                                    or screenDist <= ToolAimAssist.FOV

                                local betterTarget
                                if ToolAimAssist.UseFOV then
                                    betterTarget = screenDist < bestScreenDist
                                        or (math.abs(screenDist - bestScreenDist) < 0.01 and worldDist < bestWorldDist)
                                else
                                    -- FOV OFF: target the nearest visible player from the selected team
                                    -- anywhere on screen, still respecting Range + Wall Check.
                                    betterTarget = worldDist < bestWorldDist
                                end

                                if fovPass and betterTarget then
                                    local visible = true
                                    if ToolAimAssist.WallCheck then
                                        local params = RaycastParams.new()
                                        params.FilterType = Enum.RaycastFilterType.Exclude
                                        params.FilterDescendantsInstances = {myChar}
                                        params.IgnoreWater = true
                                        local hit = workspace:Raycast(origin, delta, params)
                                        visible = not hit or hit.Instance:IsDescendantOf(p.Character)
                                    end

                                    if visible then
                                        bestPart = part
                                        bestScreenDist = screenDist
                                        bestWorldDist = worldDist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPart, bestWorldDist
end

local function getPredictedAimPosition(part, origin, distance)
    if not part then return nil end

    local pos = part.Position
    if not ToolAimAssist.Prediction then
        return pos
    end

    local velocity = Vector3.zero
    pcall(function()
        velocity = part.AssemblyLinearVelocity
    end)

    -- Hindari spike velocity/ragdoll bikin prediction ngawur.
    if velocity.Magnitude > 120 then
        velocity = velocity.Unit * 120
    end

    local bulletSpeed = math.max(ToolAimAssist.BulletSpeed, 1)
    local travelTime = (distance or (pos - origin).Magnitude) / bulletSpeed

    -- Kompensasi setengah RTT supaya tidak over-lead terlalu parah.
    local pingComp = getNetworkPingSeconds() * 0.5
    local leadTime = math.clamp((travelTime + pingComp) * ToolAimAssist.PredictionScale, 0, 1.25)

    return pos + velocity * leadTime
end

local function showToolAimTracer(fromPos, toPos)
    if not ToolAimAssist.Tracer or not fromPos or not toPos then return end

    local tracer = ToolAimAssist.TracerPart
    if not tracer or not tracer.Parent then
        tracer = TrackArtifact(Instance.new("Part"))
        tracer.Name = "BluehavenToolAssistTracer"
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.CanTouch = false
        tracer.CanQuery = false
        tracer.CastShadow = false
        tracer.Material = Enum.Material.Neon
        tracer.Color = Color3.fromRGB(255, 110, 20)
        tracer.Transparency = 1
        tracer.Size = Vector3.new(0.06, 0.06, 1)
        tracer.Parent = workspace
        ToolAimAssist.TracerPart = tracer
    end

    local delta = toPos - fromPos
    local length = delta.Magnitude
    if length <= 0.01 then return end

    tracer.Size = Vector3.new(0.06, 0.06, length)
    tracer.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -length * 0.5)
    tracer.Transparency = 0.2

    local thisTracer = tracer
    task.delay(0.07, function()
        if thisTracer and thisTracer.Parent then
            thisTracer.Transparency = 1
        end
    end)
end

rewriteToFFireArgs = function(args)
    if not ToolAimAssist.Enabled or not args then return nil end

    local vectorIndex = nil
    for i = 1, (args.n or #args) do
        if typeof(args[i]) == "Vector3" then
            vectorIndex = i
            break
        end
    end
    if not vectorIndex then return nil end

    local origin = nil
    local first = args[1]
    if typeof(first) == "Instance" then
        if first:IsA("BasePart") then
            origin = first.Position
        elseif first:IsA("Attachment") then
            origin = first.WorldPosition
        elseif first:IsA("Model") then
            local okPivot, pivot = pcall(function() return first:GetPivot() end)
            if okPivot then origin = pivot.Position end
        end
    end

    if not origin then
        local char = LocalPlayer.Character
        local equipped = char and char:FindFirstChildOfClass("Tool")
        local muzzle = equipped and getToolMuzzle(equipped)
        local root = char and char:FindFirstChild("HumanoidRootPart")
        origin = muzzle and muzzle.Position or (root and root.Position)
    end
    if not origin then return nil end

    local targetPart, distance = getAimAssistTarget(origin)
    if not targetPart then
        ToolAimAssist.LastTarget = nil
        return nil
    end

    local targetPos = getPredictedAimPosition(targetPart, origin, distance)
    if not targetPos then return nil end

    local direction = targetPos - origin
    if direction.Magnitude <= 0.01 then return nil end

    ToolAimAssist.LastTarget = targetPart
    args[vectorIndex] = direction.Unit
    showToolAimTracer(origin, targetPos)
    return args
end

local function onToFToolActivated(tool)
    if not ToolAimAssist.Enabled then return end

    local muzzle = getToolMuzzle(tool)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local origin = muzzle and muzzle.Position or (root and root.Position)
    if not origin then return end

    local targetPart, distance = getAimAssistTarget(origin)
    if not targetPart then
        ToolAimAssist.LastTarget = nil
        return
    end

    ToolAimAssist.LastTarget = targetPart
    local targetPos = getPredictedAimPosition(targetPart, origin, distance)
    if not targetPos then return end

    -- Preview only. The actual shot direction is rewritten inside
    -- the game's own FireServer call, so one click stays one shot.
    showToolAimTracer(origin, targetPos)
end

local function bindToolAimAssist(tool)
    if not isToFTool(tool) or ToolAimAssist.ToolConnections[tool] then return end

    ToolAimAssist.ToolConnections[tool] = TrackConnection(tool.Activated:Connect(function()
        if HubRuntime.Alive then onToFToolActivated(tool) end
    end))

    TrackConnection(tool.AncestryChanged:Connect(function(_, parent)
        if not parent then
            local conn = ToolAimAssist.ToolConnections[tool]
            if conn then
                pcall(function() conn:Disconnect() end)
            end
            ForgetConnection(conn)
            ToolAimAssist.ToolConnections[tool] = nil
        end
    end))
end

local function scanAimAssistTools()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    if char then
        for _, obj in ipairs(char:GetChildren()) do
            bindToolAimAssist(obj)
        end
    end

    if backpack then
        for _, obj in ipairs(backpack:GetChildren()) do
            bindToolAimAssist(obj)
        end
    end
end

local function setupToolAimAssistListeners()
    if ToolAimAssist.CharacterConn then
        pcall(function() ToolAimAssist.CharacterConn:Disconnect() end)
    end
    if ToolAimAssist.BackpackConn then
        pcall(function() ToolAimAssist.BackpackConn:Disconnect() end)
    end

    local char = LocalPlayer.Character
    if char then
        ToolAimAssist.CharacterConn = char.ChildAdded:Connect(bindToolAimAssist)
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        ToolAimAssist.BackpackConn = backpack.ChildAdded:Connect(bindToolAimAssist)
    end

    scanAimAssistTools()
end

-- No permanent Tool.Activated listeners are started automatically.
-- Silent Aim uses the actual ToF remote call through the reversible namecall hook.


-- ============== UI SETUP =================

-- ============= PLAYER TAB =============
-- TELEPORT TOOLS
AbilityTab:AddButton({
    Text = "Teleport Generator",
    Func = TeleportToGenerator,
    Desc = "Teleport ke generator"
})
AbilityTab:AddButton({
    Text = "Teleport Hook",
    Func = TeleportToHook,
    Desc = "Teleport ke hook"
})
AbilityTab:AddButton({
    Text = "Teleport Gate",
    Func = TeleportToGate,
    Desc = "Teleport ke gate"
})
AbilityTab:AddButton({
    Text = "Teleport Pallet",
    Func = TeleportToPallet,
    Desc = "Teleport ke pallet"
})
AbilityTab:AddButton({
    Text = "Teleport Window",
    Func = TeleportToWindow,
    Desc = "Teleport ke window"
})
AbilityTab:AddButton({
    Text = "Refresh Map Cache",
    Func = RefreshMapForTeleport,
    Desc = "Refresh semua cache map"
})
AbilityTab:AddDivider()

-- KILLER TAB
KillerTab:AddToggle("Bypass Cooldown", {
    Default = false,
    Text = "Bypass Cooldown",
    Callback = function(v)
        Killer.BypassCooldown = v
        toggleBypassCooldown(v)
    end
})
KillerTab:AddToggle("Bypass Leap", {
    Default = false,
    Text = "Bypass Leap",
    Callback = function(v)
        Killer.BypassLeap = v
        if v then StartLeapBypass() else StopLeapBypass() end
    end
})
KillerTab:AddToggle("Third Person", {
    Default = false,
    Text = "Third Person",
    Tooltip = "Killer only.",
    Callback = function(v)
        if v and GetRole() ~= "Killer" then
            Killer.ThirdPerson = false

            -- Autoload may contain Third Person = true while we are Survivor/
            -- Spectator. Refuse it without touching the live camera.
            task.defer(function()
                local toggle = Toggles["Third Person"]
                if toggle and toggle.Value then
                    toggle:SetValue(false)
                end
            end)
            return
        end

        Killer.ThirdPerson = v

        if v then
            local cam = workspace.CurrentCamera
            if not cam then return end

            if not Killer.ThirdPersonWasActive then
                Killer.OriginalCameraType = cam.CameraType
                Killer.OriginalCameraMode = LocalPlayer.CameraMode
                Killer.OriginalMinZoom = LocalPlayer.CameraMinZoomDistance
                Killer.OriginalMaxZoom = LocalPlayer.CameraMaxZoomDistance
                Killer.ThirdPersonWasActive = true
            end

            cam.CameraType = Enum.CameraType.Custom
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 6
            LocalPlayer.CameraMaxZoomDistance = math.max(12, Killer.OriginalMaxZoom or 12)
            return
        end

        -- OFF must be a no-op if Bluehaven never enabled Third Person.
        -- This prevents autoload/default callbacks from overwriting VD camera.
        if Killer.ThirdPersonWasActive then
            local cam = workspace.CurrentCamera

            if cam and Killer.OriginalCameraType ~= nil then
                cam.CameraType = Killer.OriginalCameraType
            end

            if Killer.OriginalCameraMode ~= nil then
                LocalPlayer.CameraMode = Killer.OriginalCameraMode
            end

            if not CameraZoom.UnlimitedZoom then
                if Killer.OriginalMinZoom ~= nil then
                    LocalPlayer.CameraMinZoomDistance = Killer.OriginalMinZoom
                end
                if Killer.OriginalMaxZoom ~= nil then
                    LocalPlayer.CameraMaxZoomDistance = Killer.OriginalMaxZoom
                end
            end

            Killer.ThirdPersonWasActive = false
            Killer.OriginalCameraType = nil
            Killer.OriginalCameraMode = nil
            Killer.OriginalMinZoom = nil
            Killer.OriginalMaxZoom = nil
        end
    end
})
KillerTab:AddDivider()
KillerTab:AddToggle("Kill All (Killer)", {
    Default = false,
    Text = "Kill All Players",
    Callback = function(v)
        Killer.KillAll = v
    end
})
KillerTab:AddInput("Kill Range", {
    Text = "Kill Range",
    Default = "500",
    Numeric = true,
    Finished = false,
    Callback = function(v)
        Killer.KillRange = tonumber(v) or 500
    end
})
KillerTab:AddToggle("Anti Blind (Killer)", {
    Default = false,
    Text = "Anti Blind",
    Callback = function(v)
        Killer.AntiBlind = v
        if v then installMainNamecallHook() end
    end
})
KillerTab:AddToggle("Block Vaults", {
    Default = false,
    Text = "Block Vault",
    Callback = function(v)
        Killer.BlockVaults = v
        if v then installMainNamecallHook() end
    end
})

-- ============== SURVIVOR FEATURES ==============
ParryBox:AddToggle("Auto Parry", {
    Default = false,
    Text = "Auto Parry",
    Callback = function(v)
        Config.Surv_AutoParry = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsKiller(p) and p.Character then
                    AttachParrySensor(p.Character)
                end
            end
        end
    end
})
ParryBox:AddToggle("Parry Safety", {
    Default = false,
    Text = "Parry Safety",
    Tooltip = "Tidak parry saat vault atau repair.",
    Callback = function(v)
        Config.Surv_ParrySafety = v
    end
})
ParryBox:AddLabel("No parry during vault / repair.", true)
ParryBox:AddToggle("Aggressive Parry", {
    Default = false,
    Text = "Aggressive Parry",
    Tooltip = "Parry saat serangan masuk jarak dekat.",
    Callback = function(v)
        Config.Surv_ParryAggressive = v
    end
})
ParryBox:AddToggle("Auto Crouch (Abyssal S1)", {
    Default = false,
    Text = "Abyssal Auto Crouch",
    Tooltip = "Jongkok hanya jika Abyssal dekat.",
    Callback = function(v)
        Config.Surv_AutoCrouch = v
    end
})
ParryBox:AddLabel("Uses the Parry Distance below.", true)
ParryBox:AddSlider("Parry Distance", {
    Text = "Parry Distance",
    Default = 15,
    Min = 5,
    Max = 30,
    Callback = function(v)
        Config.Surv_ParryRadius = v
    end
})
ParryBox:AddSlider("Parry Face Sensitivity", {
    Text = "Facing Sensitivity",
    Tooltip = "Semakin tinggi, arah hadap makin ketat.",
    Default = 0.7,
    Min = 0.1,
    Max = 1,
    Decimal = true,
    Callback = function(v)
        Config.Surv_ParryFace = v
    end
})

-- AUTO SKILLCHECK
-- Legit:
--   Presses normal input anywhere inside the known perfect window.
-- Instant:
--   Still uses the game's REAL rotating line, but fires with zero added delay
--   only on the lower edge of the small success box. No guessed result remote.
local SkillCheckWatcher = {
    Prompt = nil,
    LineConn = nil,
    VisibleConn = nil,
    DescConn = nil,
    Busy = false,
    Fired = false,
    BindSerial = 0,
}

local function SC_Disconnect(conn)
    if conn then
        pcall(function() conn:Disconnect() end)
    end
end

local function SC_StopLineWatch()
    if SkillCheckWatcher.LineConn then
        SC_Disconnect(SkillCheckWatcher.LineConn)
        SkillCheckWatcher.LineConn = nil
    end
end

local function SC_ResetPromptState()
    SkillCheckWatcher.Busy = false
    SkillCheckWatcher.Fired = false
end

local function SC_Stop()
    SkillCheckWatcher.BindSerial = SkillCheckWatcher.BindSerial + 1

    SC_StopLineWatch()
    SC_Disconnect(SkillCheckWatcher.VisibleConn)
    SC_Disconnect(SkillCheckWatcher.DescConn)

    SkillCheckWatcher.VisibleConn = nil
    SkillCheckWatcher.DescConn = nil
    SkillCheckWatcher.Prompt = nil
    SC_ResetPromptState()
    Connections.SkillHeartbeat = nil
end

local function SC_Press()
    if UserInputService.TouchEnabled then
        local current = PlayerGui

        for segment in string.gmatch("Survivor-mob.Controls.action.check", "[^%.]+") do
            current = current and current:FindFirstChild(segment)
        end

        if current and current:IsA("GuiObject") then
            local inset = game:GetService("GuiService"):GetGuiInset()
            local pos = current.AbsolutePosition
            local size = current.AbsoluteSize
            local x = pos.X + size.X * 0.5 + inset.X
            local y = pos.Y + size.Y * 0.5 + inset.Y

            pcall(function()
                VirtualInputManager:SendTouchEvent(8822, 0, x, y)
                task.wait(0.008)
                VirtualInputManager:SendTouchEvent(8822, 2, x, y)
            end)
            return
        end
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.008)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function SC_IsInsideArc(lineRotation, goalRotation, offsetStart, offsetEnd)
    local lr = (lineRotation or 0) % 360
    local gr = (goalRotation or 0) % 360

    local startRange = (gr + offsetStart) % 360
    local endRange = (gr + offsetEnd) % 360

    if startRange > endRange then
        return lr >= startRange or lr <= endRange
    end

    return lr >= startRange and lr <= endRange
end

local function SC_IsInsideLegitGoal(line, goal)
    -- Full known perfect window.
    return SC_IsInsideArc(line.Rotation, goal.Rotation, 104, 114)
end

local function SC_IsInsideInstantEdge(line, goal)
    -- Lower edge of the small box, slightly inset so exact boundary rounding
    -- does not miss. This is the REAL moving line, not a visual fake snap.
    return SC_IsInsideArc(line.Rotation, goal.Rotation, 111, 114)
end

local function SC_StartLineWatch(check, line, goal)
    SC_StopLineWatch()

    if not Auto.SkillCheck
        or not check
        or not check.Parent
        or not check.Visible
        or not line
        or not line.Parent
        or not goal
        or not goal.Parent then
        return
    end

    SkillCheckWatcher.LineConn = RunService.RenderStepped:Connect(function()
        if not Auto.SkillCheck
            or not check.Parent
            or not check.Visible
            or not line.Parent
            or not goal.Parent then

            SC_StopLineWatch()
            return
        end

        if SkillCheckWatcher.Busy or SkillCheckWatcher.Fired then
            return
        end

        local shouldPress
        if Auto.SkillCheckMode == "Instant" then
            shouldPress = SC_IsInsideInstantEdge(line, goal)
        else
            shouldPress = SC_IsInsideLegitGoal(line, goal)
        end

        if not shouldPress then return end

        SkillCheckWatcher.Busy = true
        SkillCheckWatcher.Fired = true

        -- Normal game input only. No SkillCheckResultEvent guessing.
        SC_Press()

        SkillCheckWatcher.Busy = false
        SC_StopLineWatch()
    end)
end

local function SC_BindPrompt(prompt)
    if not Auto.SkillCheck or not prompt or not prompt.Parent then return end

    SkillCheckWatcher.BindSerial = SkillCheckWatcher.BindSerial + 1
    local serial = SkillCheckWatcher.BindSerial

    SC_StopLineWatch()
    SC_Disconnect(SkillCheckWatcher.VisibleConn)
    SkillCheckWatcher.VisibleConn = nil
    SkillCheckWatcher.Prompt = prompt
    SC_ResetPromptState()

    task.defer(function()
        if serial ~= SkillCheckWatcher.BindSerial then return end
        if not Auto.SkillCheck or not prompt.Parent then return end

        local check = prompt:FindFirstChild("Check") or prompt:WaitForChild("Check", 1.5)
        if not check then return end

        local line = check:FindFirstChild("Line") or check:WaitForChild("Line", 1.5)
        local goal = check:FindFirstChild("Goal") or check:WaitForChild("Goal", 1.5)
        if not line or not goal then return end
        if serial ~= SkillCheckWatcher.BindSerial then return end

        SkillCheckWatcher.VisibleConn = check:GetPropertyChangedSignal("Visible"):Connect(function()
            if serial ~= SkillCheckWatcher.BindSerial then return end

            if not check.Visible then
                SC_StopLineWatch()
                SC_ResetPromptState()
                return
            end

            SC_ResetPromptState()
            SC_StartLineWatch(check, line, goal)
        end)

        if check.Visible then
            SC_StartLineWatch(check, line, goal)
        end
    end)
end

local function SC_Start()
    SC_Stop()
    Auto.SkillCheck = true

    local existing = PlayerGui:FindFirstChild("SkillCheckPromptGui")
    if existing then
        SC_BindPrompt(existing)
    end

    SkillCheckWatcher.DescConn = PlayerGui.DescendantAdded:Connect(function(obj)
        if not Auto.SkillCheck then return end

        if obj.Name == "SkillCheckPromptGui" then
            SC_BindPrompt(obj)
            return
        end

        if obj.Name == "Check" or obj.Name == "Line" or obj.Name == "Goal" then
            local ancestor = obj

            while ancestor and ancestor ~= PlayerGui do
                if ancestor.Name == "SkillCheckPromptGui" then
                    if SkillCheckWatcher.Prompt ~= ancestor
                        or not SkillCheckWatcher.VisibleConn then
                        SC_BindPrompt(ancestor)
                    end
                    break
                end

                ancestor = ancestor.Parent
            end
        end
    end)

    Connections.SkillHeartbeat = SkillCheckWatcher.DescConn
end

AbilityTab:AddToggle("Auto Skillcheck", {
    Default = false,
    Text = "Auto Skillcheck",
    Callback = function(v)
        Auto.SkillCheck = v

        if v then
            SC_Start()
        else
            SC_Stop()
        end
    end
})

AbilityTab:AddDropdown("Skillcheck Mode", {
    Default = "Legit",
    Values = {"Legit", "Instant"},
    Callback = function(v)
        Auto.SkillCheckMode = v
        SC_ResetPromptState()

        if Auto.SkillCheck
            and SkillCheckWatcher.Prompt
            and SkillCheckWatcher.Prompt.Parent then

            local prompt = SkillCheckWatcher.Prompt
            SkillCheckWatcher.Prompt = nil
            SC_BindPrompt(prompt)
        end
    end
})

-- FAST VAULT
AbilityTab:AddToggle("Fast Vault", {
    Default = false,
    Text = "Fast Vault + Window",
    Callback = function(v)
        FastVault.Enabled = v
        toggleFastVault(v)
    end
})
AbilityTab:AddSlider("Fast Vault Speed", {
    Text = "Vault Speed",
    Default = FastVault.Speed,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(v)
        FastVault.Speed = v

        if FastVault.Enabled and FastVault.LastAnimator and FastVault.LastCharacter then
            pcall(function()
                FV_BoostCurrentlyPlaying(FastVault.LastAnimator, FastVault.LastCharacter)
            end)
        end
    end
})
AbilityTab:AddLabel("Speeds vault movement + animation.", true)

-- GEN BYPASS
AbilityTab:AddToggle("Gen Bypass", {
    Default = false,
    Text = "Gen Bypass",
    Callback = function(v)
        setGenBypass(v)
        Library:Notify({
            Title = "Gen Bypass",
            Description = v and "Enabled! Click button on screen or press G" or "Disabled",
            Time = 2
        })
    end
})

-- ============== AIM / TOF ==============
-- Heavy Silent Aim hook tetap tidak dipakai karena versi itu yang bikin stutter.
-- AimBot sekarang memakai lightweight Tool.Activated assist yang sudah ada.
SilentAim.Enabled = false
ToFAimConfig.Enabled = false

AimlockBox:AddToggle("Light Aim Assist", {
    Default = false,
    Text = "Silent Aim (Light)",
    Tooltip = "Target scan hanya saat Twist of Fate menembak; target team bisa Killer / Survivor.",
    Callback = function(v)
        ToolAimAssist.Enabled = v
        if v then
            ToFFireRemote = getCurrentToFFireRemote() or ToFFireRemote
            installMainNamecallHook()
        end
        updateAimFOVVisual()

        -- Sync toggle yang sama di Twist of Fate bila ada.
        pcall(function()
            if Toggles["Experimental Tool Assist"]
                and Toggles["Experimental Tool Assist"].Value ~= v then
                Toggles["Experimental Tool Assist"]:SetValue(v)
            end
        end)
    end
})

AimlockBox:AddLabel("Light mode: only selected player team")

AimlockBox:AddDropdown("Light Aim Target Team", {
    Default = "Killer",
    Values = {"Killer", "Survivor"},
    Text = "Target Team",
    Callback = function(v)
        ToolAimAssist.TargetMode = v
        SilentAim.TargetMode = v
    end
})

AimlockBox:AddDropdown("Light Aim Target Part", {
    Default = "HumanoidRootPart",
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Text = "Aim Part",
    Callback = function(v)
        ToolAimAssist.TargetPart = v
        SilentAim.TargetPart = v
    end
})

ToFBox:AddToggle("Experimental Tool Assist", {
    Default = false,
    Text = "ToF Aim Assist",
    Tooltip = "Arahkan ToF ke team pilihan.",
    Callback = function(v)
        ToolAimAssist.Enabled = v
        if v then
            ToFFireRemote = getCurrentToFFireRemote() or ToFFireRemote
            installMainNamecallHook()
        end
        updateAimFOVVisual()

        pcall(function()
            if Toggles["Light Aim Assist"]
                and Toggles["Light Aim Assist"].Value ~= v then
                Toggles["Light Aim Assist"]:SetValue(v)
            end
        end)
    end
})

ToFBox:AddToggle("Tool Assist Prediction", {
    Default = true,
    Text = "Prediction",
    Callback = function(v)
        ToolAimAssist.Prediction = v
    end
})

ToFBox:AddToggle("Tool Assist Tracer", {
    Default = true,
    Text = "Orange Tracer",
    Callback = function(v)
        ToolAimAssist.Tracer = v
        if not v and ToolAimAssist.TracerPart then
            ToolAimAssist.TracerPart.Transparency = 1
        end
    end
})

ToFBox:AddToggle("Tool Assist Wall Check", {
    Default = true,
    Text = "Wall Check",
    Callback = function(v)
        ToolAimAssist.WallCheck = v
    end
})

ToFBox:AddToggle("Tool Assist Use FOV", {
    Default = true,
    Text = "Use FOV Limit",
    Tooltip = "ON: dalam FOV. OFF: target terdekat.",
    Callback = function(v)
        ToolAimAssist.UseFOV = v
        updateAimFOVVisual()
    end
}):AddColorPicker("ToolAimFOVColor", {
    Default = ToolAimAssist.FOVColor,
    Title = "FOV Color",
    Callback = function(v)
        ToolAimAssist.FOVColor = v
        updateAimFOVVisual()
    end
})

ToFBox:AddSlider("Tool Assist FOV", {
    Text = "FOV",
    Default = 110,
    Min = 40,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        ToolAimAssist.FOV = v
        updateAimFOVVisual()
    end
})

ToFBox:AddSlider("Tool Assist Range", {
    Text = "Range",
    Default = 180,
    Min = 30,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        ToolAimAssist.Range = v
    end
})

ToFBox:AddSlider("Tool Bullet Speed", {
    Text = "Bullet Speed",
    Default = 200,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(v)
        ToolAimAssist.BulletSpeed = v
    end
})

ToFBox:AddSlider("Prediction Scale", {
    Text = "Prediction Scale",
    Default = 1,
    Min = 0.5,
    Max = 1.8,
    Rounding = 2,
    Callback = function(v)
        ToolAimAssist.PredictionScale = v
    end
})

ToFBox:AddLabel("No getgc / no per-frame target scan")

-- ============== CROSSHAIR ==============
CrosshairBox:AddToggle("Crosshair", {
    Default = false,
    Text = "Crosshair",
    Callback = function(v)
        Crosshair.Enabled = v
        updateCrosshairGui()
    end
})
CrosshairBox:AddDropdown("Crosshair Style", {
    Default = "Plus",
    Values = {"Plus", "Dot", "Circle"},
    Callback = function(v)
        Crosshair.Style = v
        updateCrosshairGui()
    end
})
CrosshairBox:AddLabel("Crosshair Color"):AddColorPicker("CrosshairColorPicker", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v)
        Crosshair.Color = v
        updateCrosshairGui()
    end
})
CrosshairBox:AddSlider("Crosshair Size", {
    Text = "Crosshair Size",
    Default = 8,
    Min = 2,
    Max = 20,
    Callback = function(v)
        Crosshair.Size = v
        updateCrosshairGui()
    end
})
CrosshairBox:AddSlider("Crosshair Thickness", {
    Text = "Crosshair Thickness",
    Default = 2,
    Min = 1,
    Max = 5,
    Callback = function(v)
        Crosshair.Thickness = v
        updateCrosshairGui()
    end
})

-- ============== ESP COLOR HELPERS ==============
local function RefreshExistingSetColor(set, color)
    for obj in pairs(set) do
        local h = ESPCache.Objects[obj]
        if h and h.Parent then
            if h.FillColor ~= color then h.FillColor = color end
            if h.OutlineColor ~= color then h.OutlineColor = color end
        end
    end
end

local function RefreshPlayerColor(teamName, color)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == teamName and p.Character then
            local h = ESPCache.Objects[p.Character]
            if h and h.Parent then
                h.FillColor = color
                h.OutlineColor = color
            end
        end
    end
end

local function RefreshGeneratorColor()
    for gen in pairs(ESPCache.Generators) do
        if gen and gen.Parent then
            local state = ESPVisualState.Generator[gen]
            if state then state.LastColor = nil end
            if ESP.Generator then UpdateGenerator(gen, getRoot()) end
        end
    end
end

-- ============== ESP TAB ==============
ESPBox:AddToggle("ESP Survivor", {
    Default = false,
    Text = "Survivor ESP",
    Callback = function(v)
        ESP.Survivor = v
        if not v then clearPlayerTeamESP("Survivors") end
    end
}):AddColorPicker("ESPColorSurvivor", {
    Default = TeamColors.Survivor,
    Title = "Survivor ESP Color",
    Callback = function(v)
        TeamColors.Survivor = v
        RefreshPlayerColor("Survivors", v)
    end
})

ESPBox:AddToggle("ESP Killer", {
    Default = false,
    Text = "Killer ESP",
    Callback = function(v)
        ESP.Killer = v
        if not v then clearPlayerTeamESP("Killer") end
    end
}):AddColorPicker("ESPColorKiller", {
    Default = TeamColors.Killer,
    Title = "Killer ESP Color",
    Callback = function(v)
        TeamColors.Killer = v
        RefreshPlayerColor("Killer", v)
    end
})

ESPBox:AddToggle("ESP Generator", {
    Default = false,
    Text = "Generator ESP",
    Callback = function(v)
        ESP.Generator = v
        if not v then clearGeneratorESP() end
    end
}):AddColorPicker("ESPColorGenerator", {
    Default = GeneratorColor,
    Title = "Generator ESP Color",
    Callback = function(v)
        GeneratorColor = v
        RefreshGeneratorColor()
    end
})

ESPBox:AddToggle("ESP Pallet", {
    Default = false,
    Text = "Pallet ESP",
    Callback = function(v)
        ESP.Pallet = v
        if not v then clearESPSet(ESPCache.Pallets) end
    end
}):AddColorPicker("ESPColorPallet", {
    Default = PalletColor,
    Title = "Pallet ESP Color",
    Callback = function(v)
        PalletColor = v
        RefreshExistingSetColor(ESPCache.Pallets, v)
    end
})

ESPBox:AddToggle("ESP Window", {
    Default = false,
    Text = "Window ESP",
    Callback = function(v)
        ESP.Window = v
        if not v then clearESPSet(ESPCache.Windows) end
    end
}):AddColorPicker("ESPColorWindow", {
    Default = WindowColor,
    Title = "Window ESP Color",
    Callback = function(v)
        WindowColor = v
        RefreshExistingSetColor(ESPCache.Windows, v)
    end
})

ESPBox:AddToggle("ESP SCP", {
    Default = false,
    Text = "SCP ESP",
    Callback = function(v)
        ESP.SCP = v
        if not v then clearESPSet(ESPCache.SCP) end
    end
}):AddColorPicker("ESPColorSCP", {
    Default = SCPColor,
    Title = "SCP ESP Color",
    Callback = function(v)
        SCPColor = v
        RefreshExistingSetColor(ESPCache.SCP, v)
    end
})
ESPBox:AddSlider("ESP Distance", {
    Text = "ESP Distance",
    Default = 500,
    Min = 10,
    Max = 500,
    Callback = function(v)
        ESP.Distance = v
    end
})

ESPBox:AddButton({
    Text = "Reset ESP Colors",
    Func = function()
        TeamColors.Survivor = Color3.fromRGB(60, 255, 120)
        TeamColors.Killer = Color3.fromRGB(255, 60, 60)
        GeneratorColor = Color3.fromRGB(255, 170, 0)
        PalletColor = Color3.fromRGB(74, 255, 181)
        WindowColor = Color3.fromRGB(74, 255, 181)
        SCPColor = Color3.fromRGB(255, 0, 0)
        StatusDownColor = Color3.fromRGB(255, 80, 80)
        StatusColors.Name = Color3.fromRGB(255, 255, 255)
        StatusColors.Distance = Color3.fromRGB(90, 210, 255)
        StatusColors.Health = Color3.fromRGB(100, 255, 130)
        StatusColors.Item = Color3.fromRGB(255, 215, 90)

        pcall(function() Options.ESPColorSurvivor:SetValueRGB(TeamColors.Survivor) end)
        pcall(function() Options.ESPColorKiller:SetValueRGB(TeamColors.Killer) end)
        pcall(function() Options.ESPColorGenerator:SetValueRGB(GeneratorColor) end)
        pcall(function() Options.ESPColorPallet:SetValueRGB(PalletColor) end)
        pcall(function() Options.ESPColorWindow:SetValueRGB(WindowColor) end)
        pcall(function() Options.ESPColorSCP:SetValueRGB(SCPColor) end)
        pcall(function() Options.ESPColorDownStatus:SetValueRGB(StatusDownColor) end)
        pcall(function() Options.StatusNameColor:SetValueRGB(StatusColors.Name) end)
        pcall(function() Options.StatusDistanceColor:SetValueRGB(StatusColors.Distance) end)
        pcall(function() Options.StatusHealthColor:SetValueRGB(StatusColors.Health) end)
        pcall(function() Options.StatusItemColor:SetValueRGB(StatusColors.Item) end)

        RefreshPlayerColor("Survivors", TeamColors.Survivor)
        RefreshPlayerColor("Killer", TeamColors.Killer)
        RefreshGeneratorColor()
        RefreshExistingSetColor(ESPCache.Pallets, PalletColor)
        RefreshExistingSetColor(ESPCache.Windows, WindowColor)
        RefreshExistingSetColor(ESPCache.SCP, SCPColor)
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddToggle("Show Name", {
    Default = false,
    Text = "Show Name",
    Callback = function(v)
        ESPStatus.ShowName = v
        Timers.lastStatusESP = 0
        if not isStatusESPEnabled() then clearAllStatusESP() end
    end
}):AddColorPicker("StatusNameColor", {
    Default = StatusColors.Name,
    Title = "Name Color",
    Callback = function(v)
        StatusColors.Name = v
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddToggle("Show Distance", {
    Default = false,
    Text = "Show Distance",
    Callback = function(v)
        ESPStatus.ShowDistance = v
        Timers.lastStatusESP = 0
        if not isStatusESPEnabled() then clearAllStatusESP() end
    end
}):AddColorPicker("StatusDistanceColor", {
    Default = StatusColors.Distance,
    Title = "Distance Color",
    Callback = function(v)
        StatusColors.Distance = v
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddToggle("Show Health", {
    Default = false,
    Text = "Show Health",
    Callback = function(v)
        ESPStatus.ShowHealth = v
        Timers.lastStatusESP = 0
        if not isStatusESPEnabled() then clearAllStatusESP() end
    end
}):AddColorPicker("StatusHealthColor", {
    Default = StatusColors.Health,
    Title = "Health Color",
    Callback = function(v)
        StatusColors.Health = v
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddToggle("Show Item", {
    Default = false,
    Text = "Show Item",
    Callback = function(v)
        ESPStatus.ShowItem = v
        Timers.lastStatusESP = 0
        if not isStatusESPEnabled() then clearAllStatusESP() end
    end
}):AddColorPicker("StatusItemColor", {
    Default = StatusColors.Item,
    Title = "Item Color",
    Callback = function(v)
        StatusColors.Item = v
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddLabel("DOWN Color"):AddColorPicker("ESPColorDownStatus", {
    Default = StatusDownColor,
    Title = "DOWN Color",
    Callback = function(v)
        StatusDownColor = v
        Timers.lastStatusESP = 0
    end
})

ESPStatusBox:AddSlider("Status Radius", {
    Text = "Status Radius",
    Default = 500,
    Min = 10,
    Max = 500,
    Callback = function(v)
        ESPStatus.Radius = v
        Timers.lastStatusESP = 0
    end
})

-- ============== PLAYER / MOVEMENT ==============
MovementBox:AddToggle("Movement Boost", {
    Default = false,
    Text = "Movement Boost",
    Tooltip = "Boost gerak tanpa ubah WalkSpeed.",
    Callback = function(v)
        Movement.BoostEnabled = v
        applyMovementBoost()
    end
})

MovementBox:AddLabel("Boost Toggle Key"):AddKeyPicker("MovementBoostKeyPicker", {
    Default = "B",
    Mode = "Press",
    NoUI = true,
    Text = "Movement Boost Key",
    Callback = function() end,
    ChangedCallback = function(v)
        if typeof(v) == "EnumItem" then
            Movement.BoostKeybind = v
        end
    end
})

MovementBox:AddSlider("Movement Boost Value", {
    Text = "Boost Strength",
    Default = 6,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Callback = function(v)
        Movement.BoostValue = v
    end
})
MovementBox:AddLabel("Ground boost; WalkSpeed stays unchanged.", true)
MovementBox:AddLabel("Use the keybind to toggle boost.", true)
MovementBox:AddLabel("Jump follows the game default.", true)

MovementBox:AddToggle("NoClip", {
    Default = false,
    Text = "NoClip",
    Callback = function(v)
        toggleNoClip(v)
    end
})

-- AUTO FLEE
MovementBox:AddDivider()
MovementBox:AddLabel("Survivor movement helper.", true)
MovementBox:AddToggle("Auto Flee (Survivor)", {
    Default = false,
    Text = "Auto Flee",
    Callback = function(v)
        AutoFlee.Enabled = v
    end
})
MovementBox:AddSlider("Flee Distance", {
    Text = "Flee Distance",
    Default = 50,
    Min = 10,
    Max = 100,
    Callback = function(v)
        AutoFlee.DetectDistance = v
    end
})

-- ============== MISC TAB ==============

-- EMOTE
EmoteBox:AddLabel("Choose an emote to play.", true)
EmoteBox:AddDropdown("Emote", {
    Default = "Mannrobics",
    Values = EmoteList,
    Callback = function(v)
        Emote.Selected = v
    end
})
EmoteBox:AddButton({
    Text = "Play Emote",
    Func = function()
        if not EmoteRemote then notify("Emote", "EmoteHandler tidak ditemukan.", 2); return end
        local ok = pcall(function()
            EmoteRemote:FireServer(Emote.Selected)
        end)
        if ok then Emote.Active = true end
    end,
    Desc = "Play selected emote"
})
EmoteBox:AddButton({
    Text = "Stop Emote",
    Func = function()
        if not EmoteRemote then notify("Emote", "EmoteHandler tidak ditemukan.", 2); return end
        pcall(function()
            EmoteRemote:FireServer("Stop")
        end)
        Emote.Active = false
    end,
    Desc = "Stop current emote"
})

-- CHAT & NAME
ChatNameBox:AddLabel("Simple chat and name tools.", true)

ChatNameBox:AddToggle("Fake Chat Tag", {
    Default = false,
    Text = "Fake Chat Tag",
    Callback = function(v)
        FakeTag.Enabled = v
        if v then installFakeTagHook() end
    end
})
ChatNameBox:AddInput("Tag Text", {
    Text = "Tag Text",
    Default = "[BLUEHAVEN]",
    Numeric = false,
    Finished = false,
    Callback = function(v)
        FakeTag.Text = v or "[BLUEHAVEN]"
    end
})
ChatNameBox:AddLabel("Tag Color"):AddColorPicker("FakeTagColorPicker", {
    Default = Color3.fromRGB(0, 191, 255),
    Callback = function(v)
        FakeTag.Color = "#" .. string.format("%02x%02x%02x", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
    end
})

-- HIDE NAME
ChatNameBox:AddToggle("Hide Name", {
    Default = false,
    Text = "Hide Name",
    Callback = function(v)
        HideName.Enabled = v
        enableHideName(v)
    end
})
ChatNameBox:AddLabel("Hide Name Key"):AddKeyPicker("HideNameKeyPicker", {
    Default = "F3",
    Mode = "Press",
    Text = "Toggle Hide Name",
    Callback = function()
        setToggleValue("Hide Name", not HideName.Enabled, function(v)
            HideName.Enabled = v
            enableHideName(v)
        end)
    end,
    ChangedCallback = function(v)
        if typeof(v) == "EnumItem" then HideName.Keybind = v end
    end
})

-- FAKE PARRY ANIMATION
FakeParryBox:AddLabel("Visual parry animation only.", true)

FakeParryBox:AddToggle("Fake Parry Enabled", {
    Default = false,
    Text = "Enable Fake Parry",
    Callback = function(v)
        FakeParry.Enabled = v
    end
})
FakeParryBox:AddDropdown("Fake Parry Style", {
    Text = "Animation",
    Default = "Enten",
    Values = {"Enten", "Stopwatch", "Fih", "BloodShield"},
    Callback = function(v)
        FakeParry.Animation = v
    end
})
FakeParryBox:AddButton({
    Text = "Play Fake Parry",
    Func = function()
        playFakeParryAnimation(true)
    end
})

FakeParryBox:AddLabel("Toggle Key"):AddKeyPicker("FakeParryKeyPicker", {
    Default = "V",
    Mode = "Press",
    Text = "Fake Parry Key",
    Callback = function() end,
    ChangedCallback = function(v)
        if typeof(v) == "EnumItem" then FakeParry.Keybind = v end
    end
})

-- ============== VISUAL TAB ==============
VisualBox:AddToggle("Fullbright", {
    Default = false,
    Text = "Fullbright",
    Callback = function(v)
        Visual.Fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.ClockTime = OriginalLighting.ClockTime
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        end
    end
})
VisualBox:AddToggle("No Shadow", {
    Default = false,
    Text = "No Shadow",
    Callback = function(v)
        Visual.NoShadow = v
        Lighting.GlobalShadows = not v
    end
})
VisualBox:AddToggle("No Fog", {
    Default = false,
    Text = "No Fog",
    Callback = function(v)
        Visual.NoFog = v
        Lighting.FogStart = v and 0 or OriginalLighting.FogStart
        Lighting.FogEnd = v and 1000000 or OriginalLighting.FogEnd
    end
})

TimeBox:AddToggle("Set Clock Time", {
    Default = false,
    Text = "Set Clock Time",
    Callback = function(v)
        Visual.ClockTimeEnabled = v
        if v then
            Lighting.ClockTime = Visual.ClockTime
        else
            Lighting.ClockTime = OriginalLighting.ClockTime
        end
    end
})
TimeBox:AddSlider("Clock Time", {
    Text = "Clock Time",
    Default = 14,
    Min = 0,
    Max = 24,
    Callback = function(v)
        Visual.ClockTime = v
        if Visual.ClockTimeEnabled then
            Lighting.ClockTime = v
        end
    end
})
TimeBox:AddToggle("Ambient Color", {
    Default = false,
    Text = "Ambient Color",
    Callback = function(v)
        Visual.Ambient = v
        if v then
            Lighting.Ambient = Visual.AmbientColor
            Lighting.OutdoorAmbient = Visual.AmbientColor
        else
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end
    end
})
TimeBox:AddLabel("Ambient Color"):AddColorPicker("AmbientColorPicker", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v)
        Visual.AmbientColor = v
        if Visual.Ambient then
            Lighting.Ambient = v
            Lighting.OutdoorAmbient = v
        end
    end
})

ZoomBox:AddToggle("Unlimited Zoom", {
    Default = false,
    Text = "Unlimited Zoom",
    Callback = function(v)
        CameraZoom.UnlimitedZoom = v

        if v then
            if not CameraZoom.ZoomWasActive then
                CameraZoom.SavedMinZoom = LocalPlayer.CameraMinZoomDistance
                CameraZoom.SavedMaxZoom = LocalPlayer.CameraMaxZoomDistance
                CameraZoom.ZoomWasActive = true
            end

            LocalPlayer.CameraMaxZoomDistance = CameraZoom.MaxDistance
            LocalPlayer.CameraMinZoomDistance = CameraZoom.MinDistance
            return
        end

        -- OFF is intentionally a no-op unless Bluehaven previously changed zoom.
        if CameraZoom.ZoomWasActive then
            if CameraZoom.SavedMaxZoom ~= nil then
                LocalPlayer.CameraMaxZoomDistance = CameraZoom.SavedMaxZoom
            end
            if CameraZoom.SavedMinZoom ~= nil then
                LocalPlayer.CameraMinZoomDistance = CameraZoom.SavedMinZoom
            end

            CameraZoom.ZoomWasActive = false
            CameraZoom.SavedMinZoom = nil
            CameraZoom.SavedMaxZoom = nil
        end
    end
})
ZoomBox:AddSlider("Max Zoom Distance", {
    Text = "Max Zoom Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Callback = function(v)
        CameraZoom.MaxDistance = v
        if CameraZoom.UnlimitedZoom then
            LocalPlayer.CameraMaxZoomDistance = v
        end
    end
})
ZoomBox:AddToggle("FOV Changer", {
    Default = false,
    Text = "FOV Changer",
    Callback = function(v)
        CameraZoom.FOVEnabled = v
        local cam = workspace.CurrentCamera

        if v then
            if not cam then return end

            if not CameraZoom.FOVWasActive then
                CameraZoom.SavedFOV = cam.FieldOfView
                CameraZoom.FOVWasActive = true
            end

            cam.FieldOfView = CameraZoom.FOV
            return
        end

        -- Do not overwrite VD's FOV just because an autoloaded toggle is false.
        if CameraZoom.FOVWasActive then
            if cam and CameraZoom.SavedFOV ~= nil then
                cam.FieldOfView = CameraZoom.SavedFOV
            end

            CameraZoom.FOVWasActive = false
            CameraZoom.SavedFOV = nil
        end
    end
})
ZoomBox:AddSlider("FOV Value", {
    Text = "FOV Value",
    Default = 70,
    Min = 1,
    Max = 120,
    Callback = function(v)
        CameraZoom.FOV = v
        if CameraZoom.FOVEnabled then
            local cam = workspace.CurrentCamera
            if cam then cam.FieldOfView = v end
        end
    end
})

-- MORPH AVATAR
MorphAvaBox:AddInput("Morph Username", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Username",
    Callback = function(v) MorphState.Username = tostring(v or "") end
})
MorphAvaBox:AddButton({
    Text = "Apply Morph",
    Func = applyMorphByUsername,
    Desc = "Gunakan avatar dari username Roblox"
})
MorphAvaBox:AddButton({
    Text = "Reset Morph",
    Func = resetMorph,
    Desc = "Kembalikan avatar sebelum morph"
})

-- ============== UI SETTINGS ==============
-- Toggle/keybind mengikuti API resmi Obsidian.
SettingBox:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame and Library.KeybindFrame.Visible or false,
    Text = "Show Keybind Menu",
    Callback = function(value)
        if Library.KeybindFrame then
            Library.KeybindFrame.Visible = value
        end
    end
})


SettingBox:AddToggle("UIAnimations", {
    Default = true,
    Text = "UI Animations",
    Callback = function(value)
        pcall(function()
            Window:SetAnimations({
                ToggleWindow = value,
                TabSwitch = value,
                Dropdown = value,
            })
        end)
    end
})

SettingBox:AddLabel("Menu Toggle Key"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    Mode = "Toggle",
    NoUI = true,
    Text = "Toggle Bluehaven UI",
})

-- Obsidian memakai keypicker ini untuk show/hide seluruh window.
Library.ToggleKeybind = Options.MenuKeybind

SettingBox:AddButton({
    Text = "Toggle UI",
    Func = function()
        pcall(function()
            Window:Toggle()
        end)
    end
})

SettingBox:AddDivider()
SettingBox:AddLabel("Configs are managed on the right.", true)
SettingBox:AddDivider()
SettingBox:AddButton({
    Text = "Unload Hub (Clean)",
    Func = function()
        Library:Unload()
    end
})

-- Jump modification is intentionally unsupported.
Movement.JumpPowerEnabled = false
Movement.ForceJumpEnabled = false
toggleForceJump(false)

-- ============== CONFIG / THEME MANAGER ==============
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BluehavenHub")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({
    "MenuKeybind",
    "SaveManager_ConfigName",
    "SaveManager_ConfigList",
    "AutoSaveConfig",
})
ThemeManager:SetFolder("BluehavenHub")

local AutoSaveConfig = {
    Enabled = false,
    ConfigName = nil,
    Generation = 0,
    Suppress = false,
    Bound = false,
}

local AutoSaveTargetLabel = nil

local function sanitizeConfigName(value)
    local name = tostring(value or "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("[/\\:%*%?%\"<>|]", "_")
    if #name > 40 then name = name:sub(1, 40) end
    return name
end

local function refreshConfigList(selectName)
    local values = {}
    local ok, result = pcall(function()
        return SaveManager:RefreshConfigList()
    end)
    if ok and type(result) == "table" then
        values = result
    end

    if Options.SaveManager_ConfigList then
        pcall(function()
            Options.SaveManager_ConfigList:SetValues(values)
            if selectName then
                Options.SaveManager_ConfigList:SetValue(selectName)
            end
        end)
    end

    return values
end

local function configExists(name)
    if not name or name == "" then return false end
    local values = refreshConfigList()
    for _, existing in ipairs(values) do
        if existing == name then return true end
    end
    return false
end

local function setActiveConfig(name)
    local clean = sanitizeConfigName(name)
    if clean == "" then clean = nil end
    AutoSaveConfig.ConfigName = clean

    if AutoSaveTargetLabel then
        AutoSaveTargetLabel:SetText(
            clean and ("Auto-save target: " .. clean) or "Auto-save target: none"
        )
    end
end

local function getSelectedConfig()
    local selected = Options.SaveManager_ConfigList and Options.SaveManager_ConfigList.Value
    if type(selected) == "string" and selected ~= "" then
        return sanitizeConfigName(selected)
    end
    return nil
end

local function getCreatedConfigCandidate()
    if AutoSaveConfig.ConfigName and configExists(AutoSaveConfig.ConfigName) then
        return AutoSaveConfig.ConfigName
    end

    local selected = getSelectedConfig()
    if selected and configExists(selected) then
        return selected
    end

    local typed = Options.SaveManager_ConfigName and sanitizeConfigName(Options.SaveManager_ConfigName.Value)
    if typed and typed ~= "" and configExists(typed) then
        return typed
    end

    return nil
end

local function saveActiveConfig(silent)
    local name = AutoSaveConfig.ConfigName
    if not name or not configExists(name) then
        if not silent then
            notify("Config", "Buat atau load config dulu.", 2)
        end
        return false
    end

    local success, err = SaveManager:Save(name)
    if not success and not silent then
        notify("Config", "Save gagal: " .. tostring(err), 2)
    end
    return success == true
end

local function scheduleAutoSave()
    if not AutoSaveConfig.Enabled
        or AutoSaveConfig.Suppress
        or not AutoSaveConfig.ConfigName then
        return
    end

    AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
    local generation = AutoSaveConfig.Generation

    task.delay(0.45, function()
        if not HubRuntime.Alive
            or not AutoSaveConfig.Enabled
            or AutoSaveConfig.Suppress
            or generation ~= AutoSaveConfig.Generation then
            return
        end

        saveActiveConfig(true)
    end)
end

ConfigBox:AddInput("SaveManager_ConfigName", {
    Text = "Config Name",
    Default = "",
    Numeric = false,
    Finished = false,
    Placeholder = "example: config5",
    Callback = function() end,
})

ConfigBox:AddDropdown("SaveManager_ConfigList", {
    Text = "Config List",
    Values = SaveManager:RefreshConfigList(),
    AllowNull = true,
    Callback = function() end,
})

ConfigBox:AddButton({
    Text = "Create Config",
    Tooltip = "Buat config dari semua setting saat ini.",
    Func = function()
        local name = sanitizeConfigName(Options.SaveManager_ConfigName.Value)
        if name == "" then
            notify("Config", "Isi Config Name dulu.", 2)
            return
        end

        local success, err = SaveManager:Save(name)
        if not success then
            notify("Config", "Create gagal: " .. tostring(err), 2)
            return
        end

        setActiveConfig(name)
        refreshConfigList(name)
        notify("Config", "Created: " .. name, 2)
    end
}):AddButton({
    Text = "Load",
    Tooltip = "Load config yang dipilih.",
    Func = function()
        local name = getSelectedConfig()
        if not name then
            notify("Config", "Pilih Config List dulu.", 2)
            return
        end

        AutoSaveConfig.Suppress = true
        AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1

        local success, err = SaveManager:Load(name)
        if not success then
            AutoSaveConfig.Suppress = false
            notify("Config", "Load gagal: " .. tostring(err), 2)
            return
        end

        setActiveConfig(name)
        pcall(function() Options.SaveManager_ConfigName:SetValue(name) end)

        task.delay(0.75, function()
            AutoSaveConfig.Suppress = false
        end)

        notify("Config", "Loaded: " .. name, 2)
    end
})

ConfigBox:AddButton({
    Text = "Overwrite",
    Tooltip = "Simpan setting sekarang ke config aktif.",
    Func = function()
        local name = getSelectedConfig() or AutoSaveConfig.ConfigName
        if not name or not configExists(name) then
            notify("Config", "Buat atau pilih config dulu.", 2)
            return
        end

        setActiveConfig(name)
        local success, err = SaveManager:Save(name)
        notify("Config", success and ("Saved: " .. name) or ("Save gagal: " .. tostring(err)), 2)
    end
}):AddButton({
    Text = "Refresh",
    Tooltip = "Refresh Config List.",
    Func = function()
        refreshConfigList()
        notify("Config", "List refreshed.", 1.5)
    end
})

ConfigBox:AddButton({
    Text = "Set Auto Load",
    Tooltip = "Load config ini saat hub dibuka.",
    Func = function()
        local name = getSelectedConfig() or AutoSaveConfig.ConfigName
        if not name or not configExists(name) then
            notify("Config", "Pilih config dulu.", 2)
            return
        end

        local ok, err = pcall(function()
            writefile(SaveManager.Folder .. "/settings/autoload.txt", name)
        end)
        notify("Config", ok and ("Auto load: " .. name) or ("Gagal: " .. tostring(err)), 2)
    end
})

ConfigBox:AddToggle("AutoSaveConfig", {
    Default = false,
    Text = "Auto Save Config",
    Tooltip = "Simpan semua perubahan ke config aktif.",
    Callback = function(v)
        if not v then
            AutoSaveConfig.Enabled = false
            AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
            return
        end

        local name = getCreatedConfigCandidate()
        if not name then
            AutoSaveConfig.Enabled = false
            notify("Auto Save", "Buat atau load config dulu.", 2)
            task.defer(function()
                if Toggles.AutoSaveConfig and Toggles.AutoSaveConfig.Value then
                    Toggles.AutoSaveConfig:SetValue(false)
                end
            end)
            return
        end

        setActiveConfig(name)
        AutoSaveConfig.Enabled = true
        saveActiveConfig(true)
        notify("Auto Save", "Active: " .. name, 2)
    end
})

AutoSaveTargetLabel = ConfigBox:AddLabel("Auto-save target: none", true)
ConfigBox:AddLabel("Auto Save stores toggles, sliders, colors, dropdowns and keybinds.", true)

-- Themes stay separate from gameplay config.
pcall(function()
    ThemeManager:ApplyToTab(Tabs.UISettings)
end)

-- Auto-save watches every savable Obsidian toggle/option.
local function bindAutoSaveWatchers()
    if AutoSaveConfig.Bound then return end
    AutoSaveConfig.Bound = true

    local function bindOne(idx, object)
        if not object or type(object.OnChanged) ~= "function" then return end
        if idx == "AutoSaveConfig"
            or idx == "SaveManager_ConfigName"
            or idx == "SaveManager_ConfigList"
            or idx == "MenuKeybind"
            or (SaveManager.Ignore and SaveManager.Ignore[idx]) then
            return
        end

        pcall(function()
            object:OnChanged(function()
                scheduleAutoSave()
            end)
        end)
    end

    for idx, toggle in pairs(Toggles) do
        bindOne(idx, toggle)
    end
    for idx, option in pairs(Options) do
        bindOne(idx, option)
    end
end

task.defer(bindAutoSaveWatchers)

-- Load the library's normal autoload config after the UI exists.
task.defer(function()
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end)

-- ============== MAIN LOOP ==============
Connections.MainHeartbeat = TrackConnection(RunService.Heartbeat:Connect(function()
    if not HubRuntime.Alive then return end

    local now = tick()

    -- FPS + footer: footer library tidak perlu ditulis ulang setiap frame.
    State.Frames = State.Frames + 1
    if now - State.LastTick >= 1 then
        State.FPS = State.Frames
        State.Frames = 0
        State.LastTick = now
        local footerRole = GetRole()
        if type(Window.SetFooter) == "function" then
            pcall(function()
                Window:SetFooter(string.format("FPS: %d | Role: %s | %s", State.FPS, footerRole, os.date("%H:%M:%S")))
            end)
        end
    end

    local role
    if AutoFlee.Enabled or Killer.KillAll then role = GetRole() end

    -- Auto Flee tidak perlu scan killer setiap render frame.
    if AutoFlee.Enabled and role == "Survivor" and now - Timers.lastAutoFlee >= 0.08 then
        Timers.lastAutoFlee = now
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            local nearestRoot, nearDist = nil, AutoFlee.DetectDistance
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
                    local khrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local khum = p.Character:FindFirstChildOfClass("Humanoid")
                    if khrp and khum and khum.Health > 0 then
                        local dist = (khrp.Position - hrp.Position).Magnitude
                        if dist < nearDist then nearDist = dist; nearestRoot = khrp end
                    end
                end
            end
            if nearestRoot then
                local away = hrp.Position - nearestRoot.Position
                if away.Magnitude > 0.01 then hum:Move(away.Unit, false) end
            end
        end
    end

    -- Kill All / Basic Attack spam (server remote dependent)
    if Killer.KillAll and role == "Killer" and now - Timers.lastKillerUpdate >= 0.2 then
        Timers.lastKillerUpdate = now
        local hasTarget = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 and GetDistance(hrp.Position) <= Killer.KillRange then
                    hasTarget = true
                    break
                end
            end
        end
        if hasTarget and AttackEvent then
            pcall(function() AttackEvent:FireServer() end)
        end
    end

    if PlayerMods.GodMode and now - Timers.lastGodMode >= 0.10 then
        Timers.lastGodMode = now
        applyGodMode()
    end

    local root = getRoot()
    if root then
        -- Player Highlight and Status ESP are independent.
        local playerDue = (ESP.Survivor or ESP.Killer)
            and (now - Timers.lastPlayerESP >= ESPPerf.PlayerInterval)

        if playerDue then
            Timers.lastPlayerESP = now
            local rootPos = root.Position
            local rangeSq = ESP.Distance * ESP.Distance

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local isSurv = p.Team and p.Team.Name == "Survivors"
                    local isKill = p.Team and p.Team.Name == "Killer"
                    local enabled = (ESP.Survivor and isSurv) or (ESP.Killer and isKill)
                    local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local inRange = phrp and distSq(phrp.Position, rootPos) <= rangeSq

                    if enabled and inRange then
                        createESP(p.Character, isKill and TeamColors.Killer or TeamColors.Survivor)
                    else
                        removeESP(p.Character)
                    end
                end
            end
        end

        local statusDue = isStatusESPEnabled()
            and (now - Timers.lastStatusESP >= ESPPerf.StatusInterval)

        if statusDue then
            Timers.lastStatusESP = now
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    createStatusESP(p, p.Character, root)
                end
            end
        end

        -- Generator: biasanya sedikit, cukup 2x/detik.
        if ESP.Generator and now - Timers.lastGeneratorESP >= ESPPerf.GeneratorInterval then
            Timers.lastGeneratorESP = now
            for gen in pairs(ESPCache.Generators) do
                if gen and gen.Parent then UpdateGenerator(gen, root) end
            end
        end

        -- Window/Pallet: map bisa punya ratusan object, jadi diproses batch.
        if ESP.Window and now - Timers.lastWindowESP >= ESPPerf.WindowInterval then
            Timers.lastWindowESP = now
            processMapBatch(ESPCache.WindowList, ESPCache.Windows, root, "Window", "WindowCursor")
        end

        if ESP.Pallet and now - Timers.lastPalletESP >= ESPPerf.PalletInterval then
            Timers.lastPalletESP = now
            processMapBatch(ESPCache.PalletList, ESPCache.Pallets, root, "Pallet", "PalletCursor")
        end

        if ESP.SCP and now - Timers.lastSCPEsp >= ESPPerf.SCPInterval then
            Timers.lastSCPEsp = now
            UpdateSCPEsp(root)
        end
    end

    -- Crosshair GUI statis di tengah; update hanya saat setting berubah/respawn.
end))

-- CharacterAdded Handler
Connections.MainCharacterAdded = TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    if not HubRuntime.Alive then return end
    task.wait(0.5)
    if Movement.BoostEnabled then applyMovementBoost() end
    if Movement.NoClip then toggleNoClip(true) end
    if PlayerMods.GodMode then applyGodMode() end
    if HideName.Enabled then hideOverheadName(true) end
    if Crosshair.Enabled then updateCrosshairGui() end
    Movement.OriginalHumanoid = nil
    MorphState.OriginalDescription = nil
    
    -- Reattach parry sensor ke semua killer
    if Config.Surv_AutoParry then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsKiller(p) and p.Character then
                AttachParrySensor(p.Character)
            end
        end
    end
end))

-- Setup Players
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        SetupPlayer(p)
    end
end
Connections.PlayerAdded = TrackConnection(Players.PlayerAdded:Connect(function(p)
    if HubRuntime.Alive then SetupPlayer(p) end
end))

-- Heavy getgc Silent Aim tetap disabled. Light Silent Aim mengubah arah pada FireServer ToF asli.
-- Tidak ada duplicate shot, getgc, atau per-frame target scan.

-- ==== AUTO START ====
if Config.Surv_AutoParry then
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            AttachParrySensor(p.Character)
        end
    end
end

local function HardClearBluehavenVisuals()
    -- Cached ESP first.
    pcall(function()
        local objects = {}
        for obj in pairs(ESPCache.Objects) do objects[#objects + 1] = obj end
        for _, obj in ipairs(objects) do removeESP(obj) end
    end)

    pcall(clearAllStatusESP)
    pcall(clearGeneratorESP)

    -- Known map/player objects: catches visuals whose cache entry was lost.
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            if char then
                for _, child in ipairs(char:GetDescendants()) do
                    if child.Name == "BluehavenESP"
                        or child.Name == "BluehavenStatusESP"
                        or child.Name == "GenESP"
                        or child.Name == "GenHighlight" then
                        child:Destroy()
                    end
                end
            end
        end

        local sets = {
            ESPCache.Generators,
            ESPCache.Windows,
            ESPCache.Pallets,
            ESPCache.SCP,
            ESPCache.Hooks,
            ESPCache.Gates,
        }

        for _, set in ipairs(sets) do
            for obj in pairs(set) do
                if obj and obj.Parent then
                    local names = {"BluehavenESP", "BluehavenStatusESP", "GenESP", "GenHighlight"}
                    for _, name in ipairs(names) do
                        local leftover = obj:FindFirstChild(name)
                        if leftover then leftover:Destroy() end
                    end
                end
            end
        end
    end)

    pcall(destroyCrosshairGui)

    if GenBypass.UI then
        DestroyArtifact(GenBypass.UI)
    end
    GenBypass.UI = nil
    GenBypass.Button = nil

    local oldBypass = PlayerGui:FindFirstChild("BypassGenUI")
    if oldBypass then pcall(function() oldBypass:Destroy() end) end

    local oldCrosshair = PlayerGui:FindFirstChild("BluehavenCrosshair")
    if oldCrosshair then pcall(function() oldCrosshair:Destroy() end) end

    if ToolAimAssist.TracerPart then
        DestroyArtifact(ToolAimAssist.TracerPart)
        ToolAimAssist.TracerPart = nil
    end

    DestroyTrackedArtifacts()

    AimFOVVisual.Gui = nil
    AimFOVVisual.Circle = nil
    AimFOVVisual.Stroke = nil
end

-- Cleanup saat UI di-unload.
-- SAFE MODE: only undo states Bluehaven was actually using.
-- Do not blindly reset live game camera/lighting/humanoid state to stale snapshots.
if type(Library.OnUnload) == "function" then
    Library:OnUnload(function()
        if HubRuntime.Unloading then return end
        HubRuntime.Unloading = true

        -- Snapshot BEFORE toggles are zeroed.
        local unloadState = {
            HideName = HideName.Enabled,
            FastVault = FastVault.Enabled,
            Boost = Movement.BoostEnabled,
            NoClip = Movement.NoClip,
            BypassCooldown = Killer.BypassCooldown,
            BypassLeap = Killer.BypassLeap,

            Lighting = Visual.Fullbright
                or Visual.NoShadow
                or Visual.NoFog
                or Visual.Ambient
                or Visual.ClockTimeEnabled,

            ThirdPerson = Killer.ThirdPersonWasActive,
            UnlimitedZoom = CameraZoom.ZoomWasActive,
            FOV = CameraZoom.FOVWasActive,

            Morph = MorphState.Active,
            Emote = Emote.Active,
        }

        HubRuntime.Alive = false

        if AutoSaveConfig then
            AutoSaveConfig.Enabled = false
            AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
        end

        -- Disable feature flags first so any surviving hook becomes pass-through.
        Auto.SkillCheck = false
        Auto.Parry = false
        Auto.PalletDrop = false
        AutoFlee.Enabled = false
        AutoStalk.Enabled = false

        SilentAim.Enabled = false
        ToFAimConfig.Enabled = false
        ToolAimAssist.Enabled = false
        GunAim.Enabled = false
        GunAim.Holding = false
        GunAim.Target = nil
        AttackAim.Enabled = false
        AttackAim.Holding = false
        SpearAim.Enabled = false
        Masked.Enabled = false

        ESP.Survivor = false
        ESP.Killer = false
        ESP.Generator = false
        ESP.Pallet = false
        ESP.Window = false
        ESP.SCP = false
        ESPStatus.ShowName = false
        ESPStatus.ShowDistance = false
        ESPStatus.ShowHealth = false
        ESPStatus.ShowItem = false

        Config.Surv_AutoParry = false
        Config.Surv_AutoCrouch = false

        Killer.KillAll = false
        Killer.BypassCooldown = false
        Killer.BypassLeap = false
        Killer.ThirdPerson = false
        Killer.AntiBlind = false
        Killer.BlockVaults = false

        CameraZoom.UnlimitedZoom = false
        CameraZoom.FOVEnabled = false

        PlayerMods.GodMode = false
        PlayerMods.AntiFall = false
        PlayerMods.AntiVault = false

        GenBypass.Enabled = false
        GenBoostConfig.Enabled = false
        FastVault.Enabled = false
        Crosshair.Enabled = false
        FakeParry.Enabled = false
        FakeTag.Enabled = false

        -- Skillcheck: stop only Bluehaven's connections.
        pcall(SC_Stop)

        -- Feature-specific cleanup.
        if unloadState.FastVault then
            pcall(function() toggleFastVault(false) end)
        else
            pcall(FV_Disconnect)
        end

        if unloadState.BypassCooldown then
            pcall(function() toggleBypassCooldown(false) end)
        end

        if unloadState.BypassLeap then
            pcall(StopLeapBypass)
        end

        pcall(function()
            if State.ParryCooldownThread and type(task.cancel) == "function" then
                task.cancel(State.ParryCooldownThread)
            end
            State.ParryCooldownThread = nil
            State.ParryCooldown = false
        end)

        -- Movement Boost never changes WalkSpeed, just disconnect its impulse loop.
        Movement.BoostEnabled = false
        Movement.JumpPowerEnabled = false
        Movement.ForceJumpEnabled = false
        pcall(applyMovementBoost)
        pcall(function() toggleForceJump(false) end)


        if unloadState.NoClip then
            Movement.NoClip = false
            pcall(function() toggleNoClip(false) end)
        else
            Movement.NoClip = false
        end


        -- Stop tool-assist listeners.
        pcall(function()
            if ToolAimAssist.CharacterConn then ToolAimAssist.CharacterConn:Disconnect() end
            if ToolAimAssist.BackpackConn then ToolAimAssist.BackpackConn:Disconnect() end
            ToolAimAssist.CharacterConn = nil
            ToolAimAssist.BackpackConn = nil

            for tool, conn in pairs(ToolAimAssist.ToolConnections) do
                if conn then pcall(function() conn:Disconnect() end) end
                ToolAimAssist.ToolConnections[tool] = nil
            end
        end)

        -- Stop all Bluehaven-owned connections BEFORE deleting visuals.
        DisconnectTrackedConnections()

        pcall(function()
            if ESPScanState.DelayTask and type(task.cancel) == "function" then
                task.cancel(ESPScanState.DelayTask)
            end

            ESPScanState.DelayTask = nil
            ESPScanState.Generation = ESPScanState.Generation + 1
            ESPScanState.Running = false
        end)

        -- Only undo morph/emote if Bluehaven actually had them active.
        if unloadState.Emote then
            pcall(function()
                if EmoteRemote then EmoteRemote:FireServer("Stop") end
            end)
            Emote.Active = false
        end

        if unloadState.Morph and MorphState.OriginalDescription then
            pcall(function()
                local hum = getHumanoid()
                if hum then
                    hum:ApplyDescription(MorphState.OriginalDescription)
                    MorphState.Active = false
                end
            end)
        end

        -- Only restore Hide Name if it was enabled.
        if unloadState.HideName then
            HideName.Enabled = false
            pcall(function() enableHideName(false) end)
        else
            HideName.Enabled = false
        end

        -- Restore fake chat callback because Bluehaven installs this wrapper itself.
        pcall(function()
            if FakeTagHook.Installed then
                TextChatService.OnIncomingMessage = FakeTagHook.Original
            end
            FakeTagHook.Installed = false
            FakeTagHook.Original = nil
        end)

        pcall(removeSilentAimHook)
        pcall(stopFakeParryAnimation)

        -- Attempt hook restoration, but NEVER discard oldNamecall on failure.
        -- If an executor cannot restore it safely, all feature flags are already
        -- false, so the installed hook remains a transparent pass-through.
        if mainNamecallHookInstalled and oldNamecall and type(hookmetamethod) == "function" then
            local restored = pcall(function()
                hookmetamethod(game, "__namecall", oldNamecall)
            end)

            if restored then
                mainNamecallHookInstalled = false
                oldNamecall = nil
            end
        end

        -- Do not touch live game lighting/camera unless Bluehaven had overridden it.
        if unloadState.Lighting then
            pcall(function()
                Lighting.Brightness = OriginalLighting.Brightness
                Lighting.ClockTime = OriginalLighting.ClockTime
                Lighting.Ambient = OriginalLighting.Ambient
                Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
                Lighting.GlobalShadows = OriginalLighting.GlobalShadows
                Lighting.FogStart = OriginalLighting.FogStart
                Lighting.FogEnd = OriginalLighting.FogEnd
            end)
        end

        -- Restore only camera properties Bluehaven actually changed,
        -- using the live snapshots captured at feature-enable time.
        if unloadState.ThirdPerson then
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam and Killer.OriginalCameraType ~= nil then
                    cam.CameraType = Killer.OriginalCameraType
                end
                if Killer.OriginalCameraMode ~= nil then
                    LocalPlayer.CameraMode = Killer.OriginalCameraMode
                end
                if Killer.OriginalMinZoom ~= nil and not unloadState.UnlimitedZoom then
                    LocalPlayer.CameraMinZoomDistance = Killer.OriginalMinZoom
                end
                if Killer.OriginalMaxZoom ~= nil and not unloadState.UnlimitedZoom then
                    LocalPlayer.CameraMaxZoomDistance = Killer.OriginalMaxZoom
                end
            end)
        end

        if unloadState.UnlimitedZoom then
            pcall(function()
                if CameraZoom.SavedMinZoom ~= nil then
                    LocalPlayer.CameraMinZoomDistance = CameraZoom.SavedMinZoom
                end
                if CameraZoom.SavedMaxZoom ~= nil then
                    LocalPlayer.CameraMaxZoomDistance = CameraZoom.SavedMaxZoom
                end
            end)
        end

        if unloadState.FOV then
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam and CameraZoom.SavedFOV ~= nil then
                    cam.FieldOfView = CameraZoom.SavedFOV
                end
            end)
        end

        Killer.ThirdPersonWasActive = false
        Killer.OriginalCameraType = nil
        Killer.OriginalCameraMode = nil
        Killer.OriginalMinZoom = nil
        Killer.OriginalMaxZoom = nil

        CameraZoom.ZoomWasActive = false
        CameraZoom.SavedMinZoom = nil
        CameraZoom.SavedMaxZoom = nil
        CameraZoom.FOVWasActive = false
        CameraZoom.SavedFOV = nil

        pcall(function()
            if AimFOVVisual.Circle then
                AimFOVVisual.Circle.Visible = false
            end
        end)

        HardClearBluehavenVisuals()

        -- Clear only Bluehaven caches.
        pcall(function()
            table.clear(Attached)
            table.clear(ESPCache.Objects)
            table.clear(ESPCache.Status)
            table.clear(ESPCache.SCP)
            table.clear(ESPCache.Generators)
            table.clear(ESPCache.Windows)
            table.clear(ESPCache.Pallets)
            table.clear(ESPCache.Hooks)
            table.clear(ESPCache.Gates)

            table.clear(ESPCache.WindowList)
            table.clear(ESPCache.PalletList)
            table.clear(ESPCache.SCPList)
            table.clear(ESPCache.HookList)
            table.clear(ESPCache.GateList)

            table.clear(ESPCache.WindowIndex)
            table.clear(ESPCache.PalletIndex)
            table.clear(ESPCache.SCPIndex)
            table.clear(ESPCache.HookIndex)
            table.clear(ESPCache.GateIndex)

            table.clear(ESPVisualState.Generator)
            table.clear(ESPVisualState.WindowPos)
            table.clear(GenBypass.Cache)
            table.clear(GenBypass.Processed)

            GenBypass.CacheTimer = 0
            ESPPerf.WindowCursor = 1
            ESPPerf.PalletCursor = 1

            State.AutoParryAdornment = nil
            State.ParryCircle = nil
            ToolAimAssist.LastTarget = nil
        end)
    end)
end

-- UI siap!
Library:Notify({
    Title = "Bluehaven Hub",
    Description = "Loaded (Anti-Freeze mode aktif)",
    Time = 3
})

print("✅ Bluehaven Hub loaded! Enjoy!")
