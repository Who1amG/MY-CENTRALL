-- 🦈 Glassmas UI • Apple Glass Christmas (Xeno)
-- Un solo script • Copy/Paste • Drag + Tabs + Notifs + Sounds + Themes + Minimize/Close
-- Hecho para Sp4rk

--================ SERVICES ================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--================ SAFE PARENT (Xeno) ================
local function getUiParent()
    local ok, res = pcall(function()
        if gethui then return gethui() end
    end)
    if ok and res then return res end
    return PlayerGui
end

--================ TWEENS ================
local TFast = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TMed  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TSlow = TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

--================ GUI ROOT =================
local UI = Instance.new("ScreenGui")
UI.Name = "GlassmasUI"
UI.ResetOnSpawn = false
UI.Parent = getUiParent()

--================ SOUNDS (SWAPPED AS REQUESTED) ================
-- Tabs (cambiar casilla) -> "slide"
-- Options (activar botón) -> "click"
local S_Slide = Instance.new("Sound", UI)
S_Slide.SoundId = "rbxassetid://6026984224"
S_Slide.Volume = 1

local S_Click = Instance.new("Sound", UI)
S_Click.SoundId = "rbxassetid://541909867"
S_Click.Volume = 1

local function playTabSound()
    pcall(function() SoundService:PlayLocalSound(S_Slide) end)
end

local function playOptionSound()
    pcall(function() SoundService:PlayLocalSound(S_Click) end)
end

--================ THEME (Glass more vivid) ================
local Theme = {
    Glass  = Color3.fromRGB(255,110,110),
    Header = Color3.fromRGB(60,15,20),
    Accent = Color3.fromRGB(255,90,90),
    Text   = Color3.fromRGB(245,248,255),
    Muted  = Color3.fromRGB(210,220,255),
}

local Styles = {
    Red =    { Glass=Color3.fromRGB(255,110,110), Header=Color3.fromRGB(60,15,20),  Accent=Color3.fromRGB(255,90,90)  },
    Blue =   { Glass=Color3.fromRGB(110,165,255), Header=Color3.fromRGB(15,25,60),  Accent=Color3.fromRGB(120,180,255) },
    Black =  { Glass=Color3.fromRGB(55,55,55),    Header=Color3.fromRGB(15,15,15),  Accent=Color3.fromRGB(200,200,200) },
    Purple = { Glass=Color3.fromRGB(175,120,255), Header=Color3.fromRGB(40,20,70),  Accent=Color3.fromRGB(205,150,255) },
    Green =  { Glass=Color3.fromRGB(120,255,180), Header=Color3.fromRGB(15,60,35),  Accent=Color3.fromRGB(120,255,180) },
    Gold =   { Glass=Color3.fromRGB(255,210,120), Header=Color3.fromRGB(75,55,18),  Accent=Color3.fromRGB(255,215,120) },
}

--================ WINDOW ================
local Window = Instance.new("Frame", UI)
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, 600, 0, 380)
Window.BackgroundColor3 = Theme.Glass
Window.BackgroundTransparency = 0.80
Window.BorderSizePixel = 0
Window.ClipsDescendants = false

local WCorner = Instance.new("UICorner", Window)
WCorner.CornerRadius = UDim.new(0, 22)

local WStroke = Instance.new("UIStroke", Window)
WStroke.Color = Theme.Accent
WStroke.Thickness = 1.5
WStroke.Transparency = 0.45

local WGrad = Instance.new("UIGradient", Window)
WGrad.Rotation = 25
WGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.10),
    NumberSequenceKeypoint.new(0.5, 0.25),
    NumberSequenceKeypoint.new(1, 0.10),
})

--================ HEADER ================
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1, 0, 0, 56)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Theme.Header
Header.BackgroundTransparency = 0.25
Header.BorderSizePixel = 0
Header.Active = true

local HCorner = Instance.new("UICorner", Header)
HCorner.CornerRadius = UDim.new(0, 22)

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 80, 0, 0)
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "🦈 Glassmas UI • 🎄 Christmas"

local function makeDot(color, x)
    local b = Instance.new("TextButton", Header)
    b.AutoButtonColor = false
    b.Text = ""
    b.Size = UDim2.new(0, 14, 0, 14)
    b.Position = UDim2.new(0, x, 0.5, -7)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local BtnClose = makeDot(Color3.fromRGB(255, 95, 90), 16)
local BtnMin   = makeDot(Color3.fromRGB(255, 200, 80), 40)

local function dotHover(btn)
    btn.MouseEnter:Connect(function()
        tween(btn, TFast, {Size = UDim2.new(0, 15, 0, 15)})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TFast, {Size = UDim2.new(0, 14, 0, 14)})
    end)
end
dotHover(BtnClose)
dotHover(BtnMin)

--================ TABS ================
local Tabs = Instance.new("Frame", Window)
Tabs.BackgroundTransparency = 1
Tabs.Position = UDim2.new(0, 12, 0, 62)
Tabs.Size = UDim2.new(1, -24, 0, 44)

local function makeTabButton(txt, x)
    local b = Instance.new("TextButton", Tabs)
    b.AutoButtonColor = false
    b.Text = txt
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = Theme.Text
    b.BackgroundColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundTransparency = 0.88
    b.BorderSizePixel = 0
    b.Position = UDim2.new(0, x, 0, 0)
    b.Size = UDim2.new(0, 180, 0, 40)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)
    local s = Instance.new("UIStroke", b)
    s.Transparency = 0.75
    s.Color = Theme.Accent
    s.Thickness = 1
    return b, s
end

local TabAuto, TabAutoStroke     = makeTabButton("🏠 Auto Farm", 0)
local TabVisual, TabVisStroke    = makeTabButton("👁 Visual", 190)
local TabSettings, TabSetStroke  = makeTabButton("⚙️ Settings", 380)

--================ CONTENT ================
local Content = Instance.new("Frame", Window)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 12, 0, 112)
Content.Size = UDim2.new(1, -24, 1, -124)
Content.ClipsDescendants = true

local function newPage()
    local p = Instance.new("Frame", Content)
    p.BackgroundTransparency = 1
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    return p
end

local PageAuto = newPage()
local PageVisual = newPage()
local PageSettings = newPage()
PageAuto.Visible = true
local CurrentPage = PageAuto

--================ NOTIFICATIONS ================
local NotifHost = Instance.new("Frame", UI)
NotifHost.BackgroundTransparency = 1
NotifHost.Size = UDim2.new(0, 360, 1, 0)
NotifHost.Position = UDim2.new(1, -380, 0, 12)

local NotifList = Instance.new("UIListLayout", NotifHost)
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 10)
NotifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifList.VerticalAlignment = Enum.VerticalAlignment.Top

local function Notify(msg, good)
    local n = Instance.new("Frame", NotifHost)
    n.Size = UDim2.new(0, 340, 0, 64)
    n.BackgroundColor3 = Theme.Glass
    n.BackgroundTransparency = 0.10
    n.BorderSizePixel = 0
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 16)

    local s = Instance.new("UIStroke", n)
    s.Thickness = 1
    s.Transparency = 0.50
    s.Color = good and Color3.fromRGB(120,255,180) or Color3.fromRGB(255,95,90)

    local t = Instance.new("TextLabel", n)
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 12, 0, 0)
    t.Size = UDim2.new(1, -24, 1, 0)
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = msg

    n.Position = UDim2.new(0, 30, 0, 0)
    tween(n, TFast, {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(2.2, function()
        tween(n, TFast, {Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1})
        tween(s, TFast, {Transparency = 1})
        task.delay(0.22, function()
            if n then n:Destroy() end
        end)
    end)
end

--================ TAB ACTIVE LOOK =================
local function setTabActive(which)
    local function styleTab(btn, st, active)
        tween(btn, TFast, {BackgroundTransparency = active and 0.78 or 0.90})
        tween(st,  TFast, {Transparency = active and 0.40 or 0.80})
    end
    styleTab(TabAuto, TabAutoStroke, which=="auto")
    styleTab(TabVisual, TabVisStroke, which=="visual")
    styleTab(TabSettings, TabSetStroke, which=="settings")
end
setTabActive("auto")

local function switchPage(target, which)
    if target == CurrentPage then return end
    playTabSound()

    local old = CurrentPage
    CurrentPage = target

    target.Position = UDim2.new(0.06, 0, 0, 0)
    target.Visible = true
    tween(target, TMed, {Position = UDim2.new(0,0,0,0)})
    tween(old, TMed, {Position = UDim2.new(-0.06, 0, 0, 0)})

    task.delay(0.26, function()
        if old then
            old.Visible = false
            old.Position = UDim2.new(0,0,0,0)
        end
    end)

    setTabActive(which)
end

TabAuto.MouseButton1Click:Connect(function() switchPage(PageAuto, "auto") end)
TabVisual.MouseButton1Click:Connect(function() switchPage(PageVisual, "visual") end)
TabSettings.MouseButton1Click:Connect(function() switchPage(PageSettings, "settings") end)

--================ APPLE TOGGLE =================
local function makeAppleToggle(parent, label, y)
    local state = false

    local b = Instance.new("TextButton", parent)
    b.AutoButtonColor = false
    b.Size = UDim2.new(0, 320, 0, 44)
    b.Position = UDim2.new(0.5, -160, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundTransparency = 0.86
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)

    local s = Instance.new("UIStroke", b)
    s.Thickness = 1
    s.Color = Theme.Accent
    s.Transparency = 0.80

    local t = Instance.new("TextLabel", b)
    t.BackgroundTransparency = 1
    t.Size = UDim2.new(1, -16, 1, 0)
    t.Position = UDim2.new(0, 12, 0, 0)
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left

    local function render()
        t.Text = ("%s: %s"):format(label, state and "ON" or "OFF")
        tween(s, TFast, {Transparency = state and 0.35 or 0.80})
        tween(b, TFast, {BackgroundTransparency = state and 0.80 or 0.86})
    end
    render()

    b.MouseButton1Click:Connect(function()
        state = not state
        playOptionSound()
        render()
        Notify(label .. (state and " activado" or " desactivado"), state)
    end)

    b.MouseEnter:Connect(function()
        tween(b, TFast, {BackgroundTransparency = math.max(0.72, b.BackgroundTransparency - 0.06)})
    end)
    b.MouseLeave:Connect(function()
        render()
    end)

    return {
        Button = b,
        Set = function(v) state = not not v; render() end,
        Get = function() return state end,
    }
end

--================ AUTO FARM / VISUAL DEMOS =================
makeAppleToggle(PageAuto, "🧪 AutoFarm Test 1", 24)
makeAppleToggle(PageAuto, "🧪 AutoFarm Test 2", 78)
makeAppleToggle(PageVisual, "✨ Visual Test", 24)

--================ SETTINGS ================
local SettingsScroll = Instance.new("ScrollingFrame", PageSettings)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsScroll.ScrollBarThickness = 4
SettingsScroll.ScrollBarImageColor3 = Theme.Accent

local SettingsList = Instance.new("UIListLayout", SettingsScroll)
SettingsList.Padding = UDim.new(0, 10)
SettingsList.SortOrder = Enum.SortOrder.LayoutOrder
SettingsList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updateCanvas()
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, SettingsList.AbsoluteContentSize.Y + 20)
end
SettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.defer(updateCanvas)

local function sectionTitle(text)
    local l = Instance.new("TextLabel", SettingsScroll)
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -24, 0, 22)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextColor3 = Theme.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    return l
end

sectionTitle("🎛️ UI Controls")

local KeyRow = Instance.new("Frame", SettingsScroll)
KeyRow.BackgroundTransparency = 1
KeyRow.Size = UDim2.new(1, -24, 0, 48)

local KeyLabel = Instance.new("TextLabel", KeyRow)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Size = UDim2.new(0.55, 0, 1, 0)
KeyLabel.Font = Enum.Font.GothamSemibold
KeyLabel.TextSize = 13
KeyLabel.TextColor3 = Theme.Muted
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Text = "Tecla para ocultar/mostrar UI:"

local KeyBox = Instance.new("TextBox", KeyRow)
KeyBox.Size = UDim2.new(0, 70, 0, 34)
KeyBox.Position = UDim2.new(0.62, 0, 0.5, -17)
KeyBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
KeyBox.BackgroundTransparency = 0.86
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.GothamBold
KeyBox.TextSize = 16
KeyBox.TextColor3 = Theme.Text
KeyBox.Text = "H"
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)

local SetKeyBtn = Instance.new("TextButton", KeyRow)
SetKeyBtn.AutoButtonColor = false
SetKeyBtn.Size = UDim2.new(0, 110, 0, 34)
SetKeyBtn.Position = UDim2.new(1, -110, 0.5, -17)
SetKeyBtn.BackgroundColor3 = Theme.Glass
SetKeyBtn.BackgroundTransparency = 0.75
SetKeyBtn.BorderSizePixel = 0
SetKeyBtn.Font = Enum.Font.GothamBold
SetKeyBtn.TextSize = 13
SetKeyBtn.TextColor3 = Theme.Text
SetKeyBtn.Text = "ESTABLECER"
Instance.new("UICorner", SetKeyBtn).CornerRadius = UDim.new(0, 10)

local hideKey = Enum.KeyCode.H
local uiVisible = true

SetKeyBtn.MouseButton1Click:Connect(function()
    local txt = tostring(KeyBox.Text or ""):upper()
    if #txt ~= 1 then
        playOptionSound()
        Notify("⚠️ Pon solo 1 letra (A-Z)", false)
        KeyBox.Text = hideKey.Name
        return
    end
    local kc = Enum.KeyCode[txt]
    if not kc then
        playOptionSound()
        Notify("⚠️ Tecla inválida: "..txt, false)
        KeyBox.Text = hideKey.Name
        return
    end
    hideKey = kc
    KeyBox.Text = txt
    playOptionSound()
    Notify("✅ Tecla cambiada a: "..txt, true)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == hideKey then
        uiVisible = not uiVisible
        Window.Visible = uiVisible
        Notify(uiVisible and "🎄 UI mostrada" or "🎄 UI ocultada", uiVisible)
    end
end)

sectionTitle("🎨 Cambiar estilo de UI")

local themeButtons = {}
local currentStyleKey = "Red"

local function applyStyle(key)
    local style = Styles[key]
    if not style then return end
    currentStyleKey = key

    tween(Window, TMed, {BackgroundColor3 = style.Glass})
    tween(Header, TMed, {BackgroundColor3 = style.Header})
    tween(WStroke, TMed, {Color = style.Accent})
    tween(SettingsScroll, TMed, {ScrollBarImageColor3 = style.Accent})
    tween(TabAutoStroke, TMed, {Color = style.Accent})
    tween(TabVisStroke, TMed, {Color = style.Accent})
    tween(TabSetStroke, TMed, {Color = style.Accent})

    Theme.Glass = style.Glass
    Theme.Header = style.Header
    Theme.Accent = style.Accent

    for k, ref in pairs(themeButtons) do
        ref.Set(k == key)
    end
end

local function makeThemeSelect(label, key)
    local t = makeAppleToggle(SettingsScroll, label, 0)
    t.Button.MouseButton1Click:Connect(function()
        playOptionSound()
        applyStyle(key)
        Notify("🎨 Estilo: "..label, true)
    end)
    themeButtons[key] = t
end

makeThemeSelect("🔴 Glass Red", "Red")
makeThemeSelect("🔵 Glass Blue", "Blue")
makeThemeSelect("⚫ Glass Black", "Black")
makeThemeSelect("🟣 Glass Purple", "Purple")
makeThemeSelect("🟢 Glass Green", "Green")
makeThemeSelect("🟡 Glass Gold", "Gold")

task.defer(function()
    applyStyle(currentStyleKey)
end)

--================ MINIMIZE / CLOSE =================
local minimized = false
local originalSize = Window.Size

local function setMinimized(on)
    minimized = on
    if minimized then
        playOptionSound()
        tween(Window, TMed, {Size = UDim2.new(0, 600, 0, 56)})
        task.delay(0.18, function()
            if minimized then
                Tabs.Visible = false
                Content.Visible = false
            end
        end)
    else
        playOptionSound()
        Tabs.Visible = true
        Content.Visible = true
        tween(Window, TMed, {Size = originalSize})
    end
end

BtnMin.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

BtnClose.MouseButton1Click:Connect(function()
    playOptionSound()
    tween(WStroke, TFast, {Transparency = 1})
    tween(Window, TSlow, {BackgroundTransparency = 1, Size = UDim2.new(0, 520, 0, 0)})
    task.delay(0.42, function()
        if UI then UI:Destroy() end
    end)
end)

--================ DRAG =================
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--================ WELCOME =================
Notify("✅ Glassmas UI cargada (Xeno)", true)
print("[GlassmasUI] Loaded • Xeno Ready • Sp4rk 🦈")
