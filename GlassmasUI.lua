-- 🦈 Glassmas UI • Principal (Apple Glass Christmas) • Single Script (FIXED + MISC SNOWMANS)
-- ✅ Tabs + Animations + Sounds (Tab=Slide, Option=Click)
-- ✅ Drag desde cualquier parte (SIN romper clicks)
-- ✅ Snow DENTRO del UI + Toggle ON/OFF (NO tapa opciones)
-- ✅ Drag + Minimize + Close + Keybind Hide
-- ✅ Settings: Dropdown Themes + Dropdown Fonts (5) (Exclusive ON)
-- ✅ + NEW: Misc Tab + Toggle "Collect Snowmans" (ON/OFF) (NO extra UI)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Anti-duplicate (safe)
if getgenv().GlassmasUI_Running then
	pcall(function()
		if getgenv().GlassmasUI_Shutdown then getgenv().GlassmasUI_Shutdown() end
	end)
end

--==================== GUI ROOT ====================
local UI = Instance.new("ScreenGui")
UI.Name = "GlassmasUI"
UI.ResetOnSpawn = false
UI.Parent = PlayerGui

-- Allow clean shutdown
getgenv().GlassmasUI_Running = true
getgenv().GlassmasUI_Shutdown = function()
	getgenv().GlassmasUI_Running = false
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

--==================== SOUNDS ====================
local S_Slide = Instance.new("Sound", UI)
S_Slide.SoundId = "rbxassetid://541909867" -- slide
S_Slide.Volume = 1

local S_Click = Instance.new("Sound", UI)
S_Click.SoundId = "rbxassetid://6026984224" -- click
S_Click.Volume = 1

local function playTabSound()
	pcall(function() SoundService:PlayLocalSound(S_Slide) end)
end

local function playOptionSound()
	pcall(function() SoundService:PlayLocalSound(S_Click) end)
end

--==================== THEME & FONTS ====================
local Styles = {
	Red    = {Glass=Color3.fromRGB(255,110,110), Header=Color3.fromRGB(60,15,20), Accent=Color3.fromRGB(255,90,90)},
	Blue   = {Glass=Color3.fromRGB(110,170,255), Header=Color3.fromRGB(15,25,60), Accent=Color3.fromRGB(120,180,255)},
	Green  = {Glass=Color3.fromRGB(110,255,170), Header=Color3.fromRGB(15,60,35), Accent=Color3.fromRGB(120,255,180)},
	Purple = {Glass=Color3.fromRGB(180,110,255), Header=Color3.fromRGB(40,20,70), Accent=Color3.fromRGB(205,150,255)},
	Gold   = {Glass=Color3.fromRGB(255,210,110), Header=Color3.fromRGB(75,55,18), Accent=Color3.fromRGB(255,215,120)},
	Black = {
		Glass  = Color3.fromRGB(18, 18, 18),
		Header = Color3.fromRGB(10, 10, 10),
		Accent = Color3.fromRGB(90, 90, 90)
	},

	BlackDark = {
		Glass  = Color3.fromRGB(10, 10, 10),
		Header = Color3.fromRGB(6, 6, 6),
		Accent = Color3.fromRGB(60, 60, 60)
	},

}

local Fonts = {
	["Gotham"] = Enum.Font.Gotham,
	["Gotham Semi"] = Enum.Font.GothamSemibold,
	["SourceSans"] = Enum.Font.SourceSans,
	["Nunito"] = Enum.Font.Nunito,
	["Fredoka"] = Enum.Font.FredokaOne,
}

local CurrentStyle = "Red"
local CurrentFontName = "Gotham"

local Theme = {
	Glass = Styles[CurrentStyle].Glass,
	Header = Styles[CurrentStyle].Header,
	Accent = Styles[CurrentStyle].Accent,
	Text = Color3.fromRGB(245,248,255),
	Muted = Color3.fromRGB(210,220,255),
}

--==================== NOTIFICATIONS ====================
local NotifHost = Instance.new("Frame", UI)
NotifHost.BackgroundTransparency = 1
NotifHost.Size = UDim2.new(0, 330, 1, 0)
NotifHost.Position = UDim2.new(1, -345, 0, 12)
NotifHost.Active = false
NotifHost.ZIndex = 999

local NotifList = Instance.new("UIListLayout", NotifHost)
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 10)
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

--==================== WINDOW ====================
local Window = Instance.new("Frame", UI)
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.new(0,560,0,360)
Window.BackgroundColor3 = Theme.Glass
Window.BackgroundTransparency = 0.80
Window.BorderSizePixel = 0
Window.Active = true
Window.ZIndex = 10

Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 22)

local WStroke = Instance.new("UIStroke", Window)
WStroke.Color = Theme.Accent
WStroke.Thickness = 1.5
WStroke.Transparency = 0.45

local WGrad = Instance.new("UIGradient", Window)
WGrad.Rotation = 25
WGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.10),
	NumberSequenceKeypoint.new(0.5, 0.28),
	NumberSequenceKeypoint.new(1, 0.10),
})

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

--==================== SNOW (INSIDE UI, NO INPUT) ====================
local SnowLayer = Instance.new("Frame", Window)
SnowLayer.Name = "SnowLayer"
SnowLayer.BackgroundTransparency = 1
SnowLayer.Size = UDim2.new(1, 0, 1, 0)
SnowLayer.Active = false
SnowLayer.Selectable = false
SnowLayer.ZIndex = 11
SnowLayer.ClipsDescendants = true

local SnowEnabled = true
local snowThreadId = 0

local function clearSnow()
	for _,c in ipairs(SnowLayer:GetChildren()) do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
end

local function spawnSnowflake()
	local flake = Instance.new("Frame")
	flake.Parent = SnowLayer
	flake.BorderSizePixel = 0
	flake.Active = false
	flake.Selectable = false
	flake.ZIndex = 11

	local sz = math.random(2, 5)
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
			task.wait(0.14)
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

-- Layout para 4 tabs (NO se salen)
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
	b.Size = UDim2.new(0, 124, 0, 40) -- caben 4
	b.ZIndex = 31
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)

	local st = Instance.new("UIStroke", b)
	st.Transparency = 0.75
	st.Color = Theme.Accent
	st.Thickness = 1
	return b, st
end

local TabAuto, TabAutoStroke     = makeTabButton("🏠 Auto")
local TabVisual, TabVisualStroke = makeTabButton("👁 Visual")
local TabSettings, TabSetStroke  = makeTabButton("⚙️ Settings")
local TabMisc, TabMiscStroke     = makeTabButton("🧩 Misc")

--==================== CONTENT ====================
local Content = Instance.new("Frame", Window)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 12, 0, 112)
Content.Size = UDim2.new(1, -24, 1, -124)
Content.ClipsDescendants = true
Content.Active = false
Content.ZIndex = 30

local function newPage()
	local p = Instance.new("Frame", Content)
	p.BackgroundTransparency = 1
	p.Size = UDim2.new(1, 0, 1, 0)
	p.Visible = false
	p.Active = false
	p.ZIndex = 30
	return p
end

local PageAuto = newPage()
local PageVisual = newPage()
local PageSettings = newPage()
local PageMisc = newPage()

PageAuto.Visible = true
local CurrentPage = PageAuto
local switching = false

--==================== DRAG ANYWHERE (NO ROMPE CLICKS) ====================
local Drag = {
	pending = false,
	active = false,
	startPos = nil,
	startMouse = nil,
	threshold = 6
}

local function beginDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
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
	return Drag.active
end

Window.InputBegan:Connect(beginDrag)
Window.InputEnded:Connect(endDrag)

for _,obj in ipairs(Window:GetDescendants()) do
	if obj:IsA("Frame") or obj:IsA("TextLabel") then
		obj.InputBegan:Connect(beginDrag)
		obj.InputEnded:Connect(endDrag)
	end
end

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
local function setTabActive(which)
	local function style(btn, st, active)
		tween(btn, TFast, {BackgroundTransparency = active and 0.82 or 0.90})
		tween(st,  TFast, {Transparency = active and 0.40 or 0.80})
	end
	style(TabAuto, TabAutoStroke, which=="auto")
	style(TabVisual, TabVisualStroke, which=="visual")
	style(TabSettings, TabSetStroke, which=="settings")
	style(TabMisc, TabMiscStroke, which=="misc")
end
setTabActive("auto")

local function switchPage(target, which)
	if switching or target == CurrentPage then return end
	switching = true
	playTabSound()

	CurrentPage.Visible = false
	target.Position = UDim2.new(0.06, 0, 0, 0)
	target.Visible = true
	tween(target, TMed, {Position = UDim2.new(0, 0, 0, 0)})

	CurrentPage = target
	setTabActive(which)

	task.delay(0.22, function()
		switching = false
	end)
end

TabAuto.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageAuto, "auto")
end)

TabVisual.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageVisual, "visual")
end)

TabSettings.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageSettings, "settings")
end)

TabMisc.MouseButton1Click:Connect(function()
	if shouldIgnoreClick() then return end
	switchPage(PageMisc, "misc")
end)

--==================== TOGGLE BUTTON ====================
local function makeAppleToggle(parent, label, y, onChanged)
	local state = false

	local b = Instance.new("TextButton", parent)
        b.Text = "" -- 🔥 QUITA EL "Button" FANTASMA
        b.AutoButtonColor = false

	b.Size = UDim2.new(0, 320, 0, 44)
	b.Position = UDim2.new(0.5, -160, 0, y)
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

	b.MouseEnter:Connect(function()
		tween(b, TFast, {BackgroundTransparency = math.max(0.74, b.BackgroundTransparency - 0.06)})
	end)
	b.MouseLeave:Connect(function()
		render()
	end)

	return {
		Set = function(v) state = not not v; render() end,
		Get = function() return state end,
		Button = b,
	}
end


--==================== VISUAL ====================

--==================== VISUAL ESP ====================
local ESPEnabled = false
local ESPObjects = {}
local ESPFontIndex = 1

local ESPFonts = {
	Enum.Font.Gotham,          -- Clean
	Enum.Font.GothamBold,      -- Bold
	Enum.Font.SourceSans,      -- Classic
	Enum.Font.SourceSansBold,  -- Strong
	Enum.Font.Arcade,          -- Arcade
	Enum.Font.Cartoon,         -- Cartoon
	Enum.Font.FredokaOne,      -- Rounded
}


local function clearESP()
	for _,v in pairs(ESPObjects) do
		pcall(function() v:Destroy() end)
	end
	table.clear(ESPObjects)
end

local function createESP(player)
	if player == LocalPlayer then return end
	if not player.Character then return end

	local char = player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end

	local bill = Instance.new("BillboardGui")
	bill.Name = "GlassmasESP"
	bill.Adornee = hrp
	bill.Size = UDim2.new(0, 100, 0, 40)
	bill.StudsOffset = Vector3.new(0, 3, 0)
	bill.AlwaysOnTop = true
	bill.Parent = UI

	local name = Instance.new("TextLabel", bill)
	name.BackgroundTransparency = 1
	name.Size = UDim2.new(1, 0, 1, 0)
	name.Font = Fonts[CurrentFontName]
	name.TextSize = 14
	name.TextColor3 = Color3.fromRGB(255, 80, 80)
	name.TextStrokeTransparency = 0
	name.Text = player.Name
	name.TextScaled = true

	table.insert(ESPObjects, bill)
end

local function enableESP()
	clearESP()
	for _,plr in ipairs(Players:GetPlayers()) do
		createESP(plr)
	end

	ESPObjects._added = Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if ESPEnabled then
				createESP(plr)
			end
		end)
	end)

	ESPObjects._char = Players.PlayerRemoving:Connect(function()
		clearESP()
	end)
end

local function disableESP()
	if ESPObjects._added then ESPObjects._added:Disconnect() end
	if ESPObjects._char then ESPObjects._char:Disconnect() end
	clearESP()
end

makeAppleToggle(PageVisual, "👁 Player ESP", 24, function(on)
	ESPEnabled = on
	if on then
		enableESP()
		Notify("👁 ESP activado", true)
	else
		disableESP()
		Notify("👁 ESP desactivado", false)
	end
end)



--==================== MISC: SNOWMANS COLLECT (ON/OFF) ====================
local snowCollectRunning = false
local snowCollectThreadId = 0

local TP_OFFSET = Vector3.new(0, 6, 0)
local BETWEEN_DELAY = 1

local function forcePhysics(hum)
	pcall(function()
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
	end)
	task.wait(0.15)
	pcall(function()
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

local function waitGround(hum, timeout)
	local t0 = tick()
	while tick() - t0 < (timeout or 1.5) do
		if hum and hum.Parent and hum.FloorMaterial ~= Enum.Material.Air then
			return true
		end
		task.wait(0.05)
	end
	return false
end

local function tpTo(hrp, hum, cf)
	if not (hrp and hum) then return end
	hrp.CFrame = cf + TP_OFFSET
	task.wait(0.1)
	forcePhysics(hum)
	waitGround(hum, 1.5)
end

local function startCollectSnowmans()
	if snowCollectRunning then return end
	snowCollectRunning = true
	snowCollectThreadId += 1
	local myId = snowCollectThreadId

	task.spawn(function()
		while getgenv().GlassmasUI_Running and snowCollectRunning and myId == snowCollectThreadId do
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")

			-- HoldDuration = 0
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") then
					v.HoldDuration = 0
				end
			end

			local SnowmansFolder = workspace:FindFirstChild("Snowmans")
			if not SnowmansFolder then
				task.wait(2)
				continue
			end

			for _, snowman in ipairs(SnowmansFolder:GetChildren()) do
				if not (snowCollectRunning and myId == snowCollectThreadId) then break end
				if snowman:IsA("Model") then
					local prompt
					for _, d in ipairs(snowman:GetDescendants()) do
						if d:IsA("ProximityPrompt") and d.Enabled then
							prompt = d
							break
						end
					end

					if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
						tpTo(hrp, hum, prompt.Parent.CFrame)
						task.wait(0.3)

						if fireproximityprompt then
							pcall(function()
								fireproximityprompt(prompt)
							end)
						end

						task.wait(BETWEEN_DELAY)
					end
				end
			end

			task.wait(1.0)
		end
	end)
end

local function stopCollectSnowmans()
	snowCollectRunning = false
	snowCollectThreadId += 1
end

makeAppleToggle(PageMisc, "☃️ Collect Snowmans", 24, function(on)
	if on then
		startCollectSnowmans()
		Notify("☃️ Auto-colección de Snowmans ACTIVADA", true)
	else
		stopCollectSnowmans()
		Notify("☃️ Auto-colección de Snowmans DESACTIVADA", false)
	end
end)

--==================== SETTINGS (SCROLL) ====================
local SettingsScroll = Instance.new("ScrollingFrame", PageSettings)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsScroll.ScrollBarThickness = 4
SettingsScroll.ScrollBarImageColor3 = Theme.Accent
SettingsScroll.Active = true
SettingsScroll.ZIndex = 40

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
	l.Font = Fonts[CurrentFontName]
	l.TextSize = 14
	l.TextColor3 = Theme.Text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.ZIndex = 41
	return l
end

sectionTitle("🎛️ UI Controls")

-- Snow Toggle
local snowToggle = makeAppleToggle(SettingsScroll, "❄️ Nieve", 0, function(on)
	SnowEnabled = on
	if not on then
		clearSnow()
	end
end)
snowToggle.Set(true)

-- Keybind hide/show
local KeyRow = Instance.new("Frame", SettingsScroll)
KeyRow.BackgroundTransparency = 1
KeyRow.Size = UDim2.new(1, -24, 0, 48)
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

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == hideKey then
		uiVisible = not uiVisible
		Window.Visible = uiVisible
		Notify(uiVisible and "🎄 UI mostrada" or "🎄 UI ocultada", uiVisible)
	end
end)

-- Dropdown helper
local function makeDropdownHeader(titleText)
	local headerBtn = Instance.new("TextButton", SettingsScroll)
	headerBtn.AutoButtonColor = false
	headerBtn.Size = UDim2.new(0, 320, 0, 44)
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

	local container = Instance.new("Frame", SettingsScroll)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.Size = UDim2.new(0, 320, 0, 0)
	container.ZIndex = 41

	local list = Instance.new("UIListLayout", container)
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	local open = false
	headerBtn.MouseButton1Click:Connect(function()
		if shouldIgnoreClick() then return end
		open = not open
		playOptionSound()
		headerBtn.Text = titleText .. (open and " ▾" or " ▸")
		tween(container, TMed, {Size = open and UDim2.new(0, 320, 0, 44*5 + 8*4) or UDim2.new(0, 320, 0, 0)})
	end)

	return headerBtn, container
end

local function applyStyle(key)
	local s = Styles[key]
	if not s then return end
	CurrentStyle = key

	Theme.Glass = s.Glass
	Theme.Header = s.Header
	Theme.Accent = s.Accent

	tween(Window, TMed, {BackgroundColor3 = Theme.Glass})
	tween(Header, TMed, {BackgroundColor3 = Theme.Header})
	tween(WStroke, TMed, {Color = Theme.Accent})
	tween(TabAutoStroke, TMed, {Color = Theme.Accent})
	tween(TabVisualStroke, TMed, {Color = Theme.Accent})
	tween(TabSetStroke, TMed, {Color = Theme.Accent})
	tween(TabMiscStroke, TMed, {Color = Theme.Accent})
	tween(SettingsScroll, TMed, {ScrollBarImageColor3 = Theme.Accent})

	-- 🔥 AQUÍ VA ESTO (AL FINAL DE applyStyle)
	-- Ajustar opacidad según estilo (Glass negro real)
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
end

sectionTitle("🎨 Personalización")

-- Dropdown: Themes
local _, ThemeContainer = makeDropdownHeader("🎨 Mostrar UIS")
local themeToggles = {}
for key,_ in pairs(Styles) do
	local tog = makeAppleToggle(ThemeContainer, "• Glass " .. key, 0, function(on)
		if not on then
			if CurrentStyle == key then
				themeToggles[key].Set(true)
			end
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

-- Dropdown: Fonts
local _, FontContainer = makeDropdownHeader("🔤 estilos de letra")
local fontToggles = {}
for name,_ in pairs(Fonts) do
	local tog = makeAppleToggle(FontContainer, "• " .. name, 0, function(on)
		if not on then
			if CurrentFontName == name then
				fontToggles[name].Set(true)
			end
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
	if shouldIgnoreClick() then return end
	playOptionSound()

	-- stop background loops clean
	stopCollectSnowmans()
	getgenv().GlassmasUI_Running = false

	tween(WStroke, TFast, {Transparency = 1})
	tween(Window, TSlow, {BackgroundTransparency = 1, Size = UDim2.new(0, 520, 0, 0)})
	task.delay(0.42, function()
		if UI then UI:Destroy() end
	end)
end)

Notify(" Made By SPK 💎 ", true)
print("[GlassmasUI] Loaded • Tabs(4) • Misc Snowmans Toggle ON/OFF • Single Script")
