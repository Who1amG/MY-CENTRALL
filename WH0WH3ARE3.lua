-- 🦈 Glassmas UI • Principal (Apple Glass Christmas) • Single Script
-- ✅ FIXED • NO "Label" VACÍO • UI COMPLETA • XENO READY
-- Made for Sp4rk 💎

--==================== SERVICES ====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local PPS = game:GetService("ProximityPromptService")
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")


local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


--==================== ANTI DUPLICATE (FIXED - CIERRA LA VIEJA) ====================
if getgenv().GlassmasUI_Running then
    pcall(function()
        if getgenv().GlassmasUI_Shutdown then
            getgenv().GlassmasUI_Shutdown()  -- cierra la vieja
        end
    end)
    task.wait(0.5)  -- espera a que se destruya
end
getgenv().GlassmasUI_Running = true

--==================== SAFE FOLDERS (NO CRASH) ====================
local ElementsFolder = RS:FindFirstChild("Elements")
local ItemsFolder = ElementsFolder and ElementsFolder:FindFirstChild("ItemsFolder")
local MappyFolder = workspace:FindFirstChild("mappy")
local BackpackShops = MappyFolder and MappyFolder:FindFirstChild("BackpackShops")

--==================== HELPERS ====================
local function getCharParts()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not (hum and hrp) then return end
	return char, hum, hrp
end
--==================== UI SPACING GLOBAL ====================
local UI_ITEM_HEIGHT = 44      -- altura exacta de tus botones buenos
local UI_ITEM_PADDING = 4      -- separación EXACTA como en la imagen

--==================== FLY (CORE SIMPLE - FIX TOTAL 2025) ====================
local FlyEnabled = false   -- estado del toggle / keybind
local FlyRunning = false  -- estado REAL (movers activos)
local FlySpeed = 110
local Fly_MIN, Fly_MAX = 90, 250
local FlyGyro, FlyVelocity
local FlyConn, FlyNoclipConn
local FlyMove = {F=0,B=0,L=0,R=0,U=0,D=0}
local RunService = game:GetService("RunService")

local function startFly()
	if FlyRunning then return end

	local char, hum, hrp = getCharParts()
	if not (char and hum and hrp) then
		Notify("❌ Character no listo para volar", false)
		return
	end

	-- ahora sí marcamos estado
	FlyRunning = true
	FlyEnabled = true

	-- estado humanoid correcto
	hum.PlatformStand = true
	hum.AutoRotate = false
	hum:ChangeState(Enum.HumanoidStateType.Physics)
	task.wait()

	-- crear movers
	FlyGyro = Instance.new("BodyGyro")
	FlyGyro.P = 9e4
	FlyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	FlyGyro.CFrame = hrp.CFrame
	FlyGyro.Parent = hrp

	FlyVelocity = Instance.new("BodyVelocity")
	FlyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
	FlyVelocity.Velocity = Vector3.zero
	FlyVelocity.Parent = hrp

	-- noclip SOLO una vez
for _,v in ipairs(char:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CanCollide = false
	end
end

	-- movimiento
	FlyConn = RunService.Heartbeat:Connect(function()
		if not FlyEnabled then return end
		local cam = workspace.CurrentCamera
		local dir =
			(cam.CFrame.LookVector * (FlyMove.F - FlyMove.B)) +
			(cam.CFrame.RightVector * (FlyMove.R - FlyMove.L)) +
			(Vector3.new(0,1,0) * (FlyMove.U - FlyMove.D))

		FlyVelocity.Velocity =
			dir.Magnitude > 0 and dir.Unit * FlySpeed or Vector3.zero

		if dir.Magnitude > 0 then
	FlyGyro.CFrame = cam.CFrame
end
	end)

	Notify("🕊️ Fly ACTIVADO", true)
end


local function stopFly()
	if not FlyEnabled then return end

	FlyEnabled = false
	FlyRunning = false

	-- limpiar movimiento
	FlyMove = {F=0,B=0,L=0,R=0,U=0,D=0}

	-- desconectar
	if FlyConn then FlyConn:Disconnect() FlyConn = nil end
	if FlyNoclipConn then FlyNoclipConn:Disconnect() FlyNoclipConn = nil end

	-- destruir movers
	if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
	if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end

	-- restaurar humanoid
	local char, hum, hrp = getCharParts()
	if hum and hrp then
		hum.PlatformStand = false
		hum.AutoRotate = true
		hrp.Anchored = false

		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait()
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end

	Notify("🕊️ Fly DESACTIVADO", false)
end


local function getESPVerticalOffset(distance)
	-- separación progresiva según distancia
	-- cerca: poco offset
	-- lejos: mucho offset
	return math.clamp(distance / 18, 0.8, 6)
end


local Camera = workspace.CurrentCamera

local function getBillboardScale(worldPos)
	local camPos = Camera.CFrame.Position
	local dist = (camPos - worldPos).Magnitude

	local REF_DIST = 25
	local scale = math.clamp(dist / REF_DIST, 0.6, 2.2)

	return scale
end


local function tpStanding(targetPart, distance)
	distance = distance or 2.2
	local _, _, hrp = getCharParts()
	if not (hrp and targetPart and targetPart:IsA("BasePart")) then return end
	local forward = targetPart.CFrame.LookVector
	local targetPos = targetPart.Position - forward * distance + Vector3.new(0, 0.5, 0)
	local cf = CFrame.new(targetPos, targetPart.Position)
	hrp.CFrame = cf
	task.wait(0.25)
end

local function tpBack(cf)
	local _, _, hrp = getCharParts()
	if not hrp then return end
	hrp.CFrame = cf
	task.wait(0.25)
end

local function playerHasTool(toolName)
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		for _,t in ipairs(backpack:GetChildren()) do
			if t:IsA("Tool") and t.Name == toolName then
				return true
			end
		end
	end
	local char = LocalPlayer.Character
	if char then
		for _,t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") and t.Name == toolName then
				return true
			end
		end
	end
	return false
end

-- restaurar colisiones
local char = LocalPlayer.Character
if char then
	for _,v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
end

--==================== UI ROOT ====================
local UI = Instance.new("ScreenGui")
UI.Name = "GlassmasUI"
UI.ResetOnSpawn = false
UI.Parent = PlayerGui

getgenv().GlassmasUI_Shutdown = function()
    getgenv().GlassmasUI_Running = false
    
    -- Apagar Fly
    if FlyEnabled then stopFly() end
	    -- 🔥 Apagar ESP refactor (si existe)
    pcall(function()
    if getgenv().GlassmasUI_ESP_Stop then
        getgenv().GlassmasUI_ESP_Stop()
    else
        -- fallback por si no existe
        clearESP()
        disableESP()
    end
end)
    
    -- Borrar ESP
    clearESP()
    disableESP()
    
    pcall(function()
        if UI then UI:Destroy() end
    end)
end

--==================== TWEENS ====================
local TFast = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TMed  = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TSlow = TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)


local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

--==================== BLUR FUNCTIONS ====================
local function blurIn()
	if GlassBlur then
		tween(GlassBlur, TSlow, {Size = 16})
	end
end

local function blurOut()
	if GlassBlur then
		tween(GlassBlur, TSlow, {Size = 0})
	end
end


--==================== SOUNDS ====================
local S_Slide = Instance.new("Sound")
S_Slide.SoundId = "rbxassetid://541909867"
S_Slide.Volume = 1
S_Slide.Parent = UI

local S_Click = Instance.new("Sound")
S_Click.SoundId = "rbxassetid://6026984224"
S_Click.Volume = 1
S_Click.Parent = UI

local function playTabSound()
	pcall(function() SoundService:PlayLocalSound(S_Slide) end)
end
local function playOptionSound()
	pcall(function() SoundService:PlayLocalSound(S_Click) end)
end

--==================== THEME & FONTS ====================
local Styles = {
	Red = {Glass=Color3.fromRGB(255,110,110), Header=Color3.fromRGB(60,15,20), Accent=Color3.fromRGB(255,90,90)},
	Blue = {Glass=Color3.fromRGB(110,170,255), Header=Color3.fromRGB(15,25,60), Accent=Color3.fromRGB(120,180,255)},
	Green = {Glass=Color3.fromRGB(110,255,170), Header=Color3.fromRGB(15,60,35), Accent=Color3.fromRGB(120,255,180)},
	Purple = {Glass=Color3.fromRGB(180,110,255), Header=Color3.fromRGB(40,20,70), Accent=Color3.fromRGB(205,150,255)},
	Gold = {Glass=Color3.fromRGB(255,210,110), Header=Color3.fromRGB(75,55,18), Accent=Color3.fromRGB(255,215,120)},
	Black = {Glass=Color3.fromRGB(18,18,18), Header=Color3.fromRGB(10,10,10), Accent=Color3.fromRGB(90,90,90)},
	BlackDark = {Glass=Color3.fromRGB(10,10,10), Header=Color3.fromRGB(6,6,6), Accent=Color3.fromRGB(60,60,60)},
}

local Fonts = {
	["Gotham"] = Enum.Font.Gotham,
	["Gotham Semi"] = Enum.Font.GothamSemibold,
	["SourceSans"] = Enum.Font.SourceSans,
	["Nunito"] = Enum.Font.Nunito,
	["Fredoka"] = Enum.Font.FredokaOne,
}

local CurrentStyle = "Black"   -- 🔥 inicia en negro
local CurrentFontName = "Fredoka"
-- color glass para logs (mismo theme, más profundo)
local function getLogsGlassColor(baseColor)
    -- mezcla con negro para hacerlo más opaco sin perder el tono
    return baseColor:Lerp(Color3.new(0, 0, 0), 0.18)
end

local Theme = {
	Glass = Styles[CurrentStyle].Glass,
	Header = Styles[CurrentStyle].Header,
	Accent = Styles[CurrentStyle].Accent,
	Text = Color3.fromRGB(245,248,255),
	Muted = Color3.fromRGB(210,220,255),
}

--==================== LOGS & NOTIFY ====================
local ActiveLogs = {}

local NotifHost = Instance.new("Frame", UI)
NotifHost.BackgroundTransparency = 1
NotifHost.Size = UDim2.new(0, 330, 1, 0)
NotifHost.Position = UDim2.new(1, -345, 0, 12)
NotifHost.ZIndex = 999

local NotifList = Instance.new("UIListLayout", NotifHost)
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, UI_ITEM_PADDING)
NotifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifList.VerticalAlignment = Enum.VerticalAlignment.Top

local function Notify(msg, good)
	local n = Instance.new("Frame")
	n.Size = UDim2.new(0, 310, 0, 56)
	n.BackgroundColor3 = Theme.Glass
	n.BackgroundTransparency = 0.10
	n.BorderSizePixel = 0
	n.Parent = NotifHost
	n.ZIndex = 999
	Instance.new("UICorner", n).CornerRadius = UDim.new(0, 16)

	local s = Instance.new("UIStroke", n)
	s.Thickness = 1
	s.Transparency = 0.50
	s.Color = good and Color3.fromRGB(120,255,180) or Color3.fromRGB(255,95,90)

	local t = Instance.new("TextLabel", n)
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, 12, 0, 0)
	t.Size = UDim2.new(1, -24, 1, 0)
	t.Font = Fonts[CurrentFontName]
	t.TextSize = 14
	t.TextColor3 = Theme.Text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = msg
	t.ZIndex = 999

	n.Position = UDim2.new(0, 24, 0, 0)
	tween(n, TFast, {Position = UDim2.new(0, 0, 0, 0)})

	task.delay(2.1, function()
		if not n.Parent then return end
		tween(n, TFast, {Position = UDim2.new(0, 24, 0, 0), BackgroundTransparency = 1})
		tween(s, TFast, {Transparency = 1})
		task.delay(0.22, function()
			if n then n:Destroy() end
		end)
	end)
end

local LogsUI_List -- se asigna cuando exista
local function AddLog(text)
	table.insert(ActiveLogs, {text=text, time=os.clock(), ui=nil})
	if LogsUI_List then
		local item = Instance.new("TextLabel")
		item.Parent = LogsUI_List
		item.BackgroundTransparency = 1
		item.Font = Fonts[CurrentFontName]
		item.TextSize = 13
		item.TextColor3 = Theme.Muted
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextWrapped = true
		item.Size = UDim2.new(1, 0, 0, 18)
		item.Text = "• "..text
		item.Size = UDim2.new(1, 0, 0, item.TextBounds.Y + 2)
		ActiveLogs[#ActiveLogs].ui = item

		task.delay(12, function()
			if item and item.Parent then item:Destroy() end
		end)
	end
end

--==================== WINDOW ====================
local Window = Instance.new("Frame", UI)
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.new(0,560,0,360)
Window.BackgroundColor3 = Theme.Glass
Window.BackgroundTransparency = 0.80
Window.BorderSizePixel = 0
Window.Active = true
Window.Selectable = true
Window.ZIndex = 10
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 22)

local WStroke = Instance.new("UIStroke", Window)
WStroke.Color = Theme.Accent
WStroke.Thickness = 1.5
WStroke.Transparency = 0.45

--==================== BLUR iOS ====================
local Lighting = game:GetService("Lighting")

local GlassBlur = Instance.new("BlurEffect")
GlassBlur.Name = "GlassmasBlur"
GlassBlur.Size = 0
GlassBlur.Parent = Lighting


--==================== HEADER ====================
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Theme.Header
Header.BackgroundTransparency = 0.25
Header.BorderSizePixel = 0
Header.Active = true
Header.ZIndex = 20
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 22)

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 78, 0, 0)
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Font = Fonts[CurrentFontName]
Title.TextSize = 18
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Who We Are😈"
Title.ZIndex = 21

local function makeDot(color, x)
	local b = Instance.new("TextButton", Header)
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = UDim2.new(0, 14, 0, 14)
	b.Position = UDim2.new(0, x, 0.5, -7)
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.ZIndex = 22
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	return b
end

local BtnClose = makeDot(Color3.fromRGB(255, 95, 90), 16)
local BtnMin   = makeDot(Color3.fromRGB(255, 200, 80), 40)

--==================== SNOW LAYER ====================
local SnowLayer = Instance.new("Frame", Window)
SnowLayer.Name = "SnowLayer"
SnowLayer.BackgroundTransparency = 1
SnowLayer.Size = UDim2.new(1, 0, 1, 0)
SnowLayer.Active = false
SnowLayer.Selectable = false
SnowLayer.ZIndex = 50
SnowLayer.ClipsDescendants = true

local SnowEnabled = true
local snowThreadId = 0

local function clearSnow()
	for _,c in ipairs(SnowLayer:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
end

local function spawnSnowflake()
	local flake = Instance.new("Frame")
	flake.Parent = SnowLayer
	flake.BorderSizePixel = 0
	flake.Active = false
	flake.Selectable = false
	flake.ZIndex = 51

	local sz = math.random(3, 5)
	flake.Size = UDim2.new(0, sz, 0, sz)
	flake.Position = UDim2.new(math.random(), 0, -0.08, 0)
	flake.BackgroundColor3 = Color3.fromRGB(255,255,255)
	flake.BackgroundTransparency = math.random(25, 55)/100
	Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)

	local drift = math.random(-45, 45)
	local tFall = math.random(60, 95)/10
	tween(flake, TweenInfo.new(tFall, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Position = UDim2.new(flake.Position.X.Scale, drift, 1.12, 0)
	})
	task.delay(tFall, function()
		if flake and flake.Parent then flake:Destroy() end
	end)
end

local function snowLoop()
	snowThreadId += 1
	local myId = snowThreadId
	task.spawn(function()
		while UI.Parent and getgenv().GlassmasUI_Running and myId == snowThreadId do
			task.wait(0.28)
			if SnowEnabled and Window.Visible then
				spawnSnowflake()
			end
		end
	end)
end
snowLoop()

--==================== TABS ====================
local TabsBar = Instance.new("Frame", Window)
TabsBar.BackgroundTransparency = 1
TabsBar.Position = UDim2.new(0, 12, 0, 62)
TabsBar.Size = UDim2.new(1, -24, 0, 44)
TabsBar.Active = false
TabsBar.ZIndex = 30

local TabsLayout = Instance.new("UIListLayout", TabsBar)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 10)
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeTabButton(txt)
	local b = Instance.new("TextButton", TabsBar)
	b.AutoButtonColor = false
	b.Text = txt
	b.Font = Fonts[CurrentFontName]
	b.TextSize = 14
	b.TextColor3 = Theme.Text
	b.BackgroundColor3 = Color3.fromRGB(255,255,255)
	b.BackgroundTransparency = 0.90
	b.BorderSizePixel = 0
	b.Size = UDim2.new(0, 124, 0, 40)
	b.ZIndex = 31
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)

	local st = Instance.new("UIStroke", b)
	st.Transparency = 0.75
	st.Color = Theme.Accent
	st.Thickness = 1

	return b, st
end

local TabAuto,    TabAutoStroke = makeTabButton("🏠 Auto")
local TabVisual,  TabVisualStroke = makeTabButton("👁 Visual")
local TabSettings,TabSetStroke = makeTabButton("⚙️ Settings")
local TabMisc,    TabMiscStroke = makeTabButton("🧩 Misc")

TabAuto.LayoutOrder = 1
TabVisual.LayoutOrder = 2
TabMisc.LayoutOrder = 3
TabSettings.LayoutOrder = 4


--==================== CONTENT ====================
local Content = Instance.new("Frame", Window)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 12, 0, 112)
Content.Size = UDim2.new(1, -24, 1, -124)
Content.ClipsDescendants = true
Content.Active = false
Content.ZIndex = 30

local function newPageFrame()
	local p = Instance.new("Frame", Content)
	p.BackgroundTransparency = 1
	p.Size = UDim2.new(1, 0, 1, 0)
	p.Visible = false
	p.Active = false
	p.ZIndex = 30
	return p
end

local PageAuto = newPageFrame()

local PageVisual = Instance.new("ScrollingFrame", Content)
PageVisual.BackgroundTransparency = 1
PageVisual.Size = UDim2.new(1, 0, 1, -6)
PageVisual.CanvasSize = UDim2.new(0, 0, 0, 0)
PageVisual.ScrollBarThickness = 4
PageVisual.ScrollBarImageColor3 = Theme.Accent
PageVisual.Visible = false
PageVisual.ZIndex = 30
PageVisual.Active = true
PageVisual:SetAttribute("NoDrag", true)
PageVisual.BorderSizePixel = 0
PageVisual.ScrollBarImageTransparency = 0


local PageSettings = newPageFrame()

local PageMisc = Instance.new("ScrollingFrame", Content)
PageMisc.BackgroundTransparency = 1
PageMisc.Size = UDim2.new(1, 0, 1, -6)
PageMisc.CanvasSize = UDim2.new(0, 0, 0, 0)
PageMisc.ScrollBarThickness = 4
PageMisc.ScrollBarImageColor3 = Theme.Accent
PageMisc.Visible = false
PageMisc.ZIndex = 30
PageMisc.Active = true
PageMisc:SetAttribute("NoDrag", true)
PageMisc.BorderSizePixel = 0
PageMisc.ScrollBarImageTransparency = 0

--==================== VISUAL CONTENT ====================
local VisualContent = Instance.new("Frame", PageVisual)
VisualContent.BackgroundTransparency = 1
VisualContent.Size = UDim2.new(1, 0, 1, 0)

local VisualLeft = Instance.new("Frame", VisualContent)
VisualLeft.BackgroundTransparency = 1
VisualLeft.Size = UDim2.new(0.5, -6, 1, 0)
VisualLeft.Position = UDim2.new(0, 0, 0, 0)
VisualLeft.ClipsDescendants = true -- 🔑 FIX REAL


local VisualRight = Instance.new("Frame", VisualContent)
VisualRight.BackgroundTransparency = 1
VisualRight.Size = UDim2.new(0.5, -6, 1, 0)
VisualRight.Position = UDim2.new(0.5, 6, 0, 0)

local VisualLeftList = Instance.new("UIListLayout", VisualLeft)
VisualLeftList.Padding = UDim.new(0, UI_ITEM_PADDING)
VisualLeftList.SortOrder = Enum.SortOrder.LayoutOrder

local VisualRightList = Instance.new("UIListLayout", VisualRight)
VisualRightList.Padding = UDim.new(0, UI_ITEM_PADDING)
VisualRightList.SortOrder = Enum.SortOrder.LayoutOrder

local function updateVisualCanvas()
	local h = math.max(
		VisualLeftList.AbsoluteContentSize.Y,
		VisualRightList.AbsoluteContentSize.Y
	)
	PageVisual.CanvasSize = UDim2.new(0, 0, 0, h + 20)
end

VisualLeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateVisualCanvas)
VisualRightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateVisualCanvas)
task.defer(updateVisualCanvas)

--==================== MISC CONTENT ====================
local MiscContent = Instance.new("Frame", PageMisc)
MiscContent.BackgroundTransparency = 1
MiscContent.Size = UDim2.new(1, 0, 1, 0)

local MiscLeft = Instance.new("Frame", MiscContent)
MiscLeft.BackgroundTransparency = 1
MiscLeft.Size = UDim2.new(0.5, -6, 1, 0)
MiscLeft.Position = UDim2.new(0, 0, 0, 0)
MiscLeft.ClipsDescendants = true


local MiscRight = Instance.new("Frame", MiscContent)
MiscRight.BackgroundTransparency = 1
MiscRight.Size = UDim2.new(0.5, -6, 1, 0)
MiscRight.Position = UDim2.new(0.5, 6, 0, 0)
MiscRight.ClipsDescendants = true


local MiscLeftList = Instance.new("UIListLayout", MiscLeft)
MiscLeftList.Padding = UDim.new(0, UI_ITEM_PADDING)
MiscLeftList.SortOrder = Enum.SortOrder.LayoutOrder

local MiscRightList = Instance.new("UIListLayout", MiscRight)
MiscRightList.Padding = UDim.new(0, UI_ITEM_PADDING)
MiscRightList.SortOrder = Enum.SortOrder.LayoutOrder


local function updateMiscCanvas()
	local h = math.max(
		MiscLeftList.AbsoluteContentSize.Y,
		MiscRightList.AbsoluteContentSize.Y
	)
	PageMisc.CanvasSize = UDim2.new(0, 0, 0, h + 80)

end

MiscLeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMiscCanvas)
MiscRightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMiscCanvas)

task.defer(updateMiscCanvas)

--==================== LOG PANEL (VISUAL) ====================
local LogsContainer = Instance.new("Frame", VisualLeft)
LogsContainer.Name = "LogsContainer"
LogsContainer.Size = UDim2.new(1, 0, 0, 170)
LogsContainer.BackgroundColor3 = getLogsGlassColor(Theme.Glass)
LogsContainer.BackgroundTransparency = 0.78
LogsContainer.BorderSizePixel = 0
LogsContainer.ZIndex = 35
LogsContainer.LayoutOrder = 0
LogsContainer.ClipsDescendants = true -- 🔑 IMPIDE QUE SE SALGAN
LogsContainer:SetAttribute("NoDrag", true)
Instance.new("UICorner", LogsContainer).CornerRadius = UDim.new(0, 16)

local LogsStroke = Instance.new("UIStroke", LogsContainer)
LogsStroke.Color = Theme.Accent
LogsStroke.Transparency = 0.6
LogsStroke.Thickness = 1

local LogsTitle = Instance.new("TextLabel", LogsContainer)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Size = UDim2.new(1, -12, 0, 24)
LogsTitle.Position = UDim2.new(0, 6, 0, 6)
LogsTitle.Font = Fonts[CurrentFontName]
LogsTitle.TextSize = 14
LogsTitle.TextColor3 = Theme.Text
LogsTitle.TextXAlignment = Enum.TextXAlignment.Left
LogsTitle.Text = "📜 Logs"
LogsTitle.ZIndex = 36
LogsTitle:SetAttribute("NoDrag", true)

local LogsList = Instance.new("ScrollingFrame", LogsContainer)
LogsList.BackgroundTransparency = 1
LogsList.Position = UDim2.new(0, 6, 0, 36)
LogsList.Size = UDim2.new(1, -12, 1, -48)
LogsList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsList.ScrollBarThickness = 4
LogsList.ScrollBarImageColor3 = Theme.Accent
LogsList.ZIndex = 36
LogsList.Active = true
LogsList:SetAttribute("NoDrag", true)

local LogsLayout = Instance.new("UIListLayout", LogsList)
LogsLayout.Padding = UDim.new(0, 6)
LogsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
LogsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 🔄 ajustar canvas automáticamente
local function updateLogsCanvas()
	LogsList.CanvasSize = UDim2.new(
		0, 0,
		0, LogsLayout.AbsoluteContentSize.Y + 6
	)
end

LogsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLogsCanvas)
task.defer(updateLogsCanvas)

LogsUI_List = LogsList

--==================== DRAG ANYWHERE (XENO SAFE) ====================


local Drag = {pending=false, active=false, startPos=nil, startMouse=nil, threshold=6}
local SliderDragging = false

local function beginDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	-- ❌ si un slider está siendo arrastrado, NO mover UI
	if SliderDragging then
		return
	end

	-- si está minimizado, SOLO drag desde header
	if minimized then
		if not input.Target:IsDescendantOf(Header) then
			return
		end
	end

	Drag.pending = true
	Drag.active = false
	Drag.startMouse = input.Position
	Drag.startPos = Window.Position
end

local function endDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	task.delay(0.05, function()
		Drag.pending = false
		Drag.active = false
	end)
end

local function shouldIgnoreClick()
	-- ❌ si realmente estabas arrastrando, ignorar click
	if Drag.active then
		return true
	end
	return false
end


-- drag desde Window
Window.InputBegan:Connect(beginDrag)
Window.InputEnded:Connect(endDrag)

-- drag desde TODOS los hijos (como el script bueno)
for _,obj in ipairs(Window:GetDescendants()) do
	if obj:IsA("Frame") or obj:IsA("TextLabel") then
		obj.InputBegan:Connect(beginDrag)
		obj.InputEnded:Connect(endDrag)
	end
end

-- 🔑 FIX DEFINITIVO: liberar drag aunque sueltes sobre botones
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Drag.pending = false
		Drag.active = false
	end
end)


UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	if not Drag.pending then return end

	local delta = input.Position - Drag.startMouse
	if not Drag.active then
		if math.abs(delta.X) >= Drag.threshold or math.abs(delta.Y) >= Drag.threshold then
			Drag.active = true
		else
			return
		end
	end

	Window.Position = UDim2.new(
		Drag.startPos.X.Scale,
		Drag.startPos.X.Offset + delta.X,
		Drag.startPos.Y.Scale,
		Drag.startPos.Y.Offset + delta.Y
	)
end)


--==================== TAB SWITCH ====================
local PageAutoKey, PageVisualKey, PageSettingsKey, PageMiscKey = "auto","visual","settings","misc"
local CurrentPage = PageAuto
PageAuto.Visible = true

local switching = false

local function setTabActive(which)
	local function style(btn, st, active)
		tween(btn, TFast, {BackgroundTransparency = active and 0.82 or 0.90})
		tween(st, TFast, {Transparency = active and 0.40 or 0.80})
	end
	style(TabAuto, TabAutoStroke, which==PageAutoKey)
	style(TabVisual, TabVisualStroke, which==PageVisualKey)
	style(TabSettings, TabSetStroke, which==PageSettingsKey)
	style(TabMisc, TabMiscStroke, which==PageMiscKey)
end

setTabActive(PageAutoKey)

local function redrawLogs()
	-- limpia
	for _,c in ipairs(LogsList:GetChildren()) do
		if c:IsA("TextLabel") then c:Destroy() end
	end
	-- redibuja
	for _,log in ipairs(ActiveLogs) do
		local item = Instance.new("TextLabel")
		item.Parent = LogsList
		item.BackgroundTransparency = 1
		item.Font = Fonts[CurrentFontName]
		item.TextSize = 13
		item.TextColor3 = Theme.Muted
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextWrapped = true
		item.Size = UDim2.new(1,0,0,18)
		item.Text = "• "..tostring(log.text)
		item.Size = UDim2.new(1,0,0,item.TextBounds.Y + 2)
		log.ui = item
	end
end

local function switchPage(target, which)
	if switching or target == CurrentPage then return end
	switching = true
	playTabSound()

	-- 🔒 desactivar input de la página actual
	if CurrentPage:IsA("ScrollingFrame") then
		CurrentPage.Active = false
	else
		for _,c in ipairs(CurrentPage:GetChildren()) do
			if c:IsA("ScrollingFrame") then
				c.Active = false
			end
		end
	end

	CurrentPage.Visible = false

	-- preparar nueva página
	target.Position = UDim2.new(0.06, 0, 0, 0)
	target.Visible = true

	-- 🔓 activar input SOLO de la página nueva
	if target:IsA("ScrollingFrame") then
		target.Active = true
	else
		for _,c in ipairs(target:GetChildren()) do
			if c:IsA("ScrollingFrame") then
				c.Active = true
			end
		end
	end

	tween(target, TMed, {Position = UDim2.new(0, 0, 0, 0)})

	CurrentPage = target
	setTabActive(which)

	if which == PageVisualKey then
		redrawLogs()
	end

	task.delay(0.22, function()
		switching = false
	end)
end


TabAuto.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageAuto, PageAutoKey)
end)

TabVisual.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageVisual, PageVisualKey)
end)

TabSettings.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageSettings, PageSettingsKey)
end)

TabMisc.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageMisc, PageMiscKey)
end)

--==================== UI COMPONENTS ====================
local function makeAppleToggle(parent, label, order, onChanged)
	local state = false

	local b = Instance.new("TextButton", parent)
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = UDim2.new(1, 0, 0, 44)
	b.LayoutOrder = order or 0
	b.BackgroundColor3 = Color3.fromRGB(255,255,255)
	b.BackgroundTransparency = 0.88
	b.BorderSizePixel = 0
	b.ZIndex = 40
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)

	local st = Instance.new("UIStroke", b)
	st.Thickness = 1
	st.Color = Theme.Accent
	st.Transparency = 0.80

	local t = Instance.new("TextLabel", b)
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -16, 1, 0)
	t.Position = UDim2.new(0, 12, 0, 0)
	t.Font = Fonts[CurrentFontName]
	t.TextSize = 14
	t.TextColor3 = Theme.Text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 41

	local function render()
		t.Text = ("%s: %s"):format(label, state and "ON" or "OFF")
		tween(st, TFast, {Transparency = state and 0.35 or 0.80})
		tween(b, TFast, {BackgroundTransparency = state and 0.82 or 0.88})
	end

	render()

	b.MouseButton1Click:Connect(function()
		if shouldIgnoreClick() then return end
		state = not state
		playOptionSound()
		render()
		Notify(label .. (state and " activado" or " desactivado"), state)
		if onChanged then onChanged(state) end
	end)

	return {
		Set = function(v) state = not not v; render() end,
		Get = function() return state end,
		Button = b,
	}
end

local function makeAppleAction(parent, text, order, onClick)
	local b = Instance.new("TextButton", parent)
	b.AutoButtonColor = false
	b.Size = UDim2.new(1, 0, 0, 44)
	b.LayoutOrder = order or 0
	b.BackgroundColor3 = Color3.fromRGB(255,255,255)
	b.BackgroundTransparency = 0.88
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Fonts[CurrentFontName]
	b.TextSize = 14
	b.TextColor3 = Theme.Text
	b.ZIndex = 41
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)

	local st = Instance.new("UIStroke", b)
	st.Thickness = 1
	st.Color = Theme.Accent
	st.Transparency = 0.75

	b.MouseButton1Click:Connect(function()
		if shouldIgnoreClick() then return end
		playOptionSound()
		if onClick then onClick() end
	end)

	return b
end

local function makeDropdownHeaderDynamic(parent, titleText)
	local headerBtn = Instance.new("TextButton", parent)
	headerBtn.AutoButtonColor = false
	headerBtn.Size = UDim2.new(1, 0, 0, 44)
	headerBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	headerBtn.BackgroundTransparency = 0.88
	headerBtn.BorderSizePixel = 0
	headerBtn.Text = titleText .. " ▸"
	headerBtn.Font = Fonts[CurrentFontName]
	headerBtn.TextSize = 14
	headerBtn.TextColor3 = Theme.Text
	headerBtn.ZIndex = 41
	Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 14)

	local st = Instance.new("UIStroke", headerBtn)
	st.Thickness = 1
	st.Color = Theme.Accent
	st.Transparency = 0.80

	local container = Instance.new("Frame", parent)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.Size = UDim2.new(1, 0, 0, 0)
	container.ZIndex = 41

	local list = Instance.new("UIListLayout", container)
	list.Padding = UDim.new(0, UI_ITEM_PADDING)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local open = false

	local function refreshSize(animated)
		local h = list.AbsoluteContentSize.Y + 6
		local target = open
	and UDim2.new(1, 0, 0, h)
	or UDim2.new(1, 0, 0, 0)
		if animated then tween(container, TMed, {Size = target}) else container.Size = target end
	end

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if open then refreshSize(false) end
	end)

	headerBtn.MouseButton1Click:Connect(function()
		if shouldIgnoreClick() then return end
		open = not open
		playOptionSound()
		headerBtn.Text = titleText .. (open and " ▾" or " ▸")
		refreshSize(true)
	end)

	return headerBtn, container, list
end

--==================== APPLE CLEANING SCREEN ====================
local function showCleaningScreen(duration)
	local gui = Instance.new("ScreenGui")
	gui.Name = "MoneyCleaningScreen"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = PlayerGui

	local bg = Instance.new("Frame", gui)
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = Color3.new(0,0,0)
	bg.BackgroundTransparency = 1
	bg.ZIndex = 1000

	local text = Instance.new("TextLabel", bg)
	text.AnchorPoint = Vector2.new(0.5,0.5)
	text.Position = UDim2.new(0.5,0,0.5,0)
	text.Size = UDim2.new(0,520,0,80)
	text.BackgroundTransparency = 1
	text.TextWrapped = true
	text.Text = "🧼 LIMPIANDO DINERO\n⏳ ESPERA 30 SEGUNDOS"
	text.Font = Fonts[CurrentFontName]
	text.TextSize = 26
	text.TextColor3 = Color3.fromRGB(240,240,240)
	text.TextTransparency = 1
	text.ZIndex = 1001

	-- fade in
	TweenService:Create(bg, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0.01
	}):Play()

	TweenService:Create(text, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
		TextTransparency = 0
	}):Play()

	-- animación flotante estilo Apple
	task.spawn(function()
		while gui.Parent do
			TweenService:Create(text, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0.5,0,0.5,-6)
			}):Play()
			task.wait(1.8)
			TweenService:Create(text, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0.5,0,0.5,6)
			}):Play()
			task.wait(1.8)
		end
	end)

	-- cerrar automático
	task.delay(duration, function()
		if gui.Parent then
			TweenService:Create(bg, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(text, TweenInfo.new(0.5), {
				TextTransparency = 1
			}):Play()
			task.wait(0.6)
			gui:Destroy()
		end
	end)
end


--==================== TOOLTIP (HOVER INFO) ====================
local function attachTooltip(button, text)
	local tip = Instance.new("TextLabel", UI)
	tip.BackgroundColor3 = Color3.fromRGB(20,20,20)
	tip.BackgroundTransparency = 0.12
	tip.BorderSizePixel = 0
	tip.TextWrapped = true
	tip.TextXAlignment = Enum.TextXAlignment.Left
	tip.TextYAlignment = Enum.TextYAlignment.Top
	tip.Font = Fonts[CurrentFontName]
	tip.TextSize = 13
	tip.TextColor3 = Color3.fromRGB(245,245,245)
	tip.Text = text
	tip.Visible = false
	tip.ZIndex = 999
	tip.Size = UDim2.new(0, 280, 0, 58)
	Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 10)

	button.MouseEnter:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		tip.Position = UDim2.fromOffset(pos.X + 14, pos.Y + 14)
		tip.Visible = true
	end)

	button.MouseLeave:Connect(function()
		tip.Visible = false
	end)

	UserInputService.InputChanged:Connect(function(i)
		if tip.Visible and i.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = UserInputService:GetMouseLocation()
			tip.Position = UDim2.fromOffset(pos.X + 14, pos.Y + 14)
		end
	end)
end


--==================== PAGE AUTO (placeholder limpio) ====================
do
	local hint = Instance.new("TextLabel", PageAuto)
	hint.BackgroundTransparency = 1
	hint.Size = UDim2.new(1, -20, 0, 26)
	hint.Position = UDim2.new(0, 10, 0, 10)
	hint.Font = Fonts[CurrentFontName]
	hint.TextSize = 14
	hint.TextColor3 = Theme.Muted
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.Text = "🏠 Auto listo. (Aquí metemos tus autos/farm si quieres)"
end

--==================== VISUAL: ESP (REFACTOR ULTRA LIGERO) ====================
local ESPEnabled = false
local ESPItemsEnabled = false
local ESPTextSize = 14
local ESPColor = Color3.fromRGB(255, 80, 80)

-- Cache interno (no toca UI / no cambia opciones)
local ESP = {
    Players = {},   -- [userId] = BillboardGui
    Items = {},     -- [userId] = BillboardGui
    Conns = {},     -- conexiones para cleanup
    Running = true,
}

local function espIsAlive()
    return UI and UI.Parent and getgenv().GlassmasUI_Running and ESP.Running
end

-- === REFRESH (sin scans PlayerGui) ===
local function refreshESPFont()
    for _, gui in pairs(ESP.Players) do
        local label = gui and gui:FindFirstChild("ESPNameLabel", true)
        if label and label:IsA("TextLabel") then
            label.Font = Fonts[CurrentFontName]
        end
    end
    for _, gui in pairs(ESP.Items) do
        local label = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
        if label and label:IsA("TextLabel") then
            label.Font = Fonts[CurrentFontName]
        end
    end
end

local function applyESPTextSize()
    for _, gui in pairs(ESP.Players) do
        local lbl = gui and gui:FindFirstChild("ESPNameLabel", true)
        if lbl and lbl:IsA("TextLabel") then
            lbl.TextSize = ESPTextSize
        end
    end
    for _, gui in pairs(ESP.Items) do
        local lbl = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl:IsA("TextLabel") then
            lbl.TextSize = math.clamp(ESPTextSize - 2, 10, 20)
        end
    end
end

local function applyESPColor()
    for _, gui in pairs(ESP.Players) do
        local lbl = gui and gui:FindFirstChild("ESPNameLabel", true)
        if lbl and lbl:IsA("TextLabel") then
            lbl.TextColor3 = ESPColor
        end
    end
    for _, gui in pairs(ESP.Items) do
        local lbl = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl:IsA("TextLabel") then
            lbl.TextColor3 = ESPColor
        end
    end
end

-- === Destroy helpers ===
local function destroyPlayerESP(userId)
    local gui = ESP.Players[userId]
    if gui then
        ESP.Players[userId] = nil
        pcall(function() gui:Destroy() end)
    end
end

local function destroyItemsESP(userId)
    local gui = ESP.Items[userId]
    if gui then
        ESP.Items[userId] = nil
        pcall(function() gui:Destroy() end)
    end
end

-- Mantengo tus APIs para que NO rompa nada (close/shutdown)
local function clearESP()
    for userId, _ in pairs(ESP.Players) do
        destroyPlayerESP(userId)
    end
    for userId, _ in pairs(ESP.Items) do
        destroyItemsESP(userId)
    end
end

local function removePlayerESP(player)
    if not player then return end
    destroyPlayerESP(player.UserId)
    destroyItemsESP(player.UserId)
end

-- === Create player ESP ===
local function createESP(player)
    if not espIsAlive() then return end
    if not ESPEnabled then return end
    if not player or player == LocalPlayer then return end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    -- si existe, no recrear
    if ESP.Players[player.UserId] and ESP.Players[player.UserId].Parent then return end
    destroyPlayerESP(player.UserId)

    local bill = Instance.new("BillboardGui")
    bill.Name = "GlassmasESP_" .. player.UserId
    bill.Adornee = hrp
    bill.Size = UDim2.fromOffset(120, 34)
    bill.AlwaysOnTop = true
    bill.Parent = PlayerGui
    bill:SetAttribute("GlassmasESP", true)

    local name = Instance.new("TextLabel", bill)
    name.Name = "ESPNameLabel"
    name.BackgroundTransparency = 1
    name.Size = UDim2.new(1, 0, 1, 0)
    name.Font = Fonts[CurrentFontName]
    name.TextSize = ESPTextSize
    name.TextColor3 = ESPColor
    name.TextStrokeTransparency = 0
    name.Text = player.Name
    name.TextScaled = false

    ESP.Players[player.UserId] = bill
end

-- === Items ESP (tool equipado) ===
local function updatePlayerItemsESP(player)
    if not espIsAlive() then return end
    if not ESPItemsEnabled then return end
    if not player or player == LocalPlayer then return end

    local char = player.Character
    if not char then
        destroyItemsESP(player.UserId)
        return
    end

    local leftFoot = char:FindFirstChild("LeftFoot")
    if not (leftFoot and leftFoot:IsA("BasePart")) then
        destroyItemsESP(player.UserId)
        return
    end

    -- SOLO TOOL EQUIPADO
    local equippedTool
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            equippedTool = obj
            break
        end
    end

    if not equippedTool then
        destroyItemsESP(player.UserId)
        return
    end

    local gui = ESP.Items[player.UserId]
    if not (gui and gui.Parent) then
        destroyItemsESP(player.UserId)

        local bill = Instance.new("BillboardGui")
        bill.Name = "GlassmasItemsESP_" .. player.UserId
        bill.Adornee = leftFoot
        bill.Size = UDim2.fromOffset(160, 26)
        bill.AlwaysOnTop = true
        bill.Parent = PlayerGui

        local text = Instance.new("TextLabel", bill)
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Font = Fonts[CurrentFontName]
        text.TextSize = math.clamp(ESPTextSize - 2, 10, 20)
        text.TextColor3 = ESPColor
        text.Text = "🖐 " .. equippedTool.Name

        ESP.Items[player.UserId] = bill
        gui = bill
    end

    -- update texto si cambió
    local lbl = gui:FindFirstChildWhichIsA("TextLabel", true)
    if lbl then
        local newText = "🖐 " .. equippedTool.Name
        if lbl.Text ~= newText then
            lbl.Text = newText
        end
        lbl.TextSize = math.clamp(ESPTextSize - 2, 10, 20)
        lbl.TextColor3 = ESPColor
        lbl.Font = Fonts[CurrentFontName]
    end

    -- si el Adornee cambió
    if gui.Adornee ~= leftFoot then
        gui.Adornee = leftFoot
    end
end

local function disableESP()
    ESPEnabled = false
    -- borrar SOLO Player ESP
    for userId, gui in pairs(ESP.Players) do
        if gui then
            destroyPlayerESP(userId)
        end
    end
end

local function enableESP()
    -- crear ESP para los players existentes (sin scans)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createESP(plr)
        end
    end
end

-- === Respawn hook (sin loops raros) ===
local function hookCharacter(player)
    if ESP.Conns["char_" .. player.UserId] then
        ESP.Conns["char_" .. player.UserId]:Disconnect()
        ESP.Conns["char_" .. player.UserId] = nil
    end

    ESP.Conns["char_" .. player.UserId] = player.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 6)
        local hum = char:WaitForChild("Humanoid", 6)
        if not (hrp and hum) then return end

        task.wait(0.25)

        if ESPEnabled then
            removePlayerESP(player)
            createESP(player)
            AddLog("🔄 ESP respawn: " .. player.Name)
        else
            removePlayerESP(player)
        end
    end)
end

-- jugadores que YA están
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        hookCharacter(plr)
    end
end

-- jugadores que ENTRAN después
ESP.Conns.PlayerAdded = Players.PlayerAdded:Connect(function(plr)
    if plr == LocalPlayer then return end
    hookCharacter(plr)

    if ESPEnabled then
        task.wait(0.25)
        createESP(plr)
        AddLog("➕ SE UNIO: " .. plr.Name)
    end
end)

ESP.Conns.PlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
    removePlayerESP(plr)
end)

-- IZQUIERDA (MISMO TOGGLE / MISMA OPCIÓN)
makeAppleToggle(VisualLeft, "👁 Player ESP", 1, function(on)
    ESPEnabled = on
    AddLog(on and "ESP ACTIVADO" or "ESP DESACTIVADO")
    if on then enableESP() else disableESP() end
end)

makeAppleToggle(VisualLeft, "🔍 Mostrar objetos del jugador", 2, function(on)
    ESPItemsEnabled = on
    AddLog(on and "ItemsESP ON" or "ItemsESP OFF")

    if not on then
        -- borrar items sin tocar player esp
        for userId, _ in pairs(ESP.Items) do
            destroyItemsESP(userId)
        end
    end
end)

-- DERECHA (MISMO HEADER / MISMO CONTENIDO)
local ESPHeader, ESPContainer = makeDropdownHeaderDynamic(
    VisualRight,
    "⚙️ Ajustes de ESP"
)
ESPHeader.LayoutOrder = 1
ESPContainer.LayoutOrder = 2

-- tamaño del texto ESP (SLIDER) - MISMA UX
do
    local SliderFrame = Instance.new("Frame", ESPContainer)
    SliderFrame.Size = UDim2.new(1, 0, 0, UI_ITEM_HEIGHT + 12)
    SliderFrame:SetAttribute("NoDrag", true)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.ZIndex = 41

    local Title = Instance.new("TextLabel", SliderFrame)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.Font = Fonts[CurrentFontName]
    Title.TextSize = 14
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = "🔠 Tamaño del texto ESP"

    local BarBack = Instance.new("Frame", SliderFrame)
    BarBack.Position = UDim2.new(0, 0, 0, 32)
    BarBack.Size = UDim2.new(1, 0, 0, 10)
    BarBack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BarBack.BackgroundTransparency = 0.65
    BarBack.BorderSizePixel = 0
    Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBack)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.Accent
    BarFill.BorderSizePixel = 0
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", BarBack)
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, -9, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 42
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local MIN, MAX = 10, 22

    local function setFromX(x)
        local pct = math.clamp(
            (x - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X,
            0, 1
        )

        ESPTextSize = math.floor(MIN + (MAX - MIN) * pct)
        applyESPTextSize()

        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, -9, 0.5, -9)
    end

    BarBack.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		SliderDragging = true
		Drag.pending = false
		setFromX(i.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		SliderDragging = false
	end
end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(i.Position.X)
        end
    end)

    SliderFrame:SetAttribute("NoDrag", true)
    BarBack:SetAttribute("NoDrag", true)
    BarFill:SetAttribute("NoDrag", true)
    Knob:SetAttribute("NoDrag", true)

    task.defer(function()
        local pct = (ESPTextSize - MIN) / (MAX - MIN)
        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, -9, 0.5, -9)
    end)
end

-- 🎨 COLOR DEL ESP (VERSIÓN SEGURA – SIN RULETA)
do
	local colorBtn = Instance.new("TextButton", ESPContainer)
	colorBtn.Size = UDim2.new(1, 0, 0, 44)
	colorBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	colorBtn.BackgroundTransparency = 0.88
	colorBtn.BorderSizePixel = 0
	colorBtn.Text = "🎨 Color del ESP"
	colorBtn.Font = Fonts[CurrentFontName]
	colorBtn.TextSize = 14
	colorBtn.TextColor3 = Theme.Text
	colorBtn.ZIndex = 41
	colorBtn.AutoButtonColor = false
	colorBtn:SetAttribute("NoDrag", true)
	Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 14)

	-- ⬛ preview SOLO visual
	local preview = Instance.new("Frame", colorBtn)
	preview.Size = UDim2.new(0, 26, 0, 26)
	preview.Position = UDim2.new(1, -34, 0.5, -13)
	preview.BackgroundColor3 = ESPColor
	preview.BorderSizePixel = 0
	preview.ZIndex = 42
	preview:SetAttribute("NoDrag", true)
	Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

	colorBtn.MouseButton1Click:Connect(function()
		if shouldIgnoreClick() then return end
		playOptionSound()
		Notify("🎨 Selector de color desactivado (próxima versión)", false)
	end)
end


-- === Loops ultra ligeros (sin scans / sin destruir y recrear sin motivo) ===
-- 1) offsets + sanity de player esp (0.25s)
ESP.Conns.ESP_LoopA = task.spawn(function()
    while espIsAlive() do
        if ESPEnabled then
            for userId, gui in pairs(ESP.Players) do
                if gui and gui.Parent and gui.Adornee and gui.Adornee:IsA("BasePart") then
                    local adornee = gui.Adornee
                    local dist = (Camera.CFrame.Position - adornee.Position).Magnitude
                    local sep = getESPVerticalOffset(dist)
                    gui.StudsOffset = Vector3.new(0, 3 + sep, 0)

                    local lbl = gui:FindFirstChild("ESPNameLabel", true)
                    if lbl and lbl:IsA("TextLabel") then
                        lbl.TextSize = ESPTextSize
                        lbl.TextColor3 = ESPColor
                    end
                end
            end

            -- crear si falta (players nuevos / edge cases)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local g = ESP.Players[plr.UserId]
                    if not (g and g.Parent) then
                        createESP(plr)
                    end
                end
            end
        end
        task.wait(0.25)
    end
end)

-- 2) items update (0.15s)
ESP.Conns.ESP_LoopB = task.spawn(function()
    while espIsAlive() do
        if ESPItemsEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    updatePlayerItemsESP(plr)
                end
            end

            for userId, gui in pairs(ESP.Items) do
                if gui and gui.Parent and gui.Adornee and gui.Adornee:IsA("BasePart") then
                    local adornee = gui.Adornee
                    local dist = (Camera.CFrame.Position - adornee.Position).Magnitude
                    local sep = getESPVerticalOffset(dist)
                    gui.StudsOffset = Vector3.new(0, -0.6 - sep, 0)
                end
            end
        else
            -- si se apagó, limpiar items sin tocar players
            for userId, _ in pairs(ESP.Items) do
                destroyItemsESP(userId)
            end
        end
        task.wait(0.15)
    end
end)

-- === Exponer para tu shutdown/close (no rompe) ===
getgenv().GlassmasUI_ESP_Clear = function()
    clearESP()
end

getgenv().GlassmasUI_ESP_Stop = function()
    ESP.Running = false
    -- limpia todo al parar
    clearESP()
    -- desconectar events player hooks
    for k, c in pairs(ESP.Conns) do
        if typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
        ESP.Conns[k] = nil
    end
end

--==================== SETTINGS (SCROLL) ====================
local SettingsScroll = Instance.new("ScrollingFrame", PageSettings)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.Size = UDim2.new(1, 0, 1, -6)
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsScroll.ScrollBarThickness = 4
SettingsScroll.ScrollBarImageColor3 = Theme.Accent
SettingsScroll.Active = true
SettingsScroll.ZIndex = 30 -- 🔑 MISMO NIVEL QUE LAS PÁGINAS
SettingsScroll:SetAttribute("NoDrag", true)


local SettingsList = Instance.new("UIListLayout", SettingsScroll)
SettingsList.Padding = UDim.new(0, UI_ITEM_PADDING)
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
	l.Font = Fonts[CurrentFontName]
	l.TextSize = 14
	l.TextColor3 = Theme.Text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.ZIndex = 41
	return l
end

sectionTitle("🎛️ UI Controls")

local snowToggle = makeAppleToggle(SettingsScroll, "❄️ Nieve", 1, function(on)
	SnowEnabled = on
	if not on then clearSnow() end
end)
snowToggle.Set(true)

-- Keybind hide/show
local KeyRow = Instance.new("Frame", SettingsScroll)
KeyRow.BackgroundTransparency = 1
KeyRow.Size = UDim2.new(1, -24, 0, UI_ITEM_HEIGHT)
KeyRow.ZIndex = 41

local KeyLabel = Instance.new("TextLabel", KeyRow)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Size = UDim2.new(0.55, 0, 1, 0)
KeyLabel.Font = Fonts[CurrentFontName]
KeyLabel.TextSize = 13
KeyLabel.TextColor3 = Theme.Muted
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Text = "Tecla para ocultar/mostrar UI:"
KeyLabel.ZIndex = 41

local KeyBox = Instance.new("TextBox", KeyRow)
KeyBox.Size = UDim2.new(0, 70, 0, 34)
KeyBox.Position = UDim2.new(0.62, 0, 0.5, -17)
KeyBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
KeyBox.BackgroundTransparency = 0.88
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Fonts[CurrentFontName]
KeyBox.TextSize = 16
KeyBox.TextColor3 = Theme.Text
KeyBox.Text = "H"
KeyBox.ZIndex = 41
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)

local SetKeyBtn = Instance.new("TextButton", KeyRow)
SetKeyBtn.AutoButtonColor = false
SetKeyBtn.Size = UDim2.new(0, 110, 0, 34)
SetKeyBtn.Position = UDim2.new(1, -110, 0.5, -17)
SetKeyBtn.BackgroundColor3 = Theme.Glass
SetKeyBtn.BackgroundTransparency = 0.78
SetKeyBtn.BorderSizePixel = 0
SetKeyBtn.Font = Fonts[CurrentFontName]
SetKeyBtn.TextSize = 13
SetKeyBtn.TextColor3 = Theme.Text
SetKeyBtn.Text = "ESTABLECER"
SetKeyBtn.ZIndex = 41
Instance.new("UICorner", SetKeyBtn).CornerRadius = UDim.new(0, 10)

local hideKey = Enum.KeyCode.H
local uiVisible = true

SetKeyBtn.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	playOptionSound()

	local txt = tostring(KeyBox.Text or ""):upper()
	if #txt ~= 1 or not Enum.KeyCode[txt] then
		Notify("⚠️ Pon 1 letra válida (A-Z)", false)
		KeyBox.Text = hideKey.Name
		return
	end

	hideKey = Enum.KeyCode[txt]
	KeyBox.Text = txt
	Notify("✅ Tecla cambiada a: "..txt, true)
end)


sectionTitle("🎨 Personalización")

local function applyStyle(key)
	local s = Styles[key]
	if not s then return end

	CurrentStyle = key
	Theme.Glass = s.Glass
	Theme.Header = s.Header
	Theme.Accent = s.Accent

	-- 🔑 actualizar muted según el theme (CLAVE)
	Theme.Muted = Theme.Glass:Lerp(Color3.new(1,1,1), 0.55)

	tween(Window, TMed, {BackgroundColor3 = Theme.Glass})
	tween(Header, TMed, {BackgroundColor3 = Theme.Header})
	tween(WStroke, TMed, {Color = Theme.Accent})

	tween(TabAutoStroke, TMed, {Color = Theme.Accent})
	tween(TabVisualStroke, TMed, {Color = Theme.Accent})
	tween(TabSetStroke, TMed, {Color = Theme.Accent})
	tween(TabMiscStroke, TMed, {Color = Theme.Accent})

	tween(SettingsScroll, TMed, {ScrollBarImageColor3 = Theme.Accent})
	tween(PageVisual, TMed, {ScrollBarImageColor3 = Theme.Accent})
	tween(PageMisc, TMed, {ScrollBarImageColor3 = Theme.Accent})
	if LogsList then
	tween(LogsList, TMed, {ScrollBarImageColor3 = Theme.Accent})
end


	-- logs
	tween(LogsStroke, TMed, {Color = Theme.Accent})

	if LogsContainer then
		tween(LogsContainer, TMed, {
			BackgroundColor3 = getLogsGlassColor(Theme.Glass),
			BackgroundTransparency = 0.78
		})
	end

	-- 🔁 actualizar color de texto de logs EXISTENTES
	if LogsUI_List then
		for _,c in ipairs(LogsUI_List:GetChildren()) do
			if c:IsA("TextLabel") then
				c.TextColor3 = Theme.Muted
			end
		end
	end

	if key == "Black" then
		tween(Window, TMed, {BackgroundTransparency = 0.82})
	elseif key == "BlackDark" then
		tween(Window, TMed, {BackgroundTransparency = 0.90})
	else
		tween(Window, TMed, {BackgroundTransparency = 0.80})
	end
end

local function applyFont(name)
	local f = Fonts[name]
	if not f then return end
	CurrentFontName = name

	for _,v in ipairs(UI:GetDescendants()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
			v.Font = f
		end
	end
	refreshESPFont()
	redrawLogs()
end

local ThemeHeader, ThemeContainer = makeDropdownHeaderDynamic(SettingsScroll, "🎨 Mostrar UIS")
ThemeHeader.LayoutOrder = 10
ThemeContainer.LayoutOrder = 11

local themeToggles = {}
for key,_ in pairs(Styles) do
	local tog = makeAppleToggle(ThemeContainer, "• Glass "..key, 0, function(on)
		if not on then
			if CurrentStyle == key then themeToggles[key].Set(true) end
			return
		end
		for k,t in pairs(themeToggles) do
			if k ~= key then t.Set(false) end
		end
		applyStyle(key)
	end)
	themeToggles[key] = tog
end
themeToggles[CurrentStyle].Set(true)

local FontHeader, FontContainer = makeDropdownHeaderDynamic(SettingsScroll, "🔤 estilos de letra")
FontHeader.LayoutOrder = 12
FontContainer.LayoutOrder = 13

local fontToggles = {}
for name,_ in pairs(Fonts) do
	local tog = makeAppleToggle(FontContainer, "• "..name, 0, function(on)
		if not on then
			if CurrentFontName == name then fontToggles[name].Set(true) end
			return
		end
		for n,t in pairs(fontToggles) do
			if n ~= name then t.Set(false) end
		end
		applyFont(name)
	end)
	fontToggles[name] = tog
end
fontToggles[CurrentFontName].Set(true)

-- ==================== CAMERA SETUP (EXACT) ====================
local Camera = workspace.CurrentCamera

local BASE_CAMERA_CFRAME = CFrame.new(
	-720.347595, 48.588726, 261.107269,
	-0.999807477, -0.00462738099, -0.0190718602,
	 0.00142769329,  0.952079952, -0.305846155,
	 0.0195732024, -0.305814475, -0.951889932
)

local function SetCameraOnceExact()
	local cam = Camera
	local oldType = cam.CameraType
	local oldSubject = cam.CameraSubject
	local oldFOV = cam.FieldOfView

	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = BASE_CAMERA_CFRAME

	-- 1 frame EXACTO
	RunService.RenderStepped:Wait()

	cam.CameraType = oldType
	cam.CameraSubject = oldSubject
	cam.FieldOfView = oldFOV
end

--==================== MONEY DRYER INSTANT (A→B) ====================
local function runMoneyDryer()
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local ProximityPromptService = game:GetService("ProximityPromptService")

	if not fireproximityprompt then return end

	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.HoldDuration = 0
			v.RequiresLineOfSight = false
		end
	end

	local dryersFolder = Workspace:WaitForChild("MoneyDryers")
	local dryers = dryersFolder:GetChildren()
	if #dryers < 2 then return end

	local PromptA = dryers[4]:WaitForChild("WashingPromptPart"):WaitForChild("ProximityPrompt")
	local PromptB = dryers[5]:WaitForChild("WashingPromptPart"):WaitForChild("ProximityPrompt")

	local _, hum, hrp = getCharParts()
	if not (hum and hrp) then return end

	-- cámara exacta (1 frame, sin lock)
SetCameraOnceExact()

-- TP exacto A↔B
local pA = PromptA.Parent.Position
local pB = PromptB.Parent.Position
local mid = (pA + pB) / 2
hrp.CFrame = CFrame.new(mid, mid + (pA - pB).Unit)


	local SPAM_ON = true
	local INTERVAL = 1 / 60
	local acc = 0

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not SPAM_ON then
			conn:Disconnect()
			return
		end
		acc += dt
		while acc >= INTERVAL do
			acc -= INTERVAL
			fireproximityprompt(PromptA)
			fireproximityprompt(PromptB)
		end
	end)

	hum:ChangeState(Enum.HumanoidStateType.Jumping)

	task.delay(30, function()
		SPAM_ON = false
	end)
end

-- ==================== MONEY LAUNDER HELPERS (NO TOCAR) ====================
local moneyWashRunning = false
local MONEY_WASH_TIME = 30
local MONEY_WASH_CPS = 10

local function getValidDryers()
    local folder = workspace:FindFirstChild("MoneyDryers")
    if not folder then return {} end
    
    local valid = {}
    for _, dryer in ipairs(folder:GetChildren()) do
        local promptPart = dryer:FindFirstChild("WashingPromptPart")
        local prompt = promptPart and promptPart:FindFirstChildOfClass("ProximityPrompt")
        if prompt and promptPart and promptPart:IsA("BasePart") then
            table.insert(valid, {
                dryer = dryer,
                part = promptPart,
                prompt = prompt,
                pos = promptPart.Position
            })
        end
    end
    return valid
end

local function findBestDupePair(dryers)
    if #dryers < 2 then return dryers[1], nil end
    
    local best1, best2 = nil, nil
    local minDist = math.huge
    
    for i = 1, #dryers-1 do
        for j = i+1, #dryers do
            local dist = (dryers[i].pos - dryers[j].pos).Magnitude
            if dist < minDist then
                minDist = dist
                best1 = dryers[i]
                best2 = dryers[j]
            end
        end
    end
    
    return best1, best2
end

--==================== MISC: SNOWMANS (ONE SHOT) ====================
local snowCollectRunning = false
local snowCollectThreadId = 0
local TP_OFFSET = Vector3.new(0, 6, 0)
-- 🔁 Refuerzo de ProximityPrompts (evita que desaparezca la E)
-- ==================== SNOWMAN PROMPT CONTROL (FIX DEFINITIVO) ====================
local SnowmanPromptCache = {}

local function cacheSnowmanPrompts()
	SnowmanPromptCache = {}
	local folder = workspace:FindFirstChild("Snowmans")
	if not folder then return end

	for _, obj in ipairs(folder:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			SnowmanPromptCache[obj] = {
				Enabled = obj.Enabled,
				HoldDuration = obj.HoldDuration,
				MaxActivationDistance = obj.MaxActivationDistance,
				RequiresLineOfSight = obj.RequiresLineOfSight,
			}
		end
	end
end

local function forceSnowmanPrompts()
	local folder = workspace:FindFirstChild("Snowmans")
	if not folder then return end

	for _, obj in ipairs(folder:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			pcall(function()
				obj.Enabled = true
				obj.HoldDuration = 0
				obj.MaxActivationDistance = 999
				obj.RequiresLineOfSight = false
			end)
		end
	end
end

local function restoreSnowmanPrompts()
	for prompt, data in pairs(SnowmanPromptCache) do
		if prompt and prompt.Parent then
			pcall(function()
				prompt.Enabled = data.Enabled
				prompt.HoldDuration = data.HoldDuration
				prompt.MaxActivationDistance = data.MaxActivationDistance
				prompt.RequiresLineOfSight = data.RequiresLineOfSight
			end)
		end
	end
	SnowmanPromptCache = {}
end



local function disableSnowmanPrompts()
	local folder = workspace:FindFirstChild("Snowmans")
	if not folder then return end
	for _, obj in ipairs(folder:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			pcall(function()
				obj.Enabled = false
			end)
		end
	end
end

local function startCollectSnowmans()
	if snowCollectRunning then return end
	snowCollectRunning = true
	snowCollectThreadId += 1
	local myId = snowCollectThreadId

	local char, hum, hrp = getCharParts()
	if not (char and hum and hrp) then
		Notify("❌ Character no listo", false)
		AddLog("❌ Character no listo")
		snowCollectRunning = false
		return
	end

	local folder = workspace:FindFirstChild("Snowmans")
	if not folder then
		Notify("❌ No se encontró Snowmans", false)
		AddLog("❌ Snowmans folder no existe")
		snowCollectRunning = false
		return
	end

	local snowmans = folder:GetChildren()
	local valid = {}

	for _,m in ipairs(snowmans) do
		if m:IsA("Model") then
			for _,d in ipairs(m:GetDescendants()) do
				if d:IsA("ProximityPrompt") then
					table.insert(valid, m)
					break
				end
			end
		end
	end

	if #valid == 0 then
		Notify("❄️ No hay Snowmans en el mapa", false)
		AddLog("❄️ No hay Snowmans disponibles")
		snowCollectRunning = false
		return
	end

	for i,m in ipairs(valid) do
		if not m:GetAttribute("GlassmasID") then
			m:SetAttribute("GlassmasID", i)
		end
	end

	Notify("☃️ Recolectando Snowmans...", true)
	AddLog("☃️ Iniciando ONE-SHOT Snowmans ("..#valid..")")
	cacheSnowmanPrompts()
forceSnowmanPrompts()

	local cam = workspace.CurrentCamera
	local processed = {}

	local function tpTo(part)
		if not part then return end
		hrp.CFrame = part.CFrame + TP_OFFSET
		task.wait(0.12)
	end

	local collected = 0

	for i,m in ipairs(valid) do
		if myId ~= snowCollectThreadId then break end
		if processed[m] then continue end

		local prompt
		for _,d in ipairs(m:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Enabled then
				prompt = d
				break
			end
		end

		if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
			tpTo(prompt.Parent)
			pcall(function()
				cam.CFrame = CFrame.new(cam.CFrame.Position, prompt.Parent.Position)
			end)
			task.wait(0.25)

			local ok = false
			if fireproximityprompt then
				ok = pcall(function() fireproximityprompt(prompt) end)
			else
				ok = pcall(function() PPS:TriggerPrompt(prompt) end)
			end

			if ok then
				collected += 1
				processed[m] = true
				pcall(function() prompt.Enabled = false end)
				AddLog("✅ Snowman #" .. tostring(m:GetAttribute("GlassmasID") or i))
				Notify("☃️ "..collected.." / "..#valid, true)
			else
				AddLog("❌ Fallo Snowman #" .. tostring(m:GetAttribute("GlassmasID") or i))
				Notify("❌ Fallo Snowman #" .. tostring(m:GetAttribute("GlassmasID") or i), false)
			end
		end

		task.wait(0.35)
	end
    
	restoreSnowmanPrompts()
snowCollectRunning = false
	Notify("✅ Recolección finalizada ("..collected.." / "..#valid..")", true)
	AddLog("☃️ Final: "..collected.." / "..#valid)
	AddLog("🛑 Snowmans auto OFF")
end

-- ==================== MISC: MONEY LAUNDER (DUPE x2 FIXED - 2025 UPDATE) ====================
local function washMoney(dupeMode)
    if moneyWashRunning then
        Notify("⏳ Lavado ya en progreso...", false)
        return
    end
    moneyWashRunning = true

    local _, _, hrp = getCharParts()
    if not hrp then
        moneyWashRunning = false
        return
    end

    local startCF = hrp.CFrame
    local dryers = getValidDryers()

    if #dryers == 0 then
        Notify("❌ No se encontraron lavadoras", false)
        moneyWashRunning = false
        return
    end

    local mainDryer, dupeDryer = dryers[1], nil
    if dupeMode and #dryers >= 2 then
        mainDryer, dupeDryer = findBestDupePair(dryers)
    end

    local count = dupeMode and 2 or 1
    Notify(dupeMode and "🧼🔥 DUPE x2 INICIADO! (MÁXIMO RATE)" or "🧼 Lavado normal iniciado", true)
    AddLog(dupeMode and "🧼 DUPE x2 ON" or "🧼 Lavado normal ON")

    -- TP seguro
    local targetPos
    if dupeMode and dupeDryer then
        targetPos = (mainDryer.pos + dupeDryer.pos) / 2 + Vector3.new(0, 5, 0)
    else
        targetPos = mainDryer.part.Position + Vector3.new(0, 5, 0)
    end

    hrp.CFrame = CFrame.new(targetPos, mainDryer.pos)
    task.wait(0.3)

    -- Forzar prompts
    local function forcePrompt(d)
        pcall(function()
            d.prompt.Enabled = true
            d.prompt.HoldDuration = 0
            d.prompt.MaxActivationDistance = 999
            d.prompt.RequiresLineOfSight = false
        end)
    end

    forcePrompt(mainDryer)
    if dupeDryer then forcePrompt(dupeDryer) end

    -- Clicks iniciales 100% paralelos
    task.spawn(function()
        pcall(fireproximityprompt or PPS.TriggerPrompt, mainDryer.prompt)
    end)
    if dupeDryer then
        task.spawn(function()
            pcall(fireproximityprompt or PPS.TriggerPrompt, dupeDryer.prompt)
        end)
    end

    task.wait(0.8)

    -- Auto-clicker ultra rápido
    local function startClicker(prompt)
        task.spawn(function()
            local clicks = MONEY_WASH_TIME * MONEY_WASH_CPS
            for _ = 1, clicks do
                if not moneyWashRunning then break end
                pcall(fireproximityprompt or PPS.TriggerPrompt, prompt)
                task.wait()
                pcall(fireproximityprompt or PPS.TriggerPrompt, prompt)
                task.wait(1 / MONEY_WASH_CPS - 0.01)
            end
        end)
    end

    startClicker(mainDryer.prompt)
    if dupeDryer then startClicker(dupeDryer.prompt) end

    -- Timer
    task.spawn(function()
        for t = MONEY_WASH_TIME, 1, -1 do
            if not moneyWashRunning then break end
            Notify((dupeMode and "🧼🔥 DUPE x2" or "🧼 Lavando").." ⏱️ "..t.."s", true)
            task.wait(1)
        end
        Notify("✅ "..(dupeMode and "DUPE x2 ¡DOBLE GANANCIA!" or "Lavado").." COMPLETADO 💰💰", true)
        AddLog("🧼 "..(dupeMode and "DUPE x2" or "Normal").." OFF")
        moneyWashRunning = false
    end)

    -- Volver
    task.wait(0.6)
    hrp.CFrame = startCF
end

 
-- ==================== FLY + HIDE UI + TOGGLE (FIX FINAL - FUNCIONA SIEMPRE) ====================
-- Tecla Fly personalizable (se actualiza en tiempo real)
local FlyKey = Enum.KeyCode.F
local waitingFlyKey = false

-- Row para Fly (con toggle + keybind)
local FlyRow = Instance.new("Frame", MiscLeft)
FlyRow.BackgroundTransparency = 1
FlyRow.Size = UDim2.new(1, 0, 0, UI_ITEM_HEIGHT)
FlyRow.LayoutOrder = 1

-- Toggle Fly
local flyToggle = makeAppleToggle(FlyRow, "🕊️ Fly", 0, function(on)
    if on then
        startFly()
    else
        stopFly()
    end
end)

flyToggle.Button.Size = UDim2.new(0.48, 0, 1, 0)

-- Label + TextBox + Botón CAMBIAR
local FlyKeyLabel = Instance.new("TextLabel", FlyRow)
FlyKeyLabel.BackgroundTransparency = 1
FlyKeyLabel.Size = UDim2.new(0.2, 0, 1, 0)
FlyKeyLabel.Position = UDim2.new(0.5, 10, 0, 0)
FlyKeyLabel.Font = Fonts[CurrentFontName]
FlyKeyLabel.TextSize = 13
FlyKeyLabel.TextColor3 = Theme.Muted
FlyKeyLabel.Text = "Tecla:"

local FlyKeyBox = Instance.new("TextBox", FlyRow)
FlyKeyBox.Size = UDim2.new(0, 50, 0, 34)
FlyKeyBox.Position = UDim2.new(0.7, 0, 0.5, -17)
FlyKeyBox.BackgroundTransparency = 1 -- ❗ sin caja
FlyKeyBox.BorderSizePixel = 0
FlyKeyBox.ClearTextOnFocus = false
FlyKeyBox.TextXAlignment = Enum.TextXAlignment.Center
FlyKeyBox:SetAttribute("NoDrag", true)
FlyKeyBox.Text = ""               -- 🔥 NO mostrar nada
FlyKeyBox.TextTransparency = 1    -- 🔥 invisible total
FlyKeyBox.TextEditable = false    -- 🔒 nadie escribe aquí
FlyKeyBox.Visible = false         -- 🔥 opcional pero recomendado


local SetFlyKeyBtn = Instance.new("TextButton", FlyRow)
SetFlyKeyBtn.Size = UDim2.new(0, 90, 0, 34)
SetFlyKeyBtn.Position = UDim2.new(1, -90, 0.5, -17)
SetFlyKeyBtn.BackgroundColor3 = Theme.Glass
SetFlyKeyBtn.BackgroundTransparency = 0.78
SetFlyKeyBtn.Text = "[ "..FlyKey.Name.." ]"
SetFlyKeyBtn.Font = Fonts[CurrentFontName]
SetFlyKeyBtn.TextSize = 13
SetFlyKeyBtn.TextColor3 = Theme.Text
Instance.new("UICorner", SetFlyKeyBtn).CornerRadius = UDim.new(0, 10)
SetFlyKeyBtn:SetAttribute("NoDrag", true)

SetFlyKeyBtn.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	playOptionSound()

	waitingFlyKey = true
	SetFlyKeyBtn.Text = "[ ... ]"
	Notify("⌨️ Presiona la nueva tecla para Fly", true)
end)

-- INPUT GLOBAL ÚNICO (Hide UI + Fly + Movimiento)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Hide/Show UI
    if input.KeyCode == hideKey then
        uiVisible = not uiVisible
        Window.Visible = uiVisible
        if uiVisible then blurIn() else blurOut() end
        Notify(uiVisible and "🎄 UI mostrada" or "🎄 UI ocultada", uiVisible)
        return
    end

    -- Toggle Fly con la tecla personalizada
    -- capturar nueva tecla Fly
if waitingFlyKey then
	waitingFlyKey = false
	FlyKey = input.KeyCode

	SetFlyKeyBtn.Text = "[ "..FlyKey.Name.." ]"

	Notify("✅ Tecla Fly cambiada a: "..FlyKey.Name, true)
	return
end

-- Toggle Fly con tecla asignada
if input.KeyCode == FlyKey then
	local newState = not flyToggle.Get()
	flyToggle.Set(newState)

	if newState then
		startFly()
	else
		stopFly()
	end
	return
end

    -- Movimiento solo si Fly activo
    if not FlyEnabled then return end
    if input.KeyCode == Enum.KeyCode.W then FlyMove.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then FlyMove.B = 1 end
    if input.KeyCode == Enum.KeyCode.A then FlyMove.L = 1 end
    if input.KeyCode == Enum.KeyCode.D then FlyMove.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then FlyMove.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then FlyMove.D = 1 end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if not FlyEnabled then return end
    if input.KeyCode == Enum.KeyCode.W then FlyMove.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then FlyMove.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then FlyMove.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then FlyMove.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then FlyMove.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then FlyMove.D = 0 end
end)

-- Slider velocidad (igual)
local FlyHeader, FlyContainer = makeDropdownHeaderDynamic(MiscLeft, "⚡ Velocidad")
FlyHeader.LayoutOrder = 2
FlyContainer.LayoutOrder = 3


-- Snowmans
makeAppleAction(MiscLeft, "☃️ Recolectar Snowmans (ONE SHOT)", 4, function()
	if snowCollectRunning then
		Notify("⏳ Ya se está recolectando...", false)
		return
	end
	startCollectSnowmans()
end)

-- Dinero (DESACTIVADO - SOLO INFO)
-- Dinero (LIMPIEZA TOTAL REAL)
-- Dinero (LIMPIEZA TOTAL REAL)
-- Dinero (LIMPIEZA TOTAL REAL)
local dupeMoneyBtn = makeAppleAction(
	MiscLeft,
	"💰 LIMPIAR TODO EL DINERO",
	5,
	function()
		if moneyWashRunning then
			Notify("⏳ Ya se está limpiando dinero...", false)
			return
		end

		-- 📍 GUARDAR POSICIÓN EXACTA
		local _, _, hrp = getCharParts()
		if not hrp then
			Notify("❌ Character no listo", false)
			return
		end
		local originalCF = hrp.CFrame

		AddLog("🧼 Limpieza total iniciada")

		-- 🖤 pantalla negra SOLO 8 segundos
		showCleaningScreen(9)

		-- 🚀 ejecutar dryer
		task.spawn(runMoneyDryer)

		-- ⏱️ REGRESAR A LOS 6 SEGUNDOS
		task.delay(6, function()
			local _, _, hrp2 = getCharParts()
			if hrp2 then
				hrp2.CFrame = originalCF
				AddLog("↩️ Posición original restaurada")
			end
		end)
	end
)

dupeMoneyBtn:SetAttribute("NoDrag", true)
dupeMoneyBtn.TextSize = 14

-- Tooltip SIN click
attachTooltip(
	dupeMoneyBtn,
	"LIMPIA TODO TU DINERO DE UNA\n\nRECOMENDACIÓN:\nTener de 30K a 100K en rojo (avaces falla🔴) "
)



dupeMoneyBtn:SetAttribute("NoDrag", true)
dupeMoneyBtn.TextSize = 14

-- Tooltip SIN click
attachTooltip(
	dupeMoneyBtn,
	"LIMPIA TODO TU DINERO DE UNA\n\nRECOMENDACIÓN:\nTener de 30K a 100K en rojo (avaces falla🔴) "
)

do
	local SliderFrame = Instance.new("Frame", FlyContainer)
	SliderFrame.Size = UDim2.new(1, 0, 0, UI_ITEM_HEIGHT + 12)
	SliderFrame.BackgroundTransparency = 1

	local Title = Instance.new("TextLabel", SliderFrame)
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1, 0, 0, 22)
	Title.Font = Fonts[CurrentFontName]
	Title.TextSize = 14
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Text = "⚡ Velocidad de vuelo"

	local BarBack = Instance.new("Frame", SliderFrame)
	BarBack.Position = UDim2.new(0, 0, 0, 32)
	BarBack.Size = UDim2.new(1, 0, 0, 10)
	BarBack.BackgroundColor3 = Color3.fromRGB(0,0,0)
	BarBack.BackgroundTransparency = 0.65
	BarBack.BorderSizePixel = 0
	Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1,0)

	local BarFill = Instance.new("Frame", BarBack)
	BarFill.BackgroundColor3 = Theme.Accent
	BarFill.BorderSizePixel = 0
	Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1,0)

	local Knob = Instance.new("Frame", BarBack)
	Knob.Size = UDim2.new(0,18,0,18)
	Knob.BackgroundColor3 = Color3.fromRGB(235,235,235)
	Knob.BorderSizePixel = 0
	Knob.ZIndex = 42
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

	-- 🔒 esto evita que el slider mueva el UI
	SliderFrame:SetAttribute("NoDrag", true)
	BarBack:SetAttribute("NoDrag", true)
	BarFill:SetAttribute("NoDrag", true)
	Knob:SetAttribute("NoDrag", true)

	local dragging = false

	local function setFromX(x)
		local pct = math.clamp(
			(x - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X,
			0, 1
		)

		FlySpeed = math.floor(Fly_MIN + (Fly_MAX - Fly_MIN) * pct)
		BarFill.Size = UDim2.new(pct, 0, 1, 0)
		Knob.Position = UDim2.new(pct, -9, 0.5, -9)
	end

	BarBack.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		SliderDragging = true
		Drag.pending = false
		setFromX(i.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		SliderDragging = false
	end
end)


	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(i.Position.X)
		end
	end)

	-- valor inicial
	task.defer(function()
		local pct = (FlySpeed - Fly_MIN) / (Fly_MAX - Fly_MIN)
		BarFill.Size = UDim2.new(pct, 0, 1, 0)
		Knob.Position = UDim2.new(pct, -9, 0.5, -9)
	end)
end


--==================== MISC: BACKPACK BUY ====================
local function getAvailableBackpacks()
	local list = {}
	if not ItemsFolder then return list end

	for _,v in ipairs(ItemsFolder:GetChildren()) do
		if v and v.Name and tostring(v.Name):lower():find("backpack") then
			if v.Name ~= "BackpackARPClock" and v.Name ~= "BackpackBlack" then
				table.insert(list, v.Name)
			end
		end
	end

	table.sort(list)
	return list
end

local function buySingleBackpack(backpackName)
	if not BackpackShops then
		Notify("❌ BackpackShops no existe", false)
		AddLog("❌ BackpackShops no existe")
		return
	end

	local char, _, hrp = getCharParts()
	if not (char and hrp) then
		Notify("❌ Character no listo", false)
		AddLog("❌ Character no listo")
		return
	end

	if playerHasTool(backpackName) then
		Notify("✅ Ya tienes: "..backpackName, true)
		AddLog("🎒 Ya tienes: "..backpackName)
		return
	end

	local originalCFrame = hrp.CFrame
	local found = false

	for _, shop in ipairs(BackpackShops:GetChildren()) do
		for _, obj in ipairs(shop:GetDescendants()) do
			if obj:IsA("ProximityPrompt") and obj.ActionText then
				local a = obj.ActionText:lower()
				if a:find("buy") then
					-- filtro por nombre aproximado
					local key = backpackName:lower():gsub("backpack","")
					if key == "" then key = backpackName:lower() end
					if a:find(key) or (backpackName == "BackpackLV" and a:find("lv")) then
						found = true
						local part = obj.Parent
						if part and part:IsA("BasePart") then
							tpStanding(part, 2.2)
							task.wait(0.25)
							pcall(function() obj.HoldDuration = 0 end)

							local ok = false
							if fireproximityprompt then
								ok = pcall(function() fireproximityprompt(obj) end)
							else
								ok = pcall(function() PPS:TriggerPrompt(obj) end)
							end

							task.wait(0.8)
							tpBack(originalCFrame)

							if ok then
	Notify("📨 Compra enviada: "..backpackName, true)
	AddLog("📨 Solicitud enviada: "..backpackName)

	--[[ 
task.spawn(function()
    local success = waitForBackpackChange(3)
    if success then
        Notify("✅ Compra confirmada: "..backpackName, true)
        AddLog("✅ Compra confirmada: "..backpackName)
    else
        Notify("⚠️ Compra no confirmada (posible fallo)", false)
        AddLog("⚠️ Compra no confirmada: "..backpackName)
    end
end)
]]

else
	Notify("❌ Prompt falló: "..backpackName, false)
	AddLog("❌ Prompt falló: "..backpackName)
end


							return
						end
					end
				end
			end
		end
	end

	if not found then
		Notify("❌ No se encontró la siguiente: "..backpackName, false)
		AddLog("❌ No se encontró prompt: "..backpackName)
	end
end

local BackpackHeader, BackpackContainer = makeDropdownHeaderDynamic(MiscRight, "🎒 Mochilas")
BackpackHeader.LayoutOrder = 4
BackpackContainer.LayoutOrder = 5

-- 🔄 RECUPERAR MOCHILAS
local backpacks = getAvailableBackpacks()
if #backpacks == 0 then
    makeAppleAction(BackpackContainer, "• (No se detectaron mochilas)", 1, function() end)
else
    for i, name in ipairs(backpacks) do
        local btn = makeAppleAction(BackpackContainer, "• " .. name, i, function()
            buySingleBackpack(name)
        end)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.TextSize = 13
    end
end

-- 🔁 SERVER HOP FIABLE 2025 (sin readfile/writefile + fallback random)
local serverHopBtn = makeAppleAction(
    MiscRight,
    "🔁 serverHop",
    6,
    function()
        Drag.active = false
        Drag.pending = false
        
        Notify("🔁 Buscando servidor nuevo...", true)
        AddLog("🔁 Server Hop iniciado")
        
        local placeId = game.PlaceId
        local jobId = game.JobId
        local servers = {}
        local cursor = ""
        
        -- Intento API (mejorado: limit=50 para evitar bugs)
        local success, err = pcall(function()
            for i = 1, 8 do  -- 8 páginas = 400 servers máx
                local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=50"
                if cursor ~= "" then url = url .. "&cursor=" .. cursor end
                
                local body = game:HttpGet(url)
                local data = HttpService:JSONDecode(body)
                
                for _, srv in ipairs(data.data) do
                    if srv.id ~= jobId and srv.playing < srv.maxPlayers then
                        table.insert(servers, srv.id)
                    end
                end
                
                cursor = data.nextPageCursor or ""
                if cursor == "" then break end
                task.wait(0.2)
            end
        end)
        
        if #servers > 0 then
            local target = servers[math.random(#servers)]
            AddLog("✅ Encontrados " .. #servers .. " servers → Hopping a " .. target)
            Notify("🔁 Saltando a server nuevo...", true)
            TeleportService:TeleportToPlaceInstance(placeId, target, LocalPlayer)
            return
        end
        
        -- Fallback infalible: Teleport random (Roblox elige uno con espacio)
        Notify("🔁 API sin resultados → Hop random", true)
        AddLog("⚠️ Fallback random hop")
        TeleportService:Teleport(placeId, LocalPlayer)
    end
)

serverHopBtn.Size = UDim2.new(1, 0, 0, 44)
serverHopBtn.TextSize = 14
serverHopBtn:SetAttribute("NoDrag", true)

-- 🔄 REJOIN SERVER (MISMO SERVER)
local rejoinBtn = makeAppleAction(
    MiscRight,
    "🔄 Rejoin Server",
    7, -- debajo de serverHop
    function()
        Drag.active = false
        Drag.pending = false

        Notify("🔄 Reuniéndose al mismo server...", true)
        AddLog("🔄 Rejoin Server ejecutado")

        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer

        ts:Teleport(game.PlaceId, p)
    end
)

rejoinBtn.Size = UDim2.new(1, 0, 0, 44)
rejoinBtn.TextSize = 14
rejoinBtn:SetAttribute("NoDrag", true)

-- 🔁 REJOIN WITH SCRIPT (AUTO LOAD)
local rejoinWithScriptBtn = makeAppleAction(
    MiscRight,
    "🔁 Rejoin with Script",
    8, -- debajo de Rejoin Server
    function()
        Drag.active = false
        Drag.pending = false

        Notify("🔁 Rejoin + auto script...", true)
        AddLog("🔁 Rejoin with Script iniciado")

        -- 🔒 Script en cola (se ejecuta al entrar)
        if queue_on_teleport then
            queue_on_teleport([[
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Who1amG/MY-CENTRALL/refs/heads/main/WH0WH3ARE3.lua"))()
                end)
            ]])
        end

        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:Teleport(game.PlaceId, p)
    end
)

rejoinWithScriptBtn.Size = UDim2.new(1, 0, 0, 44)
rejoinWithScriptBtn.TextSize = 14
rejoinWithScriptBtn:SetAttribute("NoDrag", true)




--==================== MINIMIZE / CLOSE ====================
local minimized = false
local originalSize = Window.Size

BtnMin.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	minimized = not minimized
	playOptionSound()

	if minimized then
		tween(Window, TMed, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 56)})
		task.delay(0.16, function()
			if minimized then
				TabsBar.Visible = false
				Content.Visible = false
				SnowLayer.Visible = true
			end
		end)
	else
		TabsBar.Visible = true
		Content.Visible = true
		tween(Window, TMed, {Size = originalSize})
	end
end)

BtnClose.MouseButton1Click:Connect(function()
    blurOut()
    if shouldIgnoreClick() then return end
    playOptionSound()
    getgenv().GlassmasUI_Running = false
    
    -- 🔥 Apagar Fly si estaba activo
    if FlyEnabled then stopFly() end
    
    -- 🔥 BORRAR TODO EL ESP
    clearESP()
    disableESP()  -- apaga flags también
    
    tween(WStroke, TFast, {Transparency = 1})
    tween(Window, TSlow, {BackgroundTransparency = 1, Size = UDim2.new(0, 520, 0, 0)})
    task.delay(0.42, function()
        if UI then UI:Destroy() end
    end)
end)

--==================== FINAL ====================
AddLog("🧪 Sistema de logs iniciado correctamente")
Notify("Made By SPK 💎", true)
blurIn()
print("[GlassmasUI] Loaded • Fixed • Tabs • Settings • Misc • Visual Logs")
