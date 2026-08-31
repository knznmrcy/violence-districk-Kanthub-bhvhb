-- ==============================================
--     BLUEHAVEN HUB - Kantzy
-- ==============================================
SEMENTARA NO LIBRARY(KANTZY) 
GABISA DI LOAD PUNG GAUSAH MALING

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

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera

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
    Distance  = 100
}

local ESPStatus = {
    Enabled      = false,
    ShowName     = true,
    ShowDistance = true,
    ShowHealth   = false,
    ShowItem     = true,
    Radius       = 100
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

    GenBypass.UI = Instance.new("ScreenGui")
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

    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then 
            GB_DoRepair(bestPoint) 
        end
    end)
end

-- Inisialisasi button
GB_CreateButton()

-- Recreate button saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GB_CreateButton()
    GB_UpdateButton()
end)

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
    Animation = "Parry",
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
    FOVEnabled    = false,
    FOV           = 70,
    DefaultFOV    = workspace.CurrentCamera.FieldOfView
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
    JumpPowerEnabled  = false,
    JumpPowerValue    = 50,
    OriginalJumpPower = 50,
    WalkSpeedEnabled  = false,
    WalkSpeedValue    = 17.6,
    OriginalWalkSpeed = 16,
    NoClip            = false
}

local FastVault = {
    Enabled    = false,
    Speed      = 1.2,
    ReplaceMap = {
        ["rbxassetid://83873880822918"] = "rbxassetid://136962284480779"
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
    Selected = "Mannrobics"
}

local EmoteButton = {
    Show        = false,
    GuiInstance = nil
}

-- ============== GROUPED STATE / CONNECTIONS ==============

local Connections = {
    WalkSpeed     = nil,
    NoClip        = nil,
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
    lastESPUpdate    = 0,
    lastKillerUpdate = 0,
    lastGodMode      = 0,
    lastTracerScan   = 0,
    lastPalletScan   = 0,
    lastPalletDrop   = 0,
    lastVaultBlock   = 0
}

local ESPCache = {
    Objects    = {}, 
    Status     = {},
    SCP        = {}, 
    Generators = {},
    Windows    = {},
    Pallets    = {}
}

local OriginalLighting = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows  = Lighting.GlobalShadows
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
local function getSilentTarget()
    local root = getRoot()
    if not root then return nil end
    local myPos = root.Position
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, SilentAim.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local valid = false
        if SilentAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then valid = true
        elseif SilentAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then valid = true
        elseif SilentAim.TargetMode == "All" then valid = true
        elseif SilentAim.TargetMode == "SCP" then
            for obj in pairs(ESPCache.SCP) do
                if obj and obj.Parent then valid = true end
            end
        end
        if not valid then continue end

        local part = p.Character:FindFirstChild(SilentAim.TargetPart)
            or p.Character:FindFirstChild("HumanoidRootPart")
            or p.Character:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position

        -- Improved prediction: pakai AssemblyLinearVelocity
        if SilentAim.Prediction then
            local vel = Vector3.new()
            pcall(function() vel = part.AssemblyLinearVelocity end)
            local dist = (targetPos - myPos).Magnitude
            local travelTime = dist / SilentAim.BulletSpeed
            targetPos = targetPos + vel * (SilentAim.PredictStrength * travelTime)
        end

        -- Wall check
        if SilentAim.WallCheck then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(myPos, targetPos - myPos, params)
            if result then continue end
        end

        local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
        if onScreen then
            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            local worldDist = (targetPos - myPos).Magnitude
            if distFromCenter < bestDist and distFromCenter <= SilentAim.FOV and worldDist <= SilentAim.Distance then
                bestDist = distFromCenter
                best = part
            end
        end
    end

    return best
end

local function setupSilentAimHook()
    if silentHookActive then return end
    -- Try getgc approach
    local castTable = nil
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "cast") and type(rawget(v,"cast")) == "function" then
                castTable = v
                break
            end
        end
    end)
    if not castTable then
        -- Fallback: hook via namecall
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if SilentAim.Enabled and method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                local target = getSilentTarget()
                if target then
                    return target, target.Position, Vector3.new(0,1,0), target.Material
                end
            end
            return oldNamecall(self, ...)
        end)
        silentHookActive = true
        return
    end
    silentOriginalCast = castTable.cast
    if not silentOriginalCast then return end
    silentHookActive = true
    castTable.cast = function(p1, p2, p3)
        if SilentAim.Enabled then
            local target = getSilentTarget()
            if target then
                return target, target.Position, Vector3.new(0,1,0), target.Material
            end
        end
        return silentOriginalCast(p1, p2, p3)
    end
end

local function removeSilentAimHook()
    if not silentHookActive then return end
    local castTable = nil
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "cast") then
                castTable = v
                break
            end
        end
    end)
    if castTable and silentOriginalCast then
        castTable.cast = silentOriginalCast
    end
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

local function getRoot()
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

local EmoteRemote = Remotes:WaitForChild("EmoteHandler")

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
    Size = UDim2.fromOffset(450, 1000),
    CornerRadius = 20,
    AutoShow = true,
})
-- TABS
local Tabs = {
    Player     = Window:AddTab("Player",      "user","Ability Survivor & Killer"),
    ESP        = Window:AddTab("ESP",         "eye","Esp player, object, stats"),
    Misc       = Window:AddTab("Misc",        "sliders-horizontal","Movement, Emote, Fun"),
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
local MovementBox  = Tabs.Misc:AddLeftGroupbox("Movement", "move")
local EmoteBox     = Tabs.Misc:AddRightGroupbox("Emote", "music")
local FunBox       = Tabs.Misc:AddRightGroupbox("Fake Chat Tag", "message-circle")
local VisualBox    = Tabs.Visual:AddLeftGroupbox("Graphics", "sun")
local MorphAvaBox  = Tabs.Visual:AddLeftGroupbox("Morph Avatar", "user")
local TimeBox      = Tabs.Visual:AddRightGroupbox("Clock & Ambient", "alarm-clock-check")
local ZoomBox      = Tabs.Visual:AddRightGroupbox("Zoom Out", "fullscreen")
local SettingBox   = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")

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
        Library:Notify({Title = "Teleport", Description = "Berhasil!", Duration = 1})
    end
end

local function applyJumpPower()
    if not Movement.JumpPowerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = Movement.JumpPowerValue end
end

local function shouldDisableWalkSpeed()
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

local function applyWalkSpeed()
    if Connections.WalkSpeed then
        Connections.WalkSpeed:Disconnect()
        Connections.WalkSpeed = nil
    end

    Connections.WalkSpeed = RunService.Heartbeat:Connect(function()
        if not Movement.WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if shouldDisableWalkSpeed() then return end
        if hum.WalkSpeed ~= Movement.WalkSpeedValue then
            hum.WalkSpeed = Movement.WalkSpeedValue
        end
    end)
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
            for i = 1, 10 do parryRemote:FireServer() end
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
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end)
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

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)

    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then
                    TriggerCrouch()
                end
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
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
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
    end)
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then 
        AttachParrySensor(p.Character) 
    end
end

function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide then
            v.CanCollide = not Movement.NoClip
        end
    end
end

local function toggleNoClip(state)
    Movement.NoClip = state
    if state then
        if Connections.NoClip then Connections.NoClip:Disconnect() end
        Connections.NoClip = RunService.RenderStepped:Connect(function()
            if Movement.NoClip then applyNoClip() end
        end)
    else
        if Connections.NoClip then
            Connections.NoClip:Disconnect()
            Connections.NoClip = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
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

local function SetupAntiFallDamage()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if not r then return end
        local m = r:FindFirstChild("Mechanics")
        local fallEvent = m and m:FindFirstChild("Fall")
        if not (fallEvent and fallEvent:IsA("RemoteEvent")) then return end

        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)

                    if not checkcaller() and PlayerMods.AntiFall and self == fallEvent then
                        local method = getnamecallmethod()
                        if method == "FireServer" then
                            return nil
                        end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end

SetupAntiFallDamage()

-- ============= ESP SYSTEM ==============

for _, obj in ipairs(workspace:GetDescendants()) do
    if string.find(string.lower(obj.Name), "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
    end
end

workspace.DescendantAdded:Connect(function(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    ESPCache.SCP[obj] = nil
    ESPCache.Generators[obj] = nil
    ESPCache.Windows[obj] = nil
    ESPCache.Pallets[obj] = nil
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj]:Destroy()
        ESPCache.Objects[obj] = nil
    end
end)

local function removeESP(obj)
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj]:Destroy()
        ESPCache.Objects[obj] = nil
    end
end

local function createESP(obj, color)
    if not obj then return end
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj].FillColor = color
        ESPCache.Objects[obj].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    ESPCache.Objects[obj] = h
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then removeESP(obj) end
    end)
end

local function removeStatusESP(char)
    if ESPCache.Status[char] then
        ESPCache.Status[char]:Destroy()
        ESPCache.Status[char] = nil
    end
end

local function GetHeldItem(char)
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if ESPItems[obj.Name] then return obj.Name end
        if obj:IsA("Tool") and ESPItems[obj.Name] then return obj.Name end
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

local function ApplyGenHighlight(object, color)
    local h = object:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboard(text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GenESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    return billboard
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not ESP.Generator then
        local old = generator:FindFirstChild("GenESP")
        if old then old:Destroy() end
        local h = generator:FindFirstChild("GenHighlight")
        if h then h:Destroy() end
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenESP")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        return
    end
    local cp = math.clamp(percent, 0, 100)
    local color = GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
    local text = string.format("[%.0f%%]", percent)
    if not billboard then
        billboard = CreateBillboard(text, color)
        billboard.Adornee = generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = text; lbl.TextColor3 = color end
    end
    ApplyGenHighlight(generator, color)
end

local function UpdateMapESP(obj, root)
    if not obj or not root then return end
    local pos
    if obj:IsA("Model") then pos = obj:GetPivot().Position
    elseif obj:IsA("BasePart") then pos = obj.Position end
    if not pos then return end
    local distance = (pos - root.Position).Magnitude
    if obj.Name == "Window" then
        if ESP.Window and distance <= ESP.Distance then createESP(obj, WindowColor)
        else removeESP(obj) end
    end
    if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        if ESP.Pallet and distance <= ESP.Distance then createESP(obj, PalletColor)
        else removeESP(obj) end
    end
end

local function createStatusESP(player, char, root)
    if not ESPStatus.Enabled then removeStatusESP(char); return end
    if not root then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end

    local isDown = hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true

    local dist = (head.Position - root.Position).Magnitude
    if dist > ESPStatus.Radius then removeStatusESP(char); return end

    local text = ""
    if isDown then text = "🔻 DOWN\n" end
    if ESPStatus.ShowName then
        text = text .. player.Name
        if ESPStatus.ShowItem then
            local item = GetHeldItem(char)
            if item then text = text .. " [" .. item .. "]" end
        end
        text = text .. "\n"
    end
    if ESPStatus.ShowDistance then text = text .. string.format("Dist: %.0f\n", dist) end
    if ESPStatus.ShowHealth    then text = text .. string.format("HP: %.0f\n", hum.Health) end
    if text == "" then removeStatusESP(char); return end

    local teamColor = Color3.new(1, 1, 1)
    if player.Team then
        if player.Team.Name == "Killer" then teamColor = TeamColors.Killer
        elseif player.Team.Name == "Survivors" then teamColor = TeamColors.Survivor end
    end
    if isDown then teamColor = Color3.fromRGB(255, 0, 0) end

    local billboard = ESPCache.Status[char]
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 50)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = teamColor
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = text
        label.Parent = billboard
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = char
        ESPCache.Status[char] = billboard
    else
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then label.Text = text; label.TextColor3 = teamColor end
    end
end

local function UpdateSCPEsp(root)
    if not ESP.SCP then
        for obj in pairs(ESPCache.SCP) do removeESP(obj) end
        return
    end
    for obj in pairs(ESPCache.SCP) do
        if obj and obj.Parent then
            local pos
            if obj:IsA("Model") then pos = obj:GetPivot().Position
            elseif obj:IsA("BasePart") then pos = obj.Position end
            if pos then
                if (pos - root.Position).Magnitude <= ESP.Distance then
                    createESP(obj, SCPColor)
                else
                    removeESP(obj)
                end
            end
        end
    end
end

-- ============== TELEPORT MAP FUNCTIONS =================
local function TeleportToGenerator()
    local gens = {}
    for obj in pairs(ESPCache.Generators) do
        if obj and obj.Parent then
            table.insert(gens, obj)
        end
    end
    if #gens == 0 then 
        Library:Notify({Title = "TP Generator", Description = "Tidak ada generator!", Duration = 2})
        return 
    end
    if TeleportIndex.Generator > #gens then TeleportIndex.Generator = 1 end
    
    local gen = gens[TeleportIndex.Generator]
    local part = gen:FindFirstChildWhichIsA("BasePart")
    if part then
        TeleportToPart(part)
        Library:Notify({Title = "TP Generator", Description = "Generator " .. TeleportIndex.Generator, Duration = 1.2})
    end
    TeleportIndex.Generator = TeleportIndex.Generator + 1
end

local function TeleportToHook()
    local hooks = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Hook" and obj:IsA("Model") then
            table.insert(hooks, obj)
        end
    end
    if #hooks == 0 then 
        Library:Notify({Title = "TP Hook", Description = "Tidak ada hook!", Duration = 2})
        return 
    end
    if TeleportIndex.Hook > #hooks then TeleportIndex.Hook = 1 end
    
    local hook = hooks[TeleportIndex.Hook]
    local part = hook:FindFirstChild("HookPoint") or hook:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Hook = TeleportIndex.Hook + 1
end

local function TeleportToGate()
    local gates = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Gate" and obj:IsA("Model") then
            table.insert(gates, obj)
        end
    end
    if #gates == 0 then 
        Library:Notify({Title = "TP Gate", Description = "Tidak ada gate!", Duration = 2})
        return 
    end
    if TeleportIndex.Gate > #gates then TeleportIndex.Gate = 1 end
    
    local gate = gates[TeleportIndex.Gate]
    local part = gate:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Gate = TeleportIndex.Gate + 1
end

local function TeleportToPallet()
    local pallets = {}
    for pal in pairs(ESPCache.Pallets) do
        if pal and pal.Parent then
            table.insert(pallets, pal)
        end
    end
    if #pallets == 0 then 
        Library:Notify({Title = "TP Pallet", Description = "Tidak ada pallet!", Duration = 2})
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
        Library:Notify({Title = "TP Window", Description = "Tidak ada window!", Duration = 2})
        return 
    end
    if TeleportIndex.Window > #windows then TeleportIndex.Window = 1 end
    
    local window = windows[TeleportIndex.Window]
    local part = window:FindFirstChild("Bottom") or window:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Window = TeleportIndex.Window + 1
end

local function RefreshMapForTeleport()
    -- Refresh cache dengan scanning ulang
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Generator" then ESPCache.Generators[obj] = true
        elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
        elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
        end
    end
    -- Reset index
    TeleportIndex.Generator = 1
    TeleportIndex.Hook = 1
    TeleportIndex.Gate = 1
    TeleportIndex.Pallet = 1
    TeleportIndex.Window = 1
    Library:Notify({Title = "Refresh Map", Description = "Cache diperbarui!", Duration = 2})
end

-- ========== AUTO SYSTEM =================

-- NAMECALL HOOK
local _tofDeferred = false
local oldNamecall

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = { ... }
    
    if not checkcaller() and method == "FireServer" then
        if Killer.AntiBlind and GotBlindedRemote and self == GotBlindedRemote then
            local isKiller = LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
            if isKiller then
                return nil
            end
        end
        
        if PlayerMods.AntiVault and self.Name == "VaultEvent" then
            return nil
        end
    end
    
    if _tofDeferred then
        return oldNamecall(self, ...)
    elseif ToFAimConfig.Enabled and ToFFireRemote and self == ToFFireRemote and method == "FireServer" and not checkcaller() then

        if typeof(args[1]) == "Instance" and typeof(args[2]) == "Vector3" then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if myRoot then
                local bestPart, bestDist = nil, ToFAimConfig.Range
                
                if ToFAimConfig.TargetMode == "SCP" then
                    for obj in pairs(ESPCache.SCP) do
                        if obj and obj.Parent then
                            local part
                            if obj:IsA("Model") then 
                                part = obj:FindFirstChild(ToFAimConfig.AimPart) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            elseif obj:IsA("BasePart") then 
                                part = obj 
                            end
                            
                            if part then
                                local d = (part.Position - myRoot.Position).Magnitude
                                if d <= bestDist then
                                    bestDist = d
                                    bestPart = part
                                end
                            end
                        end
                    end
                else
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Team then
                            local validTeam = (ToFAimConfig.TargetMode == "Killer" and plr.Team.Name == "Killer") or 
                                              (ToFAimConfig.TargetMode == "Survivor" and plr.Team.Name == "Survivors")
                            
                            if validTeam then
                                local targetPart = plr.Character:FindFirstChild(ToFAimConfig.AimPart)
                                local targetHum  = plr.Character:FindFirstChildOfClass("Humanoid")
                                if targetPart and targetHum and targetHum.Health > 0 then
                                    local d = (targetPart.Position - myRoot.Position).Magnitude
                                    if d <= bestDist then
                                        bestDist = d
                                        bestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end

                if bestPart then
                    local gunPart = args[1]
                    local gunPos
                    pcall(function() gunPos = gunPart.Position end)
                    gunPos = gunPos or myRoot.Position

                    local targetCenter = bestPart.Position
                    local targetPos = targetCenter
                    
                    if ToFAimConfig.Predict then
                        local rawVel    = bestPart.AssemblyLinearVelocity
                        local flatVel   = Vector3.new(rawVel.X, 0, rawVel.Z)
                        local travelTime = bestDist / ToFAimConfig.BulletSpeed
                        targetPos = targetCenter + (flatVel * travelTime)
                    end

                    local dir    = targetPos - gunPos
                    local newDir = (dir.Magnitude > 0.01) and dir.Unit or args[2]

                    local camLook      = Camera.CFrame.LookVector
                    local dotCheck     = camLook:Dot(newDir)
                    
                    if dotCheck < ToFAimConfig.DotThreshold then
                        return
                    end

                    _tofDeferred = true
                    task.defer(function()
                        pcall(function()
                            ToFFireRemote:FireServer(args[1], newDir)
                        end)
                        _tofDeferred = false
                    end)
                    return
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

local function StartLeapBypass()
    Connections.LeapBypass = task.spawn(function()
        local leapFunction, m2Function
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info.name == "tryActivate" then leapFunction = v end
                if info.name == "playM2Animation" then m2Function = v end
                if leapFunction and m2Function then break end
            end
        end
        if not leapFunction and not m2Function then
            warn("Function tidak ditemukan.") return
        end
        while task.wait(0.1) do
            if not Killer.BypassLeap then break end
            for _, fn in pairs({leapFunction, m2Function}) do
                if fn then
                    for i, val in pairs(debug.getupvalues(fn)) do
                        if type(val) == "table" then
                            local mt = getrawmetatable(val)
                            if mt and mt.__index then
                                local ok, check = pcall(function() return mt.__index(val, "Cooldown") end)
                                if ok and check then
                                    debug.setupvalue(fn, i, setmetatable({}, {
                                        __index = function(t, k)
                                            if k == "Cooldown" then return 0 end
                                            return rawget(t, k)
                                        end
                                    }))
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function toggleBypassCooldown(state)
    if state then
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
                mt.__index = newcclosure(function(t, k)
                    if k == "canUse" then return true end
                    if k == "Cooldown" then return 0 end
                    return old(t, k)
                end)
            end
        end
    end
end

function toggleFastVault(state)
    if state then
        local fastAnim = FastVault.ReplaceMap["rbxassetid://83873880822918"] or "rbxassetid://136962284480779"
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "PlayVaultAnimation") then
                local mt = getrawmetatable(v)
                if mt and mt.__index then
                    local ok, check = pcall(function() return mt.__index(v, "PlayVaultAnimation") end)
                    if ok and check then
                        local old = mt.__index
                        mt.__index = newcclosure(function(t, k)
                            if k == "PlayVaultAnimation" then
                                return function(...)
                                    local args = {...}
                                    if type(args[3]) == "string" and FastVault.ReplaceMap[args[3]] then
                                        args[3] = FastVault.ReplaceMap[args[3]]
                                    end
                                    return old(t, k)(table.unpack(args))
                                end
                            end
                            return old(t, k)
                        end)
                    end
                end
            end
        end
    end
end

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
        if v then StartLeapBypass() end
    end
})
KillerTab:AddToggle("Third Person", {
    Default = false,
    Text = "Third Person",
    Callback = function(v)
        Killer.ThirdPerson = v
        if v then
            Killer.ThirdPersonWasActive = true
            Killer.OriginalCameraType = Camera.CameraType
            Camera.CameraType = Enum.CameraType.Fixed
        else
            Killer.ThirdPersonWasActive = false
            if Killer.OriginalCameraType then
                Camera.CameraType = Killer.OriginalCameraType
            end
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
    end
})
KillerTab:AddToggle("Block Vaults", {
    Default = false,
    Text = "Block Vault",
    Callback = function(v)
        Killer.BlockVaults = v
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
    Text = "Parry Safety (No vault/repair)",
    Callback = function(v)
        Config.Surv_ParrySafety = v
    end
})
ParryBox:AddToggle("Aggressive Parry", {
    Default = false,
    Text = "Aggressive Parry",
    Callback = function(v)
        Config.Surv_ParryAggressive = v
    end
})
ParryBox:AddToggle("Auto Crouch (Abyssal S1)", {
    Default = false,
    Text = "Auto Crouch Abyssal S1",
    Callback = function(v)
        Config.Surv_AutoCrouch = v
    end
})
ParryBox:AddSlider("Parry Distance", {
    Default = 15,
    Min = 5,
    Max = 30,
    Callback = function(v)
        Config.Surv_ParryRadius = v
    end
})
ParryBox:AddSlider("Parry Face Sensitivity", {
    Default = 0.7,
    Min = 0.1,
    Max = 1,
    Decimal = true,
    Callback = function(v)
        Config.Surv_ParryFace = v
    end
})

-- AUTO SKILLCHECK
AbilityTab:AddToggle("Auto Skillcheck", {
    Default = false,
    Text = "Auto Skillcheck",
    Callback = function(v)
        Auto.SkillCheck = v
        if v then
            Connections.SkillHeartbeat = RunService.RenderStepped:Connect(function()
                if not Auto.SkillCheck then 
                    if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect(); Connections.SkillHeartbeat = nil end
                    return 
                end
                local skillCheck = PlayerGui:FindFirstChild("SkillCheck")
                if not skillCheck then return end
                local indicator = skillCheck:FindFirstChild("Indicator")
                if not indicator then return end
                local progress = indicator:GetAttribute("SkillCheck")
                local index = indicator:GetAttribute("Index")
                if progress and index and progress >= 98 and Auto.SkillCheckMode == "Legit" then
                    SkillCheckRemote:FireServer(index)
                elseif progress and index and progress >= 0 and Auto.SkillCheckMode == "Instant" then
                    SkillCheckRemote:FireServer(index)
                end
            end)
        else
            if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect(); Connections.SkillHeartbeat = nil end
        end
    end
})
AbilityTab:AddDropdown("Skillcheck Mode", {
    Default = "Legit",
    Values = {"Legit", "Instant"},
    Callback = function(v)
        Auto.SkillCheckMode = v
    end
})

-- FAST VAULT
AbilityTab:AddToggle("Fast Vault", {
    Default = false,
    Text = "Fast Vault",
    Callback = function(v)
        FastVault.Enabled = v
        toggleFastVault(v)
    end
})

-- GEN BYPASS
AbilityTab:AddToggle("Gen Bypass", {
    Default = false,
    Text = "Gen Bypass",
    Callback = function(v)
        setGenBypass(v)
        Library:Notify({
            Title = "Gen Bypass",
            Description = v and "Enabled! Click button on screen or press G" or "Disabled",
            Duration = 2
        })
    end
})

-- ============== AIMBOT ==============
AimlockBox:AddToggle("Silent Aim", {
    Default = false,
    Text = "Silent Aim",
    Callback = function(v)
        SilentAim.Enabled = v
        if v then setupSilentAimHook() else removeSilentAimHook() end
    end
})
AimlockBox:AddDropdown("Silent Target", {
    Default = "Killer",
    Values = {"Killer", "Survivor", "All", "SCP"},
    Callback = function(v)
        SilentAim.TargetMode = v
    end
})
AimlockBox:AddSlider("Silent FOV", {
    Default = 200,
    Min = 50,
    Max = 500,
    Callback = function(v)
        SilentAim.FOV = v
    end
})
AimlockBox:AddSlider("Silent Distance", {
    Default = 400,
    Min = 100,
    Max = 1000,
    Callback = function(v)
        SilentAim.Distance = v
    end
})
AimlockBox:AddToggle("Prediction", {
    Default = true,
    Text = "Prediction",
    Callback = function(v)
        SilentAim.Prediction = v
    end
})
AimlockBox:AddToggle("Wall Check", {
    Default = true,
    Text = "Wall Check",
    Callback = function(v)
        SilentAim.WallCheck = v
    end
})

-- ============== TWIST OF FATE AIM ==============
ToFBox:AddToggle("ToF Aim Assist", {
    Default = false,
    Text = "ToF Aim Assist",
    Callback = function(v)
        ToFAimConfig.Enabled = v
    end
})
ToFBox:AddDropdown("ToF Target", {
    Default = "Killer",
    Values = {"Killer", "Survivor", "SCP"},
    Callback = function(v)
        ToFAimConfig.TargetMode = v
    end
})
ToFBox:AddSlider("ToF Range", {
    Default = 90,
    Min = 20,
    Max = 200,
    Callback = function(v)
        ToFAimConfig.Range = v
    end
})
ToFBox:AddToggle("ToF Prediction", {
    Default = true,
    Text = "Prediction",
    Callback = function(v)
        ToFAimConfig.Predict = v
    end
})

-- ============== CROSSHAIR ==============
CrosshairBox:AddToggle("Crosshair", {
    Default = false,
    Text = "Crosshair",
    Callback = function(v)
        Crosshair.Enabled = v
        if v then
            local c = Drawing.new("Line")
            c.Color = Crosshair.Color
            c.Thickness = Crosshair.Thickness
            CrosshairDrawings[1] = c
            
            local c2 = Drawing.new("Line")
            c2.Color = Crosshair.Color
            c2.Thickness = Crosshair.Thickness
            CrosshairDrawings[2] = c2
        else
            for _, d in pairs(CrosshairDrawings) do
                if d and d.Remove then d:Remove() end
            end
            CrosshairDrawings = {}
        end
    end
})
CrosshairBox:AddDropdown("Crosshair Style", {
    Default = "Plus",
    Values = {"Plus", "Dot", "Circle"},
    Callback = function(v)
        Crosshair.Style = v
    end
})
CrosshairBox:AddColorPicker("Crosshair Color", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v)
        Crosshair.Color = v
        for _, d in pairs(CrosshairDrawings) do
            if d then d.Color = v end
        end
    end
})
CrosshairBox:AddSlider("Crosshair Size", {
    Default = 8,
    Min = 2,
    Max = 20,
    Callback = function(v)
        Crosshair.Size = v
    end
})
CrosshairBox:AddSlider("Crosshair Thickness", {
    Default = 2,
    Min = 1,
    Max = 5,
    Callback = function(v)
        Crosshair.Thickness = v
        for _, d in pairs(CrosshairDrawings) do
            if d then d.Thickness = v end
        end
    end
})

-- ============== ESP TAB ==============
ESPBox:AddToggle("ESP Survivor", {
    Default = false,
    Text = "Survivor ESP",
    Callback = function(v)
        ESP.Survivor = v
    end
})
ESPBox:AddToggle("ESP Killer", {
    Default = false,
    Text = "Killer ESP",
    Callback = function(v)
        ESP.Killer = v
    end
})
ESPBox:AddToggle("ESP Generator", {
    Default = false,
    Text = "Generator ESP",
    Callback = function(v)
        ESP.Generator = v
    end
})
ESPBox:AddToggle("ESP Pallet", {
    Default = false,
    Text = "Pallet ESP",
    Callback = function(v)
        ESP.Pallet = v
    end
})
ESPBox:AddToggle("ESP Window", {
    Default = false,
    Text = "Window ESP",
    Callback = function(v)
        ESP.Window = v
    end
})
ESPBox:AddToggle("ESP SCP", {
    Default = false,
    Text = "SCP ESP",
    Callback = function(v)
        ESP.SCP = v
    end
})
ESPBox:AddSlider("ESP Distance", {
    Default = 100,
    Min = 10,
    Max = 500,
    Callback = function(v)
        ESP.Distance = v
    end
})

ESPStatusBox:AddToggle("ESP Status", {
    Default = false,
    Text = "Enable Status ESP",
    Callback = function(v)
        ESPStatus.Enabled = v
    end
})
ESPStatusBox:AddToggle("Show Name", {
    Default = true,
    Text = "Show Name",
    Callback = function(v)
        ESPStatus.ShowName = v
    end
})
ESPStatusBox:AddToggle("Show Distance", {
    Default = true,
    Text = "Show Distance",
    Callback = function(v)
        ESPStatus.ShowDistance = v
    end
})
ESPStatusBox:AddToggle("Show Health", {
    Default = false,
    Text = "Show Health",
    Callback = function(v)
        ESPStatus.ShowHealth = v
    end
})
ESPStatusBox:AddToggle("Show Item", {
    Default = true,
    Text = "Show Item",
    Callback = function(v)
        ESPStatus.ShowItem = v
    end
})
ESPStatusBox:AddSlider("Status Radius", {
    Default = 100,
    Min = 10,
    Max = 500,
    Callback = function(v)
        ESPStatus.Radius = v
    end
})

-- ============== MISC TAB ==============
MovementBox:AddToggle("WalkSpeed", {
    Default = false,
    Text = "WalkSpeed",
    Callback = function(v)
        Movement.WalkSpeedEnabled = v
        if v then applyWalkSpeed() end
    end
})
MovementBox:AddInput("WalkSpeed Value", {
    Default = "17.6",
    Numeric = true,
    Finished = false,
    Callback = function(v)
        Movement.WalkSpeedValue = tonumber(v) or 16
        if Movement.WalkSpeedEnabled then applyWalkSpeed() end
    end
})
MovementBox:AddToggle("JumpPower", {
    Default = false,
    Text = "JumpPower",
    Callback = function(v)
        Movement.JumpPowerEnabled = v
        if v then applyJumpPower() end
    end
})
MovementBox:AddInput("JumpPower Value", {
    Default = "50",
    Numeric = true,
    Finished = false,
    Callback = function(v)
        Movement.JumpPowerValue = tonumber(v) or 50
        if Movement.JumpPowerEnabled then applyJumpPower() end
    end
})
MovementBox:AddToggle("NoClip", {
    Default = false,
    Text = "NoClip",
    Callback = function(v)
        toggleNoClip(v)
    end
})

-- EMOTE
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
        pcall(function()
            EmoteRemote:FireServer(Emote.Selected)
        end)
    end,
    Desc = "Play selected emote"
})
EmoteBox:AddButton({
    Text = "Stop Emote",
    Func = function()
        pcall(function()
            EmoteRemote:FireServer("Stop")
        end)
    end,
    Desc = "Stop current emote"
})

-- FAKE CHAT TAG
FunBox:AddToggle("Fake Chat Tag", {
    Default = false,
    Text = "Fake Chat Tag",
    Callback = function(v)
        FakeTag.Enabled = v
    end
})
FunBox:AddInput("Tag Text", {
    Default = "[BLUEHAVEN]",
    Numeric = false,
    Finished = false,
    Callback = function(v)
        FakeTag.Text = v or "[BLUEHAVEN]"
    end
})
FunBox:AddColorPicker("Tag Color", {
    Default = Color3.fromRGB(0, 191, 255),
    Callback = function(v)
        FakeTag.Color = "#" .. string.format("%02x%02x%02x", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
    end
})

-- HIDE NAME
FunBox:AddToggle("Hide Name", {
    Default = false,
    Text = "Hide Name",
    Callback = function(v)
        HideName.Enabled = v
        enableHideName(v)
    end
})
FunBox:AddKeybind("Hide Name Keybind", {
    Default = Enum.KeyCode.F3,
    Callback = function(v)
        HideName.Keybind = v
    end,
    Text = "Hide Name Keybind"
})

-- FAKE PARRY ANIMATION
FunBox:AddToggle("Fake Parry Animation", {
    Default = false,
    Text = "Fake Parry Animation",
    Callback = function(v)
        FakeParry.Enabled = v
    end
})
FunBox:AddDropdown("Fake Parry Animation", {
    Default = "Enten",
    Values = {"Enten", "Stopwatch", "Fih", "BloodShield"},
    Callback = function(v)
        FakeParry.Animation = v
    end
})
FunBox:AddKeybind("Fake Parry Keybind", {
    Default = Enum.KeyCode.V,
    Callback = function(v)
        FakeParry.Keybind = v
    end,
    Text = "Fake Parry Keybind"
})

-- AUTO FLEE
MovementBox:AddToggle("Auto Flee (Survivor)", {
    Default = false,
    Text = "Auto Flee",
    Callback = function(v)
        AutoFlee.Enabled = v
    end
})
MovementBox:AddSlider("Flee Distance", {
    Default = 50,
    Min = 10,
    Max = 100,
    Callback = function(v)
        AutoFlee.DetectDistance = v
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
        Lighting.FogEnd = v and 100000 or 1000
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
TimeBox:AddColorPicker("Ambient Color Picker", {
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
            Camera.MaxZoomDistance = CameraZoom.MaxDistance
            Camera.MinZoomDistance = CameraZoom.MinDistance
        else
            Camera.MaxZoomDistance = 400
            Camera.MinZoomDistance = 1
        end
    end
})
ZoomBox:AddSlider("Max Zoom Distance", {
    Default = 1000,
    Min = 100,
    Max = 5000,
    Callback = function(v)
        CameraZoom.MaxDistance = v
        if CameraZoom.UnlimitedZoom then
            Camera.MaxZoomDistance = v
        end
    end
})
ZoomBox:AddToggle("FOV Changer", {
    Default = false,
    Text = "FOV Changer",
    Callback = function(v)
        CameraZoom.FOVEnabled = v
        if v then
            Camera.FieldOfView = CameraZoom.FOV
        else
            Camera.FieldOfView = CameraZoom.DefaultFOV
        end
    end
})
ZoomBox:AddSlider("FOV Value", {
    Default = 70,
    Min = 1,
    Max = 120,
    Callback = function(v)
        CameraZoom.FOV = v
        if CameraZoom.FOVEnabled then
            Camera.FieldOfView = v
        end
    end
})

-- MORPH AVATAR (Ini hanya UI, tidak ada fungsi morph)
MorphAvaBox:AddLabel("Morph Avatar"):AddLabel("Morph fitur tidak tersedia di versi ini")

-- ============== UI SETTINGS ==============
SettingBox:AddButton({
    Text = "Save Config",
    Func = function()
        SaveManager:Save()
        Library:Notify({Title = "Config", Description = "Config saved!", Duration = 2})
    end
})
SettingBox:AddButton({
    Text = "Load Config",
    Func = function()
        SaveManager:Load()
        Library:Notify({Title = "Config", Description = "Config loaded!", Duration = 2})
    end
})
SettingBox:AddButton({
    Text = "Reset Config",
    Func = function()
        SaveManager:Reset()
        Library:Notify({Title = "Config", Description = "Config reset!", Duration = 2})
    end
})
SettingBox:AddDivider()
SettingBox:AddButton({
    Text = "Destroy UI",
    Func = function()
        Library:Destroy()
        Library:Notify({Title = "UI", Description = "UI destroyed!", Duration = 2})
    end
})

-- ============== THEME MANAGER ==============
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BluehavenHub")
SaveManager:IgnoreTheme = true
ThemeManager:SetFolder("BluehavenHub")

-- ============== MAIN LOOP ==============
RunService.Heartbeat:Connect(function()
    -- FPS Counter
    State.Frames = State.Frames + 1
    if tick() - State.LastTick >= 1 then
        State.FPS = State.Frames
        State.Frames = 0
        State.LastTick = tick()
    end
    
    -- Update footer
    local role = GetRole()
    Window:SetFooter(string.format("FPS: %d | Role: %s | %s", State.FPS, role, os.date("%H:%M:%S")))
    
    -- Auto Flee
    if AutoFlee.Enabled and role == "Survivor" then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local nearest = nil
            local nearDist = AutoFlee.DetectDistance
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
                    local khrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if khrp then
                        local dist = (khrp.Position - hrp.Position).Magnitude
                        if dist < nearDist then
                            nearDist = dist
                            nearest = p
                        end
                    end
                end
            end
            if nearest then
                local direction = (hrp.Position - nearest.Character.HumanoidRootPart.Position).Unit
                local moveVector = direction * 16
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                end)
            end
        end
    end
    
    -- Kill All
    if Killer.KillAll and role == "Killer" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and GetDistance(hrp.Position) <= Killer.KillRange then
                    pcall(function()
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            hum.Health = 0
                        end
                    end)
                end
            end
        end
    end
    
    -- God Mode
    if PlayerMods.GodMode then
        applyGodMode()
    end
    
    -- ESP UPDATE
    local root = getRoot()
    if root and (tick() - Timers.lastESPUpdate >= 0.1) then
        Timers.lastESPUpdate = tick()
        
        -- Update player ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isSurv = p.Team and p.Team.Name == "Survivors"
                local isKill = p.Team and p.Team.Name == "Killer"
                if (ESP.Survivor and isSurv) or (ESP.Killer and isKill) then
                    createStatusESP(p, p.Character, root)
                else
                    removeStatusESP(p.Character)
                end
            end
        end
        
        -- Update generator
        for gen in pairs(ESPCache.Generators) do
            if gen and gen.Parent then
                UpdateGenerator(gen)
            end
        end
        
        -- Update map objects
        for win in pairs(ESPCache.Windows) do
            if win and win.Parent then
                UpdateMapESP(win, root)
            end
        end
        for pal in pairs(ESPCache.Pallets) do
            if pal and pal.Parent then
                UpdateMapESP(pal, root)
            end
        end
        
        -- Update SCP
        UpdateSCPEsp(root)
    end
    
    -- Crosshair
    if Crosshair.Enabled then
        local center = Camera.ViewportSize / 2
        local size = Crosshair.Size
        local offset = Vector2.new(Crosshair.OffsetX, Crosshair.OffsetY)
        local c = center + offset
        
        if #CrosshairDrawings >= 2 then
            if Crosshair.Style == "Plus" then
                CrosshairDrawings[1].From = Vector2.new(c.X - size, c.Y)
                CrosshairDrawings[1].To = Vector2.new(c.X - 2, c.Y)
                CrosshairDrawings[2].From = Vector2.new(c.X + 2, c.Y)
                CrosshairDrawings[2].To = Vector2.new(c.X + size, c.Y)
                CrosshairDrawings[1].Visible = true
                CrosshairDrawings[2].Visible = true
            elseif Crosshair.Style == "Dot" then
                CrosshairDrawings[1].From = Vector2.new(c.X - 1, c.Y)
                CrosshairDrawings[1].To = Vector2.new(c.X + 1, c.Y)
                CrosshairDrawings[2].From = Vector2.new(c.X, c.Y - 1)
                CrosshairDrawings[2].To = Vector2.new(c.X, c.Y + 1)
                CrosshairDrawings[1].Visible = true
                CrosshairDrawings[2].Visible = true
            elseif Crosshair.Style == "Circle" then
                CrosshairDrawings[1].From = Vector2.new(c.X - size, c.Y)
                CrosshairDrawings[1].To = Vector2.new(c.X + size, c.Y)
                CrosshairDrawings[2].From = Vector2.new(c.X, c.Y - size)
                CrosshairDrawings[2].To = Vector2.new(c.X, c.Y + size)
                CrosshairDrawings[1].Visible = true
                CrosshairDrawings[2].Visible = true
            end
        end
    end
end)

-- CharacterAdded Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Movement.WalkSpeedEnabled then applyWalkSpeed() end
    if Movement.JumpPowerEnabled then applyJumpPower() end
    if Movement.NoClip then applyNoClip() end
    if PlayerMods.GodMode then applyGodMode() end
    if HideName.Enabled then hideOverheadName(true) end
    
    -- Reattach parry sensor ke semua killer
    if Config.Surv_AutoParry then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsKiller(p) and p.Character then
                AttachParrySensor(p.Character)
            end
        end
    end
end)

-- Setup Players
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        SetupPlayer(p)
    end
end
Players.PlayerAdded:Connect(SetupPlayer)

-- Silent Aim init
setupSilentAimHook()

-- ==== AUTO START ====
if Config.Surv_AutoParry then
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            AttachParrySensor(p.Character)
        end
    end
end

-- UI siap!
Library:Notify({
    Title = "Bluehaven Hub",
    Description = "Script loaded successfully!",
    Duration = 3
})

print("✅ Bluehaven Hub loaded! Enjoy!")
