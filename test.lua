local _BH_FN = {}
local previousRuntimeStop = nil
pcall(function()
local env =
(type(getgenv) == "function" and getgenv())
or _G
previousRuntimeStop = env.__BLUEHAVEN_RUNTIME_STOP
env.__BLUEHAVEN_RUNTIME_STOP = nil
env.__BLUEHAVEN_GUI_CLEANUP = nil
end)
if type(previousRuntimeStop) == "function" then
pcall(previousRuntimeStop)
end
function _BH_FN.BH_CleanupOldGui()
local roots = {}
local seenRoots = {}
local function addRoot(root)
if root and not seenRoots[root] then
seenRoots[root] = true
roots[#roots + 1] = root
end
end
pcall(function()
addRoot(game:GetService("CoreGui"))
end)
pcall(function()
if type(gethui) == "function" then
addRoot(gethui())
end
end)
pcall(function()
local pg = game:GetService("Players").LocalPlayer
and game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
addRoot(pg)
end)
local destroyed = {}
for _, root in ipairs(roots) do
local ok, descendants = pcall(function()
return root:GetDescendants()
end)
if ok and descendants then
for _, obj in ipairs(descendants) do
local isText =
obj:IsA("TextLabel")
or obj:IsA("TextButton")
or obj:IsA("TextBox")
if isText then
local value = ""
pcall(function()
value = tostring(obj.Text or "")
end)
local normalized = string.lower(value)
if string.find(
normalized,
"bluehaven hub",
1,
true
) == 1 then
local gui =
obj:FindFirstAncestorOfClass("ScreenGui")
if gui
and not destroyed[gui] then
destroyed[gui] = true
pcall(function()
gui:Destroy()
end)
end
end
end
end
end
end
end
pcall(_BH_FN.BH_CleanupOldGui)
local WindUI = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()
local UI_TOUCH_DEVICE = game:GetService("UserInputService").TouchEnabled
local UI_INITIAL_VIEWPORT = workspace.CurrentCamera
and workspace.CurrentCamera.ViewportSize
or Vector2.new(800, 600)
local UI_TWO_COLUMN = not UI_TOUCH_DEVICE
or UI_INITIAL_VIEWPORT.X >= 780
local BLUEHAVEN_OBSIDIAN_THEME = "Bluehaven Ocean"
local bluehavenThemeReady = pcall(function()
local theme = {Name = BLUEHAVEN_OBSIDIAN_THEME}
local themes = WindUI:GetThemes()
local dark = type(themes) == "table" and themes.Dark
if type(dark) == "table" then
for key, value in pairs(dark) do
if typeof(value) == "Color3" then
local level = math.clamp(
value.R * 0.299
+ value.G * 0.587
+ value.B * 0.114,
0,
1
)
theme[key] = Color3.fromRGB(
math.floor(2 + level * 30),
math.floor(10 + level * 78),
math.floor(24 + level * 143)
)
else
theme[key] = value
end
end
end
theme.Name = BLUEHAVEN_OBSIDIAN_THEME
theme.Accent = Color3.fromRGB(4, 34, 72)
theme.Background = Color3.fromRGB(2, 10, 24)
theme.Dialog = Color3.fromRGB(5, 23, 47)
theme.Outline = Color3.fromRGB(20, 79, 134)
theme.Text = Color3.fromRGB(235, 248, 255)
theme.Placeholder = Color3.fromRGB(119, 164, 201)
theme.Button = Color3.fromRGB(8, 35, 70)
theme.Icon = Color3.fromRGB(148, 205, 240)
theme.Toggle = Color3.fromRGB(69, 179, 244)
theme.Slider = Color3.fromRGB(43, 142, 228)
theme.Checkbox = Color3.fromRGB(72, 184, 247)
theme.Primary = Color3.fromRGB(63, 169, 244)
theme.PanelBackground = Color3.fromRGB(2, 13, 30)
theme.PanelBackgroundTransparency = 1
theme.LabelBackground = Color3.fromRGB(12, 35, 66)
theme.LabelBackgroundTransparency = 0.16
WindUI:AddTheme(theme)
end)
if not bluehavenThemeReady then
BLUEHAVEN_OBSIDIAN_THEME = "Dark"
end
WindUI._BluehavenSetThemeUnlocked = WindUI.SetTheme
function WindUI:_ApplyBluehavenFixedTheme()
if type(self._BluehavenSetThemeUnlocked) ~= "function" then
return false
end
return pcall(
self._BluehavenSetThemeUnlocked,
self,
BLUEHAVEN_OBSIDIAN_THEME
)
end
WindUI:_ApplyBluehavenFixedTheme()
function WindUI:SetTheme()
if type(self._BluehavenSetThemeUnlocked) == "function" then
return self._BluehavenSetThemeUnlocked(
self,
BLUEHAVEN_OBSIDIAN_THEME
)
end
end
local Library = {
Options = {},
Toggles = {},
KeybindFrame = {Visible = false},
Unloaded = false,
_UnloadCallbacks = {},
_Window = nil,
_KeybindConnection = nil,
}
local function windSafeCall(object, method, ...)
local fn = object and object[method]
if type(fn) ~= "function" then
return false, nil
end
return pcall(fn, object, ...)
end
local function windKeyValue(value)
if typeof(value) == "EnumItem" then
local name = string.lower(value.Name)
if name == "none" or name == "unknown" then
return Enum.KeyCode.Unknown
end
return value
end
local name = tostring(value or "Unknown")
if string.lower(name) == "none"
or string.lower(name) == "unknown" then
return Enum.KeyCode.Unknown
end
return Enum.KeyCode[name]
or Enum.UserInputType[name]
or Enum.KeyCode.Unknown
end
local function windAttachInlineColorPicker(
owner,
picker
)
if not owner
or owner._Kind ~= "Toggle"
or not picker then
return
end
task.defer(function()
pcall(function()
local ownerRaw = owner.Raw
local pickerRaw = picker.Raw
local ownerMain = ownerRaw
and ownerRaw.ToggleFrame
and ownerRaw.ToggleFrame.UIElements
and ownerRaw.ToggleFrame.UIElements.Main
local swatch = pickerRaw
and pickerRaw.UIElements
and pickerRaw.UIElements.Colorpicker
if typeof(ownerMain) ~= "Instance"
or typeof(swatch) ~= "Instance" then
return
end
swatch.Parent = ownerMain
swatch.Name = "InlineColorPicker"
swatch.AnchorPoint = Vector2.new(1, 0.5)
swatch.Position = UDim2.new(1, -48, 0.5, 0)
swatch.Size = UDim2.fromOffset(22, 22)
swatch.ZIndex = math.max(
swatch.ZIndex,
ownerMain.ZIndex + 2
)
local pickerMain = pickerRaw
and pickerRaw.ColorpickerFrame
and pickerRaw.ColorpickerFrame.UIElements
and pickerRaw.ColorpickerFrame.UIElements.Main
if typeof(pickerMain) == "Instance"
and pickerMain ~= ownerMain then
pickerMain.Visible = false
pickerMain.Size = UDim2.fromOffset(0, 0)
pcall(function()
pickerMain.AutomaticSize =
Enum.AutomaticSize.None
end)
end
end)
end)
end
local function windDispatch(element, value, ...)
if element._Kind == "Keybind" then
value = windKeyValue(value)
end
element.Value = value
element._Generation = element._Generation + 1
if type(element._RefreshStateGlyph) == "function" then
element._RefreshStateGlyph(value == true)
end
if type(element._Callback) == "function" then
local ok, err = pcall(element._Callback, value, ...)
if not ok then warn("[Bluehaven/WindUI] callback: " .. tostring(err)) end
end
for _, callback in ipairs(element._ChangedCallbacks) do
local ok, err = pcall(callback, value)
if not ok then warn("[Bluehaven/WindUI] changed: " .. tostring(err)) end
end
end
local windCreateElement
local function windWrapElement(raw, parent, kind, id, config, default)
local element = {
Raw = raw,
Parent = parent,
Value = default,
_Kind = kind,
_Callback = config and config.Callback,
_ChangedCallback = config and config.ChangedCallback,
_ChangedCallbacks = {},
_Generation = 0,
}
function element:OnChanged(callback)
if type(callback) == "function" then
self._ChangedCallbacks[#self._ChangedCallbacks + 1] = callback
end
return self
end
function element:SetValue(value)
local before = self._Generation
local ok = false
if self._Kind == "Dropdown" then
ok = select(1, windSafeCall(self.Raw, "Select", value))
else
ok = select(1, windSafeCall(self.Raw, "Set", value))
end
if not ok or self._Generation == before then
windDispatch(self, value)
end
return self
end
function element:SetValueRGB(value)
local before = self._Generation
local ok = select(1, windSafeCall(self.Raw, "Set", value))
if not ok or self._Generation == before then
windDispatch(self, value)
end
return self
end
function element:SetValues(values)
windSafeCall(self.Raw, "Refresh", values)
return self
end
function element:SetText(text)
local changed = select(1, windSafeCall(self.Raw, "SetTitle", text))
if not changed then
windSafeCall(self.Raw, "SetDesc", text)
end
return self
end
function element:AddColorPicker(optionId, optionConfig)
local picker = windCreateElement(
self.Parent,
"Colorpicker",
optionId,
optionConfig or {}
)
windAttachInlineColorPicker(
self,
picker
)
return picker
end
function element:AddKeyPicker(optionId, optionConfig)
return windCreateElement(
self.Parent,
"Keybind",
optionId,
optionConfig or {}
)
end
function element:AddButton(buttonConfig)
return windCreateElement(
self.Parent,
"Button",
nil,
buttonConfig or {}
)
end
if type(element._ChangedCallback) == "function" then
element._ChangedCallbacks[#element._ChangedCallbacks + 1] =
element._ChangedCallback
end
if id then
if kind == "Toggle" then
Library.Toggles[id] = element
else
Library.Options[id] = element
end
end
return element
end
local function windCompactElementText(raw, expectedTitle)
local seen = {}
local function compactInstance(instance)
if not instance:IsA("TextLabel") then return end
local name = string.lower(instance.Name)
local expected = tostring(expectedTitle or "")
local isControlText = name == "title"
or name == "desc"
or name == "description"
or string.find(name, "title", 1, true) ~= nil
or string.find(name, "description", 1, true) ~= nil
or (expected ~= "" and instance.Text == expected)
if not isControlText then
return
end
instance.TextWrapped = false
instance.TextScaled = false
instance.TextTruncate = Enum.TextTruncate.AtEnd
if instance.TextSize > (UI_TOUCH_DEVICE and 14 or 13) then
instance.TextSize = UI_TOUCH_DEVICE and 14 or 13
end
end
local function visit(value, depth)
if depth > 4 then return end
if typeof(value) == "Instance" then
compactInstance(value)
for _, descendant in ipairs(value:GetDescendants()) do
compactInstance(descendant)
end
return
end
if type(value) ~= "table" or seen[value] then return end
seen[value] = true
for key, child in pairs(value) do
local keyName = tostring(key)
if depth == 0
or keyName == "UIElements"
or keyName == "Title"
or keyName == "Desc"
or keyName == "Description"
or string.find(keyName, "Frame", 1, true) then
visit(child, depth + 1)
end
end
end
pcall(visit, raw, 0)
end
local WIND_CONTROL_ICON_RULES = {
{"bypass cooldown", "timer-off"},
{"no attack slow", "gauge"},
{"bypass leap", "rabbit"},
{"third person", "camera"},
{"kill all", "skull"},
{"anti blind", "eye"},
{"block vault", "shield-ban"},
{"auto crouch", "person-standing"},
{"self heal", "heart-pulse"},
{"fast vault", "move-up-right"},
{"anti slow", "shield"},
{"pistol target", "target"},
{"veil target", "scan-eye"},
{"light flashlight", "flashlight"},
{"tool assist prediction", "route"},
{"tool assist use fov", "scan"},
{"tool assist tracer", "scan-line"},
{"pistol stable", "crosshair"},
{"esp survivor", "users"},
{"esp killer", "skull"},
{"esp generator", "zap"},
{"esp pallet", "panels-top-left"},
{"esp window", "panel-top"},
{"esp hook", "anchor"},
{"esp scp", "triangle-alert"},
{"show item", "package"},
{"movement boost", "rocket"},
{"noclip", "ghost"},
{"anti knockdown", "shield-plus"},
{"anti loop", "refresh-cw"},
{"fake chat tag", "tag"},
{"hide name", "eye-off"},
{"fullbright", "sun"},
{"no shadow", "moon"},
{"no fog", "cloud-sun"},
{"set clock", "clock-3"},
{"ambient color", "palette"},
{"unlimited zoom", "search"},
{"fov changer", "scan"},
{"show keybind", "keyboard"},
{"ui animation", "wand-sparkles"},
{"auto save", "save"},
{"heal", "heart-pulse"},
{"health", "heart-pulse"},
{"aim", "crosshair"},
{"crosshair", "crosshair"},
{"fov", "scan"},
{"zoom", "zoom-in"},
{"esp", "eye"},
{"name", "user-round"},
{"chat", "message-circle"},
{"tag", "tag"},
{"skill", "badge-check"},
{"parry", "shield-check"},
{"generator", "zap"},
{"pallet", "panels-top-left"},
{"vault", "move-up-right"},
{"window", "panel-top"},
{"clock", "clock-3"},
{"ambient", "palette"},
{"color", "palette"},
{"shadow", "sun"},
{"fog", "cloud-fog"},
{"light", "sun"},
{"morph", "user-round-cog"},
{"emote", "music-2"},
{"config", "save"},
{"auto save", "save"},
{"speed", "gauge"},
{"delay", "timer"},
{"frequency", "activity"},
{"distance", "ruler"},
{"range", "radio"},
{"size", "maximize-2"},
{"transparency", "blend"},
}
local function windControlIcon(title, kind)
local normalized = string.lower(tostring(title or ""))
for _, rule in ipairs(WIND_CONTROL_ICON_RULES) do
if string.find(normalized, rule[1], 1, true) then
return rule[2]
end
end
if kind == "Slider" then
return "sliders-horizontal"
end
return "toggle-right"
end
local function windInstallToggleStateGlyph(raw, element, initialValue)
pcall(function()
local toggleFrame = raw
and raw.ToggleFrame
and raw.ToggleFrame.UIElements
and raw.ToggleFrame.UIElements.Main
local switch = toggleFrame
and toggleFrame:FindFirstChild("ToggleFrame", true)
local knob = switch and switch:FindFirstChild("Frame")
if not knob then return end
local old = knob:FindFirstChild("BluehavenStateIcon")
if old then old:Destroy() end
for _, child in ipairs(knob:GetDescendants()) do
if child:IsA("ImageLabel") or child:IsA("TextLabel") then
child.Visible = false
end
end
switch.BorderSizePixel = 0
switch.BackgroundColor3 = Color3.fromRGB(23, 50, 76)
switch.BackgroundTransparency = 0
switch.ClipsDescendants = true
local switchCorner = switch:FindFirstChildOfClass("UICorner")
or Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(1, 0)
switchCorner.Parent = switch
local trackGradient = switch:FindFirstChild(
"BluehavenToggleGradient"
)
if trackGradient and not trackGradient:IsA("UIGradient") then
trackGradient:Destroy()
trackGradient = nil
end
trackGradient = trackGradient or Instance.new("UIGradient")
trackGradient.Name = "BluehavenToggleGradient"
trackGradient.Rotation = 0
trackGradient.Color = ColorSequence.new(
Color3.fromRGB(255, 255, 255),
Color3.fromRGB(188, 229, 255)
)
trackGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.82),
NumberSequenceKeypoint.new(0.48, 0.94),
NumberSequenceKeypoint.new(1, 1),
})
trackGradient.Parent = switch
for _, child in ipairs(switch:GetChildren()) do
if child:IsA("UIGradient") and child ~= trackGradient then
child.Enabled = false
end
end
local trackStroke = switch:FindFirstChild("BluehavenToggleStroke")
if trackStroke and not trackStroke:IsA("UIStroke") then
trackStroke:Destroy()
trackStroke = nil
end
trackStroke = trackStroke or Instance.new("UIStroke")
trackStroke.Name = "BluehavenToggleStroke"
trackStroke.Thickness = 1
trackStroke.Parent = switch
knob.BorderSizePixel = 0
knob.BackgroundTransparency = 0
local knobPixels = UI_TOUCH_DEVICE and 18 or 16
knob.Size = UDim2.fromOffset(knobPixels, knobPixels)
local knobCorner = knob:FindFirstChildOfClass("UICorner")
or Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob
local knobStroke = knob:FindFirstChild("BluehavenKnobStroke")
if knobStroke and not knobStroke:IsA("UIStroke") then
knobStroke:Destroy()
knobStroke = nil
end
knobStroke = knobStroke or Instance.new("UIStroke")
knobStroke.Name = "BluehavenKnobStroke"
knobStroke.Thickness = 1
knobStroke.Parent = knob
local trackTween = nil
local strokeTween = nil
local knobTween = nil
local knobStrokeTween = nil
local transition = TweenInfo.new(
0.18,
Enum.EasingStyle.Quint,
Enum.EasingDirection.Out
)
element._RefreshStateGlyph = function(enabled)
if not switch.Parent or not knob.Parent then return end
switch.BackgroundTransparency = 0
knob.BackgroundTransparency = 0
knob.Size = UDim2.fromOffset(knobPixels, knobPixels)
local trackColor = enabled
and Color3.fromRGB(32, 166, 228)
or Color3.fromRGB(23, 50, 76)
local strokeColor = enabled
and Color3.fromRGB(126, 222, 255)
or Color3.fromRGB(78, 124, 158)
local knobColor = enabled
and Color3.fromRGB(248, 253, 255)
or Color3.fromRGB(205, 224, 237)
local knobOutlineColor = enabled
and Color3.fromRGB(195, 235, 255)
or Color3.fromRGB(119, 158, 187)
local trackStrokeTransparency = enabled and 0.30 or 0.58
local knobStrokeTransparency = enabled and 0.20 or 0.55
if not element._ToggleStyleReady then
switch.BackgroundColor3 = trackColor
trackStroke.Color = strokeColor
trackStroke.Transparency = trackStrokeTransparency
knob.BackgroundColor3 = knobColor
knobStroke.Color = knobOutlineColor
knobStroke.Transparency = knobStrokeTransparency
element._ToggleStyleReady = true
return
end
for _, tween in ipairs({
trackTween,
strokeTween,
knobTween,
knobStrokeTween,
}) do
if tween then pcall(function() tween:Cancel() end) end
end
trackTween = TweenService:Create(switch, transition, {
BackgroundColor3 = trackColor,
})
strokeTween = TweenService:Create(trackStroke, transition, {
Color = strokeColor,
Transparency = trackStrokeTransparency,
})
knobTween = TweenService:Create(knob, transition, {
BackgroundColor3 = knobColor,
})
knobStrokeTween = TweenService:Create(knobStroke, transition, {
Color = knobOutlineColor,
Transparency = knobStrokeTransparency,
})
trackTween:Play()
strokeTween:Play()
knobTween:Play()
knobStrokeTween:Play()
end
element._RefreshStateGlyph(initialValue == true)
end)
end
local function windPolishNativeToggle(raw, element)
local function apply()
pcall(function()
local toggleFrame = raw
and raw.ToggleFrame
and raw.ToggleFrame.UIElements
and raw.ToggleFrame.UIElements.Main
local switch = toggleFrame
and toggleFrame:FindFirstChild("ToggleFrame", true)
local knob = switch
and switch:FindFirstChild("Frame")
if not switch or not knob then
return
end
switch.BorderSizePixel = 0
switch.ClipsDescendants = true
knob.BorderSizePixel = 0
knob.BackgroundColor3 = Color3.fromRGB(250, 253, 255)
knob.BackgroundTransparency = 0
local knobCorner = knob:FindFirstChildOfClass("UICorner")
or Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob
for _, child in ipairs(switch:GetDescendants()) do
if child:IsA("UIStroke") then
child:Destroy()
elseif child:IsDescendantOf(knob)
and (
child:IsA("ImageLabel")
or child:IsA("ImageButton")
or child:IsA("TextLabel")
or child:IsA("TextButton")
) then
child.Visible = false
end
end
end)
end
element._RefreshStateGlyph = function()
task.defer(apply)
end
task.defer(apply)
task.delay(0.08, apply)
end
windCreateElement = function(parent, kind, id, config)
config = config or {}
local title = config.Text or config.Title or id or ""
local default = config.Default
if kind == "Toggle" and default == nil then default = false end
if kind == "Input" and default == nil then default = "" end
if kind == "Dropdown" and default == nil and not config.AllowNull then
default = config.Values and config.Values[1] or nil
end
if kind == "Keybind" then default = windKeyValue(default) end
local element
local rawConfig = {
Title = title,
Desc = config.Desc,
Flag = id,
Callback = function(value, ...)
if element then windDispatch(element, value, ...) end
end,
}
if kind == "Toggle" then
rawConfig.Icon = nil
rawConfig.IconThemed = false
rawConfig.Animation = true
rawConfig.Justify = "Left"
elseif kind == "Slider" then
rawConfig.Icon = config.Icon
rawConfig.IconThemed = config.Icon ~= nil
rawConfig.IconAlign = "Left"
rawConfig.Justify = "Left"
end
if kind == "Toggle" then
rawConfig.Value = default
rawConfig.Type = "Toggle"
rawConfig.Size = UDim2.new(
1,
0,
0,
UI_TOUCH_DEVICE and 40 or 32
)
elseif kind == "Slider" then
rawConfig.Value = {
Min = config.Min or 0,
Max = config.Max or 100,
Default = default or config.Min or 0,
}
rawConfig.Step = 1 / (10 ^ math.max(0, tonumber(config.Rounding) or 0))
elseif kind == "Dropdown" then
rawConfig.Values = config.Values or {}
rawConfig.Value = default
rawConfig.AllowNone = config.AllowNull == true
rawConfig.Multi = config.Multi == true
rawConfig.SearchBarEnabled = #(config.Values or {}) > 8
elseif kind == "Input" then
rawConfig.Value = default
rawConfig.Placeholder = config.Placeholder or ""
elseif kind == "Colorpicker" then
rawConfig.Default = default or Color3.new(1, 1, 1)
rawConfig.Transparency = config.Transparency
elseif kind == "Keybind" then
rawConfig.Value = typeof(default) == "EnumItem" and default.Name or default
rawConfig.Callback = function(...)
if type(config.Callback) == "function" then
local ok, err = pcall(config.Callback, ...)
if not ok then warn("[Bluehaven/WindUI] keybind: " .. tostring(err)) end
end
end
elseif kind == "Button" then
rawConfig.Icon = config.Icon
rawConfig.IconThemed = config.IconThemed ~= false
rawConfig.Justify = config.Justify or "Center"
rawConfig.Size = config.Size
rawConfig.Callback = config.Func or config.Callback or function() end
end
local ok, raw = windSafeCall(parent, kind, rawConfig)
if not ok then
warn("[Bluehaven/WindUI] gagal membuat " .. kind .. ": " .. tostring(raw))
raw = {}
end
windCompactElementText(raw, title)
task.defer(function()
windCompactElementText(raw, title)
end)
task.delay(0.08, function()
windCompactElementText(raw, title)
end)
task.delay(0.30, function()
windCompactElementText(raw, title)
end)
element = windWrapElement(raw, parent, kind, id, config, default)
if kind == "Toggle" then
windPolishNativeToggle(raw, element)
end
if kind == "Keybind" and raw then
element._Callback = nil
windSafeCall(raw, "OnChanged", function(value)
windDispatch(element, value)
end)
end
return element
end
local function windWrapContainer(raw)
local container = {
Raw = raw,
_Columns = nil,
}
local function ensureColumns(owner)
if owner._Columns then
return owner._Columns
end
if not UI_TWO_COLUMN then
owner._Columns = {
Left = owner.Raw,
Right = owner.Raw,
}
return owner._Columns
end
local _, row = windSafeCall(owner.Raw, "HStack", {
AutoSpace = false,
})
local _, left = windSafeCall(row, "VStack", {Gap = 6})
local _, right = windSafeCall(row, "VStack", {Gap = 6})
if row and left and right then
owner._Columns = {
Row = row,
Left = left,
Right = right,
}
else
owner._Columns = {
Left = owner.Raw,
Right = owner.Raw,
}
end
return owner._Columns
end
function container:AddToggle(id, config)
return windCreateElement(self.Raw, "Toggle", id, config)
end
function container:AddSlider(id, config)
return windCreateElement(self.Raw, "Slider", id, config)
end
function container:AddDropdown(id, config)
return windCreateElement(self.Raw, "Dropdown", id, config)
end
function container:AddInput(id, config)
return windCreateElement(self.Raw, "Input", id, config)
end
function container:AddColorPicker(id, config)
return windCreateElement(self.Raw, "Colorpicker", id, config)
end
function container:AddKeyPicker(id, config)
return windCreateElement(self.Raw, "Keybind", id, config)
end
function container:AddButton(config)
return windCreateElement(self.Raw, "Button", nil, config)
end
function container:AddButtonRow(leftConfig, rightConfig)
local _, row = windSafeCall(self.Raw, "HStack", {
Gap = UI_TOUCH_DEVICE and 8 or 6,
AutoSpace = false,
})
row = row or self.Raw
local buttonHeight = UI_TOUCH_DEVICE and 40 or 32
leftConfig = leftConfig or {}
rightConfig = rightConfig or {}
leftConfig.Size = leftConfig.Size or UDim2.new(0.5, -3, 0, buttonHeight)
rightConfig.Size = rightConfig.Size or UDim2.new(0.5, -3, 0, buttonHeight)
local left = windCreateElement(row, "Button", nil, leftConfig)
local right = windCreateElement(row, "Button", nil, rightConfig)
return left, right
end
function container:AddLabel(text)
local _, rawLabel = windSafeCall(self.Raw, "Paragraph", {
Title = tostring(text or ""),
})
return windWrapElement(rawLabel or {}, self.Raw, "Label", nil, {}, text)
end
function container:AddDivider()
windSafeCall(self.Raw, "Divider")
return self
end
function container:AddLeftGroupbox(title, icon)
local columns = ensureColumns(self)
local _, section = windSafeCall(columns.Left, "Section", {
Title = title,
Icon = icon,
Opened = true,
Box = true,
})
return windWrapContainer(section or columns.Left)
end
function container:AddRightGroupbox(title, icon)
local columns = ensureColumns(self)
local _, section = windSafeCall(columns.Right, "Section", {
Title = title,
Icon = icon,
Opened = true,
Box = true,
})
return windWrapContainer(section or columns.Right)
end
function container:AddRightTabbox()
local _, switchBar = windSafeCall(self.Raw, "HStack", {
AutoSpace = false,
})
local tabbox = {
Parent = self.Raw,
SwitchBar = switchBar or self.Raw,
Pages = {},
Selected = 1,
}
function tabbox:_Select(index)
self.Selected = index
for pageIndex, page in ipairs(self.Pages) do
local selected = pageIndex == index
local frame = page.Raw and page.Raw.ElementFrame
if frame then
frame.Visible = selected
end
local buttonFrame = page.Button and page.Button.ButtonFrame
windSafeCall(
buttonFrame,
"SetTitle",
page.Title
)
end
end
function tabbox:AddTab(title, icon)
local _, pageRaw = windSafeCall(self.Parent, "VStack", {
Gap = 6,
})
if not pageRaw then
_, pageRaw = windSafeCall(self.Parent, "Section", {
Title = title,
Icon = icon,
Opened = true,
Box = true,
})
end
pageRaw = pageRaw or self.Parent
local pageIndex = #self.Pages + 1
local page = {
Title = tostring(title or ("Tab " .. pageIndex)),
Icon = icon,
Raw = pageRaw,
Button = nil,
}
self.Pages[pageIndex] = page
local _, button = windSafeCall(self.SwitchBar, "Button", {
Title = page.Title,
Icon = icon,
IconThemed = true,
Justify = "Center",
IconAlign = "Left",
Size = UDim2.new(1, 0, 0, UI_TOUCH_DEVICE and 40 or 34),
Callback = function()
self:_Select(pageIndex)
end,
})
page.Button = button
self:_Select(self.Selected)
return windWrapContainer(pageRaw)
end
return tabbox
end
return container
end
function Library:Notify(config)
config = config or {}
WindUI:Notify({
Title = config.Title or "Bluehaven",
Content = config.Description or config.Content or "",
Duration = config.Time or config.Duration or 2,
Icon = config.Icon or "bell",
})
end
function Library:CreateWindow(config)
config = config or {}
local icon = tostring(config.Icon or "")
if icon:match("^%d+$") then icon = "rbxassetid://" .. icon end
local iconSize = math.clamp(tonumber(config.IconSize) or 36, 20, 38)
local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
local windowSize = config.Size or UDim2.fromOffset(700, 420)
local minSize = Vector2.new(620, 370)
local maxSize = Vector2.new(900, 620)
local sidebarWidth = config.SideBarWidth or 140
if UI_TOUCH_DEVICE then
local width = math.clamp(viewport.X - 24, 350, 760)
local height = math.clamp(viewport.Y - 64, 320, 440)
windowSize = UDim2.fromOffset(width, height)
minSize = Vector2.new(math.min(340, width), math.min(300, height))
maxSize = Vector2.new(780, 540)
sidebarWidth = math.clamp(math.floor(width * 0.22), 105, 135)
end
local raw = WindUI:CreateWindow({
Title = config.Title or "Bluehaven Hub",
Author = config.Author,
Icon = icon ~= "" and icon or "wind",
IconSize = iconSize,
IconRadius = 6,
IconThemed = false,
Theme = BLUEHAVEN_OBSIDIAN_THEME,
Folder = "BluehavenHub",
Footer = config.Footer,
User = config.User,
Size = windowSize,
MinSize = minSize,
MaxSize = maxSize,
SideBarWidth = sidebarWidth,
Radius = config.CornerRadius or config.Radius or 9,
Resizable = true,
AutoScale = true,
Acrylic = false,
Transparent = false,
ShadowTransparency = 0.45,
HidePanelBackground = false,
NewElements = false,
HideSearchBar = true,
ScrollBarEnabled = false,
Topbar = {
Height = config.TopbarHeight
or (UI_TOUCH_DEVICE and 42 or 44),
ButtonsType = "Default",
},
ToggleKey = Enum.KeyCode.RightShift,
OpenButton = {
Title = "BH",
Enabled = true,
Draggable = true,
OnlyMobile = true,
Scale = 0.42,
CornerRadius = UDim.new(1, 0),
StrokeThickness = 1,
Color = ColorSequence.new(
Color3.fromRGB(12, 12, 12),
Color3.fromRGB(38, 38, 38)
),
},
})
local window = windWrapContainer(raw)
window.Raw = raw
window.ConfigManager = raw and raw.ConfigManager
function window:AddTab(title, tabIcon, description)
local _, tab = windSafeCall(self.Raw, "Tab", {
Title = title,
Icon = tabIcon,
Desc = description,
})
return windWrapContainer(tab or self.Raw)
end
function window:Toggle()
local ok = select(1, windSafeCall(self.Raw, "Toggle"))
if ok then return end
for _, root in ipairs({
game:GetService("CoreGui"),
game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui"),
}) do
if root then
for _, object in ipairs(root:GetDescendants()) do
if (object:IsA("TextLabel") or object:IsA("TextButton"))
and object.Text == (config.Title or "Bluehaven Hub") then
local gui = object:FindFirstAncestorOfClass("ScreenGui")
if gui then gui.Enabled = not gui.Enabled; return end
end
end
end
end
end
function window:SetAnimations(value)
windSafeCall(self.Raw, "SetAnimations", value)
end
function window:SetFooter(value)
windSafeCall(self.Raw, "SetFooter", value)
end
Library._Window = window
return window
end
function Library:OnUnload(callback)
if type(callback) == "function" then
self._UnloadCallbacks[#self._UnloadCallbacks + 1] = callback
end
end
function Library:Unload()
if self.Unloaded then return end
self.Unloaded = true
if self._KeybindConnection then
pcall(function() self._KeybindConnection:Disconnect() end)
self._KeybindConnection = nil
end
for _, callback in ipairs(self._UnloadCallbacks) do
pcall(callback)
end
local raw = self._Window and self._Window.Raw
local destroyed = select(1, windSafeCall(raw, "Destroy"))
if not destroyed then
pcall(function() WindUI:Destroy() end)
end
end
setmetatable(Library, {
__newindex = function(self, key, value)
rawset(self, key, value)
if key ~= "ToggleKeybind" then return end
local selected = value and value.Value
if self._Window and typeof(selected) == "EnumItem" then
windSafeCall(self._Window.Raw, "SetToggleKey", selected)
end
if value and type(value.OnChanged) == "function" then
value:OnChanged(function(newKey)
if self._Window and typeof(newKey) == "EnumItem" then
windSafeCall(self._Window.Raw, "SetToggleKey", newKey)
end
end)
end
end,
})
local ThemeManager = {}
function ThemeManager:SetLibrary() end
function ThemeManager:SetFolder() end
function ThemeManager:ApplyToTab()
WindUI:_ApplyBluehavenFixedTheme()
end
local SaveManager = {
Folder = "BluehavenHub",
Ignore = {},
}
function SaveManager:SetLibrary() end
function SaveManager:SetFolder(folder) self.Folder = folder end
function SaveManager:IgnoreThemeSettings() end
function SaveManager:SetIgnoreIndexes(indexes)
for _, index in ipairs(indexes or {}) do self.Ignore[index] = true end
end
function SaveManager:_SettingsFolder()
return tostring(self.Folder) .. "/settings"
end
function SaveManager:_EnsureFolder()
if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
return false, "folder API tidak tersedia"
end
if not isfolder(self.Folder) then makefolder(self.Folder) end
local settings = self:_SettingsFolder()
if not isfolder(settings) then makefolder(settings) end
return true
end
local function windEncodeValue(value)
if typeof(value) == "Color3" then
return {__windType = "Color3", R = value.R, G = value.G, B = value.B}
end
if typeof(value) == "EnumItem" then
return {
__windType = "EnumItem",
EnumType = tostring(value.EnumType),
Name = value.Name,
}
end
if type(value) == "boolean" or type(value) == "number"
or type(value) == "string" or type(value) == "table" then
return value
end
return tostring(value)
end
local function windDecodeValue(value)
if type(value) ~= "table" then return value end
if value.__windType == "Color3" then
return Color3.new(value.R or 1, value.G or 1, value.B or 1)
end
if value.__windType == "EnumItem" then
local enumName = tostring(value.EnumType or ""):match("Enum%.(.+)")
local enumType = enumName and Enum[enumName]
return enumType and enumType[value.Name] or Enum.KeyCode.Unknown
end
return value
end
function SaveManager:RefreshConfigList()
local values = {}
local folder = self:_SettingsFolder()
if type(listfiles) ~= "function" or type(isfolder) ~= "function" or not isfolder(folder) then
return values
end
local ok, files = pcall(listfiles, folder)
if not ok then return values end
for _, path in ipairs(files) do
local name = tostring(path):match("([^/\\]+)%.json$")
if name then values[#values + 1] = name end
end
table.sort(values)
return values
end
function SaveManager:Save(name)
local ok, err = self:_EnsureFolder()
if not ok then return false, err end
if type(writefile) ~= "function" then return false, "writefile tidak tersedia" end
local values = {}
for id, element in pairs(Library.Toggles) do
if not self.Ignore[id] then values[id] = windEncodeValue(element.Value) end
end
for id, element in pairs(Library.Options) do
if not self.Ignore[id] then values[id] = windEncodeValue(element.Value) end
end
local encoded = game:GetService("HttpService"):JSONEncode({
Format = "BluehavenWindUI-1",
Values = values,
})
local success, writeErr = pcall(writefile, self:_SettingsFolder() .. "/" .. name .. ".json", encoded)
return success, writeErr
end
function SaveManager:Load(name)
local path = self:_SettingsFolder() .. "/" .. name .. ".json"
if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(path) then
return false, "config tidak ditemukan"
end
local ok, decoded = pcall(function()
return game:GetService("HttpService"):JSONDecode(readfile(path))
end)
if not ok or type(decoded) ~= "table" then return false, decoded end
local values = decoded.Values
local legacyTypes = {}
if type(values) ~= "table" then
values = {}
for _, entry in ipairs(decoded) do
if type(entry) == "table" and entry.idx then
values[entry.idx] = entry.value
legacyTypes[entry.idx] = entry.type
end
end
end
for id, value in pairs(values) do
local element = Library.Toggles[id] or Library.Options[id]
if element and not self.Ignore[id] then
value = windDecodeValue(value)
if legacyTypes[id] == "ColorPicker" and type(value) == "string" then
local hex = value:gsub("#", "")
if hex:match("^%x%x%x%x%x%x$") then
value = Color3.fromHex(hex)
end
elseif legacyTypes[id] == "KeyPicker" then
if type(value) == "table" then
value = value.key or value.Key or value[1]
end
value = windKeyValue(value)
end
if element._Kind == "Colorpicker" and typeof(value) == "Color3" then
element:SetValueRGB(value)
else
element:SetValue(value)
end
end
end
return true
end
function SaveManager:Delete(name)
local clean = tostring(name or "")
:gsub("^%s+", "")
:gsub("%s+$", "")
:gsub("[/\\:%*%?%\"<>|]", "_")
if clean == "" then
return false, "nama config kosong"
end
local path = self:_SettingsFolder()
.. "/"
.. clean
.. ".json"
if type(isfile) ~= "function"
or not isfile(path) then
return false, "config tidak ditemukan"
end
if type(delfile) ~= "function" then
return false, "delfile tidak tersedia"
end
local success, deleteErr = pcall(delfile, path)
if not success then
return false, deleteErr
end
local autoloadPath = self:_SettingsFolder()
.. "/autoload.txt"
if type(readfile) == "function"
and isfile(autoloadPath) then
local ok, autoloadName = pcall(readfile, autoloadPath)
if ok
and tostring(autoloadName)
:gsub("^%s+", "")
:gsub("%s+$", "") == clean then
pcall(delfile, autoloadPath)
end
end
return true
end
function SaveManager:LoadAutoloadConfig()
local path = self:_SettingsFolder() .. "/autoload.txt"
if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(path) then
return false, "autoload belum diatur"
end
return self:Load(tostring(readfile(path)):gsub("^%s+", ""):gsub("%s+$", ""))
end
function _BH_FN.RunBluehavenHub()
local BluehavenCleanupToken = {}
pcall(function()
local env =
(type(getgenv) == "function" and getgenv())
or _G
env.__BLUEHAVEN_CLEANUP_TOKEN =
BluehavenCleanupToken
env.__BLUEHAVEN_GUI_CLEANUP = function()
pcall(_BH_FN.BH_CleanupOldGui)
end
end)
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
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
local GuiService      = game:GetService("GuiService")
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera
local HubRuntime = {
Alive = true,
Unloading = false,
Connections = {},
Artifacts = {},
TrackTicks = 0,
}
function _BH_FN.PruneRuntimeRefs()
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
function _BH_FN.TrackConnection(conn)
if conn then
HubRuntime.Connections[conn] = true
HubRuntime.TrackTicks = HubRuntime.TrackTicks + 1
if HubRuntime.TrackTicks % 48 == 0 then _BH_FN.PruneRuntimeRefs() end
end
return conn
end
function _BH_FN.ForgetConnection(conn)
if conn then HubRuntime.Connections[conn] = nil end
end
function _BH_FN.TrackArtifact(obj)
if obj then
HubRuntime.Artifacts[obj] = true
HubRuntime.TrackTicks = HubRuntime.TrackTicks + 1
if HubRuntime.TrackTicks % 48 == 0 then _BH_FN.PruneRuntimeRefs() end
end
return obj
end
function _BH_FN.ForgetArtifact(obj)
if obj then HubRuntime.Artifacts[obj] = nil end
end
function _BH_FN.DestroyArtifact(obj)
if not obj then return end
_BH_FN.ForgetArtifact(obj)
pcall(function()
if obj.Parent then obj:Destroy() end
end)
end
function _BH_FN.DisconnectTrackedConnections()
for conn in pairs(HubRuntime.Connections) do
pcall(function() conn:Disconnect() end)
HubRuntime.Connections[conn] = nil
end
end
function _BH_FN.DestroyTrackedArtifacts()
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
local HideName = {
Enabled = false,
Keybind = Enum.KeyCode.F3,
Connection = nil
}
local SilentAim = {
Enabled = false,
FOV = 95,
Distance = 400,
TargetPart = "HumanoidRootPart",
Prediction = true,
PredictStrength = 0.15,
BulletSpeed = 800,
TargetMode = "Auto",
WallCheck = true
}
local silentHookActive = false
local silentOriginalCast = nil
local ESP = {
Survivor  = false,
Killer    = false,
Generator = false,
Pallet    = false,
Window    = false,
Hook      = false,
SCP       = false,
Distance  = 500
}
local ESPStyle = {
Mode = "Clean",
FillTransparency = 0.68,
OutlineTransparency = 0.02,
OutlineBrightness = 0.20,
Adaptive = true,
NearDistance = 70,
MidDistance = 180,
PlateColor = Color3.fromRGB(8, 9, 12),
PlateTransparency = 0.52,
PlateEdgeTransparency = 1,
GeneratorWidth = 108,
GeneratorHeight = 20,
GeneratorOffset = 1.72,
StatusWidth = 110,
StatusBaseHeight = 0,
StatusLineHeight = 14,
StatusTextSize = 10,
StatusWorldOffset = 1.15,
StatusScaleStart = 55,
StatusMinScale = 0.62,
}
local ESPStatus = {
ShowName     = false,
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
Health   = Color3.fromRGB(100, 255, 130),
Item     = Color3.fromRGB(255, 215, 90),
Hooked   = Color3.fromRGB(255, 130, 95),
Carried  = Color3.fromRGB(255, 185, 95),
}
local Auto = {
SkillCheck          = false,
SkillCheckGenerator = false,
SkillCheckMode      = "Legit",
SkillCheckReactionDelay = 0.00,
SkillCheckReactionJitter = 0.00,
SkillCheckScanHz = 120,
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
CacheMap    = nil,
Processed   = {},
HotkeyCode  = Enum.KeyCode.G,
KeybindUpdating = false,
Generation  = 0,
Running     = false,
ActivePoints = {},
ActiveRepairEvent = nil,
ActiveHRP = nil,
OriginalCFrame = nil,
StartedFromRepair = false,
OriginalRepairPoint = nil,
NativeRepairActive = false,
RepairMonitorConnection = nil,
RepairCancelReadyAt = 0,
RepairLostChecks = 0,
RepairLostTolerance = 3,
PointSettleDelay = 0.075,
PointRetryDelay = 0.10,
ExtraPointRadius = 16,
ExtraPointDelay = 0.025,
PendingUntil = 0,
LastRequestAt = 0,
OverlayActive = false,
OverlayMonitorConnection = nil,
RepairStateConnections = {},
RepairCharacterConnection = nil,
ControllerContext = nil,
ControllerScanAt = 0,
ControllerScanInterval = 3,
SurvivorActions = nil,
}
function GB_GetAllGenerators()
local now = tick()
local mapFolder = workspace:FindFirstChild("Map")
if mapFolder ~= GenBypass.CacheMap then
GenBypass.CacheMap = mapFolder
GenBypass.CacheTimer = 0
table.clear(GenBypass.Cache)
table.clear(GenBypass.Processed)
end
if mapFolder
and now - GenBypass.CacheTimer < 2 then
local alive = {}
for _, gen in ipairs(GenBypass.Cache) do
if gen and gen.Parent then
alive[#alive + 1] = gen
end
end
GenBypass.Cache = alive
return GenBypass.Cache
end
GenBypass.Cache = {}
GenBypass.CacheTimer = now
if not mapFolder then return GenBypass.Cache end
pcall(function()
for _, v in pairs(mapFolder:GetDescendants()) do
if v:IsA("Model") and v.Name == "Generator" then
local hasRepairPoint = false
for _, obj in ipairs(v:GetDescendants()) do
if obj:IsA("BasePart")
and obj.Name:find(
"GeneratorPoint",
1,
true
) then
hasRepairPoint = true
break
end
end
local isReal = v:GetAttribute("RepairProgress") ~= nil
or v:GetAttribute("kickcount") ~= nil
or v:GetAttribute("ProgressRepair") ~= nil
or hasRepairPoint
if isReal then table.insert(GenBypass.Cache, v) end
end
end
end)
return GenBypass.Cache
end
function GB_GetPoints(genModel)
local points = {}
if not genModel then return points end
pcall(function()
for _, obj in ipairs(genModel:GetDescendants()) do
if obj:IsA("BasePart") and obj.Name:find("GeneratorPoint", 1, true) then
points[#points + 1] = obj
end
end
end)
return points
end
function GB_GetGeneratorFromPoint(point)
local current = point
while current and current ~= workspace do
if current:IsA("Model") and current.Name == "Generator" then
local isReal = current:GetAttribute("RepairProgress") ~= nil
or current:GetAttribute("kickcount") ~= nil
or current:GetAttribute("ProgressRepair") ~= nil
if isReal then
return current
end
end
current = current.Parent
end
return nil
end
function _BH_FN.GB_IsPointRepairing(point)
if not point or not point.Parent then
return false
end
local repairing = false
pcall(function()
repairing =
point:GetAttribute("IsRepairing") == true
or point:GetAttribute("isRepairing") == true
end)
return repairing
end
function _BH_FN.GB_GetClientInteract(character)
local char =
character
or LocalPlayer.Character
return char
and (
char:FindFirstChild("CheckInterractable")
or char:FindFirstChild("CheckInteractable")
)
end
function _BH_FN.GB_IsClientRepairing()
local interact = _BH_FN.GB_GetClientInteract()
if not interact then return false end
local repairing = false
pcall(function()
repairing =
interact:GetAttribute("isRepairing") == true
or interact:GetAttribute("IsRepairing") == true
or interact:GetAttribute("repairing") == true
or interact:GetAttribute("Repairing") == true
end)
if not repairing
and type(_BH_FN.GB_FindControllerContext) == "function" then
local context = _BH_FN.GB_FindControllerContext()
local state = context and context.state
local action = state and state.activeMouseAction
repairing = action ~= nil
and string.find(
string.lower(tostring(action)),
"repair",
1,
true
) ~= nil
and state.currentRepairPoint ~= nil
end
return repairing
end
function _BH_FN.GB_ClearClientRepairState()
return false
end
function _BH_FN.GB_GetSurvivorActions()
if type(GenBypass.SurvivorActions) == "table"
and type(GenBypass.SurvivorActions.startRepair) == "function" then
return GenBypass.SurvivorActions
end
local modules =
ReplicatedStorage:FindFirstChild("Modules")
local survivors =
modules
and modules:FindFirstChild("Survivors")
local module =
survivors
and survivors:FindFirstChild("SurvivorActions")
if not module then
return nil
end
local ok, actions =
pcall(require, module)
if ok
and type(actions) == "table"
and type(actions.startRepair) == "function" then
GenBypass.SurvivorActions = actions
return actions
end
return nil
end
function _BH_FN.GB_IsControllerContext(candidate, char, interact)
if type(candidate) ~= "table" then
return false
end
return rawget(candidate, "player") == LocalPlayer
and rawget(candidate, "character") == char
and rawget(candidate, "humanoidRootPart")
== char:FindFirstChild("HumanoidRootPart")
and rawget(candidate, "script") == interact
and type(rawget(candidate, "state")) == "table"
and type(rawget(candidate, "prompts")) == "table"
and type(rawget(candidate, "startCooldown")) == "function"
end
function _BH_FN.GB_FindControllerContext()
local char = LocalPlayer.Character
local interact = _BH_FN.GB_GetClientInteract()
if not char or not interact then
return nil
end
local cached =
GenBypass.ControllerContext
if _BH_FN.GB_IsControllerContext(
cached,
char,
interact
) then
return cached
end
GenBypass.ControllerContext = nil
if type(getgc) == "function" then
local now = os.clock()
if now < GenBypass.ControllerScanAt then
return nil
end
GenBypass.ControllerScanAt =
now + GenBypass.ControllerScanInterval
local ok, objects =
pcall(getgc, true)
if ok and type(objects) == "table" then
for _, candidate in pairs(objects) do
if _BH_FN.GB_IsControllerContext(
candidate,
char,
interact
) then
GenBypass.ControllerContext = candidate
return candidate
end
end
end
end
return nil
end
function _BH_FN.GB_ResumeOriginalRepair(
point,
generation
)
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not point
or not point.Parent then
return false
end
local actions =
_BH_FN.GB_GetSurvivorActions()
local context =
_BH_FN.GB_FindControllerContext()
if not actions or not context then
return false
end
local char = LocalPlayer.Character
local root =
char
and char:FindFirstChild("HumanoidRootPart")
if not root
or (root.Position - point.Position).Magnitude > 8 then
return false
end
local ok, action =
pcall(
actions.startRepair,
context,
point
)
if not ok then
return false
end
if type(context.state) == "table" then
context.state.activeMouseAction =
action or "repairing"
end
local startedAt = os.clock()
local clientSeenAt = nil
while HubRuntime.Alive
and GenBypass.Enabled
and generation == GenBypass.Generation
and point.Parent
and os.clock() - startedAt < 0.80 do
if _BH_FN.GB_IsPointRepairing(point) then
return true
end
if _BH_FN.GB_IsClientRepairing() then
clientSeenAt = clientSeenAt or os.clock()
if os.clock() - clientSeenAt >= 0.35 then
return true
end
else
clientSeenAt = nil
end
task.wait(0.025)
end
return false
end
function _BH_FN.GB_ResumeOriginalRepairFallback(
point,
generation,
remote
)
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not point
or not point.Parent
or not remote then
return false
end
local char = LocalPlayer.Character
local hum =
char
and char:FindFirstChildOfClass("Humanoid")
local root =
char
and char:FindFirstChild("HumanoidRootPart")
local interact = _BH_FN.GB_GetClientInteract()
if not char
or not hum
or not root
or hum.Health <= 0
or (root.Position - point.Position).Magnitude > 8 then
return false
end
local context =
_BH_FN.GB_FindControllerContext()
local ok = pcall(function()
if interact then
interact:SetAttribute("isRepairing", true)
end
if context and type(context.state) == "table" then
context.state.currentRepairPoint = point
context.state.activeMouseAction = "repairing"
context.state.movementCheckThread = nil
if context.prompts
and context.prompts.generator then
context.prompts.generator.Visible = false
end
if context.frame then
context.frame.Visible = true
end
if context.progressFrame then
context.progressFrame.Visible = true
end
end
hum.AutoRotate = false
root.Anchored = true
local generator =
GB_GetGeneratorFromPoint(point)
local lookPart =
generator
and (
generator:FindFirstChild("Main")
or generator.PrimaryPart
)
if not lookPart
or not lookPart:IsA("BasePart") then
lookPart = point
end
local lookPosition = lookPart.Position
local flatTarget = Vector3.new(
lookPosition.X,
root.Position.Y,
lookPosition.Z
)
if (flatTarget - root.Position).Magnitude > 0.01 then
root.CFrame = CFrame.lookAt(
root.Position,
flatTarget
)
end
remote:FireServer(point, true)
end)
if not ok then
_BH_FN.GB_ClearClientRepairState()
return false
end
task.wait(0.10)
local accepted = GB_WaitRepairing(
point,
0.55,
generation
)
if accepted
and _BH_FN.GB_IsClientRepairing() then
return true
end
pcall(function()
remote:FireServer(point, false)
end)
_BH_FN.GB_ClearClientRepairState()
return false
end
function _BH_FN.GB_StopOriginalRepair()
if GenBypass.RepairMonitorConnection then
pcall(function()
GenBypass.RepairMonitorConnection:Disconnect()
end)
_BH_FN.ForgetConnection(
GenBypass.RepairMonitorConnection
)
GenBypass.RepairMonitorConnection = nil
end
local remote = GenBypass.ActiveRepairEvent
local point = GenBypass.OriginalRepairPoint
local stoppedNatively = false
local actions =
_BH_FN.GB_GetSurvivorActions()
local context =
_BH_FN.GB_FindControllerContext()
if actions
and context
and type(actions.stopRepair) == "function" then
stoppedNatively =
pcall(
actions.stopRepair,
context,
{clearGenIfLowHealth = false}
)
end
if not stoppedNatively
and remote
and point
and point.Parent then
pcall(function()
remote:FireServer(point, false)
end)
end
_BH_FN.GB_ClearClientRepairState()
_BH_FN.GB_ReleaseTrackedPoints()
GenBypass.NativeRepairActive = false
GenBypass.RepairCancelReadyAt = 0
GenBypass.RepairLostChecks = 0
GenBypass.ActiveRepairEvent = nil
GenBypass.OriginalRepairPoint = nil
end
function _BH_FN.GB_TrackActivePoint(point)
if point and point.Parent then
GenBypass.ActivePoints[point] = true
end
end
function _BH_FN.GB_ReleaseTrackedPoints()
local remote = GenBypass.ActiveRepairEvent
if remote then
for point in pairs(GenBypass.ActivePoints) do
if point and point.Parent then
pcall(function()
remote:FireServer(point, false)
end)
end
GenBypass.ActivePoints[point] = nil
end
else
table.clear(GenBypass.ActivePoints)
end
end
function _BH_FN.GB_StartRepairMonitor(generation)
if GenBypass.RepairMonitorConnection then
pcall(function()
GenBypass.RepairMonitorConnection:Disconnect()
end)
_BH_FN.ForgetConnection(
GenBypass.RepairMonitorConnection
)
end
GenBypass.RepairCancelReadyAt =
os.clock() + 0.45
GenBypass.RepairLostChecks = 0
local lastCheck = 0
GenBypass.RepairMonitorConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function()
if not GenBypass.NativeRepairActive then
return
end
local now = os.clock()
if now - lastCheck < 0.05 then
return
end
lastCheck = now
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation then
_BH_FN.GB_StopOriginalRepair()
return
end
if now < GenBypass.RepairCancelReadyAt then
return
end
if not _BH_FN.GB_IsClientRepairing() then
GenBypass.RepairLostChecks =
GenBypass.RepairLostChecks + 1
if GenBypass.RepairLostChecks
>= GenBypass.RepairLostTolerance then
_BH_FN.GB_StopOriginalRepair()
end
return
end
GenBypass.RepairLostChecks = 0
local char = LocalPlayer.Character
local hum =
char
and char:FindFirstChildOfClass("Humanoid")
if hum
and hum.MoveDirection.Magnitude > 0.05 then
_BH_FN.GB_StopOriginalRepair()
end
end)
)
end
function _BH_FN.GB_MoveToRepairPoint(
root,
generator,
point
)
if not root
or not root.Parent
or not point
or not point.Parent then
return false
end
local body =
generator
and (
generator:FindFirstChild(
"GeneratorBody",
true
)
or generator:FindFirstChild(
"Main",
true
)
or generator.PrimaryPart
)
if not body
or not body:IsA("BasePart") then
body = point
end
local target = Vector3.new(
body.Position.X,
point.Position.Y,
body.Position.Z
)
if (target - point.Position).Magnitude <= 0.01 then
target =
point.Position
+ root.CFrame.LookVector
end
return pcall(function()
root.Anchored = true
root.AssemblyLinearVelocity =
Vector3.zero
root.AssemblyAngularVelocity =
Vector3.zero
root.CFrame =
CFrame.lookAt(
point.Position,
target
)
end)
end
function _BH_FN.GB_RestoreCharacterNow()
local hrp = GenBypass.ActiveHRP
local cf = GenBypass.OriginalCFrame
if hrp and hrp.Parent then
pcall(function()
hrp.Anchored = false
if cf then
hrp.CFrame = cf
end
end)
end
end
function _BH_FN.GB_CancelRunning()
if not GenBypass.Running then
return false
end
GenBypass.Generation = GenBypass.Generation + 1
GenBypass.Running = false
_BH_FN.GB_ReleaseTrackedPoints()
table.clear(GenBypass.Processed)
GenBypass.StartedFromRepair = false
GenBypass.OriginalRepairPoint = nil
GenBypass.NativeRepairActive = false
GenBypass.RepairLostChecks = 0
return true
end
function _BH_FN.GB_UnloadSafe()
GenBypass.Generation = GenBypass.Generation + 1
GenBypass.Enabled = false
_BH_FN.GB_StopExtraRepair()
if type(_BH_FN.GB_DisconnectRepairWatchers) == "function" then
_BH_FN.GB_DisconnectRepairWatchers()
end
table.clear(
GenBypass.ActivePoints
)
GenBypass.ActiveRepairEvent = nil
GenBypass.ActiveHRP = nil
GenBypass.OriginalCFrame = nil
GenBypass.OriginalRepairPoint = nil
GenBypass.StartedFromRepair = false
GenBypass.NativeRepairActive = false
GenBypass.RepairMonitorConnection = nil
GenBypass.RepairCancelReadyAt = 0
GenBypass.RepairLostChecks = 0
GenBypass.ControllerContext = nil
table.clear(
GenBypass.Processed
)
end
function GB_WaitRepairing(point, timeout, generation)
local start = tick()
while HubRuntime.Alive
and GenBypass.Enabled
and (generation == nil or generation == GenBypass.Generation)
and point
and point.Parent
and tick() - start < (timeout or 1) do
local repairing = false
pcall(function()
repairing = point:GetAttribute("IsRepairing") == true
or point:GetAttribute("isRepairing") == true
end)
if repairing then return true end
task.wait(0.05)
end
return false
end
function _BH_FN.GB_DoRepairLegacy(targetPoint)
if true then
return false
end
if not HubRuntime.Alive
or not GenBypass.Enabled
or GenBypass.Running
or not targetPoint
or not targetPoint.Parent then
return
end
local genModel = GB_GetGeneratorFromPoint(targetPoint)
if not genModel or not genModel.Parent then
return
end
local RepairEvent =
ReplicatedStorage:FindFirstChild("Remotes")
and ReplicatedStorage.Remotes:FindFirstChild("Generator")
and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
if not RepairEvent then
return
end
local char = LocalPlayer.Character
local root =
char
and char:FindFirstChild(
"HumanoidRootPart"
)
local hum =
char
and char:FindFirstChildOfClass(
"Humanoid"
)
if not root
or not hum
or hum.Health <= 0 then
return
end
if GenBypass.NativeRepairActive then
_BH_FN.GB_StopOriginalRepair()
task.wait(0.05)
elseif next(GenBypass.ActivePoints) ~= nil then
_BH_FN.GB_ReleaseTrackedPoints()
end
GenBypass.Generation = GenBypass.Generation + 1
local generation = GenBypass.Generation
GenBypass.Running = true
GenBypass.Processed[genModel] = generation
GenBypass.ActiveRepairEvent = RepairEvent
GenBypass.ActiveHRP = root
GenBypass.OriginalCFrame = root.CFrame
GenBypass.NativeRepairActive = false
GenBypass.StartedFromRepair =
_BH_FN.GB_IsClientRepairing()
GenBypass.OriginalRepairPoint =
targetPoint
if GenBypass.StartedFromRepair then
local context =
_BH_FN.GB_FindControllerContext()
local currentPoint =
context
and context.state
and context.state.currentRepairPoint
if currentPoint
and currentPoint.Parent
and GB_GetGeneratorFromPoint(currentPoint)
== genModel then
GenBypass.OriginalRepairPoint =
currentPoint
end
end
table.clear(GenBypass.ActivePoints)
local startedFromRepair =
GenBypass.StartedFromRepair
local originalRepairPoint =
GenBypass.OriginalRepairPoint
if startedFromRepair then
local actions =
_BH_FN.GB_GetSurvivorActions()
local context =
_BH_FN.GB_FindControllerContext()
if actions
and context
and type(actions.stopRepair) == "function" then
pcall(
actions.stopRepair,
context,
{clearGenIfLowHealth = false}
)
else
pcall(function()
RepairEvent:FireServer(
originalRepairPoint,
false
)
end)
_BH_FN.GB_ClearClientRepairState()
end
task.wait(0.04)
end
local function stillValid()
return HubRuntime.Alive
and GenBypass.Enabled
and GenBypass.Running
and generation == GenBypass.Generation
and genModel
and genModel.Parent
end
local ok, err = pcall(function()
for _, point in ipairs(GB_GetPoints(genModel)) do
if not stillValid() then
break
end
if point
and point.Parent
and (
not startedFromRepair
or point ~= originalRepairPoint
) then
if not _BH_FN.GB_MoveToRepairPoint(
root,
genModel,
point
) then
error("failed to move to generator point")
end
task.wait(0.05)
_BH_FN.GB_TrackActivePoint(point)
RepairEvent:FireServer(point, true)
task.wait(GenBypass.PointSettleDelay)
if not _BH_FN.GB_IsPointRepairing(point)
and not _BH_FN.GB_IsClientRepairing() then
task.wait(GenBypass.PointRetryDelay)
if stillValid() then
RepairEvent:FireServer(point, true)
task.wait(GenBypass.PointSettleDelay)
end
end
end
end
if not stillValid() then
return
end
local resumePoint =
originalRepairPoint
if not resumePoint
or not resumePoint.Parent then
resumePoint = targetPoint
end
if not _BH_FN.GB_MoveToRepairPoint(
root,
genModel,
resumePoint
) then
error("failed to return to repair point")
end
if GenBypass.ActivePoints[resumePoint] then
RepairEvent:FireServer(
resumePoint,
false
)
GenBypass.ActivePoints[resumePoint] =
nil
task.wait(0.04)
end
local resumed =
_BH_FN.GB_ResumeOriginalRepair(
resumePoint,
generation
)
if not resumed then
resumed =
_BH_FN.GB_ResumeOriginalRepairFallback(
resumePoint,
generation,
RepairEvent
)
end
if not resumed then
error("native repair was not accepted")
end
GenBypass.OriginalRepairPoint =
resumePoint
GenBypass.NativeRepairActive = true
_BH_FN.GB_TrackActivePoint(resumePoint)
_BH_FN.GB_StartRepairMonitor(generation)
end)
if not ok or not stillValid() then
_BH_FN.GB_ReleaseTrackedPoints()
_BH_FN.GB_RestoreCharacterNow()
_BH_FN.GB_ClearClientRepairState()
GenBypass.NativeRepairActive = false
end
if GenBypass.Processed[genModel] == generation then
GenBypass.Processed[genModel] = nil
end
if generation == GenBypass.Generation then
GenBypass.Running = false
end
if not GenBypass.NativeRepairActive
and next(GenBypass.ActivePoints) == nil then
GenBypass.ActiveRepairEvent = nil
end
GenBypass.ActiveHRP = nil
GenBypass.OriginalCFrame = nil
GenBypass.StartedFromRepair = false
if not GenBypass.NativeRepairActive then
GenBypass.OriginalRepairPoint = nil
end
if not ok
and HubRuntime.Alive
and generation == GenBypass.Generation then
warn(
"[Bluehaven GenBypass] "
.. tostring(err)
)
end
end
function _BH_FN.GB_DisconnectOverlayMonitor()
local connection = GenBypass.OverlayMonitorConnection
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
GenBypass.OverlayMonitorConnection = nil
end
end
function _BH_FN.GB_StopExtraRepair()
_BH_FN.GB_DisconnectOverlayMonitor()
_BH_FN.GB_ReleaseTrackedPoints()
GenBypass.OverlayActive = false
GenBypass.Running = false
GenBypass.ActiveRepairEvent = nil
GenBypass.OriginalRepairPoint = nil
GenBypass.StartedFromRepair = false
GenBypass.NativeRepairActive = false
GenBypass.ActiveHRP = nil
GenBypass.OriginalCFrame = nil
end
function _BH_FN.GB_GetNativeRepairPoint(fallbackPoint)
local context = _BH_FN.GB_FindControllerContext()
local state = context and context.state
local currentPoint = state and state.currentRepairPoint
if currentPoint
and currentPoint.Parent
and GB_GetGeneratorFromPoint(currentPoint) then
return currentPoint
end
return fallbackPoint
end
function _BH_FN.GB_StartOverlayMonitor(generation, generator)
_BH_FN.GB_DisconnectOverlayMonitor()
local elapsed = 0
GenBypass.OverlayMonitorConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function(dt)
if not GenBypass.OverlayActive then
return
end
elapsed = elapsed + dt
if elapsed < 0.10 then
return
end
elapsed = 0
local original = GenBypass.OriginalRepairPoint
local sameGenerator =
original
and original.Parent
and GB_GetGeneratorFromPoint(original) == generator
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not _BH_FN.GB_IsClientRepairing()
or not sameGenerator then
_BH_FN.GB_StopExtraRepair()
end
end)
)
end
function GB_DoRepair(targetPoint)
if not HubRuntime.Alive
or not GenBypass.Enabled
or GenBypass.Running
or GenBypass.OverlayActive
or not _BH_FN.GB_IsClientRepairing() then
return false
end
local nativePoint =
_BH_FN.GB_GetNativeRepairPoint(targetPoint)
local generator =
GB_GetGeneratorFromPoint(nativePoint)
if not generator or not generator.Parent then
return false
end
local remote =
ReplicatedStorage:FindFirstChild("Remotes")
and ReplicatedStorage.Remotes:FindFirstChild("Generator")
and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not remote
or not remote:IsA("RemoteEvent")
or not root
or not hum
or hum.Health <= 0 then
return false
end
GenBypass.Generation = GenBypass.Generation + 1
local generation = GenBypass.Generation
GenBypass.Running = true
GenBypass.ActiveRepairEvent = remote
GenBypass.OriginalRepairPoint = nativePoint
GenBypass.StartedFromRepair = true
table.clear(GenBypass.ActivePoints)
local requested = 0
for _, point in ipairs(GB_GetPoints(generator)) do
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not _BH_FN.GB_IsClientRepairing() then
break
end
if point ~= nativePoint
and point.Parent
and (point.Position - root.Position).Magnitude
<= GenBypass.ExtraPointRadius then
local fired = pcall(function()
remote:FireServer(point, true)
end)
if fired then
GenBypass.ActivePoints[point] = true
requested = requested + 1
task.wait(GenBypass.ExtraPointDelay)
if not _BH_FN.GB_IsPointRepairing(point)
and _BH_FN.GB_IsClientRepairing() then
pcall(function()
remote:FireServer(point, true)
end)
end
end
end
end
GenBypass.Running = false
if requested <= 0
or not _BH_FN.GB_IsClientRepairing()
or generation ~= GenBypass.Generation then
_BH_FN.GB_StopExtraRepair()
return false
end
GenBypass.OverlayActive = true
_BH_FN.GB_StartOverlayMonitor(generation, generator)
return true
end
function GB_GetNearestPoint()
local character = LocalPlayer.Character
local hrp = character
and character:FindFirstChild("HumanoidRootPart")
if not hrp then
return nil
end
local activePoint = nil
local activeDist = math.huge
local bestPoint = nil
local bestDist = math.huge
for _, gen in ipairs(GB_GetAllGenerators()) do
if gen and gen.Parent then
for _, point in ipairs(GB_GetPoints(gen)) do
if point and point.Parent then
local d =
(hrp.Position - point.Position).Magnitude
if d < bestDist then
bestDist = d
bestPoint = point
end
if _BH_FN.GB_IsPointRepairing(point)
and d < activeDist then
activeDist = d
activePoint = point
end
end
end
end
end
if activePoint then
return activePoint, activeDist
end
return bestPoint, bestDist
end
function _BH_FN.GB_Request()
if not HubRuntime.Alive
or not GenBypass.Enabled then
return
end
local now = os.clock()
if GenBypass.OverlayActive then
return
end
if not _BH_FN.GB_IsClientRepairing() then
GenBypass.PendingUntil = now + 2
return
end
if now - GenBypass.LastRequestAt < 0.10 then
return
end
GenBypass.LastRequestAt = now
GenBypass.PendingUntil = 0
GenBypass.CacheTimer = 0
local bestPoint, bestDist =
GB_GetNearestPoint()
bestPoint =
_BH_FN.GB_GetNativeRepairPoint(bestPoint)
if bestPoint
and bestPoint.Parent
and (
bestDist <= 10
or _BH_FN.GB_IsClientRepairing()
) then
task.spawn(
GB_DoRepair,
bestPoint
)
end
end
function _BH_FN.GB_DisconnectRepairWatchers()
for _, connection in ipairs(GenBypass.RepairStateConnections) do
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
end
end
table.clear(GenBypass.RepairStateConnections)
if GenBypass.RepairCharacterConnection then
pcall(function()
GenBypass.RepairCharacterConnection:Disconnect()
end)
_BH_FN.ForgetConnection(GenBypass.RepairCharacterConnection)
GenBypass.RepairCharacterConnection = nil
end
end
function _BH_FN.GB_BindRepairWatcher(char)
for _, connection in ipairs(GenBypass.RepairStateConnections) do
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
end
end
table.clear(GenBypass.RepairStateConnections)
if not GenBypass.Enabled or not char then
return
end
local interact = _BH_FN.GB_GetClientInteract()
if not interact then
local deadline = os.clock() + 1.5
repeat
task.wait()
interact =
_BH_FN.GB_GetClientInteract(char)
until interact
or not char.Parent
or os.clock() >= deadline
end
if not interact or not GenBypass.Enabled then
return
end
local function refresh()
if not GenBypass.Enabled then
return
end
if _BH_FN.GB_IsClientRepairing() then
task.delay(0.08, function()
if GenBypass.Enabled
and _BH_FN.GB_IsClientRepairing()
and not GenBypass.OverlayActive
and not GenBypass.Running then
_BH_FN.GB_Request()
end
end)
elseif GenBypass.OverlayActive
or next(GenBypass.ActivePoints) ~= nil then
_BH_FN.GB_StopExtraRepair()
end
end
for _, attribute in ipairs({
"isRepairing",
"IsRepairing",
"repairing",
"Repairing",
}) do
GenBypass.RepairStateConnections[#GenBypass.RepairStateConnections + 1] =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal(attribute):Connect(refresh)
)
end
refresh()
end
function GB_UpdateButton()
if GenBypass.Button then
GenBypass.Button.Visible = GenBypass.Enabled and UserInputService.TouchEnabled
end
end
function GB_CreateButton()
local oldUI = PlayerGui:FindFirstChild("BypassGenUI")
if oldUI then
_BH_FN.DestroyArtifact(oldUI)
if GenBypass.UI == oldUI then
GenBypass.UI = nil
GenBypass.Button = nil
end
end
GenBypass.UI = _BH_FN.TrackArtifact(Instance.new("ScreenGui"))
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
_BH_FN.TrackConnection(
GenBypass.Button.MouseButton1Click:Connect(
_BH_FN.GB_Request
)
)
end
GB_CreateButton()
_BH_FN.TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
if not HubRuntime.Alive then return end
GenBypass.ControllerContext = nil
task.wait(0.5)
if not HubRuntime.Alive then return end
GB_CreateButton()
GB_UpdateButton()
end))
function setGenBypass(v)
local nextState = v == true
if not nextState then
GenBypass.Generation =
GenBypass.Generation + 1
GenBypass.Enabled = false
_BH_FN.GB_StopExtraRepair()
_BH_FN.GB_DisconnectRepairWatchers()
table.clear(GenBypass.Processed)
GenBypass.ControllerContext = nil
else
GenBypass.Enabled = true
_BH_FN.GB_DisconnectRepairWatchers()
end
GB_UpdateButton()
end
function _BH_FN.GB_RecoverStaleLegacyInteraction()
if GenBypass.OverlayActive or GenBypass.Running then
return false
end
local context = _BH_FN.GB_FindControllerContext()
local state = context and context.state
local interact = _BH_FN.GB_GetClientInteract()
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if type(state) ~= "table" or not interact or not char then
return false
end
local action = string.lower(tostring(state.activeMouseAction or ""))
if not string.find(action, "repair", 1, true) then
return false
end
local point = state.currentRepairPoint
local function hasNativeRepairSignal()
local active = false
pcall(function()
active = interact:GetAttribute("isRepairing") == true
or interact:GetAttribute("IsRepairing") == true
or interact:GetAttribute("repairing") == true
or interact:GetAttribute("Repairing") == true
or _BH_FN.GB_IsPointRepairing(point)
end)
return active
end
if hasNativeRepairSignal() then
return false
end
task.wait(0.85)
if not HubRuntime.Alive
or GenBypass.OverlayActive
or GenBypass.Running
or LocalPlayer.Character ~= char
or state.activeMouseAction == nil
or hasNativeRepairSignal() then
return false
end
pcall(function()
state.activeMouseAction = nil
state.currentRepairPoint = nil
state.movementCheckThread = nil
for _, attribute in ipairs({
"isRepairing",
"IsRepairing",
"repairing",
"Repairing",
}) do
if interact:GetAttribute(attribute) ~= nil then
interact:SetAttribute(attribute, false)
end
end
if root then
root.Anchored = false
root:RemoveTag("doing action")
end
if hum then
hum.AutoRotate = true
end
if context.prompts
and context.prompts.generator then
context.prompts.generator.Visible = true
end
end)
if context.proximity
and type(context.proximity.scan) == "function" then
pcall(context.proximity.scan, context.proximity, interact)
end
return true
end
task.defer(function()
task.wait(1.25)
pcall(_BH_FN.GB_RecoverStaleLegacyInteraction)
end)
task.spawn(function()
while HubRuntime.Alive do
task.wait(1.5)
pcall(_BH_FN.GB_RecoverStaleLegacyInteraction)
end
end)
pcall(_BH_FN.GB_StopExtraRepair)
pcall(_BH_FN.GB_DisconnectRepairWatchers)
GenBypass.Generation = GenBypass.Generation + 1
GenBypass.Running = false
GenBypass.OverlayActive = false
GenBypass.ActiveRepairEvent = nil
GenBypass.ActiveHRP = nil
GenBypass.OriginalCFrame = nil
GenBypass.JobSnapshot = nil
GenBypass.WorkerGeneration = nil
GenBypass.StableMonitorConnection = nil
GenBypass.JobGenerator = nil
GenBypass.JobAnchorPosition = nil
GenBypass.PendingPoint = nil
GenBypass.ActionControl = nil
GenBypass.StartedFromRepair = false
GenBypass.RepairLostChecks = 0
GenBypass.Cancelling = false
GenBypass.NativeRepairExpected = false
GenBypass.NativePoseOwned = false
GenBypass.NativeRepairPoint = nil
GenBypass.NativeRepairContext = nil
GenBypass.NativeRepairActions = nil
GenBypass.PoseRestarting = false
GenBypass.PoseRestartAttempts = 0
GenBypass.MaxPoseRestartAttempts = 1
GenBypass.LastRequestAt = 0
GenBypass.RequestCooldown = 0.30
GenBypass.MaxStartDistance = 9
GenBypass.StayRadius = 15
GenBypass.MaxActiveDuration = 12
GenBypass.PointSettleDelay = 0.12
GenBypass.PointRetryDelay = 0.08
GenBypass.PointAcceptTimeout = 0.55
table.clear(GenBypass.ActivePoints)
table.clear(GenBypass.Processed)
function GB_UpdateButton()
local button = GenBypass.Button
if button then
button.Visible =
GenBypass.Enabled
and UserInputService.TouchEnabled
local label =
button:FindFirstChildWhichIsA("TextLabel")
if label then
if GenBypass.Cancelling then
label.Text = "WAIT"
elseif GenBypass.Running
or GenBypass.OverlayActive then
label.Text = "CANCEL"
else
label.Text = "BYPASS"
end
end
end
local actionControl = GenBypass.ActionControl
if actionControl
and type(actionControl.SetText) == "function" then
actionControl:SetText(
(GenBypass.Running or GenBypass.OverlayActive)
and "Cancel Gen Bypass"
or "Use Gen Bypass"
)
end
end
function _BH_FN.GB_GetRepairRemote()
local remotes =
ReplicatedStorage:FindFirstChild("Remotes")
local generatorFolder =
remotes and remotes:FindFirstChild("Generator")
local remote =
generatorFolder
and generatorFolder:FindFirstChild("RepairEvent")
if remote and remote:IsA("RemoteEvent") then
return remote
end
return nil
end
function _BH_FN.GB_StopStableMonitor()
local connection =
GenBypass.StableMonitorConnection
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
GenBypass.StableMonitorConnection = nil
end
end
function _BH_FN.GB_RestoreStableSnapshot(snapshot)
snapshot = snapshot or GenBypass.JobSnapshot
if type(snapshot) ~= "table" then
return false
end
local root = snapshot.Root
local humanoid = snapshot.Humanoid
local restoreRepairAnchor =
snapshot.WasRepairing == true
and _BH_FN.GB_IsClientRepairing()
local restoreAnchored =
snapshot.Anchored == true
and (
snapshot.WasRepairing ~= true
or restoreRepairAnchor
)
if root and root.Parent then
pcall(function()
root.CFrame = snapshot.CFrame
root.AssemblyLinearVelocity =
snapshot.LinearVelocity or Vector3.zero
root.AssemblyAngularVelocity =
snapshot.AngularVelocity or Vector3.zero
root.Anchored = restoreAnchored
end)
end
if humanoid and humanoid.Parent then
pcall(function()
if snapshot.WasRepairing == true
and not restoreRepairAnchor then
humanoid.AutoRotate = true
else
humanoid.AutoRotate =
snapshot.AutoRotate ~= false
end
end)
end
if GenBypass.JobSnapshot == snapshot then
GenBypass.JobSnapshot = nil
end
return true
end
function _BH_FN.GB_ClearNativePoseRefs()
GenBypass.NativeRepairExpected = false
GenBypass.NativePoseOwned = false
GenBypass.NativeRepairPoint = nil
GenBypass.NativeRepairContext = nil
GenBypass.NativeRepairActions = nil
GenBypass.PoseRestarting = false
GenBypass.PoseRestartAttempts = 0
end
function _BH_FN.GB_HasNativeRepairPose(point)
local character = LocalPlayer.Character
local root =
character
and character:FindFirstChild("HumanoidRootPart")
if not root
or not root.Parent
or not root.Anchored
or not _BH_FN.GB_IsClientRepairing() then
return false
end
if point
and point.Parent
and (root.Position - point.Position).Magnitude > 9 then
return false
end
local context = _BH_FN.GB_FindControllerContext()
local state = context and context.state
local currentPoint = state and state.currentRepairPoint
return currentPoint == nil
or point == nil
or currentPoint == point
end
function _BH_FN.GB_StopOwnedNativePose()
local owned = GenBypass.NativePoseOwned
local point = GenBypass.NativeRepairPoint
local context = GenBypass.NativeRepairContext
local actions = GenBypass.NativeRepairActions
local stopped = false
if owned
and actions
and context
and type(actions.stopRepair) == "function" then
stopped = pcall(
actions.stopRepair,
context,
{clearGenIfLowHealth = false}
)
end
if owned and not stopped then
local remote = GenBypass.ActiveRepairEvent
if remote and point and point.Parent then
pcall(function()
remote:FireServer(point, false)
end)
end
local state = context and context.state
if state and state.currentRepairPoint == point then
state.activeMouseAction = nil
state.currentRepairPoint = nil
end
local character = LocalPlayer.Character
local root =
character
and character:FindFirstChild("HumanoidRootPart")
local humanoid =
character
and character:FindFirstChildOfClass("Humanoid")
if root then
root.Anchored = false
end
if humanoid then
humanoid.AutoRotate = true
end
end
_BH_FN.GB_ClearNativePoseRefs()
end
function _BH_FN.GB_StartNativePose(
point,
generation,
forceRestart
)
if not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not point
or not point.Parent then
return false
end
local character = LocalPlayer.Character
local root =
character
and character:FindFirstChild("HumanoidRootPart")
local humanoid =
character
and character:FindFirstChildOfClass("Humanoid")
if not root
or not humanoid
or humanoid.Health <= 0
or (root.Position - point.Position).Magnitude > 9 then
return false
end
if not forceRestart
and _BH_FN.GB_HasNativeRepairPose(point) then
GenBypass.NativeRepairExpected = true
GenBypass.NativeRepairPoint = point
GenBypass.NativePoseOwned = false
return true
end
local actions = _BH_FN.GB_GetSurvivorActions()
local context = _BH_FN.GB_FindControllerContext()
if not actions or not context then
return false
end
GenBypass.NativeRepairExpected = true
GenBypass.NativePoseOwned = true
GenBypass.NativeRepairPoint = point
GenBypass.NativeRepairContext = context
GenBypass.NativeRepairActions = actions
if forceRestart
and type(actions.stopRepair) == "function" then
pcall(
actions.stopRepair,
context,
{clearGenIfLowHealth = false}
)
local remote = GenBypass.ActiveRepairEvent
if remote and point.Parent then
pcall(function()
remote:FireServer(point, false)
end)
end
task.wait(0.06)
end
if generation ~= GenBypass.Generation
or not GenBypass.Enabled then
return false
end
local ok, action = pcall(
actions.startRepair,
context,
point
)
if not ok
or generation ~= GenBypass.Generation
or not GenBypass.Enabled then
if type(actions.stopRepair) == "function" then
pcall(
actions.stopRepair,
context,
{clearGenIfLowHealth = false}
)
end
return false
end
if type(context.state) == "table" then
context.state.currentRepairPoint = point
context.state.activeMouseAction =
action or "repairing"
end
local deadline = os.clock() + 0.75
repeat
if generation ~= GenBypass.Generation
or not GenBypass.Enabled
or not HubRuntime.Alive then
return false
end
if _BH_FN.GB_HasNativeRepairPose(point) then
return true
end
task.wait(0.04)
until os.clock() >= deadline
return false
end
function _BH_FN.GB_ReleaseStablePoints()
local remote = GenBypass.ActiveRepairEvent
local pending = GenBypass.PendingPoint
if remote
and pending
and pending.Parent
and not GenBypass.ActivePoints[pending] then
pcall(function()
remote:FireServer(pending, false)
end)
end
GenBypass.PendingPoint = nil
for point in pairs(GenBypass.ActivePoints) do
if remote and point and point.Parent then
pcall(function()
remote:FireServer(point, false)
end)
end
GenBypass.ActivePoints[point] = nil
end
end
function _BH_FN.GB_IsStableJobValid(
generation,
root,
generator
)
local character = LocalPlayer.Character
local humanoid =
character
and character:FindFirstChildOfClass("Humanoid")
return HubRuntime.Alive
and GenBypass.Enabled
and generation == GenBypass.Generation
and root
and root.Parent
and character
and root:IsDescendantOf(character)
and humanoid
and humanoid.Health > 0
and generator
and generator.Parent
end
function _BH_FN.GB_ReadGeneratorProgress(generator)
if not generator or not generator.Parent then
return nil
end
local progress = nil
pcall(function()
progress =
generator:GetAttribute("RepairProgress")
or generator:GetAttribute("ProgressRepair")
or generator:GetAttribute("Progress")
end)
progress = tonumber(progress)
if not progress then
return nil
end
if progress > 1 then
progress = progress / 100
end
return math.clamp(progress, 0, 1)
end
function _BH_FN.GB_MoveStableRoot(root, point)
if not root
or not root.Parent
or not point
or not point.Parent then
return false
end
return pcall(function()
root.Anchored = true
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
root.CFrame = point.CFrame
end)
end
function _BH_FN.GB_WaitStablePoint(
point,
timeout,
generation
)
local deadline =
os.clock() + (tonumber(timeout) or 0.5)
repeat
if generation ~= GenBypass.Generation
or not GenBypass.Enabled
or not HubRuntime.Alive then
return false
end
if _BH_FN.GB_IsPointRepairing(point) then
return true
end
task.wait(0.04)
until os.clock() >= deadline
return false
end
function _BH_FN.GB_StartStableMonitor(
generation,
generator,
root,
anchorPosition
)
_BH_FN.GB_StopStableMonitor()
local startedAt = os.clock()
local elapsed = 0
GenBypass.RepairLostChecks = 0
GenBypass.StableMonitorConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function(dt)
elapsed = elapsed + dt
if elapsed < 0.15 then
return
end
elapsed = 0
local progress =
_BH_FN.GB_ReadGeneratorProgress(generator)
local character = LocalPlayer.Character
local humanoid =
character
and character:FindFirstChildOfClass("Humanoid")
local invalid =
not HubRuntime.Alive
or not GenBypass.Enabled
or generation ~= GenBypass.Generation
or not root
or not root.Parent
or not generator
or not generator.Parent
or not humanoid
or humanoid.Health <= 0
or os.clock() - startedAt
>= GenBypass.MaxActiveDuration
or (progress and progress >= 0.995)
if not invalid and anchorPosition then
invalid =
(root.Position - anchorPosition).Magnitude
> GenBypass.StayRadius
end
if not invalid
and humanoid.MoveDirection.Magnitude > 0.06 then
invalid = true
elseif not invalid
and GenBypass.NativeRepairExpected
and os.clock() - startedAt > 0.65 then
if _BH_FN.GB_HasNativeRepairPose(
GenBypass.NativeRepairPoint
) then
GenBypass.RepairLostChecks = 0
elseif GenBypass.PoseRestarting then
GenBypass.RepairLostChecks = 0
else
GenBypass.RepairLostChecks =
GenBypass.RepairLostChecks + 1
if GenBypass.RepairLostChecks >= 2 then
if GenBypass.PoseRestartAttempts
< GenBypass.MaxPoseRestartAttempts then
GenBypass.PoseRestartAttempts =
GenBypass.PoseRestartAttempts + 1
GenBypass.PoseRestarting = true
GenBypass.RepairLostChecks = 0
local repairPoint =
GenBypass.NativeRepairPoint
task.spawn(function()
local resumed =
_BH_FN.GB_StartNativePose(
repairPoint,
generation,
true
)
if generation
== GenBypass.Generation then
GenBypass.PoseRestarting = false
if resumed then
GenBypass.RepairLostChecks = 0
else
_BH_FN.GB_StopExtraRepair()
end
end
end)
else
invalid = true
end
end
end
end
if invalid then
_BH_FN.GB_StopExtraRepair()
end
end)
)
end
function _BH_FN.GB_StopExtraRepair()
GenBypass.Generation = GenBypass.Generation + 1
_BH_FN.GB_StopStableMonitor()
_BH_FN.GB_ReleaseStablePoints()
_BH_FN.GB_StopOwnedNativePose()
_BH_FN.GB_RestoreStableSnapshot()
GenBypass.OverlayActive = false
GenBypass.ActiveRepairEvent = nil
GenBypass.ActiveHRP = nil
GenBypass.OriginalCFrame = nil
GenBypass.JobGenerator = nil
GenBypass.JobAnchorPosition = nil
GenBypass.StartedFromRepair = false
GenBypass.RepairLostChecks = 0
if not GenBypass.WorkerGeneration then
GenBypass.Running = false
GenBypass.Cancelling = false
else
GenBypass.Cancelling = true
end
table.clear(GenBypass.Processed)
GB_UpdateButton()
end
function _BH_FN.GB_UnloadSafe()
GenBypass.Enabled = false
_BH_FN.GB_StopExtraRepair()
pcall(_BH_FN.GB_DisconnectRepairWatchers)
if GenBypass.UI then
_BH_FN.DestroyArtifact(GenBypass.UI)
GenBypass.UI = nil
GenBypass.Button = nil
end
end
function _BH_FN.GB_RecoverStaleLegacyInteraction()
return false
end
function GB_WaitRepairing(point, timeout)
return _BH_FN.GB_WaitStablePoint(
point,
timeout,
GenBypass.Generation
)
end
function GB_DoRepair(targetPoint)
if not HubRuntime.Alive
or not GenBypass.Enabled
or GenBypass.Running
or GenBypass.OverlayActive
or GenBypass.Cancelling
or not targetPoint
or not targetPoint.Parent then
return false
end
local generator =
GB_GetGeneratorFromPoint(targetPoint)
local remote =
_BH_FN.GB_GetRepairRemote()
local character = LocalPlayer.Character
local root =
character
and character:FindFirstChild("HumanoidRootPart")
local humanoid =
character
and character:FindFirstChildOfClass("Humanoid")
if not generator
or not remote
or not root
or not humanoid
or humanoid.Health <= 0
or (root.Position - targetPoint.Position).Magnitude
> GenBypass.MaxStartDistance then
return false
end
GenBypass.Generation = GenBypass.Generation + 1
local generation = GenBypass.Generation
local startedFromRepair =
_BH_FN.GB_IsClientRepairing()
local snapshot = {
Root = root,
Humanoid = humanoid,
CFrame = root.CFrame,
Anchored = root.Anchored,
WasRepairing = startedFromRepair,
LinearVelocity = root.AssemblyLinearVelocity,
AngularVelocity = root.AssemblyAngularVelocity,
AutoRotate = humanoid.AutoRotate,
}
GenBypass.Running = true
GenBypass.WorkerGeneration = generation
GenBypass.Cancelling = false
GenBypass.JobSnapshot = snapshot
GenBypass.ActiveRepairEvent = remote
GenBypass.ActiveHRP = root
GenBypass.OriginalCFrame = snapshot.CFrame
GenBypass.JobGenerator = generator
GenBypass.JobAnchorPosition = targetPoint.Position
GenBypass.StartedFromRepair = startedFromRepair
GenBypass.RepairLostChecks = 0
GenBypass.NativeRepairExpected = false
GenBypass.NativePoseOwned = false
GenBypass.NativeRepairPoint = nil
GenBypass.NativeRepairContext = nil
GenBypass.NativeRepairActions = nil
GenBypass.PoseRestarting = false
GenBypass.PoseRestartAttempts = 0
GenBypass.Processed[generator] = generation
table.clear(GenBypass.ActivePoints)
GB_UpdateButton()
local activated = 0
local ok, err = pcall(function()
local points = GB_GetPoints(generator)
table.sort(points, function(a, b)
return (a.Position - targetPoint.Position).Magnitude
< (b.Position - targetPoint.Position).Magnitude
end)
for _, point in ipairs(points) do
if not _BH_FN.GB_IsStableJobValid(
generation,
root,
generator
) then
break
end
if point ~= targetPoint and point.Parent then
if not _BH_FN.GB_MoveStableRoot(root, point) then
error("failed to move to generator point")
end
task.wait(GenBypass.PointSettleDelay)
if not _BH_FN.GB_IsStableJobValid(
generation,
root,
generator
) then
break
end
GenBypass.PendingPoint = point
local fired = pcall(function()
remote:FireServer(point, true)
end)
if fired then
local requestSent = true
local accepted =
_BH_FN.GB_WaitStablePoint(
point,
GenBypass.PointAcceptTimeout,
generation
)
if not accepted
and _BH_FN.GB_IsStableJobValid(
generation,
root,
generator
) then
pcall(function()
remote:FireServer(point, false)
end)
task.wait(GenBypass.PointRetryDelay)
if _BH_FN.GB_MoveStableRoot(root, point) then
local retrySent = pcall(function()
remote:FireServer(point, true)
end)
requestSent = requestSent or retrySent
accepted =
_BH_FN.GB_WaitStablePoint(
point,
0.35,
generation
)
end
end
if accepted or requestSent then
GenBypass.ActivePoints[point] = true
GenBypass.PendingPoint = nil
activated = activated + 1
else
pcall(function()
remote:FireServer(point, false)
end)
GenBypass.PendingPoint = nil
end
else
GenBypass.PendingPoint = nil
end
end
end
end)
_BH_FN.GB_RestoreStableSnapshot(snapshot)
local stillValid =
_BH_FN.GB_IsStableJobValid(
generation,
root,
generator
)
local nativeReady = false
if ok and stillValid and activated > 0 then
nativeReady = _BH_FN.GB_StartNativePose(
targetPoint,
generation,
true
)
stillValid =
_BH_FN.GB_IsStableJobValid(
generation,
root,
generator
)
end
if GenBypass.Processed[generator] == generation then
GenBypass.Processed[generator] = nil
end
if GenBypass.WorkerGeneration == generation then
GenBypass.WorkerGeneration = nil
GenBypass.Running = false
GenBypass.Cancelling = false
end
if not ok
or not stillValid
or activated <= 0
or not nativeReady then
_BH_FN.GB_ReleaseStablePoints()
_BH_FN.GB_StopOwnedNativePose()
GenBypass.OverlayActive = false
GenBypass.ActiveRepairEvent = nil
GenBypass.StartedFromRepair = false
GB_UpdateButton()
if not ok then
warn("[Bluehaven GenBypass V2] " .. tostring(err))
end
return false
end
GenBypass.OverlayActive = true
GB_UpdateButton()
_BH_FN.GB_StartStableMonitor(
generation,
generator,
root,
targetPoint.Position
)
return true
end
function _BH_FN.GB_Request()
if not HubRuntime.Alive
or not GenBypass.Enabled then
return false
end
if GenBypass.Cancelling then
return false
end
if GenBypass.Running
or GenBypass.OverlayActive then
_BH_FN.GB_StopExtraRepair()
return true
end
local now = os.clock()
if now - GenBypass.LastRequestAt
< GenBypass.RequestCooldown then
return false
end
GenBypass.LastRequestAt = now
GenBypass.CacheTimer = 0
local point, distance = GB_GetNearestPoint()
if not point
or not point.Parent
or not distance
or distance > GenBypass.MaxStartDistance then
return false
end
task.spawn(GB_DoRepair, point)
return true
end
function setGenBypass(value)
local enabled = value == true
if not enabled then
GenBypass.Enabled = false
_BH_FN.GB_StopExtraRepair()
pcall(_BH_FN.GB_DisconnectRepairWatchers)
else
GenBypass.Enabled = true
pcall(_BH_FN.GB_DisconnectRepairWatchers)
end
GB_UpdateButton()
end
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function()
_BH_FN.GB_StopExtraRepair()
end)
)
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
local GunAim = {
Enabled         = false,
Holding         = false,
TargetMode      = "Killer",
Strength        = 1,
Predict         = true,
PredictStrength = 0.12,
FOV             = 95,
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
local SharedAimFOV = {
Value = 95,
}
local ToolAimAssist = {
Enabled = false,
Tracer = false,
Prediction = true,
WallCheck = true,
UseFOV = true,
ShowFOV = false,
FOVColor = Color3.fromRGB(255, 170, 0),
Range = 180,
FOV = 95,
BulletSpeed = 200,
PredictionScale = 1.0,
TargetMode = "Auto",
TargetPart = "HumanoidRootPart",
StableTarget = true,
StickyExtraPixels = 22,
TargetSwitchMargin = 8,
PredictionTime = 0.12,
VelocityCap = 32,
CameraStrength = 0.46,
CameraTickRate = 0.02,
LastCameraTick = 0,
ToolConnections = setmetatable({}, {__mode = "k"}),
PlayerCharacterConn = nil,
CharacterConn = nil,
BackpackConn = nil,
RenderConnection = nil,
TracerPart = nil,
LastTarget = nil,
LastTargetAt = 0,
}
local SmartAimCore = {
Motion = setmetatable(
{},
{__mode = "k"}
),
MotionAlpha = 0.34,
}
function _BH_FN.AIM_LocalCanAssist()
return not _BH_FN.AIM_IsUnavailable(
LocalPlayer.Character
)
end
function _BH_FN.AIM_IsUnavailable(char)
if not char then
return true
end
local hum =
char:FindFirstChildOfClass(
"Humanoid"
)
if not hum
or hum.Health <= 0 then
return true
end
return char:GetAttribute("IsDead") == true
or char:GetAttribute("IsHooked") == true
or char:GetAttribute("IsCarried") == true
or char:GetAttribute("Knocked") == true
or char:GetAttribute("Downed") == true
or char:GetAttribute("IsDown") == true
end
function _BH_FN.AIM_ApplyCameraAssist(
targetPosition,
strength
)
local camera = workspace.CurrentCamera
if not camera
or typeof(targetPosition) ~= "Vector3" then
return false
end
local origin = camera.CFrame.Position
local delta = targetPosition - origin
if delta.Magnitude <= 0.01 then
return false
end
local desired = CFrame.lookAt(
origin,
targetPosition,
camera.CFrame.UpVector
)
camera.CFrame = camera.CFrame:Lerp(
desired,
math.clamp(tonumber(strength) or 0.35, 0.05, 1)
)
return true
end
function _BH_FN.AIM_GetSmoothedVelocity(
part,
cap
)
if not part
or not part.Parent then
return Vector3.zero
end
local raw =
part.AssemblyLinearVelocity
local flat =
Vector3.new(
raw.X,
0,
raw.Z
)
local maxSpeed =
math.max(
1,
tonumber(cap) or 30
)
if flat.Magnitude > maxSpeed then
flat =
flat.Unit * maxSpeed
end
local previous =
SmartAimCore.Motion[part]
if not previous then
SmartAimCore.Motion[part] =
flat
return flat
end
local alpha =
SmartAimCore.MotionAlpha
local smooth =
previous:Lerp(
flat,
alpha
)
SmartAimCore.Motion[part] =
smooth
return smooth
end
function _BH_FN.AIM_GetPredictionTime(
baseTime,
worldDistance,
velocity
)
local base =
math.clamp(
tonumber(baseTime) or 0.10,
0,
0.25
)
local distanceFactor =
math.clamp(
(tonumber(worldDistance) or 0)
/ 200,
0,
1
)
local speedFactor =
math.clamp(
(velocity and velocity.Magnitude or 0)
/ 24,
0,
1
)
return math.clamp(
base
* (0.72
+ distanceFactor * 0.30
+ speedFactor * 0.18),
0,
0.28
)
end
function _BH_FN.AIM_GetPredictedPosition(
part,
worldDistance,
baseTime,
velocityCap
)
if not part then
return nil
end
local velocity =
_BH_FN.AIM_GetSmoothedVelocity(
part,
velocityCap
)
local t =
_BH_FN.AIM_GetPredictionTime(
baseTime,
worldDistance,
velocity
)
return part.Position
+ velocity * t
end
function _BH_FN.AIM_GetCandidateParts(
char,
preferred
)
if not char then
return {}
end
if preferred == "HumanoidRootPart" then
local root =
char:FindFirstChild("HumanoidRootPart")
if root and root:IsA("BasePart") then
return {root}
end
end
local result = {}
local seen = {}
for _, name in ipairs({
preferred,
"HumanoidRootPart",
"UpperTorso",
"Torso",
"LowerTorso",
"Head",
}) do
if name
and not seen[name] then
seen[name] = true
local part =
char:FindFirstChild(name)
if part
and part:IsA("BasePart") then
result[#result + 1] =
part
end
end
end
return result
end
function _BH_FN.AIM_GetVisibleSampleCount(
origin,
myChar,
targetChar,
parts
)
if not origin
or not myChar
or not targetChar then
return 0
end
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances =
{myChar}
params.IgnoreWater = true
pcall(function()
params.RespectCanCollide = true
end)
local count = 0
for _, part in ipairs(parts) do
local hit =
workspace:Raycast(
origin,
part.Position - origin,
params
)
if not hit
or hit.Instance:IsDescendantOf(
targetChar
) then
count = count + 1
end
end
return count
end
function _BH_FN.AIM_GetRole(player)
if not player then
return nil
end
local function normalize(value)
local name =
string.lower(
tostring(value or "")
)
if name == "killer"
or name == "killers"
or string.find(name, "killer", 1, true)
or string.find(name, "slasher", 1, true)
or string.find(name, "hunter", 1, true)
or string.find(name, "monster", 1, true) then
return "Killer"
end
if name == "survivor"
or name == "survivors"
or string.find(name, "survivor", 1, true)
or string.find(name, "runner", 1, true)
or string.find(name, "civilian", 1, true) then
return "Survivor"
end
return nil
end
if player.Team then
local role = normalize(player.Team.Name)
if role then return role end
end
for _, key in ipairs({
"Role",
"role",
"CharacterRole",
}) do
local role =
normalize(player:GetAttribute(key))
if role then return role end
end
if player:GetAttribute("IsKiller") == true then
return "Killer"
end
if player:GetAttribute("IsSurvivor") == true then
return "Survivor"
end
local char = player.Character
if char then
for _, key in ipairs({
"Role",
"role",
"CharacterRole",
}) do
local role =
normalize(char:GetAttribute(key))
if role then return role end
end
if char:GetAttribute("IsKiller") == true then
return "Killer"
end
if char:GetAttribute("IsSurvivor") == true then
return "Survivor"
end
end
return nil
end
function _BH_FN.AIM_MatchesTargetRole(
player,
targetRole
)
if not player
or player == LocalPlayer
or not player.Character then
return false
end
local role = _BH_FN.AIM_GetRole(player)
if role then
return targetRole == "All"
or role == targetRole
end
local myRole = _BH_FN.AIM_GetRole(LocalPlayer)
local myTeam = LocalPlayer.Team
local theirTeam = player.Team
if myTeam and theirTeam and myTeam ~= theirTeam then
return targetRole == "All"
or myRole == nil
or targetRole ~= myRole
end
return targetRole == "All"
or myRole == nil
or targetRole ~= myRole
end
function _BH_FN.AIM_ResolveTargetRole(mode)
if mode and mode ~= "Auto" then
return mode
end
local localRole = _BH_FN.AIM_GetRole(LocalPlayer)
if localRole == "Killer" then
return "Survivor"
end
if localRole == "Survivor" then
return "Killer"
end
return "Killer"
end
local TargetAssistDiag = {
PistolEnabled = false,
VeilEnabled = false,
PrecisionEnabled = false, -- hidden diagnostic only
FOV = 95,
Range = 180,
WallCheck = true,
TickRate = 0.05,
LastTick = 0,
PistolTargetPart = "HumanoidRootPart",
PistolStableTarget = true,
StickyExtraPixels = 24,
PredictionTime = 0.12,
TargetSwitchMargin = 9,
VelocityCap = 30,
PistolStrength = 0.42,
VeilStrength = 0.08,
Connection = nil,
Gui = nil,
Circle = nil,
Label = nil,
InfoLabel = nil,
Target = nil,
Mode = nil,
}
local FlashlightAimAssist = {
Enabled = false,
FOV = 95,
Range = 120,
WallCheck = true,
TickRate = 0.05,
LastTick = 0,
Target = nil,
PredictionTime = 0.10,
StableTarget = true,
StickyExtraPixels = 18,
VelocityCap = 28,
Strength = 0.34,
Connection = nil,
Gui = nil,
Circle = nil,
Stroke = nil,
Label = nil,
}
local AimFOVVisual = {
Gui = nil,
Circle = nil,
Stroke = nil,
}
function _BH_FN.ensureAimFOVVisual()
if AimFOVVisual.Gui and AimFOVVisual.Gui.Parent
and AimFOVVisual.Circle and AimFOVVisual.Circle.Parent then
return
end
if AimFOVVisual.Gui then
_BH_FN.DestroyArtifact(AimFOVVisual.Gui)
end
local gui = _BH_FN.TrackArtifact(Instance.new("ScreenGui"))
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
function _BH_FN.updateAimFOVVisual()
_BH_FN.ensureAimFOVVisual()
local circle = AimFOVVisual.Circle
local stroke = AimFOVVisual.Stroke
if not circle or not stroke then return end
local diameter = math.max(20, (tonumber(SharedAimFOV.Value) or 95) * 2)
circle.Size = UDim2.fromOffset(diameter, diameter)
stroke.Color = ToolAimAssist.FOVColor
local role = type(_BH_FN.UI_GetMouseRole) == "function"
and _BH_FN.UI_GetMouseRole()
or _BH_FN.AIM_GetRole(LocalPlayer)
local playableRole = role == "Survivor"
or role == "Killer"
circle.Visible = HubRuntime.Alive
and ToolAimAssist.ShowFOV
and playableRole
and LocalPlayer.Character ~= nil
end
function _BH_FN.TAD_GetEquippedTool()
local char = LocalPlayer.Character
return char and char:FindFirstChildOfClass("Tool")
end
function _BH_FN.TAD_IsPistolEquipped()
local tool = _BH_FN.TAD_GetEquippedTool()
if not tool then
return false
end
local name = string.lower(tool.Name)
return (
string.find(name, "twist", 1, true)
and string.find(name, "fate", 1, true)
) ~= nil
or string.find(name, "pistol", 1, true) ~= nil
or string.find(name, "revolver", 1, true) ~= nil
or string.find(name, "handgun", 1, true) ~= nil
or tool:GetAttribute("IsGun") == true
or tool:GetAttribute("WeaponType") == "Pistol"
end
function _BH_FN.TAD_IsPistolAiming()
return _BH_FN.TAD_IsPistolEquipped()
end
function _BH_FN.TAD_NormalizeRoleName(value)
if value == nil then
return nil
end
local name =
string.lower(
tostring(value)
)
if name == "killer"
or name == "killers" then
return "Killer"
end
if name == "survivor"
or name == "survivors" then
return "Survivor"
end
return nil
end
function _BH_FN.TAD_GetPlayerRole(player)
if not player then
return nil
end
local sharedRole = _BH_FN.AIM_GetRole(player)
if sharedRole then
return sharedRole
end
if player.Team then
local role =
_BH_FN.TAD_NormalizeRoleName(
player.Team.Name
)
if role then
return role
end
end
for _, key in ipairs({
"Role",
"role",
"CharacterRole",
}) do
local role =
_BH_FN.TAD_NormalizeRoleName(
player:GetAttribute(key)
)
if role then
return role
end
end
if player:GetAttribute("IsKiller") == true then
return "Killer"
end
if player:GetAttribute("IsSurvivor") == true then
return "Survivor"
end
local char = player.Character
if char then
for _, key in ipairs({
"Role",
"role",
"CharacterRole",
}) do
local role =
_BH_FN.TAD_NormalizeRoleName(
char:GetAttribute(key)
)
if role then
return role
end
end
if char:GetAttribute("IsKiller") == true then
return "Killer"
end
if char:GetAttribute("IsSurvivor") == true then
return "Survivor"
end
end
return nil
end
function _BH_FN.TAD_GetMode()
if TargetAssistDiag.PistolEnabled
and _BH_FN.TAD_IsPistolAiming() then
return "Pistol", "Killer"
end
if TargetAssistDiag.VeilEnabled
and _BH_FN.TAD_GetPlayerRole(
LocalPlayer
) == "Killer" then
return "Veil", "Survivor"
end
return nil, nil
end
function _BH_FN.TAD_EnsureGui()
if TargetAssistDiag.Gui and TargetAssistDiag.Gui.Parent
and TargetAssistDiag.Circle and TargetAssistDiag.Circle.Parent
and TargetAssistDiag.Label and TargetAssistDiag.Label.Parent then
return
end
if TargetAssistDiag.Gui then _BH_FN.DestroyArtifact(TargetAssistDiag.Gui) end
local gui = _BH_FN.TrackArtifact(Instance.new("ScreenGui"))
gui.Name = "BluehavenTargetAssistDiag"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 30
gui.Parent = PlayerGui
local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Visible = false
circle.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.2
stroke.Transparency = 0.4
stroke.Parent = circle
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0.5, 42)
label.Size = UDim2.fromOffset(160, 20)
label.BackgroundTransparency = 1
label.TextSize = 13
label.Font = Enum.Font.GothamSemibold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.45
label.Visible = false
label.Parent = gui
local info = Instance.new("TextLabel")
info.AnchorPoint = Vector2.new(0.5, 0)
info.Position = UDim2.new(0.5, 0, 0.5, 62)
info.Size = UDim2.fromOffset(260, 18)
info.BackgroundTransparency = 1
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.fromRGB(235, 235, 235)
info.TextStrokeTransparency = 0.55
info.Text = ""
info.Visible = false
info.Parent = gui
TargetAssistDiag.Gui = gui
TargetAssistDiag.Circle = circle
TargetAssistDiag.Label = label
TargetAssistDiag.InfoLabel = info
end
function _BH_FN.TAD_Hide()
if TargetAssistDiag.Circle then
TargetAssistDiag.Circle.Visible = false
end
if TargetAssistDiag.Label then
TargetAssistDiag.Label.Visible = false
end
if TargetAssistDiag.InfoLabel then
TargetAssistDiag.InfoLabel.Visible = false
end
TargetAssistDiag.Target = nil
TargetAssistDiag.Mode = nil
end
function _BH_FN.TAD_TargetMatches(player, targetRole)
if not player
or player == LocalPlayer then
return false
end
if TargetAssistDiag.Mode == "Veil" then
targetRole = "Survivor"
end
return _BH_FN.AIM_MatchesTargetRole(
player,
targetRole
)
end
function _BH_FN.TAD_GetPistolTargetPart(char)
if not char then return nil end
local preferred = TargetAssistDiag.PistolTargetPart or "Head"
local part = char:FindFirstChild(preferred)
if part and part:IsA("BasePart") then
return part
end
return char:FindFirstChild("Head")
or char:FindFirstChild("HumanoidRootPart")
or char:FindFirstChild("UpperTorso")
end
function _BH_FN.TAD_GetFlatVelocity(
part,
cap
)
return _BH_FN.AIM_GetSmoothedVelocity(
part,
cap
)
end
function _BH_FN.TAD_GetPredictedPosition(
part
)
if not part then
return nil
end
local root =
LocalPlayer.Character
and LocalPlayer.Character:FindFirstChild(
"HumanoidRootPart"
)
local distance =
root
and (
part.Position
- root.Position
).Magnitude
or 0
return _BH_FN.AIM_GetPredictedPosition(
part,
distance,
TargetAssistDiag.PredictionTime,
TargetAssistDiag.VelocityCap
)
end
function _BH_FN.TAD_IsCharacterUnavailable(char)
return _BH_FN.AIM_IsUnavailable(char)
end
function _BH_FN.TAD_IsPartVisible(
myChar,
origin,
targetPart
)
if not TargetAssistDiag.WallCheck then
return true
end
if not myChar
or not origin
or not targetPart
or not targetPart.Parent then
return false
end
local targetChar =
targetPart.Parent
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances =
{myChar}
params.IgnoreWater = true
pcall(function()
params.RespectCanCollide = true
end)
local samples = {}
for _, name in ipairs({
targetPart.Name,
"Head",
"UpperTorso",
"HumanoidRootPart",
}) do
local part =
targetChar:FindFirstChild(name)
if part
and part:IsA("BasePart") then
samples[#samples + 1] =
part.Position
end
end
local originPosition =
origin.Position
+ Vector3.new(0, 1.1, 0)
for _, position in ipairs(samples) do
local delta =
position - originPosition
local hit =
workspace:Raycast(
originPosition,
delta,
params
)
if not hit
or hit.Instance:IsDescendantOf(
targetChar
) then
return true
end
end
return false
end
function _BH_FN.TAD_GetScreenScore(
cam,
center,
position,
worldDistance
)
local screen,
onScreen =
cam:WorldToViewportPoint(
position
)
if not onScreen
or screen.Z <= 0 then
return nil
end
local screenDistance =
(
Vector2.new(
screen.X,
screen.Y
)
- center
).Magnitude
if screenDistance
> SharedAimFOV.Value then
return nil
end
return screenDistance
+ worldDistance * 0.025,
screenDistance
end
function _BH_FN.TAD_FindTarget(targetTeam)
if not _BH_FN.AIM_LocalCanAssist() then
return nil
end
local cam =
workspace.CurrentCamera
local myChar =
LocalPlayer.Character
if not cam or not myChar then
return nil
end
local root =
myChar:FindFirstChild(
"HumanoidRootPart"
)
if not root then
return nil
end
local viewport =
cam.ViewportSize
local center =
Vector2.new(
viewport.X * 0.5,
viewport.Y * 0.5
)
local function evaluate(part, extraFOV)
if not part
or not part.Parent
or not part:IsA("BasePart") then
return nil
end
local char =
part.Parent
local player =
Players:GetPlayerFromCharacter(
char
)
if not player
or not _BH_FN.TAD_TargetMatches(
player,
targetTeam
) then
return nil
end
local hum =
char:FindFirstChildOfClass(
"Humanoid"
)
if not hum
or hum.Health <= 0
or _BH_FN.TAD_IsCharacterUnavailable(
char
) then
return nil
end
local worldDistance =
(
part.Position
- root.Position
).Magnitude
if worldDistance
> TargetAssistDiag.Range then
return nil
end
local predicted =
TargetAssistDiag.Mode == "Veil"
and part.Position
or _BH_FN.TAD_GetPredictedPosition(
part
)
or part.Position
local screen,
onScreen =
cam:WorldToViewportPoint(
predicted
)
if not onScreen
or screen.Z <= 0 then
return nil
end
local screenDistance =
(
Vector2.new(
screen.X,
screen.Y
)
- center
).Magnitude
if screenDistance
> SharedAimFOV.Value
+ (extraFOV or 0) then
return nil
end
if not _BH_FN.TAD_IsPartVisible(
myChar,
root,
part
) then
return nil
end
local score =
screenDistance
+ worldDistance * 0.025
return {
Part = part,
Score = score,
ScreenDistance = screenDistance,
}
end
local current =
TargetAssistDiag.Target
local currentResult = nil
if TargetAssistDiag.PistolStableTarget
and current then
currentResult =
evaluate(
current,
TargetAssistDiag.StickyExtraPixels
)
end
local best = nil
for _, player in ipairs(
Players:GetPlayers()
) do
if _BH_FN.TAD_TargetMatches(
player,
targetTeam
) and player.Character then
local char =
player.Character
local preferred
if TargetAssistDiag.Mode
== "Veil" then
preferred =
"HumanoidRootPart"
else
preferred =
TargetAssistDiag.PistolTargetPart
or "Head"
end
local result = nil
for _, part in ipairs(
_BH_FN.AIM_GetCandidateParts(
char,
preferred
)
) do
local candidate =
evaluate(
part,
0
)
if candidate
and (
not result
or candidate.Score
< result.Score
) then
result =
candidate
end
end
if result
and (
not best
or result.Score < best.Score
) then
best = result
end
end
end
if currentResult then
if not best
or currentResult.Score
<= best.Score
+ TargetAssistDiag.TargetSwitchMargin then
return currentResult.Part
end
end
return best
and best.Part
or nil
end
function _BH_FN.TAD_GetPrecisionInfo(target)
if not target
or not target.Parent then
return nil
end
local cam = workspace.CurrentCamera
local char = LocalPlayer.Character
local root = char
and char:FindFirstChild("HumanoidRootPart")
if not cam or not root then
return nil
end
local delta =
target.Position - cam.CFrame.Position
if delta.Magnitude <= 0.001 then
return nil
end
local targetDirection = delta.Unit
local shotDirection =
cam.CFrame.LookVector.Unit
local dot =
math.clamp(
shotDirection:Dot(targetDirection),
-1,
1
)
local angleError =
math.deg(math.acos(dot))
local screen, onScreen =
cam:WorldToViewportPoint(
target.Position
)
local screenError = math.huge
if onScreen and screen.Z > 0 then
local viewport = cam.ViewportSize
screenError =
(
Vector2.new(
screen.X,
screen.Y
)
- Vector2.new(
viewport.X * 0.5,
viewport.Y * 0.5
)
).Magnitude
end
local worldDistance =
(
target.Position - root.Position
).Magnitude
local targetHumanoid =
target.Parent:FindFirstChildOfClass(
"Humanoid"
)
local moving =
targetHumanoid
and targetHumanoid.MoveDirection.Magnitude
> 0.05
return {
Angle = angleError,
Screen = screenError,
Distance = worldDistance,
Moving = moving == true,
Part = target.Name,
}
end
function _BH_FN.TAD_Update()
local mode, targetTeam = _BH_FN.TAD_GetMode()
if not mode then _BH_FN.TAD_Hide(); return end
if mode == "Veil" then
targetTeam = "Survivor"
end
_BH_FN.TAD_EnsureGui()
local diameter = math.max(20, SharedAimFOV.Value * 2)
TargetAssistDiag.Circle.Size = UDim2.fromOffset(diameter, diameter)
TargetAssistDiag.Circle.Visible = true
TargetAssistDiag.Mode = mode
local target =
_BH_FN.TAD_FindTarget(targetTeam)
TargetAssistDiag.Target = target
if target then
local targetPosition =
mode == "Veil"
and target.Position
or _BH_FN.TAD_GetPredictedPosition(target)
_BH_FN.AIM_ApplyCameraAssist(
targetPosition,
mode == "Pistol"
and TargetAssistDiag.PistolStrength
or TargetAssistDiag.VeilStrength
)
end
TargetAssistDiag.Label.Text =
string.upper(mode) .. " TARGET"
TargetAssistDiag.Label.Visible =
mode ~= "Pistol"
and target ~= nil
if TargetAssistDiag.InfoLabel then
TargetAssistDiag.InfoLabel.Visible =
false
end
end
function _BH_FN.TAD_RefreshConnection()
local enabled = TargetAssistDiag.PistolEnabled or TargetAssistDiag.VeilEnabled
if TargetAssistDiag.Connection then
pcall(function() TargetAssistDiag.Connection:Disconnect() end)
_BH_FN.ForgetConnection(TargetAssistDiag.Connection)
TargetAssistDiag.Connection = nil
end
if not enabled then _BH_FN.TAD_Hide(); return end
_BH_FN.TAD_EnsureGui()
TargetAssistDiag.LastTick = 0
TargetAssistDiag.Connection = _BH_FN.TrackConnection(
RunService.RenderStepped:Connect(function()
if not HubRuntime.Alive then return end
local now = os.clock()
if now - TargetAssistDiag.LastTick < TargetAssistDiag.TickRate then return end
TargetAssistDiag.LastTick = now
_BH_FN.TAD_Update()
end)
)
end
function _BH_FN.FAA_FindFlashlightPart()
local char = LocalPlayer.Character
if not char then
return nil
end
local fallback = nil
for _, obj in ipairs(
char:GetDescendants()
) do
local remaining =
obj:GetAttribute("remaining")
if type(remaining) == "number" then
local lower =
string.lower(obj.Name)
if string.find(
lower,
"flash",
1,
true
)
or string.find(
lower,
"light",
1,
true
)
or string.find(
lower,
"senter",
1,
true
) then
return obj
end
fallback = fallback or obj
end
end
return fallback
end
function _BH_FN.FAA_IsFlashlightEquipped()
local part =
_BH_FN.FAA_FindFlashlightPart()
if not part then
local tool = _BH_FN.TAD_GetEquippedTool()
if not tool then return false end
local name = string.lower(tool.Name)
return string.find(name, "flash", 1, true) ~= nil
or string.find(name, "light", 1, true) ~= nil
or string.find(name, "senter", 1, true) ~= nil
end
local remaining =
tonumber(
part:GetAttribute("remaining")
) or 0
return part:GetAttribute("remaining") == nil
or remaining > 0
end
function _BH_FN.FAA_EnsureVisual()
if FlashlightAimAssist.Gui
and FlashlightAimAssist.Gui.Parent
and FlashlightAimAssist.Circle
and FlashlightAimAssist.Circle.Parent
and FlashlightAimAssist.Label
and FlashlightAimAssist.Label.Parent then
return
end
if FlashlightAimAssist.Gui then
_BH_FN.DestroyArtifact(FlashlightAimAssist.Gui)
end
local gui = _BH_FN.TrackArtifact(Instance.new("ScreenGui"))
gui.Name = "BluehavenFlashlightAimAssist"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 31
gui.Parent = PlayerGui
local circle = Instance.new("Frame")
circle.Name = "FOV"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Visible = false
circle.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.2
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(235, 235, 235)
stroke.Parent = circle
local label = Instance.new("TextLabel")
label.Name = "Target"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0.5, 18)
label.Size = UDim2.fromOffset(90, 20)
label.BackgroundTransparency = 1
label.Text = "TARGET"
label.TextSize = 13
label.Font = Enum.Font.GothamSemibold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.45
label.Visible = false
label.Parent = gui
FlashlightAimAssist.Gui = gui
FlashlightAimAssist.Circle = circle
FlashlightAimAssist.Stroke = stroke
FlashlightAimAssist.Label = label
end
function _BH_FN.FAA_Hide()
if FlashlightAimAssist.Circle then
FlashlightAimAssist.Circle.Visible = false
end
if FlashlightAimAssist.Label then
FlashlightAimAssist.Label.Visible = false
end
FlashlightAimAssist.Target = nil
end
function _BH_FN.FAA_IsKiller(player)
if not player or player == LocalPlayer then
return false
end
local role = player:GetAttribute("Role")
if role == "Killer" then
return true
end
local teamName =
player.Team
and string.lower(player.Team.Name)
or ""
return string.find(
teamName,
"killer",
1,
true
) ~= nil
end
function _BH_FN.FAA_GetPredictedPosition(
part
)
if not part then
return nil
end
local root =
LocalPlayer.Character
and LocalPlayer.Character:FindFirstChild(
"HumanoidRootPart"
)
local distance =
root
and (
part.Position
- root.Position
).Magnitude
or 0
return _BH_FN.AIM_GetPredictedPosition(
part,
distance,
FlashlightAimAssist.PredictionTime,
FlashlightAimAssist.VelocityCap
)
end
function _BH_FN.FAA_IsVisible(
myChar,
myRoot,
targetPart
)
if not FlashlightAimAssist.WallCheck then
return true
end
if not myChar
or not myRoot
or not targetPart
or not targetPart.Parent then
return false
end
local char =
targetPart.Parent
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances =
{myChar}
params.IgnoreWater = true
local origin =
myRoot.Position
+ Vector3.new(0, 1.2, 0)
for _, name in ipairs({
"Head",
"UpperTorso",
"HumanoidRootPart",
}) do
local part =
char:FindFirstChild(name)
if part
and part:IsA("BasePart") then
local hit =
workspace:Raycast(
origin,
part.Position - origin,
params
)
if not hit
or hit.Instance:IsDescendantOf(
char
) then
return true
end
end
end
return false
end
function _BH_FN.FAA_FindTarget()
if not _BH_FN.AIM_LocalCanAssist() then
return nil
end
local cam =
workspace.CurrentCamera
local myChar =
LocalPlayer.Character
if not cam or not myChar then
return nil
end
local myRoot =
myChar:FindFirstChild(
"HumanoidRootPart"
)
if not myRoot then
return nil
end
local viewport =
cam.ViewportSize
local center =
Vector2.new(
viewport.X * 0.5,
viewport.Y * 0.5
)
local function evaluate(part, extraFOV)
if not part
or not part.Parent
or not part:IsA("BasePart") then
return nil
end
local char =
part.Parent
local hum =
char:FindFirstChildOfClass(
"Humanoid"
)
if not hum
or hum.Health <= 0
or _BH_FN.TAD_IsCharacterUnavailable(
char
) then
return nil
end
local worldDistance =
(
part.Position
- myRoot.Position
).Magnitude
if worldDistance
> FlashlightAimAssist.Range then
return nil
end
local predicted =
_BH_FN.FAA_GetPredictedPosition(
part
)
or part.Position
local screenPos,
onScreen =
cam:WorldToViewportPoint(
predicted
)
if not onScreen
or screenPos.Z <= 0 then
return nil
end
local screenDistance =
(
Vector2.new(
screenPos.X,
screenPos.Y
)
- center
).Magnitude
if screenDistance
> SharedAimFOV.Value
+ (extraFOV or 0) then
return nil
end
if not _BH_FN.FAA_IsVisible(
myChar,
myRoot,
part
) then
return nil
end
return {
Part = part,
Score = screenDistance
+ worldDistance * 0.025,
}
end
local current = nil
if FlashlightAimAssist.StableTarget
and FlashlightAimAssist.Target then
current =
evaluate(
FlashlightAimAssist.Target,
FlashlightAimAssist.StickyExtraPixels
)
end
local best = nil
local targetRole =
_BH_FN.AIM_ResolveTargetRole(
ToolAimAssist.TargetMode
)
for _, player in ipairs(
Players:GetPlayers()
) do
if player ~= LocalPlayer
and targetRole ~= nil
and _BH_FN.AIM_MatchesTargetRole(
player,
targetRole
)
and player.Character then
local char =
player.Character
local result = nil
for _, part in ipairs(
_BH_FN.AIM_GetCandidateParts(
char,
ToolAimAssist.TargetPart
)
) do
local candidate =
evaluate(
part,
0
)
if candidate
and (
not result
or candidate.Score
< result.Score
) then
result =
candidate
end
end
if result
and (
not best
or result.Score < best.Score
) then
best = result
end
end
end
if current then
if not best
or current.Score
<= best.Score + 8 then
return current.Part
end
end
return best
and best.Part
or nil
end
function _BH_FN.FAA_Update()
if not FlashlightAimAssist.Enabled
or not _BH_FN.FAA_IsFlashlightEquipped() then
_BH_FN.FAA_Hide()
return
end
_BH_FN.FAA_EnsureVisual()
local diameter =
math.max(
20,
(tonumber(SharedAimFOV.Value) or 95) * 2
)
FlashlightAimAssist.Circle.Size =
UDim2.fromOffset(
diameter,
diameter
)
FlashlightAimAssist.Circle.Visible = true
local target = _BH_FN.FAA_FindTarget()
FlashlightAimAssist.Target = target
if target then
_BH_FN.AIM_ApplyCameraAssist(
_BH_FN.FAA_GetPredictedPosition(target),
FlashlightAimAssist.Strength
)
end
FlashlightAimAssist.Label.Visible =
target ~= nil
end
function _BH_FN.FAA_SetEnabled(state)
FlashlightAimAssist.Enabled =
state == true
if FlashlightAimAssist.Connection then
pcall(function()
FlashlightAimAssist.Connection:Disconnect()
end)
_BH_FN.ForgetConnection(
FlashlightAimAssist.Connection
)
FlashlightAimAssist.Connection = nil
end
if not FlashlightAimAssist.Enabled then
_BH_FN.FAA_Hide()
return
end
_BH_FN.FAA_EnsureVisual()
FlashlightAimAssist.LastTick = 0
FlashlightAimAssist.Connection =
_BH_FN.TrackConnection(
RunService.RenderStepped:Connect(function()
if not HubRuntime.Alive
or not FlashlightAimAssist.Enabled then
return
end
local now = os.clock()
if now
- FlashlightAimAssist.LastTick
< FlashlightAimAssist.TickRate then
return
end
FlashlightAimAssist.LastTick = now
_BH_FN.FAA_Update()
end)
)
end
local AttackAim = {
Enabled         = false,
Holding         = false,
Strength        = 1,
Predict         = true,
PredictStrength = 0.12,
FOV             = 95,
VisibilityCheck = true,
AimPart         = "HumanoidRootPart"
}
local SpearAim = {
Enabled = false,
Gravity = 50,
Speed   = 100,
FOV     = 95,
AimPart = "HumanoidRootPart"
}
function _BH_FN.SetSharedAimFOV(value)
local v =
math.clamp(
tonumber(value) or 95,
40,
500
)
SharedAimFOV.Value = v
SilentAim.FOV = v
GunAim.FOV = v
ToolAimAssist.FOV = v
TargetAssistDiag.FOV = v
FlashlightAimAssist.FOV = v
AttackAim.FOV = v
SpearAim.FOV = v
pcall(_BH_FN.updateAimFOVVisual)
if TargetAssistDiag.PistolEnabled
or TargetAssistDiag.VeilEnabled then
pcall(_BH_FN.TAD_Update)
end
if FlashlightAimAssist.Enabled then
pcall(_BH_FN.FAA_Update)
end
end
function _BH_FN.SetSharedAimPart(value)
local part = value == "Kepala"
and "Head"
or value == "Dada"
and "UpperTorso"
or "HumanoidRootPart"
SilentAim.TargetPart = part
GunAim.AimPart = part
ToFAimConfig.AimPart = part
ToolAimAssist.TargetPart = part
AttackAim.AimPart = part
SpearAim.AimPart = part
ToolAimAssist.LastTarget = nil
end
local Killer = {
KillAll   = false,
KillRange = 500,
KillTarget = nil,
KillLastAttack = 0,
KillLastTeleport = 0,
KillAttackInterval = 0.075,
KillTeleportInterval = 0.04,
KillBehindDistance = 3.25,
BypassCooldown = false,
NoAttackSlow = false,
BypassLeap = false,
ThirdPerson = false,
ThirdPersonWasActive = false,
ThirdPersonOrder = nil,
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
local CameraMutation = {
Sequence = 0,
}
local CameraZoom = {
UnlimitedZoom = false,
MaxDistance   = 1000,
MinDistance   = 0,
ZoomWasActive = false,
SavedMinZoom  = nil,
SavedMaxZoom  = nil,
ZoomOrder     = nil,
FOVEnabled    = false,
FOV           = 70,
FOVWasActive  = false,
SavedFOV      = nil,
AppliedFOV    = nil,
FOVOrder      = nil,
}
local UnloadValidation = {
Token = 0,
LastReasons = {},
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
local AntiKnockdown = {
Enabled = false,
Active = false,
Connection = nil,
CharacterConnection = nil,
AnimationConnection = nil,
RagdollConnection = nil,
HealthConnection = nil,
Character = nil,
Humanoid = nil,
Animator = nil,
RagdollTrigger = nil,
OriginalSuppressHit = nil,
OriginalRagdollValue = nil,
OriginalPlatformStand = nil,
OriginalSit = nil,
OriginalAutoRotate = nil,
AnimationController = nil,
ControllerClass = nil,
OriginalKnockedWalkSpeed = nil,
OriginalCheckConditions = nil,
OriginalGetDesiredBaseSpeed = nil,
OriginalPlayHitAnimation = nil,
OriginalPlayAnimation = nil,
PatchedCheckConditions = nil,
PatchedGetDesiredBaseSpeed = nil,
PatchedPlayHitAnimation = nil,
PatchedPlayAnimation = nil,
HealthIndexInstalled = false,
OriginalHealthIndex = nil,
HealthSpoofDepth = 0,
ProximityModule = nil,
ProximityConfig = nil,
OriginalCantInteract = nil,
OriginalProximityScan = nil,
PatchedCantInteract = nil,
PatchedProximityScan = nil,
ControllerScanAt = 0,
ControllerScanInterval = 3,
AnimationScanAt = 0,
AnimationScanInterval = 0.08,
KnockedAnimationIds = {
["74118390445259"] = true,
["106618106536124"] = true,
["104682704142865"] = true,
["139830743437188"] = true,
["121845674088602"] = true,
},
BaseWalkSpeed = 10,
TickRate = 0.06,
LastTick = 0,
}
local AntiLoopStuck = {
Enabled = false,
Connection = nil,
LastPosition = nil,
StillSince = 0,
LastTick = 0,
CooldownUntil = 0,
SampleRate = 0.10,
TriggerTime = 0.90,
MoveThreshold = 0.40,
}
local SelfHeal = {
Enabled = false,
Running = false,
Accepted = false,
Generation = 0,
MonitorConnection = nil,
HealthWatchConnection = nil,
CharacterWatchConnection = nil,
RetryAt = 0,
MonitorInterval = 0.10,
HealthRatioThreshold = 0.50,
TargetRoot = nil,
TargetCharacter = nil,
ClientStateOwned = false,
StartHealth = 0,
HealAnimConnection = nil,
HealAnimRecConnection = nil,
StopConnection = nil,
DoneConnection = nil,
HealthConnection = nil,
Animator = nil,
AnimationPlayedConnection = nil,
AnimationGuardConnection = nil,
AnimationSuppressUntil = 0,
AnimationScanInterval = 0.12,
BaselineTracks = setmetatable({}, {__mode = "k"}),
HiddenHealTracks = setmetatable({}, {__mode = "k"}),
AckTimeout = 2.25,
}
local DropAllPallet = {
Running = false,
Generation = 0,
Delay = 0.06,
AckTimeout = 0.55,
TweenSpeed = 230,
TweenMin = 0.08,
TweenMax = 0.38,
ActiveTween = nil,
ArrivalSettle = 0.09,
DropSettle = 0.12,
DropStateTimeout = 1.25,
Requested = 0,
Success = 0,
Failed = 0,
AckCounter = 0,
AckConnection = nil,
OriginalCFrame = nil,
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
BoostCharacter         = nil,
BoostBase              = 1,
BoostBaseWasNil        = true,
BoostLastWritten       = nil,
OriginalWalkSpeed      = 16,
NoClip                 = false
}
local FastVault = {
Enabled              = false,
Speed                = 1.85,
CharacterConnection  = nil,
VaultStateConnection = nil,
VaultStateUpperConnection = nil,
SlideStateConnection = nil,
SlideStateUpperConnection = nil,
VaultBindableConnection = nil,
DescendantConnection = nil,
AnimatorConnection   = nil,
SyncConnection       = nil,
Character            = nil,
Interact             = nil,
Animator             = nil,
VaultWindowUntil     = 0,
WindowJumpUntil      = 0,
RestoreToken         = 0,
SlideActive         = false,
SlideToken          = 0,
SlideWalkSpeed      = 10,
PalletSlideUntil    = 0,
OriginalVaultSpeed  = nil,
VaultSpeedWasNil    = true,
LastWrittenVaultSpeed = nil,
ProximityModule = nil,
OriginalFindNearestPoint = nil,
PatchedFindNearestPoint = nil,
BoostedTracks        = setmetatable({}, {__mode = "k"}),
}
local AntiSlowVault = {
Enabled = false,
Character = nil,
Humanoid = nil,
Interact = nil,
CharacterConnection = nil,
VaultConnection = nil,
VaultBindableConnection = nil,
SlideConnection = nil,
SlideUpperConnection = nil,
SlowConnection = nil,
SlowServerConnection = nil,
DescendantConnection = nil,
HeartbeatConnection = nil,
LastFreeWalkSpeed = 10,
CapturedWalkSpeed = 10,
PendingWalkSpeed = 10,
WasVaulting = false,
WindowVaultActive = false,
SlideWasActive = false,
Generation = 0,
GuardUntil = 0,
GuardDuration = 5,
SampleInterval = 0.08,
MinUsefulSpeed = 4,
MinFreeSample = 8,
}
local ParryDryRun = {
Enabled = false,
LastLog = {},
LogCooldown = 0.35,
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
Surv_ParrySafety = true,
Surv_ParryAggressive = false,
Surv_ParryCircle = true,
Surv_ParryRadius = 9.5,
Surv_ParryFace = 0.7,
Surv_AutoCrouch = false,
Ignored_Skills_List = {}
}
local State = {
ParryCooldown = false,
ParryCooldownTime = 60,
ParryInputLockUntil = 0,
ParryCooldownThread = nil,
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
lastHookESP         = 0,
lastSCPEsp          = 0,
lastKillerUpdate    = 0,
lastGodMode         = 0,
lastFooterUpdate    = 0,
lastTracerScan      = 0,
lastPalletScan      = 0,
lastPalletDrop      = 0,
lastVaultBlock      = 0
}
local ESPPerf = {
PlayerInterval    = 0.18,
StatusInterval    = 0.45,
GeneratorInterval = 0.60,
WindowInterval    = 0.35,
PalletInterval    = 0.35,
HookInterval      = 0.45,
SCPInterval       = 0.50,
MapBatchSize      = 40,
WindowCursor      = 1,
PalletCursor      = 1,
HookCursor        = 1,
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
local Attached = setmetatable({}, {__mode = "k"})
function _BH_FN.shouldHideNameObject(object)
local ok, isTextObj = pcall(function()
return object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")
end)
if not ok or not isTextObj then return false end
local text = ""
pcall(function() text = tostring(object.Text or "") end)
return text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil
end
local HideNameCharConn = nil
function _BH_FN.hideOverheadName(enabled)
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
if obj.Name:lower():find("name") or obj.Name:lower():find("overhead") then
obj.Enabled = not enabled
end
end
end
end
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
function _BH_FN.enableHideName(enabled)
if HideName.Connection then
pcall(function() HideName.Connection:Disconnect() end)
HideName.Connection = nil
end
if HideNameCharConn then
pcall(function() HideNameCharConn:Disconnect() end)
HideNameCharConn = nil
end
local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if playerGui then
local function process(object)
if _BH_FN.shouldHideNameObject(object) then
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
_BH_FN.hideOverheadName(enabled)
if enabled then
HideNameCharConn = LocalPlayer.CharacterAdded:Connect(function()
task.wait(0.5)
if HideName.Enabled then
_BH_FN.hideOverheadName(true)
end
end)
end
end
local getRoot
function _BH_FN.getSilentTarget()
local root = getRoot()
if not root then return nil end
local myPos = root.Position
local cam = workspace.CurrentCamera
if not cam then return nil end
local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
local best = nil
local bestScore = math.huge
local function consider(part, targetModel)
if not part
or not part:IsA("BasePart")
or not targetModel then
return
end
local worldDist =
(part.Position - myPos).Magnitude
if worldDist > SilentAim.Distance then
return
end
local targetPos =
SilentAim.Prediction
and _BH_FN.AIM_GetPredictedPosition(
part,
worldDist,
SilentAim.PredictStrength,
ToolAimAssist.VelocityCap
)
or part.Position
if SilentAim.WallCheck then
local visible =
_BH_FN.AIM_GetVisibleSampleCount(
myPos,
LocalPlayer.Character,
targetModel,
_BH_FN.AIM_GetCandidateParts(
targetModel,
part.Name
)
)
if visible <= 0 then return end
end
local screenPos, onScreen =
cam:WorldToViewportPoint(targetPos)
if not onScreen or screenPos.Z <= 0 then
return
end
local screenDist =
(Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
if screenDist > SharedAimFOV.Value then
return
end
local score = screenDist + worldDist * 0.02
if score < bestScore then
bestScore = score
best = part
end
end
local resolvedTargetRole =
_BH_FN.AIM_ResolveTargetRole(
SilentAim.TargetMode
)
if SilentAim.TargetMode == "SCP" then
for obj in pairs(ESPCache.SCP) do
if obj and obj.Parent then
if obj:IsA("Model") then
local part =
obj:FindFirstChild(
SilentAim.TargetPart,
true
)
or obj:FindFirstChild(
"HumanoidRootPart",
true
)
or obj.PrimaryPart
or obj:FindFirstChildWhichIsA(
"BasePart",
true
)
consider(part, obj)
elseif obj:IsA("BasePart") then
consider(obj, obj.Parent)
end
end
end
return best
end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character then
if not _BH_FN.AIM_IsUnavailable(p.Character) then
local valid = SilentAim.TargetMode == "All"
or _BH_FN.AIM_MatchesTargetRole(
p,
resolvedTargetRole
)
if valid then
for _, part in ipairs(
_BH_FN.AIM_GetCandidateParts(
p.Character,
SilentAim.TargetPart
)
) do
consider(part, p.Character)
end
end
end
end
end
return best
end
function _BH_FN.setupSilentAimHook()
SilentAim.Enabled = true
silentHookActive = false
return true
end
function _BH_FN.removeSilentAimHook()
SilentAim.Enabled = false
silentHookActive = false
silentOriginalCast = nil
end
function IsSafeToParry(char)
if not Config.Surv_ParrySafety then return true end
if not char then return false end
local interactObj =
_BH_FN.GB_GetClientInteract(char)
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
local role = _BH_FN.AIM_GetRole(LocalPlayer)
if role then
return role
end
return LocalPlayer.Team
and "Spectator"
or "Unknown"
end
function IsSurvivor(p)
return p ~= nil
and _BH_FN.AIM_GetRole(p) == "Survivor"
end
function IsKiller(p)
return p
and (
p:GetAttribute("Role") == "Killer"
or (p.Team and p.Team.Name == "Killer")
)
or false
end
function IsDowned(char)
if not char then return false end
local hum = char:FindFirstChildOfClass("Humanoid")
if char:GetAttribute("IsHooked") == true
or char:GetAttribute("IsCarried") == true then
return true
end
if AntiKnockdown.Enabled
and char == LocalPlayer.Character
and hum ~= nil
and hum.Health > 0 then
return false
end
return hum ~= nil and hum.Health > 0 and hum.Health <= 50
end
function GetDistance(pos)
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not root then return math.huge end
return (pos - root.Position).Magnitude
end
function _BH_FN.KA_Reset()
Killer.KillTarget = nil
Killer.KillLastAttack = 0
Killer.KillLastTeleport = 0
end
function _BH_FN.KA_IsTargetDown(char, humanoid)
if not char
or not humanoid
or humanoid.Health <= 0 then
return true
end
return humanoid.Health <= 50
or char:GetAttribute("Knocked") == true
or char:GetAttribute("Downed") == true
or char:GetAttribute("IsDown") == true
or char:GetAttribute("IsKnocked") == true
or char:GetAttribute("IsHooked") == true
or char:GetAttribute("IsCarried") == true
end
function _BH_FN.KA_IsValidTarget(player, origin)
if not player
or player == LocalPlayer
or _BH_FN.AIM_GetRole(player)
~= "Survivor" then
return false
end
local char = player.Character
local humanoid =
char
and char:FindFirstChildOfClass("Humanoid")
local root =
char
and char:FindFirstChild("HumanoidRootPart")
if not root
or _BH_FN.KA_IsTargetDown(
char,
humanoid
) then
return false
end
return not origin
or (root.Position - origin).Magnitude
<= Killer.KillRange
end
function _BH_FN.KA_SelectTarget(origin)
local best = nil
local bestDistance = math.huge
for _, player in ipairs(
Players:GetPlayers()
) do
if _BH_FN.KA_IsValidTarget(
player,
origin
) then
local root =
player.Character.HumanoidRootPart
local distance =
(root.Position - origin).Magnitude
if distance < bestDistance then
bestDistance = distance
best = player
end
end
end
return best
end
function _BH_FN.KA_Update(now)
if not Killer.KillAll
or GetRole() ~= "Killer" then
_BH_FN.KA_Reset()
return
end
local char = LocalPlayer.Character
local root =
char
and char:FindFirstChild("HumanoidRootPart")
local humanoid =
char
and char:FindFirstChildOfClass("Humanoid")
if not root
or not humanoid
or humanoid.Health <= 0 then
return
end
local target = Killer.KillTarget
if not _BH_FN.KA_IsValidTarget(target) then
target = _BH_FN.KA_SelectTarget(
root.Position
)
Killer.KillTarget = target
end
if not target or not target.Character then
return
end
local targetRoot =
target.Character:FindFirstChild(
"HumanoidRootPart"
)
local targetHumanoid =
target.Character:FindFirstChildOfClass(
"Humanoid"
)
if not targetRoot
or _BH_FN.KA_IsTargetDown(
target.Character,
targetHumanoid
) then
Killer.KillTarget = nil
return
end
if now - Killer.KillLastTeleport
>= Killer.KillTeleportInterval then
Killer.KillLastTeleport = now
local behind =
targetRoot.Position
- targetRoot.CFrame.LookVector
* Killer.KillBehindDistance
pcall(function()
root.AssemblyLinearVelocity =
Vector3.zero
root.AssemblyAngularVelocity =
Vector3.zero
root.CFrame = CFrame.lookAt(
behind,
targetRoot.Position
)
end)
end
if AttackEvent
and now - Killer.KillLastAttack
>= Killer.KillAttackInterval then
Killer.KillLastAttack = now
pcall(function()
AttackEvent:FireServer()
end)
end
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
local HookColor      = Color3.fromRGB(255, 95, 95)
local SCPColor       = Color3.fromRGB(255, 0, 0)
local EmoteRemote = Remotes:FindFirstChild("EmoteHandler") or Remotes:WaitForChild("EmoteHandler", 5)
local MAIN_ICON_ASSET = "rbxassetid://106553395370008"
local HeaderStyle = {
Title = "Bluehaven Hub - VD",
Subtitle = "",
TopbarHeight = 40,
MobileScale = 0.88,
VIP = {
Text = "VIP",
CrownAsset = "rbxassetid://11322089611",
Width = 62, Height = 22,
Gap = 12, Y = 0, Radius = 7,
TextSize = 11, CrownSize = 12,
MedallionSize = 24, MedallionOffset = -4,
Background = Color3.fromRGB(112, 72, 13),
Background2 = Color3.fromRGB(53, 32, 5),
Stroke = Color3.fromRGB(255, 210, 91),
CrownColor = Color3.fromRGB(255, 226, 128),
TextColor = Color3.fromRGB(255, 235, 169),
},
Status = {
Width = 150, Height = 34,
Right = 112, Y = 0,
TextSize = 11, FPSSize = 10,
Background = Color3.fromRGB(5, 27, 56),
Background2 = Color3.fromRGB(3, 17, 37),
Stroke = Color3.fromRGB(45, 151, 220),
TextColor = Color3.fromRGB(235, 248, 255),
MutedTextColor = Color3.fromRGB(145, 185, 216),
SeparatorColor = Color3.fromRGB(32, 87, 139),
SpectatorColor = Color3.fromRGB(235, 169, 58),
SurvivorColor = Color3.fromRGB(72, 210, 124),
KillerColor = Color3.fromRGB(235, 76, 84),
},
}
local function headerMetric(value, minimum)
local number = tonumber(value) or 0
if UI_TOUCH_DEVICE then
number = number * (tonumber(HeaderStyle.MobileScale) or 0.88)
end
number = math.round(number)
if minimum ~= nil then
number = math.max(minimum, number)
end
return number
end
local Window = Library:CreateWindow({
Title = HeaderStyle.Title,
Author = HeaderStyle.Subtitle ~= ""
and HeaderStyle.Subtitle
or nil,
Icon = MAIN_ICON_ASSET,
IconSize = 38,
NotifySide = "Right",
User = {
Enabled = false,
Anonymous = false,
},
EnableSidebarResize = true,
EnableCompacting = true,
SidebarCompacted = true,
Size = UDim2.fromOffset(700, 420),
SideBarWidth = 155,
CornerRadius = 9,
TopbarHeight = headerMetric(HeaderStyle.TopbarHeight, 40),
AutoShow = true,
})
function _BH_FN.UI_ResolveWindowNodes()
local raw = Window.Raw
local elements = raw and raw.UIElements
local root = elements and elements.Main
if not root then
return nil
end
local function descendantNamed(parent, wanted)
wanted = string.lower(wanted)
for _, item in ipairs(parent:GetDescendants()) do
if string.lower(item.Name) == wanted then
return item
end
end
return nil
end
local main = root:FindFirstChild("Main")
or descendantNamed(root, "Main")
or root
local topbar = main:FindFirstChild("Topbar")
or descendantNamed(main, "Topbar")
local titleLabel = nil
for _, item in ipairs((topbar or main):GetDescendants()) do
if item:IsA("TextLabel") or item:IsA("TextButton") then
local text = tostring(item.Text or "")
if string.find(
string.lower(text),
"bluehaven hub",
1,
true
) == 1 then
titleLabel = item
break
end
end
end
if not topbar and titleLabel then
local cursor = titleLabel.Parent
while cursor and cursor ~= main do
if string.find(
string.lower(cursor.Name),
"top",
1,
true
) then
topbar = cursor
break
end
cursor = cursor.Parent
end
end
if not topbar then
for _, item in ipairs(main:GetChildren()) do
if item:IsA("GuiObject") then
local height = item.AbsoluteSize.Y
if height >= 26 and height <= 84 then
topbar = item
break
end
end
end
end
return root, main, topbar, titleLabel
end
function _BH_FN.UI_CreateVIPBadge()
local root, main, topbar, titleLabel =
_BH_FN.UI_ResolveWindowNodes()
if not topbar or not titleLabel then
return false
end
local function applyOceanGradient(
frame,
name,
firstColor,
middleColor,
secondColor,
rotation
)
if not frame or not frame:IsA("GuiObject") then
return
end
frame.BackgroundColor3 = Color3.new(1, 1, 1)
local existing = frame:FindFirstChild(name)
if existing and not existing:IsA("UIGradient") then
existing:Destroy()
existing = nil
end
local surfaceGradient = existing or Instance.new("UIGradient")
surfaceGradient.Name = name
surfaceGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, firstColor),
ColorSequenceKeypoint.new(0.26, Color3.fromRGB(3, 18, 39)),
ColorSequenceKeypoint.new(0.50, middleColor),
ColorSequenceKeypoint.new(0.74, Color3.fromRGB(4, 24, 48)),
ColorSequenceKeypoint.new(1, secondColor),
})
surfaceGradient.Rotation = rotation
surfaceGradient.Parent = frame
end
applyOceanGradient(
main,
"BluehavenOceanSurface",
Color3.fromRGB(1, 5, 13),
Color3.fromRGB(12, 71, 118),
Color3.fromRGB(1, 7, 17),
118
)
applyOceanGradient(
topbar,
"BluehavenOceanTopbar",
Color3.fromRGB(1, 5, 12),
Color3.fromRGB(14, 74, 121),
Color3.fromRGB(2, 8, 19),
0
)
titleLabel.Text = HeaderStyle.Title
for _, object in ipairs(topbar:GetDescendants()) do
if object:IsA("ImageLabel")
and string.find(
string.lower(object.Name),
"icon",
1,
true
) then
object.Image = MAIN_ICON_ASSET
object.ImageColor3 = Color3.new(1, 1, 1)
object.ScaleType = Enum.ScaleType.Fit
object.Size = UDim2.fromOffset(
headerMetric(38, 34),
headerMetric(38, 34)
)
break
end
end
local oldBadge = topbar:FindFirstChild("BluehavenVIPBadge")
local oldStatus = topbar:FindFirstChild("BluehavenTopbarStatus")
if oldBadge and oldStatus then
local oldRole = oldStatus:FindFirstChild("Role")
local oldFPS = oldStatus:FindFirstChild("FPS")
local oldNextKiller = oldStatus:FindFirstChild("NextKiller")
local oldNextKillerDot = oldStatus:FindFirstChild("NextKillerDot")
if oldRole and oldFPS and oldNextKiller and oldNextKillerDot then
_BH_FN.UI_TopbarRoleLabel = oldRole
_BH_FN.UI_TopbarFPSLabel = oldFPS
_BH_FN.UI_TopbarNextKillerLabel = oldNextKiller
_BH_FN.UI_TopbarNextKillerDot = oldNextKillerDot
_BH_FN.UI_TopbarStatusDot = oldStatus:FindFirstChild("Online")
_BH_FN.UI_TopbarStatusDotStroke =
_BH_FN.UI_TopbarStatusDot
and _BH_FN.UI_TopbarStatusDot:FindFirstChildOfClass("UIStroke")
_BH_FN.UI_TopbarStatusDotGlow =
oldStatus:FindFirstChild("OnlineGlow")
local oldOutline = oldStatus:FindFirstChildOfClass("UIStroke")
if oldOutline then oldOutline:Destroy() end
_BH_FN.UI_TopbarStatusStroke = nil
return true
end
end
if oldBadge then oldBadge:Destroy() end
if oldStatus then oldStatus:Destroy() end
topbar.ClipsDescendants = false
local badge = Instance.new("Frame")
badge.Name = "BluehavenVIPBadge"
badge.AnchorPoint = Vector2.new(0, 0.5)
local badgeWidth = headerMetric(HeaderStyle.VIP.Width, 38)
local badgeHeight = headerMetric(HeaderStyle.VIP.Height, 16)
badge.Size = UDim2.fromOffset(badgeWidth, badgeHeight)
badge.BackgroundColor3 = Color3.new(1, 1, 1)
badge.BackgroundTransparency = 0
badge.BorderSizePixel = 0
badge.ClipsDescendants = false
badge.ZIndex = 1001
badge.Parent = topbar
_BH_FN.TrackArtifact(badge)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(
0,
headerMetric(HeaderStyle.VIP.Radius, 3)
)
corner.Parent = badge
local gradient = Instance.new("UIGradient")
gradient.Name = "DarkGoldGradient"
gradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, HeaderStyle.VIP.Background),
ColorSequenceKeypoint.new(0.52, Color3.fromRGB(142, 94, 20)),
ColorSequenceKeypoint.new(1, HeaderStyle.VIP.Background2),
})
gradient.Rotation = 0
gradient.Parent = badge
local stroke = Instance.new("UIStroke")
stroke.Color = HeaderStyle.VIP.Stroke
stroke.Transparency = 0.16
stroke.Thickness = 1
stroke.Parent = badge
local shine = Instance.new("Frame")
shine.Name = "PremiumShine"
shine.Position = UDim2.fromScale(0, 0)
shine.Size = UDim2.fromScale(1, 1)
shine.BackgroundColor3 = Color3.fromRGB(255, 239, 178)
shine.BackgroundTransparency = 0
shine.BorderSizePixel = 0
shine.ZIndex = badge.ZIndex + 1
shine.Parent = badge
local shineCorner = Instance.new("UICorner")
shineCorner.CornerRadius = corner.CornerRadius
shineCorner.Parent = shine
local shineGradient = Instance.new("UIGradient")
shineGradient.Name = "PremiumShineGradient"
shineGradient.Color = ColorSequence.new(
Color3.fromRGB(255, 247, 213),
Color3.fromRGB(255, 216, 105)
)
shineGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(0.38, 1),
NumberSequenceKeypoint.new(0.48, 0.76),
NumberSequenceKeypoint.new(0.52, 0.46),
NumberSequenceKeypoint.new(0.56, 0.76),
NumberSequenceKeypoint.new(0.66, 1),
NumberSequenceKeypoint.new(1, 1),
})
shineGradient.Rotation = 18
shineGradient.Offset = Vector2.new(-1.25, 0)
shineGradient.Parent = shine
if _BH_FN.UI_VIPShineTween then
pcall(function()
_BH_FN.UI_VIPShineTween:Cancel()
end)
end
local shineTween = TweenService:Create(
shineGradient,
TweenInfo.new(
2.2,
Enum.EasingStyle.Sine,
Enum.EasingDirection.InOut,
-1,
false,
1.5
),
{Offset = Vector2.new(1.25, 0)}
)
_BH_FN.UI_VIPShineTween = shineTween
shineTween:Play()
Library:OnUnload(function()
if _BH_FN.UI_VIPShineTween == shineTween then
pcall(function() shineTween:Cancel() end)
_BH_FN.UI_VIPShineTween = nil
end
end)
local medallionSize = headerMetric(
HeaderStyle.VIP.MedallionSize,
18
)
local medallion = Instance.new("Frame")
medallion.Name = "CrownMedallion"
medallion.AnchorPoint = Vector2.new(0, 0.5)
medallion.Position = UDim2.new(
0,
headerMetric(HeaderStyle.VIP.MedallionOffset),
0.5,
0
)
medallion.Size = UDim2.fromOffset(
medallionSize,
medallionSize
)
medallion.BackgroundColor3 = Color3.new(1, 1, 1)
medallion.BorderSizePixel = 0
medallion.ZIndex = badge.ZIndex + 2
medallion.Parent = badge
local medallionCorner = Instance.new("UICorner")
medallionCorner.CornerRadius = UDim.new(1, 0)
medallionCorner.Parent = medallion
local medallionStroke = Instance.new("UIStroke")
medallionStroke.Color = HeaderStyle.VIP.Stroke
medallionStroke.Transparency = 0.04
medallionStroke.Thickness = 1
medallionStroke.Parent = medallion
local medallionGradient = Instance.new("UIGradient")
medallionGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(154, 103, 22)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(69, 41, 6)),
})
medallionGradient.Rotation = 45
medallionGradient.Parent = medallion
local crown = Instance.new("ImageLabel")
crown.Name = "Crown"
crown.BackgroundTransparency = 1
local crownSize = headerMetric(HeaderStyle.VIP.CrownSize, 10)
crown.AnchorPoint = Vector2.new(0.5, 0.5)
crown.Position = UDim2.fromScale(0.5, 0.5)
crown.Size = UDim2.fromOffset(crownSize, crownSize)
crown.Image = HeaderStyle.VIP.CrownAsset
crown.ImageColor3 = HeaderStyle.VIP.CrownColor
crown.ScaleType = Enum.ScaleType.Fit
crown.ZIndex = medallion.ZIndex + 1
crown.Parent = medallion
local vip = Instance.new("TextLabel")
vip.Name = "VIP"
vip.BackgroundTransparency = 1
local vipTextX = headerMetric(25, 20)
vip.Position = UDim2.fromOffset(vipTextX, 0)
vip.Size = UDim2.new(1, -vipTextX - 1, 1, 0)
vip.Font = Enum.Font.GothamBold
vip.Text = HeaderStyle.VIP.Text
vip.TextColor3 = Color3.new(1, 1, 1)
vip.TextSize = headerMetric(HeaderStyle.VIP.TextSize, 8)
vip.TextXAlignment = Enum.TextXAlignment.Left
vip.ZIndex = badge.ZIndex + 3
vip.Parent = badge
local vipGradient = Instance.new("UIGradient")
vipGradient.Name = "VIPTextGold"
vipGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 229, 145)),
ColorSequenceKeypoint.new(0.55, HeaderStyle.VIP.TextColor),
ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 151, 37)),
})
vipGradient.Rotation = 0
vipGradient.Parent = vip
local statusPill = Instance.new("Frame")
statusPill.Name = "BluehavenTopbarStatus"
statusPill.AnchorPoint = Vector2.new(1, 0.5)
statusPill.Position = UDim2.new(
1,
-headerMetric(HeaderStyle.Status.Right, 86),
0.5,
headerMetric(HeaderStyle.Status.Y)
)
statusPill.Size = UDim2.fromOffset(
headerMetric(HeaderStyle.Status.Width, 76),
headerMetric(HeaderStyle.Status.Height, 18)
)
statusPill.BackgroundColor3 = Color3.fromRGB(0, 7, 19)
statusPill.BackgroundTransparency = 1
statusPill.BorderSizePixel = 0
statusPill.ZIndex = 1000
statusPill.Parent = topbar
_BH_FN.TrackArtifact(statusPill)
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, headerMetric(7, 5))
statusCorner.Parent = statusPill
_BH_FN.UI_TopbarStatusStroke = nil
local onlineGlow = Instance.new("Frame")
onlineGlow.Name = "OnlineGlow"
onlineGlow.AnchorPoint = Vector2.new(0.5, 0.5)
onlineGlow.Position = UDim2.new(0, headerMetric(12, 9), 0.27, 0)
onlineGlow.Size = UDim2.fromOffset(
headerMetric(13, 9),
headerMetric(13, 9)
)
onlineGlow.BackgroundColor3 = HeaderStyle.Status.SpectatorColor
onlineGlow.BackgroundTransparency = 0.82
onlineGlow.BorderSizePixel = 0
onlineGlow.ZIndex = statusPill.ZIndex + 1
onlineGlow.Parent = statusPill
local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = onlineGlow
_BH_FN.UI_TopbarStatusDotGlow = onlineGlow
local onlineDot = Instance.new("Frame")
onlineDot.Name = "Online"
onlineDot.AnchorPoint = Vector2.new(0, 0.5)
onlineDot.Position = UDim2.new(0, headerMetric(9, 6), 0.27, 0)
onlineDot.Size = UDim2.fromOffset(
headerMetric(6, 4),
headerMetric(6, 4)
)
onlineDot.BackgroundColor3 = HeaderStyle.Status.SpectatorColor
onlineDot.BorderSizePixel = 0
onlineDot.ZIndex = statusPill.ZIndex + 2
onlineDot.Parent = statusPill
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = onlineDot
_BH_FN.UI_TopbarStatusDot = onlineDot
local dotStroke = Instance.new("UIStroke")
dotStroke.Color = HeaderStyle.Status.SpectatorColor
dotStroke.Transparency = 0.44
dotStroke.Thickness = 1
dotStroke.Parent = onlineDot
_BH_FN.UI_TopbarStatusDotStroke = dotStroke
local roleLabel = Instance.new("TextLabel")
roleLabel.Name = "Role"
roleLabel.BackgroundTransparency = 1
roleLabel.Position = UDim2.fromOffset(headerMetric(21, 15), 0)
roleLabel.Size = UDim2.new(0.52, -headerMetric(21, 15), 0.54, 0)
roleLabel.Font = Enum.Font.GothamSemibold
roleLabel.Text = UI_TOUCH_DEVICE and "SPEC" or "Spectator"
roleLabel.TextColor3 = HeaderStyle.Status.TextColor
roleLabel.TextSize = headerMetric(HeaderStyle.Status.TextSize, 8)
roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
roleLabel.TextXAlignment = Enum.TextXAlignment.Left
roleLabel.ZIndex = statusPill.ZIndex + 2
roleLabel.Parent = statusPill
_BH_FN.UI_TopbarRoleLabel = roleLabel
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.AnchorPoint = Vector2.new(0.5, 0.5)
separator.Position = UDim2.new(0.58, 0, 0.27, 0)
separator.Size = UDim2.fromOffset(1, headerMetric(10, 7))
separator.BackgroundColor3 = HeaderStyle.Status.SeparatorColor
separator.BorderSizePixel = 0
separator.ZIndex = statusPill.ZIndex + 2
separator.Parent = statusPill
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPS"
fpsLabel.BackgroundTransparency = 1
fpsLabel.Position = UDim2.new(0.61, 0, 0, 0)
fpsLabel.Size = UDim2.new(0.39, -headerMetric(8, 5), 0.54, 0)
fpsLabel.Font = Enum.Font.GothamMedium
fpsLabel.Text = "-- FPS"
fpsLabel.TextColor3 = HeaderStyle.Status.MutedTextColor
fpsLabel.TextSize = headerMetric(HeaderStyle.Status.FPSSize, 8)
fpsLabel.TextTruncate = Enum.TextTruncate.AtEnd
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.ZIndex = statusPill.ZIndex + 2
fpsLabel.Parent = statusPill
_BH_FN.UI_TopbarFPSLabel = fpsLabel
local nextKillerDot = Instance.new("Frame")
nextKillerDot.Name = "NextKillerDot"
nextKillerDot.AnchorPoint = Vector2.new(0, 0.5)
nextKillerDot.Position = UDim2.new(0, headerMetric(9, 6), 0.76, 0)
nextKillerDot.Size = UDim2.fromOffset(
headerMetric(7, 5),
headerMetric(7, 5)
)
nextKillerDot.BackgroundColor3 = HeaderStyle.Status.KillerColor
nextKillerDot.BorderSizePixel = 0
nextKillerDot.ZIndex = statusPill.ZIndex + 2
nextKillerDot.Parent = statusPill
local nextKillerDotCorner = Instance.new("UICorner")
nextKillerDotCorner.CornerRadius = UDim.new(1, 0)
nextKillerDotCorner.Parent = nextKillerDot
_BH_FN.UI_TopbarNextKillerDot = nextKillerDot
local nextKillerLabel = Instance.new("TextLabel")
nextKillerLabel.Name = "NextKiller"
nextKillerLabel.BackgroundTransparency = 1
nextKillerLabel.Position = UDim2.new(
0,
headerMetric(21, 15),
0.5,
0
)
nextKillerLabel.Size = UDim2.new(
1,
-headerMetric(28, 20),
0.5,
0
)
nextKillerLabel.Font = Enum.Font.GothamMedium
nextKillerLabel.Text = "Next • scanning..."
nextKillerLabel.TextColor3 = HeaderStyle.Status.MutedTextColor
nextKillerLabel.TextSize = headerMetric(11, 9)
nextKillerLabel.TextTruncate = Enum.TextTruncate.AtEnd
nextKillerLabel.TextXAlignment = Enum.TextXAlignment.Left
nextKillerLabel.ZIndex = statusPill.ZIndex + 2
nextKillerLabel.Parent = statusPill
_BH_FN.UI_TopbarNextKillerLabel = nextKillerLabel
local function positionBadge()
if badge.Parent and titleLabel.Parent then
local uiScale = root:FindFirstChildOfClass("UIScale")
local scaleValue = uiScale and uiScale.Scale or 1
scaleValue = math.max(scaleValue, 0.01)
local titleX = (
titleLabel.AbsolutePosition.X
- topbar.AbsolutePosition.X
) / scaleValue
local titleWidth = titleLabel.AbsoluteSize.X / scaleValue
badge.Position = UDim2.new(
0,
titleX
+ titleWidth
+ headerMetric(HeaderStyle.VIP.Gap, 4),
0.5,
headerMetric(HeaderStyle.VIP.Y)
)
end
end
positionBadge()
_BH_FN.TrackConnection(
titleLabel:GetPropertyChangedSignal("TextBounds"):Connect(positionBadge)
)
_BH_FN.TrackConnection(
titleLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionBadge)
)
_BH_FN.TrackConnection(
titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionBadge)
)
task.defer(positionBadge)
return true
end
function _BH_FN.UI_ApplyVisibleGradients()
local root, main, topbar = _BH_FN.UI_ResolveWindowNodes()
if not main then
return 0
end
local styled = 0
local oceanStops = {
{0.00, Color3.fromRGB(13, 83, 143)},
{0.16, Color3.fromRGB(10, 73, 125)},
{0.32, Color3.fromRGB(7, 60, 105)},
{0.50, Color3.fromRGB(5, 45, 81)},
{0.68, Color3.fromRGB(3, 33, 62)},
{0.84, Color3.fromRGB(1, 20, 41)},
{1.00, Color3.fromRGB(0, 7, 19)},
}
local function sampleOcean(position)
local t = math.clamp(position, 0, 1)
for index = 1, #oceanStops - 1 do
local first = oceanStops[index]
local second = oceanStops[index + 1]
if t <= second[1] then
local span = math.max(second[1] - first[1], 0.0001)
return first[2]:Lerp(
second[2],
(t - first[1]) / span
)
end
end
return oceanStops[#oceanStops][2]
end
local function alignedSequence(object)
local mainWidth = main.AbsoluteSize.X
local objectWidth = object.AbsoluteSize.X
local startPosition = 0
local endPosition = 1
if mainWidth > 1 and objectWidth > 1 then
startPosition = math.clamp(
(object.AbsolutePosition.X - main.AbsolutePosition.X)
/ mainWidth,
0,
1
)
endPosition = math.clamp(
(object.AbsolutePosition.X + objectWidth
- main.AbsolutePosition.X) / mainWidth,
startPosition,
1
)
end
local keypoints = {}
for _, localPosition in ipairs({0, 0.16, 0.32, 0.50, 0.68, 0.84, 1}) do
local globalPosition = startPosition
+ (endPosition - startPosition) * localPosition
keypoints[#keypoints + 1] = ColorSequenceKeypoint.new(
localPosition,
sampleOcean(globalPosition)
)
end
return ColorSequence.new(keypoints)
end
local function applyAlignedGradient(object, name, clearImage)
if not object or not object:IsA("GuiObject") then
return
end
for _, legacyName in ipairs({
"BluehavenOceanTopbar",
"BluehavenOceanRoot",
"BluehavenContentSurface",
"BluehavenVisibleGradient",
"BluehavenAlignedTopbar",
"BluehavenAlignedHeaderCover",
"BluehavenAlignedContent",
"BluehavenAlignedPage",
"BluehavenAlignedRightSurface",
"BluehavenAlignedSidebar",
"OceanStatusGradient",
}) do
if legacyName ~= name then
local legacy = object:FindFirstChild(legacyName)
if legacy then legacy:Destroy() end
end
end
object.BackgroundColor3 = Color3.new(1, 1, 1)
object.BackgroundTransparency = 0
if clearImage
and (object:IsA("ImageLabel")
or object:IsA("ImageButton")) then
object.ImageTransparency = 1
end
local existing = object:FindFirstChild(name)
if existing and not existing:IsA("UIGradient") then
existing:Destroy()
existing = nil
end
local gradient = existing or Instance.new("UIGradient")
gradient.Name = name
gradient.Color = alignedSequence(object)
gradient.Rotation = 0
gradient.Parent = object
styled = styled + 1
end
local function revealParentGradient(object)
if not object or not object:IsA("GuiObject") then
return
end
for _, gradientName in ipairs({
"BluehavenOceanTopbar",
"BluehavenOceanRoot",
"BluehavenContentSurface",
"BluehavenVisibleGradient",
"BluehavenAlignedTopbar",
"BluehavenAlignedHeaderCover",
"BluehavenAlignedContent",
"BluehavenAlignedPage",
"BluehavenAlignedRightSurface",
"BluehavenAlignedSidebar",
"OceanStatusGradient",
}) do
local gradient = object:FindFirstChild(gradientName)
if gradient then gradient:Destroy() end
end
object.BackgroundTransparency = 1
if object:IsA("ImageLabel") or object:IsA("ImageButton") then
object.ImageTransparency = 1
end
end
applyAlignedGradient(main, "BluehavenOceanSurface", false)
if root ~= main then
local rootGradient = root:FindFirstChild("BluehavenOceanRoot")
if rootGradient then rootGradient:Destroy() end
end
revealParentGradient(topbar)
if topbar then
local barSize = topbar.AbsoluteSize
local barPosition = topbar.AbsolutePosition
if barSize.X > 0 and barSize.Y > 0 then
for _, object in ipairs(topbar:GetDescendants()) do
local protectedHeader =
object.Name == "BluehavenVIPBadge"
or object.Name == "BluehavenTopbarStatus"
or object:FindFirstAncestor("BluehavenVIPBadge")
or object:FindFirstAncestor("BluehavenTopbarStatus")
if not protectedHeader
and object:IsA("GuiObject")
and not object:IsA("TextLabel")
and not object:IsA("TextButton")
and object.AbsoluteSize.X >= barSize.X * 0.88
and object.AbsoluteSize.Y >= barSize.Y * 0.72 then
revealParentGradient(object)
end
end
for _, object in ipairs(topbar:GetDescendants()) do
local isBackingSurface = object:IsA("Frame")
or object:IsA("CanvasGroup")
or object:IsA("ScrollingFrame")
or object:IsA("ImageLabel")
local relativeX = object.AbsolutePosition.X
- barPosition.X
local protectedHeader =
object.Name == "BluehavenVIPBadge"
or object.Name == "BluehavenTopbarStatus"
or object:FindFirstAncestor("BluehavenVIPBadge")
or object:FindFirstAncestor("BluehavenTopbarStatus")
local isRightButtonBacking = relativeX >= barSize.X * 0.68
and object.AbsoluteSize.X >= 48
and object.AbsoluteSize.Y >= barSize.Y * 0.52
if isBackingSurface
and isRightButtonBacking
and not protectedHeader then
revealParentGradient(object)
end
end
end
end
local statusPill = topbar
and topbar:FindFirstChild("BluehavenTopbarStatus", true)
if statusPill and statusPill:IsA("GuiObject") then
revealParentGradient(statusPill)
end
local contentSurface = nil
local contentArea = 0
local mainSize = main.AbsoluteSize
local mainPosition = main.AbsolutePosition
local sidebarSurface = nil
local sidebarArea = 0
if mainSize.X > 0 and mainSize.Y > 0 then
for _, object in ipairs(main:GetDescendants()) do
if object:IsA("GuiObject")
and object ~= topbar
and not (topbar and object:IsDescendantOf(topbar)) then
local absolute = object.AbsoluteSize
local relativeX = object.AbsolutePosition.X
- mainPosition.X
local area = absolute.X * absolute.Y
local isSidebar = relativeX <= mainSize.X * 0.08
and absolute.X >= mainSize.X * 0.14
and absolute.X <= mainSize.X * 0.42
and absolute.Y >= mainSize.Y * 0.55
if isSidebar and area > sidebarArea then
sidebarSurface = object
sidebarArea = area
end
end
end
end
if sidebarSurface then
revealParentGradient(sidebarSurface)
end
if mainSize.X > 0 and mainSize.Y > 0 then
for _, object in ipairs(main:GetDescendants()) do
if object:IsA("GuiObject")
and object ~= topbar
and not (topbar and object:IsDescendantOf(topbar)) then
local absolute = object.AbsoluteSize
local relativeX = object.AbsolutePosition.X
- mainPosition.X
local area = absolute.X * absolute.Y
local isRightCanvas = relativeX >= mainSize.X * 0.16
and absolute.X >= mainSize.X * 0.52
and absolute.Y >= mainSize.Y * 0.55
if isRightCanvas and area > contentArea then
contentSurface = object
contentArea = area
end
end
end
end
if contentSurface then
revealParentGradient(contentSurface)
end
local function syncRightSurface(object)
if not object:IsA("GuiObject")
or object == main
or object == topbar
or object == contentSurface
or (topbar and object:IsDescendantOf(topbar))
or object:IsA("TextLabel")
or object:IsA("TextButton")
or object:IsA("TextBox") then
return
end
local mainSurfaceSize = main.AbsoluteSize
local absolute = object.AbsoluteSize
if mainSurfaceSize.X <= 0 or mainSurfaceSize.Y <= 0 then
return
end
local relativeX = object.AbsolutePosition.X
- main.AbsolutePosition.X
local isRightBackground = relativeX >= mainSurfaceSize.X * 0.16
and absolute.X >= mainSurfaceSize.X * 0.46
and absolute.Y >= mainSurfaceSize.Y * 0.40
if not isRightBackground then
return
end
revealParentGradient(object)
styled = styled + 1
end
for _, object in ipairs(main:GetDescendants()) do
syncRightSurface(object)
end
if not _BH_FN.UI_GradientDescendantConnection then
_BH_FN.UI_GradientDescendantConnection =
main.DescendantAdded:Connect(function(object)
if object:IsA("GuiObject") then
task.delay(0.05, function()
if HubRuntime.Alive and object.Parent then
pcall(syncRightSurface, object)
end
end)
end
end)
_BH_FN.TrackConnection(_BH_FN.UI_GradientDescendantConnection)
end
if contentSurface and not _BH_FN.UI_GradientLayoutBound then
_BH_FN.UI_GradientLayoutBound = true
local pending = false
local function scheduleGradientSync()
if pending then return end
pending = true
task.defer(function()
pending = false
if HubRuntime.Alive then
pcall(_BH_FN.UI_ApplyVisibleGradients)
end
end)
end
for _, item in ipairs({
main,
topbar,
sidebarSurface,
contentSurface,
}) do
if item and item:IsA("GuiObject") then
_BH_FN.TrackConnection(
item:GetPropertyChangedSignal("AbsoluteSize"):Connect(
scheduleGradientSync
)
)
if item == sidebarSurface or item == contentSurface then
_BH_FN.TrackConnection(
item:GetPropertyChangedSignal("AbsolutePosition"):Connect(
scheduleGradientSync
)
)
end
end
end
end
return styled
end
task.spawn(function()
for _ = 1, 30 do
if not HubRuntime.Alive then
return
end
local ok, created = pcall(_BH_FN.UI_CreateVIPBadge)
if ok and created then
return
end
task.wait(0.1)
end
end)
function _BH_FN.UI_UpdateProfileStatus(role, fps)
local roleText = tostring(role or "Spectator")
local fpsText = tostring(fps or "--")
local roleLabel = _BH_FN.UI_TopbarRoleLabel
local fpsLabel = _BH_FN.UI_TopbarFPSLabel
if not roleLabel or not roleLabel.Parent
or not fpsLabel or not fpsLabel.Parent then
_BH_FN.UI_CreateVIPBadge()
roleLabel = _BH_FN.UI_TopbarRoleLabel
fpsLabel = _BH_FN.UI_TopbarFPSLabel
end
if not roleLabel or not roleLabel.Parent
or not fpsLabel or not fpsLabel.Parent then
return false
end
if UI_TOUCH_DEVICE then
local compactRole = roleText == "Spectator" and "SPEC"
or roleText == "Survivor" and "SURV"
or roleText == "Killer" and "KILL"
or string.upper(string.sub(roleText, 1, 4))
roleLabel.Text = compactRole
else
roleLabel.Text = roleText
end
fpsLabel.Text = string.format("%s FPS", fpsText)
local roleColor = roleText == "Killer"
and HeaderStyle.Status.KillerColor
or roleText == "Survivor"
and HeaderStyle.Status.SurvivorColor
or HeaderStyle.Status.SpectatorColor
local statusDot = _BH_FN.UI_TopbarStatusDot
if statusDot and statusDot.Parent then
statusDot.BackgroundColor3 = roleColor
local dotStroke = _BH_FN.UI_TopbarStatusDotStroke
if dotStroke and dotStroke.Parent then
dotStroke.Color = roleColor
end
local dotGlow = _BH_FN.UI_TopbarStatusDotGlow
if dotGlow and dotGlow.Parent then
dotGlow.BackgroundColor3 = roleColor
end
end
return true
end
local MouseCaptureState = {
GuiOpen = true,
Applying = false,
RefreshQueued = false,
LastMode = nil,
LastGuiOpen = nil,
NativeVisibilityHooks = false,
CharacterConnections = {},
}
function _BH_FN.UI_GetMouseRole()
local team = LocalPlayer.Team
local teamName = team and string.lower(team.Name) or ""
if string.find(teamName, "spect", 1, true)
or string.find(teamName, "observer", 1, true)
or string.find(teamName, "lobby", 1, true)
or string.find(teamName, "waiting", 1, true) then
return "Spectator"
end
if string.find(teamName, "survivor", 1, true) then
return "Survivor"
end
if string.find(teamName, "killer", 1, true) then
return "Killer"
end
local ok, role = pcall(GetRole)
if ok and (role == "Survivor" or role == "Killer") then
return role
end
return "Spectator"
end
function _BH_FN.UI_ApplyMouseCapture(forceTransition)
if MouseCaptureState.Applying then return end
local role = _BH_FN.UI_GetMouseRole()
local activeRole = role == "Survivor" or role == "Killer"
local mode = MouseCaptureState.GuiOpen
and "Open"
or (activeRole and "Gameplay" or "Spectator")
if not MouseCaptureState.GuiOpen
and forceTransition ~= true
and MouseCaptureState.LastMode == mode then
return
end
MouseCaptureState.LastMode = mode
local shouldLock = mode == "Gameplay"
local desiredBehavior = shouldLock
and Enum.MouseBehavior.LockCenter
or Enum.MouseBehavior.Default
MouseCaptureState.Applying = true
pcall(function()
if UserInputService.MouseBehavior ~= desiredBehavior then
UserInputService.MouseBehavior = desiredBehavior
end
UserInputService.MouseIconEnabled = not shouldLock
end)
MouseCaptureState.Applying = false
end
function _BH_FN.UI_SetGuiOpen(isOpen)
local nextOpen = isOpen == true
local changed = MouseCaptureState.GuiOpen ~= nextOpen
MouseCaptureState.GuiOpen = nextOpen
MouseCaptureState.LastGuiOpen = nextOpen
if not nextOpen then
pcall(function()
local focused = UserInputService:GetFocusedTextBox()
if focused then
focused:ReleaseFocus(false)
end
end)
pcall(function()
GuiService.SelectedObject = nil
end)
end
_BH_FN.UI_ApplyMouseCapture(changed)
if not nextOpen
and type(_BH_FN.GB_RecoverStaleLegacyInteraction)
== "function" then
task.defer(function()
pcall(_BH_FN.GB_RecoverStaleLegacyInteraction)
end)
end
if nextOpen then
task.defer(_BH_FN.UI_ApplyMouseCapture)
task.delay(0.08, _BH_FN.UI_ApplyMouseCapture)
task.delay(0.20, _BH_FN.UI_ApplyMouseCapture)
end
end
local openHook = select(1, windSafeCall(Window.Raw, "OnOpen", function()
_BH_FN.UI_SetGuiOpen(true)
end))
local closeHook = select(1, windSafeCall(Window.Raw, "OnClose", function()
_BH_FN.UI_SetGuiOpen(false)
end))
MouseCaptureState.NativeVisibilityHooks = openHook and closeHook
local baseWindowToggle = Window.Toggle
function Window:Toggle()
local wasOpen = MouseCaptureState.GuiOpen
baseWindowToggle(self)
_BH_FN.UI_SetGuiOpen(not wasOpen)
end
task.defer(function()
local root, main = _BH_FN.UI_ResolveWindowNodes()
local screenGui = root
and (root:IsA("ScreenGui")
and root
or root:FindFirstAncestorOfClass("ScreenGui"))
local function syncVisibility()
local visible = true
if screenGui and not screenGui.Enabled then
visible = false
end
if root and root:IsA("GuiObject") and not root.Visible then
visible = false
end
if main and main:IsA("GuiObject") and not main.Visible then
visible = false
end
if visible ~= MouseCaptureState.GuiOpen then
_BH_FN.UI_SetGuiOpen(visible)
end
end
if screenGui then
_BH_FN.TrackConnection(
screenGui:GetPropertyChangedSignal("Enabled")
:Connect(syncVisibility)
)
end
for _, object in ipairs({root, main}) do
if object and object:IsA("GuiObject") then
_BH_FN.TrackConnection(
object:GetPropertyChangedSignal("Visible")
:Connect(syncVisibility)
)
end
end
syncVisibility()
end)
local function refreshMouseCapture()
if MouseCaptureState.RefreshQueued then return end
MouseCaptureState.RefreshQueued = true
task.defer(function()
MouseCaptureState.RefreshQueued = false
_BH_FN.UI_ApplyMouseCapture()
_BH_FN.UI_UpdateProfileStatus(
_BH_FN.UI_GetMouseRole(),
State and State.FPS or "--"
)
pcall(_BH_FN.updateAimFOVVisual)
end)
end
_BH_FN.TrackConnection(
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshMouseCapture)
)
for _, attributeName in ipairs({
"Role",
"role",
"CharacterRole",
"IsKiller",
"IsSurvivor",
}) do
_BH_FN.TrackConnection(
LocalPlayer:GetAttributeChangedSignal(attributeName):Connect(refreshMouseCapture)
)
end
local function bindMouseCharacterValidation(character)
for _, connection in ipairs(MouseCaptureState.CharacterConnections) do
_BH_FN.ForgetConnection(connection)
pcall(function() connection:Disconnect() end)
end
table.clear(MouseCaptureState.CharacterConnections)
if not character then
refreshMouseCapture()
return
end
for _, attributeName in ipairs({
"Role",
"role",
"CharacterRole",
"IsKiller",
"IsSurvivor",
}) do
local connection = _BH_FN.TrackConnection(
character:GetAttributeChangedSignal(attributeName):Connect(refreshMouseCapture)
)
MouseCaptureState.CharacterConnections[#MouseCaptureState.CharacterConnections + 1] = connection
end
refreshMouseCapture()
end
bindMouseCharacterValidation(LocalPlayer.Character)
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(bindMouseCharacterValidation)
)
_BH_FN.TrackConnection(
LocalPlayer.CharacterRemoving:Connect(function()
task.defer(refreshMouseCapture)
end)
)
Library:OnUnload(function()
MouseCaptureState.GuiOpen = false
_BH_FN.UI_ApplyMouseCapture()
end)
_BH_FN.UI_SetGuiOpen(true)
_BH_FN.UI_UpdateProfileStatus(
_BH_FN.UI_GetMouseRole(),
"--"
)
local Tabs = {
About      = Window:AddTab("About",    "info", "Hub information"),
Player     = Window:AddTab("Player",   "user", "Survivor & Killer"),
Aim        = Window:AddTab("Aim",      "crosshair", "Aim settings"),
ESP        = Window:AddTab("ESP",      "eye", "Player, object & stats"),
Misc       = Window:AddTab("Misc",     "sliders-horizontal", "Emote, chat & parry"),
Visual     = Window:AddTab("Visual",   "sparkles", "Graphics & avatar"),
UISettings = Window:AddTab("Settings", "settings-2", "Config & interface")
}
local UIBox = {}
UIBox.ESP             = Tabs.ESP:AddLeftGroupbox("ESP Cham", "scan-eye")
UIBox.ESPStatus       = Tabs.ESP:AddRightGroupbox("ESP Status", "scan-eye")
UIBox.PlayerTabs      = Tabs.Player:AddRightTabbox()
UIBox.AbilityTab      = UIBox.PlayerTabs:AddTab("Survivor", "user")
UIBox.TeleportTab     = UIBox.PlayerTabs:AddTab("Teleport", "map-pin")
UIBox.KillerTab       = UIBox.PlayerTabs:AddTab("Killer", "skull")
UIBox.AboutInfo       = Tabs.About:AddLeftGroupbox("Hub Info", "info")
UIBox.AboutControl    = Tabs.About:AddRightGroupbox("Controls", "mouse-pointer-2")
UIBox.TeleportMap     = UIBox.TeleportTab:AddLeftGroupbox("Map Teleport", "map-pin")
UIBox.TeleportTool    = UIBox.TeleportTab:AddRightGroupbox("Map Utility", "refresh-cw")
UIBox.KillerCore      = UIBox.KillerTab:AddLeftGroupbox("Killer Core", "skull")
UIBox.KillerUtility   = UIBox.KillerTab:AddRightGroupbox("Killer Utility", "zap")
UIBox.Aim             = Tabs.Aim:AddLeftGroupbox("Aim", "crosshair")
UIBox.AimSettings     = Tabs.Aim:AddRightGroupbox("Aim Settings", "settings-2")
UIBox.Parry           = UIBox.AbilityTab:AddLeftGroupbox("Survivor Combat", "swords")
UIBox.Crosshair       = Tabs.Aim:AddRightGroupbox("Crosshair", "crosshair")
UIBox.WeaponAim       = Tabs.Aim:AddLeftGroupbox("Weapon Settings", "target")
UIBox.Movement        = UIBox.AbilityTab:AddRightGroupbox("Movement", "move")
UIBox.SkillCheck      = UIBox.AbilityTab:AddLeftGroupbox("Skill Check", "gauge")
UIBox.SurvivorUtility = UIBox.AbilityTab:AddRightGroupbox("Survivor Utility", "heart-pulse")
UIBox.MiscTabs    = Tabs.Misc:AddRightTabbox()
UIBox.Emote       = UIBox.MiscTabs:AddTab("Emotes", "music")
UIBox.ChatName    = UIBox.MiscTabs:AddTab("Chat & Identity", "message-circle")
UIBox.FakeParry   = UIBox.MiscTabs:AddTab("Parry Visual", "shield")
UIBox.VisualTabs  = Tabs.Visual:AddRightTabbox()
UIBox.Visual      = UIBox.VisualTabs:AddTab("Graphics", "sun")
UIBox.Time        = UIBox.VisualTabs:AddTab("World", "alarm-clock-check")
UIBox.Zoom        = UIBox.VisualTabs:AddTab("Camera", "fullscreen")
UIBox.MorphAvatar = UIBox.VisualTabs:AddTab("Avatar", "user")
UIBox.SettingsTabs = Tabs.UISettings:AddRightTabbox()
UIBox.Settings     = UIBox.SettingsTabs:AddTab("Interface", "wrench")
UIBox.Config       = UIBox.SettingsTabs:AddTab("Configuration", "save")
function _BH_FN.TeleportToPart(part)
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
end
end
function _BH_FN.getHumanoid()
local char = LocalPlayer.Character
return char and char:FindFirstChildOfClass("Humanoid")
end
function _BH_FN.captureMovementOriginal(hum)
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
function _BH_FN.applyJumpPower()
Movement.JumpPowerEnabled = false
end
function _BH_FN.doForceJump()
return
end
function _BH_FN.toggleForceJump(_state)
Movement.ForceJumpEnabled = false
if Movement.ForceJumpConnection then
pcall(function()
Movement.ForceJumpConnection:Disconnect()
end)
_BH_FN.ForgetConnection(Movement.ForceJumpConnection)
Movement.ForceJumpConnection = nil
end
end
function _BH_FN.shouldDisableMovementBoost()
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
function _BH_FN.AK_IsAllowedHealthCaller(caller)
if not caller
or typeof(caller) ~= "Instance" then
return false
end
local tool = caller:FindFirstAncestorOfClass(
"Tool"
)
if not tool then
return false
end
local char = LocalPlayer.Character
local backpack =
LocalPlayer:FindFirstChildOfClass("Backpack")
local belongsToPlayer =
char ~= nil
and tool:IsDescendantOf(char)
or backpack ~= nil
and tool:IsDescendantOf(backpack)
if not belongsToPlayer then
return false
end
if tool:GetAttribute("IsGun") == true
or tool:GetAttribute("IsWeapon") == true
or tool:GetAttribute("WeaponType") ~= nil then
return true
end
local name = string.lower(tool.Name)
for _, hint in ipairs({
"pistol",
"revolver",
"handgun",
"dagger",
"knife",
"blade",
"weapon",
"flashlight",
"twist of fate",
"veil",
}) do
if string.find(name, hint, 1, true) then
return true
end
end
return false
end
function _BH_FN.AK_InstallHealthReadHook()
if AntiKnockdown.HealthIndexInstalled then
return true
end
if type(hookmetamethod) ~= "function" then
return false
end
local originalIndex
local callback = function(object, key)
local value =
originalIndex(object, key)
if key ~= "Health"
or object ~= AntiKnockdown.Humanoid
or not AntiKnockdown.Enabled
or type(value) ~= "number"
or value <= 0
or value > 50 then
return value
end
if AntiKnockdown.HealthSpoofDepth > 0 then
return 51
end
if type(checkcaller) == "function"
and checkcaller() then
return value
end
local caller = nil
if type(getcallingscript) == "function" then
pcall(function()
caller = getcallingscript()
end)
end
if _BH_FN.AK_IsAllowedHealthCaller(caller) then
return 51
end
return value
end
if type(newcclosure) == "function" then
callback = newcclosure(callback)
end
local ok, previous =
pcall(function()
return hookmetamethod(
game,
"__index",
callback
)
end)
if not ok or type(previous) ~= "function" then
return false
end
originalIndex = previous
AntiKnockdown.OriginalHealthIndex =
previous
AntiKnockdown.HealthIndexInstalled = true
return true
end
function _BH_FN.AK_CallWithHealthSpoof(callback, ...)
AntiKnockdown.HealthSpoofDepth =
AntiKnockdown.HealthSpoofDepth + 1
local results =
table.pack(
pcall(callback, ...)
)
AntiKnockdown.HealthSpoofDepth =
math.max(
0,
AntiKnockdown.HealthSpoofDepth - 1
)
if not results[1] then
error(results[2], 0)
end
return table.unpack(
results,
2,
results.n
)
end
function _BH_FN.AK_DisconnectField(key)
local connection =
AntiKnockdown[key]
if not connection then
return
end
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
AntiKnockdown[key] = nil
end
function _BH_FN.AK_IsBusy(char)
if not char then
return true
end
local root =
char:FindFirstChild("HumanoidRootPart")
if not root then
return true
end
if root.Anchored
and not (
AntiKnockdown.Enabled
and AntiKnockdown.Active
) then
return true
end
if char:GetAttribute("IsHooked")
or char:GetAttribute("IsCarried") then
return true
end
local interact =
_BH_FN.GB_GetClientInteract(char)
if interact then
for _, attr in ipairs({
"isRepairing",
"isHealing",
"isVaulting",
"isSliding",
"isDroppingPallet",
"isUnhooking",
"isExiting",
}) do
if interact:GetAttribute(attr) then
return true
end
end
end
return false
end
function _BH_FN.AK_FindAnimationController(char, hum)
local cached =
AntiKnockdown.AnimationController
if type(cached) == "table"
and rawget(cached, "character") == char
and rawget(cached, "humanoid") == hum then
return cached
end
AntiKnockdown.AnimationController = nil
if type(getgc) ~= "function" then
return nil
end
local now = os.clock()
if now < AntiKnockdown.ControllerScanAt then
return nil
end
AntiKnockdown.ControllerScanAt =
now + AntiKnockdown.ControllerScanInterval
local ok, objects =
pcall(getgc, true)
if not ok or type(objects) ~= "table" then
return nil
end
for _, candidate in pairs(objects) do
if type(candidate) == "table"
and rawget(candidate, "character") == char
and rawget(candidate, "humanoid") == hum
and type(rawget(candidate, "normalWalkSpeed")) == "number"
and type(rawget(candidate, "knockedWalkSpeed")) == "number"
and type(rawget(candidate, "runSpeed")) == "number" then
AntiKnockdown.AnimationController = candidate
return candidate
end
end
return nil
end
function _BH_FN.AK_GetTargetSpeed(controller, char)
local base =
AntiKnockdown.BaseWalkSpeed
if type(controller) == "table" then
local normal =
tonumber(
rawget(controller, "normalWalkSpeed")
) or base
local crouch =
tonumber(
rawget(controller, "crouchSpeed")
) or 6
if rawget(controller, "isEmoting") == true then
base =
tonumber(
rawget(controller, "emoteWalkSpeed")
) or normal
elseif rawget(controller, "isCtrlHeld") == true
or char:GetAttribute("Crouching") then
base = crouch
else
base = normal
end
elseif char:GetAttribute("Crouching") then
base = 6
end
return math.max(0, base)
end
function _BH_FN.AK_RestoreControllerHooks()
local class =
AntiKnockdown.ControllerClass
if type(class) == "table" then
pcall(function()
if rawget(class, "_checkConditions")
== AntiKnockdown.PatchedCheckConditions then
rawset(
class,
"_checkConditions",
AntiKnockdown.OriginalCheckConditions
)
end
if rawget(class, "_getDesiredBaseSpeed")
== AntiKnockdown.PatchedGetDesiredBaseSpeed then
rawset(
class,
"_getDesiredBaseSpeed",
AntiKnockdown.OriginalGetDesiredBaseSpeed
)
end
if rawget(class, "_playHitAnimation")
== AntiKnockdown.PatchedPlayHitAnimation then
rawset(
class,
"_playHitAnimation",
AntiKnockdown.OriginalPlayHitAnimation
)
end
if rawget(class, "_playAnimation")
== AntiKnockdown.PatchedPlayAnimation then
rawset(
class,
"_playAnimation",
AntiKnockdown.OriginalPlayAnimation
)
end
end)
end
local controller =
AntiKnockdown.AnimationController
if type(controller) == "table"
and AntiKnockdown.OriginalKnockedWalkSpeed ~= nil then
pcall(function()
controller.knockedWalkSpeed =
AntiKnockdown.OriginalKnockedWalkSpeed
end)
end
AntiKnockdown.ControllerClass = nil
AntiKnockdown.OriginalKnockedWalkSpeed = nil
AntiKnockdown.OriginalCheckConditions = nil
AntiKnockdown.OriginalGetDesiredBaseSpeed = nil
AntiKnockdown.OriginalPlayHitAnimation = nil
AntiKnockdown.OriginalPlayAnimation = nil
AntiKnockdown.PatchedCheckConditions = nil
AntiKnockdown.PatchedGetDesiredBaseSpeed = nil
AntiKnockdown.PatchedPlayHitAnimation = nil
AntiKnockdown.PatchedPlayAnimation = nil
end
function _BH_FN.AK_InstallControllerHooks(controller)
if type(controller) ~= "table" then
return
end
_BH_FN.AK_RestoreControllerHooks()
AntiKnockdown.AnimationController = controller
AntiKnockdown.OriginalKnockedWalkSpeed =
rawget(controller, "knockedWalkSpeed")
local class =
getmetatable(controller)
if type(class) ~= "table" then
return
end
local originalCheck =
rawget(class, "_checkConditions")
local originalDesired =
rawget(class, "_getDesiredBaseSpeed")
local originalPlayHit =
rawget(class, "_playHitAnimation")
local originalPlayAnimation =
rawget(class, "_playAnimation")
if type(originalCheck) ~= "function"
or type(originalDesired) ~= "function" then
return
end
AntiKnockdown.ControllerClass = class
AntiKnockdown.OriginalCheckConditions = originalCheck
AntiKnockdown.OriginalGetDesiredBaseSpeed = originalDesired
AntiKnockdown.OriginalPlayHitAnimation = originalPlayHit
AntiKnockdown.OriginalPlayAnimation = originalPlayAnimation
AntiKnockdown.PatchedCheckConditions =
function(self, ...)
local char = rawget(self, "character")
local hum = rawget(self, "humanoid")
if AntiKnockdown.Enabled
and char == LocalPlayer.Character
and hum
and hum.Health > 0
and hum.Health <= 50
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
self.isKnocked = false
if not _BH_FN.AK_IsBusy(char) then
self.isHitAnimating = false
self.cantupdatespeed = false
local target =
_BH_FN.AK_GetTargetSpeed(
self,
char
)
if type(self._setWalkSpeedSmooth)
== "function" then
self:_setWalkSpeedSmooth(target)
else
hum.WalkSpeed = target
end
end
self.isKnocked = false
return
end
return originalCheck(self, ...)
end
AntiKnockdown.PatchedGetDesiredBaseSpeed =
function(self, ...)
local char = rawget(self, "character")
local hum = rawget(self, "humanoid")
if AntiKnockdown.Enabled
and char == LocalPlayer.Character
and hum
and hum.Health > 0
and hum.Health <= 50
and not _BH_FN.AK_IsBusy(char) then
return _BH_FN.AK_GetTargetSpeed(
self,
char
)
end
return originalDesired(self, ...)
end
if type(originalPlayHit) == "function" then
AntiKnockdown.PatchedPlayHitAnimation =
function(self, ...)
local char = rawget(self, "character")
local hum = rawget(self, "humanoid")
if AntiKnockdown.Enabled
and char == LocalPlayer.Character
and hum
and hum.Health > 0
and hum.Health <= 50
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
self.isHitAnimating = false
return
end
return originalPlayHit(self, ...)
end
end
if type(originalPlayAnimation) == "function" then
AntiKnockdown.PatchedPlayAnimation =
function(self, animationName, ...)
local char = rawget(self, "character")
local hum = rawget(self, "humanoid")
if AntiKnockdown.Enabled
and char == LocalPlayer.Character
and hum
and hum.Health > 0
and hum.Health <= 50
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
if animationName == "knockedIdle"
or animationName == "knockedWalk" then
return
end
end
return originalPlayAnimation(
self,
animationName,
...
)
end
end
local installed = pcall(function()
rawset(
class,
"_checkConditions",
AntiKnockdown.PatchedCheckConditions
)
rawset(
class,
"_getDesiredBaseSpeed",
AntiKnockdown.PatchedGetDesiredBaseSpeed
)
if AntiKnockdown.PatchedPlayHitAnimation then
rawset(
class,
"_playHitAnimation",
AntiKnockdown.PatchedPlayHitAnimation
)
end
if AntiKnockdown.PatchedPlayAnimation then
rawset(
class,
"_playAnimation",
AntiKnockdown.PatchedPlayAnimation
)
end
end)
if not installed then
_BH_FN.AK_RestoreControllerHooks()
end
end
function _BH_FN.AK_RestoreProximityHook()
local module =
AntiKnockdown.ProximityModule
if type(module) == "table"
and module.cantInteract
== AntiKnockdown.PatchedCantInteract then
pcall(function()
module.cantInteract =
AntiKnockdown.OriginalCantInteract
end)
end
if type(module) == "table"
and module.scan
== AntiKnockdown.PatchedProximityScan then
pcall(function()
module.scan =
AntiKnockdown.OriginalProximityScan
end)
end
AntiKnockdown.ProximityModule = nil
AntiKnockdown.ProximityConfig = nil
AntiKnockdown.OriginalCantInteract = nil
AntiKnockdown.OriginalProximityScan = nil
AntiKnockdown.PatchedCantInteract = nil
AntiKnockdown.PatchedProximityScan = nil
end
function _BH_FN.AK_InstallProximityHook()
_BH_FN.AK_RestoreProximityHook()
local modules =
ReplicatedStorage:FindFirstChild("Modules")
local survivors =
modules
and modules:FindFirstChild("Survivors")
local proximityScript =
survivors
and survivors:FindFirstChild("SurvivorProximity")
local configScript =
survivors
and survivors:FindFirstChild("SurvivorConfig")
if not proximityScript or not configScript then
return
end
local ok, module =
pcall(require, proximityScript)
local configOk, config =
pcall(require, configScript)
if not ok
or not configOk
or type(module) ~= "table"
or type(config) ~= "table"
or type(module.cantInteract) ~= "function"
or type(module.scan) ~= "function" then
return
end
local original = module.cantInteract
local originalScan = module.scan
AntiKnockdown.ProximityModule = module
AntiKnockdown.ProximityConfig = config
AntiKnockdown.OriginalCantInteract = original
AntiKnockdown.OriginalProximityScan = originalScan
AntiKnockdown.PatchedCantInteract =
function(self, ...)
if AntiKnockdown.Enabled
and rawget(self, "player") == LocalPlayer then
return false
end
return original(self, ...)
end
AntiKnockdown.PatchedProximityScan =
function(self, scriptObject, ...)
local results = {
originalScan(
self,
scriptObject,
...
)
}
local char = rawget(self, "character")
local hum = rawget(self, "humanoid")
local root = rawget(self, "humanoidRootPart")
local state = rawget(self, "state")
local interact =
scriptObject
or rawget(self, "script")
if not AntiKnockdown.Enabled
or rawget(self, "player") ~= LocalPlayer
or not char
or not hum
or not root
or type(state) ~= "table"
or not interact
or hum.Health <= 0
or hum.Health > 50
or char:GetAttribute("IsHooked")
or char:GetAttribute("IsCarried") then
return table.unpack(results)
end
local radius =
tonumber(config.DETECTION_RADIUS)
or 4
local generatorRadius =
tonumber(
config.GENERATOR_DETECTION_RADIUS
) or radius
local free =
not root:HasTag("doing action")
state.vaultPoint = nil
state.palletSlidePoint = nil
state.palletDropPoint = nil
state.generatorPoint = nil
state.unhookPoint = nil
state.exitPoint = nil
if free
and not interact:GetAttribute("isVaulting") then
state.vaultPoint =
self:findNearestPoint(
"VaultPoint",
radius
)
end
if free
and not interact:GetAttribute("isSliding") then
state.palletSlidePoint =
self:findNearestPoint(
"PalletPointSlide",
radius
)
end
if free
and not interact:GetAttribute("isDroppingPallet") then
state.palletDropPoint =
self:findNearestPoint(
"PalletPoint",
radius
)
end
if not interact:GetAttribute("isRepairing") then
state.generatorPoint =
self:findNearestPoint(
"GeneratorPoint",
generatorRadius
)
end
if not interact:GetAttribute("isUnhooking") then
state.unhookPoint =
self:findNearestPoint(
"UnhookPoint",
radius
)
end
if not interact:GetAttribute("isExiting") then
state.exitPoint =
self:findNearestPoint(
"ExitPoint",
radius
)
end
return table.unpack(results)
end
pcall(function()
module.cantInteract =
AntiKnockdown.PatchedCantInteract
module.scan =
AntiKnockdown.PatchedProximityScan
end)
end
function _BH_FN.AK_IsKnockedTrack(track)
local animation =
track
and track.Animation
local id =
animation
and tostring(animation.AnimationId)
:match("%d+")
if id ~= nil
and AntiKnockdown.KnockedAnimationIds[id]
== true then
return true
end
local trackName = string.lower(
tostring(track and track.Name or "")
)
local animationName = string.lower(
tostring(animation and animation.Name or "")
)
for _, name in ipairs({trackName, animationName}) do
if string.find(name, "knock", 1, true)
or string.find(name, "hitfront", 1, true)
or string.find(name, "hitback", 1, true)
or name == "hit1"
or name == "hit2" then
return true
end
end
return false
end
function _BH_FN.AK_StopKnockedAnimations()
local animator =
AntiKnockdown.Animator
if not animator or not animator.Parent then
return
end
local ok, tracks =
pcall(function()
return animator:GetPlayingAnimationTracks()
end)
if not ok or not tracks then
return
end
for _, track in ipairs(tracks) do
if _BH_FN.AK_IsKnockedTrack(track) then
pcall(function()
track:AdjustSpeed(0)
track:AdjustWeight(0, 0)
track:Stop(0)
end)
end
end
end
function _BH_FN.AK_BindAnimator(animator)
_BH_FN.AK_DisconnectField(
"AnimationConnection"
)
AntiKnockdown.Animator = animator
if not animator then
return
end
AntiKnockdown.AnimationConnection =
_BH_FN.TrackConnection(
animator.AnimationPlayed:Connect(function(track)
local hum = AntiKnockdown.Humanoid
if AntiKnockdown.Enabled
and hum
and hum.Health > 0
and hum.Health <= 50
and _BH_FN.AK_IsKnockedTrack(track) then
pcall(function()
track:AdjustSpeed(0)
track:AdjustWeight(0, 0)
track:Stop(0)
end)
end
end)
)
end
function _BH_FN.AK_ApplyTick(char, hum)
local recovering =
hum.Health > 0
and hum.Health <= 50
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried")
if not recovering then
if AntiKnockdown.Active then
AntiKnockdown.Active = false
pcall(function()
char:SetAttribute(
"supresshitanim",
AntiKnockdown.OriginalSuppressHit
)
end)
local controller =
AntiKnockdown.AnimationController
if type(controller) == "table"
and AntiKnockdown.OriginalKnockedWalkSpeed
~= nil then
pcall(function()
controller.knockedWalkSpeed =
AntiKnockdown.OriginalKnockedWalkSpeed
end)
end
if not _BH_FN.AK_IsBusy(char) then
pcall(function()
if AntiKnockdown.OriginalPlatformStand
~= nil then
hum.PlatformStand =
AntiKnockdown.OriginalPlatformStand
end
if AntiKnockdown.OriginalSit ~= nil then
hum.Sit = AntiKnockdown.OriginalSit
end
if AntiKnockdown.OriginalAutoRotate
~= nil then
hum.AutoRotate =
AntiKnockdown.OriginalAutoRotate
end
end)
end
end
return
end
AntiKnockdown.Active = true
if char:GetAttribute("supresshitanim")
~= true then
pcall(function()
char:SetAttribute(
"supresshitanim",
true
)
end)
end
local ragdoll =
AntiKnockdown.RagdollTrigger
if ragdoll
and ragdoll.Parent
and ragdoll.Value then
if not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
pcall(function()
ragdoll.Value = false
end)
end
end
local controller =
_BH_FN.AK_FindAnimationController(
char,
hum
)
if controller then
if not AntiKnockdown.ControllerClass then
_BH_FN.AK_InstallControllerHooks(
controller
)
end
pcall(function()
controller.isKnocked = false
if not _BH_FN.AK_IsBusy(char) then
controller.isHitAnimating = false
controller.cantupdatespeed = false
end
controller.knockedWalkSpeed =
_BH_FN.AK_GetTargetSpeed(
controller,
char
)
end)
end
local now = os.clock()
if now >= AntiKnockdown.AnimationScanAt then
AntiKnockdown.AnimationScanAt =
now + AntiKnockdown.AnimationScanInterval
_BH_FN.AK_StopKnockedAnimations()
end
if _BH_FN.AK_IsBusy(char) then
return
end
local targetSpeed =
_BH_FN.AK_GetTargetSpeed(
controller,
char
)
pcall(function()
local root =
char:FindFirstChild("HumanoidRootPart")
if root and root.Anchored then
root.Anchored = false
end
if controller then
controller.isKnocked = false
end
hum.PlatformStand = false
hum.Sit = false
if char:GetAttribute("Aiming")
~= true then
hum.AutoRotate = true
end
if not controller
and math.abs(hum.WalkSpeed - targetSpeed) > 0.10 then
hum.WalkSpeed = targetSpeed
end
local state = hum:GetState()
if state == Enum.HumanoidStateType.Physics
or state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.FallingDown then
hum:ChangeState(
Enum.HumanoidStateType.GettingUp
)
end
end)
end
function _BH_FN.AK_UnbindCharacter()
for _, key in ipairs({
"Connection",
"AnimationConnection",
"RagdollConnection",
"HealthConnection",
}) do
_BH_FN.AK_DisconnectField(key)
end
local controller =
AntiKnockdown.AnimationController
_BH_FN.AK_RestoreControllerHooks()
_BH_FN.AK_RestoreProximityHook()
local char =
AntiKnockdown.Character
local hum =
AntiKnockdown.Humanoid
if char and char.Parent then
pcall(function()
char:SetAttribute(
"supresshitanim",
AntiKnockdown.OriginalSuppressHit
)
end)
end
local ragdoll =
AntiKnockdown.RagdollTrigger
if ragdoll
and ragdoll.Parent
and AntiKnockdown.OriginalRagdollValue ~= nil
and char
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
pcall(function()
ragdoll.Value =
AntiKnockdown.OriginalRagdollValue
end)
end
if hum
and hum.Parent
and not _BH_FN.AK_IsBusy(char) then
pcall(function()
if AntiKnockdown.OriginalPlatformStand ~= nil then
hum.PlatformStand =
AntiKnockdown.OriginalPlatformStand
end
if AntiKnockdown.OriginalSit ~= nil then
hum.Sit = AntiKnockdown.OriginalSit
end
if AntiKnockdown.OriginalAutoRotate ~= nil then
hum.AutoRotate =
AntiKnockdown.OriginalAutoRotate
end
end)
end
if type(controller) == "table"
and rawget(controller, "character") == char
and type(controller._checkConditions) == "function" then
pcall(function()
controller:_checkConditions()
end)
end
AntiKnockdown.Character = nil
AntiKnockdown.Humanoid = nil
AntiKnockdown.Animator = nil
AntiKnockdown.RagdollTrigger = nil
AntiKnockdown.AnimationController = nil
AntiKnockdown.OriginalSuppressHit = nil
AntiKnockdown.OriginalRagdollValue = nil
AntiKnockdown.OriginalPlatformStand = nil
AntiKnockdown.OriginalSit = nil
AntiKnockdown.OriginalAutoRotate = nil
AntiKnockdown.ControllerScanAt = 0
AntiKnockdown.AnimationScanAt = 0
AntiKnockdown.LastTick = 0
AntiKnockdown.Active = false
end
function _BH_FN.AK_BindCharacter(char)
_BH_FN.AK_UnbindCharacter()
if not AntiKnockdown.Enabled
or not char then
return
end
local hum =
char:FindFirstChildOfClass("Humanoid")
if not hum then
return
end
AntiKnockdown.Character = char
AntiKnockdown.Humanoid = hum
AntiKnockdown.OriginalSuppressHit =
char:GetAttribute("supresshitanim")
AntiKnockdown.OriginalPlatformStand =
hum.PlatformStand
AntiKnockdown.OriginalSit = hum.Sit
AntiKnockdown.OriginalAutoRotate = hum.AutoRotate
local ragdoll =
char:FindFirstChild("RagdollTrigger", true)
if ragdoll
and ragdoll:IsA("BoolValue") then
AntiKnockdown.RagdollTrigger = ragdoll
AntiKnockdown.OriginalRagdollValue =
ragdoll.Value
if hum.Health <= 50
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
pcall(function()
ragdoll.Value = false
end)
end
AntiKnockdown.RagdollConnection =
_BH_FN.TrackConnection(
ragdoll:GetPropertyChangedSignal("Value")
:Connect(function()
if AntiKnockdown.Enabled
and hum.Health <= 50
and ragdoll.Value
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
task.defer(function()
if AntiKnockdown.Enabled
and hum.Health <= 50
and ragdoll.Parent
and not char:GetAttribute("IsHooked")
and not char:GetAttribute("IsCarried") then
ragdoll.Value = false
end
end)
end
end)
)
end
local controller =
_BH_FN.AK_FindAnimationController(
char,
hum
)
if controller then
_BH_FN.AK_InstallControllerHooks(
controller
)
end
_BH_FN.AK_BindAnimator(
hum:FindFirstChildOfClass("Animator")
)
AntiKnockdown.HealthConnection =
_BH_FN.TrackConnection(
hum.HealthChanged:Connect(function()
if not HubRuntime.Alive
or not AntiKnockdown.Enabled
or not char.Parent then
return
end
task.defer(function()
if AntiKnockdown.Enabled
and char.Parent
and hum.Parent then
_BH_FN.AK_ApplyTick(char, hum)
end
end)
end)
)
AntiKnockdown.Connection =
_BH_FN.TrackConnection(
RunService.RenderStepped:Connect(function()
if not HubRuntime.Alive
or not AntiKnockdown.Enabled
or not char.Parent
or hum.Health <= 0 then
return
end
local now = os.clock()
if now - AntiKnockdown.LastTick
< AntiKnockdown.TickRate then
return
end
AntiKnockdown.LastTick = now
if not AntiKnockdown.Animator
or not AntiKnockdown.Animator.Parent then
local animator =
hum:FindFirstChildOfClass("Animator")
if animator then
_BH_FN.AK_BindAnimator(animator)
end
end
_BH_FN.AK_ApplyTick(char, hum)
end)
)
end
function _BH_FN.AK_SetEnabled(state)
AntiKnockdown.Enabled =
state == true
if AntiKnockdown.Enabled then
task.defer(function()
if _BH_FN.installMainNamecallHook then
_BH_FN.installMainNamecallHook()
end
end)
end
_BH_FN.AK_DisconnectField(
"CharacterConnection"
)
_BH_FN.AK_UnbindCharacter()
if not AntiKnockdown.Enabled then
return
end
if LocalPlayer.Character then
_BH_FN.AK_BindCharacter(
LocalPlayer.Character
)
end
AntiKnockdown.CharacterConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.20)
if AntiKnockdown.Enabled then
_BH_FN.AK_BindCharacter(char)
end
end)
)
end
function _BH_FN.ALS_IsBusy(char)
if not char then return true end
local root = char:FindFirstChild("HumanoidRootPart")
if not root or root.Anchored then return true end
local hum =
char:FindFirstChildOfClass("Humanoid")
if AntiKnockdown.Enabled
and (
AntiKnockdown.Active
or (hum and hum.Health > 0 and hum.Health <= 50)
) then
return true
end
local interact =
_BH_FN.GB_GetClientInteract(char)
if interact then
for _, attr in ipairs({
"isRepairing", "isVaulting", "isSliding", "isHealing",
"isUnhooking", "isExiting", "isDroppingPallet"
}) do
if interact:GetAttribute(attr) then return true end
end
end
return char:GetAttribute("IsCarried")
or char:GetAttribute("IsHooked")
or char:GetAttribute("MovementLocked")
end
function _BH_FN.ALS_ResetState()
AntiLoopStuck.LastPosition = nil
AntiLoopStuck.StillSince = 0
end
function _BH_FN.ALS_GetMoveIntent(hum)
if hum and hum.MoveDirection.Magnitude >= 0.10 then
return hum.MoveDirection.Unit
end
local camera = workspace.CurrentCamera
if not camera then return Vector3.zero end
local x = 0
local z = 0
if UserInputService:IsKeyDown(Enum.KeyCode.W) then z = z + 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then z = z - 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then x = x + 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then x = x - 1 end
if x == 0 and z == 0 then
return Vector3.zero
end
local look = Vector3.new(
camera.CFrame.LookVector.X,
0,
camera.CFrame.LookVector.Z
)
local right = Vector3.new(
camera.CFrame.RightVector.X,
0,
camera.CFrame.RightVector.Z
)
if look.Magnitude <= 0.01
or right.Magnitude <= 0.01 then
return Vector3.zero
end
local direction = right.Unit * x + look.Unit * z
return direction.Magnitude > 0.01
and direction.Unit
or Vector3.zero
end
function _BH_FN.ALS_SetEnabled(state)
AntiLoopStuck.Enabled = state == true
if AntiLoopStuck.Connection then
pcall(function() AntiLoopStuck.Connection:Disconnect() end)
_BH_FN.ForgetConnection(AntiLoopStuck.Connection)
AntiLoopStuck.Connection = nil
end
_BH_FN.ALS_ResetState()
if not AntiLoopStuck.Enabled then return end
AntiLoopStuck.Connection = _BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function()
if not HubRuntime.Alive or not AntiLoopStuck.Enabled then return end
local now = os.clock()
if now - AntiLoopStuck.LastTick < AntiLoopStuck.SampleRate then return end
AntiLoopStuck.LastTick = now
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
local intent = _BH_FN.ALS_GetMoveIntent(hum)
if not hum or not root or hum.Health <= 0
or _BH_FN.ALS_IsBusy(char)
or intent.Magnitude < 0.15 then
_BH_FN.ALS_ResetState()
return
end
if not AntiLoopStuck.LastPosition then
AntiLoopStuck.LastPosition = root.Position
AntiLoopStuck.StillSince = now
return
end
local moved = (root.Position - AntiLoopStuck.LastPosition).Magnitude
if moved >= AntiLoopStuck.MoveThreshold then
AntiLoopStuck.LastPosition = root.Position
AntiLoopStuck.StillSince = now
return
end
if AntiLoopStuck.StillSince == 0 then
AntiLoopStuck.StillSince = now
return
end
local flatVelocity = Vector3.new(
root.AssemblyLinearVelocity.X,
0,
root.AssemblyLinearVelocity.Z
).Magnitude
if flatVelocity > 1.25 then
AntiLoopStuck.LastPosition = root.Position
AntiLoopStuck.StillSince = now
return
end
if now < AntiLoopStuck.CooldownUntil
or now - AntiLoopStuck.StillSince < AntiLoopStuck.TriggerTime then
return
end
AntiLoopStuck.CooldownUntil = now + 1.75
AntiLoopStuck.StillSince = now
AntiLoopStuck.LastPosition = root.Position
pcall(function()
hum.AutoRotate = true
local velocity = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = Vector3.new(
intent.X * 7,
math.max(velocity.Y, 5),
intent.Z * 7
)
if hum.FloorMaterial ~= Enum.Material.Air then
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end
end)
end)
)
end
function _BH_FN.MB_GetMultiplier()
return 1
+ math.clamp(
tonumber(Movement.BoostValue) or 0,
0,
20
) / 20
end
function _BH_FN.MB_RestoreNative()
if Connections.Boost then
pcall(function()
Connections.Boost:Disconnect()
end)
_BH_FN.ForgetConnection(Connections.Boost)
Connections.Boost = nil
end
local char = Movement.BoostCharacter
if char and char.Parent then
pcall(function()
if Movement.BoostBaseWasNil then
char:SetAttribute("speedboost", nil)
else
char:SetAttribute(
"speedboost",
Movement.BoostBase
)
end
end)
end
Movement.BoostCharacter = nil
Movement.BoostBase = 1
Movement.BoostBaseWasNil = true
Movement.BoostLastWritten = nil
end
function _BH_FN.MB_WriteNative(char)
if not char
or not char.Parent
or not Movement.BoostEnabled then
return
end
local value =
math.max(
0.05,
tonumber(Movement.BoostBase) or 1
)
* _BH_FN.MB_GetMultiplier()
Movement.BoostLastWritten = value
pcall(function()
char:SetAttribute("speedboost", value)
end)
end
function _BH_FN.applyMovementBoost()
local char = LocalPlayer.Character
if not Movement.BoostEnabled then
_BH_FN.MB_RestoreNative()
return
end
if not char then
return
end
if Movement.BoostCharacter ~= char then
_BH_FN.MB_RestoreNative()
Movement.BoostCharacter = char
local existing =
char:GetAttribute("speedboost")
Movement.BoostBaseWasNil =
existing == nil
Movement.BoostBase =
tonumber(existing) or 1
elseif Connections.Boost then
_BH_FN.MB_WriteNative(char)
return
end
_BH_FN.MB_WriteNative(char)
Connections.Boost =
_BH_FN.TrackConnection(
char:GetAttributeChangedSignal(
"speedboost"
):Connect(function()
if not HubRuntime.Alive
or not Movement.BoostEnabled
or Movement.BoostCharacter ~= char then
return
end
local current =
char:GetAttribute("speedboost")
local numeric =
tonumber(current)
if numeric
and Movement.BoostLastWritten
and math.abs(
numeric
- Movement.BoostLastWritten
) < 0.0001 then
return
end
Movement.BoostBaseWasNil =
current == nil
Movement.BoostBase =
numeric or 1
_BH_FN.MB_WriteNative(char)
end)
)
end
function tapMobileParryButton()
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if not playerGui then return false end
local survivorMob = playerGui:FindFirstChild("Survivor-mob")
local parryBtn = survivorMob
and survivorMob:FindFirstChild("Controls")
and survivorMob.Controls:FindFirstChild("Gui-mob")
if parryBtn
and parryBtn:IsA("GuiButton")
and parryBtn.Visible
and type(firesignal) == "function" then
local ok = pcall(function()
firesignal(parryBtn.MouseButton1Down)
task.wait(0.01)
firesignal(parryBtn.MouseButton1Up)
end)
if ok then return true end
end
local sent = false
pcall(function()
if mouse2click then
mouse2click()
sent = true
return
end
if mouse2press and mouse2release then
mouse2press()
task.wait(0.01)
mouse2release()
sent = true
return
end
if MouseButton2Click then
MouseButton2Click()
sent = true
return
end
VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
task.wait(0.01)
VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
sent = true
end)
return sent
end
function ExecuteParry()
local now = os.clock()
if State.ParryCooldown
or now < (State.ParryInputLockUntil or 0) then
return false
end
State.ParryInputLockUntil = now + 0.75
State.lastParry = now
local sent = false
pcall(function()
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local items = remotes and remotes:FindFirstChild("Items")
local dagger = items and items:FindFirstChild("Parrying Dagger")
local parryRemote = dagger and dagger:FindFirstChild("parry")
if parryRemote and parryRemote:IsA("RemoteEvent") then
parryRemote:FireServer()
sent = true
end
end)
if not sent then
sent = tapMobileParryButton()
end
if not sent then
State.ParryInputLockUntil = now
return false
end
return true
end
function ListenToParryResult()
task.spawn(function()
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
local items = remotes and remotes:WaitForChild("Items", 5)
local dagger = items and items:WaitForChild("Parrying Dagger", 5)
local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
if parryResultRemote then
_BH_FN.TrackConnection(parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
if not HubRuntime.Alive then return end
local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
State.ParryCooldown = true
if State.ParryCooldownThread
and type(task.cancel) == "function" then
pcall(task.cancel, State.ParryCooldownThread)
end
State.ParryCooldownThread = task.delay(cdDur, function()
State.ParryCooldown = false
State.ParryCooldownThread = nil
end)
end))
end
end)
end
ListenToParryResult()
function _BH_FN.ParryDryRunLog(key, message)
if not ParryDryRun.Enabled then
return
end
local now = os.clock()
local last = ParryDryRun.LastLog[key] or 0
if now - last < ParryDryRun.LogCooldown then
return
end
ParryDryRun.LastLog[key] = now
print("[Bluehaven Parry Test] " .. message)
end
function _BH_FN.PDR_GetFlatVelocity(part, cap)
if not part then
return Vector3.zero
end
local velocity =
part.AssemblyLinearVelocity
local flat =
Vector3.new(
velocity.X,
0,
velocity.Z
)
local maxSpeed =
tonumber(cap) or 28
if flat.Magnitude > maxSpeed then
flat =
flat.Unit * maxSpeed
end
return flat
end
function _BH_FN.PDR_HasLineOfSight(
killerChar,
killerRoot,
myChar
)
local myRoot =
myChar:FindFirstChild(
"HumanoidRootPart"
)
if not myRoot then
return false
end
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances =
{killerChar}
params.IgnoreWater = true
local origin =
killerRoot.Position
+ Vector3.new(0, 1.2, 0)
for _, name in ipairs({
"Head",
"UpperTorso",
"HumanoidRootPart",
}) do
local part =
myChar:FindFirstChild(name)
if part
and part:IsA("BasePart") then
local hit =
workspace:Raycast(
origin,
part.Position - origin,
params
)
if not hit
or hit.Instance:IsDescendantOf(
myChar
) then
return true
end
end
end
return false
end
function _BH_FN.ParryDryRunEvaluate(
kChar,
attackName,
animId
)
if not ParryDryRun.Enabled then
return
end
local myChar =
LocalPlayer.Character
local myHRP =
myChar
and myChar:FindFirstChild(
"HumanoidRootPart"
)
local kHRP =
kChar
and kChar:FindFirstChild(
"HumanoidRootPart"
)
if not myChar
or not myHRP
or not kHRP then
_BH_FN.ParryDryRunLog(
tostring(kChar) .. ":missing",
tostring(attackName)
.. " -> SKIP (missing character/root)"
)
return
end
if IsDowned(myChar) then
_BH_FN.ParryDryRunLog(
tostring(kChar) .. ":down",
tostring(attackName)
.. " -> SKIP (player downed)"
)
return
end
if not IsSafeToParry(myChar) then
_BH_FN.ParryDryRunLog(
tostring(kChar) .. ":busy",
tostring(attackName)
.. " -> SKIP (repair/vault/etc)"
)
return
end
local radius =
math.clamp(
tonumber(
Config.Surv_ParryRadius
) or 9.5,
5,
15
)
local predictionTime = 0.12
local myPred =
myHRP.Position
+ _BH_FN.PDR_GetFlatVelocity(
myHRP,
26
) * predictionTime
local killerPred =
kHRP.Position
+ _BH_FN.PDR_GetFlatVelocity(
kHRP,
30
) * predictionTime
local flatDelta =
Vector3.new(
myPred.X - killerPred.X,
0,
myPred.Z - killerPred.Z
)
local distance =
flatDelta.Magnitude
if distance > radius then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":far:"
.. tostring(animId),
string.format(
"%s -> MISS | dist %.1f > %.1f",
tostring(attackName),
distance,
radius
)
)
return
end
if not _BH_FN.PDR_HasLineOfSight(
kChar,
kHRP,
myChar
) then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":blocked:"
.. tostring(animId),
string.format(
"%s -> BLOCKED | wall/geometry",
tostring(attackName)
)
)
return
end
local look =
kHRP.CFrame.LookVector
local lookFlat =
Vector3.new(
look.X,
0,
look.Z
)
if lookFlat.Magnitude <= 0.001
or flatDelta.Magnitude <= 0.001 then
return
end
lookFlat =
lookFlat.Unit
local towardPlayer =
flatDelta.Unit
local facingDot =
lookFlat:Dot(
towardPlayer
)
local threshold =
tonumber(
Config.Surv_ParryFace
) or 0.7
if facingDot < threshold then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":face:"
.. tostring(animId),
string.format(
"%s -> MISS | facing %.2f < %.2f",
tostring(attackName),
facingDot,
threshold
)
)
return
end
local forwardDistance =
flatDelta:Dot(
lookFlat
)
if forwardDistance < -0.4 then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":behind:"
.. tostring(animId),
tostring(attackName)
.. " -> MISS | behind attacker"
)
return
end
local lateralVector =
flatDelta
- lookFlat
* forwardDistance
local lateralDistance =
lateralVector.Magnitude
local bodyHalfWidth = 2.0
local attackHalfWidth = 2.15
local corridor =
bodyHalfWidth
+ attackHalfWidth
if lateralDistance > corridor then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":side:"
.. tostring(animId),
string.format(
"%s -> MISS | lateral %.1f > %.1f",
tostring(attackName),
lateralDistance,
corridor
)
)
return
end
local verticalDelta =
math.abs(
myPred.Y
- killerPred.Y
)
if verticalDelta > 5.5 then
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":vertical:"
.. tostring(animId),
string.format(
"%s -> MISS | height %.1f",
tostring(attackName),
verticalDelta
)
)
return
end
_BH_FN.ParryDryRunLog(
tostring(kChar)
.. ":risk:"
.. tostring(animId),
string.format(
"%s -> HIT-RISK | dist %.1f | face %.2f | side %.1f",
tostring(attackName),
distance,
facingDot,
lateralDistance
)
)
end
local ParrySensor = {
ActiveTracks = setmetatable({}, {__mode = "k"}),
EvidenceAt = setmetatable({}, {__mode = "k"}),
EvidenceWindow = 0.30,
CancelGrace = 0.055,
MinAdvance = 0.035,
AdvanceEpsilon = 0.002,
KeyframeNames = {
"Hit",
"Damage",
"Strike",
"Swing",
"Slash",
"Hitbox",
"HitStart",
"DamageStart",
},
}
function _BH_FN.PARRY_MarkCommitEvidence(kChar)
if kChar and kChar.Parent then
ParrySensor.EvidenceAt[kChar] = os.clock()
end
end
function _BH_FN.PARRY_HasCommitEvidence(kChar)
local seenAt = ParrySensor.EvidenceAt[kChar]
return seenAt ~= nil
and os.clock() - seenAt <= ParrySensor.EvidenceWindow
end
function _BH_FN.PARRY_BindTrailEvidence(kChar, trail)
if not trail or not trail:IsA("Trail") then
return
end
_BH_FN.TrackConnection(
trail:GetPropertyChangedSignal("Enabled"):Connect(function()
if HubRuntime.Alive and trail.Enabled then
_BH_FN.PARRY_MarkCommitEvidence(kChar)
end
end)
)
end
local ParryProfiles = {
Basic = {
CommitTime = 0.18,
MinCommit = 0.11,
MaxCommit = 0.34,
CommitFraction = 0.24,
MarkerLead = 0.075,
StrikeWindow = 0.30,
MaxWatch = 1.05,
PredictionTime = 0.08,
AttackPadding = 1.45,
},
Lunge = {
CommitTime = 0.25,
MinCommit = 0.14,
MaxCommit = 0.48,
CommitFraction = 0.23,
MarkerLead = 0.09,
StrikeWindow = 0.50,
MaxWatch = 1.45,
PredictionTime = 0.14,
AttackPadding = 1.95,
},
Frenzy = {
CommitTime = 0.13,
MinCommit = 0.08,
MaxCommit = 0.26,
CommitFraction = 0.18,
MarkerLead = 0.055,
StrikeWindow = 0.28,
MaxWatch = 0.85,
PredictionTime = 0.10,
AttackPadding = 1.65,
},
Special = {
CommitTime = 0.20,
MinCommit = 0.11,
MaxCommit = 0.42,
CommitFraction = 0.22,
MarkerLead = 0.08,
StrikeWindow = 0.40,
MaxWatch = 1.25,
PredictionTime = 0.11,
AttackPadding = 1.80,
},
}
function _BH_FN.PARRY_GetProfile(attackName, animId)
local lower = string.lower(tostring(attackName or ""))
if string.find(lower, "lunge", 1, true) then
return ParryProfiles.Lunge
end
if string.find(lower, "frenzy", 1, true) then
return ParryProfiles.Frenzy
end
if string.find(lower, "basic", 1, true) then
return ParryProfiles.Basic
end
if animId == "80411309607666"
or string.find(lower, "s1", 1, true) then
return ParryProfiles.Special
end
return ParryProfiles.Special
end
function _BH_FN.PARRY_ReadTrack(track)
local ok, snapshot = pcall(function()
return {
IsPlaying = track.IsPlaying == true,
TimePosition = tonumber(track.TimePosition) or 0,
Length = tonumber(track.Length) or 0,
Speed = tonumber(track.Speed) or 1,
Weight = tonumber(track.WeightCurrent) or 1,
}
end)
if not ok then
return nil
end
return snapshot
end
function _BH_FN.PARRY_ResolveCommitTime(track, profile, length)
local commit = profile.CommitTime
if length and length > 0.08 then
commit = math.clamp(
length * profile.CommitFraction,
profile.MinCommit,
profile.MaxCommit
)
end
local earliestMarker = nil
for _, keyframeName in ipairs(ParrySensor.KeyframeNames) do
local ok, keyframeTime = pcall(function()
return track:GetTimeOfKeyframe(keyframeName)
end)
keyframeTime = ok and tonumber(keyframeTime) or nil
if keyframeTime
and keyframeTime >= (profile.MinCommit + profile.MarkerLead)
and (not earliestMarker or keyframeTime < earliestMarker) then
earliestMarker = keyframeTime
end
end
if earliestMarker then
commit = math.clamp(
earliestMarker - profile.MarkerLead,
profile.MinCommit,
profile.MaxCommit
)
end
return commit
end
function _BH_FN.PARRY_EvaluateThreat(kChar, profile)
local myChar = LocalPlayer.Character
local owner = kChar and Players:GetPlayerFromCharacter(kChar)
if owner and not IsKiller(owner) then
return false, "not-killer"
end
local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
local kHRP = kChar and kChar:FindFirstChild("HumanoidRootPart")
local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
local kHum = kChar and kChar:FindFirstChildOfClass("Humanoid")
if not myChar
or not kChar
or not myHRP
or not kHRP
or not myHum
or not kHum
or myHum.Health <= 0
or kHum.Health <= 0 then
return false, "missing"
end
if IsDowned(myChar) then
return false, "downed"
end
if not IsSafeToParry(myChar) then
return false, "busy"
end
local predictionTime = profile.PredictionTime
if Config.Surv_ParryAggressive then
predictionTime = predictionTime + 0.04
end
local myPred = myHRP.Position
+ _BH_FN.PDR_GetFlatVelocity(myHRP, 26) * predictionTime
local killerPred = kHRP.Position
+ _BH_FN.PDR_GetFlatVelocity(kHRP, 32) * predictionTime
local flatDelta = Vector3.new(
myPred.X - killerPred.X,
0,
myPred.Z - killerPred.Z
)
local distance = flatDelta.Magnitude
local radius = math.clamp(
tonumber(Config.Surv_ParryRadius) or 9.5,
5,
15
)
if distance > radius then
return false, "far", {
Distance = distance,
Radius = radius,
}
end
local verticalDelta = math.abs(myPred.Y - killerPred.Y)
if verticalDelta > 5.0 then
return false, "vertical", {
Height = verticalDelta,
}
end
if not _BH_FN.PDR_HasLineOfSight(kChar, kHRP, myChar) then
return false, "blocked"
end
if distance <= 0.001 then
return true, "overlap", {
Distance = distance,
Facing = 1,
Front = 1,
Lateral = 0,
}
end
local towardPlayer = flatDelta.Unit
local killerLook = kHRP.CFrame.LookVector
local killerLookFlat = Vector3.new(killerLook.X, 0, killerLook.Z)
local myLook = myHRP.CFrame.LookVector
local myLookFlat = Vector3.new(myLook.X, 0, myLook.Z)
if killerLookFlat.Magnitude <= 0.001
or myLookFlat.Magnitude <= 0.001 then
return false, "invalid-facing"
end
killerLookFlat = killerLookFlat.Unit
myLookFlat = myLookFlat.Unit
local facingThreshold = math.clamp(
tonumber(Config.Surv_ParryFace) or 0.7,
0.1,
1
)
local facingDot = killerLookFlat:Dot(towardPlayer)
if facingDot < facingThreshold then
return false, "killer-facing", {
Facing = facingDot,
Threshold = facingThreshold,
}
end
local frontThreshold = math.clamp(
facingThreshold - 0.08,
0.35,
0.95
)
local towardKiller = -towardPlayer
local frontDot = myLookFlat:Dot(towardKiller)
if frontDot < frontThreshold then
return false, "player-front", {
Front = frontDot,
Threshold = frontThreshold,
}
end
local forwardDistance = flatDelta:Dot(killerLookFlat)
if forwardDistance < -0.25 then
return false, "behind"
end
local lateralVector = flatDelta - killerLookFlat * forwardDistance
local lateralDistance = lateralVector.Magnitude
local myHalfWidth = math.max(myHRP.Size.X, myHRP.Size.Z) * 0.5
local killerHalfWidth = math.max(kHRP.Size.X, kHRP.Size.Z) * 0.5
local corridor = myHalfWidth
+ killerHalfWidth
+ profile.AttackPadding
if lateralDistance > corridor then
return false, "side", {
Lateral = lateralDistance,
Corridor = corridor,
}
end
local closingSpeed = _BH_FN.PDR_GetFlatVelocity(kHRP, 32):Dot(towardPlayer)
if closingSpeed < -5
and distance > (corridor + 1.25) then
return false, "retreating", {
Closing = closingSpeed,
}
end
return true, "risk", {
Distance = distance,
Facing = facingDot,
Front = frontDot,
Lateral = lateralDistance,
Closing = closingSpeed,
}
end
function _BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
threat,
reason,
data
)
if not ParryDryRun.Enabled then
return
end
data = data or {}
local key = tostring(kChar)
.. ":"
.. tostring(animId)
.. ":"
.. tostring(reason)
local message
if threat then
message = string.format(
"%s -> COMMITTED HIT-RISK | dist %.1f | face %.2f | front %.2f | side %.1f",
tostring(attackName),
tonumber(data.Distance) or 0,
tonumber(data.Facing) or 0,
tonumber(data.Front) or 0,
tonumber(data.Lateral) or 0
)
elseif reason == "cancelled" then
message = tostring(attackName)
.. " -> IGNORED | cancelled before commit (fake/feint)"
elseif reason == "paused" then
message = tostring(attackName)
.. " -> IGNORED | animation stalled before commit"
elseif reason == "far" then
message = string.format(
"%s -> MISS | dist %.1f > %.1f",
tostring(attackName),
tonumber(data.Distance) or 0,
tonumber(data.Radius) or 0
)
elseif reason == "killer-facing" then
message = string.format(
"%s -> MISS | killer face %.2f < %.2f",
tostring(attackName),
tonumber(data.Facing) or 0,
tonumber(data.Threshold) or 0
)
elseif reason == "player-front" then
message = string.format(
"%s -> MISS | not in front %.2f < %.2f",
tostring(attackName),
tonumber(data.Front) or 0,
tonumber(data.Threshold) or 0
)
elseif reason == "side" then
message = string.format(
"%s -> MISS | side %.1f > %.1f",
tostring(attackName),
tonumber(data.Lateral) or 0,
tonumber(data.Corridor) or 0
)
elseif reason == "vertical" then
message = string.format(
"%s -> MISS | height %.1f",
tostring(attackName),
tonumber(data.Height) or 0
)
elseif reason == "blocked" then
message = tostring(attackName)
.. " -> MISS | wall/geometry"
elseif reason == "retreating" then
message = tostring(attackName)
.. " -> MISS | killer moving away"
elseif reason == "cooldown" then
message = tostring(attackName)
.. " -> SKIP | parry cooldown"
else
message = tostring(attackName)
.. " -> SKIP | "
.. tostring(reason)
end
_BH_FN.ParryDryRunLog(key, message)
end
function _BH_FN.PARRY_StopWatcher(track)
local watcher = ParrySensor.ActiveTracks[track]
if not watcher then
return
end
ParrySensor.ActiveTracks[track] = nil
if watcher.Connection then
pcall(function()
watcher.Connection:Disconnect()
end)
_BH_FN.ForgetConnection(watcher.Connection)
watcher.Connection = nil
end
end
function _BH_FN.PARRY_StopCharacterWatchers(kChar)
local tracks = {}
for track, watcher in pairs(ParrySensor.ActiveTracks) do
if watcher.KillerCharacter == kChar then
tracks[#tracks + 1] = track
end
end
for _, track in ipairs(tracks) do
_BH_FN.PARRY_StopWatcher(track)
end
end
function _BH_FN.PARRY_WatchAttack(kChar, track, attackName, animId)
if not kChar
or not track
or ParrySensor.ActiveTracks[track] then
return
end
local wantsCrouch = animId == "80411309607666"
and Config.Surv_AutoCrouch
local wantsParry = Config.Surv_AutoParry
and not (
Config.Ignored_Skills_List
and Config.Ignored_Skills_List[attackName]
)
if not wantsParry
and not wantsCrouch
and not ParryDryRun.Enabled then
return
end
local profile = _BH_FN.PARRY_GetProfile(attackName, animId)
local snapshot = _BH_FN.PARRY_ReadTrack(track)
if not snapshot then
return
end
local startedAt = os.clock()
local watcher = {
KillerCharacter = kChar,
AttackName = attackName,
AnimationId = animId,
Profile = profile,
StartedAt = startedAt,
StartPosition = snapshot.TimePosition,
MaxPosition = snapshot.TimePosition,
LastAdvanceAt = startedAt,
CommitTime = profile.CommitTime,
CommitResolved = false,
Committed = false,
DecisionLogged = false,
LastReason = "no-risk",
LastData = nil,
Connection = nil,
}
ParrySensor.ActiveTracks[track] = watcher
watcher.Connection = _BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function()
if ParrySensor.ActiveTracks[track] ~= watcher then
return
end
local now = os.clock()
local elapsed = now - watcher.StartedAt
local currentWantsCrouch = animId == "80411309607666"
and Config.Surv_AutoCrouch
local currentWantsParry = Config.Surv_AutoParry
and not (
Config.Ignored_Skills_List
and Config.Ignored_Skills_List[attackName]
)
if not HubRuntime.Alive
or not kChar.Parent
or (
not currentWantsParry
and not currentWantsCrouch
and not ParryDryRun.Enabled
) then
_BH_FN.PARRY_StopWatcher(track)
return
end
local current = _BH_FN.PARRY_ReadTrack(track)
if not current then
_BH_FN.PARRY_StopWatcher(track)
return
end
if current.TimePosition
> (watcher.MaxPosition + ParrySensor.AdvanceEpsilon) then
watcher.MaxPosition = current.TimePosition
watcher.LastAdvanceAt = now
end
if not current.IsPlaying
and elapsed >= ParrySensor.CancelGrace then
if not watcher.Committed then
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
false,
"cancelled"
)
end
_BH_FN.PARRY_StopWatcher(track)
return
end
if elapsed > profile.MaxWatch then
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
false,
watcher.LastReason,
watcher.LastData
)
_BH_FN.PARRY_StopWatcher(track)
return
end
if not watcher.CommitResolved
and (current.Length > 0.08 or elapsed >= 0.12) then
watcher.CommitTime = _BH_FN.PARRY_ResolveCommitTime(
track,
profile,
current.Length
)
watcher.CommitResolved = true
end
local advanced = watcher.MaxPosition - watcher.StartPosition
local minAdvance = ParrySensor.MinAdvance
if watcher.StartPosition
>= (watcher.CommitTime * 0.65) then
minAdvance = 0.012
end
if current.Speed <= 0.01
and not watcher.Committed
and now - watcher.LastAdvanceAt > 0.14 then
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
false,
"paused"
)
_BH_FN.PARRY_StopWatcher(track)
return
end
local concreteCommit =
_BH_FN.PARRY_HasCommitEvidence(kChar)
if elapsed < ParrySensor.CancelGrace
or advanced < minAdvance
or (
watcher.MaxPosition < watcher.CommitTime
and not concreteCommit
)
or current.Weight <= 0.015 then
return
end
watcher.Committed = true
if watcher.MaxPosition
> (watcher.CommitTime + profile.StrikeWindow) then
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
false,
watcher.LastReason,
watcher.LastData
)
_BH_FN.PARRY_StopWatcher(track)
return
end
local threat, reason, data = _BH_FN.PARRY_EvaluateThreat(
kChar,
profile
)
watcher.LastReason = reason
watcher.LastData = data
if not threat then
return
end
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
true,
reason,
data
)
watcher.DecisionLogged = true
if currentWantsCrouch then
task.spawn(TriggerCrouch)
_BH_FN.PARRY_StopWatcher(track)
return
end
if not currentWantsParry then
_BH_FN.PARRY_StopWatcher(track)
return
end
if State.ParryCooldown then
_BH_FN.PARRY_LogDecision(
kChar,
attackName,
animId,
false,
"cooldown"
)
_BH_FN.PARRY_StopWatcher(track)
return
end
ExecuteParry()
_BH_FN.PARRY_StopWatcher(track)
end)
)
end
function AttachParrySensor(kChar)
if not kChar or Attached[kChar] then return end
Attached[kChar] = true
local humanoid = kChar:FindFirstChild("Humanoid")
if not humanoid then
humanoid = kChar:WaitForChild("Humanoid", 5)
if not humanoid then
Attached[kChar] = nil
return
end
end
local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
animator = humanoid:WaitForChild("Animator", 5)
if not animator then
Attached[kChar] = nil
return
end
end
_BH_FN.TrackConnection(humanoid.ChildAdded:Connect(function(child)
if not HubRuntime.Alive then return end
if child:IsA("Animator") then
Attached[kChar] = nil
AttachParrySensor(kChar)
end
end))
_BH_FN.TrackConnection(kChar.AncestryChanged:Connect(function(_, parent)
if not parent then
Attached[kChar] = nil
ParrySensor.EvidenceAt[kChar] = nil
_BH_FN.PARRY_StopCharacterWatchers(kChar)
end
end))
for _, obj in ipairs(kChar:GetDescendants()) do
if obj:IsA("Trail") then
_BH_FN.PARRY_BindTrailEvidence(kChar, obj)
end
end
_BH_FN.TrackConnection(kChar.DescendantAdded:Connect(function(obj)
if not HubRuntime.Alive then return end
local lowerName = string.lower(obj.Name)
if string.find(lowerName, "wallhitboxcollider_", 1, true) then
_BH_FN.PARRY_MarkCommitEvidence(kChar)
elseif obj:IsA("Trail") then
_BH_FN.PARRY_BindTrailEvidence(kChar, obj)
if obj.Enabled then
_BH_FN.PARRY_MarkCommitEvidence(kChar)
end
end
end))
_BH_FN.TrackConnection(animator.AnimationPlayed:Connect(function(track)
if not HubRuntime.Alive then return end
local animId = track.Animation and track.Animation.AnimationId or ""
local id = animId:match("%d+")
local attackName = VALID_PARRY_IDS[id]
if not attackName then return end
_BH_FN.PARRY_WatchAttack(kChar, track, attackName, id)
end))
end
function TryAttach(p)
if p ~= LocalPlayer and IsKiller(p) and p.Character then
AttachParrySensor(p.Character)
end
end
function SetupPlayer(p)
if p == LocalPlayer or not HubRuntime.Alive then return end
_BH_FN.TrackConnection(p.CharacterAdded:Connect(function()
if HubRuntime.Alive then TryAttach(p) end
end))
_BH_FN.TrackConnection(p:GetPropertyChangedSignal("Team"):Connect(function()
if HubRuntime.Alive then TryAttach(p) end
end))
if p.Character then TryAttach(p) end
end
function _BH_FN.setNoClipPart(v)
if not v or not v:IsA("BasePart") then return end
if NoClipOriginal[v] == nil then NoClipOriginal[v] = v.CanCollide end
if v.CanCollide then v.CanCollide = false end
end
function _BH_FN.applyNoClip()
local char = LocalPlayer.Character
if Movement.NoClip then
if not char then return end
for _, v in ipairs(char:GetDescendants()) do
_BH_FN.setNoClipPart(v)
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
function _BH_FN.toggleNoClip(state)
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
_BH_FN.applyNoClip()
local char = LocalPlayer.Character
if char then
Connections.NoClipAdded = char.DescendantAdded:Connect(function(obj)
if Movement.NoClip then _BH_FN.setNoClipPart(obj) end
end)
end
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
_BH_FN.applyNoClip()
end
end
function _BH_FN.applyGodMode()
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
local FallRemote = nil
pcall(function()
local mechanics = Remotes:FindFirstChild("Mechanics")
local candidate = mechanics and mechanics:FindFirstChild("Fall")
if candidate and candidate:IsA("RemoteEvent") then FallRemote = candidate end
end)
function _BH_FN.addIndexed(list, indexMap, obj)
if indexMap[obj] then return end
list[#list + 1] = obj
indexMap[obj] = #list
end
function _BH_FN.removeIndexed(list, indexMap, obj)
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
function _BH_FN.registerESPObject(obj)
if not obj then return end
local name = obj.Name
local lowerName = string.lower(name)
if string.find(lowerName, "scp", 1, true) and not ESPCache.SCP[obj] then
ESPCache.SCP[obj] = true
_BH_FN.addIndexed(ESPCache.SCPList, ESPCache.SCPIndex, obj)
end
if name == "Generator" then
ESPCache.Generators[obj] = true
elseif name == "Window" then
if not ESPCache.Windows[obj] then
ESPCache.Windows[obj] = true
_BH_FN.addIndexed(ESPCache.WindowList, ESPCache.WindowIndex, obj)
end
elseif name == "Pallet" or name == "Palletwrong" then
if not ESPCache.Pallets[obj] then
ESPCache.Pallets[obj] = true
_BH_FN.addIndexed(ESPCache.PalletList, ESPCache.PalletIndex, obj)
end
elseif name == "Hook" and obj:IsA("Model") then
if not ESPCache.Hooks[obj] then
ESPCache.Hooks[obj] = true
_BH_FN.addIndexed(ESPCache.HookList, ESPCache.HookIndex, obj)
end
elseif name == "Gate" and obj:IsA("Model") then
if not ESPCache.Gates[obj] then
ESPCache.Gates[obj] = true
_BH_FN.addIndexed(ESPCache.GateList, ESPCache.GateIndex, obj)
end
end
end
local ESPScanState = { Running = false, Generation = 0, DelayTask = nil }
function _BH_FN.startIncrementalMapScan()
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
_BH_FN.registerESPObject(obj)
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
if HubRuntime.Alive then _BH_FN.startIncrementalMapScan() end
end)
_BH_FN.TrackConnection(workspace.DescendantAdded:Connect(function(obj)
if HubRuntime.Alive then _BH_FN.registerESPObject(obj) end
end))
function _BH_FN.removeESP(obj)
local h = ESPCache.Objects[obj]
if h then
_BH_FN.DestroyArtifact(h)
ESPCache.Objects[obj] = nil
end
end
function _BH_FN.ESP_GetCharacterState(
char,
hum
)
if not char
or not hum
or hum.Health <= 0 then
return "DEAD"
end
if char:GetAttribute("IsHooked") == true then
return "HOOKED"
end
if char:GetAttribute("IsCarried") == true then
return "CARRIED"
end
if hum.Health <= 50
or char:GetAttribute("Downed") == true
or char:GetAttribute("IsDown") == true
or char:GetAttribute("Knocked") == true then
return "DOWN"
end
return "NORMAL"
end
function _BH_FN.ESP_IsCharacterVisible(
originRoot,
char
)
if not originRoot
or not char
or not char.Parent then
return false
end
local myChar =
LocalPlayer.Character
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances =
myChar and {myChar} or {}
params.IgnoreWater = true
pcall(function()
params.RespectCanCollide = true
end)
local origin =
originRoot.Position
+ Vector3.new(0, 1.15, 0)
for _, name in ipairs({
"Head",
"UpperTorso",
"HumanoidRootPart",
}) do
local part =
char:FindFirstChild(name)
if part
and part:IsA("BasePart") then
local hit =
workspace:Raycast(
origin,
part.Position - origin,
params
)
if not hit
or hit.Instance:IsDescendantOf(
char
) then
return true
end
end
end
return false
end
function _BH_FN.ESP_GetAdaptiveStyle(
distance,
visible,
state
)
if ESPStyle.Mode == "Line"
or ESPStyle.Mode == "Outline" then
return 1, 0.02
end
local fill =
ESPStyle.FillTransparency
local outline =
ESPStyle.OutlineTransparency
if not ESPStyle.Adaptive then
return fill, outline
end
local d =
math.max(
0,
tonumber(distance) or 0
)
if d <= ESPStyle.NearDistance then
fill = fill - 0.035
outline = outline - 0.025
elseif d >= ESPStyle.MidDistance then
fill = fill + 0.025
outline = outline + 0.05
end
if visible == false then
fill = fill - 0.045
outline = outline - 0.045
end
if state == "DOWN"
or state == "HOOKED"
or state == "CARRIED" then
fill = fill + 0.025
outline = outline - 0.035
elseif state == "INJURED" then
outline = outline - 0.015
end
return math.clamp(
fill,
0.52,
1
),
math.clamp(
outline,
0,
1
)
end
function _BH_FN.ESP_GetOutlineColor(color)
local source = color or Color3.new(1, 1, 1)
return source:Lerp(
Color3.new(1, 1, 1),
ESPStyle.OutlineBrightness or 0.20
)
end
function _BH_FN.ESP_ApplyPlateStyle(label)
if not label or not label.Parent then
return
end
label.BackgroundTransparency = 1
label.BorderSizePixel = 0
label.ClipsDescendants = false
label.ZIndex = 2
for _, child in ipairs(label:GetChildren()) do
if child:IsA("UICorner")
or child:IsA("UIStroke") then
child:Destroy()
end
end
local oldGradient =
label:FindFirstChild("ESPPlateEdgeFade")
if oldGradient then
oldGradient:Destroy()
end
local plate =
label:FindFirstChild("ESPPlateBackground")
if plate and not plate:IsA("Frame") then
plate:Destroy()
plate = nil
end
if not plate then
plate = Instance.new("Frame")
plate.Name = "ESPPlateBackground"
plate.Parent = label
end
plate.Size = UDim2.new(1, 0, 1, 0)
plate.Position = UDim2.new(0, 0, 0, 0)
plate.BackgroundColor3 = ESPStyle.PlateColor
plate.BackgroundTransparency =
ESPStyle.PlateTransparency
plate.BorderSizePixel = 0
plate.ZIndex = 1
local gradient =
plate:FindFirstChild("ESPPlateEdgeFade")
if not gradient
or not gradient:IsA("UIGradient") then
if gradient then
gradient:Destroy()
end
gradient = Instance.new("UIGradient")
gradient.Name = "ESPPlateEdgeFade"
gradient.Rotation = 0
gradient.Parent = plate
end
gradient.Color = ColorSequence.new(
ESPStyle.PlateColor,
ESPStyle.PlateColor
)
gradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(
0,
ESPStyle.PlateEdgeTransparency
),
NumberSequenceKeypoint.new(0.10, 0),
NumberSequenceKeypoint.new(0.90, 0),
NumberSequenceKeypoint.new(
1,
ESPStyle.PlateEdgeTransparency
),
})
local fadeTransparency = {
0.58,
0.74,
0.90,
}
for index, transparency in ipairs(fadeTransparency) do
local fadeName =
"ESPPlateBottomFade" .. tostring(index)
local fade =
label:FindFirstChild(fadeName)
if fade and not fade:IsA("Frame") then
fade:Destroy()
fade = nil
end
if not fade then
fade = Instance.new("Frame")
fade.Name = fadeName
fade.Parent = label
end
fade.Size = UDim2.new(0.90, 0, 0, 2)
fade.Position = UDim2.new(
0.05,
0,
1,
(index - 1) * 2
)
fade.BackgroundColor3 = ESPStyle.PlateColor
fade.BackgroundTransparency = transparency
fade.BorderSizePixel = 0
fade.ZIndex = 1
local fadeGradient =
fade:FindFirstChild("ESPPlateFadeEdge")
if not fadeGradient
or not fadeGradient:IsA("UIGradient") then
if fadeGradient then
fadeGradient:Destroy()
end
fadeGradient = Instance.new("UIGradient")
fadeGradient.Name = "ESPPlateFadeEdge"
fadeGradient.Rotation = 0
fadeGradient.Parent = fade
end
fadeGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(0.16, 0),
NumberSequenceKeypoint.new(0.84, 0),
NumberSequenceKeypoint.new(1, 1),
})
end
end
function _BH_FN.ESP_RemovePlateStyle(label)
if not label or not label.Parent then
return
end
label.BackgroundTransparency = 1
label.BorderSizePixel = 0
label.ClipsDescendants = false
for _, child in ipairs(label:GetChildren()) do
local name = child.Name
if name == "ESPPlateBackground"
or name == "ESPPlateEdgeFade"
or string.sub(name, 1, 18)
== "ESPPlateBottomFade"
or child:IsA("UICorner")
or child:IsA("UIStroke") then
child:Destroy()
end
end
end
function _BH_FN.ESP_ApplyHighlightStyle(
h,
color,
profile
)
if not h or not h.Parent then
return
end
profile =
profile or {}
local fill,
outline =
_BH_FN.ESP_GetAdaptiveStyle(
profile.Distance,
profile.Visible,
profile.State
)
if h.FillColor ~= color then
h.FillColor = color
end
local outlineColor =
_BH_FN.ESP_GetOutlineColor(color)
if h.OutlineColor ~= outlineColor then
h.OutlineColor = outlineColor
end
if h.FillTransparency ~= fill then
h.FillTransparency = fill
end
if h.OutlineTransparency ~= outline then
h.OutlineTransparency = outline
end
end
function _BH_FN.createESP(
obj,
color,
profile
)
if not obj
or not obj.Parent then
return
end
local h =
ESPCache.Objects[obj]
if h and h.Parent then
_BH_FN.ESP_ApplyHighlightStyle(
h,
color,
profile
)
return
end
local adornee = obj
if not obj:IsA("Model")
and not obj:IsA("BasePart") then
adornee =
obj:FindFirstChildWhichIsA(
"BasePart",
true
)
or obj:FindFirstAncestorOfClass(
"Model"
)
end
if not adornee then
return
end
h =
_BH_FN.TrackArtifact(
Instance.new("Highlight")
)
h.Name = "BluehavenESP"
h.Adornee = adornee
h.DepthMode =
Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = obj
ESPCache.Objects[obj] = h
_BH_FN.ESP_ApplyHighlightStyle(
h,
color,
profile
)
end
function _BH_FN.removeStatusESP(char)
local billboard = ESPCache.Status[char]
if billboard then
_BH_FN.DestroyArtifact(billboard)
ESPCache.Status[char] = nil
end
end
function _BH_FN.removeGeneratorVisual(generator)
local state = ESPVisualState.Generator[generator]
if state then
if state.Billboard then _BH_FN.DestroyArtifact(state.Billboard) end
if state.Highlight then _BH_FN.DestroyArtifact(state.Highlight) end
ESPVisualState.Generator[generator] = nil
else
local old = generator and generator:FindFirstChild("GenESP")
if old then old:Destroy() end
local h = generator and generator:FindFirstChild("GenHighlight")
if h then h:Destroy() end
end
end
function _BH_FN.clearESPSet(set)
for obj in pairs(set) do _BH_FN.removeESP(obj) end
end
function _BH_FN.clearAllStatusESP()
for char in pairs(ESPCache.Status) do _BH_FN.removeStatusESP(char) end
end
function _BH_FN.clearPlayerTeamESP(roleName)
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer
and _BH_FN.AIM_GetRole(p) == roleName
and p.Character then
_BH_FN.removeESP(p.Character)
_BH_FN.removeStatusESP(p.Character)
end
end
end
function _BH_FN.clearGeneratorESP()
for generator in pairs(ESPCache.Generators) do
if generator then _BH_FN.removeGeneratorVisual(generator) end
end
end
local ESPRoleGate = {
Blocked = false,
}
function _BH_FN.ESP_LocalCanRender()
local role =
_BH_FN.AIM_GetRole(LocalPlayer)
return role == "Survivor"
or role == "Killer"
end
function _BH_FN.ESP_ClearAllVisualsForLobby()
local objects = {}
for obj in pairs(
ESPCache.Objects
) do
objects[#objects + 1] = obj
end
for _, obj in ipairs(objects) do
_BH_FN.removeESP(obj)
end
_BH_FN.clearAllStatusESP()
_BH_FN.clearGeneratorESP()
end
function _BH_FN.ESP_UpdateLocalRoleGate()
local allowed =
_BH_FN.ESP_LocalCanRender()
if not allowed then
if not ESPRoleGate.Blocked then
ESPRoleGate.Blocked = true
pcall(
_BH_FN.ESP_ClearAllVisualsForLobby
)
end
return false
end
if ESPRoleGate.Blocked then
ESPRoleGate.Blocked = false
Timers.lastPlayerESP = 0
Timers.lastStatusESP = 0
Timers.lastGeneratorESP = 0
Timers.lastWindowESP = 0
Timers.lastPalletESP = 0
Timers.lastHookESP = 0
Timers.lastSCPEsp = 0
end
return true
end
function _BH_FN.GetHeldItem(char)
if not char then return nil end
for _, obj in ipairs(char:GetChildren()) do
if ESPItems[obj.Name] then return obj.Name end
end
return nil
end
function _BH_FN.GetGameValue(obj, name)
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
function _BH_FN.distSq(a, b)
local dx = a.X - b.X
local dy = a.Y - b.Y
local dz = a.Z - b.Z
return dx * dx + dy * dy + dz * dz
end
function _BH_FN.getObjectPosition(obj, cacheStatic)
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
function _BH_FN.ensureGeneratorState(generator)
local state = ESPVisualState.Generator[generator]
if state then return state end
state = {
LastPercent = nil,
LastColor = nil,
Adornee = nil,
}
ESPVisualState.Generator[generator] = state
return state
end
function _BH_FN.ESP_GetGeneratorAdornee(generator)
if not generator then return nil end
if generator:IsA("BasePart") then
return generator
end
if generator:IsA("Model") then
local main =
generator:FindFirstChild(
"GeneratorBody",
true
)
or generator:FindFirstChild(
"Main",
true
)
or generator.PrimaryPart
if main and main:IsA("BasePart") then
return main
end
end
return generator:FindFirstChildWhichIsA(
"BasePart",
true
)
end
function _BH_FN.ensureGenHighlight(
generator,
state,
color,
distance
)
local h =
state.Highlight
if not h or not h.Parent then
h =
_BH_FN.TrackArtifact(
Instance.new("Highlight")
)
h.Name = "GenHighlight"
h.Adornee = generator
h.DepthMode =
Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = generator
state.Highlight = h
end
_BH_FN.ESP_ApplyHighlightStyle(
h,
color,
{
Distance = distance,
Visible = nil,
State = "NORMAL",
}
)
end
function _BH_FN.CreateBillboard(text, color)
local billboard = _BH_FN.TrackArtifact(Instance.new("BillboardGui"))
billboard.Name = "GenESP"
billboard.Size = UDim2.fromOffset(
ESPStyle.GeneratorWidth,
ESPStyle.GeneratorHeight
)
billboard.AlwaysOnTop = true
billboard.MaxDistance = ESP.Distance
billboard.StudsOffset = Vector3.new(0, 0, 0)
billboard.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
billboard.SizeOffset = Vector2.new(0, 0)
billboard.LightInfluence = 0
local label = Instance.new("TextLabel")
label.Name = "Value"
label.Size = UDim2.new(1, 0, 1, 0)
label.RichText = true
label.Text = text
label.TextColor3 = color
label.TextStrokeTransparency = 0.90
label.Font = Enum.Font.GothamMedium
label.TextSize = 12
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)
padding.Parent = label
label.Parent = billboard
_BH_FN.ESP_ApplyPlateStyle(label)
return billboard, label
end
function _BH_FN.ESP_GetGeneratorWorldOffset(
generator,
adornee
)
return Vector3.new(
0,
ESPStyle.GeneratorOffset,
0
)
end
function _BH_FN.ESP_FormatGeneratorText(percent, color)
return string.format(
'<font color="#FFFFFF">GEN </font><font color="%s">%d%%</font>',
_BH_FN.colorToHex(color),
percent
)
end
function _BH_FN.UpdateGenerator(generator, root)
if not ESP.Generator or not generator or not generator.Parent then return end
local currentRoot = root or getRoot()
local pos = _BH_FN.getObjectPosition(generator, false)
if not currentRoot or not pos
or _BH_FN.distSq(pos, currentRoot.Position) > (ESP.Distance * ESP.Distance) then
_BH_FN.removeGeneratorVisual(generator)
return
end
local percent = _BH_FN.GetGameValue(generator, "RepairProgress") or _BH_FN.GetGameValue(generator, "Progress") or 0
local rounded = math.floor((tonumber(percent) or 0) + 0.5)
if rounded >= 100 then
_BH_FN.removeGeneratorVisual(generator)
return
end
local color = GeneratorColor
local state = _BH_FN.ensureGeneratorState(generator)
local generatorDistance =
(pos - currentRoot.Position).Magnitude
_BH_FN.ensureGenHighlight(
generator,
state,
color,
generatorDistance
)
if not state.Billboard or not state.Billboard.Parent then
local billboard, label = _BH_FN.CreateBillboard(
_BH_FN.ESP_FormatGeneratorText(rounded, color),
color
)
local adornee =
_BH_FN.ESP_GetGeneratorAdornee(
generator
)
if adornee then
billboard.Adornee = adornee
billboard.StudsOffsetWorldSpace =
_BH_FN.ESP_GetGeneratorWorldOffset(
generator,
adornee
)
billboard.Parent = generator
state.Billboard = billboard
state.Label = label
state.Adornee = adornee
else
_BH_FN.DestroyArtifact(billboard)
end
elseif rounded ~= state.LastPercent or state.LastColor ~= color then
local label = state.Label or state.Billboard:FindFirstChild("Value")
if label then
local newText =
_BH_FN.ESP_FormatGeneratorText(
rounded,
color
)
if label.Text ~= newText then label.Text = newText end
if label.TextColor3 ~= color then label.TextColor3 = color end
_BH_FN.ESP_ApplyPlateStyle(label)
state.Label = label
end
end
if state.Billboard and state.Billboard.Parent then
local currentAdornee =
_BH_FN.ESP_GetGeneratorAdornee(
generator
)
if currentAdornee
and state.Billboard.Adornee
~= currentAdornee then
state.Billboard.Adornee =
currentAdornee
state.Adornee = currentAdornee
end
local desiredSize = UDim2.fromOffset(
ESPStyle.GeneratorWidth,
ESPStyle.GeneratorHeight
)
if state.Billboard.Size ~= desiredSize then
state.Billboard.Size = desiredSize
end
local desiredOffset =
Vector3.new(0, 0, 0)
if state.Billboard.StudsOffset ~= desiredOffset then
state.Billboard.StudsOffset = desiredOffset
end
local billboardAdornee =
state.Billboard.Adornee
local desiredWorldOffset =
_BH_FN.ESP_GetGeneratorWorldOffset(
generator,
billboardAdornee
)
if state.Billboard.StudsOffsetWorldSpace
~= desiredWorldOffset then
state.Billboard.StudsOffsetWorldSpace =
desiredWorldOffset
end
if state.Billboard.SizeOffset
~= Vector2.new(0, 0) then
state.Billboard.SizeOffset =
Vector2.new(0, 0)
end
local label =
state.Label
or state.Billboard:FindFirstChild("Value")
if label then
_BH_FN.ESP_ApplyPlateStyle(label)
state.Label = label
end
end
state.LastPercent = rounded
state.LastColor = color
end
function _BH_FN.ESP_IsObviouslyUnavailableMapObject(
obj,
kind
)
if not obj or not obj.Parent then
return true
end
if obj:GetAttribute("Destroyed") == true
or obj:GetAttribute("IsDestroyed") == true then
return true
end
if kind == "Pallet"
and (
obj:GetAttribute("Broken") == true
or obj:GetAttribute("IsBroken") == true
) then
return true
end
return false
end
function _BH_FN.UpdateMapESP(
obj,
root,
kind
)
if not obj
or not root
or not obj.Parent then
return
end
local enabled =
(kind == "Window" and ESP.Window)
or (kind == "Pallet" and ESP.Pallet)
or (kind == "Hook" and ESP.Hook)
if not enabled
or _BH_FN.ESP_IsObviouslyUnavailableMapObject(
obj,
kind
) then
_BH_FN.removeESP(obj)
return
end
local pos =
_BH_FN.getObjectPosition(
obj,
kind == "Window"
)
if not pos then
_BH_FN.removeESP(obj)
return
end
local distance =
(pos - root.Position).Magnitude
if distance <= ESP.Distance then
local color =
kind == "Window"
and WindowColor
or kind == "Hook"
and HookColor
or PalletColor
_BH_FN.createESP(
obj,
color,
{
Distance = distance,
Visible = nil,
State = "NORMAL",
}
)
else
_BH_FN.removeESP(obj)
end
end
function _BH_FN.isStatusESPEnabled()
return ESPStatus.ShowName
or ESPStatus.ShowHealth
or ESPStatus.ShowItem
end
function _BH_FN.colorToHex(color)
return string.format(
"#%02X%02X%02X",
math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
)
end
function _BH_FN.escapeRichText(value)
local s = tostring(value or "")
s = s:gsub("&", "&amp;")
s = s:gsub("<", "&lt;")
s = s:gsub(">", "&gt;")
return s
end
function _BH_FN.richLine(color, value)
return string.format('<font color="%s">%s</font>', _BH_FN.colorToHex(color), _BH_FN.escapeRichText(value))
end
function _BH_FN.createStatusESP(
player,
char,
root
)
if not _BH_FN.ESP_LocalCanRender() then
if char then
_BH_FN.removeStatusESP(char)
end
return
end
if _BH_FN.TAD_IsPistolAiming() then
if char then
_BH_FN.removeStatusESP(char)
end
return
end
if not _BH_FN.isStatusESPEnabled()
or not root
or not char then
if char then
_BH_FN.removeStatusESP(char)
end
return
end
local head =
char:FindFirstChild("Head")
local hum =
char:FindFirstChildOfClass(
"Humanoid"
)
if not head or not hum then
_BH_FN.removeStatusESP(char)
return
end
local state =
_BH_FN.ESP_GetCharacterState(
char,
hum
)
if state == "DEAD" then
_BH_FN.removeStatusESP(char)
return
end
local distance =
(head.Position - root.Position).Magnitude
if distance > ESPStatus.Radius then
_BH_FN.removeStatusESP(char)
return
end
local lines = {}
if ESPStatus.ShowName then
local isKiller = player.Team
and string.find(
string.lower(player.Team.Name),
"killer",
1,
true
) ~= nil
lines[#lines + 1] =
_BH_FN.richLine(
isKiller
and TeamColors.Killer
or TeamColors.Survivor,
player.DisplayName ~= ""
and player.DisplayName
or player.Name
)
end
if state == "DOWN" then
lines[#lines + 1] =
_BH_FN.richLine(
StatusDownColor,
"DOWN"
)
elseif state == "HOOKED" then
lines[#lines + 1] =
_BH_FN.richLine(
StatusColors.Hooked,
"HOOKED"
)
elseif state == "CARRIED" then
lines[#lines + 1] =
_BH_FN.richLine(
StatusColors.Carried,
"CARRIED"
)
end
if ESPStatus.ShowHealth then
local healthColor =
state == "DOWN"
and StatusDownColor
or StatusColors.Health
lines[#lines + 1] =
_BH_FN.richLine(
healthColor,
string.format(
"HP: %.0f",
hum.Health
)
)
end
if ESPStatus.ShowItem then
local item =
_BH_FN.GetHeldItem(char)
if item then
lines[#lines + 1] =
_BH_FN.richLine(
StatusColors.Item,
"Item: " .. item
)
end
end
if #lines == 0 then
_BH_FN.removeStatusESP(char)
return
end
local textValue =
table.concat(
lines,
"\n"
)
local scaleStart = ESPStyle.StatusScaleStart
local scaleRange =
math.max(1, ESPStatus.Radius - scaleStart)
local scaleAlpha =
math.clamp(
(distance - scaleStart) / scaleRange,
0,
1
)
local statusScale =
1 - scaleAlpha
* (1 - ESPStyle.StatusMinScale)
local statusWidth =
math.max(
68,
math.floor(
ESPStyle.StatusWidth
* statusScale
+ 0.5
)
)
local statusHeight =
math.max(
12,
math.floor(
(
ESPStyle.StatusBaseHeight
+ (#lines * ESPStyle.StatusLineHeight)
)
* statusScale
+ 0.5
)
)
local statusTextSize =
math.max(
9,
math.floor(
ESPStyle.StatusTextSize
* statusScale
+ 0.5
)
)
local billboard =
ESPCache.Status[char]
if not billboard
or not billboard.Parent then
billboard =
_BH_FN.TrackArtifact(
Instance.new("BillboardGui")
)
billboard.Name =
"BluehavenStatusESP"
billboard.Size =
UDim2.fromOffset(
statusWidth,
statusHeight
)
billboard.AlwaysOnTop = true
billboard.LightInfluence = 0
billboard.MaxDistance =
ESPStatus.Radius
billboard.Adornee = head
billboard.StudsOffset =
Vector3.new(0, 0, 0)
billboard.StudsOffsetWorldSpace =
Vector3.new(
0,
ESPStyle.StatusWorldOffset,
0
)
billboard.SizeOffset = Vector2.new(0, 0)
local label =
Instance.new("TextLabel")
label.Name = "Value"
label.Size =
UDim2.new(
1,
0,
1,
0
)
local padding =
Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)
padding.PaddingTop = UDim.new(0, 2)
padding.PaddingBottom = UDim.new(0, 2)
padding.Parent = label
label.RichText = true
label.TextColor3 =
Color3.new(1, 1, 1)
label.TextStrokeTransparency =
0.90
label.Font =
Enum.Font.GothamMedium
label.TextSize = statusTextSize
label.TextScaled = false
label.TextWrapped = true
label.TextXAlignment =
Enum.TextXAlignment.Center
label.TextYAlignment =
Enum.TextYAlignment.Center
label.Text = textValue
label.Parent = billboard
_BH_FN.ESP_RemovePlateStyle(label)
billboard.Parent = char
ESPCache.Status[char] =
billboard
else
local desiredSize =
UDim2.fromOffset(
statusWidth,
statusHeight
)
if billboard.Size ~= desiredSize then
billboard.Size = desiredSize
end
if billboard.MaxDistance
~= ESPStatus.Radius then
billboard.MaxDistance =
ESPStatus.Radius
end
if billboard.Adornee ~= head then
billboard.Adornee = head
end
local desiredOffset =
Vector3.new(0, 0, 0)
if billboard.StudsOffset
~= desiredOffset then
billboard.StudsOffset =
desiredOffset
end
local desiredWorldOffset =
Vector3.new(
0,
ESPStyle.StatusWorldOffset,
0
)
if billboard.StudsOffsetWorldSpace
~= desiredWorldOffset then
billboard.StudsOffsetWorldSpace =
desiredWorldOffset
end
if billboard.SizeOffset
~= Vector2.new(0, 0) then
billboard.SizeOffset =
Vector2.new(0, 0)
end
local label =
billboard:FindFirstChild(
"Value"
)
or billboard:FindFirstChildOfClass(
"TextLabel"
)
if label then
label.RichText = true
label.TextSize = statusTextSize
label.TextScaled = false
_BH_FN.ESP_RemovePlateStyle(label)
if label.Text ~= textValue then
label.Text = textValue
end
end
end
end
function _BH_FN.UpdateSCPEsp(root)
if not ESP.SCP or not root then return end
local rangeSq = ESP.Distance * ESP.Distance
for _, obj in ipairs(ESPCache.SCPList) do
if obj and ESPCache.SCP[obj] and obj.Parent then
local pos = _BH_FN.getObjectPosition(obj, false)
if pos and _BH_FN.distSq(pos, root.Position) <= rangeSq then
local distance =
(pos - root.Position).Magnitude
_BH_FN.createESP(
obj,
SCPColor,
{
Distance = distance,
Visible = nil,
State = "NORMAL",
}
)
else
_BH_FN.removeESP(obj)
end
end
end
end
function _BH_FN.processMapBatch(list, set, root, kind, cursorField)
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
_BH_FN.UpdateMapESP(obj, root, kind)
end
end
ESPPerf[cursorField] = cursor
end
_BH_FN.TrackConnection(workspace.DescendantRemoving:Connect(function(obj)
if not HubRuntime.Alive then return end
ESPVisualState.WindowPos[obj] = nil
if ESPCache.SCP[obj] then
ESPCache.SCP[obj] = nil
_BH_FN.removeIndexed(ESPCache.SCPList, ESPCache.SCPIndex, obj)
end
if ESPCache.Windows[obj] then
ESPCache.Windows[obj] = nil
_BH_FN.removeIndexed(ESPCache.WindowList, ESPCache.WindowIndex, obj)
end
if ESPCache.Pallets[obj] then
ESPCache.Pallets[obj] = nil
_BH_FN.removeIndexed(ESPCache.PalletList, ESPCache.PalletIndex, obj)
end
if ESPCache.Hooks[obj] then
ESPCache.Hooks[obj] = nil
_BH_FN.removeIndexed(ESPCache.HookList, ESPCache.HookIndex, obj)
end
if ESPCache.Gates[obj] then
ESPCache.Gates[obj] = nil
_BH_FN.removeIndexed(ESPCache.GateList, ESPCache.GateIndex, obj)
end
if ESPCache.Generators[obj] then
ESPCache.Generators[obj] = nil
_BH_FN.removeGeneratorVisual(obj)
end
_BH_FN.removeESP(obj)
if ESPCache.Status[obj] then _BH_FN.removeStatusESP(obj) end
end))
function _BH_FN.TeleportToGenerator()
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
_BH_FN.TeleportToPart(part)
end
TeleportIndex.Generator = TeleportIndex.Generator + 1
end
function _BH_FN.nextCachedObject(list, set, indexName)
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
function _BH_FN.TeleportToHook()
local hook = _BH_FN.nextCachedObject(ESPCache.HookList, ESPCache.Hooks, "Hook")
if not hook then
Library:Notify({Title = "TP Hook", Description = "Hook belum ter-cache. Coba Refresh Map.", Time = 2})
return
end
local part = hook:FindFirstChild("HookPoint") or hook:FindFirstChildWhichIsA("BasePart")
if part then _BH_FN.TeleportToPart(part) end
end
function _BH_FN.TeleportToGate()
local gate = _BH_FN.nextCachedObject(ESPCache.GateList, ESPCache.Gates, "Gate")
if not gate then
Library:Notify({Title = "TP Gate", Description = "Gate belum ter-cache. Coba Refresh Map.", Time = 2})
return
end
local part = gate:FindFirstChildWhichIsA("BasePart")
if part then _BH_FN.TeleportToPart(part) end
end
function _BH_FN.TeleportToPallet()
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
if part then _BH_FN.TeleportToPart(part) end
TeleportIndex.Pallet = TeleportIndex.Pallet + 1
end
function _BH_FN.SH_DisconnectOne(connection)
if not connection then
return
end
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
end
local SELF_HEAL_ANIMATION_HINTS = {
"heal",
"healing",
"selfheal",
"bandage",
"medic",
"medical",
"treat",
"recover",
"firstaid",
}
local SELF_HEAL_ANIMATION_EXCLUDES = {
"walk",
"run",
"idle",
"jump",
"fall",
"land",
"vault",
"slide",
"crouch",
"sprint",
"attack",
"slash",
"lunge",
"swing",
"parry",
"stun",
"knock",
"down",
"hook",
"carry",
"emote",
}
function _BH_FN.SH_GetTrackDescriptor(track)
local values = {}
pcall(function()
values[#values + 1] =
tostring(track.Name or "")
end)
pcall(function()
local animation = track.Animation
if animation then
values[#values + 1] =
tostring(animation.Name or "")
end
end)
return string.lower(
table.concat(values, " ")
)
end
function _BH_FN.SH_IsLikelyHealTrack(track)
if not track
or SelfHeal.BaselineTracks[track] then
return false
end
local char = LocalPlayer.Character
local localRoot =
char
and char:FindFirstChild("HumanoidRootPart")
if not SelfHeal.Running
or SelfHeal.TargetRoot ~= localRoot then
return false
end
if SelfHeal.HiddenHealTracks[track] then
return true
end
local descriptor =
_BH_FN.SH_GetTrackDescriptor(track)
for _, hint in ipairs(
SELF_HEAL_ANIMATION_HINTS
) do
if string.find(
descriptor,
hint,
1,
true
) then
return true
end
end
for _, excluded in ipairs(
SELF_HEAL_ANIMATION_EXCLUDES
) do
if string.find(
descriptor,
excluded,
1,
true
) then
return false
end
end
if os.clock()
> SelfHeal.AnimationSuppressUntil then
return false
end
local priority = nil
pcall(function()
priority = track.Priority
end)
return priority == Enum.AnimationPriority.Action
or priority == Enum.AnimationPriority.Action2
or priority == Enum.AnimationPriority.Action3
or priority == Enum.AnimationPriority.Action4
end
function _BH_FN.SH_HideHealTrack(track)
if not track then
return
end
SelfHeal.HiddenHealTracks[track] = true
pcall(function()
if track.IsPlaying then
track:AdjustWeight(0, 0)
end
end)
end
function _BH_FN.SH_ScanHealAnimations()
if not SelfHeal.Running
or not SelfHeal.Animator then
return
end
local ok, tracks = pcall(function()
return SelfHeal.Animator:GetPlayingAnimationTracks()
end)
if not ok or not tracks then
return
end
for _, track in ipairs(tracks) do
if SelfHeal.HiddenHealTracks[track]
or _BH_FN.SH_IsLikelyHealTrack(track) then
_BH_FN.SH_HideHealTrack(track)
end
end
end
function _BH_FN.SH_StopAnimationGuard()
for _, key in ipairs({
"AnimationPlayedConnection",
"AnimationGuardConnection",
}) do
local connection = SelfHeal[key]
if connection then
_BH_FN.SH_DisconnectOne(connection)
SelfHeal[key] = nil
end
end
for track in pairs(SelfHeal.HiddenHealTracks) do
pcall(function()
if track.IsPlaying then
track:Stop(0)
end
end)
end
table.clear(SelfHeal.BaselineTracks)
table.clear(SelfHeal.HiddenHealTracks)
SelfHeal.Animator = nil
SelfHeal.AnimationSuppressUntil = 0
end
function _BH_FN.SH_StartAnimationGuard(
char,
humanoid,
generation
)
_BH_FN.SH_StopAnimationGuard()
if not char
or not humanoid then
return
end
local animator =
humanoid:FindFirstChildOfClass(
"Animator"
)
if not animator then
animator = humanoid:WaitForChild(
"Animator",
1
)
end
if not animator then
return
end
SelfHeal.Animator = animator
local ok, existingTracks = pcall(function()
return animator:GetPlayingAnimationTracks()
end)
if ok and existingTracks then
for _, track in ipairs(existingTracks) do
SelfHeal.BaselineTracks[track] = true
end
end
SelfHeal.AnimationPlayedConnection =
_BH_FN.TrackConnection(
animator.AnimationPlayed:Connect(function(track)
if not SelfHeal.Running
or generation
~= SelfHeal.Generation then
return
end
if _BH_FN.SH_IsLikelyHealTrack(track) then
_BH_FN.SH_HideHealTrack(track)
end
task.defer(function()
if SelfHeal.Running
and generation
== SelfHeal.Generation then
_BH_FN.SH_ScanHealAnimations()
end
end)
end)
)
local accumulator = 0
SelfHeal.AnimationGuardConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function(dt)
if not HubRuntime.Alive
or not SelfHeal.Running
or generation
~= SelfHeal.Generation
or LocalPlayer.Character
~= char then
_BH_FN.SH_StopAnimationGuard()
return
end
accumulator = accumulator + dt
if accumulator
< SelfHeal.AnimationScanInterval then
return
end
accumulator = 0
_BH_FN.SH_ScanHealAnimations()
end)
)
end
function _BH_FN.SH_MarkAnimationWindow(
generation,
duration
)
if not SelfHeal.Running
or generation
~= SelfHeal.Generation then
return
end
SelfHeal.AnimationSuppressUntil = math.max(
SelfHeal.AnimationSuppressUntil,
os.clock() + (tonumber(duration) or 1.5)
)
_BH_FN.SH_ScanHealAnimations()
task.defer(function()
if SelfHeal.Running
and generation
== SelfHeal.Generation then
_BH_FN.SH_ScanHealAnimations()
end
end)
end
function _BH_FN.SH_ClearConnections()
_BH_FN.SH_StopAnimationGuard()
for _, key in ipairs({
"HealAnimConnection",
"HealAnimRecConnection",
"StopConnection",
"DoneConnection",
"HealthConnection",
}) do
local connection =
SelfHeal[key]
if connection then
_BH_FN.SH_DisconnectOne(connection)
SelfHeal[key] = nil
end
end
end
function _BH_FN.SH_StopMonitor()
for _, key in ipairs({
"MonitorConnection",
"HealthWatchConnection",
"CharacterWatchConnection",
}) do
local connection = SelfHeal[key]
if connection then
_BH_FN.SH_DisconnectOne(connection)
SelfHeal[key] = nil
end
end
end
function _BH_FN.SH_GetRemotes()
local remotes =
ReplicatedStorage:FindFirstChild(
"Remotes"
)
if not remotes then
return nil
end
local function findNamed(parent, ...)
if not parent then return nil end
local names = {...}
for _, name in ipairs(names) do
local exact = parent:FindFirstChild(name)
if exact then return exact end
end
for _, child in ipairs(parent:GetChildren()) do
local lower = string.lower(child.Name)
for _, name in ipairs(names) do
if lower == string.lower(name) then
return child
end
end
end
return nil
end
local healing =
findNamed(remotes, "Healing", "Heal")
if not healing then
return nil
end
return {
HealEvent =
findNamed(healing, "HealEvent", "Heal"),
HealAnim =
findNamed(healing, "HealAnim"),
HealAnimRec =
findNamed(healing, "HealAnimRec"),
Stophealing =
findNamed(
healing,
"Stophealing",
"StopHealing"
),
Healdone =
findNamed(
healing,
"Healdone",
"HealDone"
),
}
end
function _BH_FN.SH_GetCharacter()
local char =
LocalPlayer.Character
if not char then
return nil
end
return char,
char:FindFirstChildOfClass(
"Humanoid"
),
char:FindFirstChild(
"HumanoidRootPart"
),
_BH_FN.GB_GetClientInteract()
end
function _BH_FN.SH_ShouldHeal(humanoid)
if not humanoid
or humanoid.Health <= 0
or humanoid.MaxHealth <= 0 then
return false
end
local threshold =
humanoid.MaxHealth
* SelfHeal.HealthRatioThreshold
local injured =
humanoid.Health
< humanoid.MaxHealth - 0.01
if not injured then
return false
end
return humanoid.Health <= threshold + 0.01
or _BH_FN.SH_IsDownedState(
humanoid.Parent,
humanoid
)
end
function _BH_FN.SH_IsDownedState(
char,
humanoid
)
if not char
or not humanoid
or humanoid.Health <= 0 then
return false
end
if humanoid.Health
<= humanoid.MaxHealth
* SelfHeal.HealthRatioThreshold
+ 0.01 then
return true
end
for _, attribute in ipairs({
"Knocked",
"Downed",
"IsDown",
"IsKnocked",
}) do
if char:GetAttribute(attribute) == true then
return true
end
end
local ragdoll =
char:FindFirstChild("RagdollTrigger")
return ragdoll ~= nil
and ragdoll:IsA("BoolValue")
and ragdoll.Value == true
end
function _BH_FN.SH_IsBusy(
char,
humanoid,
root,
interact
)
if not char
or not humanoid
or not root
or humanoid.Health <= 0 then
return true
end
local downed =
_BH_FN.SH_IsDownedState(
char,
humanoid
)
if root.Anchored and not downed then
return true
end
if GetRole() ~= "Survivor" then
return true
end
if char:GetAttribute("IsCarried")
or char:GetAttribute("IsHooked") then
return true
end
if not downed
and humanoid.MoveDirection.Magnitude > 0.05 then
return true
end
if interact then
for _, attr in ipairs({
"isRepairing",
"isVaulting",
"isSliding",
"isDroppingPallet",
"isUnhooking",
"isExiting",
}) do
if interact:GetAttribute(attr) then
return true
end
end
if not downed
and interact:GetAttribute("isHealing") then
return true
end
end
return false
end
function _BH_FN.SH_SetClientState(
interact,
state
)
if not interact then
return
end
pcall(function()
interact:SetAttribute(
"isHealing",
state == true
)
end)
end
function _BH_FN.SH_HasClientHealState(
targetRoot
)
local char, _, root, interact =
_BH_FN.SH_GetCharacter()
if not char
or not root
or root ~= targetRoot then
return false
end
if interact then
for _, attribute in ipairs({
"isHealing",
"IsHealing",
"healing",
"Healing",
}) do
if interact:GetAttribute(attribute) == true then
return true
end
end
end
local context =
type(_BH_FN.GB_FindControllerContext) == "function"
and _BH_FN.GB_FindControllerContext()
or nil
local state =
context and context.state
if type(state) ~= "table" then
return false
end
if state.currentHealPoint == targetRoot then
return true
end
local action =
string.lower(
tostring(
state.activeMouseAction
or ""
)
)
return string.find(
action,
"heal",
1,
true
) ~= nil
end
function _BH_FN.SH_SetToggleOff()
task.defer(function()
local toggle =
Toggles
and Toggles["Self Heal"]
if toggle
and toggle.Value then
toggle:SetValue(false)
end
end)
end
function _BH_FN.SH_Stop(
sendRemote,
reason,
silent,
disableToggle
)
local wasRunning =
SelfHeal.Running
local shouldDisable =
disableToggle == true
SelfHeal.Generation = SelfHeal.Generation + 1
SelfHeal.Running = false
SelfHeal.Accepted = false
SelfHeal.RetryAt = os.clock() + 0.35
if shouldDisable then
SelfHeal.Enabled = false
end
local target =
SelfHeal.TargetRoot
local targetCharacter =
SelfHeal.TargetCharacter
local ownedClientState =
SelfHeal.ClientStateOwned == true
SelfHeal.TargetRoot = nil
SelfHeal.TargetCharacter = nil
SelfHeal.ClientStateOwned = false
local remotes =
_BH_FN.SH_GetRemotes()
local currentCharacter, _, _, interact =
_BH_FN.SH_GetCharacter()
if wasRunning
and ownedClientState
and currentCharacter == targetCharacter then
_BH_FN.SH_SetClientState(
interact,
false
)
end
if sendRemote
and target
and target.Parent
and remotes
and remotes.HealEvent
and remotes.HealEvent:IsA(
"RemoteEvent"
) then
pcall(function()
remotes.HealEvent:FireServer(
target,
false
)
end)
end
_BH_FN.SH_ClearConnections()
if wasRunning
and reason
and not silent then
Library:Notify({
Title = "Self Heal",
Description = reason,
Time = 2
})
end
if shouldDisable then
_BH_FN.SH_StopMonitor()
_BH_FN.SH_SetToggleOff()
end
end
function _BH_FN.SH_Accept(
generation
)
if not SelfHeal.Running
or generation
~= SelfHeal.Generation then
return
end
SelfHeal.Accepted = true
local _, _, _, interact =
_BH_FN.SH_GetCharacter()
local nativeStateWasActive = false
if interact then
pcall(function()
nativeStateWasActive =
interact:GetAttribute(
"isHealing"
) == true
end)
end
if interact and not nativeStateWasActive then
_BH_FN.SH_SetClientState(
interact,
true
)
SelfHeal.ClientStateOwned = true
else
SelfHeal.ClientStateOwned = false
end
end
function _BH_FN.SH_Start()
if not SelfHeal.Enabled
or SelfHeal.Running
or os.clock() < SelfHeal.RetryAt then
return false
end
local char,
humanoid,
root,
interact =
_BH_FN.SH_GetCharacter()
if not char
or not humanoid
or not root then
return false
end
if _BH_FN.SH_IsBusy(
char,
humanoid,
root,
interact
) then
return false
end
if not _BH_FN.SH_ShouldHeal(humanoid) then
return false
end
local remotes =
_BH_FN.SH_GetRemotes()
if not remotes
or not remotes.HealEvent
or not remotes.HealEvent:IsA(
"RemoteEvent"
) then
Library:Notify({
Title = "Self Heal",
Description = "HealEvent not found",
Time = 2
})
_BH_FN.SH_Stop(
false,
nil,
true,
true
)
return false
end
_BH_FN.SH_ClearConnections()
SelfHeal.Generation = SelfHeal.Generation + 1
local generation =
SelfHeal.Generation
SelfHeal.Running = true
SelfHeal.Accepted = false
SelfHeal.TargetRoot = root
SelfHeal.TargetCharacter = char
SelfHeal.ClientStateOwned = false
SelfHeal.StartHealth =
humanoid.Health
local function onHealSignal(state)
if not SelfHeal.Running
or generation
~= SelfHeal.Generation then
return
end
if state ~= false then
_BH_FN.SH_MarkAnimationWindow(
generation,
1.5
)
end
if state == false then
local rejected =
not SelfHeal.Accepted
_BH_FN.SH_Stop(
false,
rejected
and "Server rejected / perk required"
or nil,
not rejected,
rejected
)
return
end
_BH_FN.SH_Accept(generation)
end
if remotes.HealAnim
and remotes.HealAnim:IsA(
"RemoteEvent"
) then
SelfHeal.HealAnimConnection =
_BH_FN.TrackConnection(
remotes.HealAnim.OnClientEvent:Connect(
onHealSignal
)
)
end
if remotes.HealAnimRec
and remotes.HealAnimRec:IsA(
"RemoteEvent"
) then
SelfHeal.HealAnimRecConnection =
_BH_FN.TrackConnection(
remotes.HealAnimRec.OnClientEvent:Connect(
onHealSignal
)
)
end
if remotes.Stophealing
and remotes.Stophealing:IsA(
"RemoteEvent"
) then
SelfHeal.StopConnection =
_BH_FN.TrackConnection(
remotes.Stophealing.OnClientEvent:Connect(
function()
if SelfHeal.Running
and generation
== SelfHeal.Generation then
_BH_FN.SH_Stop(
false,
nil,
true,
false
)
end
end
)
)
end
if remotes.Healdone
and remotes.Healdone:IsA(
"RemoteEvent"
) then
SelfHeal.DoneConnection =
_BH_FN.TrackConnection(
remotes.Healdone.OnClientEvent:Connect(
function()
if SelfHeal.Running
and generation
== SelfHeal.Generation then
_BH_FN.SH_Stop(
false,
"Complete",
false,
false
)
end
end
)
)
end
SelfHeal.HealthConnection =
_BH_FN.TrackConnection(
humanoid.HealthChanged:Connect(
function(health)
if not SelfHeal.Running
or generation
~= SelfHeal.Generation then
return
end
if health
> SelfHeal.StartHealth
+ 0.01 then
_BH_FN.SH_Accept(
generation
)
end
if health
>= humanoid.MaxHealth
- 0.01 then
_BH_FN.SH_Stop(
true,
"HP full",
false,
false
)
elseif health <= 0 then
_BH_FN.SH_Stop(
false,
nil,
true,
false
)
end
end
)
)
_BH_FN.SH_StartAnimationGuard(
char,
humanoid,
generation
)
SelfHeal.AnimationSuppressUntil = math.huge
_BH_FN.SH_MarkAnimationWindow(
generation,
SelfHeal.AckTimeout + 0.35
)
local fired =
pcall(function()
remotes.HealEvent:FireServer(
root,
true
)
end)
if not fired then
_BH_FN.SH_Stop(
false,
"Failed to start",
false,
true
)
return false
end
task.delay(
SelfHeal.AckTimeout,
function()
if not SelfHeal.Running
or generation
~= SelfHeal.Generation
or SelfHeal.Accepted then
return
end
local currentChar,
currentHumanoid =
_BH_FN.SH_GetCharacter()
if currentChar == char
and currentHumanoid
and currentHumanoid.Health
> SelfHeal.StartHealth
+ 0.01 then
_BH_FN.SH_Accept(
generation
)
return
end
if _BH_FN.SH_HasClientHealState(root) then
_BH_FN.SH_Accept(
generation
)
return
end
_BH_FN.SH_Stop(
true,
"Server rejected / perk required",
false,
true
)
end
)
return true
end
function _BH_FN.SH_BindHealthWatcher(humanoid)
if SelfHeal.HealthWatchConnection then
_BH_FN.SH_DisconnectOne(
SelfHeal.HealthWatchConnection
)
SelfHeal.HealthWatchConnection = nil
end
if not humanoid then
return
end
SelfHeal.HealthWatchConnection =
_BH_FN.TrackConnection(
humanoid.HealthChanged:Connect(function()
if not HubRuntime.Alive
or not SelfHeal.Enabled
or SelfHeal.Running
or os.clock() < SelfHeal.RetryAt
or humanoid.Parent == nil then
return
end
if _BH_FN.SH_ShouldHeal(humanoid) then
task.defer(_BH_FN.SH_Start)
end
end)
)
end
function _BH_FN.SH_StartMonitor()
local _, currentHumanoid =
_BH_FN.SH_GetCharacter()
_BH_FN.SH_BindHealthWatcher(
currentHumanoid
)
if not SelfHeal.CharacterWatchConnection then
SelfHeal.CharacterWatchConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(char)
if SelfHeal.Running then
_BH_FN.SH_Stop(
false,
nil,
true,
false
)
end
local humanoid =
char:WaitForChild(
"Humanoid",
5
)
if SelfHeal.Enabled
and humanoid
and humanoid:IsA("Humanoid") then
_BH_FN.SH_BindHealthWatcher(
humanoid
)
if _BH_FN.SH_ShouldHeal(
humanoid
) then
task.defer(_BH_FN.SH_Start)
end
end
end)
)
end
if SelfHeal.MonitorConnection then
return
end
local accumulator = 0
SelfHeal.MonitorConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function(dt)
if not HubRuntime.Alive
or not SelfHeal.Enabled then
return
end
accumulator = accumulator + dt
if accumulator
< SelfHeal.MonitorInterval then
return
end
accumulator = 0
if SelfHeal.Running then
local targetRoot =
SelfHeal.TargetRoot
if not targetRoot
or not targetRoot.Parent
or GetRole() ~= "Survivor"
or SelfHeal.TargetCharacter
~= LocalPlayer.Character then
_BH_FN.SH_Stop(
false,
nil,
true,
false
)
end
return
end
if os.clock() < SelfHeal.RetryAt then
return
end
local _, humanoid =
_BH_FN.SH_GetCharacter()
if _BH_FN.SH_ShouldHeal(humanoid) then
_BH_FN.SH_Start()
end
end)
)
end
function _BH_FN.SH_SetEnabled(state)
local enabled =
state == true
if enabled then
SelfHeal.Enabled = true
SelfHeal.RetryAt = 0
_BH_FN.SH_StartMonitor()
local _, humanoid =
_BH_FN.SH_GetCharacter()
_BH_FN.SH_Start()
else
_BH_FN.SH_Stop(
true,
nil,
true,
true
)
end
end
function _BH_FN.DAP_GetRemote()
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local pallet = remotes and remotes:FindFirstChild("Pallet")
return pallet and pallet:FindFirstChild("PalletDropEvent")
end
function _BH_FN.DAP_GetCharacter()
local char = LocalPlayer.Character
if not char then return nil, nil, nil end
local root = char:FindFirstChild("HumanoidRootPart")
local interact =
_BH_FN.GB_GetClientInteract(char)
return char, root, interact
end
function _BH_FN.DAP_IsBusy(interact, root)
if not root or root.Anchored then
return true
end
if not interact then
return false
end
for _, attr in ipairs({
"isRepairing",
"isVaulting",
"isSliding",
"isHealing",
"isUnhooking",
"isExiting",
}) do
if interact:GetAttribute(attr) then
return true
end
end
return false
end
function _BH_FN.DAP_GetWorldPosition(obj)
if not obj then return nil end
if obj:IsA("BasePart") then
return obj.Position
end
if obj:IsA("Model") then
local ok, pivot = pcall(function()
return obj:GetPivot()
end)
if ok and pivot then
return pivot.Position
end
end
local part = obj:FindFirstChildWhichIsA("BasePart", true)
return part and part.Position
end
function _BH_FN.DAP_CollectPallets()
local result = {}
local seen = {}
for _, pal in ipairs(ESPCache.PalletList) do
if pal
and pal.Parent
and ESPCache.Pallets[pal]
and not seen[pal] then
seen[pal] = true
result[#result + 1] = pal
end
end
return result
end
function _BH_FN.DAP_AddCandidate(list, seen, candidate)
if not candidate
or not candidate.Parent
or seen[candidate] then
return
end
seen[candidate] = true
list[#list + 1] = candidate
end
function _BH_FN.DAP_GetCandidates(pallet)
local candidates = {}
local seen = {}
if not pallet or not pallet.Parent then
return candidates
end
for _, name in ipairs({
"PalletDropPoint",
"PalletPointDrop",
"DropPoint",
"PalletPoint",
"PrimaryPartPallet",
}) do
_BH_FN.DAP_AddCandidate(
candidates,
seen,
pallet:FindFirstChild(name, true)
)
end
for _, obj in ipairs(pallet:GetDescendants()) do
if obj:IsA("BasePart") then
local lower = string.lower(obj.Name)
local looksLikePoint =
string.find(lower, "drop", 1, true)
or string.find(lower, "point", 1, true)
if looksLikePoint then
_BH_FN.DAP_AddCandidate(candidates, seen, obj)
end
end
end
local palletPos = _BH_FN.DAP_GetWorldPosition(pallet)
if palletPos then
for _, tag in ipairs({
"PalletDropPoint",
"PalletPointDrop",
"PalletPoint",
}) do
local tagged = {}
pcall(function()
tagged = CollectionService:GetTagged(tag)
end)
for _, obj in ipairs(tagged) do
local pos = _BH_FN.DAP_GetWorldPosition(obj)
if pos
and (pos - palletPos).Magnitude <= 14 then
_BH_FN.DAP_AddCandidate(candidates, seen, obj)
end
end
end
end
if pallet:IsA("Model") then
_BH_FN.DAP_AddCandidate(candidates, seen, pallet.PrimaryPart)
end
_BH_FN.DAP_AddCandidate(
candidates,
seen,
pallet:FindFirstChildWhichIsA("BasePart", true)
)
_BH_FN.DAP_AddCandidate(candidates, seen, pallet)
return candidates
end
function _BH_FN.DAP_OrderPallets(
pallets,
startPosition
)
local remaining = {}
for _, pallet in ipairs(pallets) do
if pallet and pallet.Parent then
remaining[#remaining + 1] =
pallet
end
end
local ordered = {}
local cursor = startPosition
while #remaining > 0 do
local bestIndex = 1
local bestDistance = math.huge
for i, pallet in ipairs(
remaining
) do
local pos =
_BH_FN.DAP_GetWorldPosition(
pallet
)
local distance =
pos
and cursor
and (
pos - cursor
).Magnitude
or math.huge
if distance < bestDistance then
bestDistance = distance
bestIndex = i
end
end
local chosen =
table.remove(
remaining,
bestIndex
)
ordered[#ordered + 1] =
chosen
cursor =
_BH_FN.DAP_GetWorldPosition(
chosen
)
or cursor
end
return ordered
end
function _BH_FN.DAP_StopTween()
local tween =
DropAllPallet.ActiveTween
if tween then
pcall(function()
tween:Cancel()
end)
end
DropAllPallet.ActiveTween = nil
end
function _BH_FN.DAP_TweenRoot(
root,
targetCFrame,
generation
)
if not root
or not root.Parent
or not targetCFrame then
return false
end
_BH_FN.DAP_StopTween()
local distance =
(
root.Position
- targetCFrame.Position
).Magnitude
local speed =
math.max(
1,
tonumber(
DropAllPallet.TweenSpeed
) or 230
)
local duration =
math.clamp(
distance / speed,
DropAllPallet.TweenMin,
DropAllPallet.TweenMax
)
pcall(function()
root.AssemblyLinearVelocity =
Vector3.zero
root.AssemblyAngularVelocity =
Vector3.zero
end)
local tween =
TweenService:Create(
root,
TweenInfo.new(
duration,
Enum.EasingStyle.Sine,
Enum.EasingDirection.InOut
),
{
CFrame = targetCFrame
}
)
DropAllPallet.ActiveTween =
tween
tween:Play()
local done = false
local completedConnection
completedConnection =
tween.Completed:Connect(function()
done = true
end)
local timeout =
os.clock()
+ duration
+ 0.15
while not done
and HubRuntime.Alive
and DropAllPallet.Running
and generation
== DropAllPallet.Generation
and os.clock() < timeout do
task.wait()
end
if completedConnection then
completedConnection:Disconnect()
end
if DropAllPallet.ActiveTween
== tween then
DropAllPallet.ActiveTween =
nil
end
if not DropAllPallet.Running
or generation
~= DropAllPallet.Generation then
pcall(function()
tween:Cancel()
end)
return false
end
return true
end
function _BH_FN.DAP_GetNearCFrame(candidate, fallback)
local position =
_BH_FN.DAP_GetWorldPosition(candidate)
or _BH_FN.DAP_GetWorldPosition(fallback)
local palletPosition =
_BH_FN.DAP_GetWorldPosition(
fallback
)
or position
if not position then
return nil
end
local standPosition =
position
+ Vector3.new(
0,
2.2,
0
)
local lookPosition =
Vector3.new(
palletPosition.X,
standPosition.Y,
palletPosition.Z
)
if (
lookPosition
- standPosition
).Magnitude <= 0.01 then
return CFrame.new(
standPosition
)
end
return CFrame.lookAt(
standPosition,
lookPosition
)
end
function _BH_FN.DAP_SetDroppingState(interact, state)
if not interact then return end
pcall(function()
interact:SetAttribute(
"isDroppingPallet",
state == true
)
end)
end
function _BH_FN.DAP_EnsureAckConnection(remote)
if DropAllPallet.AckConnection then
return
end
DropAllPallet.AckConnection =
_BH_FN.TrackConnection(
remote.OnClientEvent:Connect(function()
DropAllPallet.AckCounter = DropAllPallet.AckCounter + 1
end)
)
end
function _BH_FN.DAP_WaitForAck(previousCounter, generation)
local started = os.clock()
while HubRuntime.Alive
and DropAllPallet.Running
and generation == DropAllPallet.Generation
and os.clock() - started < DropAllPallet.AckTimeout do
if DropAllPallet.AckCounter > previousCounter then
return true
end
task.wait(0.03)
end
return false
end
function _BH_FN.DAP_WaitForDropState(
interact,
generation
)
if not interact then
task.wait(
DropAllPallet.DropSettle
)
return
end
local started =
os.clock()
local sawActive = false
while HubRuntime.Alive
and DropAllPallet.Running
and generation
== DropAllPallet.Generation
and os.clock() - started
< DropAllPallet.DropStateTimeout do
local active =
interact:GetAttribute(
"isDroppingPallet"
) == true
if active then
sawActive = true
elseif sawActive then
break
end
task.wait(0.03)
end
task.wait(
DropAllPallet.DropSettle
)
end
function _BH_FN.DAP_TryCandidate(
remote,
pallet,
candidate,
root,
interact,
generation
)
if not candidate
or not candidate.Parent
or not root
or not root.Parent then
return false
end
local near = _BH_FN.DAP_GetNearCFrame(candidate, pallet)
if not near then
return false
end
if not _BH_FN.DAP_TweenRoot(
root,
near,
generation
) then
return false
end
pcall(function()
root.AssemblyLinearVelocity =
Vector3.zero
root.AssemblyAngularVelocity =
Vector3.zero
end)
task.wait(
DropAllPallet.ArrivalSettle
)
if not DropAllPallet.Running
or generation
~= DropAllPallet.Generation then
return false
end
local before =
DropAllPallet.AckCounter
_BH_FN.DAP_SetDroppingState(
interact,
true
)
local fired =
pcall(function()
remote:FireServer(
candidate
)
end)
if not fired then
_BH_FN.DAP_SetDroppingState(
interact,
false
)
return false
end
DropAllPallet.Requested = DropAllPallet.Requested + 1
local acked =
_BH_FN.DAP_WaitForAck(
before,
generation
)
if acked then
_BH_FN.DAP_WaitForDropState(
interact,
generation
)
end
_BH_FN.DAP_SetDroppingState(
interact,
false
)
return acked
end
function _BH_FN.DAP_RestoreCharacter(
generation,
smooth
)
local _, root, interact =
_BH_FN.DAP_GetCharacter()
_BH_FN.DAP_SetDroppingState(
interact,
false
)
local original =
DropAllPallet.OriginalCFrame
if root
and root.Parent
and original then
pcall(function()
root.Anchored = false
end)
if smooth == true
and generation
and DropAllPallet.Running
and generation
== DropAllPallet.Generation then
_BH_FN.DAP_TweenRoot(
root,
original,
generation
)
else
_BH_FN.DAP_StopTween()
pcall(function()
root.CFrame =
original
root.AssemblyLinearVelocity =
Vector3.zero
root.AssemblyAngularVelocity =
Vector3.zero
end)
end
end
DropAllPallet.OriginalCFrame =
nil
end
function _BH_FN.DAP_UnloadSafe()
local ownedMovement =
DropAllPallet.Running
or DropAllPallet.ActiveTween ~= nil
or DropAllPallet.OriginalCFrame ~= nil
DropAllPallet.Generation = DropAllPallet.Generation + 1
DropAllPallet.Running = false
pcall(_BH_FN.DAP_StopTween)
local char =
LocalPlayer.Character
local root =
char
and char:FindFirstChild(
"HumanoidRootPart"
)
if ownedMovement and root and root.Parent then
pcall(function()
root.Anchored = false
end)
end
DropAllPallet.OriginalCFrame = nil
end
function _BH_FN.DAP_Cancel()
if not DropAllPallet.Running then
return false
end
DropAllPallet.Generation = DropAllPallet.Generation + 1
DropAllPallet.Running = false
_BH_FN.DAP_StopTween()
_BH_FN.DAP_RestoreCharacter(nil, false)
return true
end
function _BH_FN.DAP_Request()
if DropAllPallet.Running then
_BH_FN.DAP_Cancel()
Library:Notify({
Title = "Drop All Pallet",
Description = "Cancelled",
Time = 1.5
})
return
end
local remote = _BH_FN.DAP_GetRemote()
if not remote or not remote:IsA("RemoteEvent") then
Library:Notify({
Title = "Drop All Pallet",
Description = "Remote not found",
Time = 2
})
return
end
local char, root, interact = _BH_FN.DAP_GetCharacter()
if not char or not root then
return
end
if _BH_FN.DAP_IsBusy(interact, root) then
Library:Notify({
Title = "Drop All Pallet",
Description = "Finish current action first",
Time = 2
})
return
end
local pallets =
_BH_FN.DAP_CollectPallets()
if #pallets > 1 then
pallets =
_BH_FN.DAP_OrderPallets(
pallets,
root.Position
)
end
if #pallets == 0 then
if not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
Library:Notify({
Title = "Drop All Pallet",
Description = "Refresh map cache first",
Time = 2
})
return
end
_BH_FN.DAP_EnsureAckConnection(remote)
DropAllPallet.Generation = DropAllPallet.Generation + 1
local generation = DropAllPallet.Generation
DropAllPallet.Running = true
DropAllPallet.Requested = 0
DropAllPallet.Success = 0
DropAllPallet.Failed = 0
DropAllPallet.OriginalCFrame = root.CFrame
Library:Notify({
Title = "Drop All Pallet",
Description =
tostring(#pallets)
.. " pallets | press again to cancel",
Time = 2
})
task.spawn(function()
for _, pallet in ipairs(pallets) do
if not HubRuntime.Alive
or not DropAllPallet.Running
or generation ~= DropAllPallet.Generation then
break
end
if pallet and pallet.Parent then
local success = false
local candidates = _BH_FN.DAP_GetCandidates(pallet)
for _, candidate in ipairs(candidates) do
if not DropAllPallet.Running
or generation ~= DropAllPallet.Generation then
break
end
if _BH_FN.DAP_TryCandidate(
remote,
pallet,
candidate,
root,
interact,
generation
) then
success = true
break
end
task.wait(DropAllPallet.Delay)
end
if success then
DropAllPallet.Success = DropAllPallet.Success + 1
else
DropAllPallet.Failed = DropAllPallet.Failed + 1
end
end
end
if generation == DropAllPallet.Generation then
_BH_FN.DAP_RestoreCharacter(
generation,
true
)
DropAllPallet.Running =
false
Library:Notify({
Title = "Drop All Pallet",
Description =
tostring(DropAllPallet.Success)
.. " dropped | "
.. tostring(DropAllPallet.Failed)
.. " failed",
Time = 3
})
end
end)
end
function _BH_FN.TeleportToWindow()
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
if part then _BH_FN.TeleportToPart(part) end
TeleportIndex.Window = TeleportIndex.Window + 1
end
function _BH_FN.RefreshMapForTeleport()
if not ESPScanState.Running then _BH_FN.startIncrementalMapScan() end
TeleportIndex.Generator = 1
TeleportIndex.Hook = 1
TeleportIndex.Gate = 1
TeleportIndex.Pallet = 1
TeleportIndex.Window = 1
end
function _BH_FN.notify(title, description, t)
pcall(function()
Library:Notify({Title = title, Description = description, Time = t or 2})
end)
end
function _BH_FN.installFakeTagHook()
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
function _BH_FN.stopFakeParryAnimation()
local track = State.FakeParryTrack
State.FakeParryTrack = nil
if track then
pcall(function()
if track.IsPlaying then track:Stop(0.06) end
end)
end
end
function _BH_FN.playFakeParryAnimation(forcePlay)
local id = FakeParryAnimations[FakeParry.Animation]
if not id then
_BH_FN.notify("Fake Parry", "Animation tidak ditemukan: " .. tostring(FakeParry.Animation), 2)
return false
end
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not char or not hum or hum.Health <= 0 then
_BH_FN.notify("Fake Parry", "Character belum siap.", 2)
return false
end
local animator = hum:FindFirstChildOfClass("Animator")
if not animator then
animator = Instance.new("Animator")
animator.Parent = hum
end
_BH_FN.stopFakeParryAnimation()
local anim = Instance.new("Animation")
anim.Name = "BluehavenFakeParry"
anim.AnimationId = id
local track = nil
local loaded = pcall(function()
track = animator:LoadAnimation(anim)
end)
if not loaded or not track then
pcall(function()
track = hum:LoadAnimation(anim)
end)
end
if not track then
pcall(function() anim:Destroy() end)
_BH_FN.notify("Fake Parry", "Animation gagal di-load.", 2)
return false
end
State.FakeParryTrack = track
pcall(function()
track.Priority = Enum.AnimationPriority.Action4
track.Looped = false
track:Play(0.03, 1, 1)
track:AdjustWeight(1, 0.03)
end)
pcall(function() anim:Destroy() end)
local stopConn
stopConn = _BH_FN.TrackConnection(track.Stopped:Connect(function()
if State.FakeParryTrack == track then
State.FakeParryTrack = nil
end
if stopConn then
_BH_FN.ForgetConnection(stopConn)
pcall(function() stopConn:Disconnect() end)
stopConn = nil
end
end))
task.delay(2.8, function()
if HubRuntime.Alive and State.FakeParryTrack == track then
_BH_FN.stopFakeParryAnimation()
end
end)
return true
end
function _BH_FN.getCurrentDescription()
local hum = _BH_FN.getHumanoid()
if not hum then return nil end
local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
return ok and desc or nil
end
function _BH_FN.applyMorphByUsername()
local username = tostring(MorphState.Username or ""):match("^%s*(.-)%s*$")
if username == "" then
_BH_FN.notify("Morph Avatar", "Isi username dulu.", 2)
return
end
local hum = _BH_FN.getHumanoid()
if not hum then return end
if not MorphState.OriginalDescription then MorphState.OriginalDescription = _BH_FN.getCurrentDescription() end
task.spawn(function()
local ok, err = pcall(function()
local userId = Players:GetUserIdFromNameAsync(username)
local desc = Players:GetHumanoidDescriptionFromUserId(userId)
hum:ApplyDescription(desc)
end)
if ok then
MorphState.Active = true
end
_BH_FN.notify("Morph Avatar", ok and ("Morph ke " .. username .. " berhasil.") or ("Gagal: " .. tostring(err)), 2)
end)
end
function _BH_FN.resetMorph()
local hum = _BH_FN.getHumanoid()
if not hum then return end
if MorphState.OriginalDescription then
local ok, err = pcall(function()
hum:ApplyDescription(MorphState.OriginalDescription)
end)
if ok then
MorphState.Active = false
end
_BH_FN.notify("Morph Avatar", ok and "Avatar dikembalikan." or ("Reset gagal: " .. tostring(err)), 2)
else
_BH_FN.notify("Morph Avatar", "Belum ada morph yang disimpan.", 2)
end
end
function _BH_FN.destroyCrosshairGui()
if CrosshairGui.Gui then pcall(function() CrosshairGui.Gui:Destroy() end) end
CrosshairGui.Gui = nil
CrosshairGui.Horizontal = nil
CrosshairGui.Vertical = nil
CrosshairGui.Dot = nil
CrosshairGui.Circle = nil
end
function _BH_FN.ensureCrosshairGui()
if CrosshairGui.Gui and CrosshairGui.Gui.Parent then return end
local gui = _BH_FN.TrackArtifact(Instance.new("ScreenGui"))
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
function _BH_FN.updateCrosshairGui()
if not Crosshair.Enabled then
_BH_FN.destroyCrosshairGui()
return
end
_BH_FN.ensureCrosshairGui()
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
function _BH_FN.setToggleValue(id, value, fallback)
local toggle = Toggles and Toggles[id]
if toggle and type(toggle.SetValue) == "function" then
toggle:SetValue(value)
elseif fallback then
fallback(value)
end
end
_BH_FN.TrackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
if not HubRuntime.Alive or gameProcessed then return end
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
if input.KeyCode == GenBypass.HotkeyCode then
if not GenBypass.Enabled then
setGenBypass(true)
end
_BH_FN.GB_Request()
return
end
if input.KeyCode == FakeParry.Keybind then
_BH_FN.playFakeParryAnimation(true)
return
end
if input.KeyCode == Movement.BoostKeybind then
local nextState = not Movement.BoostEnabled
local boostToggle = Toggles["Movement Boost"]
if boostToggle and type(boostToggle.SetValue) == "function" then
boostToggle:SetValue(nextState)
else
Movement.BoostEnabled = nextState
_BH_FN.applyMovementBoost()
end
_BH_FN.notify(
"Movement Boost",
nextState and "Enabled" or "Disabled",
1.2
)
return
end
end))
local oldNamecall
local mainNamecallHookInstalled = false
local rewriteToFFireArgs
function _BH_FN.installMainNamecallHook()
if mainNamecallHookInstalled then return true end
if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
return false
end
local ok = pcall(function()
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
local hookNeeded =
(AntiKnockdown.Enabled and AntiKnockdown.Active)
or PlayerMods.AntiFall
or Killer.AntiBlind
or Killer.BlockVaults
or PlayerMods.AntiVault
if not hookNeeded then
return oldNamecall(self, ...)
end
local method = getnamecallmethod()
if method == "GetAttribute"
and AntiKnockdown.Enabled
and AntiKnockdown.Active
and self == LocalPlayer.Character then
local callerIsUs =
type(checkcaller) == "function"
and checkcaller()
if not callerIsUs then
local attribute = select(1, ...)
local isDownAttribute =
attribute == "Knocked"
or attribute == "Downed"
or attribute == "IsDown"
or attribute == "IsKnocked"
if isDownAttribute then
local caller = nil
if type(getcallingscript)
== "function" then
pcall(function()
caller = getcallingscript()
end)
end
if caller ~= nil
and _BH_FN.AK_IsAllowedHealthCaller(
caller
) then
return false
end
end
end
end
if method == "FireServer" then
local callerIsUs = type(checkcaller) == "function" and checkcaller() or false
if not callerIsUs then
if PlayerMods.AntiFall and FallRemote and self == FallRemote then
return nil
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
local LeapBypassState = {
Originals = {},
Patched = {},
}
function _BH_FN.RestoreLeapBypass()
for _, entry in ipairs(LeapBypassState.Originals) do
pcall(function() debug.setupvalue(entry.fn, entry.index, entry.value) end)
end
table.clear(LeapBypassState.Originals)
table.clear(LeapBypassState.Patched)
end
function _BH_FN.StopLeapBypass()
Killer.BypassLeap = false
if Connections.LeapBypass and type(task.cancel) == "function" then
pcall(function() task.cancel(Connections.LeapBypass) end)
end
Connections.LeapBypass = nil
_BH_FN.RestoreLeapBypass()
end
function _BH_FN.StartLeapBypass()
if type(getgc) ~= "function"
or type(islclosure) ~= "function"
or not debug
or type(debug.getupvalues) ~= "function"
or type(debug.setupvalue) ~= "function" then
_BH_FN.notify("Bypass Leap", "Executor tidak support fitur ini.", 2)
Killer.BypassLeap = false
return
end
_BH_FN.RestoreLeapBypass()
Connections.LeapBypass = task.spawn(function()
local leapFunction, m2Function
local okGC, gcObjects = pcall(getgc, false)
if not okGC or type(gcObjects) ~= "table" then
return
end
for index, v in ipairs(gcObjects) do
if not Killer.BypassLeap or not HubRuntime.Alive then return end
if type(v) == "function" and islclosure(v) then
local okInfo, info = pcall(debug.getinfo, v)
if okInfo and info then
if info.name == "tryActivate" then leapFunction = v end
if info.name == "playM2Animation" then m2Function = v end
if leapFunction and m2Function then break end
end
end
if index % 100 == 0 then
task.wait()
end
end
if not leapFunction and not m2Function then
warn("Bypass Leap: function tidak ditemukan.")
return
end
for _, fn in pairs({leapFunction, m2Function}) do
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
Generation = 0,
ScanThread = nil,
ScanRunning = false,
LastFullScan = 0,
FullScanAttempts = 0,
CooldownConnection = nil,
CharacterConnection = nil,
Controllers = setmetatable({}, {__mode = "k"}),
OriginalValues = setmetatable({}, {__mode = "k"}),
ControllerMethods = setmetatable({}, {__mode = "k"}),
LastControllerCount = 0,
}
function _BH_FN.CD_Disconnect(key)
local connection = CooldownBypassState[key]
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
CooldownBypassState[key] = nil
end
end
function _BH_FN.CD_IsCooldownKey(key)
if type(key) ~= "string" then
return false
end
local compact = string.lower(key):gsub("[%s_%-]", "")
return compact == "cd"
or string.find(compact, "cooldown", 1, true) ~= nil
end
function _BH_FN.CD_RecordValue(container, key, value)
local entries = CooldownBypassState.OriginalValues[container]
if not entries then
entries = {}
CooldownBypassState.OriginalValues[container] = entries
end
if entries[key] == nil then
entries[key] = {
Original = value,
Applied = nil,
}
end
return entries[key]
end
function _BH_FN.CD_PatchTable(container, depth, seen, budget)
if type(container) ~= "table"
or depth > 6
or seen[container]
or budget.Count >= 900 then
return
end
seen[container] = true
for key, value in pairs(container) do
budget.Count = budget.Count + 1
if budget.Count >= 900 then
return
end
local compact = type(key) == "string"
and string.lower(key):gsub("[%s_%-]", "")
or ""
local replacement = nil
if type(value) == "number"
and _BH_FN.CD_IsCooldownKey(key)
and value ~= 0 then
replacement = 0
elseif type(value) == "boolean" then
if compact == "oncooldown"
or compact == "coolingdown"
or compact == "cooldownactive" then
replacement = false
elseif compact == "canuse"
or compact == "isready" then
replacement = true
end
end
if replacement ~= nil
and value ~= replacement then
local snapshot =
_BH_FN.CD_RecordValue(
container,
key,
value
)
snapshot.Applied = replacement
pcall(function()
rawset(container, key, replacement)
end)
end
if type(value) == "table" then
_BH_FN.CD_PatchTable(
value,
depth + 1,
seen,
budget
)
elseif type(value) == "function"
and debug
and type(debug.getupvalues) == "function" then
local ok, upvalues =
pcall(debug.getupvalues, value)
if ok and type(upvalues) == "table" then
for _, upvalue in pairs(upvalues) do
if type(upvalue) == "table" then
_BH_FN.CD_PatchTable(
upvalue,
depth + 1,
seen,
budget
)
end
end
end
end
end
end
function _BH_FN.CD_IsKillerController(candidate)
if type(candidate) ~= "table" then
return false
end
return rawget(candidate, "player") == LocalPlayer
and rawget(candidate, "character") == LocalPlayer.Character
and type(rawget(candidate, "config")) == "table"
and type(rawget(candidate, "state")) == "table"
and type(rawget(candidate, "makeMoveCooldown")) == "function"
and type(rawget(candidate, "canStartAction")) == "function"
end
function _BH_FN.CD_FindControllerInValue(
value,
seen,
depth,
budget
)
if type(value) ~= "table"
or seen[value]
or depth > 2
or budget.Count >= 180 then
return 0
end
seen[value] = true
budget.Count = budget.Count + 1
if _BH_FN.CD_IsKillerController(value) then
CooldownBypassState.Controllers[value] = true
return 1
end
local found = 0
for _, nested in pairs(value) do
if budget.Count >= 180 then
break
end
if type(nested) == "table" then
found = found +
_BH_FN.CD_FindControllerInValue(
nested,
seen,
depth + 1,
budget
)
end
end
return found
end
function _BH_FN.CD_FindSignalControllers()
if type(getconnections) ~= "function"
or not debug
or type(debug.getupvalues) ~= "function" then
return 0
end
local remotes =
ReplicatedStorage:FindFirstChild("Remotes")
local killers =
remotes and remotes:FindFirstChild("Killers")
local attacks =
remotes and remotes:FindFirstChild("Attacks")
local killerFolder =
killers and killers:FindFirstChild("Killer")
local signals = {
killerFolder
and killerFolder:FindFirstChild("CooldownEvent"),
killers and killers:FindFirstChild("SlowAttack"),
attacks and attacks:FindFirstChild("AfterAttack"),
}
local seen = {}
local budget = {Count = 0}
local found = 0
for _, remote in pairs(signals) do
if remote and remote:IsA("RemoteEvent") then
local okConnections, connections =
pcall(getconnections, remote.OnClientEvent)
if okConnections
and type(connections) == "table" then
for _, connection in ipairs(connections) do
local callback = nil
pcall(function()
callback = connection.Function
or connection.Callback
end)
if type(callback) == "function" then
local okUpvalues, upvalues =
pcall(debug.getupvalues, callback)
if okUpvalues
and type(upvalues) == "table" then
for _, upvalue in pairs(upvalues) do
found = found +
_BH_FN.CD_FindControllerInValue(
upvalue,
seen,
0,
budget
)
end
end
end
end
end
end
end
return found
end
function _BH_FN.CD_PatchController(controller, deepPatch)
local original = rawget(controller, "makeMoveCooldown")
local existing = CooldownBypassState.ControllerMethods[controller]
if not existing and type(original) == "function" then
local replacement = function(gradient, icon, _)
return original(gradient, icon, 0)
end
CooldownBypassState.ControllerMethods[controller] = {
Original = original,
Replacement = replacement,
}
pcall(function()
rawset(controller, "makeMoveCooldown", replacement)
end)
elseif existing
and rawget(controller, "makeMoveCooldown")
~= existing.Replacement then
pcall(function()
rawset(
controller,
"makeMoveCooldown",
existing.Replacement
)
end)
end
if deepPatch == false then
return
end
local seen = {}
local budget = {Count = 0}
_BH_FN.CD_PatchTable(
rawget(controller, "config"),
0,
seen,
budget
)
_BH_FN.CD_PatchTable(
rawget(controller, "state"),
0,
seen,
budget
)
end
function _BH_FN.CD_PatchCachedControllers(deepPatch)
local count = 0
for controller in pairs(
CooldownBypassState.Controllers
) do
if _BH_FN.CD_IsKillerController(controller) then
count = count + 1
_BH_FN.CD_PatchController(controller, deepPatch)
else
CooldownBypassState.Controllers[controller] = nil
end
end
CooldownBypassState.LastControllerCount = count
return count
end
function _BH_FN.CD_ScanControllers(forceFull, deepPatch)
if not Killer.BypassCooldown
or GetRole() ~= "Killer" then
return 0
end
local count =
_BH_FN.CD_PatchCachedControllers(deepPatch)
if count == 0 then
_BH_FN.CD_FindSignalControllers()
count = _BH_FN.CD_PatchCachedControllers(true)
end
if count > 0
or CooldownBypassState.ScanRunning
or type(getgc) ~= "function" then
return count
end
local now = os.clock()
if not forceFull
and now - CooldownBypassState.LastFullScan < 4 then
return count
end
if CooldownBypassState.FullScanAttempts >= 2 then
return count
end
CooldownBypassState.LastFullScan = now
CooldownBypassState.FullScanAttempts =
CooldownBypassState.FullScanAttempts + 1
CooldownBypassState.ScanRunning = true
local ok, objects = pcall(getgc, true)
if not ok or type(objects) ~= "table" then
CooldownBypassState.ScanRunning = false
return count
end
for index, candidate in ipairs(objects) do
if not Killer.BypassCooldown
or not HubRuntime.Alive then
break
end
if _BH_FN.CD_IsKillerController(candidate) then
CooldownBypassState.Controllers[candidate] = true
break
end
if index % 120 == 0 then
task.wait()
end
end
CooldownBypassState.ScanRunning = false
return _BH_FN.CD_PatchCachedControllers(true)
end
function _BH_FN.CD_Restore()
for controller, entry in pairs(
CooldownBypassState.ControllerMethods
) do
pcall(function()
if rawget(controller, "makeMoveCooldown")
== entry.Replacement then
rawset(
controller,
"makeMoveCooldown",
entry.Original
)
end
end)
end
for container, entries in pairs(
CooldownBypassState.OriginalValues
) do
for key, snapshot in pairs(entries) do
pcall(function()
if rawget(container, key)
== snapshot.Applied then
rawset(
container,
key,
snapshot.Original
)
end
end)
end
end
CooldownBypassState.ControllerMethods =
setmetatable({}, {__mode = "k"})
CooldownBypassState.OriginalValues =
setmetatable({}, {__mode = "k"})
CooldownBypassState.Controllers =
setmetatable({}, {__mode = "k"})
CooldownBypassState.ScanRunning = false
CooldownBypassState.LastFullScan = 0
CooldownBypassState.FullScanAttempts = 0
CooldownBypassState.LastControllerCount = 0
end
function _BH_FN.toggleBypassCooldown(state)
CooldownBypassState.Generation =
CooldownBypassState.Generation + 1
local generation =
CooldownBypassState.Generation
_BH_FN.CD_Disconnect("CooldownConnection")
_BH_FN.CD_Disconnect("CharacterConnection")
if not state then
_BH_FN.CD_Restore()
CooldownBypassState.ScanThread = nil
return
end
if type(getgc) ~= "function"
and type(getconnections) ~= "function" then
_BH_FN.notify(
"Bypass Cooldown",
"Executor tidak support runtime scan.",
2
)
Killer.BypassCooldown = false
return
end
local remotes =
ReplicatedStorage:FindFirstChild("Remotes")
local killers =
remotes and remotes:FindFirstChild("Killers")
local killerFolder =
killers and killers:FindFirstChild("Killer")
local cooldownEvent =
killerFolder
and killerFolder:FindFirstChild("CooldownEvent")
if cooldownEvent
and cooldownEvent:IsA("RemoteEvent") then
CooldownBypassState.CooldownConnection =
_BH_FN.TrackConnection(
cooldownEvent.OnClientEvent:Connect(function()
task.defer(function()
if Killer.BypassCooldown
and generation
== CooldownBypassState.Generation then
_BH_FN.CD_ScanControllers(false, true)
end
end)
end)
)
end
CooldownBypassState.CharacterConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function()
CooldownBypassState.LastFullScan = 0
CooldownBypassState.FullScanAttempts = 0
task.delay(0.65, function()
if Killer.BypassCooldown
and generation
== CooldownBypassState.Generation then
_BH_FN.CD_ScanControllers(true, true)
end
end)
end)
)
task.delay(0.08, function()
if Killer.BypassCooldown
and generation
== CooldownBypassState.Generation then
_BH_FN.CD_ScanControllers(true, true)
end
end)
CooldownBypassState.ScanThread = task.spawn(function()
while HubRuntime.Alive
and Killer.BypassCooldown
and generation
== CooldownBypassState.Generation do
task.wait(1.50)
if Killer.BypassCooldown
and generation
== CooldownBypassState.Generation then
_BH_FN.CD_ScanControllers(false, false)
end
end
end)
end
local KillerAttackNoSlow = {
Enabled = false,
Generation = 0,
GuardUntil = 0,
LastResult = nil,
Controller = nil,
LastControllerScan = 0,
SlowConnection = nil,
AfterAttackConnection = nil,
RenderConnection = nil,
CharacterConnection = nil,
}
function _BH_FN.KAS_Disconnect(key)
local connection = KillerAttackNoSlow[key]
if connection then
pcall(function()
connection:Disconnect()
end)
_BH_FN.ForgetConnection(connection)
KillerAttackNoSlow[key] = nil
end
end
function _BH_FN.KAS_FindController(force)
local cached = KillerAttackNoSlow.Controller
if cached
and _BH_FN.CD_IsKillerController(cached) then
return cached
end
KillerAttackNoSlow.Controller = nil
if force then
_BH_FN.CD_FindSignalControllers()
end
for controller in pairs(
CooldownBypassState.Controllers
) do
if _BH_FN.CD_IsKillerController(controller) then
KillerAttackNoSlow.Controller = controller
return controller
else
CooldownBypassState.Controllers[controller] = nil
end
end
return nil
end
function _BH_FN.KAS_GetNormalSpeed(character)
if not character then
return 16
end
local baseSpeed =
tonumber(character:GetAttribute("Speed")) or 16
local speedBoost =
tonumber(character:GetAttribute("speedboost")) or 1
return math.clamp(baseSpeed * speedBoost, 0, 100)
end
function _BH_FN.KAS_IsHardBlocked(character, state)
if not character then
return true
end
return character:GetAttribute("Immobile") == true
or character:GetAttribute("IsStunned") == true
or (state and state.isTrueStunned == true)
or KillerAttackNoSlow.LastResult == "Parried"
end
function _BH_FN.KAS_Apply()
if not KillerAttackNoSlow.Enabled
or not Killer.NoAttackSlow
or os.clock() > KillerAttackNoSlow.GuardUntil
or GetRole() ~= "Killer" then
return
end
local character = LocalPlayer.Character
local humanoid = character
and character:FindFirstChildOfClass("Humanoid")
if not humanoid or humanoid.Health <= 0 then
return
end
local controller = _BH_FN.KAS_FindController(false)
local controllerState = controller
and rawget(controller, "state")
if _BH_FN.KAS_IsHardBlocked(
character,
controllerState
) then
return
end
humanoid.WalkSpeed =
_BH_FN.KAS_GetNormalSpeed(character)
end
function _BH_FN.KAS_StartGuard(result, duration)
if not KillerAttackNoSlow.Enabled
or not Killer.NoAttackSlow
or GetRole() ~= "Killer" then
return
end
KillerAttackNoSlow.LastResult = result
if result == "Parried" then
KillerAttackNoSlow.GuardUntil = 0
return
end
KillerAttackNoSlow.GuardUntil = math.max(
KillerAttackNoSlow.GuardUntil,
os.clock() + (duration or 2.5)
)
_BH_FN.KAS_FindController(false)
_BH_FN.KAS_Apply()
end
function _BH_FN.KAS_SetEnabled(enabled)
KillerAttackNoSlow.Generation =
KillerAttackNoSlow.Generation + 1
KillerAttackNoSlow.Enabled = enabled == true
KillerAttackNoSlow.GuardUntil = 0
KillerAttackNoSlow.LastResult = nil
KillerAttackNoSlow.Controller = nil
KillerAttackNoSlow.LastControllerScan = 0
_BH_FN.KAS_Disconnect("SlowConnection")
_BH_FN.KAS_Disconnect("AfterAttackConnection")
_BH_FN.KAS_Disconnect("RenderConnection")
_BH_FN.KAS_Disconnect("CharacterConnection")
if not enabled then
return
end
local generation = KillerAttackNoSlow.Generation
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local killers = remotes and remotes:FindFirstChild("Killers")
local attacks = remotes and remotes:FindFirstChild("Attacks")
local slowAttack = killers
and killers:FindFirstChild("SlowAttack")
local afterAttack = attacks
and attacks:FindFirstChild("AfterAttack")
if slowAttack
and slowAttack:IsA("RemoteEvent") then
KillerAttackNoSlow.SlowConnection =
_BH_FN.TrackConnection(
slowAttack.OnClientEvent:Connect(function()
task.defer(function()
if generation
== KillerAttackNoSlow.Generation then
_BH_FN.KAS_StartGuard(
"SlowAttack",
1.25
)
end
end)
end)
)
end
if afterAttack
and afterAttack:IsA("RemoteEvent") then
KillerAttackNoSlow.AfterAttackConnection =
_BH_FN.TrackConnection(
afterAttack.OnClientEvent:Connect(function(result)
task.defer(function()
if generation
== KillerAttackNoSlow.Generation then
_BH_FN.KAS_StartGuard(
result,
3.25
)
end
end)
end)
)
end
KillerAttackNoSlow.RenderConnection =
_BH_FN.TrackConnection(
RunService.RenderStepped:Connect(
_BH_FN.KAS_Apply
)
)
KillerAttackNoSlow.CharacterConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function()
KillerAttackNoSlow.Controller = nil
KillerAttackNoSlow.GuardUntil = 0
KillerAttackNoSlow.LastResult = nil
end)
)
end
function _BH_FN.FV_DisconnectOne(conn)
if not conn then return end
pcall(function()
conn:Disconnect()
end)
_BH_FN.ForgetConnection(conn)
end
function _BH_FN.FV_FindBlockedVaultPoint(
proximity,
radius
)
local char = rawget(proximity, "character")
local root = rawget(
proximity,
"humanoidRootPart"
)
if not char or not root then
return nil
end
if root:HasTag("doing action") then
return nil
end
local nearest = nil
local nearestDistance =
tonumber(radius) or 4
for _, point in ipairs(
CollectionService:GetTagged(
"VaultPoint"
)
) do
local valid =
point:IsA("BasePart")
and not point:IsDescendantOf(char)
if valid
and rawget(
proximity,
"checkPartDoingAction"
) == true
and CollectionService:HasTag(
point,
"doing action"
) then
valid = false
end
if valid then
local distance =
(point.Position - root.Position)
.Magnitude
if distance <= nearestDistance then
nearestDistance = distance
nearest = point
end
end
end
if not nearest then
return nil
end
if nearestDistance < 3.5 then
return nearest
end
local rayParams =
rawget(proximity, "rayParams")
local hit = workspace:Raycast(
root.Position,
nearest.Position - root.Position,
rayParams
)
return hit and hit.Instance == nearest
and nearest
or nil
end
function _BH_FN.FV_RestoreProximityHook()
local module = FastVault.ProximityModule
if type(module) == "table"
and module.findNearestPoint
== FastVault.PatchedFindNearestPoint then
pcall(function()
module.findNearestPoint =
FastVault.OriginalFindNearestPoint
end)
end
FastVault.ProximityModule = nil
FastVault.OriginalFindNearestPoint = nil
FastVault.PatchedFindNearestPoint = nil
end
function _BH_FN.FV_InstallProximityHook()
_BH_FN.FV_RestoreProximityHook()
local modules =
ReplicatedStorage:FindFirstChild(
"Modules"
)
local survivors =
modules
and modules:FindFirstChild(
"Survivors"
)
local proximityScript =
survivors
and survivors:FindFirstChild(
"SurvivorProximity"
)
if not proximityScript then
return false
end
local ok, module =
pcall(require, proximityScript)
if not ok
or type(module) ~= "table"
or type(module.findNearestPoint)
~= "function" then
return false
end
local original =
module.findNearestPoint
FastVault.ProximityModule = module
FastVault.OriginalFindNearestPoint =
original
FastVault.PatchedFindNearestPoint =
function(self, tagName, radius, ...)
if not FastVault.Enabled
or tagName ~= "VaultPoint"
or rawget(self, "player")
~= LocalPlayer then
return original(
self,
tagName,
radius,
...
)
end
local override =
_BH_FN.FV_FindBlockedVaultPoint(
self,
radius
)
if override then
return override
end
return original(
self,
tagName,
radius,
...
)
end
local installed = pcall(function()
module.findNearestPoint =
FastVault.PatchedFindNearestPoint
end)
if not installed then
_BH_FN.FV_RestoreProximityHook()
return false
end
return true
end
function _BH_FN.FV_GetSelectedSpeed()
return math.clamp(
tonumber(FastVault.Speed) or 1,
1,
3
)
end
function _BH_FN.FV_EnsureVaultSpeed(char)
if not char or not char.Parent then
return 1
end
local current =
tonumber(char:GetAttribute("vaultspeed"))
if not current or current <= 0 then
current = 1
pcall(function()
char:SetAttribute("vaultspeed", current)
end)
end
return current
end
task.defer(function()
_BH_FN.FV_EnsureVaultSpeed(LocalPlayer.Character)
end)
Connections.VaultSpeedSafety =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(char)
task.defer(function()
_BH_FN.FV_EnsureVaultSpeed(char)
end)
end)
)
function _BH_FN.FV_ApplyNativeSpeed(char)
char = char or FastVault.Character
if not FastVault.Enabled
or not char
or not char.Parent then
return false
end
_BH_FN.FV_EnsureVaultSpeed(char)
FastVault.LastWrittenVaultSpeed = nil
return true
end
function _BH_FN.FV_RestoreNativeSpeed(clearCapture)
local char = FastVault.Character
_BH_FN.FV_EnsureVaultSpeed(char)
FastVault.LastWrittenVaultSpeed = nil
if clearCapture ~= false then
FastVault.OriginalVaultSpeed = nil
FastVault.VaultSpeedWasNil = false
end
end
function _BH_FN.FV_GetInteract(char)
return _BH_FN.GB_GetClientInteract(char)
end
function _BH_FN.FV_IsWindowVault(interact)
if not interact then
return false
end
local vaulting = false
local sliding = false
pcall(function()
vaulting =
interact:GetAttribute("isVaulting") == true
or interact:GetAttribute("IsVaulting") == true
sliding =
interact:GetAttribute("isSliding") == true
or interact:GetAttribute("IsSliding") == true
end)
return vaulting
and not sliding
and os.clock() > FastVault.PalletSlideUntil
end
function _BH_FN.FV_IsSliding(interact)
if not interact then
return false
end
local sliding = false
pcall(function()
sliding =
interact:GetAttribute("isSliding") == true
or interact:GetAttribute("IsSliding") == true
end)
return sliding
end
function _BH_FN.FV_IsOtherActionBusy(interact)
if not interact then
return true
end
for _, attribute in ipairs({
"isRepairing",
"IsRepairing",
"isHealing",
"IsHealing",
"isDroppingPallet",
"isUnhooking",
"isExiting",
}) do
if interact:GetAttribute(attribute) == true then
return true
end
end
local vaulting =
interact:GetAttribute("isVaulting") == true
or interact:GetAttribute("IsVaulting") == true
if vaulting
and os.clock() > FastVault.PalletSlideUntil then
return true
end
return false
end
function _BH_FN.FV_RecoverPalletSlide(token, forceRelease)
if not FastVault.Enabled
or token ~= FastVault.SlideToken then
return
end
local char = FastVault.Character
local interact = FastVault.Interact
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if not char or not char.Parent
or not interact
or not hum
or hum.Health <= 0
or not root
or char:GetAttribute("IsHooked")
or char:GetAttribute("IsCarried")
or _BH_FN.FV_IsOtherActionBusy(interact) then
return
end
if _BH_FN.FV_IsSliding(interact) then
if not forceRelease then
return
end
pcall(function()
interact:SetAttribute("isSliding", false)
if interact:GetAttribute("IsSliding") ~= nil then
interact:SetAttribute("IsSliding", false)
end
end)
end
if _BH_FN.FV_IsSliding(interact) then
return
end
local movementStuck =
root.Anchored
or hum.WalkSpeed <= 1.25
if not movementStuck then
return
end
local expected = math.clamp(
tonumber(FastVault.SlideWalkSpeed) or 10,
4,
60
)
local controller =
_BH_FN.AK_FindAnimationController
and _BH_FN.AK_FindAnimationController(char, hum)
if controller then
pcall(function()
controller.cantupdatespeed = false
controller.isSlowedFromFall = false
controller.targetBaseWalkSpeed = expected
controller.smoothedBaseWalkSpeed = expected
end)
end
pcall(function()
root.Anchored = false
root:RemoveTag("doing action")
hum.AutoRotate = true
if hum.WalkSpeed <= 1.25 then
hum.WalkSpeed = expected
end
end)
end
function _BH_FN.FV_OnPalletSlideState()
if not FastVault.Enabled then
return
end
local interact = FastVault.Interact
local char = FastVault.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not interact or not hum then
return
end
if _BH_FN.FV_IsSliding(interact) then
if not FastVault.SlideActive then
FastVault.SlideActive = true
FastVault.SlideToken = FastVault.SlideToken + 1
FastVault.PalletSlideUntil = os.clock() + 3.20
if hum.WalkSpeed > 1.25 then
FastVault.SlideWalkSpeed = hum.WalkSpeed
end
local token = FastVault.SlideToken
task.delay(2.80, function()
_BH_FN.FV_RecoverPalletSlide(token, true)
end)
end
return
end
if not FastVault.SlideActive then
return
end
FastVault.SlideActive = false
FastVault.PalletSlideUntil = math.max(
FastVault.PalletSlideUntil,
os.clock() + 0.90
)
local token = FastVault.SlideToken
for _, delaySeconds in ipairs({0.08, 0.22, 0.55}) do
task.delay(delaySeconds, function()
_BH_FN.FV_RecoverPalletSlide(token, false)
end)
end
end
function _BH_FN.FV_GetTrackNames(track)
local names = {}
if not track then
return names
end
pcall(function()
names[#names + 1] =
string.lower(track.Name or "")
end)
pcall(function()
local animation = track.Animation
if animation then
names[#names + 1] =
string.lower(animation.Name or "")
end
end)
return names
end
function _BH_FN.FV_IsLikelyVaultTrack(track)
if not track
or _BH_FN.FV_IsSliding(FastVault.Interact) then
return false
end
local now = os.clock()
local names = _BH_FN.FV_GetTrackNames(track)
for _, name in ipairs(names) do
if string.find(name, "vault", 1, true)
or string.find(name, "window", 1, true)
or string.find(name, "finesse", 1, true) then
return true
end
if now <= FastVault.WindowJumpUntil then
if string.find(name, "jump", 1, true)
or string.find(name, "leap", 1, true)
or string.find(name, "climb", 1, true)
or string.find(name, "land", 1, true) then
return true
end
end
end
if _BH_FN.FV_IsWindowVault(FastVault.Interact)
or now <= FastVault.VaultWindowUntil then
local priority = nil
pcall(function()
priority = track.Priority
end)
return priority == Enum.AnimationPriority.Action
or priority == Enum.AnimationPriority.Action2
or priority == Enum.AnimationPriority.Action3
or priority == Enum.AnimationPriority.Action4
or priority == Enum.AnimationPriority.Movement
end
return false
end
function _BH_FN.FV_RestoreAnimationTracks()
for track, originalSpeed in pairs(
FastVault.BoostedTracks
) do
if track then
pcall(function()
track:AdjustSpeed(
tonumber(originalSpeed) or 1
)
end)
end
FastVault.BoostedTracks[track] = nil
end
end
function _BH_FN.FV_BoostTrack(track)
if not FastVault.Enabled
or not track
or not _BH_FN.FV_IsLikelyVaultTrack(track) then
return
end
if FastVault.BoostedTracks[track] == nil then
local originalSpeed = 1
pcall(function()
originalSpeed =
tonumber(track.Speed) or 1
end)
FastVault.BoostedTracks[track] =
originalSpeed
end
local selectedSpeed =
_BH_FN.FV_GetSelectedSpeed()
pcall(function()
track:AdjustSpeed(selectedSpeed)
end)
end
function _BH_FN.FV_BoostPlayingVaultTracks()
local animator = FastVault.Animator
if not animator then
return
end
local ok, tracks = pcall(function()
return animator:GetPlayingAnimationTracks()
end)
if not ok or not tracks then
return
end
for _, track in ipairs(tracks) do
_BH_FN.FV_BoostTrack(track)
end
end
function _BH_FN.FV_StopSync(restoreTracks)
if FastVault.SyncConnection then
_BH_FN.FV_DisconnectOne(FastVault.SyncConnection)
FastVault.SyncConnection = nil
end
if restoreTracks then
_BH_FN.FV_RestoreAnimationTracks()
_BH_FN.FV_RestoreNativeSpeed(false)
end
end
function _BH_FN.FV_ScheduleRestore()
FastVault.RestoreToken = FastVault.RestoreToken + 1
local token = FastVault.RestoreToken
task.delay(2.35, function()
if token ~= FastVault.RestoreToken then
return
end
if _BH_FN.FV_IsWindowVault(FastVault.Interact) then
return
end
if os.clock() <= FastVault.WindowJumpUntil then
return
end
_BH_FN.FV_StopSync(true)
end)
end
function _BH_FN.FV_StartSync()
if not FastVault.Enabled
or not FastVault.Animator then
return
end
_BH_FN.FV_StopSync(false)
local accumulator = 0
FastVault.SyncConnection =
_BH_FN.TrackConnection(
RunService.Heartbeat:Connect(function(dt)
if not HubRuntime.Alive
or not FastVault.Enabled
or not FastVault.Character
or not FastVault.Character.Parent then
_BH_FN.FV_StopSync(true)
return
end
if _BH_FN.FV_IsSliding(FastVault.Interact) then
_BH_FN.FV_StopSync(true)
return
end
local now = os.clock()
if not _BH_FN.FV_IsWindowVault(FastVault.Interact)
and now > FastVault.WindowJumpUntil then
_BH_FN.FV_StopSync(true)
return
end
accumulator = accumulator + dt
if accumulator < 0.035 then
return
end
accumulator = 0
_BH_FN.FV_ApplyNativeSpeed(
FastVault.Character
)
_BH_FN.FV_BoostPlayingVaultTracks()
end)
)
end
function _BH_FN.FV_OnVaultStarted()
if not FastVault.Enabled
or _BH_FN.FV_IsSliding(FastVault.Interact) then
return
end
local now = os.clock()
FastVault.RestoreToken = FastVault.RestoreToken + 1
FastVault.VaultWindowUntil = now + 1.45
FastVault.WindowJumpUntil = now + 2.20
_BH_FN.FV_ApplyNativeSpeed(
FastVault.Character
)
_BH_FN.FV_StartSync()
task.defer(function()
if FastVault.Enabled then
_BH_FN.FV_BoostPlayingVaultTracks()
end
end)
end
function _BH_FN.FV_AttachAnimator(char)
if FastVault.AnimatorConnection then
_BH_FN.FV_DisconnectOne(FastVault.AnimatorConnection)
FastVault.AnimatorConnection = nil
end
FastVault.Animator = nil
local humanoid =
char
and char:FindFirstChildOfClass("Humanoid")
if not humanoid then
return
end
local animator =
humanoid:FindFirstChildOfClass("Animator")
if not animator then
animator = humanoid:WaitForChild("Animator", 2)
end
if not animator then
return
end
FastVault.Animator = animator
FastVault.AnimatorConnection =
_BH_FN.TrackConnection(
animator.AnimationPlayed:Connect(function(track)
if not FastVault.Enabled
or _BH_FN.FV_IsSliding(FastVault.Interact) then
return
end
local now = os.clock()
if not _BH_FN.FV_IsWindowVault(FastVault.Interact)
and now > FastVault.WindowJumpUntil then
return
end
task.defer(function()
if FastVault.Enabled then
_BH_FN.FV_BoostTrack(track)
end
end)
end)
)
end
function _BH_FN.FV_Disconnect()
for _, key in ipairs({
"VaultStateConnection",
"VaultStateUpperConnection",
"SlideStateConnection",
"SlideStateUpperConnection",
"VaultBindableConnection",
"DescendantConnection",
"AnimatorConnection",
"SyncConnection",
}) do
if FastVault[key] then
_BH_FN.FV_DisconnectOne(FastVault[key])
FastVault[key] = nil
end
end
FastVault.RestoreToken = FastVault.RestoreToken + 1
FastVault.SlideToken = FastVault.SlideToken + 1
FastVault.SlideActive = false
FastVault.PalletSlideUntil = 0
FastVault.VaultWindowUntil = 0
FastVault.WindowJumpUntil = 0
_BH_FN.FV_RestoreAnimationTracks()
_BH_FN.FV_RestoreNativeSpeed(true)
FastVault.Character = nil
FastVault.Interact = nil
FastVault.Animator = nil
end
function _BH_FN.FV_AttachInteract(char, interact)
if not FastVault.Enabled
or not char
or not interact then
return
end
if FastVault.VaultStateConnection then
_BH_FN.FV_DisconnectOne(FastVault.VaultStateConnection)
FastVault.VaultStateConnection = nil
end
if FastVault.VaultStateUpperConnection then
_BH_FN.FV_DisconnectOne(
FastVault.VaultStateUpperConnection
)
FastVault.VaultStateUpperConnection = nil
end
if FastVault.SlideStateConnection then
_BH_FN.FV_DisconnectOne(FastVault.SlideStateConnection)
FastVault.SlideStateConnection = nil
end
if FastVault.SlideStateUpperConnection then
_BH_FN.FV_DisconnectOne(
FastVault.SlideStateUpperConnection
)
FastVault.SlideStateUpperConnection = nil
end
FastVault.Character = char
FastVault.Interact = interact
local function refreshVault()
if not FastVault.Enabled then
return
end
if _BH_FN.FV_IsWindowVault(interact) then
_BH_FN.FV_OnVaultStarted()
else
_BH_FN.FV_ScheduleRestore()
end
end
local function refreshSlide()
if not FastVault.Enabled then
return
end
_BH_FN.FV_OnPalletSlideState()
if _BH_FN.FV_IsSliding(interact) then
_BH_FN.FV_StopSync(true)
FastVault.VaultWindowUntil = 0
FastVault.WindowJumpUntil = 0
return
end
if _BH_FN.FV_IsWindowVault(interact) then
_BH_FN.FV_OnVaultStarted()
end
end
FastVault.VaultStateConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal(
"isVaulting"
):Connect(refreshVault)
)
FastVault.VaultStateUpperConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal(
"IsVaulting"
):Connect(refreshVault)
)
FastVault.SlideStateConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal(
"isSliding"
):Connect(refreshSlide)
)
FastVault.SlideStateUpperConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal(
"IsSliding"
):Connect(refreshSlide)
)
if _BH_FN.FV_IsWindowVault(interact) then
_BH_FN.FV_OnVaultStarted()
end
end
function _BH_FN.FV_BindCharacter(char)
if not FastVault.Enabled
or not char then
return
end
_BH_FN.FV_Disconnect()
FastVault.Character = char
local existingSpeed =
_BH_FN.FV_EnsureVaultSpeed(char)
FastVault.VaultSpeedWasNil = false
FastVault.OriginalVaultSpeed = existingSpeed
local windowRemotes =
Remotes:FindFirstChild("Window")
local vaultBindable =
windowRemotes
and windowRemotes:FindFirstChild(
"Vaultbindable"
)
if vaultBindable
and vaultBindable:IsA("BindableEvent") then
FastVault.VaultBindableConnection =
_BH_FN.TrackConnection(
vaultBindable.Event:Connect(function()
if FastVault.Enabled
and FastVault.Character == char then
_BH_FN.FV_OnVaultStarted()
end
end)
)
end
_BH_FN.FV_AttachAnimator(char)
local interact = _BH_FN.FV_GetInteract(char)
if interact then
_BH_FN.FV_AttachInteract(char, interact)
return
end
FastVault.DescendantConnection =
_BH_FN.TrackConnection(
char.DescendantAdded:Connect(function(obj)
if not FastVault.Enabled then
return
end
if obj.Name == "CheckInterractable" then
_BH_FN.FV_AttachInteract(char, obj)
end
end)
)
end
function toggleFastVault(state)
FastVault.Enabled = state == true
if FastVault.CharacterConnection then
_BH_FN.FV_DisconnectOne(
FastVault.CharacterConnection
)
FastVault.CharacterConnection = nil
end
if not FastVault.Enabled then
_BH_FN.FV_Disconnect()
_BH_FN.FV_RestoreProximityHook()
return
end
_BH_FN.FV_RestoreProximityHook()
if LocalPlayer.Character then
task.defer(
_BH_FN.FV_BindCharacter,
LocalPlayer.Character
)
end
FastVault.CharacterConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(char)
if not FastVault.Enabled then
return
end
task.wait(0.20)
if FastVault.Enabled then
_BH_FN.FV_BindCharacter(char)
end
end)
)
end
function _BH_FN.ASV_DisconnectOne(connection)
if not connection then return end
pcall(function() connection:Disconnect() end)
_BH_FN.ForgetConnection(connection)
end
function _BH_FN.ASV_IsBusy(char, interact)
if not char then return true end
local root =
char:FindFirstChild("HumanoidRootPart")
if not root or root.Anchored then
return true
end
if char:GetAttribute("IsHooked")
or char:GetAttribute("IsCarried")
or char:GetAttribute("MovementLocked") then
return true
end
if interact then
for _, attr in ipairs({
"isRepairing",
"isHealing",
"isSliding",
"IsSliding",
"isDroppingPallet",
"isUnhooking",
"isExiting",
}) do
if interact:GetAttribute(attr) then
return true
end
end
end
return false
end
function _BH_FN.ASV_IsSliding(interact)
return interact ~= nil
and (
interact:GetAttribute("isSliding") == true
or interact:GetAttribute("IsSliding") == true
)
end
function _BH_FN.ASV_GetExpectedSpeed(char)
local captured =
tonumber(
AntiSlowVault.CapturedWalkSpeed
)
if captured
and captured
>= AntiSlowVault.MinUsefulSpeed then
return math.clamp(
captured,
AntiSlowVault.MinUsefulSpeed,
60
)
end
local base = 10
if char:GetAttribute("Crouching") then
base = 6
elseif char:GetAttribute("Sprinting") then
base = 17
end
local boost =
tonumber(
char:GetAttribute("speedboost")
) or 1
return math.clamp(
base * boost,
AntiSlowVault.MinUsefulSpeed,
60
)
end
function _BH_FN.ASV_TryRestore(generation)
if not AntiSlowVault.Enabled
or generation ~= AntiSlowVault.Generation
or os.clock() > AntiSlowVault.GuardUntil then
return
end
local char = AntiSlowVault.Character
local hum = AntiSlowVault.Humanoid
local interact = AntiSlowVault.Interact
if not char or not char.Parent
or not hum or hum.Health <= 0
or _BH_FN.ASV_IsBusy(char, interact) then
return
end
if hum.Health <= 50
and not AntiKnockdown.Enabled then
return
end
if interact
and (interact:GetAttribute("isVaulting")
or interact:GetAttribute("IsVaulting")
or _BH_FN.ASV_IsSliding(interact)) then
return
end
local expected =
_BH_FN.ASV_GetExpectedSpeed(char)
local controller =
_BH_FN.AK_FindAnimationController
and _BH_FN.AK_FindAnimationController(
char,
hum
)
if controller then
pcall(function()
controller.cantupdatespeed = false
controller.isSlowedFromFall = false
controller.targetBaseWalkSpeed = expected
controller.smoothedBaseWalkSpeed = expected
end)
end
if hum.WalkSpeed < expected * 0.96 then
pcall(function()
hum.WalkSpeed = expected
end)
end
end
function _BH_FN.ASV_BeginSlowGuard(duration)
if not AntiSlowVault.Enabled then
return
end
local hum = AntiSlowVault.Humanoid
AntiSlowVault.CapturedWalkSpeed = math.clamp(
tonumber(AntiSlowVault.LastFreeWalkSpeed) or 10,
AntiSlowVault.MinUsefulSpeed,
60
)
AntiSlowVault.Generation = AntiSlowVault.Generation + 1
local generation = AntiSlowVault.Generation
local nativeDuration = math.clamp(
tonumber(duration) or 0,
0,
15
)
AntiSlowVault.GuardUntil = math.max(
AntiSlowVault.GuardUntil,
os.clock() + nativeDuration + 0.85
)
task.defer(function()
_BH_FN.ASV_TryRestore(generation)
end)
end
function _BH_FN.ASV_OnVaultState()
if not AntiSlowVault.Enabled then return end
local interact = AntiSlowVault.Interact
if not interact then return end
local vaulting = interact:GetAttribute("isVaulting") == true
if vaulting then
local hum = AntiSlowVault.Humanoid
if hum
and hum.WalkSpeed
>= AntiSlowVault.MinUsefulSpeed then
AntiSlowVault.PendingWalkSpeed =
hum.WalkSpeed
AntiSlowVault.LastFreeWalkSpeed =
hum.WalkSpeed
else
AntiSlowVault.PendingWalkSpeed =
AntiSlowVault.LastFreeWalkSpeed
end
return
end
if not AntiSlowVault.WasVaulting
or not AntiSlowVault.WindowVaultActive then
return
end
AntiSlowVault.WasVaulting = false
AntiSlowVault.WindowVaultActive = false
AntiSlowVault.Generation = AntiSlowVault.Generation + 1
local generation = AntiSlowVault.Generation
AntiSlowVault.GuardUntil =
os.clock()
+ AntiSlowVault.GuardDuration
for _, delaySeconds in ipairs({
0,
0.04,
0.10,
0.18,
0.36,
0.70,
1.20,
2.00,
3.50,
4.80,
}) do
task.delay(delaySeconds, function()
_BH_FN.ASV_TryRestore(generation)
end)
end
end
function _BH_FN.ASV_OnWindowVault()
if not AntiSlowVault.Enabled then
return
end
local interact = AntiSlowVault.Interact
if not interact
or not interact:GetAttribute("isVaulting") then
return
end
local captured =
tonumber(AntiSlowVault.PendingWalkSpeed)
or tonumber(AntiSlowVault.LastFreeWalkSpeed)
or 10
AntiSlowVault.CapturedWalkSpeed =
math.clamp(
captured,
AntiSlowVault.MinUsefulSpeed,
60
)
AntiSlowVault.WasVaulting = true
AntiSlowVault.WindowVaultActive = true
AntiSlowVault.GuardUntil = 0
AntiSlowVault.Generation =
AntiSlowVault.Generation + 1
end
function _BH_FN.ASV_OnSlideState()
if not AntiSlowVault.Enabled then
return
end
local interact = AntiSlowVault.Interact
local hum = AntiSlowVault.Humanoid
if not interact or not hum then
return
end
if _BH_FN.ASV_IsSliding(interact) then
if not AntiSlowVault.SlideWasActive
and hum.WalkSpeed >= AntiSlowVault.MinUsefulSpeed then
AntiSlowVault.PendingWalkSpeed = hum.WalkSpeed
AntiSlowVault.LastFreeWalkSpeed = hum.WalkSpeed
end
AntiSlowVault.SlideWasActive = true
AntiSlowVault.WasVaulting = false
AntiSlowVault.WindowVaultActive = false
AntiSlowVault.GuardUntil = 0
AntiSlowVault.Generation =
AntiSlowVault.Generation + 1
return
end
if not AntiSlowVault.SlideWasActive then
return
end
AntiSlowVault.SlideWasActive = false
AntiSlowVault.CapturedWalkSpeed = math.clamp(
tonumber(AntiSlowVault.PendingWalkSpeed)
or tonumber(AntiSlowVault.LastFreeWalkSpeed)
or 10,
AntiSlowVault.MinUsefulSpeed,
60
)
AntiSlowVault.Generation =
AntiSlowVault.Generation + 1
local generation = AntiSlowVault.Generation
AntiSlowVault.GuardUntil = os.clock() + 3.25
for _, delaySeconds in ipairs({
0,
0.05,
0.12,
0.25,
0.50,
0.90,
1.50,
2.40,
3.10,
}) do
task.delay(delaySeconds, function()
_BH_FN.ASV_TryRestore(generation)
end)
end
end
function _BH_FN.ASV_UnbindCharacter()
for _, key in ipairs({
"VaultConnection",
"VaultBindableConnection",
"SlideConnection",
"SlideUpperConnection",
"SlowConnection",
"SlowServerConnection",
"DescendantConnection",
"HeartbeatConnection",
}) do
local connection = AntiSlowVault[key]
if connection then
_BH_FN.ASV_DisconnectOne(connection)
AntiSlowVault[key] = nil
end
end
AntiSlowVault.Character = nil
AntiSlowVault.Humanoid = nil
AntiSlowVault.Interact = nil
AntiSlowVault.WasVaulting = false
AntiSlowVault.WindowVaultActive = false
AntiSlowVault.SlideWasActive = false
AntiSlowVault.GuardUntil = 0
end
function _BH_FN.ASV_BindCharacter(char)
_BH_FN.ASV_UnbindCharacter()
if not AntiSlowVault.Enabled or not char then
return
end
local hum = char:FindFirstChildOfClass("Humanoid")
local interact =
_BH_FN.GB_GetClientInteract(char)
if not hum then return end
AntiSlowVault.Character = char
AntiSlowVault.Humanoid = hum
if hum.WalkSpeed >= AntiSlowVault.MinFreeSample then
AntiSlowVault.LastFreeWalkSpeed = hum.WalkSpeed
AntiSlowVault.CapturedWalkSpeed = hum.WalkSpeed
end
if not interact then
AntiSlowVault.DescendantConnection =
_BH_FN.TrackConnection(
char.DescendantAdded:Connect(function(obj)
if AntiSlowVault.Enabled
and (
obj.Name == "CheckInterractable"
or obj.Name == "CheckInteractable"
) then
task.defer(
_BH_FN.ASV_BindCharacter,
char
)
end
end)
)
return
end
AntiSlowVault.Interact = interact
AntiSlowVault.VaultConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal("isVaulting")
:Connect(_BH_FN.ASV_OnVaultState)
)
local remotes =
ReplicatedStorage:FindFirstChild("Remotes")
local windowRemotes =
remotes
and remotes:FindFirstChild("Window")
local mechanicsRemotes =
remotes
and remotes:FindFirstChild("Mechanics")
local slow =
mechanicsRemotes
and mechanicsRemotes:FindFirstChild("Slow")
if slow and slow:IsA("BindableEvent") then
AntiSlowVault.SlowConnection =
_BH_FN.TrackConnection(
slow.Event:Connect(function(_, duration, secondDuration)
_BH_FN.ASV_BeginSlowGuard(
(tonumber(duration) or 0)
+ (tonumber(secondDuration) or 0)
)
end)
)
end
local slowServer =
mechanicsRemotes
and mechanicsRemotes:FindFirstChild("Slowserver")
if slowServer and slowServer:IsA("RemoteEvent") then
AntiSlowVault.SlowServerConnection =
_BH_FN.TrackConnection(
slowServer.OnClientEvent:Connect(function(_, duration)
_BH_FN.ASV_BeginSlowGuard(duration)
end)
)
end
local vaultBindable =
windowRemotes
and windowRemotes:FindFirstChild("Vaultbindable")
if vaultBindable
and vaultBindable:IsA("BindableEvent") then
AntiSlowVault.VaultBindableConnection =
_BH_FN.TrackConnection(
vaultBindable.Event:Connect(
_BH_FN.ASV_OnWindowVault
)
)
end
AntiSlowVault.SlideConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal("isSliding")
:Connect(_BH_FN.ASV_OnSlideState)
)
AntiSlowVault.SlideUpperConnection =
_BH_FN.TrackConnection(
interact:GetAttributeChangedSignal("IsSliding")
:Connect(_BH_FN.ASV_OnSlideState)
)
local accumulator = 0
AntiSlowVault.HeartbeatConnection =
_BH_FN.TrackConnection(
RunService.RenderStepped:Connect(function(dt)
if not HubRuntime.Alive
or not AntiSlowVault.Enabled
or not hum.Parent then
return
end
accumulator = accumulator + dt
if accumulator
< AntiSlowVault.SampleInterval then
return
end
accumulator = 0
if os.clock()
<= AntiSlowVault.GuardUntil then
_BH_FN.ASV_TryRestore(
AntiSlowVault.Generation
)
return
end
if not interact:GetAttribute("isVaulting")
and not _BH_FN.ASV_IsBusy(char, interact)
and hum.Health > 50
and hum.WalkSpeed
>= AntiSlowVault.MinFreeSample then
AntiSlowVault.LastFreeWalkSpeed = hum.WalkSpeed
end
end)
)
end
function _BH_FN.ASV_SetEnabled(state)
AntiSlowVault.Enabled = state == true
AntiSlowVault.Generation = AntiSlowVault.Generation + 1
if AntiSlowVault.CharacterConnection then
_BH_FN.ASV_DisconnectOne(AntiSlowVault.CharacterConnection)
AntiSlowVault.CharacterConnection = nil
end
_BH_FN.ASV_UnbindCharacter()
if not AntiSlowVault.Enabled then
return
end
if LocalPlayer.Character then
_BH_FN.ASV_BindCharacter(LocalPlayer.Character)
end
AntiSlowVault.CharacterConnection =
_BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.25)
if AntiSlowVault.Enabled then
_BH_FN.ASV_BindCharacter(char)
end
end)
)
end
function _BH_FN.getCurrentToFFireRemote()
if ToFFireRemote and ToFFireRemote.Parent then
return ToFFireRemote
end
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local items = remotes and remotes:FindFirstChild("Items")
local tof = items and items:FindFirstChild("Twist of Fate")
ToFFireRemote = tof and tof:FindFirstChild("Fire")
return ToFFireRemote
end
function _BH_FN.isToFTool(tool)
if not tool or not tool:IsA("Tool") then return false end
local n = string.lower(tool.Name)
return (n:find("twist", 1, true) ~= nil
and n:find("fate", 1, true) ~= nil)
or n:find("pistol", 1, true) ~= nil
or n:find("revolver", 1, true) ~= nil
or n:find("handgun", 1, true) ~= nil
or tool:GetAttribute("IsGun") == true
or tool:GetAttribute("WeaponType") == "Pistol"
end
function _BH_FN.getToolMuzzle(tool)
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
function _BH_FN.getNetworkPingSeconds()
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
function _BH_FN.getAimAssistTarget(
origin
)
if not ToolAimAssist.Enabled
or not _BH_FN.AIM_LocalCanAssist() then
return nil
end
local cam =
workspace.CurrentCamera
local myChar =
LocalPlayer.Character
if not cam
or not myChar
or not origin then
return nil
end
local targetRole =
_BH_FN.AIM_ResolveTargetRole(
ToolAimAssist.TargetMode
)
if not targetRole then
return nil
end
local viewport =
cam.ViewportSize
local center =
Vector2.new(
viewport.X * 0.5,
viewport.Y * 0.5
)
local function evaluate(part, extraFOV)
if not part
or not part.Parent
or not part:IsA("BasePart") then
return nil
end
local char =
part.Parent
local player =
Players:GetPlayerFromCharacter(
char
)
if not player
or _BH_FN.AIM_IsUnavailable(char) then
return nil
end
if not _BH_FN.AIM_MatchesTargetRole(
player,
targetRole
) then
return nil
end
local worldDistance =
(
part.Position
- origin
).Magnitude
if worldDistance
> ToolAimAssist.Range then
return nil
end
local predicted =
ToolAimAssist.Prediction
and _BH_FN.AIM_GetPredictedPosition(
part,
worldDistance,
ToolAimAssist.PredictionTime,
ToolAimAssist.VelocityCap
)
or part.Position
local screen,
onScreen =
cam:WorldToViewportPoint(
predicted
)
if not onScreen
or screen.Z <= 0 then
return nil
end
local screenDistance =
(
Vector2.new(
screen.X,
screen.Y
)
- center
).Magnitude
if ToolAimAssist.UseFOV
and screenDistance
> SharedAimFOV.Value
+ (extraFOV or 0) then
return nil
end
local parts =
_BH_FN.AIM_GetCandidateParts(
char,
part.Name
)
local visibleSamples =
ToolAimAssist.WallCheck
and _BH_FN.AIM_GetVisibleSampleCount(
origin,
myChar,
char,
parts
)
or #parts
if visibleSamples <= 0 then
return nil
end
local score
if ToolAimAssist.UseFOV then
score =
screenDistance
+ worldDistance * 0.025
else
score =
worldDistance
+ screenDistance * 0.04
end
score = score - math.min(
visibleSamples,
3
) * 1.5
return {
Part = part,
Distance = worldDistance,
Score = score,
}
end
local current = nil
if ToolAimAssist.StableTarget
and ToolAimAssist.LastTarget then
current =
evaluate(
ToolAimAssist.LastTarget,
ToolAimAssist.StickyExtraPixels
)
end
local best = nil
for _, player in ipairs(
Players:GetPlayers()
) do
if player ~= LocalPlayer
and player.Character
and _BH_FN.AIM_MatchesTargetRole(
player,
targetRole
)
and not _BH_FN.AIM_IsUnavailable(
player.Character
) then
local char =
player.Character
local result = nil
for _, part in ipairs(
_BH_FN.AIM_GetCandidateParts(
char,
ToolAimAssist.TargetPart
)
) do
local candidate =
evaluate(
part,
0
)
if candidate
and (
not result
or candidate.Score
< result.Score
) then
result =
candidate
end
end
if result
and (
not best
or result.Score
< best.Score
) then
best = result
end
end
end
if current then
if not best
or current.Score
<= best.Score
+ ToolAimAssist.TargetSwitchMargin then
return current.Part,
current.Distance
end
end
return best
and best.Part
or nil,
best
and best.Distance
or math.huge
end
function _BH_FN.getPredictedAimPosition(
part,
origin,
distance
)
if not part then
return nil
end
if not ToolAimAssist.Prediction then
return part.Position
end
local worldDistance =
distance
or (
part.Position
- origin
).Magnitude
local travelTime =
worldDistance
/ math.max(
tonumber(ToolAimAssist.BulletSpeed) or 200,
1
)
local predictionTime = math.clamp(
math.max(
ToolAimAssist.PredictionTime,
travelTime
)
* math.max(
tonumber(ToolAimAssist.PredictionScale) or 1,
0
)
+ _BH_FN.getNetworkPingSeconds() * 0.5,
0,
0.28
)
return _BH_FN.AIM_GetPredictedPosition(
part,
worldDistance,
predictionTime,
ToolAimAssist.VelocityCap
)
end
function _BH_FN.showToolAimTracer(fromPos, toPos)
if not ToolAimAssist.Tracer or not fromPos or not toPos then return end
local tracer = ToolAimAssist.TracerPart
if not tracer or not tracer.Parent then
tracer = _BH_FN.TrackArtifact(Instance.new("Part"))
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
rewriteToFFireArgs = function(remote, originalArgs)
if not (SilentAim.Enabled or ToolAimAssist.Enabled)
or type(originalArgs) ~= "table" then
return nil
end
local fireRemote =
_BH_FN.getCurrentToFFireRemote()
if not fireRemote
or remote ~= fireRemote then
return nil
end
local char = LocalPlayer.Character
local tool = char
and char:FindFirstChildOfClass("Tool")
local muzzle =
_BH_FN.getToolMuzzle(tool)
local camera = workspace.CurrentCamera
local root = char
and char:FindFirstChild("HumanoidRootPart")
local origin = muzzle
and muzzle.Position
or (camera and camera.CFrame.Position)
or (root and root.Position)
if not origin then
return nil
end
local targetPart
local distance = math.huge
local cachedTarget = ToolAimAssist.LastTarget
if cachedTarget
and cachedTarget.Parent
and os.clock() - ToolAimAssist.LastTargetAt <= 0.18 then
targetPart = cachedTarget
distance = (cachedTarget.Position - origin).Magnitude
else
targetPart, distance =
_BH_FN.getAimAssistTarget(origin)
end
if not targetPart and SilentAim.Enabled then
targetPart = _BH_FN.getSilentTarget()
distance = targetPart
and (targetPart.Position - origin).Magnitude
or math.huge
end
if not targetPart then
ToolAimAssist.LastTarget = nil
ToolAimAssist.LastTargetAt = 0
return nil
end
ToolAimAssist.LastTarget = targetPart
ToolAimAssist.LastTargetAt = os.clock()
local targetPosition =
_BH_FN.getPredictedAimPosition(
targetPart,
origin,
distance
)
if not targetPosition then
return nil
end
local args = {n = originalArgs.n or #originalArgs}
local vectorCount = 0
for index = 1, args.n do
args[index] = originalArgs[index]
if typeof(originalArgs[index]) == "Vector3" then
vectorCount = vectorCount + 1
end
end
local changed = false
local sawOriginVector = false
local function aimedDirection(from, originalDirection)
local delta = targetPosition - from
if delta.Magnitude <= 0.01 then
return originalDirection
end
local length = originalDirection.Magnitude
if length <= 0.01 then
length = 1
end
return delta.Unit * length
end
local function rewritePayload(payload)
local copy = {}
local payloadChanged = false
for key, value in pairs(payload) do
copy[key] = value
local keyName = string.lower(tostring(key))
local kind = typeof(value)
local isOriginKey =
string.find(keyName, "origin", 1, true)
or string.find(keyName, "start", 1, true)
or string.find(keyName, "from", 1, true)
local isDirectionKey =
string.find(keyName, "direction", 1, true)
or string.find(keyName, "unitray", 1, true)
local isTargetKey =
string.find(keyName, "target", 1, true)
or string.find(keyName, "hit", 1, true)
or string.find(keyName, "position", 1, true)
or string.find(keyName, "point", 1, true)
or string.find(keyName, "mouse", 1, true)
if kind == "Vector3"
and not isOriginKey then
copy[key] = isDirectionKey
and aimedDirection(origin, value)
or (isTargetKey and targetPosition or value)
payloadChanged =
isDirectionKey or isTargetKey or payloadChanged
elseif kind == "CFrame"
and not isOriginKey
and isTargetKey then
copy[key] = CFrame.new(targetPosition)
payloadChanged = true
elseif kind == "Ray" then
copy[key] = Ray.new(
value.Origin,
aimedDirection(
value.Origin,
value.Direction
)
)
payloadChanged = true
elseif kind == "Instance"
and value:IsA("BasePart")
and isTargetKey then
copy[key] = targetPart
payloadChanged = true
end
end
return payloadChanged and copy or payload,
payloadChanged
end
for index = 1, args.n do
local value = args[index]
local kind = typeof(value)
if kind == "Vector3" then
local nearOrigin =
(value - origin).Magnitude <= 6
if nearOrigin and vectorCount > 1 then
sawOriginVector = true
elseif value.Magnitude <= 1.5 then
args[index] =
aimedDirection(origin, value)
changed = true
elseif sawOriginVector
and (value - origin).Magnitude
> ToolAimAssist.Range * 1.5 then
args[index] =
aimedDirection(origin, value)
changed = true
else
args[index] = targetPosition
changed = true
end
elseif kind == "CFrame" then
local position = value.Position
if (position - origin).Magnitude <= 6
and args.n > 1 then
args[index] = CFrame.lookAt(
position,
targetPosition,
value.UpVector
)
else
args[index] = CFrame.new(targetPosition)
* value.Rotation
end
changed = true
elseif kind == "Ray" then
args[index] = Ray.new(
value.Origin,
aimedDirection(
value.Origin,
value.Direction
)
)
changed = true
elseif kind == "Instance"
and value:IsA("BasePart")
and not (char and value:IsDescendantOf(char)) then
args[index] = targetPart
changed = true
elseif kind == "table" then
local rewritten, payloadChanged =
rewritePayload(value)
if payloadChanged then
args[index] = rewritten
changed = true
end
end
end
if changed then
_BH_FN.showToolAimTracer(
origin,
targetPosition
)
return args
end
return nil
end
function _BH_FN.onToFToolActivated(tool)
if not ToolAimAssist.Enabled then return end
local muzzle = _BH_FN.getToolMuzzle(tool)
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local origin = muzzle and muzzle.Position or (root and root.Position)
if not origin then return end
local targetPart, distance = _BH_FN.getAimAssistTarget(origin)
if not targetPart then
ToolAimAssist.LastTarget = nil
ToolAimAssist.LastTargetAt = 0
return
end
ToolAimAssist.LastTarget = targetPart
ToolAimAssist.LastTargetAt = os.clock()
local targetPos = _BH_FN.getPredictedAimPosition(targetPart, origin, distance)
if not targetPos then return end
_BH_FN.AIM_ApplyCameraAssist(targetPos, 0.88)
_BH_FN.showToolAimTracer(origin, targetPos)
end
function _BH_FN.updateGeneralToolAim()
if not ToolAimAssist.Enabled
or not _BH_FN.AIM_LocalCanAssist() then
return
end
local char = LocalPlayer.Character
local tool =
char
and char:FindFirstChildOfClass("Tool")
if not _BH_FN.isToFTool(tool) then
ToolAimAssist.LastTarget = nil
return
end
local camera = workspace.CurrentCamera
local muzzle = _BH_FN.getToolMuzzle(tool)
local root =
char:FindFirstChild("HumanoidRootPart")
local origin =
muzzle and muzzle.Position
or camera and camera.CFrame.Position
or root and root.Position
if not origin then return end
local targetPart, distance =
_BH_FN.getAimAssistTarget(origin)
if not targetPart then
ToolAimAssist.LastTarget = nil
return
end
ToolAimAssist.LastTarget = targetPart
local targetPosition =
_BH_FN.getPredictedAimPosition(
targetPart,
origin,
distance
)
if targetPosition then
_BH_FN.AIM_ApplyCameraAssist(
targetPosition,
ToolAimAssist.CameraStrength
)
end
end
function _BH_FN.bindToolAimAssist(tool)
if not _BH_FN.isToFTool(tool) or ToolAimAssist.ToolConnections[tool] then return end
ToolAimAssist.ToolConnections[tool] = _BH_FN.TrackConnection(tool.Activated:Connect(function()
if HubRuntime.Alive then _BH_FN.onToFToolActivated(tool) end
end))
_BH_FN.TrackConnection(tool.AncestryChanged:Connect(function(_, parent)
if not parent then
local conn = ToolAimAssist.ToolConnections[tool]
if conn then
pcall(function() conn:Disconnect() end)
end
_BH_FN.ForgetConnection(conn)
ToolAimAssist.ToolConnections[tool] = nil
end
end))
end
function _BH_FN.scanAimAssistTools()
local char = LocalPlayer.Character
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if char then
for _, obj in ipairs(char:GetChildren()) do
_BH_FN.bindToolAimAssist(obj)
end
end
if backpack then
for _, obj in ipairs(backpack:GetChildren()) do
_BH_FN.bindToolAimAssist(obj)
end
end
end
function _BH_FN.stopToolAimAssistListeners()
if ToolAimAssist.RenderConnection then
pcall(function()
ToolAimAssist.RenderConnection:Disconnect()
end)
_BH_FN.ForgetConnection(
ToolAimAssist.RenderConnection
)
ToolAimAssist.RenderConnection = nil
end
if ToolAimAssist.CharacterConn then
pcall(function()
ToolAimAssist.CharacterConn:Disconnect()
end)
_BH_FN.ForgetConnection(
ToolAimAssist.CharacterConn
)
ToolAimAssist.CharacterConn = nil
end
if ToolAimAssist.PlayerCharacterConn then
pcall(function()
ToolAimAssist.PlayerCharacterConn:Disconnect()
end)
_BH_FN.ForgetConnection(
ToolAimAssist.PlayerCharacterConn
)
ToolAimAssist.PlayerCharacterConn = nil
end
if ToolAimAssist.BackpackConn then
pcall(function()
ToolAimAssist.BackpackConn:Disconnect()
end)
_BH_FN.ForgetConnection(
ToolAimAssist.BackpackConn
)
ToolAimAssist.BackpackConn = nil
end
local connections = {}
for tool, conn in pairs(
ToolAimAssist.ToolConnections
) do
connections[#connections + 1] =
{tool, conn}
end
for _, entry in ipairs(
connections
) do
local tool =
entry[1]
local conn =
entry[2]
if conn then
pcall(function()
conn:Disconnect()
end)
_BH_FN.ForgetConnection(conn)
end
ToolAimAssist.ToolConnections[tool] =
nil
end
ToolAimAssist.LastTarget = nil
ToolAimAssist.LastTargetAt = 0
if ToolAimAssist.TracerPart
and ToolAimAssist.TracerPart.Parent then
ToolAimAssist.TracerPart.Transparency = 1
end
end
function _BH_FN.setupToolAimAssistListeners()
if ToolAimAssist.CharacterConn then
pcall(function() ToolAimAssist.CharacterConn:Disconnect() end)
end
if ToolAimAssist.BackpackConn then
pcall(function() ToolAimAssist.BackpackConn:Disconnect() end)
end
if ToolAimAssist.PlayerCharacterConn then
pcall(function() ToolAimAssist.PlayerCharacterConn:Disconnect() end)
_BH_FN.ForgetConnection(ToolAimAssist.PlayerCharacterConn)
ToolAimAssist.PlayerCharacterConn = nil
end
if ToolAimAssist.RenderConnection then
pcall(function()
ToolAimAssist.RenderConnection:Disconnect()
end)
_BH_FN.ForgetConnection(
ToolAimAssist.RenderConnection
)
ToolAimAssist.RenderConnection = nil
end
local char = LocalPlayer.Character
if char then
ToolAimAssist.CharacterConn = _BH_FN.TrackConnection(
char.ChildAdded:Connect(_BH_FN.bindToolAimAssist)
)
end
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if backpack then
ToolAimAssist.BackpackConn = _BH_FN.TrackConnection(
backpack.ChildAdded:Connect(_BH_FN.bindToolAimAssist)
)
end
ToolAimAssist.PlayerCharacterConn = _BH_FN.TrackConnection(
LocalPlayer.CharacterAdded:Connect(function(newChar)
task.wait(0.2)
if not HubRuntime.Alive or not ToolAimAssist.Enabled then
return
end
if ToolAimAssist.CharacterConn then
pcall(function()
ToolAimAssist.CharacterConn:Disconnect()
end)
_BH_FN.ForgetConnection(ToolAimAssist.CharacterConn)
end
ToolAimAssist.CharacterConn = _BH_FN.TrackConnection(
newChar.ChildAdded:Connect(_BH_FN.bindToolAimAssist)
)
_BH_FN.scanAimAssistTools()
end)
)
ToolAimAssist.LastCameraTick = 0
ToolAimAssist.RenderConnection = _BH_FN.TrackConnection(
RunService.RenderStepped:Connect(function()
if not HubRuntime.Alive or not ToolAimAssist.Enabled then
return
end
local now = os.clock()
if now - ToolAimAssist.LastCameraTick < 0.05 then
return
end
ToolAimAssist.LastCameraTick = now
_BH_FN.updateGeneralToolAim()
end)
)
_BH_FN.scanAimAssistTools()
end
local NEXT_KILLER_SCORE_NAMES = {
sinpoints = 100,
sinpoint = 95,
sins = 90,
sin = 85,
killerpoints = 80,
killerchancepoints = 78,
killerpriority = 70,
killerchance = 60,
sinamount = 58,
sinvalue = 56,
}
local NEXT_KILLER_NEGATIVE_FLAGS = {
antikiller = true,
antikillerchance = true,
disablekiller = true,
disabledkiller = true,
disablekillerchance = true,
killerdisabled = true,
nokiller = true,
nokillerchance = true,
killeroff = true,
optoutkiller = true,
killeroptout = true,
}
local NEXT_KILLER_POSITIVE_FLAGS = {
killerchanceenabled = true,
killerchanceactive = true,
killerchanceon = true,
allowkiller = true,
canbekiller = true,
killereligible = true,
}
local NEXT_KILLER_DATA_CONTAINERS = {
leaderstats = true,
data = true,
stats = true,
playerdata = true,
profile = true,
settings = true,
preferences = true,
config = true,
configuration = true,
options = true,
values = true,
replicateddata = true,
}
local function nextKillerKey(value)
return string.lower(tostring(value or "")):gsub("[^%w]", "")
end
local function nextKillerBool(value)
if type(value) == "boolean" then return value end
if type(value) == "number" then return value ~= 0 end
local normalized = string.lower(tostring(value or ""))
if normalized == "true" or normalized == "on"
or normalized == "enabled" or normalized == "yes" then
return true
end
if normalized == "false" or normalized == "off"
or normalized == "disabled" or normalized == "no" then
return false
end
return nil
end
local function forEachNextKillerDataObject(player, callback)
callback(player)
for _, child in ipairs(player:GetChildren()) do
local childKey = nextKillerKey(child.Name)
local include = child:IsA("ValueBase")
or child:IsA("Folder")
or child:IsA("Configuration")
or NEXT_KILLER_DATA_CONTAINERS[childKey] == true
if include then
callback(child)
for _, descendant in ipairs(child:GetDescendants()) do
callback(descendant)
end
end
end
end
function _BH_FN.UI_ReadSinPoints(player)
local bestScore = nil
local bestPriority = -1
local function consider(name, value)
local priority = NEXT_KILLER_SCORE_NAMES[nextKillerKey(name)]
local score = tonumber(value)
if not priority or not score or score ~= score then return end
if priority > bestPriority then
bestPriority = priority
bestScore = math.max(0, math.floor(score + 0.5))
end
end
forEachNextKillerDataObject(player, function(object)
for name, value in pairs(object:GetAttributes()) do
consider(name, value)
end
if object:IsA("IntValue") or object:IsA("NumberValue") then
consider(object.Name, object.Value)
end
end)
return bestScore
end
function _BH_FN.UI_IsKillerEligible(player)
local explicitEligibility = nil
local function consider(name, value)
local key = nextKillerKey(name)
local state = nextKillerBool(value)
if state == nil then return end
if NEXT_KILLER_NEGATIVE_FLAGS[key] then
if state then
explicitEligibility = false
elseif explicitEligibility == nil then
explicitEligibility = true
end
elseif NEXT_KILLER_POSITIVE_FLAGS[key] then
if not state then
explicitEligibility = false
elseif explicitEligibility == nil then
explicitEligibility = true
end
end
end
forEachNextKillerDataObject(player, function(object)
for name, value in pairs(object:GetAttributes()) do
consider(name, value)
end
if object:IsA("BoolValue") or object:IsA("StringValue") then
consider(object.Name, object.Value)
end
end)
return explicitEligibility ~= false
end
function _BH_FN.UI_IsRoundInProgress()
for _, player in ipairs(Players:GetPlayers()) do
local teamName = player.Team
and string.lower(tostring(player.Team.Name))
or ""
if string.find(teamName, "killer", 1, true)
or string.find(teamName, "survivor", 1, true) then
return true
end
end
local ok, localRole = pcall(_BH_FN.UI_GetMouseRole)
return ok
and (localRole == "Killer" or localRole == "Survivor")
end
function _BH_FN.UI_GetNextKillerText()
if _BH_FN.UI_IsRoundInProgress() then
local ok, currentRole = pcall(_BH_FN.UI_GetMouseRole)
return "In Game", ok and currentRole == "Killer"
end
local serverPlayers = Players:GetPlayers()
local knownScores = 0
local candidates = {}
for _, player in ipairs(serverPlayers) do
local score = _BH_FN.UI_ReadSinPoints(player)
if score ~= nil then
knownScores = knownScores + 1
if _BH_FN.UI_IsKillerEligible(player) then
candidates[#candidates + 1] = {
Player = player,
Score = score,
}
end
end
end
if knownScores < #serverPlayers then
return string.format(
"Next • Unknown (%d/%d)",
knownScores,
#serverPlayers
), false
end
if #candidates == 0 then
return "Next • No eligible", false
end
table.sort(candidates, function(first, second)
if first.Score == second.Score then
return first.Player.Name < second.Player.Name
end
return first.Score > second.Score
end)
local highest = candidates[1].Score
local tiedNames = {}
for _, candidate in ipairs(candidates) do
if candidate.Score ~= highest then break end
tiedNames[#tiedNames + 1] = candidate.Player.Name
end
if #tiedNames > 1 then
local shown = table.concat(tiedNames, " / ", 1, math.min(2, #tiedNames))
if #tiedNames > 2 then
shown = shown .. " +" .. tostring(#tiedNames - 2)
end
local localPlayerIsTied = false
for _, candidate in ipairs(candidates) do
if candidate.Score ~= highest then break end
if candidate.Player == LocalPlayer then
localPlayerIsTied = true
break
end
end
return "Next • " .. shown, localPlayerIsTied
end
return "Next • " .. candidates[1].Player.Name,
candidates[1].Player == LocalPlayer
end
UIBox.AboutInfo:AddLabel("Bluehaven Hub", true)
UIBox.AboutInfo:AddLabel("Violence District • v0.0.1", true)
UIBox.AboutInfo:AddLabel("Compact WindUI untuk PC dan Android.", true)
task.spawn(function()
while HubRuntime.Alive do
local nextKillerLabel = _BH_FN.UI_TopbarNextKillerLabel
if not nextKillerLabel or not nextKillerLabel.Parent then
pcall(_BH_FN.UI_CreateVIPBadge)
nextKillerLabel = _BH_FN.UI_TopbarNextKillerLabel
end
local ok, text, localPlayerIsKiller =
pcall(_BH_FN.UI_GetNextKillerText)
if nextKillerLabel and nextKillerLabel.Parent then
nextKillerLabel.Text = ok and text or "Next • Unknown"
end
local nextKillerDot = _BH_FN.UI_TopbarNextKillerDot
if nextKillerDot and nextKillerDot.Parent then
nextKillerDot.BackgroundColor3 =
ok and localPlayerIsKiller
and HeaderStyle.Status.SurvivorColor
or HeaderStyle.Status.KillerColor
end
task.wait(2)
end
end)
UIBox.AboutControl:AddLabel("Buka / tutup UI: RightShift", true)
UIBox.AboutControl:AddLabel("Saat UI terbuka, mouse selalu bebas.", true)
UIBox.AboutControl:AddLabel("UI tertutup: Survivor/Killer lock, Spectator tetap bebas.", true)
function _BH_FN.UI_SelectAbout()
local rawTab = Tabs
and Tabs.About
and Tabs.About.Raw
if not rawTab then
return false
end
if type(rawTab.Select) == "function" then
local ok = pcall(rawTab.Select, rawTab)
if ok then
return true
end
end
local index = rawTab.Index
if type(index) == "number" then
return select(1, windSafeCall(
Window.Raw,
"SelectTab",
index
))
end
return false
end
UIBox.PlayerTabs:_Select(1)
task.defer(_BH_FN.UI_SelectAbout)
UIBox.TeleportMap:AddButton({
Text = "Teleport Generator",
Func = _BH_FN.TeleportToGenerator
})
UIBox.TeleportMap:AddButton({
Text = "Teleport Hook",
Func = _BH_FN.TeleportToHook
})
UIBox.TeleportMap:AddButton({
Text = "Teleport Gate",
Func = _BH_FN.TeleportToGate
})
UIBox.TeleportMap:AddButton({
Text = "Teleport Pallet",
Func = _BH_FN.TeleportToPallet
})
UIBox.TeleportMap:AddButton({
Text = "Teleport Window",
Func = _BH_FN.TeleportToWindow
})
UIBox.TeleportTool:AddButton({
Text = "Refresh Map Cache",
Func = _BH_FN.RefreshMapForTeleport
})
UIBox.TeleportTool:AddButton({
Text = "Drop All Pallet",
Func = _BH_FN.DAP_Request
})
UIBox.TeleportTool:AddDivider()
local KillerToggleKeys = {
"Bypass Cooldown",
"No Attack Slow",
"Bypass Leap",
"Third Person",
"Kill All (Killer)",
"Anti Blind (Killer)",
"Block Vaults",
"Veil Target Assist",
}
local KillerRoleGate = {
Desired = {},
Internal = false,
LastRole = nil,
LastDeniedAt = 0,
}
function _BH_FN.KRG_ForceToggle(toggleKey, value)
local toggle =
Toggles
and Toggles[toggleKey]
if not toggle
or type(toggle.SetValue) ~= "function"
or toggle.Value == value then
return
end
KillerRoleGate.Internal = true
pcall(function()
toggle:SetValue(value)
end)
KillerRoleGate.Internal = false
end
function _BH_FN.KRG_BlockToggle(toggleKey, value)
if KillerRoleGate.Internal then
return false
end
if value and GetRole() ~= "Killer" then
KillerRoleGate.Desired[toggleKey] = true
task.defer(function()
_BH_FN.KRG_ForceToggle(
toggleKey,
false
)
end)
local now = os.clock()
if now - KillerRoleGate.LastDeniedAt > 1 then
KillerRoleGate.LastDeniedAt = now
_BH_FN.notify(
"Killer Only",
"Fitur ini hanya bisa dinyalakan saat kamu menjadi Killer.",
1.8
)
end
return true
end
KillerRoleGate.Desired[toggleKey] =
value == true
return false
end
function _BH_FN.KRG_RefreshRole(force)
local role = GetRole()
if not force
and role == KillerRoleGate.LastRole then
return
end
local previousRole =
KillerRoleGate.LastRole
KillerRoleGate.LastRole = role
if role == "Killer" then
local restored = false
for _, toggleKey in ipairs(KillerToggleKeys) do
if KillerRoleGate.Desired[toggleKey] then
restored = true
_BH_FN.KRG_ForceToggle(
toggleKey,
true
)
end
end
if restored
and previousRole ~= "Killer" then
_BH_FN.notify(
"Killer",
"Fitur Killer sebelumnya otomatis aktif kembali.",
1.8
)
end
return
end
local saved = false
for _, toggleKey in ipairs(KillerToggleKeys) do
local toggle =
Toggles
and Toggles[toggleKey]
if toggle and toggle.Value == true then
KillerRoleGate.Desired[toggleKey] = true
saved = true
end
_BH_FN.KRG_ForceToggle(
toggleKey,
false
)
end
if saved and previousRole == "Killer" then
_BH_FN.notify(
"Killer",
"Fitur dinonaktifkan sementara sampai kamu menjadi Killer lagi.",
1.8
)
end
end
UIBox.KillerCore:AddToggle("Bypass Cooldown", {
Default = false,
Text = "Killer Skill No CD",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Bypass Cooldown",
v
) then return end
Killer.BypassCooldown = v
_BH_FN.toggleBypassCooldown(v)
end
})
UIBox.KillerCore:AddToggle("No Attack Slow", {
Default = false,
Text = "No Slow After Attack",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"No Attack Slow",
v
) then return end
Killer.NoAttackSlow = v
_BH_FN.KAS_SetEnabled(v)
end
})
UIBox.KillerCore:AddToggle("Bypass Leap", {
Default = false,
Text = "Bypass Leap",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Bypass Leap",
v
) then return end
Killer.BypassLeap = v
if v then _BH_FN.StartLeapBypass() else _BH_FN.StopLeapBypass() end
end
})
UIBox.KillerCore:AddToggle("Third Person", {
Default = false,
Text = "Third Person",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Third Person",
v
) then return end
Killer.ThirdPerson = v
if v then
local cam = workspace.CurrentCamera
if not cam then return end
if not Killer.ThirdPersonWasActive then
CameraMutation.Sequence = CameraMutation.Sequence + 1
Killer.ThirdPersonOrder = CameraMutation.Sequence
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
local cam = workspace.CurrentCamera
local isKiller = GetRole() == "Killer"
if cam then
cam.CameraType = Killer.OriginalCameraType
or Enum.CameraType.Custom
end
if isKiller then
LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
if not CameraZoom.UnlimitedZoom then
LocalPlayer.CameraMinZoomDistance = 0.5
LocalPlayer.CameraMaxZoomDistance = 0.5
end
elseif Killer.ThirdPersonWasActive then
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
end
Killer.ThirdPersonWasActive = false
Killer.ThirdPersonOrder = nil
Killer.OriginalCameraType = nil
Killer.OriginalCameraMode = nil
Killer.OriginalMinZoom = nil
Killer.OriginalMaxZoom = nil
end
})
UIBox.KillerCore:AddDivider()
UIBox.KillerUtility:AddToggle("Kill All (Killer)", {
Default = false,
Text = "Kill All Players",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Kill All (Killer)",
v
) then return end
Killer.KillAll = v
_BH_FN.KA_Reset()
end
})
UIBox.KillerUtility:AddInput("Kill Range", {
Text = "Kill Range",
Default = "500",
Numeric = true,
Finished = false,
Callback = function(v)
Killer.KillRange = tonumber(v) or 500
end
})
UIBox.KillerUtility:AddToggle("Anti Blind (Killer)", {
Default = false,
Text = "Anti Blind",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Anti Blind (Killer)",
v
) then return end
Killer.AntiBlind = v
if v then task.defer(_BH_FN.installMainNamecallHook) end
end
})
UIBox.KillerUtility:AddToggle("Block Vaults", {
Default = false,
Text = "Block Vault",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Block Vaults",
v
) then return end
Killer.BlockVaults = v
if v then task.defer(_BH_FN.installMainNamecallHook) end
end
})
Connections.KillerRoleGate =
_BH_FN.TrackConnection(
LocalPlayer:GetPropertyChangedSignal(
"Team"
):Connect(function()
task.defer(
_BH_FN.KRG_RefreshRole
)
end)
)
Connections.KillerRoleAttributeGate =
_BH_FN.TrackConnection(
LocalPlayer:GetAttributeChangedSignal(
"Role"
):Connect(function()
task.defer(
_BH_FN.KRG_RefreshRole
)
end)
)
task.defer(function()
_BH_FN.KRG_RefreshRole(true)
end)
UIBox.Parry:AddToggle("Auto Parry", {
Default = false,
Text = "Auto Parry",
Callback = function(v)
Config.Surv_AutoParry = v
Config.Surv_ParrySafety = true
ParryDryRun.Enabled = false
if v then
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and IsKiller(p) and p.Character then
AttachParrySensor(p.Character)
end
end
end
end
})
UIBox.Parry:AddToggle("Aggressive Parry", {
Default = false,
Text = "Aggressive Parry",
Callback = function(v)
Config.Surv_ParryAggressive = v
end
})
UIBox.Parry:AddToggle("Auto Crouch (Abyssal S1)", {
Default = false,
Text = "Abyssal Auto Crouch",
Callback = function(v)
Config.Surv_AutoCrouch = v
end
})
UIBox.Parry:AddSlider("Parry Distance", {
Text = "Parry Distance",
Default = 9.5,
Min = 5,
Max = 15,
Rounding = 1,
Callback = function(v)
Config.Surv_ParryRadius = v
end
})
UIBox.Parry:AddSlider("Parry Face Sensitivity", {
Text = "Facing Sensitivity",
Default = 0.7,
Min = 0.1,
Max = 1,
Decimal = true,
Callback = function(v)
Config.Surv_ParryFace = v
end
})
local SkillCheckWatcher = {
Connection = nil,
PromptAddedConnection = nil,
CheckVisibleConnection = nil,
LineRotationConnection = nil,
LegacyRoot = nil,
LegacyIndicator = nil,
Prompt = nil,
Check = nil,
Line = nil,
Goal = nil,
LastLegacyIndex = nil,
LastLegacyProgress = nil,
LegacyFired = false,
LastCheckVisible = false,
VisibleSince = 0,
ModernFired = false,
CycleGeneration = 0,
AttemptCount = 0,
MaxAttempts = 3,
InstantPending = false,
LastContextScan = 0,
ContextScanInterval = 0.15,
LastFallbackScan = 0,
FallbackScanInterval = 1.00,
ContextGenerator = nil,
ContextPoint = nil,
ContextDistance = math.huge,
GeneratorContextRadius = 18,
LastScanAt = 0,
ScanInterval = 0.10,
LastUpdateAt = 0,
PendingPress = false,
}
function _BH_FN.SC_Disconnect(conn)
if not conn then return end
pcall(function() conn:Disconnect() end)
_BH_FN.ForgetConnection(conn)
end
function _BH_FN.SC_ResetCycle()
SkillCheckWatcher.CycleGeneration =
SkillCheckWatcher.CycleGeneration + 1
SkillCheckWatcher.LastLegacyIndex = nil
SkillCheckWatcher.LastLegacyProgress = nil
SkillCheckWatcher.LegacyFired = false
SkillCheckWatcher.LastCheckVisible = false
SkillCheckWatcher.VisibleSince = 0
SkillCheckWatcher.ModernFired = false
SkillCheckWatcher.AttemptCount = 0
SkillCheckWatcher.InstantPending = false
SkillCheckWatcher.PendingPress = false
end
function _BH_FN.SC_UnbindPromptSignals()
for _, key in ipairs({
"CheckVisibleConnection",
"LineRotationConnection",
}) do
local connection = SkillCheckWatcher[key]
if connection then
_BH_FN.SC_Disconnect(connection)
SkillCheckWatcher[key] = nil
end
end
end
function _BH_FN.SC_BindPromptSignals(check, line)
_BH_FN.SC_UnbindPromptSignals()
if not check or not line then
return
end
SkillCheckWatcher.CheckVisibleConnection =
_BH_FN.TrackConnection(
check:GetPropertyChangedSignal(
"Visible"
):Connect(function()
SkillCheckWatcher.LastUpdateAt = 0
task.defer(function()
if HubRuntime.Alive
and Auto.SkillCheck then
_BH_FN.SC_Update()
end
end)
end)
)
SkillCheckWatcher.LineRotationConnection =
_BH_FN.TrackConnection(
line:GetPropertyChangedSignal(
"Rotation"
):Connect(function()
if not HubRuntime.Alive
or not Auto.SkillCheck
or not _BH_FN.SC_IsCheckVisible() then
return
end
if _BH_FN.SC_IsInstantMode() then
_BH_FN.SC_HandleInstant()
else
SkillCheckWatcher.LastUpdateAt = 0
_BH_FN.SC_Update()
end
end)
)
end
function _BH_FN.SC_ClearRefs()
_BH_FN.SC_UnbindPromptSignals()
SkillCheckWatcher.LegacyRoot = nil
SkillCheckWatcher.LegacyIndicator = nil
SkillCheckWatcher.Prompt = nil
SkillCheckWatcher.Check = nil
SkillCheckWatcher.Line = nil
SkillCheckWatcher.Goal = nil
SkillCheckWatcher.ContextGenerator = nil
SkillCheckWatcher.ContextPoint = nil
SkillCheckWatcher.ContextDistance = math.huge
end
function _BH_FN.SC_Stop()
if SkillCheckWatcher.Connection then
_BH_FN.SC_Disconnect(SkillCheckWatcher.Connection)
SkillCheckWatcher.Connection = nil
end
if SkillCheckWatcher.PromptAddedConnection then
_BH_FN.SC_Disconnect(
SkillCheckWatcher.PromptAddedConnection
)
SkillCheckWatcher.PromptAddedConnection = nil
end
Connections.SkillHeartbeat = nil
_BH_FN.SC_ClearRefs()
_BH_FN.SC_ResetCycle()
end
function _BH_FN.SC_IsAlive(obj)
return obj ~= nil and obj.Parent ~= nil
end
function _BH_FN.SC_RefreshReferences(force)
local now = os.clock()
if not force
and now - SkillCheckWatcher.LastScanAt < SkillCheckWatcher.ScanInterval then
return
end
SkillCheckWatcher.LastScanAt = now
if not _BH_FN.SC_IsAlive(SkillCheckWatcher.LegacyIndicator) then
SkillCheckWatcher.LegacyRoot = nil
SkillCheckWatcher.LegacyIndicator = nil
local root = PlayerGui:FindFirstChild("SkillCheck")
or PlayerGui:FindFirstChild("SkillCheck", true)
if root then
local indicator = root:FindFirstChild("Indicator")
or root:FindFirstChild("Indicator", true)
if indicator then
SkillCheckWatcher.LegacyRoot = root
SkillCheckWatcher.LegacyIndicator = indicator
end
end
end
if not _BH_FN.SC_IsAlive(SkillCheckWatcher.Check)
or not _BH_FN.SC_IsAlive(SkillCheckWatcher.Line)
or not _BH_FN.SC_IsAlive(SkillCheckWatcher.Goal) then
_BH_FN.SC_UnbindPromptSignals()
SkillCheckWatcher.Prompt = nil
SkillCheckWatcher.Check = nil
SkillCheckWatcher.Line = nil
SkillCheckWatcher.Goal = nil
local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
or PlayerGui:FindFirstChild("SkillCheckPromptGui", true)
if prompt then
local check = prompt:FindFirstChild("Check")
or prompt:FindFirstChild("Check", true)
if check then
local line = check:FindFirstChild("Line")
or check:FindFirstChild("Line", true)
local goal = check:FindFirstChild("Goal")
or check:FindFirstChild("Goal", true)
if line and goal then
SkillCheckWatcher.Prompt = prompt
SkillCheckWatcher.Check = check
SkillCheckWatcher.Line = line
SkillCheckWatcher.Goal = goal
_BH_FN.SC_BindPromptSignals(
check,
line
)
end
end
end
end
end
function _BH_FN.SC_GetLegacyState()
local indicator = SkillCheckWatcher.LegacyIndicator
if not _BH_FN.SC_IsAlive(indicator) then
return nil, nil, nil
end
local progress, index
local ok = pcall(function()
progress = indicator:GetAttribute("SkillCheck")
index = indicator:GetAttribute("Index")
end)
if not ok then
return indicator, nil, nil
end
progress = tonumber(progress)
if progress == nil or index == nil then
return indicator, nil, nil
end
return indicator, progress, index
end
function _BH_FN.SC_GetActionButton()
local current = PlayerGui
for segment in string.gmatch(
"Survivor-mob.Controls.action.check",
"[^%.]+"
) do
current = current and current:FindFirstChild(segment)
end
return current
end
function _BH_FN.SC_PressNormalInput()
if UserInputService.TouchEnabled then
local button = _BH_FN.SC_GetActionButton()
if button
and button:IsA("GuiObject")
and button.Visible then
if button:IsA("GuiButton")
and type(firesignal) == "function" then
local signalOk = pcall(function()
firesignal(button.Activated)
end)
if signalOk then
return true
end
end
local inset = GuiService:GetGuiInset()
local pos = button.AbsolutePosition
local size = button.AbsoluteSize
local x = pos.X + size.X * 0.5 + inset.X
local y = pos.Y + size.Y * 0.5 + inset.Y
local ok = pcall(function()
VirtualInputManager:SendTouchEvent(
8822,
0,
x,
y
)
task.wait(0.008)
VirtualInputManager:SendTouchEvent(
8822,
2,
x,
y
)
end)
if ok then
return true
end
end
end
return pcall(function()
VirtualInputManager:SendKeyEvent(
true,
Enum.KeyCode.Space,
false,
game
)
task.wait(0.006)
VirtualInputManager:SendKeyEvent(
false,
Enum.KeyCode.Space,
false,
game
)
end)
end
function _BH_FN.SC_IsCheckVisible()
local check = SkillCheckWatcher.Check
if not _BH_FN.SC_IsAlive(check) then
return false
end
local visible = false
local ok = pcall(function()
visible = check.Visible == true
local current = check.Parent
while visible and current and current ~= PlayerGui do
if current:IsA("GuiObject")
and current.Visible == false then
visible = false
break
end
if current:IsA("LayerCollector")
and current.Enabled == false then
visible = false
break
end
current = current.Parent
end
if visible then
visible = check.AbsoluteSize.X > 0
and check.AbsoluteSize.Y > 0
end
end)
return ok and visible
end
function _BH_FN.SC_IsInsideArc(
lineRotation,
goalRotation,
startOffset,
endOffset
)
local lr = (tonumber(lineRotation) or 0) % 360
local gr = (tonumber(goalRotation) or 0) % 360
local rangeStart = (gr + startOffset) % 360
local rangeEnd = (gr + endOffset) % 360
if rangeStart > rangeEnd then
return lr >= rangeStart or lr <= rangeEnd
end
return lr >= rangeStart and lr <= rangeEnd
end
function _BH_FN.SC_GetModernRotation()
local line = SkillCheckWatcher.Line
local goal = SkillCheckWatcher.Goal
if not _BH_FN.SC_IsAlive(line)
or not _BH_FN.SC_IsAlive(goal) then
return nil, nil
end
local lineRotation, goalRotation
local ok = pcall(function()
lineRotation = line.Rotation
goalRotation = goal.Rotation
end)
if not ok then
return nil, nil
end
return tonumber(lineRotation), tonumber(goalRotation)
end
function _BH_FN.SC_GetCharacterRoot()
local char = LocalPlayer.Character
return char
and char:FindFirstChild("HumanoidRootPart")
end
function _BH_FN.SC_RefreshGeneratorContext(force)
local now = os.clock()
if not force
and now - SkillCheckWatcher.LastContextScan
< SkillCheckWatcher.ContextScanInterval then
return
end
SkillCheckWatcher.LastContextScan = now
SkillCheckWatcher.ContextGenerator = nil
SkillCheckWatcher.ContextPoint = nil
SkillCheckWatcher.ContextDistance = math.huge
local root = _BH_FN.SC_GetCharacterRoot()
if not root then return end
for _, gen in ipairs(GB_GetAllGenerators()) do
if gen and gen.Parent then
for _, point in ipairs(GB_GetPoints(gen)) do
if point and point.Parent then
local distance =
(point.Position - root.Position).Magnitude
if distance
< SkillCheckWatcher.ContextDistance then
SkillCheckWatcher.ContextGenerator = gen
SkillCheckWatcher.ContextPoint = point
SkillCheckWatcher.ContextDistance = distance
end
end
end
end
end
if not SkillCheckWatcher.ContextPoint
and (
force
or now - SkillCheckWatcher.LastFallbackScan
>= SkillCheckWatcher.FallbackScanInterval
) then
SkillCheckWatcher.LastFallbackScan = now
local map = workspace:FindFirstChild("Map")
if map then
pcall(function()
for _, obj in ipairs(map:GetDescendants()) do
if obj:IsA("BasePart")
and obj.Name:find(
"GeneratorPoint",
1,
true
) then
local distance =
(obj.Position - root.Position).Magnitude
if distance
< SkillCheckWatcher.ContextDistance then
local generator =
GB_GetGeneratorFromPoint(obj)
if not generator then
local current = obj.Parent
while current
and current ~= map do
if current:IsA("Model")
and current.Name == "Generator" then
generator = current
break
end
current = current.Parent
end
end
if generator then
SkillCheckWatcher.ContextGenerator =
generator
SkillCheckWatcher.ContextPoint = obj
SkillCheckWatcher.ContextDistance =
distance
end
end
end
end
end)
end
end
end
function _BH_FN.SC_GetPromptContext()
if not _BH_FN.GB_IsClientRepairing() then
return "Unknown", nil, nil
end
_BH_FN.SC_RefreshGeneratorContext(false)
return "Generator",
SkillCheckWatcher.ContextGenerator,
SkillCheckWatcher.ContextPoint
end
function _BH_FN.SC_CategoryEnabled(category)
return category == "Generator"
and Auto.SkillCheckGenerator == true
end
function _BH_FN.SC_GetMode()
local mode =
tostring(
Auto.SkillCheckMode
or "Instant"
)
if mode == "Legit" then
return "Legit"
end
return "Instant"
end
function _BH_FN.SC_GetSelectedZone()
if _BH_FN.SC_GetMode() == "Legit" then
return 105, 112
end
return 108, 110
end
function _BH_FN.SC_IsInstantMode()
return _BH_FN.SC_GetMode() == "Instant"
end
function _BH_FN.SC_SnapLineToPerfectCenter()
local line = SkillCheckWatcher.Line
local goal = SkillCheckWatcher.Goal
if not _BH_FN.SC_IsAlive(line)
or not _BH_FN.SC_IsAlive(goal) then
return false
end
local targetRotation =
((tonumber(goal.Rotation) or 0) + 109) % 360
return pcall(function()
line.Rotation = targetRotation
end)
end
function _BH_FN.SC_ArmSafeRetry(delaySeconds)
local generation = SkillCheckWatcher.CycleGeneration
task.delay(delaySeconds or 0.16, function()
if not HubRuntime.Alive
or not Auto.SkillCheck
or generation ~= SkillCheckWatcher.CycleGeneration
or not _BH_FN.SC_IsCheckVisible() then
return
end
if SkillCheckWatcher.AttemptCount
>= SkillCheckWatcher.MaxAttempts then
return
end
SkillCheckWatcher.ModernFired = false
end)
end
function _BH_FN.SC_GetReactionDelay()
local base =
math.max(
0,
tonumber(
Auto.SkillCheckReactionDelay
) or 0
)
local jitter =
math.max(
0,
tonumber(
Auto.SkillCheckReactionJitter
) or 0
)
if jitter <= 0 then
return base
end
local variation =
(math.random() * 2 - 1)
* jitter
return math.max(
0,
base + variation
)
end
function _BH_FN.SC_PressWithDelay(
generation
)
if SkillCheckWatcher.PendingPress then
return
end
SkillCheckWatcher.PendingPress = true
local delaySeconds =
_BH_FN.SC_GetReactionDelay()
task.delay(
delaySeconds,
function()
SkillCheckWatcher.PendingPress =
false
if not HubRuntime.Alive
or not Auto.SkillCheck
or generation
~= SkillCheckWatcher.CycleGeneration
or not _BH_FN.SC_IsCheckVisible() then
return
end
_BH_FN.SC_PressNormalInput()
end
)
end
function _BH_FN.SC_HandleInstant()
if not _BH_FN.SC_IsInstantMode()
or not _BH_FN.SC_IsCheckVisible()
or not _BH_FN.GB_IsClientRepairing()
or SkillCheckWatcher.ModernFired then
return false
end
local category = _BH_FN.SC_GetPromptContext()
if not _BH_FN.SC_CategoryEnabled(category) then
return false
end
SkillCheckWatcher.ModernFired = true
SkillCheckWatcher.AttemptCount =
SkillCheckWatcher.AttemptCount + 1
_BH_FN.SC_SnapLineToPerfectCenter()
_BH_FN.SC_PressNormalInput()
_BH_FN.SC_ArmSafeRetry(0.10)
return true
end
function _BH_FN.SC_HandleModernPerfect()
if not _BH_FN.SC_IsCheckVisible() then
return false
end
if _BH_FN.SC_IsInstantMode() then
return _BH_FN.SC_HandleInstant()
end
if SkillCheckWatcher.ModernFired then
return true
end
local category = _BH_FN.SC_GetPromptContext()
if not _BH_FN.SC_CategoryEnabled(category) then
return false
end
local lr, gr = _BH_FN.SC_GetModernRotation()
if lr == nil or gr == nil then
return false
end
local startOffset, endOffset =
_BH_FN.SC_GetSelectedZone()
if not _BH_FN.SC_IsInsideArc(
lr,
gr,
startOffset,
endOffset
) then
return false
end
SkillCheckWatcher.ModernFired = true
SkillCheckWatcher.AttemptCount =
SkillCheckWatcher.AttemptCount + 1
_BH_FN.SC_PressWithDelay(
SkillCheckWatcher.CycleGeneration
)
_BH_FN.SC_ArmSafeRetry(0.20)
return true
end
function _BH_FN.SC_HandleLegacyGenerator()
if not Auto.SkillCheckGenerator
or not _BH_FN.GB_IsClientRepairing() then
return false
end
local _, progress, index =
_BH_FN.SC_GetLegacyState()
if progress == nil or index == nil then
return false
end
if index ~= SkillCheckWatcher.LastLegacyIndex then
SkillCheckWatcher.LastLegacyIndex = index
SkillCheckWatcher.LegacyFired = false
end
SkillCheckWatcher.LastLegacyProgress = progress
if SkillCheckWatcher.LegacyFired then
return true
end
if progress >= 98 then
SkillCheckWatcher.LegacyFired = true
_BH_FN.SC_PressNormalInput()
return true
end
return false
end
function _BH_FN.SC_Update()
if not HubRuntime.Alive
or not Auto.SkillCheck then
return
end
local now =
os.clock()
local hz =
math.clamp(
tonumber(
Auto.SkillCheckScanHz
) or 60,
10,
120
)
if now
- SkillCheckWatcher.LastUpdateAt
< 1 / hz then
return
end
SkillCheckWatcher.LastUpdateAt =
now
_BH_FN.SC_RefreshReferences(false)
local visible = _BH_FN.SC_IsCheckVisible()
if visible
and not SkillCheckWatcher.LastCheckVisible then
SkillCheckWatcher.CycleGeneration =
SkillCheckWatcher.CycleGeneration + 1
SkillCheckWatcher.VisibleSince = now
SkillCheckWatcher.ModernFired = false
SkillCheckWatcher.AttemptCount = 0
SkillCheckWatcher.InstantPending = false
_BH_FN.SC_RefreshGeneratorContext(true)
elseif not visible
and SkillCheckWatcher.LastCheckVisible then
SkillCheckWatcher.CycleGeneration =
SkillCheckWatcher.CycleGeneration + 1
SkillCheckWatcher.VisibleSince = 0
SkillCheckWatcher.ModernFired = false
SkillCheckWatcher.AttemptCount = 0
end
SkillCheckWatcher.LastCheckVisible = visible
if visible
and _BH_FN.GB_IsClientRepairing()
and now - SkillCheckWatcher.VisibleSince >= 0.06 then
_BH_FN.SC_HandleModernPerfect()
elseif not visible and _BH_FN.GB_IsClientRepairing() then
_BH_FN.SC_HandleLegacyGenerator()
end
end
function _BH_FN.SC_Start()
_BH_FN.SC_Stop()
if not Auto.SkillCheck then
return
end
_BH_FN.SC_RefreshReferences(true)
_BH_FN.SC_RefreshGeneratorContext(true)
SkillCheckWatcher.Connection = _BH_FN.TrackConnection(
RunService.Heartbeat:Connect(_BH_FN.SC_Update)
)
SkillCheckWatcher.PromptAddedConnection =
_BH_FN.TrackConnection(
PlayerGui.DescendantAdded:Connect(function(object)
local name = string.lower(object.Name)
if name == "skillcheckpromptgui"
or name == "skillcheck"
or name == "check"
or name == "line"
or name == "goal"
or name == "indicator" then
SkillCheckWatcher.LastScanAt = 0
task.defer(function()
if HubRuntime.Alive
and Auto.SkillCheck then
_BH_FN.SC_RefreshReferences(true)
_BH_FN.SC_Update()
end
end)
end
end)
)
Connections.SkillHeartbeat =
SkillCheckWatcher.Connection
end
function _BH_FN.SC_RefreshEnabledState()
local enabled =
Auto.SkillCheckGenerator
Auto.SkillCheck = enabled
if enabled then
_BH_FN.SC_Start()
else
_BH_FN.SC_Stop()
end
end
UIBox.SkillCheck:AddToggle("Auto Skill Check", {
Default = false,
Text = "Auto Skill Check",
Callback = function(v)
Auto.SkillCheckGenerator = v
_BH_FN.SC_ResetCycle()
_BH_FN.SC_RefreshEnabledState()
end
})
UIBox.SkillCheck:AddDropdown("Skillcheck Profile", {
Default = "Legit",
Values = {
"Instant",
"Legit"
},
Text = "Profile",
Callback = function(v)
if v == "Legit" then
Auto.SkillCheckMode = "Legit"
Auto.SkillCheckReactionDelay =
0.045
Auto.SkillCheckReactionJitter =
0.025
else
Auto.SkillCheckMode = "Instant"
Auto.SkillCheckReactionDelay =
0
Auto.SkillCheckReactionJitter =
0
end
_BH_FN.SC_ResetCycle()
_BH_FN.SC_RefreshReferences(true)
_BH_FN.SC_RefreshGeneratorContext(true)
end
})
UIBox.SkillCheck:AddSlider("Skillcheck Reaction Speed", {
Text = "Delay (ms)",
Default = 0,
Min = 0,
Max = 180,
Rounding = 0,
Callback = function(v)
Auto.SkillCheckReactionDelay =
v / 1000
end
})
UIBox.SkillCheck:AddSlider("Skillcheck Frequency", {
Text = "Check Rate",
Default = 120,
Min = 10,
Max = 120,
Rounding = 0,
Callback = function(v)
Auto.SkillCheckScanHz = v
end
})
UIBox.SurvivorUtility:AddToggle("Self Heal", {
Default = false,
Text = "Self Heal",
Callback = function(v)
_BH_FN.SH_SetEnabled(v)
end
})
UIBox.SurvivorUtility:AddToggle("Fast Vault", {
Default = false,
Text = "Fast Window Vault",
Callback = function(v)
FastVault.Enabled = v
toggleFastVault(v)
end
})
UIBox.SurvivorUtility:AddSlider("Fast Vault Speed", {
Text = "Vault Speed",
Default = FastVault.Speed,
Min = 1,
Max = 3,
Rounding = 1,
Callback = function(v)
FastVault.Speed = v
if FastVault.Enabled then
if _BH_FN.FV_IsWindowVault(
FastVault.Interact
) or os.clock()
<= FastVault.VaultWindowUntil then
_BH_FN.FV_ApplyNativeSpeed(
FastVault.Character
)
end
_BH_FN.FV_BoostPlayingVaultTracks()
end
end
})
UIBox.SurvivorUtility:AddToggle("Anti Slow Vault", {
Default = false,
Text = "Anti Slow",
Callback = function(v)
_BH_FN.ASV_SetEnabled(v)
end
})
GenBypass.ActionControl = UIBox.SurvivorUtility:AddButton({
Text = "Use Gen Bypass",
Icon = "zap",
Func = function()
if not GenBypass.Enabled then
setGenBypass(true)
end
_BH_FN.GB_Request()
end
})
GB_UpdateButton()
local KeybindGuard = {
Reverting = {},
Ready = false,
}
local MenuKeybindState = {
Key = Enum.KeyCode.RightShift,
}
local KeybindEntries = {
{
Id = "GenBypassKeyPicker",
Label = "Gen Bypass",
Get = function() return GenBypass.HotkeyCode end,
},
{
Id = "MovementBoostKeyPicker",
Label = "Movement Boost",
Get = function() return Movement.BoostKeybind end,
},
{
Id = "HideNameKeyPicker",
Label = "Hide Name",
Get = function() return HideName.Keybind end,
},
{
Id = "FakeParryKeyPicker",
Label = "Fake Parry",
Get = function() return FakeParry.Keybind end,
},
{
Id = "MenuKeybind",
Label = "Toggle UI",
Get = function() return MenuKeybindState.Key end,
},
}
function _BH_FN.KB_IsUnboundKey(value)
if typeof(value) ~= "EnumItem" then
return true
end
local name = string.lower(value.Name)
return value == Enum.KeyCode.Unknown
or name == "none"
or name == "unknown"
end
function _BH_FN.KB_RevertSilently(
optionId,
oldKey
)
if _BH_FN.KB_IsUnboundKey(oldKey) then
return
end
local option =
Options and Options[optionId]
if not option
or type(option.SetValue) ~= "function" then
return
end
local token = {}
KeybindGuard.Reverting[optionId] = token
task.defer(function()
pcall(function()
option:SetValue(oldKey)
end)
task.delay(0.15, function()
if KeybindGuard.Reverting[optionId]
== token then
KeybindGuard.Reverting[optionId] = nil
end
end)
end)
end
function _BH_FN.KB_GetBoundKey(entry)
local option =
Options and Options[entry.Id]
if option
and typeof(option.Value) == "EnumItem" then
return not _BH_FN.KB_IsUnboundKey(
option.Value
) and option.Value or nil
end
local ok, value = pcall(entry.Get)
if ok
and not _BH_FN.KB_IsUnboundKey(value) then
return value
end
return nil
end
function _BH_FN.KB_GetConflict(candidate, ownId)
if _BH_FN.KB_IsUnboundKey(candidate) then
return nil
end
for _, entry in ipairs(KeybindEntries) do
if entry.Id ~= ownId
and _BH_FN.KB_GetBoundKey(entry)
== candidate then
return entry.Label
end
end
return nil
end
function _BH_FN.KB_Apply(
optionId,
label,
candidate,
oldKey,
setter
)
if KeybindGuard.Reverting[optionId] then
return false
end
if _BH_FN.KB_IsUnboundKey(candidate) then
_BH_FN.KB_RevertSilently(
optionId,
oldKey
)
return false
end
if typeof(candidate) == "EnumItem"
and candidate ~= Enum.KeyCode.Unknown
and candidate == oldKey then
setter(candidate)
return true
end
local conflict =
_BH_FN.KB_GetConflict(
candidate,
optionId
)
if conflict then
if KeybindGuard.Ready then
Library:Notify({
Title = "Keybind Already Used",
Description = candidate.Name
.. " sudah dipakai oleh "
.. conflict
.. ". Key lama dikembalikan.",
Time = 2.8,
Icon = "triangle-alert",
})
end
_BH_FN.KB_RevertSilently(
optionId,
oldKey
)
return false
end
setter(candidate)
if KeybindGuard.Ready then
Library:Notify({
Title = "Keybind Updated",
Description = label
.. " sekarang memakai "
.. candidate.Name
.. ".",
Time = 1.6,
Icon = "keyboard",
})
end
return true
end
UIBox.SurvivorUtility:AddKeyPicker("GenBypassKeyPicker", {
Default = "G",
Mode = "Press",
NoUI = true,
Text = "Gen Bypass Key",
Callback = function() end,
ChangedCallback = function(v)
local oldKey = GenBypass.HotkeyCode
_BH_FN.KB_Apply(
"GenBypassKeyPicker",
"Gen Bypass",
v,
oldKey,
function(key)
GenBypass.HotkeyCode = key
end
)
end
})
_BH_FN.SetSharedAimFOV(95)
SilentAim.Enabled = false
ToFAimConfig.Enabled = false
SilentAim.WallCheck = true
ToolAimAssist.WallCheck = true
TargetAssistDiag.WallCheck = true
FlashlightAimAssist.WallCheck = true
GunAim.VisibilityCheck = true
UIBox.Aim:AddToggle("Pistol Target Assist", {
Default = false,
Text = "Pistol Aim",
Callback = function(v)
TargetAssistDiag.WallCheck = true
TargetAssistDiag.PistolEnabled = v == true
_BH_FN.TAD_RefreshConnection()
_BH_FN.updateAimFOVVisual()
end
})
UIBox.Aim:AddToggle("Veil Target Assist", {
Default = false,
Text = "Veil Aim",
Callback = function(v)
if _BH_FN.KRG_BlockToggle(
"Veil Target Assist",
v
) then return end
TargetAssistDiag.WallCheck = true
TargetAssistDiag.VeilEnabled = v == true
_BH_FN.TAD_RefreshConnection()
_BH_FN.updateAimFOVVisual()
end
})
UIBox.Aim:AddToggle("Light Flashlight Aim", {
Default = false,
Text = "Light / Flashlight Aim",
Callback = function(v)
local enabled = v == true
SilentAim.WallCheck = true
ToolAimAssist.WallCheck = true
FlashlightAimAssist.WallCheck = true
GunAim.VisibilityCheck = true
ToolAimAssist.Enabled =
enabled
SilentAim.Enabled =
ToolAimAssist.Enabled
ToFAimConfig.Enabled =
ToolAimAssist.Enabled
if ToolAimAssist.Enabled then
_BH_FN.setupSilentAimHook()
_BH_FN.setupToolAimAssistListeners()
else
_BH_FN.removeSilentAimHook()
_BH_FN.stopToolAimAssistListeners()
end
_BH_FN.FAA_SetEnabled(enabled)
_BH_FN.updateAimFOVVisual()
end
})
UIBox.AimSettings:AddToggle("Aim FOV Visible", {
Default = false,
Text = "FOV Survivor / Killer",
Callback = function(v)
ToolAimAssist.ShowFOV = v == true
_BH_FN.updateAimFOVVisual()
end
}):AddColorPicker("ToolAimFOVColor", {
Default = ToolAimAssist.FOVColor,
Title = "Warna FOV",
Callback = function(v)
ToolAimAssist.FOVColor = v
_BH_FN.updateAimFOVVisual()
end
})
UIBox.AimSettings:AddSlider("Shared Aim FOV", {
Text = "Ukuran FOV",
Default = 95,
Min = 40,
Max = 500,
Rounding = 0,
Callback = function(v)
_BH_FN.SetSharedAimFOV(v)
end
})
UIBox.AimSettings:AddDropdown("Light Aim Target Team", {
Default = "Auto",
Values = {"Auto", "Killer", "Survivor"},
Text = "Target Team",
Callback = function(v)
ToolAimAssist.TargetMode = v
SilentAim.TargetMode = v
end
})
UIBox.AimSettings:AddDropdown("Tool Aim Part", {
Default = "Badan",
Values = {"Kepala", "Badan", "Dada"},
Text = "Aim Part",
Callback = function(v)
_BH_FN.SetSharedAimPart(v)
end
})
UIBox.AimSettings:AddToggle("Tool Assist Prediction", {
Default = true,
Text = "Prediction",
Callback = function(v)
ToolAimAssist.Prediction = v
end
})
UIBox.AimSettings:AddToggle("Tool Assist Use FOV", {
Default = true,
Text = "Batasi Target di FOV",
Callback = function(v)
ToolAimAssist.UseFOV = v
_BH_FN.updateAimFOVVisual()
end
})
UIBox.AimSettings:AddSlider("Tool Assist Range", {
Text = "Range",
Default = 180,
Min = 30,
Max = 500,
Rounding = 0,
Callback = function(v)
ToolAimAssist.Range = v
end
})
UIBox.AimSettings:AddSlider("Tool Aim Strength", {
Text = "Strength",
Default = ToolAimAssist.CameraStrength,
Min = 0.05,
Max = 1,
Rounding = 2,
Callback = function(v)
ToolAimAssist.CameraStrength = v
end
})
UIBox.WeaponAim:AddDropdown("Pistol Aim Part", {
Default = "Badan",
Values = {
"Kepala",
"Badan",
"Dada"
},
Text = "Hit Part",
Callback = function(v)
TargetAssistDiag.PistolTargetPart =
v == "Kepala" and "Head"
or v == "Dada" and "UpperTorso"
or "HumanoidRootPart"
TargetAssistDiag.Target = nil
end
})
UIBox.WeaponAim:AddSlider("Pistol Assist Range", {
Text = "Range",
Default = 180,
Min = 30,
Max = 350,
Rounding = 0,
Callback = function(v)
TargetAssistDiag.Range = v
TargetAssistDiag.Target = nil
end
})
UIBox.WeaponAim:AddToggle("Pistol Stable Target", {
Default = true,
Text = "Target Lock",
Callback = function(v)
TargetAssistDiag.PistolStableTarget = v == true
if not v then
TargetAssistDiag.Target = nil
end
end
})
UIBox.WeaponAim:AddSlider("Pistol Aim Strength", {
Text = "Strength",
Default = TargetAssistDiag.PistolStrength,
Min = 0.05,
Max = 1,
Rounding = 2,
Callback = function(v)
TargetAssistDiag.PistolStrength = v
end
})
UIBox.WeaponAim:AddSlider("Veil Aim Strength", {
Text = "Veil Power",
Default = TargetAssistDiag.VeilStrength,
Min = 0.05,
Max = 1,
Rounding = 2,
Callback = function(v)
TargetAssistDiag.VeilStrength = v
end
})
UIBox.WeaponAim:AddSlider("Flashlight Aim Range", {
Text = "Light Range",
Default = FlashlightAimAssist.Range,
Min = 30,
Max = 250,
Rounding = 0,
Callback = function(v)
FlashlightAimAssist.Range = v
end
})
UIBox.WeaponAim:AddSlider("Flashlight Aim Strength", {
Text = "Light Power",
Default = FlashlightAimAssist.Strength,
Min = 0.05,
Max = 1,
Rounding = 2,
Callback = function(v)
FlashlightAimAssist.Strength = v
end
})
UIBox.Crosshair:AddToggle("Crosshair", {
Default = false,
Text = "Crosshair",
Callback = function(v)
Crosshair.Enabled = v
_BH_FN.updateCrosshairGui()
end
})
UIBox.Crosshair:AddDropdown("Crosshair Style", {
Default = "Plus",
Values = {"Plus", "Dot", "Circle"},
Text = "Bentuk Crosshair",
Callback = function(v)
Crosshair.Style = v
_BH_FN.updateCrosshairGui()
end
})
UIBox.Crosshair:AddColorPicker("CrosshairColorPicker", {
Title = "Warna Crosshair",
Default = Color3.fromRGB(255, 255, 255),
Callback = function(v)
Crosshair.Color = v
_BH_FN.updateCrosshairGui()
end
})
UIBox.Crosshair:AddSlider("Crosshair Size", {
Text = "Ukuran Crosshair",
Default = 8,
Min = 2,
Max = 20,
Callback = function(v)
Crosshair.Size = v
_BH_FN.updateCrosshairGui()
end
})
UIBox.Crosshair:AddSlider("Crosshair Thickness", {
Text = "Ketebalan Crosshair",
Default = 2,
Min = 1,
Max = 5,
Callback = function(v)
Crosshair.Thickness = v
_BH_FN.updateCrosshairGui()
end
})
function _BH_FN.RefreshExistingSetColor(set, color)
for obj in pairs(set) do
local h = ESPCache.Objects[obj]
if h and h.Parent then
if h.FillColor ~= color then h.FillColor = color end
local outlineColor = _BH_FN.ESP_GetOutlineColor(color)
if h.OutlineColor ~= outlineColor then h.OutlineColor = outlineColor end
end
end
end
function _BH_FN.RefreshPlayerColor(roleName, color)
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer
and _BH_FN.AIM_GetRole(p) == roleName
and p.Character then
local h = ESPCache.Objects[p.Character]
if h and h.Parent then
h.FillColor = color
h.OutlineColor = _BH_FN.ESP_GetOutlineColor(color)
end
end
end
end
function _BH_FN.RefreshGeneratorColor()
for gen in pairs(ESPCache.Generators) do
if gen and gen.Parent then
local state = ESPVisualState.Generator[gen]
if state then state.LastColor = nil end
if ESP.Generator then _BH_FN.UpdateGenerator(gen, getRoot()) end
end
end
end
UIBox.ESP:AddToggle("ESP Survivor", {
Default = false,
Text = "Survivor ESP",
Callback = function(v)
ESP.Survivor = v
Timers.lastPlayerESP = 0
if not v then _BH_FN.clearPlayerTeamESP("Survivor") end
end
}):AddColorPicker("ESPColorSurvivor", {
Default = TeamColors.Survivor,
Title = "Survivor ESP Color",
Callback = function(v)
TeamColors.Survivor = v
_BH_FN.RefreshPlayerColor("Survivor", v)
end
})
UIBox.ESP:AddToggle("ESP Killer", {
Default = false,
Text = "Killer ESP",
Callback = function(v)
ESP.Killer = v
Timers.lastPlayerESP = 0
if not v then _BH_FN.clearPlayerTeamESP("Killer") end
end
}):AddColorPicker("ESPColorKiller", {
Default = TeamColors.Killer,
Title = "Killer ESP Color",
Callback = function(v)
TeamColors.Killer = v
_BH_FN.RefreshPlayerColor("Killer", v)
end
})
UIBox.ESP:AddToggle("ESP Generator", {
Default = false,
Text = "Generator ESP",
Callback = function(v)
ESP.Generator = v
Timers.lastGeneratorESP = 0
if v and not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
if not v then _BH_FN.clearGeneratorESP() end
end
}):AddColorPicker("ESPColorGenerator", {
Default = GeneratorColor,
Title = "Generator ESP Color",
Callback = function(v)
GeneratorColor = v
_BH_FN.RefreshGeneratorColor()
end
})
UIBox.ESP:AddToggle("ESP Pallet", {
Default = false,
Text = "Pallet ESP",
Callback = function(v)
ESP.Pallet = v
Timers.lastPalletESP = 0
if v and not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
if not v then _BH_FN.clearESPSet(ESPCache.Pallets) end
end
}):AddColorPicker("ESPColorPallet", {
Default = PalletColor,
Title = "Pallet ESP Color",
Callback = function(v)
PalletColor = v
_BH_FN.RefreshExistingSetColor(ESPCache.Pallets, v)
end
})
UIBox.ESP:AddToggle("ESP Window", {
Default = false,
Text = "Window ESP",
Callback = function(v)
ESP.Window = v
Timers.lastWindowESP = 0
if v and not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
if not v then _BH_FN.clearESPSet(ESPCache.Windows) end
end
}):AddColorPicker("ESPColorWindow", {
Default = WindowColor,
Title = "Window ESP Color",
Callback = function(v)
WindowColor = v
_BH_FN.RefreshExistingSetColor(ESPCache.Windows, v)
end
})
UIBox.ESP:AddToggle("ESP Hook", {
Default = false,
Text = "Hook ESP",
Callback = function(v)
ESP.Hook = v
Timers.lastHookESP = 0
if v and not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
if not v then _BH_FN.clearESPSet(ESPCache.Hooks) end
end
}):AddColorPicker("ESPColorHook", {
Default = HookColor,
Title = "Hook ESP Color",
Callback = function(v)
HookColor = v
_BH_FN.RefreshExistingSetColor(ESPCache.Hooks, v)
end
})
UIBox.ESP:AddToggle("ESP SCP", {
Default = false,
Text = "SCP ESP",
Callback = function(v)
ESP.SCP = v
Timers.lastSCPEsp = 0
if v and not ESPScanState.Running then
_BH_FN.startIncrementalMapScan()
end
if not v then _BH_FN.clearESPSet(ESPCache.SCP) end
end
}):AddColorPicker("ESPColorSCP", {
Default = SCPColor,
Title = "SCP ESP Color",
Callback = function(v)
SCPColor = v
_BH_FN.RefreshExistingSetColor(ESPCache.SCP, v)
end
})
UIBox.ESP:AddButton({
Text = "Reset ESP Colors",
Func = function()
TeamColors.Survivor = Color3.fromRGB(60, 255, 120)
TeamColors.Killer = Color3.fromRGB(255, 60, 60)
GeneratorColor = Color3.fromRGB(255, 170, 0)
PalletColor = Color3.fromRGB(74, 255, 181)
WindowColor = Color3.fromRGB(74, 255, 181)
SCPColor = Color3.fromRGB(255, 0, 0)
HookColor = Color3.fromRGB(255, 95, 95)
StatusDownColor = Color3.fromRGB(255, 80, 80)
StatusColors.Hooked = Color3.fromRGB(255, 130, 95)
StatusColors.Carried = Color3.fromRGB(255, 185, 95)
StatusColors.Health = Color3.fromRGB(100, 255, 130)
StatusColors.Item = Color3.fromRGB(255, 215, 90)
pcall(function() Options.ESPColorSurvivor:SetValueRGB(TeamColors.Survivor) end)
pcall(function() Options.ESPColorKiller:SetValueRGB(TeamColors.Killer) end)
pcall(function() Options.ESPColorGenerator:SetValueRGB(GeneratorColor) end)
pcall(function() Options.ESPColorPallet:SetValueRGB(PalletColor) end)
pcall(function() Options.ESPColorWindow:SetValueRGB(WindowColor) end)
pcall(function() Options.ESPColorSCP:SetValueRGB(SCPColor) end)
pcall(function() Options.ESPColorHook:SetValueRGB(HookColor) end)
pcall(function() Options.StatusHealthColor:SetValueRGB(StatusColors.Health) end)
pcall(function() Options.StatusItemColor:SetValueRGB(StatusColors.Item) end)
_BH_FN.RefreshPlayerColor("Survivor", TeamColors.Survivor)
_BH_FN.RefreshPlayerColor("Killer", TeamColors.Killer)
_BH_FN.RefreshGeneratorColor()
_BH_FN.RefreshExistingSetColor(ESPCache.Pallets, PalletColor)
_BH_FN.RefreshExistingSetColor(ESPCache.Windows, WindowColor)
_BH_FN.RefreshExistingSetColor(ESPCache.SCP, SCPColor)
_BH_FN.RefreshExistingSetColor(ESPCache.Hooks, HookColor)
Timers.lastStatusESP = 0
Timers.lastPlayerESP = 0
end
})
UIBox.ESPStatus:AddToggle("ESP Name", {
Default = false,
Text = "ESP Name",
Callback = function(v)
ESPStatus.ShowName = v
Timers.lastStatusESP = 0
if not _BH_FN.isStatusESPEnabled() then
_BH_FN.clearAllStatusESP()
end
end
})
UIBox.ESPStatus:AddToggle("Show Health", {
Default = false,
Text = "Show Health",
Callback = function(v)
ESPStatus.ShowHealth = v
Timers.lastStatusESP = 0
if not _BH_FN.isStatusESPEnabled() then _BH_FN.clearAllStatusESP() end
end
}):AddColorPicker("StatusHealthColor", {
Default = StatusColors.Health,
Title = "Health Color",
Callback = function(v)
StatusColors.Health = v
Timers.lastStatusESP = 0
end
})
UIBox.ESPStatus:AddToggle("Show Item", {
Default = false,
Text = "Show Item",
Callback = function(v)
ESPStatus.ShowItem = v
Timers.lastStatusESP = 0
if not _BH_FN.isStatusESPEnabled() then _BH_FN.clearAllStatusESP() end
end
}):AddColorPicker("StatusItemColor", {
Default = StatusColors.Item,
Title = "Item Color",
Callback = function(v)
StatusColors.Item = v
Timers.lastStatusESP = 0
end
})
UIBox.ESPStatus:AddSlider("Status Radius", {
Text = "Status Radius",
Default = 500,
Min = 10,
Max = 500,
Callback = function(v)
ESPStatus.Radius = v
Timers.lastStatusESP = 0
end
})
UIBox.Movement:AddToggle("Movement Boost", {
Default = false,
Text = "Movement Boost",
Callback = function(v)
Movement.BoostEnabled = v
_BH_FN.applyMovementBoost()
end
})
UIBox.Movement:AddKeyPicker("MovementBoostKeyPicker", {
Default = "B",
Mode = "Press",
NoUI = true,
Text = "Movement Boost Key",
Callback = function() end,
ChangedCallback = function(v)
_BH_FN.KB_Apply(
"MovementBoostKeyPicker",
"Movement Boost",
v,
Movement.BoostKeybind,
function(key)
Movement.BoostKeybind = key
end
)
end
})
UIBox.Movement:AddSlider("Movement Boost Value", {
Text = "Strength",
Default = 6,
Min = 0,
Max = 20,
Rounding = 1,
Callback = function(v)
Movement.BoostValue = v
if Movement.BoostEnabled then
_BH_FN.applyMovementBoost()
end
end
})
UIBox.Movement:AddToggle("NoClip", {
Default = false,
Text = "NoClip",
Callback = function(v)
_BH_FN.toggleNoClip(v)
end
})
UIBox.Movement:AddToggle("Anti Knockdown", {
Default = false,
Text = "Anti Knockdown",
Callback = function(v)
_BH_FN.AK_SetEnabled(v)
end
})
UIBox.Movement:AddToggle("Anti Loop Stuck", {
Default = false,
Text = "Anti Loop Stuck",
Callback = function(v)
_BH_FN.ALS_SetEnabled(v)
end
})
UIBox.Emote:AddDropdown("Emote", {
Default = "Mannrobics",
Values = EmoteList,
Callback = function(v)
Emote.Selected = v
end
})
UIBox.Emote:AddButton({
Text = "Play Emote",
Func = function()
if not EmoteRemote then _BH_FN.notify("Emote", "EmoteHandler tidak ditemukan.", 2); return end
local ok = pcall(function()
EmoteRemote:FireServer(Emote.Selected)
end)
if ok then Emote.Active = true end
end
})
UIBox.Emote:AddButton({
Text = "Stop Emote",
Func = function()
if not EmoteRemote then _BH_FN.notify("Emote", "EmoteHandler tidak ditemukan.", 2); return end
pcall(function()
EmoteRemote:FireServer("Stop")
end)
Emote.Active = false
end
})
UIBox.ChatName:AddToggle("Fake Chat Tag", {
Default = false,
Text = "Fake Chat Tag",
Callback = function(v)
FakeTag.Enabled = v
if v then _BH_FN.installFakeTagHook() end
end
})
UIBox.ChatName:AddInput("Tag Text", {
Text = "Tag Text",
Default = "[BLUEHAVEN]",
Numeric = false,
Finished = false,
Callback = function(v)
FakeTag.Text = v or "[BLUEHAVEN]"
end
})
UIBox.ChatName:AddColorPicker("FakeTagColorPicker", {
Title = "Tag Color",
Default = Color3.fromRGB(0, 191, 255),
Callback = function(v)
FakeTag.Color = "#" .. string.format("%02x%02x%02x", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
end
})
UIBox.ChatName:AddToggle("Hide Name", {
Default = false,
Text = "Hide Name",
Callback = function(v)
HideName.Enabled = v
_BH_FN.enableHideName(v)
end
})
UIBox.ChatName:AddKeyPicker("HideNameKeyPicker", {
Default = "F3",
Mode = "Press",
Text = "Toggle Hide Name",
Callback = function()
_BH_FN.setToggleValue("Hide Name", not HideName.Enabled, function(v)
HideName.Enabled = v
_BH_FN.enableHideName(v)
end)
end,
ChangedCallback = function(v)
_BH_FN.KB_Apply(
"HideNameKeyPicker",
"Hide Name",
v,
HideName.Keybind,
function(key)
HideName.Keybind = key
end
)
end
})
UIBox.FakeParry:AddDropdown("Fake Parry Style", {
Text = "Animation",
Default = "Enten",
Values = {"Enten", "Stopwatch", "Fih", "BloodShield"},
Callback = function(v)
FakeParry.Animation = v
end
})
UIBox.FakeParry:AddButton({
Text = "Play Fake Parry",
Icon = "shield-check",
Func = function()
_BH_FN.playFakeParryAnimation(true)
end
})
UIBox.FakeParry:AddKeyPicker("FakeParryKeyPicker", {
Default = "V",
Mode = "Press",
Text = "Fake Parry Key",
Callback = function() end,
ChangedCallback = function(v)
_BH_FN.KB_Apply(
"FakeParryKeyPicker",
"Fake Parry",
v,
FakeParry.Keybind,
function(key)
FakeParry.Keybind = key
end
)
end
})
UIBox.Visual:AddToggle("Fullbright", {
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
UIBox.Visual:AddToggle("No Shadow", {
Default = false,
Text = "No Shadow",
Callback = function(v)
Visual.NoShadow = v
Lighting.GlobalShadows = not v
end
})
UIBox.Visual:AddToggle("No Fog", {
Default = false,
Text = "No Fog",
Callback = function(v)
Visual.NoFog = v
Lighting.FogStart = v and 0 or OriginalLighting.FogStart
Lighting.FogEnd = v and 1000000 or OriginalLighting.FogEnd
end
})
UIBox.Time:AddToggle("Set Clock Time", {
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
UIBox.Time:AddSlider("Clock Time", {
Text = "Time",
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
UIBox.Time:AddToggle("Ambient Color", {
Default = false,
Text = "Custom Ambient",
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
UIBox.Time:AddColorPicker("AmbientColorPicker", {
Title = "Ambient Color",
Default = Color3.fromRGB(255, 255, 255),
Callback = function(v)
Visual.AmbientColor = v
if Visual.Ambient then
Lighting.Ambient = v
Lighting.OutdoorAmbient = v
end
end
})
UIBox.Zoom:AddToggle("Unlimited Zoom", {
Default = false,
Text = "Unlimited Zoom",
Callback = function(v)
CameraZoom.UnlimitedZoom = v
if v then
if not CameraZoom.ZoomWasActive then
CameraMutation.Sequence = CameraMutation.Sequence + 1
CameraZoom.ZoomOrder = CameraMutation.Sequence
CameraZoom.SavedMinZoom = LocalPlayer.CameraMinZoomDistance
CameraZoom.SavedMaxZoom = LocalPlayer.CameraMaxZoomDistance
CameraZoom.ZoomWasActive = true
end
LocalPlayer.CameraMaxZoomDistance = CameraZoom.MaxDistance
LocalPlayer.CameraMinZoomDistance = CameraZoom.MinDistance
return
end
if CameraZoom.ZoomWasActive then
if CameraZoom.SavedMaxZoom ~= nil then
LocalPlayer.CameraMaxZoomDistance = CameraZoom.SavedMaxZoom
end
if CameraZoom.SavedMinZoom ~= nil then
LocalPlayer.CameraMinZoomDistance = CameraZoom.SavedMinZoom
end
CameraZoom.ZoomWasActive = false
CameraZoom.ZoomOrder = nil
CameraZoom.SavedMinZoom = nil
CameraZoom.SavedMaxZoom = nil
end
end
})
UIBox.Zoom:AddSlider("Max Zoom Distance", {
Text = "Max Zoom",
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
UIBox.Zoom:AddToggle("FOV Changer", {
Default = false,
Text = "Ubah Sudut Pandang (FOV)",
Callback = function(v)
CameraZoom.FOVEnabled = v
local cam = workspace.CurrentCamera
if v then
if not cam then return end
if not CameraZoom.FOVWasActive then
CameraMutation.Sequence = CameraMutation.Sequence + 1
CameraZoom.FOVOrder = CameraMutation.Sequence
CameraZoom.SavedFOV = cam.FieldOfView
CameraZoom.FOVWasActive = true
end
cam.FieldOfView = CameraZoom.FOV
CameraZoom.AppliedFOV = CameraZoom.FOV
return
end
local appliedFOV = CameraZoom.AppliedFOV or CameraZoom.FOV
local looksScripted = cam
and appliedFOV ~= nil
and math.abs(cam.FieldOfView - appliedFOV) <= 0.05
if cam and (CameraZoom.FOVWasActive or looksScripted) then
cam.FieldOfView = CameraZoom.SavedFOV
or OriginalCamera.FOV
or 70
end
CameraZoom.FOVWasActive = false
CameraZoom.FOVOrder = nil
CameraZoom.SavedFOV = nil
CameraZoom.AppliedFOV = nil
end
})
UIBox.Zoom:AddSlider("FOV Value", {
Text = "Lebar Pandangan",
Default = 70,
Min = 1,
Max = 120,
Callback = function(v)
CameraZoom.FOV = v
if CameraZoom.FOVEnabled then
local cam = workspace.CurrentCamera
if cam then
cam.FieldOfView = v
CameraZoom.AppliedFOV = v
end
end
end
})
UIBox.MorphAvatar:AddInput("Morph Username", {
Default = "",
Numeric = false,
Finished = false,
Text = "Username",
Callback = function(v) MorphState.Username = tostring(v or "") end
})
UIBox.MorphAvatar:AddButton({
Text = "Apply Morph",
Func = _BH_FN.applyMorphByUsername
})
UIBox.MorphAvatar:AddButton({
Text = "Reset Morph",
Func = _BH_FN.resetMorph
})
UIBox.Settings:AddToggle("KeybindMenuOpen", {
Default = Library.KeybindFrame and Library.KeybindFrame.Visible or false,
Text = "Show Keybind Menu",
Callback = function(value)
if Library.KeybindFrame then
Library.KeybindFrame.Visible = value
end
end
})
UIBox.Settings:AddToggle("UIAnimations", {
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
UIBox.Settings:AddKeyPicker("MenuKeybind", {
Default = "RightShift",
Mode = "Toggle",
NoUI = true,
Text = "Toggle Bluehaven UI",
ChangedCallback = function(v)
_BH_FN.KB_Apply(
"MenuKeybind",
"Toggle UI",
v,
MenuKeybindState.Key,
function(key)
MenuKeybindState.Key = key
end
)
end,
})
Library.ToggleKeybind = Options.MenuKeybind
UIBox.Settings:AddButton({
Text = "Toggle UI",
Func = function()
pcall(function()
Window:Toggle()
end)
end
})
UIBox.Settings:AddDivider()
UIBox.Settings:AddButton({
Text = "Unload Hub (Clean)",
Func = function()
if HubRuntime.Unloading then
return
end
pcall(function()
Library:Unload()
end)
end
})
Movement.JumpPowerEnabled = false
Movement.ForceJumpEnabled = false
_BH_FN.toggleForceJump(false)
function _BH_FN.refreshAimRuntimeFromUI()
local pistolToggle = Toggles["Pistol Target Assist"]
local veilToggle = Toggles["Veil Target Assist"]
local lightToggle = Toggles["Light Flashlight Aim"]
local fovToggle = Toggles["Aim FOV Visible"]
TargetAssistDiag.PistolEnabled =
pistolToggle and pistolToggle.Value == true or false
TargetAssistDiag.VeilEnabled =
veilToggle and veilToggle.Value == true or false
local lightEnabled =
lightToggle and lightToggle.Value == true or false
ToolAimAssist.Enabled = lightEnabled
SilentAim.Enabled = lightEnabled
ToFAimConfig.Enabled = lightEnabled
ToolAimAssist.ShowFOV =
fovToggle and fovToggle.Value == true or false
_BH_FN.TAD_RefreshConnection()
if lightEnabled then
_BH_FN.setupSilentAimHook()
_BH_FN.setupToolAimAssistListeners()
else
_BH_FN.removeSilentAimHook()
_BH_FN.stopToolAimAssistListeners()
end
_BH_FN.FAA_SetEnabled(lightEnabled)
_BH_FN.updateAimFOVVisual()
end
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
function _BH_FN.sanitizeConfigName(value)
local name = tostring(value or "")
name = name:gsub("^%s+", ""):gsub("%s+$", "")
name = name:gsub("[/\\:%*%?%\"<>|]", "_")
if #name > 40 then name = name:sub(1, 40) end
return name
end
function _BH_FN.refreshConfigList(selectName)
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
function _BH_FN.configExists(name)
if not name or name == "" then return false end
local values = _BH_FN.refreshConfigList()
for _, existing in ipairs(values) do
if existing == name then return true end
end
return false
end
function _BH_FN.setActiveConfig(name)
local clean = _BH_FN.sanitizeConfigName(name)
if clean == "" then clean = nil end
AutoSaveConfig.ConfigName = clean
end
function _BH_FN.getSelectedConfig()
local selected = Options.SaveManager_ConfigList and Options.SaveManager_ConfigList.Value
if type(selected) == "string" and selected ~= "" then
return _BH_FN.sanitizeConfigName(selected)
end
return nil
end
function _BH_FN.getCreatedConfigCandidate()
if AutoSaveConfig.ConfigName and _BH_FN.configExists(AutoSaveConfig.ConfigName) then
return AutoSaveConfig.ConfigName
end
local selected = _BH_FN.getSelectedConfig()
if selected and _BH_FN.configExists(selected) then
return selected
end
local typed = Options.SaveManager_ConfigName and _BH_FN.sanitizeConfigName(Options.SaveManager_ConfigName.Value)
if typed and typed ~= "" and _BH_FN.configExists(typed) then
return typed
end
return nil
end
function _BH_FN.saveActiveConfig(silent)
local name = AutoSaveConfig.ConfigName
if not name or not _BH_FN.configExists(name) then
if not silent then
_BH_FN.notify("Config", "Buat atau load config dulu.", 2)
end
return false
end
local success, err = SaveManager:Save(name)
if not success and not silent then
_BH_FN.notify("Config", "Save gagal: " .. tostring(err), 2)
end
return success == true
end
function _BH_FN.scheduleAutoSave()
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
_BH_FN.saveActiveConfig(true)
end)
end
UIBox.Config:AddInput("SaveManager_ConfigName", {
Text = "Config Name",
Default = "",
Numeric = false,
Finished = false,
Placeholder = "example: config5",
Callback = function() end,
})
UIBox.Config:AddDropdown("SaveManager_ConfigList", {
Text = "Config List",
Values = SaveManager:RefreshConfigList(),
AllowNull = true,
Callback = function() end,
})
UIBox.Config:AddButtonRow({
Text = "Create Config",
Func = function()
local name = _BH_FN.sanitizeConfigName(Options.SaveManager_ConfigName.Value)
if name == "" then
_BH_FN.notify("Config", "Isi Config Name dulu.", 2)
return
end
local success, err = SaveManager:Save(name)
if not success then
_BH_FN.notify("Config", "Create gagal: " .. tostring(err), 2)
return
end
_BH_FN.setActiveConfig(name)
_BH_FN.refreshConfigList(name)
_BH_FN.notify("Config", "Created: " .. name, 2)
end
}, {
Text = "Load",
Func = function()
local name = _BH_FN.getSelectedConfig()
if not name then
_BH_FN.notify("Config", "Pilih Config List dulu.", 2)
return
end
AutoSaveConfig.Suppress = true
AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
KeybindGuard.Ready = false
local success, err = SaveManager:Load(name)
if not success then
AutoSaveConfig.Suppress = false
KeybindGuard.Ready = true
_BH_FN.notify("Config", "Load gagal: " .. tostring(err), 2)
return
end
_BH_FN.setActiveConfig(name)
pcall(function() Options.SaveManager_ConfigName:SetValue(name) end)
task.delay(0.75, function()
AutoSaveConfig.Suppress = false
KeybindGuard.Ready = true
if HubRuntime.Alive then
_BH_FN.refreshAimRuntimeFromUI()
end
end)
_BH_FN.notify("Config", "Loaded: " .. name, 2)
end
})
UIBox.Config:AddButtonRow({
Text = "Overwrite",
Func = function()
local name = _BH_FN.getSelectedConfig() or AutoSaveConfig.ConfigName
if not name or not _BH_FN.configExists(name) then
_BH_FN.notify("Config", "Buat atau pilih config dulu.", 2)
return
end
_BH_FN.setActiveConfig(name)
local success, err = SaveManager:Save(name)
_BH_FN.notify("Config", success and ("Saved: " .. name) or ("Save gagal: " .. tostring(err)), 2)
end
}, {
Text = "Refresh",
Func = function()
_BH_FN.refreshConfigList()
_BH_FN.notify("Config", "List refreshed.", 1.5)
end
})
UIBox.Config:AddButton({
Text = "Set Auto Load",
Size = UDim2.new(1, 0, 0, UI_TOUCH_DEVICE and 40 or 32),
Func = function()
local name =
_BH_FN.getSelectedConfig()
or AutoSaveConfig.ConfigName
if not name or not _BH_FN.configExists(name) then
_BH_FN.notify("Config", "Pilih config yang sudah dibuat dulu.", 2)
return
end
local ok, err = pcall(function()
local settingsFolder =
SaveManager.Folder .. "/settings"
if type(isfolder) == "function"
and type(makefolder) == "function"
and not isfolder(settingsFolder) then
makefolder(settingsFolder)
end
assert(
type(writefile) == "function",
"writefile tidak tersedia"
)
writefile(
settingsFolder .. "/autoload.txt",
name
)
end)
if ok then
_BH_FN.setActiveConfig(name)
end
_BH_FN.notify(
"Config",
ok
and ("Auto load: " .. name)
or ("Gagal set auto load: " .. tostring(err)),
2
)
end
})
UIBox.Config:AddToggle("AutoSaveConfig", {
Default = false,
Text = "Auto Save Config",
Callback = function(v)
if not v then
AutoSaveConfig.Enabled = false
AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
return
end
local name = _BH_FN.getCreatedConfigCandidate()
if not name then
AutoSaveConfig.Enabled = false
_BH_FN.notify("Auto Save", "Buat atau load config dulu.", 2)
task.defer(function()
if Toggles.AutoSaveConfig and Toggles.AutoSaveConfig.Value then
Toggles.AutoSaveConfig:SetValue(false)
end
end)
return
end
_BH_FN.setActiveConfig(name)
AutoSaveConfig.Enabled = true
_BH_FN.saveActiveConfig(true)
_BH_FN.notify("Auto Save", "Active: " .. name, 2)
end
})
pcall(function()
ThemeManager:ApplyToTab(Tabs.UISettings)
end)
function _BH_FN.bindAutoSaveWatchers()
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
_BH_FN.scheduleAutoSave()
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
task.defer(_BH_FN.bindAutoSaveWatchers)
function _BH_FN.getAutoLoadConfigName()
local path =
tostring(SaveManager.Folder)
.. "/settings/autoload.txt"
if type(isfile) ~= "function"
or type(readfile) ~= "function"
or not isfile(path) then
return nil, path
end
local ok, value = pcall(readfile, path)
if not ok then
return nil, path
end
local name = _BH_FN.sanitizeConfigName(value)
if name == "" then
return nil, path
end
return name, path
end
function _BH_FN.loadAutoConfigWhenReady()
task.wait(0.65)
if not HubRuntime.Alive then
return
end
AutoSaveConfig.Suppress = true
AutoSaveConfig.Generation =
AutoSaveConfig.Generation + 1
local loadedName = nil
local ok, err = pcall(function()
local name = _BH_FN.getAutoLoadConfigName()
if name then
if not _BH_FN.configExists(name) then
error("config '" .. name .. "' tidak ditemukan")
end
local success, loadErr = SaveManager:Load(name)
if not success then
error(loadErr or "SaveManager:Load gagal")
end
loadedName = name
_BH_FN.setActiveConfig(name)
pcall(function()
Options.SaveManager_ConfigName:SetValue(name)
Options.SaveManager_ConfigList:SetValue(name)
end)
return
end
SaveManager:LoadAutoloadConfig()
end)
task.delay(0.75, function()
if HubRuntime.Alive then
AutoSaveConfig.Suppress = false
KeybindGuard.Ready = true
_BH_FN.refreshAimRuntimeFromUI()
end
end)
if not ok then
_BH_FN.notify(
"Auto Load",
"Load gagal: " .. tostring(err),
2
)
elseif loadedName then
_BH_FN.notify(
"Auto Load",
"Loaded: " .. loadedName,
2
)
end
task.defer(_BH_FN.UI_SelectAbout)
end
task.spawn(_BH_FN.loadAutoConfigWhenReady)
function _BH_FN.UI_RunLateGradientPasses()
for _, delaySeconds in ipairs({0, 0.8, 2.0}) do
task.delay(delaySeconds, function()
if HubRuntime.Alive then
pcall(_BH_FN.UI_CreateVIPBadge)
pcall(_BH_FN.UI_ApplyVisibleGradients)
end
end)
end
end
_BH_FN.UI_RunLateGradientPasses()
HubRuntime.StopToken = {}
pcall(function()
local env =
(type(getgenv) == "function" and getgenv())
or _G
env.__BLUEHAVEN_RUNTIME_TOKEN = HubRuntime.StopToken
env.__BLUEHAVEN_RUNTIME_STOP = function()
if env.__BLUEHAVEN_RUNTIME_TOKEN ~= HubRuntime.StopToken
or not HubRuntime.Alive then
return
end
HubRuntime.Alive = false
HubRuntime.Unloading = true
Auto.SkillCheck = false
Auto.SkillCheckGenerator = false
Auto.Parry = false
Auto.PalletDrop = false
Config.Surv_AutoParry = false
Config.Surv_AutoCrouch = false
SilentAim.Enabled = false
ToolAimAssist.Enabled = false
FlashlightAimAssist.Enabled = false
TargetAssistDiag.PistolEnabled = false
TargetAssistDiag.VeilEnabled = false
Killer.KillAll = false
Killer.BypassCooldown = false
Killer.NoAttackSlow = false
Killer.BypassLeap = false
Killer.AntiBlind = false
Killer.BlockVaults = false
pcall(_BH_FN.toggleBypassCooldown, false)
pcall(_BH_FN.KAS_SetEnabled, false)
pcall(_BH_FN.DAP_UnloadSafe)
pcall(_BH_FN.GB_UnloadSafe)
pcall(_BH_FN.SH_Stop, false, nil, true, true)
pcall(_BH_FN.AK_SetEnabled, false)
Movement.NoClip = false
pcall(_BH_FN.toggleNoClip, false)
FastVault.Enabled = false
pcall(_BH_FN.FV_Disconnect)
pcall(_BH_FN.FV_RestoreProximityHook)
pcall(_BH_FN.ASV_SetEnabled, false)
pcall(_BH_FN.stopToolAimAssistListeners)
pcall(_BH_FN.FAA_SetEnabled, false)
pcall(_BH_FN.TAD_RefreshConnection)
pcall(_BH_FN.SC_Stop)
HideName.Enabled = false
pcall(_BH_FN.enableHideName, false)
pcall(function()
if FakeTagHook.Installed then
TextChatService.OnIncomingMessage =
FakeTagHook.Original
end
FakeTagHook.Installed = false
FakeTagHook.Original = nil
end)
pcall(_BH_FN.DisconnectTrackedConnections)
pcall(_BH_FN.DestroyTrackedArtifacts)
pcall(_BH_FN.BH_CleanupOldGui)
if env.__BLUEHAVEN_RUNTIME_TOKEN == HubRuntime.StopToken then
env.__BLUEHAVEN_RUNTIME_STOP = nil
env.__BLUEHAVEN_RUNTIME_TOKEN = nil
end
end
end)
Connections.MainHeartbeat = _BH_FN.TrackConnection(RunService.Heartbeat:Connect(function()
if not HubRuntime.Alive then return end
local now = tick()
State.Frames = State.Frames + 1
if now - State.LastTick >= 1 then
local elapsed = math.max(now - State.LastTick, 0.001)
State.FPS = math.floor(State.Frames / elapsed + 0.5)
State.Frames = 0
State.LastTick = now
local footerRole = _BH_FN.UI_GetMouseRole()
_BH_FN.UI_UpdateProfileStatus(
footerRole,
State.FPS
)
end
if Killer.KillAll
and now - Timers.lastKillerUpdate >= 0.02 then
Timers.lastKillerUpdate = now
_BH_FN.KA_Update(now)
end
if PlayerMods.GodMode and now - Timers.lastGodMode >= 0.10 then
Timers.lastGodMode = now
_BH_FN.applyGodMode()
end
local espCanRender =
_BH_FN.ESP_UpdateLocalRoleGate()
local root = getRoot()
if root and espCanRender then
local playerDue = (ESP.Survivor or ESP.Killer)
and (now - Timers.lastPlayerESP >= ESPPerf.PlayerInterval)
if playerDue then
Timers.lastPlayerESP = now
local rootPos = root.Position
local rangeSq = ESP.Distance * ESP.Distance
for _, p in ipairs(
Players:GetPlayers()
) do
if p ~= LocalPlayer
and p.Character then
local char =
p.Character
local playerRole =
_BH_FN.AIM_GetRole(p)
local isSurv =
playerRole == "Survivor"
local isKill =
playerRole == "Killer"
local enabled =
(ESP.Survivor and isSurv)
or (ESP.Killer and isKill)
local phrp =
char:FindFirstChild(
"HumanoidRootPart"
)
local hum =
char:FindFirstChildOfClass(
"Humanoid"
)
local state =
_BH_FN.ESP_GetCharacterState(
char,
hum
)
local inRange =
phrp
and _BH_FN.distSq(
phrp.Position,
rootPos
) <= rangeSq
if enabled
and inRange
and state ~= "DEAD" then
local distance =
(
phrp.Position
- rootPos
).Magnitude
local visible =
_BH_FN.ESP_IsCharacterVisible(
root,
char
)
_BH_FN.createESP(
char,
isKill
and TeamColors.Killer
or TeamColors.Survivor,
{
Distance = distance,
Visible = visible,
State = state,
}
)
else
_BH_FN.removeESP(char)
end
end
end
end
local statusDue = _BH_FN.isStatusESPEnabled()
and (now - Timers.lastStatusESP >= ESPPerf.StatusInterval)
if statusDue then
Timers.lastStatusESP = now
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character then
_BH_FN.createStatusESP(p, p.Character, root)
end
end
end
if ESP.Generator and now - Timers.lastGeneratorESP >= ESPPerf.GeneratorInterval then
Timers.lastGeneratorESP = now
for gen in pairs(ESPCache.Generators) do
if gen and gen.Parent then _BH_FN.UpdateGenerator(gen, root) end
end
end
if ESP.Window and now - Timers.lastWindowESP >= ESPPerf.WindowInterval then
Timers.lastWindowESP = now
_BH_FN.processMapBatch(ESPCache.WindowList, ESPCache.Windows, root, "Window", "WindowCursor")
end
if ESP.Pallet and now - Timers.lastPalletESP >= ESPPerf.PalletInterval then
Timers.lastPalletESP = now
_BH_FN.processMapBatch(ESPCache.PalletList, ESPCache.Pallets, root, "Pallet", "PalletCursor")
end
if ESP.Hook and now - Timers.lastHookESP >= ESPPerf.HookInterval then
Timers.lastHookESP = now
_BH_FN.processMapBatch(ESPCache.HookList, ESPCache.Hooks, root, "Hook", "HookCursor")
end
if ESP.SCP and now - Timers.lastSCPEsp >= ESPPerf.SCPInterval then
Timers.lastSCPEsp = now
_BH_FN.UpdateSCPEsp(root)
end
end
end))
Connections.MainCharacterAdded = _BH_FN.TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
if not HubRuntime.Alive then return end
task.wait(0.5)
if Movement.BoostEnabled then _BH_FN.applyMovementBoost() end
if Movement.NoClip then _BH_FN.toggleNoClip(true) end
if PlayerMods.GodMode then _BH_FN.applyGodMode() end
if HideName.Enabled then _BH_FN.hideOverheadName(true) end
if Crosshair.Enabled then _BH_FN.updateCrosshairGui() end
Movement.OriginalHumanoid = nil
MorphState.OriginalDescription = nil
if Config.Surv_AutoParry then
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and IsKiller(p) and p.Character then
AttachParrySensor(p.Character)
end
end
end
end))
function _BH_FN.SetupExistingPlayers()
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
SetupPlayer(p)
end
end
end
_BH_FN.SetupExistingPlayers()
Connections.PlayerAdded = _BH_FN.TrackConnection(Players.PlayerAdded:Connect(function(p)
if HubRuntime.Alive then SetupPlayer(p) end
end))
function _BH_FN.AutoStartParrySensors()
if Config.Surv_AutoParry then
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and IsKiller(p) and p.Character then
AttachParrySensor(p.Character)
end
end
end
end
_BH_FN.AutoStartParrySensors()
function _BH_FN.HardClearBluehavenVisuals()
pcall(function()
local objects = {}
for obj in pairs(ESPCache.Objects) do objects[#objects + 1] = obj end
for _, obj in ipairs(objects) do _BH_FN.removeESP(obj) end
end)
pcall(_BH_FN.clearAllStatusESP)
pcall(_BH_FN.clearGeneratorESP)
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
pcall(_BH_FN.destroyCrosshairGui)
if GenBypass.UI then
_BH_FN.DestroyArtifact(GenBypass.UI)
end
GenBypass.UI = nil
GenBypass.Button = nil
local oldBypass = PlayerGui:FindFirstChild("BypassGenUI")
if oldBypass then pcall(function() oldBypass:Destroy() end) end
local oldCrosshair = PlayerGui:FindFirstChild("BluehavenCrosshair")
if oldCrosshair then pcall(function() oldCrosshair:Destroy() end) end
if ToolAimAssist.TracerPart then
_BH_FN.DestroyArtifact(ToolAimAssist.TracerPart)
ToolAimAssist.TracerPart = nil
end
_BH_FN.DestroyTrackedArtifacts()
AimFOVVisual.Gui = nil
AimFOVVisual.Circle = nil
AimFOVVisual.Stroke = nil
end
function _BH_FN.UV_CopyNoClipExpected()
local result = {}
for part, original in pairs(NoClipOriginal) do
if part and part.Parent then
result[#result + 1] = {
Part = part,
CanCollide = original,
}
end
end
return result
end
function _BH_FN.UV_Capture()
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
local data = {
Character = char,
Root = root,
Humanoid = hum,
ExpectUnanchored =
GenBypass.Running == true
or DropAllPallet.Running == true
or GenBypass.ActiveHRP == root,
NoClipExpected = _BH_FN.UV_CopyNoClipExpected(),
HadThirdPerson = Killer.ThirdPersonWasActive == true,
ExpectedCameraType = Killer.OriginalCameraType,
ExpectedCameraMode = Killer.OriginalCameraMode,
ThirdPersonOrder = Killer.ThirdPersonOrder,
ThirdMin = Killer.OriginalMinZoom,
ThirdMax = Killer.OriginalMaxZoom,
HadZoom = CameraZoom.ZoomWasActive == true,
ZoomOrder = CameraZoom.ZoomOrder,
ZoomMin = CameraZoom.SavedMinZoom,
ZoomMax = CameraZoom.SavedMaxZoom,
HadFOV = CameraZoom.FOVWasActive == true,
ExpectedFOV = CameraZoom.SavedFOV,
}
if data.HadThirdPerson and data.HadZoom then
local thirdOrder = tonumber(data.ThirdPersonOrder) or math.huge
local zoomOrder = tonumber(data.ZoomOrder) or math.huge
if thirdOrder <= zoomOrder then
data.ExpectedMinZoom = data.ThirdMin
data.ExpectedMaxZoom = data.ThirdMax
else
data.ExpectedMinZoom = data.ZoomMin
data.ExpectedMaxZoom = data.ZoomMax
end
elseif data.HadThirdPerson then
data.ExpectedMinZoom = data.ThirdMin
data.ExpectedMaxZoom = data.ThirdMax
elseif data.HadZoom then
data.ExpectedMinZoom = data.ZoomMin
data.ExpectedMaxZoom = data.ZoomMax
end
return data
end
function _BH_FN.UV_RestoreCamera(data)
if not data then return end
local cam = workspace.CurrentCamera
if data.HadThirdPerson then
if cam and data.ExpectedCameraType ~= nil then
pcall(function()
cam.CameraType = data.ExpectedCameraType
end)
end
if data.ExpectedCameraMode ~= nil then
pcall(function()
LocalPlayer.CameraMode = data.ExpectedCameraMode
end)
end
end
if data.ExpectedMinZoom ~= nil then
pcall(function()
LocalPlayer.CameraMinZoomDistance = data.ExpectedMinZoom
end)
end
if data.ExpectedMaxZoom ~= nil then
pcall(function()
LocalPlayer.CameraMaxZoomDistance = data.ExpectedMaxZoom
end)
end
if data.HadFOV and cam and data.ExpectedFOV ~= nil then
pcall(function()
cam.FieldOfView = data.ExpectedFOV
end)
end
Killer.ThirdPerson = false
Killer.ThirdPersonWasActive = false
Killer.ThirdPersonOrder = nil
Killer.OriginalCameraType = nil
Killer.OriginalCameraMode = nil
Killer.OriginalMinZoom = nil
Killer.OriginalMaxZoom = nil
CameraZoom.UnlimitedZoom = false
CameraZoom.ZoomWasActive = false
CameraZoom.ZoomOrder = nil
CameraZoom.SavedMinZoom = nil
CameraZoom.SavedMaxZoom = nil
CameraZoom.FOVEnabled = false
CameraZoom.FOVWasActive = false
CameraZoom.FOVOrder = nil
CameraZoom.SavedFOV = nil
CameraZoom.AppliedFOV = nil
end
function _BH_FN.UV_NamecallProbe()
local ok, result = pcall(function()
return game:GetService("Players") == Players
and game:GetService("RunService") == RunService
and #Players:GetPlayers() >= 1
end)
return ok and result == true
end
function _BH_FN.UV_Probe(data)
local reasons = {}
if not _BH_FN.UV_NamecallProbe() then
reasons[#reasons + 1] = "NAMECALL"
end
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if data.ExpectUnanchored and root and root.Anchored then
reasons[#reasons + 1] = "ROOT_ANCHORED"
end
local collisionMismatch = 0
for _, item in ipairs(data.NoClipExpected or {}) do
local part = item.Part
if part and part.Parent and part.CanCollide ~= item.CanCollide then
collisionMismatch = collisionMismatch + 1
end
end
if collisionMismatch > 0 then
reasons[#reasons + 1] = "NOCLIP_RESTORE"
end
if data.HadAutoRun
and hum
and tonumber(data.ExpectedWalkSpeed)
and data.ExpectedWalkSpeed > 0
and hum.WalkSpeed <= 0 then
reasons[#reasons + 1] = "WALKSPEED_ZERO"
end
if data.HadThirdPerson then
local cam = workspace.CurrentCamera
if not cam then
reasons[#reasons + 1] = "CAMERA_MISSING"
else
if data.ExpectedCameraType ~= nil
and cam.CameraType ~= data.ExpectedCameraType then
reasons[#reasons + 1] = "CAMERA_TYPE"
end
if data.ExpectedCameraMode ~= nil
and LocalPlayer.CameraMode ~= data.ExpectedCameraMode then
reasons[#reasons + 1] = "CAMERA_MODE"
end
end
end
return reasons
end
function _BH_FN.UV_IsHardFailure(reasons)
local hard = {
NAMECALL = true,
ROOT_ANCHORED = true,
CAMERA_MISSING = true,
CAMERA_TYPE = true,
NOCLIP_RESTORE = true,
WALKSPEED_ZERO = true,
}
for _, reason in ipairs(reasons) do
if hard[reason] then
return true
end
end
return #reasons >= 2
end
function _BH_FN.UV_StartPostUnloadWatch(data)
UnloadValidation.Token = UnloadValidation.Token + 1
local token = UnloadValidation.Token
task.spawn(function()
task.wait(0.35)
if token ~= UnloadValidation.Token then
return
end
local first = _BH_FN.UV_Probe(data)
if not _BH_FN.UV_IsHardFailure(first) then
return
end
task.wait(0.85)
if token ~= UnloadValidation.Token then
return
end
local second = _BH_FN.UV_Probe(data)
if not _BH_FN.UV_IsHardFailure(second) then
return
end
UnloadValidation.LastReasons = second
pcall(function()
warn(
"[Bluehaven] unload validation failed: "
.. table.concat(second, ", ")
)
end)
pcall(function()
LocalPlayer:Kick(
"Bluehaven: Failed unload.\nPlease report bug."
)
end)
end)
end
if type(Library.OnUnload) == "function" then
Library:OnUnload(function()
if HubRuntime.Unloading then
return
end
HubRuntime.Unloading = true
local unloadCheck = _BH_FN.UV_Capture()
HubRuntime.Alive = false
if AutoSaveConfig then
AutoSaveConfig.Enabled = false
AutoSaveConfig.Generation = AutoSaveConfig.Generation + 1
end
Auto.SkillCheck = false
Auto.SkillCheckGenerator = false
Auto.Parry = false
Auto.PalletDrop = false
SilentAim.Enabled = false
ToFAimConfig.Enabled = false
ToolAimAssist.Enabled = false
TargetAssistDiag.PistolEnabled = false
TargetAssistDiag.VeilEnabled = false
TargetAssistDiag.PrecisionEnabled = false
FlashlightAimAssist.Enabled = false
ParryDryRun.Enabled = false
Config.Surv_AutoParry = false
Config.Surv_AutoCrouch = false
pcall(function()
local parryTracks = {}
for track in pairs(ParrySensor.ActiveTracks) do
parryTracks[#parryTracks + 1] = track
end
for _, track in ipairs(parryTracks) do
_BH_FN.PARRY_StopWatcher(track)
end
end)
State.ParryInputLockUntil = 0
if State.ParryCooldownThread
and type(task.cancel) == "function" then
pcall(task.cancel, State.ParryCooldownThread)
State.ParryCooldownThread = nil
end
Killer.KillAll = false
_BH_FN.KA_Reset()
Killer.BypassCooldown = false
Killer.NoAttackSlow = false
Killer.BypassLeap = false
Killer.AntiBlind = false
Killer.BlockVaults = false
pcall(_BH_FN.toggleBypassCooldown, false)
pcall(_BH_FN.KAS_SetEnabled, false)
pcall(_BH_FN.DAP_UnloadSafe)
pcall(_BH_FN.GB_UnloadSafe)
pcall(
_BH_FN.SH_Stop,
true,
nil,
true,
true
)
pcall(_BH_FN.AK_SetEnabled, false)
AntiLoopStuck.Enabled = false
if AntiLoopStuck.Connection then
pcall(function()
AntiLoopStuck.Connection:Disconnect()
end)
_BH_FN.ForgetConnection(
AntiLoopStuck.Connection
)
AntiLoopStuck.Connection = nil
end
if Movement.BoostEnabled
or Movement.BoostCharacter then
Movement.BoostEnabled = false
pcall(_BH_FN.MB_RestoreNative)
end
Movement.NoClip = false
pcall(_BH_FN.toggleNoClip, false)
FastVault.Enabled = false
pcall(_BH_FN.FV_Disconnect)
pcall(_BH_FN.FV_RestoreProximityHook)
AntiSlowVault.Enabled = false
pcall(_BH_FN.ASV_SetEnabled, false)
pcall(_BH_FN.stopToolAimAssistListeners)
pcall(_BH_FN.FAA_SetEnabled, false)
pcall(_BH_FN.TAD_RefreshConnection)
pcall(_BH_FN.SC_Stop)
HideName.Enabled = false
pcall(_BH_FN.enableHideName, false)
pcall(function()
if FakeTagHook.Installed then
TextChatService.OnIncomingMessage =
FakeTagHook.Original
end
FakeTagHook.Installed = false
FakeTagHook.Original = nil
end)
pcall(_BH_FN.stopFakeParryAnimation)
pcall(
_BH_FN.UV_RestoreCamera,
unloadCheck
)
pcall(_BH_FN.DisconnectTrackedConnections)
pcall(_BH_FN.HardClearBluehavenVisuals)
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
end)
pcall(function()
local env =
(type(getgenv) == "function" and getgenv())
or _G
if env.__BLUEHAVEN_CLEANUP_TOKEN
== BluehavenCleanupToken then
env.__BLUEHAVEN_GUI_CLEANUP =
nil
env.__BLUEHAVEN_CLEANUP_TOKEN =
nil
end
end)
print(
"[Bluehaven] Ultra Safe Unload complete"
)
_BH_FN.UV_StartPostUnloadWatch(
unloadCheck
)
end)
end
print("[Bluehaven] Hub loaded! Enjoy!")
end
_BH_FN.RunBluehavenHub()
