local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService") -- YA NO SOY NIGGER

local localPlayer = Players.LocalPlayer
local PlayerGui   = localPlayer:WaitForChild("PlayerGui")

--====================================================
-- MOBILE DETECTION
--====================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local UI_W      = isMobile and 340 or 500
local UI_H      = isMobile and 290 or 390
local SIDEBAR_W = isMobile and 88  or 118
local FONT_SM   = isMobile and 9   or 10
local FONT_MD   = isMobile and 10  or 12
local FONT_LG   = isMobile and 11  or 13
local ROW_H     = isMobile and 34  or 38
local ROW_R     = isMobile and 12  or 14
local HDR_H     = isMobile and 48  or 58
local TAB_H     = isMobile and 38  or 44
local TAB_ICON  = isMobile and 13  or 16

--====================================================
-- CONFIG
--====================================================
local defaultConfig = { theme="Default", fontStyle="Modern", bgImageId="108458500083995" }
local CONFIG_FILE = "WH01Config_Template.json"
local CONFIG_ATTR = "WH01Config_Template"

local function saveConfig(cfg)
    local encoded = HttpService:JSONEncode(cfg)
    pcall(function() if writefile then writefile(CONFIG_FILE, encoded) end end)
    pcall(function() PlayerGui:SetAttribute(CONFIG_ATTR, encoded) end)
end

local function loadConfig()
    local data = nil
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        end
    end)
    if not data then
        pcall(function()
            local attr = PlayerGui:GetAttribute(CONFIG_ATTR)
            if attr then data = HttpService:JSONDecode(attr) end
        end)
    end
    if type(data) == "table" then
        for k,v in pairs(defaultConfig) do
            if data[k] == nil then data[k] = v end
        end
        return data
    end
    return table.clone(defaultConfig)
end

local config = loadConfig()

--====================================================
-- THEMES
--====================================================
local themes = {
    Default = {
        primary=Color3.fromRGB(8,8,8), secondary=Color3.fromRGB(15,15,15),
        accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(255,255,255),
        subtext=Color3.fromRGB(150,150,150), sidebar=Color3.fromRGB(12,12,12),
        row=Color3.fromRGB(18,18,18), stroke=Color3.fromRGB(255,255,255),
        snow=false, valentine=false, logoId="121057068601747",
        mainTabIcon="97378928892774", teleportTabIcon="124656414586890",
        settingsTabIcon="84417015405492", micsTabIcon="129896879015985",
        bgId="108458500083995",
    },
    Valentine = {
        primary=Color3.fromRGB(18,5,10), secondary=Color3.fromRGB(35,10,18),
        accent=Color3.fromRGB(220,60,100), text=Color3.fromRGB(255,200,215),
        subtext=Color3.fromRGB(180,100,130), sidebar=Color3.fromRGB(25,5,12),
        row=Color3.fromRGB(30,8,18), stroke=Color3.fromRGB(220,60,100),
        snow=false, valentine=true, logoId="128713599886538",
        mainTabIcon="118293451431629", teleportTabIcon="93867203416430",
        settingsTabIcon="92027932993173", micsTabIcon="81212960677084",
        bgId="86406538802929",
    },
    Snow = {
        primary=Color3.fromRGB(8,10,18), secondary=Color3.fromRGB(14,18,30),
        accent=Color3.fromRGB(200,220,255), text=Color3.fromRGB(220,235,255),
        subtext=Color3.fromRGB(140,160,200), sidebar=Color3.fromRGB(10,13,22),
        row=Color3.fromRGB(16,20,35), stroke=Color3.fromRGB(180,210,255),
        snow=true, valentine=false, logoId="105877636667273",
        mainTabIcon="86228203034983", teleportTabIcon="99769954902270",
        settingsTabIcon="98653576343548", micsTabIcon="96765613903347",
        bgId="103508032104468",
    },
    Garden = {
        primary=Color3.fromRGB(25,20,10), secondary=Color3.fromRGB(45,35,20),
        accent=Color3.fromRGB(150,200,80), text=Color3.fromRGB(245,245,230),
        subtext=Color3.fromRGB(180,160,120), sidebar=Color3.fromRGB(30,25,15),
        row=Color3.fromRGB(40,32,18), stroke=Color3.fromRGB(150,200,80),
        snow=false, valentine=false, garden=true, logoId="121057068601747",
        mainTabIcon="97378928892774", teleportTabIcon="124656414586890",
        settingsTabIcon="84417015405492", micsTabIcon="129896879015985",
        bgId="113023242212701",
    },
}
local fonts = {
    Modern=Enum.Font.GothamBold, Arcade=Enum.Font.Arcade,
    Rounded=Enum.Font.Gotham, Bold=Enum.Font.GothamBlack,
}

--====================================================
-- CLEANUP & GUI
--====================================================
if _G.WH01_SHUTDOWN_TEMPLATE then pcall(_G.WH01_SHUTDOWN_TEMPLATE) end
local shutdownFuncs = {}
_G.WH01_SHUTDOWN_TEMPLATE = function()
    for _, f in ipairs(shutdownFuncs) do pcall(f) end
end

local function randomStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, len do local r = math.random(1,#chars); s=s..chars:sub(r,r) end
    return s
end
local UI_NAME = randomStr(12)

for _, v in ipairs(PlayerGui:GetChildren()) do
    if v:GetAttribute("__mt") == true then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name=UI_NAME; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false
gui:SetAttribute("__mt", true); gui.Parent=PlayerGui

local T_FAST   = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local T_SMOOTH = TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function tw(o,i,p) TweenService:Create(o,i,p):Play() end

--====================================================
-- OBJECT REGISTRIES
--====================================================
local rows        = {}
local textMain    = {}
local textSub     = {}
local fontObjs    = {}
local checkBoxes  = {}
local dropRows    = {}
local dropLists   = {}
local strokeObjs  = {}
local sliderObjs  = {}
local scrollBars  = {}
local tabBtns     = {}
local tabData     = {}
local gameName    = nil
local root, rootStroke, bgImage
local header, headerBottom, headerDivider
local sidebar, sidebarTopCover, sideDiv
local titleLabel, subtitleLabel, statusLabel, logo
local minimize, minimizeStroke, close, closeStroke
local contentArea, body
local bgSection, bgSectionStroke, bgPrefixLbl, bgInput, applyBgBtn

--====================================================
-- SLIDER — estado global
--====================================================
local activeSlider    = nil
local sliderTouchDown = false

local function posInSlider(posX, posY)
    for _, s in ipairs(sliderObjs) do
        if s.track and s.track.Parent then
            local ap = s.track.AbsolutePosition
            local as = s.track.AbsoluteSize
            if posX >= ap.X-12 and posX <= ap.X+as.X+12 and
               posY >= ap.Y-24 and posY <= ap.Y+as.Y+24 then
                return true
            end
        end
    end
    return false
end

UserInputService.InputChanged:Connect(function(inp)
    if activeSlider and
       (inp.UserInputType==Enum.UserInputType.MouseMovement or
        inp.UserInputType==Enum.UserInputType.Touch) then
        local trackAbsPos  = activeSlider.track.AbsolutePosition
        local trackAbsSize = activeSlider.track.AbsoluteSize
        local r = math.clamp((inp.Position.X-trackAbsPos.X)/trackAbsSize.X,0,1)
        local newVal = activeSlider.minVal + r*(activeSlider.maxVal-activeSlider.minVal)
        activeSlider.update(newVal, false)
        statusLabel.Text = "● "..activeSlider.label..": "..tostring(math.floor(newVal))
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or
       inp.UserInputType==Enum.UserInputType.Touch then
        activeSlider=nil; sliderTouchDown=false
    end
end)

--====================================================
-- PARTICLES
--====================================================
local pFlakes, pConn, pContainer = {}, nil, nil
local minimized = false

local function clearParticles()
    if pConn then pConn:Disconnect(); pConn=nil end
    for _,f in ipairs(pFlakes) do
        if f and f.Parent then
            TweenService:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=1}):Play()
            task.delay(0.3,function() if f and f.Parent then f:Destroy() end end)
        end
    end
    pFlakes={}
    local c=pContainer
    if c and c.Parent then task.delay(0.3,function() if c and c.Parent then c:Destroy() end end) end
    pContainer=nil
end

local function makeParticleContainer()
    local c=Instance.new("Frame"); c.Parent=root
    c.Size=UDim2.new(1,-6,1,-6); c.Position=UDim2.new(0,3,0,3)
    c.BackgroundTransparency=1; c.ZIndex=2; c.ClipsDescendants=true
    local cc=Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,24); cc.Parent=c
    return c
end

local function startSnow()
    pContainer=makeParticleContainer()
    local MAX=20; local active=0; local timer=0
    local function spawn()
        if active>=MAX then return end; active=active+1
        local f=Instance.new("TextLabel"); f.Parent=pContainer
        f.BackgroundTransparency=1; f.Text="❄"; f.Font=Enum.Font.Gotham
        f.TextSize=math.random(8,15); f.TextColor3=Color3.fromRGB(200,220,255)
        f.TextTransparency=math.random(15,45)/100; f.ZIndex=3
        local x=math.random(2,95)/100; f.Size=UDim2.new(0,30,0,30)
        f.Position=UDim2.new(x,0,-0.02,0)
        local dur=math.random(7,12); local drift=math.random(-5,5)/100
        tw(f,TweenInfo.new(dur,Enum.EasingStyle.Sine),{Position=UDim2.new(x+drift,0,1.02,0),TextTransparency=0.8})
        table.insert(pFlakes,f)
        task.delay(dur,function() active=active-1; if f and f.Parent then f:Destroy() end end)
    end
    pConn=RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=0.9 then timer=0; spawn() end end)
    for i=1,6 do task.delay(i*0.6,spawn) end
end

local function startValentine()
    pContainer=makeParticleContainer()
    local syms={"🌹","❤️","💕","💗","💖","🌸"}
    local MAX=15; local active=0; local timer=0
    local function spawn()
        if active>=MAX then return end; active=active+1
        local f=Instance.new("TextLabel"); f.Parent=pContainer
        f.BackgroundTransparency=1; f.Text=syms[math.random(1,#syms)]; f.Font=Enum.Font.Gotham
        f.TextSize=math.random(11,18); f.TextTransparency=math.random(10,35)/100; f.ZIndex=3
        local x=math.random(2,95)/100; f.Size=UDim2.new(0,30,0,30)
        f.Position=UDim2.new(x,0,-0.02,0)
        local dur=math.random(7,12); local drift=math.random(-5,5)/100
        tw(f,TweenInfo.new(dur,Enum.EasingStyle.Sine),{Position=UDim2.new(x+drift,0,1.02,0),TextTransparency=0.8})
        table.insert(pFlakes,f)
        task.delay(dur,function() active=active-1; if f and f.Parent then f:Destroy() end end)
    end
    pConn=RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=1.6 then timer=0; spawn() end end)
    for i=1,5 do task.delay(i*1.4,spawn) end
end

local function startGarden()
    pContainer=makeParticleContainer()
    local syms={"🥕","🌿","🌾","🌻","🪴","🌱"}
    local MAX=15; local active=0; local timer=0
    local function spawn()
        if active>=MAX then return end; active=active+1
        local f=Instance.new("TextLabel"); f.Parent=pContainer
        f.BackgroundTransparency=1; f.Text=syms[math.random(1,#syms)]; f.Font=Enum.Font.Gotham
        f.TextSize=math.random(11,18); f.TextTransparency=math.random(10,35)/100; f.ZIndex=3
        local x=math.random(2,95)/100; f.Size=UDim2.new(0,30,0,30)
        f.Position=UDim2.new(x,0,-0.02,0)
        local dur=math.random(7,12); local drift=math.random(-5,5)/100
        tw(f,TweenInfo.new(dur,Enum.EasingStyle.Sine),{Position=UDim2.new(x+drift,0,1.02,0),TextTransparency=0.8})
        table.insert(pFlakes,f)
        task.delay(dur,function() active=active-1; if f and f.Parent then f:Destroy() end end)
    end
    pConn=RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=1.6 then timer=0; spawn() end end)
    for i=1,5 do task.delay(i*1.4,spawn) end
end

--====================================================
-- APPLY THEME
--====================================================
local function applyTheme(name)
    config.theme=name; saveConfig(config)
    local t=themes[name]; if not t then return end
    tw(root,T_SMOOTH,{BackgroundColor3=t.primary}); rootStroke.Color=t.stroke
    tw(header,T_SMOOTH,{BackgroundColor3=t.secondary})
    tw(headerDivider,T_SMOOTH,{BackgroundColor3=t.stroke})
    tw(sidebar,T_SMOOTH,{BackgroundColor3=t.sidebar})
    tw(sidebarTopCover,T_SMOOTH,{BackgroundColor3=t.sidebar})
    tw(sideDiv,T_SMOOTH,{BackgroundColor3=t.stroke})
    if logo and t.logoId then logo.Image="rbxassetid://"..t.logoId end
    if bgImage and t.bgId then
        bgImage.Image="rbxassetid://"..t.bgId
        config.bgImageId=t.bgId; saveConfig(config)
        if bgInput then bgInput.Text=t.bgId end
    end
    tw(titleLabel,T_SMOOTH,{TextColor3=t.text}); tw(subtitleLabel,T_SMOOTH,{TextColor3=t.subtext})
    tw(statusLabel,T_SMOOTH,{TextColor3=t.subtext})
    tw(minimize,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text}); minimizeStroke.Color=t.stroke
    tw(close,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text}); closeStroke.Color=t.stroke
    for _, scroll in ipairs(scrollBars) do
        if scroll and scroll.Parent then scroll.ScrollBarImageColor3 = t.accent end
    end
    for _,r in ipairs(rows) do
        if r.frame and r.frame.Parent then
            tw(r.frame,T_SMOOTH,{BackgroundColor3=t.row})
            if r.stroke then r.stroke.Color=t.stroke end
        end
    end
    for _,o in ipairs(textMain) do if o and o.Parent then tw(o,T_SMOOTH,{TextColor3=t.text}) end end
    for _,o in ipairs(textSub)  do if o and o.Parent then tw(o,T_SMOOTH,{TextColor3=t.subtext}) end end
    for _,cb in ipairs(checkBoxes) do
        if cb.box and cb.box.Parent then
            local checked=cb.getState()
            tw(cb.box,T_SMOOTH,{BackgroundColor3=checked and t.accent or t.row})
            if cb.chk   then cb.chk.TextColor3=t.primary end
            if cb.stroke then cb.stroke.Color=t.stroke end
        end
    end
    for _,d in ipairs(dropRows) do
        if d.frame and d.frame.Parent then
            tw(d.frame,T_SMOOTH,{BackgroundColor3=t.row})
            if d.stroke then d.stroke.Color=t.stroke end
        end
    end
    for _,d in ipairs(dropLists) do
        if d.frame and d.frame.Parent then
            tw(d.frame,T_SMOOTH,{BackgroundColor3=t.secondary})
            if d.stroke then d.stroke.Color=t.stroke end
            for _,child in ipairs(d.frame:GetChildren()) do
                if child:IsA("TextButton") then
                    tw(child,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text})
                end
            end
        end
    end
    for _,s in ipairs(sliderObjs) do
        if s.track and s.track.Parent then
            tw(s.track,T_SMOOTH,{BackgroundColor3=t.row})
            if s.stroke then s.stroke.Color=t.stroke end
            tw(s.fill,T_SMOOTH,{BackgroundColor3=t.accent})
            tw(s.knob,T_SMOOTH,{BackgroundColor3=t.accent})
            if s.valLbl  then tw(s.valLbl,T_SMOOTH,{TextColor3=t.accent}) end
            if s.nameLbl then tw(s.nameLbl,T_SMOOTH,{TextColor3=t.text}) end
        end
    end
    if bgSection       then tw(bgSection,T_SMOOTH,{BackgroundColor3=t.row}) end
    if bgSectionStroke then bgSectionStroke.Color=t.stroke end
    if bgPrefixLbl     then tw(bgPrefixLbl,T_SMOOTH,{TextColor3=t.subtext}) end
    if bgInput         then
        tw(bgInput,T_SMOOTH,{BackgroundColor3=t.primary,TextColor3=t.text})
        bgInput.PlaceholderColor3=t.subtext
    end
    if applyBgBtn then tw(applyBgBtn,T_SMOOTH,{BackgroundColor3=t.accent,TextColor3=t.primary}) end
    if seedShopLabel then tw(seedShopLabel,T_SMOOTH,{TextColor3=t.subtext}) end
    if gearShopLabel then tw(gearShopLabel,T_SMOOTH,{TextColor3=t.subtext}) end
    for i,tb in ipairs(tabBtns) do
        local on=(i==activeTabIdx)
        tw(tb.bg,T_SMOOTH,{BackgroundColor3=on and t.accent or t.row,BackgroundTransparency=on and 0 or 0.55})
        tw(tb.lbl,T_SMOOTH,{TextColor3=on and t.primary or t.text})
        if tb.stroke then tb.stroke.Color=t.stroke end
        if tb.isImage then
            tw(tb.ico,T_SMOOTH,{ImageColor3=on and t.primary or t.subtext})
            if tabData[i].name=="Main"      and t.mainTabIcon     then tb.ico.Image="rbxassetid://"..t.mainTabIcon end
            if tabData[i].name=="Mics"      and t.micsTabIcon     then tb.ico.Image="rbxassetid://"..t.micsTabIcon end
            if tabData[i].name=="Teleports" and t.teleportTabIcon then tb.ico.Image="rbxassetid://"..t.teleportTabIcon end
            if tabData[i].name=="Settings"  and t.settingsTabIcon then tb.ico.Image="rbxassetid://"..t.settingsTabIcon end
        else
            tw(tb.ico,T_SMOOTH,{TextColor3=on and t.primary or t.subtext})
        end
    end
    clearParticles()
    if not minimized then
        task.delay(0.35,function()
            local th=themes[config.theme]
            if th.snow then startSnow() elseif th.valentine then startValentine() elseif th.garden then startGarden() end
        end)
    end
end

local function applyFont(name)
    config.fontStyle=name; saveConfig(config)
    local f=fonts[name] or Enum.Font.GothamBold
    for _,o in ipairs(fontObjs) do if o and o.Parent then o.Font=f end end
end

--====================================================
-- BUILD ROOT
--====================================================
root=Instance.new("Frame"); root.Parent=gui
root.Size=UDim2.new(0,UI_W,0,UI_H)
root.Position=UDim2.fromScale(0.5,0.5); root.AnchorPoint=Vector2.new(0.5,0.5)
root.BackgroundColor3=themes[config.theme].primary
root.BackgroundTransparency=0.02; root.ClipsDescendants=true; root.ZIndex=1
local rc=Instance.new("UICorner",root); rc.CornerRadius=UDim.new(0,24)
rootStroke=Instance.new("UIStroke",root); rootStroke.Color=themes[config.theme].stroke
rootStroke.Transparency=0.88; rootStroke.Thickness=1.2

bgImage=Instance.new("ImageLabel"); bgImage.Parent=root
bgImage.Size=UDim2.new(1,-2,1,-2); bgImage.Position=UDim2.new(0,1,0,1)
bgImage.BackgroundTransparency=1
bgImage.Image="rbxassetid://"..(config.bgImageId or "108458500083995")
bgImage.ScaleType=Enum.ScaleType.Crop; bgImage.ImageTransparency=0.82
bgImage.ZIndex=1; bgImage.ClipsDescendants=true
local bic=Instance.new("UICorner"); bic.CornerRadius=UDim.new(0,24); bic.Parent=bgImage

--====================================================
-- HEADER
--====================================================
header=Instance.new("Frame"); header.Parent=root
header.Size=UDim2.new(1,0,0,HDR_H); header.BackgroundColor3=themes[config.theme].secondary
header.BackgroundTransparency=0.25; header.BorderSizePixel=0; header.ZIndex=3
local hc=Instance.new("UICorner"); hc.CornerRadius=UDim.new(0,24); hc.Parent=header
header.ClipsDescendants=true

headerDivider=Instance.new("Frame"); headerDivider.Parent=root
headerDivider.Size=UDim2.new(1,-40,0,1); headerDivider.Position=UDim2.new(0,20,0,HDR_H)
headerDivider.BackgroundColor3=themes[config.theme].stroke
headerDivider.BackgroundTransparency=0.9; headerDivider.BorderSizePixel=0; headerDivider.ZIndex=4

logo=Instance.new("ImageLabel"); logo.Parent=root
local logoSz=isMobile and 26 or 34; local logoPad=isMobile and 10 or 16; local logoTop=isMobile and 11 or 12
logo.Size=UDim2.new(0,logoSz,0,logoSz); logo.Position=UDim2.new(0,logoPad,0,logoTop)
logo.BackgroundTransparency=1; logo.Image="rbxassetid://128713599886538"
logo.ScaleType=Enum.ScaleType.Fit; logo.ZIndex=5
local lgc=Instance.new("UICorner",logo); lgc.CornerRadius=UDim.new(0.3,0)

local titleX=isMobile and 44 or 58; local titleTop=isMobile and 9 or 12
titleLabel=Instance.new("TextLabel"); titleLabel.Parent=root
titleLabel.Size=UDim2.new(0,200,0,18); titleLabel.Position=UDim2.new(0,titleX,0,titleTop)
titleLabel.BackgroundTransparency=1; titleLabel.Text="🥕 WH01"
titleLabel.Font=fonts[config.fontStyle] or Enum.Font.GothamBold
titleLabel.TextSize=FONT_SM+1; titleLabel.TextColor3=themes[config.theme].text
titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.ZIndex=5
table.insert(fontObjs,titleLabel)

task.spawn(function()
    local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then gameName=info.Name; titleLabel.Text="WH01  ·  "..gameName end
end)

local subtitleTop=isMobile and 27 or 32
subtitleLabel=Instance.new("TextLabel"); subtitleLabel.Parent=root
subtitleLabel.Size=UDim2.new(0,200,0,14); subtitleLabel.Position=UDim2.new(0,titleX,0,subtitleTop)
subtitleLabel.BackgroundTransparency=1; subtitleLabel.Text="made by wh01am"
subtitleLabel.Font=Enum.Font.Gotham; subtitleLabel.TextSize=FONT_SM-1
subtitleLabel.TextColor3=themes[config.theme].subtext
subtitleLabel.TextXAlignment=Enum.TextXAlignment.Left; subtitleLabel.ZIndex=5

statusLabel=Instance.new("TextLabel"); statusLabel.Parent=root
statusLabel.Size=UDim2.new(0,260,0,22); statusLabel.Position=UDim2.new(0,16,1,-24)
statusLabel.BackgroundTransparency=1; statusLabel.Text="● System Ready"
statusLabel.Font=Enum.Font.GothamMedium; statusLabel.TextSize=FONT_SM
statusLabel.TextColor3=themes[config.theme].subtext
statusLabel.TextXAlignment=Enum.TextXAlignment.Left; statusLabel.ZIndex=10

--====================================================
-- MINIMIZE & CLOSE
--====================================================
local btnSz=isMobile and 24 or 26; local minX=isMobile and -56 or -62
local clsX=isMobile and -28 or -32; local btnTop=isMobile and 12 or 16

minimize=Instance.new("TextButton"); minimize.Parent=root
minimize.Size=UDim2.new(0,btnSz,0,btnSz); minimize.Position=UDim2.new(1,minX,0,btnTop)
minimize.Text="—"; minimize.Font=Enum.Font.GothamBold; minimize.TextSize=12
minimize.TextColor3=themes[config.theme].text; minimize.BackgroundColor3=themes[config.theme].row
minimize.AutoButtonColor=false; minimize.ZIndex=6
local mc=Instance.new("UICorner",minimize); mc.CornerRadius=UDim.new(1,0)
minimizeStroke=Instance.new("UIStroke",minimize); minimizeStroke.Color=themes[config.theme].stroke; minimizeStroke.Transparency=0.88

close=Instance.new("TextButton"); close.Parent=root
close.Size=UDim2.new(0,btnSz,0,btnSz); close.Position=UDim2.new(1,clsX,0,btnTop)
close.Text="X"; close.Font=Enum.Font.GothamBold; close.TextSize=12
close.TextColor3=themes[config.theme].text; close.BackgroundColor3=themes[config.theme].row
close.AutoButtonColor=false; close.ZIndex=6
local clc=Instance.new("UICorner",close); clc.CornerRadius=UDim.new(1,0)
closeStroke=Instance.new("UIStroke",close); closeStroke.Color=themes[config.theme].stroke; closeStroke.Transparency=0.88

minimize.MouseEnter:Connect(function() tw(minimize,T_FAST,{BackgroundColor3=themes[config.theme].accent,TextColor3=themes[config.theme].primary}) end)
minimize.MouseLeave:Connect(function() tw(minimize,T_FAST,{BackgroundColor3=themes[config.theme].row,TextColor3=themes[config.theme].text}) end)
close.MouseEnter:Connect(function() tw(close,T_FAST,{BackgroundColor3=themes[config.theme].accent,TextColor3=themes[config.theme].primary}) end)
close.MouseLeave:Connect(function() tw(close,T_FAST,{BackgroundColor3=themes[config.theme].row,TextColor3=themes[config.theme].text}) end)

close.MouseButton1Click:Connect(function()
    if _G.WH01_SHUTDOWN_TEMPLATE then pcall(_G.WH01_SHUTDOWN_TEMPLATE); _G.WH01_SHUTDOWN_TEMPLATE=nil end
    tw(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)})
    task.delay(0.35,function() gui:Destroy() end)
end)

local miniW=isMobile and 220 or 280
minimize.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        clearParticles()
        task.delay(0.02,function()
            if body then body.Visible=false end
            statusLabel.Visible=false; bgImage.Visible=false
        end)
        tw(root,T_SMOOTH,{Size=UDim2.new(0,miniW,0,HDR_H)}); minimize.Text="▢"
        if gameName then titleLabel.Text=gameName end
    else
        tw(root,T_SMOOTH,{Size=UDim2.new(0,UI_W,0,UI_H)})
        if gameName then titleLabel.Text="WH01  ·  "..gameName end
        task.delay(0.35,function()
            if body then body.Visible=true end
            statusLabel.Visible=true; bgImage.Visible=true; minimize.Text="—"
            local th=themes[config.theme]
            if th.snow then startSnow() elseif th.valentine then startValentine() elseif th.garden then startGarden() end
        end)
    end
end)

--====================================================
-- BODY
--====================================================
body=Instance.new("Frame"); body.Parent=root
body.Size=UDim2.new(1,0,1,-(HDR_H+2)); body.Position=UDim2.new(0,0,0,HDR_H+2)
body.BackgroundTransparency=1; body.ZIndex=2

--====================================================
-- SIDEBAR
--====================================================
sidebar=Instance.new("Frame"); sidebar.Parent=body
sidebar.Size=UDim2.new(0,SIDEBAR_W,1,0)
sidebar.BackgroundColor3=themes[config.theme].sidebar
sidebar.BackgroundTransparency=0.15; sidebar.BorderSizePixel=0; sidebar.ZIndex=3
local sdc=Instance.new("UICorner",sidebar); sdc.CornerRadius=UDim.new(0,20)

sidebarTopCover=Instance.new("Frame"); sidebarTopCover.Parent=sidebar
sidebarTopCover.Size=UDim2.new(1,0,0,22); sidebarTopCover.BackgroundColor3=themes[config.theme].sidebar
sidebarTopCover.BackgroundTransparency=0.15; sidebarTopCover.BorderSizePixel=0; sidebarTopCover.ZIndex=3

sideDiv=Instance.new("Frame"); sideDiv.Parent=body
sideDiv.Size=UDim2.new(0,1,1,0); sideDiv.Position=UDim2.new(0,SIDEBAR_W,0,0)
sideDiv.BackgroundColor3=themes[config.theme].stroke
sideDiv.BackgroundTransparency=0.9; sideDiv.BorderSizePixel=0; sideDiv.ZIndex=4

--====================================================
-- CONTENT AREA
--====================================================
local contentPad=SIDEBAR_W+8
contentArea=Instance.new("ScrollingFrame"); contentArea.Parent=body
contentArea.Size=UDim2.new(1,-(contentPad+6),1,-12); contentArea.Position=UDim2.new(0,contentPad,0,6)
contentArea.BackgroundTransparency=1; contentArea.ZIndex=3
contentArea.ScrollBarThickness=isMobile and 2 or 3
contentArea.ScrollBarImageColor3=themes[config.theme].accent; contentArea.ScrollBarImageTransparency=0.3
contentArea.CanvasSize=UDim2.new(0,0,0,0); contentArea.ClipsDescendants=true; contentArea.BorderSizePixel=0
contentArea.TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
contentArea.MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
contentArea.BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scrollBars, contentArea)

--====================================================
-- PAGES
--====================================================
local function makePage()
    local p=Instance.new("Frame"); p.Parent=contentArea
    p.Size=UDim2.fromScale(1,0); p.AutomaticSize=Enum.AutomaticSize.Y
    p.BackgroundTransparency=1; p.Visible=false; p.ZIndex=4
    local pad=Instance.new("UIPadding",p)
    pad.PaddingLeft=UDim.new(0,6); pad.PaddingRight=UDim.new(0,6)
    return p
end

local mainPage      = makePage(); mainPage.Visible=true
local micsPage      = makePage()
local settingsPage  = makePage()
local teleportsPage = makePage()
local otherPage     = makePage()

local function updateCanvasSize(page)
    local maxY=0
    for _,child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") then
            local bottom=child.Position.Y.Offset+child.Size.Y.Offset
            if bottom>maxY then maxY=bottom end
        end
    end
    contentArea.CanvasSize=UDim2.new(0,0,0,maxY+20)
end

mainPage:GetPropertyChangedSignal("Visible"):Connect(function() if mainPage.Visible then updateCanvasSize(mainPage) end end)
micsPage:GetPropertyChangedSignal("Visible"):Connect(function() if micsPage.Visible then updateCanvasSize(micsPage) end end)
settingsPage:GetPropertyChangedSignal("Visible"):Connect(function() if settingsPage.Visible then updateCanvasSize(settingsPage) end end)
teleportsPage:GetPropertyChangedSignal("Visible"):Connect(function() if teleportsPage.Visible then updateCanvasSize(teleportsPage) end end)
otherPage:GetPropertyChangedSignal("Visible"):Connect(function() if otherPage.Visible then updateCanvasSize(otherPage) end end)

--====================================================
-- WIDGET HELPERS
--====================================================
local function secLabel(parent,text,yp)
    local l=Instance.new("TextLabel"); l.Parent=parent
    l.Size=UDim2.new(1,0,0,16); l.Position=UDim2.new(0,2,0,yp)
    l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBold
    l.TextSize=FONT_SM; l.TextColor3=themes[config.theme].subtext
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
    table.insert(textSub,l); table.insert(fontObjs,l); return l
end

local function checkbox(parent,text,yp,defaultOn)
    local t=themes[config.theme]; local state=defaultOn or false
    local row=Instance.new("Frame"); row.Parent=parent
    row.Size=UDim2.new(1,0,0,ROW_H); row.Position=UDim2.new(0,0,0,yp)
    row.BackgroundColor3=t.row; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.ZIndex=5
    local rc2=Instance.new("UICorner",row); rc2.CornerRadius=UDim.new(0,ROW_R)
    local rs=Instance.new("UIStroke",row); rs.Color=t.stroke; rs.Transparency=0.93
    table.insert(rows,{frame=row,stroke=rs})
    local lbl=Instance.new("TextLabel"); lbl.Parent=row
    lbl.Size=UDim2.new(1,-50,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold
    lbl.TextSize=FONT_MD; lbl.TextColor3=t.text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    table.insert(textMain,lbl); table.insert(fontObjs,lbl)
    local boxSz=isMobile and 20 or 22
    local box=Instance.new("Frame"); box.Parent=row
    box.Size=UDim2.new(0,boxSz,0,boxSz); box.Position=UDim2.new(1,-(boxSz+10),0.5,-(boxSz/2))
    box.BackgroundColor3=state and t.accent or t.row; box.BorderSizePixel=0; box.ZIndex=6
    local bc2=Instance.new("UICorner",box); bc2.CornerRadius=UDim.new(0,7)
    local bs=Instance.new("UIStroke",box); bs.Color=t.stroke; bs.Transparency=0.7
    local chk=Instance.new("TextLabel"); chk.Parent=box
    chk.Size=UDim2.fromScale(1,1); chk.BackgroundTransparency=1
    chk.Text="✓"; chk.Font=Enum.Font.GothamBold; chk.TextSize=13
    chk.TextColor3=t.primary; chk.Visible=state; chk.ZIndex=7
    table.insert(checkBoxes,{box=box,chk=chk,stroke=bs,getState=function() return state end})
    local overridden=false
    local btn=Instance.new("TextButton"); btn.Parent=row
    btn.Size=UDim2.fromScale(1,1); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=8
    btn.MouseEnter:Connect(function()
        tw(row,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.4})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].primary})
    end)
    btn.MouseLeave:Connect(function()
        tw(row,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].text})
    end)
    btn.MouseButton1Click:Connect(function()
        if overridden then overridden=false; return end
        state=not state; chk.Visible=state
        tw(box,T_FAST,{BackgroundColor3=state and themes[config.theme].accent or themes[config.theme].row})
        statusLabel.Text="● "..text..": "..(state and "ON" or "OFF")
    end)
    local function forceOff()
        if state then overridden=true end
        state=false; chk.Visible=false; tw(box,T_FAST,{BackgroundColor3=themes[config.theme].row})
    end
    return btn, function() return state end, forceOff
end

local function slider(parent,labelText,yp,minVal,maxVal,defaultVal,onChange)
    local t=themes[config.theme]; local currentVal=defaultVal or minVal
    local sliderRowH=isMobile and 50 or 54
    local row=Instance.new("Frame"); row.Parent=parent
    row.Size=UDim2.new(1,0,0,sliderRowH); row.Position=UDim2.new(0,0,0,yp)
    row.BackgroundColor3=t.row; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.ZIndex=5
    local rowc=Instance.new("UICorner",row); rowc.CornerRadius=UDim.new(0,ROW_R)
    local rows2=Instance.new("UIStroke",row); rows2.Color=t.stroke; rows2.Transparency=0.93
    table.insert(rows,{frame=row,stroke=rows2})
    local nameLbl=Instance.new("TextLabel"); nameLbl.Parent=row
    nameLbl.Size=UDim2.new(1,-65,0,16); nameLbl.Position=UDim2.new(0,12,0,6)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=labelText
    nameLbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; nameLbl.TextSize=FONT_MD
    nameLbl.TextColor3=t.text; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=6
    table.insert(textMain,nameLbl); table.insert(fontObjs,nameLbl)
    local valLbl=Instance.new("TextLabel"); valLbl.Parent=row
    valLbl.Size=UDim2.new(0,50,0,16); valLbl.Position=UDim2.new(1,-60,0,6)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(math.floor(currentVal))
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=FONT_MD
    valLbl.TextColor3=t.accent; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=6
    table.insert(textMain,valLbl)
    local trackTop=isMobile and 34 or 36
    local track=Instance.new("Frame"); track.Parent=row
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,trackTop)
    track.BackgroundColor3=t.row; track.BorderSizePixel=0; track.ZIndex=6
    local trackc=Instance.new("UICorner",track); trackc.CornerRadius=UDim.new(1,0)
    local trackStroke=Instance.new("UIStroke",track); trackStroke.Color=t.stroke; trackStroke.Transparency=0.85
    table.insert(rows,{frame=track,stroke=trackStroke})
    local ratio=(currentVal-minVal)/(maxVal-minVal)
    local fill=Instance.new("Frame"); fill.Parent=track
    fill.Size=UDim2.new(ratio,0,1,0); fill.BackgroundColor3=t.accent; fill.BorderSizePixel=0; fill.ZIndex=7
    local fillc=Instance.new("UICorner",fill); fillc.CornerRadius=UDim.new(1,0)
    local knobSz=isMobile and 20 or 16
    local knob=Instance.new("Frame"); knob.Parent=track
    knob.Size=UDim2.new(0,knobSz,0,knobSz); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(ratio,0,0.5,0); knob.BackgroundColor3=t.accent; knob.BorderSizePixel=0; knob.ZIndex=8
    local knobC=Instance.new("UICorner",knob); knobC.CornerRadius=UDim.new(1,0)
    local knobDot=Instance.new("Frame"); knobDot.Parent=knob
    knobDot.Size=UDim2.new(0,6,0,6); knobDot.AnchorPoint=Vector2.new(0.5,0.5); knobDot.Position=UDim2.new(0.5,0,0.5,0)
    knobDot.BackgroundColor3=Color3.fromRGB(255,255,255); knobDot.BackgroundTransparency=0.4; knobDot.BorderSizePixel=0; knobDot.ZIndex=9
    local kdC=Instance.new("UICorner",knobDot); kdC.CornerRadius=UDim.new(1,0)
    table.insert(sliderObjs,{track=track,fill=fill,knob=knob,stroke=trackStroke,valLbl=valLbl,nameLbl=nameLbl})
    local function updateSlider(newVal,smooth)
        newVal=math.clamp(newVal,minVal,maxVal); currentVal=newVal
        local r=(newVal-minVal)/(maxVal-minVal)
        local ti=smooth and TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) or TweenInfo.new(0)
        tw(fill,ti,{Size=UDim2.new(r,0,1,0)}); tw(knob,ti,{Position=UDim2.new(r,0,0.5,0)})
        valLbl.Text=tostring(math.floor(newVal)); if onChange then onChange(newVal) end
    end
    local hitH=isMobile and 40 or 28
    local trackBtn=Instance.new("TextButton"); trackBtn.Parent=track
    trackBtn.Size=UDim2.new(1,0,0,hitH); trackBtn.Position=UDim2.new(0,0,0.5,-hitH/2)
    trackBtn.BackgroundTransparency=1; trackBtn.Text=""; trackBtn.ZIndex=10
    local function beginSlider(posX)
        sliderTouchDown=true
        activeSlider={track=track,minVal=minVal,maxVal=maxVal,label=labelText,update=updateSlider}
        local r=math.clamp((posX-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        updateSlider(minVal+r*(maxVal-minVal),true)
        statusLabel.Text="● "..labelText..": "..tostring(math.floor(currentVal))
    end
    trackBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then beginSlider(inp.Position.X) end
    end)
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliderTouchDown=true; activeSlider={track=track,minVal=minVal,maxVal=maxVal,label=labelText,update=updateSlider}
        end
    end)
    trackBtn.MouseEnter:Connect(function()
        tw(knob,T_FAST,{Size=UDim2.new(0,knobSz+2,0,knobSz+2)})
        tw(row,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.4})
        tw(nameLbl,T_FAST,{TextColor3=themes[config.theme].primary}); tw(valLbl,T_FAST,{TextColor3=themes[config.theme].primary})
    end)
    trackBtn.MouseLeave:Connect(function()
        if not activeSlider then
            tw(knob,T_FAST,{Size=UDim2.new(0,knobSz,0,knobSz)})
            tw(row,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
            tw(nameLbl,T_FAST,{TextColor3=themes[config.theme].text}); tw(valLbl,T_FAST,{TextColor3=themes[config.theme].accent})
        end
    end)
    return row, function() return currentVal end, updateSlider
end

local function actionButton(parent,text,yp)
    local t=themes[config.theme]
    local btn=Instance.new("TextButton"); btn.Parent=parent
    btn.Size=UDim2.new(1,0,0,ROW_H); btn.Position=UDim2.new(0,0,0,yp)
    btn.Text=""; btn.BackgroundColor3=t.row; btn.BackgroundTransparency=0.2; btn.AutoButtonColor=false; btn.ZIndex=5
    local bc2=Instance.new("UICorner",btn); bc2.CornerRadius=UDim.new(0,ROW_R)
    local bs=Instance.new("UIStroke",btn); bs.Color=t.stroke; bs.Transparency=0.93
    table.insert(rows,{frame=btn,stroke=bs})
    local lbl=Instance.new("TextLabel"); lbl.Parent=btn
    lbl.Size=UDim2.new(1,-28,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; lbl.TextSize=FONT_MD
    lbl.TextColor3=t.text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    table.insert(textMain,lbl); table.insert(fontObjs,lbl)
    local arr=Instance.new("TextLabel"); arr.Parent=btn
    arr.Size=UDim2.new(0,20,0,20); arr.Position=UDim2.new(1,-26,0.5,-10)
    arr.BackgroundTransparency=1; arr.Text="→"; arr.Font=Enum.Font.GothamBold
    arr.TextSize=14; arr.TextColor3=t.subtext; arr.ZIndex=6
    table.insert(textSub,arr)
    btn.MouseEnter:Connect(function()
        tw(btn,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.4})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].primary}); tw(arr,T_FAST,{TextColor3=themes[config.theme].primary,Position=UDim2.new(1,-21,0.5,-10)})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].text}); tw(arr,T_FAST,{TextColor3=themes[config.theme].subtext,Position=UDim2.new(1,-26,0.5,-10)})
    end)
    btn.MouseButton1Down:Connect(function() tw(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,-4,0,ROW_H-2)}) end)
    btn.MouseButton1Up:Connect(function() tw(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,0,0,ROW_H)}) end)
    return btn
end

local activeDD=nil
local function dropdown(parent,labelText,options,currentVal,yp,onChange)
    local t=themes[config.theme]
    local cont=Instance.new("Frame"); cont.Parent=parent
    cont.Size=UDim2.new(1,0,0,40); cont.Position=UDim2.new(0,0,0,yp)
    cont.BackgroundTransparency=1; cont.ZIndex=8; cont.ClipsDescendants=false
    local mr=Instance.new("Frame"); mr.Parent=cont
    mr.Size=UDim2.new(1,0,0,40); mr.BackgroundColor3=t.row
    mr.BackgroundTransparency=0.25; mr.BorderSizePixel=0; mr.ZIndex=8
    local mrc=Instance.new("UICorner",mr); mrc.CornerRadius=UDim.new(0,ROW_R)
    local mrs=Instance.new("UIStroke",mr); mrs.Color=t.stroke; mrs.Transparency=0.88
    table.insert(dropRows,{frame=mr,stroke=mrs})
    local pl=Instance.new("TextLabel"); pl.Parent=mr
    pl.Size=UDim2.new(0,85,1,0); pl.Position=UDim2.new(0,12,0,0)
    pl.BackgroundTransparency=1; pl.Text=labelText..":"
    pl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; pl.TextSize=FONT_SM
    pl.TextColor3=t.subtext; pl.TextXAlignment=Enum.TextXAlignment.Left; pl.ZIndex=9
    table.insert(textSub,pl); table.insert(fontObjs,pl)
    local vl=Instance.new("TextLabel"); vl.Parent=mr
    vl.Size=UDim2.new(1,-125,1,0); vl.Position=UDim2.new(0,100,0,0)
    vl.BackgroundTransparency=1; vl.Text=currentVal
    vl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; vl.TextSize=FONT_MD
    vl.TextColor3=t.text; vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ZIndex=9
    table.insert(textMain,vl); table.insert(fontObjs,vl)
    local al=Instance.new("TextLabel"); al.Parent=mr
    al.Size=UDim2.new(0,24,1,0); al.Position=UDim2.new(1,-28,0,0)
    al.BackgroundTransparency=1; al.Text="▼"; al.Font=Enum.Font.GothamBold
    al.TextSize=10; al.TextColor3=t.subtext; al.ZIndex=9
    table.insert(textSub,al)
    local dl=Instance.new("Frame"); dl.Parent=cont
    dl.Size=UDim2.new(1,0,0,#options*34+8); dl.Position=UDim2.new(0,0,0,44)
    dl.BackgroundColor3=t.secondary; dl.BackgroundTransparency=0.05; dl.BorderSizePixel=0; dl.Visible=false; dl.ZIndex=20
    local dlc=Instance.new("UICorner",dl); dlc.CornerRadius=UDim.new(0,ROW_R)
    local dls=Instance.new("UIStroke",dl); dls.Color=t.stroke; dls.Transparency=0.85
    table.insert(dropLists,{frame=dl,stroke=dls})
    for i,opt in ipairs(options) do
        local ob=Instance.new("TextButton"); ob.Parent=dl
        ob.Size=UDim2.new(1,-8,0,28); ob.Position=UDim2.new(0,4,0,4+(i-1)*32)
        ob.Text=opt; ob.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; ob.TextSize=FONT_MD
        ob.TextColor3=(opt==currentVal) and t.accent or t.text
        ob.BackgroundColor3=t.row; ob.BackgroundTransparency=(opt==currentVal) and 0.4 or 0.85
        ob.AutoButtonColor=false; ob.ZIndex=21
        local obc=Instance.new("UICorner",ob); obc.CornerRadius=UDim.new(0,10)
        table.insert(fontObjs,ob)
        ob.MouseEnter:Connect(function() tw(ob,T_FAST,{BackgroundTransparency=0.3}) end)
        ob.MouseLeave:Connect(function() tw(ob,T_FAST,{BackgroundTransparency=(ob.Text==vl.Text) and 0.4 or 0.85}) end)
        ob.MouseButton1Click:Connect(function()
            vl.Text=opt; dl.Visible=false; activeDD=nil; tw(al,T_FAST,{Rotation=0})
            if onChange then onChange(opt) end; statusLabel.Text="● "..labelText..": "..opt
        end)
    end
    local tb=Instance.new("TextButton"); tb.Parent=mr
    tb.Size=UDim2.fromScale(1,1); tb.BackgroundTransparency=1; tb.Text=""; tb.ZIndex=10
    tb.MouseButton1Click:Connect(function()
        if activeDD and activeDD~=dl then activeDD.Visible=false; activeDD=nil end
        dl.Visible=not dl.Visible; activeDD=dl.Visible and dl or nil; tw(al,T_FAST,{Rotation=dl.Visible and 180 or 0})
    end)
    return cont
end

--====================================================
-- NOTIFICATION HELPER
--====================================================
local currentNotif = nil
local notifTimer   = nil

local function showNotif(title,message,isError)
    if notifTimer then task.cancel(notifTimer) end
    if currentNotif and currentNotif.Parent then pcall(function() currentNotif:Destroy() end) end
    local t=themes[config.theme]
    local notif=Instance.new("Frame"); notif.Parent=gui
    notif.Size=UDim2.new(0,240,0,65); notif.Position=UDim2.new(0,-260,0,100)
    notif.BackgroundColor3=t.primary; notif.BackgroundTransparency=0.08; notif.BorderSizePixel=0; notif.ZIndex=100; notif.ClipsDescendants=true
    local nc=Instance.new("UICorner",notif); nc.CornerRadius=UDim.new(0,16)
    local notifBg=Instance.new("ImageLabel"); notifBg.Parent=notif
    notifBg.Size=UDim2.new(1,0,1,0); notifBg.BackgroundTransparency=1
    notifBg.Image="rbxassetid://"..t.bgId
    notifBg.ScaleType=Enum.ScaleType.Crop; notifBg.ImageTransparency=0.85; notifBg.ZIndex=101
    local nbic=Instance.new("UICorner"); nbic.CornerRadius=UDim.new(0,16); nbic.Parent=notifBg
    local ns=Instance.new("UIStroke",notif)
    ns.Color=isError and Color3.fromRGB(220,60,60) or t.stroke; ns.Transparency=0.5; ns.Thickness=1.2
    local tl=Instance.new("TextLabel"); tl.Parent=notif
    tl.Size=UDim2.new(1,-14,0,20); tl.Position=UDim2.new(0,10,0,7)
    tl.BackgroundTransparency=1; tl.Text=title; tl.Font=Enum.Font.GothamBold; tl.TextSize=12
    tl.TextColor3=isError and Color3.fromRGB(220,60,60) or t.accent; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=102
    local ml=Instance.new("TextLabel"); ml.Parent=notif
    ml.Size=UDim2.new(1,-14,0,28); ml.Position=UDim2.new(0,10,0,28)
    ml.BackgroundTransparency=1; ml.Text=message; ml.Font=Enum.Font.GothamMedium; ml.TextSize=10
    ml.TextColor3=t.text; ml.TextWrapped=true; ml.TextXAlignment=Enum.TextXAlignment.Left; ml.ZIndex=102
    currentNotif = notif
    tw(notif,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,10,0,100)})
    notifTimer = task.delay(3.5,function()
        if notif and notif.Parent then
            tw(notif,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0,-260,0,100)})
            task.delay(0.35,function() if notif and notif.Parent then notif:Destroy() end end)
        end
        currentNotif = nil
    end)
end

--====================================================
-- SELL LOGIC
--====================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sellRemote = nil
local SELL_POSITION = Vector3.new(149.39, 204.01, 671.99)
local initialPosition = nil

local function getEquippedTool()
    local character = Players.LocalPlayer.Character
    if not character then return nil end
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

local function teleportTo(position)
    local character = Players.LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(position); return true end
    return false
end

--====================================================
-- ★ PLANT LOGIC (portado del script separado) ★
--====================================================
local plantRemote      = nil
local isPlanting       = false
local plantThread_main = nil
local plantPanelOpen   = false
local selectedPlantSeeds = {}   -- plantType → bool
local seedRowData        = {}   -- plantType → { frame, box, chk, nameLbl }

local ALL_SEEDS = {
    "Wheat","Amberpine","Apple","Banana","Beetroot","Bellpepper",
    "Birch","Cabbage","Carrot","Cherry","Corn","Dandelion",
    "Dawnblossom","Dawnfruit","Emberwood","Goldenberry","Mushroom",
    "Olive","Onion","Orange","Plum","Pomaganit","Potato","Rose",
    "Strawberry","Sunpetal","Tomato",
}

local SEED_EMOJI = {
    Wheat="🌾",  Amberpine="🌲", Apple="🍎",   Banana="🍌",
    Beetroot="🫚", Bellpepper="🫑", Birch="🌳",  Cabbage="🥬",
    Carrot="🥕",  Cherry="🍒",   Corn="🌽",    Dandelion="🌼",
    Dawnblossom="🌸", Dawnfruit="🍑", Emberwood="🔥", Goldenberry="✨",
    Mushroom="🍄", Olive="🫒",   Onion="🧅",   Orange="🍊",
    Plum="🍇",    Pomaganit="🌺", Potato="🥔",  Rose="🌹",
    Strawberry="🍓", Sunpetal="🌻", Tomato="🍅",
}

-- Extrae PlantType de una herramienta del backpack
local function getPlantTypeFromTool(tool)
    if not tool:IsA("Tool") then return nil end
    local pt = tool:GetAttribute("PlantType")
    if pt and pt ~= "" then return pt end
    local bn = tool:GetAttribute("BaseName")
    if bn then
        local stripped = bn:match("^(.+)%s+Seed$")
        if stripped then return stripped end
    end
    local name  = tool.Name
    local clean = name:match("^x%d+%s+(.+)$") or name
    return clean:match("^(.+)%s+Seed$")
end

-- Retorna seeds disponibles en el backpack  →  { [plantType] = { tool, count } }
local function getSeedsInBackpack()
    local found = {}
    local function checkTool(tool)
        if tool:GetAttribute("IsHarvested")  then return end
        if tool:GetAttribute("HarvestedFrom") then return end
        if tool:GetAttribute("FruitValue")    then return end
        local pt = getPlantTypeFromTool(tool)
        if not pt then return end
        local valid = false
        for _, k in ipairs(ALL_SEEDS) do if k == pt then valid=true; break end end
        if not valid then return end
        local count = tool:GetAttribute("ItemCount") or 1
        if not found[pt] then
            found[pt] = { tool=tool, count=count }
        else
            found[pt].count = found[pt].count + count
        end
    end
    for _, t in ipairs(Players.LocalPlayer.Backpack:GetChildren()) do pcall(checkTool, t) end
    local char = Players.LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then pcall(checkTool, t) end
        end
    end
    return found
end

-- Equipa una seed al personaje
local function equipPlantSeed(plantType)
    for _, tool in ipairs(Players.LocalPlayer.Backpack:GetChildren()) do
        if getPlantTypeFromTool(tool) == plantType then
            local char = Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(tool); return true end
            end
        end
    end
    -- Ya equipada
    local char = Players.LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and getPlantTypeFromTool(t) == plantType then return true end
        end
    end
    return false
end

-- Posición aleatoria alrededor del jugador
local function getPlantPosition(radius)
    local hrp = Players.LocalPlayer.Character and
                Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local angle = math.random() * 2 * math.pi
    local r = math.random() * (radius or 25)
    return hrp.Position + Vector3.new(math.cos(angle)*r, 0, math.sin(angle)*r)
end

--====================================================
-- ★ MAIN PAGE
--====================================================
secLabel(mainPage,"SELL OPTIONS",0)

local option1Btn, getOption1, forceOffOption1 = checkbox(mainPage,"Sell Single",62,false)
local selling = false

option1Btn.MouseButton1Click:Connect(function()
    local isNowOn = getOption1()
    if not isNowOn then
        if selling then return end
        selling = true
        task.spawn(function()
            local tool = getEquippedTool()
            if not tool then
                showNotif("Sell Single","⚠️ Nothing TO sell",true)
                statusLabel.Text="● Sell Single: Nothing To Sell"
                selling = false; task.wait(2.5); forceOffOption1(); return
            end
            showNotif("Sell Single","🛒 Plant Found: "..tool.Name,false)
            statusLabel.Text="● Sell Single: Saving..."
            initialPosition = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
            local initialMoney = 0
            pcall(function() initialMoney = Players.LocalPlayer.leaderstats.Shillings.Value end)
            task.wait(0.3)
            if not selling then showNotif("Sell Single","⏹️ Cancelled",false); selling=false; return end
            statusLabel.Text="● Sell Single: TP"
            if not teleportTo(SELL_POSITION) then
                showNotif("Sell Single","❌ Error At TP",true)
                statusLabel.Text="● Sell Single: Error"
                selling=false; task.wait(2.5); forceOffOption1(); return
            end
            task.wait(0.6)
            if not selling then
                showNotif("Sell Single","⏹️ Cancelled",false); statusLabel.Text="● Sell Single: Cancelled"
                if initialPosition then teleportTo(initialPosition) end; selling=false; return
            end
            pcall(function()
                if not sellRemote then
                    local remEv = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if remEv then sellRemote = remEv:FindFirstChild("SellItems") end
                end
                if not sellRemote then
                    showNotif("Sell Single","❌ SellItems remote not found",true)
                    selling=false; task.wait(1.5); forceOffOption1(); return
                end
                statusLabel.Text="● Sell Single: Selling"
                local sellIsFn = sellRemote:IsA("RemoteFunction")
                if sellIsFn then sellRemote:InvokeServer("SellSingle")
                else sellRemote:FireServer("SellSingle") end
                task.wait(0.4)
                if initialPosition then statusLabel.Text="● Sell Single: Returning..."; teleportTo(initialPosition); task.wait(0.3) end
                local finalMoney = 0
                pcall(function() finalMoney = Players.LocalPlayer.leaderstats.Shillings.Value end)
                local earned = finalMoney - initialMoney
                showNotif("Sell Single","📦 Sell Complete | +$"..tostring(earned),false)
                statusLabel.Text="● Sell Single: Complete | Earned: $"..tostring(earned)
                selling=false; task.wait(2.5); forceOffOption1()
            end)
        end)
    else
        selling=false; statusLabel.Text="● Sell Single: Cancelled"
        if initialPosition then teleportTo(initialPosition) end
    end
end)

local option2Btn, getOption2, forceOffOption2 = checkbox(mainPage,"Sell All",20,false)
local sellAllFlag = false

local blacklist = {"Basic Sprinkler","Turbo Sprinkler","Super Sprinkler","Favorite Tool","Harvest Bell","Watering Can","Shovel"}
local function isBlacklisted(toolName)
    for _, n in ipairs(blacklist) do if string.find(toolName, n) then return true end end
    return false
end
local function getBackpackTools()
    local backpack = Players.LocalPlayer:FindFirstChild("Backpack"); local validTools = {}
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and not isBlacklisted(tool.Name) then table.insert(validTools, tool) end
        end
    end
    return validTools
end

option2Btn.MouseButton1Click:Connect(function()
    local isNowOn = getOption2()
    if not isNowOn then
        if sellAllFlag then return end; sellAllFlag=true
        task.spawn(function()
            local validTools = getBackpackTools()
            if #validTools == 0 then
                showNotif("Sell All","⚠️ Nothing TO sell",true); statusLabel.Text="● Sell All: Nothing To Sell"
                sellAllFlag=false; task.wait(2.5); forceOffOption2(); return
            end
            showNotif("Sell All","🛒 Found "..#validTools.." items",false)
            statusLabel.Text="● Sell All: Saving..."
            initialPosition = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
            local initialMoney = 0
            pcall(function() initialMoney = Players.LocalPlayer.leaderstats.Shillings.Value end)
            task.wait(0.3)
            if not sellAllFlag then showNotif("Sell All","⏹️ Cancelled",false); sellAllFlag=false; return end
            statusLabel.Text="● Sell All: TP"
            if not teleportTo(SELL_POSITION) then
                showNotif("Sell All","❌ Error At TP",true); statusLabel.Text="● Sell All: Error"
                sellAllFlag=false; task.wait(2.5); forceOffOption2(); return
            end
            task.wait(0.6)
            if not sellAllFlag then
                showNotif("Sell All","⏹️ Cancelled",false); statusLabel.Text="● Sell All: Cancelled"
                if initialPosition then teleportTo(initialPosition) end; sellAllFlag=false; return
            end
            pcall(function()
                if not sellRemote then
                    local remEv = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if remEv then sellRemote = remEv:FindFirstChild("SellItems") end
                end
                if not sellRemote then
                    showNotif("Sell All","❌ SellItems remote not found",true)
                    sellAllFlag=false; task.wait(1.5); forceOffOption2(); return
                end
                local sellIsFn = sellRemote:IsA("RemoteFunction")
                statusLabel.Text="● Sell All: Selling"
                if sellIsFn then sellRemote:InvokeServer("SellAll")
                else sellRemote:FireServer("SellAll") end
                task.wait(0.4)
                if initialPosition then statusLabel.Text="● Sell All: Returning..."; teleportTo(initialPosition); task.wait(0.3) end
                local finalMoney = 0
                pcall(function() finalMoney = Players.LocalPlayer.leaderstats.Shillings.Value end)
                local earned = finalMoney - initialMoney
                showNotif("Sell All","📦 Sell Complete | +$"..tostring(earned),false)
                statusLabel.Text="● Sell All: Complete | "..tostring(earned)
                sellAllFlag=false; task.wait(2.5); forceOffOption2()
            end)
        end)
    else
        sellAllFlag=false; statusLabel.Text="● Sell All: Cancelled"
        if initialPosition then teleportTo(initialPosition) end
    end
end)

secLabel(mainPage,"ACTIONS",108)

local actionBtn1 = actionButton(mainPage,"Action 1",126)
actionBtn1.MouseButton1Click:Connect(function()
    statusLabel.Text="● Action 1 pressed"; showNotif("Action 1","Button pressed!",false)
end)

local actionBtn2 = actionButton(mainPage,"Action 2",126 + ROW_H + 8)
actionBtn2.MouseButton1Click:Connect(function()
    statusLabel.Text="● Action 2 pressed"; showNotif("Action 2","Second button pressed!",false)
end)

--====================================================
-- ★ PLANT OPTIONS — integración en mainPage ★
--====================================================

-- ── Constantes de layout ─────────────────────────────────────
local PLANT_SEC_Y       = 226           -- secLabel
local PLANT_CB_Y        = PLANT_SEC_Y + 20           -- 246  toggle principal
local CHOOSE_Y          = PLANT_CB_Y + ROW_H + 8     -- 292  botón "Choose Seeds"
local CHOOSE_H          = 44
local PANEL_Y           = CHOOSE_Y + CHOOSE_H + 4    -- 340  panel expandible
local PANEL_OPEN_H      = 168           -- altura cuando está abierto
local PLANTALL_Y_CLOSED = PANEL_Y + 8  -- 348  botón Plant All (panel cerrado)
local PLANTALL_Y_OPEN   = PANEL_Y + PANEL_OPEN_H + 8 -- 516  (panel abierto)

-- ── 1. Etiqueta de sección ───────────────────────────────────
secLabel(mainPage,"PLANT OPTIONS", PLANT_SEC_Y)

-- ── 2. Toggle maestro "Plant Seeds" ─────────────────────────
local plantSeedsBtn, getPlantSeedsState, forceOffPlantSeeds =
    checkbox(mainPage, "Plant Seeds", PLANT_CB_Y, false)

-- ── 3. Botón "Choose Seeds" (expandible) ────────────────────
local t0 = themes[config.theme]

local chooseCont = Instance.new("Frame"); chooseCont.Parent = mainPage
chooseCont.Size            = UDim2.new(1, 0, 0, CHOOSE_H)
chooseCont.Position        = UDim2.new(0, 0, 0, CHOOSE_Y)
chooseCont.BackgroundColor3 = t0.row; chooseCont.BackgroundTransparency = 0.2
chooseCont.BorderSizePixel = 0; chooseCont.ZIndex = 5
local chooseCorner  = Instance.new("UICorner", chooseCont); chooseCorner.CornerRadius = UDim.new(0, ROW_R)
local chooseStroke_ = Instance.new("UIStroke", chooseCont); chooseStroke_.Color = t0.stroke; chooseStroke_.Transparency = 0.88
table.insert(rows, {frame=chooseCont, stroke=chooseStroke_})

-- Ícono de hoja
local chooseIco = Instance.new("TextLabel"); chooseIco.Parent = chooseCont
chooseIco.Size = UDim2.new(0, 22, 0, 22); chooseIco.Position = UDim2.new(0, 10, 0.5, -11)
chooseIco.BackgroundTransparency = 1; chooseIco.Text = "🌱"
chooseIco.Font = Enum.Font.Gotham; chooseIco.TextSize = 14
chooseIco.TextColor3 = t0.text; chooseIco.ZIndex = 6

local chooseLbl_ = Instance.new("TextLabel"); chooseLbl_.Parent = chooseCont
chooseLbl_.Size = UDim2.new(1,-90,0,18); chooseLbl_.Position = UDim2.new(0,36,0,6)
chooseLbl_.BackgroundTransparency = 1; chooseLbl_.Text = "Choose Seeds"
chooseLbl_.Font = fonts[config.fontStyle] or Enum.Font.GothamBold
chooseLbl_.TextSize = FONT_MD; chooseLbl_.TextColor3 = t0.text
chooseLbl_.TextXAlignment = Enum.TextXAlignment.Left; chooseLbl_.ZIndex = 6
table.insert(textMain, chooseLbl_); table.insert(fontObjs, chooseLbl_)

local chooseSubLbl_ = Instance.new("TextLabel"); chooseSubLbl_.Parent = chooseCont
chooseSubLbl_.Size = UDim2.new(1,-90,0,13); chooseSubLbl_.Position = UDim2.new(0,36,0,24)
chooseSubLbl_.BackgroundTransparency = 1; chooseSubLbl_.Text = "Tap to select seeds"
chooseSubLbl_.Font = Enum.Font.Gotham; chooseSubLbl_.TextSize = FONT_SM-1
chooseSubLbl_.TextColor3 = t0.subtext; chooseSubLbl_.TextXAlignment = Enum.TextXAlignment.Left; chooseSubLbl_.ZIndex = 6
table.insert(textSub, chooseSubLbl_)

-- Badge con número de seeds seleccionadas
local chooseBadge = Instance.new("TextLabel"); chooseBadge.Parent = chooseCont
chooseBadge.Size = UDim2.new(0,28,0,18); chooseBadge.Position = UDim2.new(1,-62,0.5,-9)
chooseBadge.BackgroundColor3 = t0.secondary; chooseBadge.BorderSizePixel = 0
chooseBadge.Text = "0"; chooseBadge.Font = Enum.Font.GothamBold
chooseBadge.TextSize = 9; chooseBadge.TextColor3 = t0.subtext; chooseBadge.ZIndex = 6
local chooseBadgeC = Instance.new("UICorner", chooseBadge); chooseBadgeC.CornerRadius = UDim.new(0,5)

local chooseArrow_ = Instance.new("TextLabel"); chooseArrow_.Parent = chooseCont
chooseArrow_.Size = UDim2.new(0,24,0,24); chooseArrow_.Position = UDim2.new(1,-28,0.5,-12)
chooseArrow_.BackgroundTransparency = 1; chooseArrow_.Text = "▼"
chooseArrow_.Font = Enum.Font.GothamBold; chooseArrow_.TextSize = 11
chooseArrow_.TextColor3 = t0.subtext; chooseArrow_.ZIndex = 6
table.insert(textSub, chooseArrow_)

local chooseTBtn_ = Instance.new("TextButton"); chooseTBtn_.Parent = chooseCont
chooseTBtn_.Size = UDim2.fromScale(1,1); chooseTBtn_.BackgroundTransparency = 1
chooseTBtn_.Text = ""; chooseTBtn_.ZIndex = 8

-- ── 4. Panel expandible con scroll de seeds ──────────────────
local seedPanel = Instance.new("Frame"); seedPanel.Parent = mainPage
seedPanel.Size             = UDim2.new(1, 0, 0, 0)   -- empieza colapsado
seedPanel.Position         = UDim2.new(0, 0, 0, PANEL_Y)
seedPanel.BackgroundColor3 = t0.secondary; seedPanel.BackgroundTransparency = 0.08
seedPanel.BorderSizePixel  = 0; seedPanel.ClipsDescendants = true; seedPanel.ZIndex = 5
local seedPanelC  = Instance.new("UICorner", seedPanel); seedPanelC.CornerRadius = UDim.new(0, ROW_R)
local seedPanelS  = Instance.new("UIStroke", seedPanel);  seedPanelS.Color = t0.stroke; seedPanelS.Transparency = 0.82

local seedPanelScroll = Instance.new("ScrollingFrame"); seedPanelScroll.Parent = seedPanel
seedPanelScroll.Size                    = UDim2.new(1,-4,1,-4); seedPanelScroll.Position = UDim2.new(0,2,0,2)
seedPanelScroll.BackgroundTransparency  = 1; seedPanelScroll.BorderSizePixel = 0
seedPanelScroll.ScrollBarThickness      = 2; seedPanelScroll.ScrollBarImageColor3 = t0.accent
seedPanelScroll.ScrollBarImageTransparency = 0.3
seedPanelScroll.CanvasSize              = UDim2.new(0,0,0,0); seedPanelScroll.ZIndex = 6
seedPanelScroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
table.insert(scrollBars, seedPanelScroll)
local seedScrollLayout = Instance.new("UIListLayout", seedPanelScroll)
seedScrollLayout.Padding    = UDim.new(0,3); seedScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
local seedScrollPad = Instance.new("UIPadding", seedPanelScroll)
seedScrollPad.PaddingLeft  = UDim.new(0,4); seedScrollPad.PaddingRight = UDim.new(0,4)
seedScrollPad.PaddingTop   = UDim.new(0,4); seedScrollPad.PaddingBottom = UDim.new(0,4)

-- ── 5. Botón "Plant All" ─────────────────────────────────────
local plantAllBtn = Instance.new("TextButton"); plantAllBtn.Parent = mainPage
plantAllBtn.Size             = UDim2.new(1, 0, 0, ROW_H)
plantAllBtn.Position         = UDim2.new(0, 0, 0, PLANTALL_Y_CLOSED)
plantAllBtn.Text             = ""; plantAllBtn.AutoButtonColor = false; plantAllBtn.ZIndex = 5
plantAllBtn.BackgroundColor3 = t0.row; plantAllBtn.BackgroundTransparency = 0.2; plantAllBtn.BorderSizePixel = 0
local plantAllBtnC = Instance.new("UICorner", plantAllBtn); plantAllBtnC.CornerRadius = UDim.new(0, ROW_R)
local plantAllBtnS = Instance.new("UIStroke", plantAllBtn); plantAllBtnS.Color = t0.stroke; plantAllBtnS.Transparency = 0.93
table.insert(rows, {frame=plantAllBtn, stroke=plantAllBtnS})

local plantAllLbl = Instance.new("TextLabel"); plantAllLbl.Parent = plantAllBtn
plantAllLbl.Size = UDim2.new(1,-38,1,0); plantAllLbl.Position = UDim2.new(0,12,0,0)
plantAllLbl.BackgroundTransparency = 1; plantAllLbl.Text = "🌱  Plant All"
plantAllLbl.Font = fonts[config.fontStyle] or Enum.Font.GothamBold; plantAllLbl.TextSize = FONT_MD
plantAllLbl.TextColor3 = t0.text; plantAllLbl.TextXAlignment = Enum.TextXAlignment.Left; plantAllLbl.ZIndex = 6
table.insert(textMain, plantAllLbl); table.insert(fontObjs, plantAllLbl)

local plantAllArr = Instance.new("TextLabel"); plantAllArr.Parent = plantAllBtn
plantAllArr.Size = UDim2.new(0,20,0,20); plantAllArr.Position = UDim2.new(1,-26,0.5,-10)
plantAllArr.BackgroundTransparency = 1; plantAllArr.Text = "→"
plantAllArr.Font = Enum.Font.GothamBold; plantAllArr.TextSize = 14
plantAllArr.TextColor3 = t0.subtext; plantAllArr.ZIndex = 6
table.insert(textSub, plantAllArr)

plantAllBtn.MouseEnter:Connect(function()
    tw(plantAllBtn,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.4})
    tw(plantAllLbl,T_FAST,{TextColor3=themes[config.theme].primary})
    tw(plantAllArr,T_FAST,{TextColor3=themes[config.theme].primary,Position=UDim2.new(1,-21,0.5,-10)})
end)
plantAllBtn.MouseLeave:Connect(function()
    tw(plantAllBtn,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
    tw(plantAllLbl,T_FAST,{TextColor3=themes[config.theme].text})
    tw(plantAllArr,T_FAST,{TextColor3=themes[config.theme].subtext,Position=UDim2.new(1,-26,0.5,-10)})
end)
plantAllBtn.MouseButton1Down:Connect(function() tw(plantAllBtn,TweenInfo.new(0.1),{Size=UDim2.new(1,-4,0,ROW_H-2)}) end)
plantAllBtn.MouseButton1Up:Connect(function()   tw(plantAllBtn,TweenInfo.new(0.1),{Size=UDim2.new(1,0,0,ROW_H)}) end)

-- ── Helpers de selección visual en seed rows ─────────────────
local function refreshBadge()
    local n = 0
    for _, v in pairs(selectedPlantSeeds) do if v then n=n+1 end end
    chooseBadge.Text = tostring(n)
end

local function setSeedVisual(plantType, selected)
    local d = seedRowData[plantType]
    if not d then return end
    d.chk.Visible = selected
    tw(d.box, T_FAST, {BackgroundColor3 = selected and themes[config.theme].accent or themes[config.theme].row})
    tw(d.frame, T_FAST, {BackgroundColor3 = selected and themes[config.theme].accent or themes[config.theme].row,
                         BackgroundTransparency = selected and 0.35 or 0.2})
    tw(d.nameLbl, T_FAST, {TextColor3 = selected and themes[config.theme].primary or themes[config.theme].text})
end

-- ── Builder del panel de seeds ───────────────────────────────
local function buildSeedPanel()
    -- Limpiar contenido anterior
    for _, v in ipairs(seedPanelScroll:GetChildren()) do
        if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then v:Destroy() end
    end
    seedRowData = {}

    local backpackSeeds = getSeedsInBackpack()
    local t = themes[config.theme]
    local count = 0

    for _, plantType in ipairs(ALL_SEEDS) do
        if backpackSeeds[plantType] then
            count = count + 1
            local seedInfo = backpackSeeds[plantType]
            local selState = selectedPlantSeeds[plantType] or false

            -- Frame de la fila
            local row = Instance.new("Frame"); row.Parent = seedPanelScroll
            row.Size             = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = selState and t.accent or t.row
            row.BackgroundTransparency = selState and 0.35 or 0.2
            row.BorderSizePixel  = 0; row.LayoutOrder = count; row.ZIndex = 7
            local rowC = Instance.new("UICorner", row); rowC.CornerRadius = UDim.new(0, 8)
            local rowS = Instance.new("UIStroke",  row); rowS.Color = t.stroke; rowS.Transparency = 0.82
            table.insert(rows, {frame=row, stroke=rowS})

            -- Emoji
            local emo = Instance.new("TextLabel"); emo.Parent = row
            emo.Size = UDim2.new(0,22,1,0); emo.Position = UDim2.new(0,6,0,0)
            emo.BackgroundTransparency = 1; emo.Text = SEED_EMOJI[plantType] or "🌿"
            emo.Font = Enum.Font.Gotham; emo.TextSize = 14; emo.TextColor3 = t.text; emo.ZIndex = 8

            -- Nombre
            local nameLbl = Instance.new("TextLabel"); nameLbl.Parent = row
            nameLbl.Size = UDim2.new(1,-86,1,0); nameLbl.Position = UDim2.new(0,32,0,0)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = plantType
            nameLbl.Font = fonts[config.fontStyle] or Enum.Font.GothamBold; nameLbl.TextSize = FONT_MD-1
            nameLbl.TextColor3 = selState and t.primary or t.text
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 8
            table.insert(textMain, nameLbl); table.insert(fontObjs, nameLbl)

            -- Badge cantidad
            local cntBadge = Instance.new("TextLabel"); cntBadge.Parent = row
            cntBadge.Size = UDim2.new(0,32,0,16); cntBadge.Position = UDim2.new(1,-58,0.5,-8)
            cntBadge.BackgroundColor3 = t.secondary; cntBadge.BorderSizePixel = 0
            cntBadge.Text = "x"..seedInfo.count; cntBadge.Font = Enum.Font.GothamBold
            cntBadge.TextSize = 9; cntBadge.TextColor3 = t.subtext; cntBadge.ZIndex = 8
            local cntC = Instance.new("UICorner", cntBadge); cntC.CornerRadius = UDim.new(0,4)

            -- Checkbox
            local boxSz = isMobile and 18 or 20
            local box = Instance.new("Frame"); box.Parent = row
            box.Size = UDim2.new(0,boxSz,0,boxSz); box.Position = UDim2.new(1,-(boxSz+5),0.5,-(boxSz/2))
            box.BackgroundColor3 = selState and t.accent or t.row; box.BorderSizePixel = 0; box.ZIndex = 8
            local boxC = Instance.new("UICorner", box); boxC.CornerRadius = UDim.new(0,5)
            local boxS = Instance.new("UIStroke",  box); boxS.Color = t.stroke; boxS.Transparency = 0.65
            local chk = Instance.new("TextLabel"); chk.Parent = box
            chk.Size = UDim2.fromScale(1,1); chk.BackgroundTransparency = 1
            chk.Text = "✓"; chk.Font = Enum.Font.GothamBold; chk.TextSize = 11
            chk.TextColor3 = t.primary; chk.Visible = selState; chk.ZIndex = 9
            table.insert(checkBoxes, {box=box, chk=chk, stroke=boxS, getState=function() return selectedPlantSeeds[plantType] or false end})

            -- Registrar en seedRowData
            seedRowData[plantType] = {frame=row, box=box, chk=chk, nameLbl=nameLbl}

            -- Botón invisible encima
            local rowBtn = Instance.new("TextButton"); rowBtn.Parent = row
            rowBtn.Size = UDim2.fromScale(1,1); rowBtn.BackgroundTransparency = 1; rowBtn.Text = ""; rowBtn.ZIndex = 10

            rowBtn.MouseEnter:Connect(function()
                if not selectedPlantSeeds[plantType] then
                    tw(row,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.45})
                    tw(nameLbl,T_FAST,{TextColor3=themes[config.theme].primary})
                end
            end)
            rowBtn.MouseLeave:Connect(function()
                if not selectedPlantSeeds[plantType] then
                    tw(row,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
                    tw(nameLbl,T_FAST,{TextColor3=themes[config.theme].text})
                end
            end)
            rowBtn.MouseButton1Click:Connect(function()
                selectedPlantSeeds[plantType] = not (selectedPlantSeeds[plantType] or false)
                local sel = selectedPlantSeeds[plantType]
                setSeedVisual(plantType, sel)
                refreshBadge()
                statusLabel.Text = "● "..plantType..": "..(sel and "SELECTED ✓" or "DESELECTED")
            end)
        end
    end

    -- Mensaje si backpack vacío
    if count == 0 then
        local emptyLbl = Instance.new("TextLabel"); emptyLbl.Parent = seedPanelScroll
        emptyLbl.Size = UDim2.new(1,0,0,40); emptyLbl.BackgroundTransparency = 1
        emptyLbl.Text = "⚠  No seeds found in backpack"
        emptyLbl.Font = Enum.Font.Gotham; emptyLbl.TextSize = 10
        emptyLbl.TextColor3 = themes[config.theme].subtext
        emptyLbl.TextXAlignment = Enum.TextXAlignment.Center; emptyLbl.ZIndex = 7
    end

    refreshBadge()
    return count
end

-- ── Lógica de apertura / cierre del panel ────────────────────
chooseTBtn_.MouseEnter:Connect(function()
    if not plantPanelOpen then
        tw(chooseCont,T_FAST,{BackgroundColor3=themes[config.theme].accent,BackgroundTransparency=0.4})
        tw(chooseLbl_,T_FAST,{TextColor3=themes[config.theme].primary})
    end
end)
chooseTBtn_.MouseLeave:Connect(function()
    if not plantPanelOpen then
        tw(chooseCont,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
        tw(chooseLbl_,T_FAST,{TextColor3=themes[config.theme].text})
    end
end)

chooseTBtn_.MouseButton1Click:Connect(function()
    plantPanelOpen = not plantPanelOpen

    if plantPanelOpen then
        buildSeedPanel()
        -- Animar apertura (slide down)
        tw(seedPanel,
           TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
           {Size=UDim2.new(1,0,0,PANEL_OPEN_H)})
        tw(plantAllBtn, T_SMOOTH, {Position=UDim2.new(0,0,0,PLANTALL_Y_OPEN)})
        tw(chooseArrow_, T_FAST,  {Rotation=180})
        tw(chooseCont, T_FAST,
           {BackgroundColor3=themes[config.theme].accent, BackgroundTransparency=0.25})
        tw(chooseLbl_, T_FAST, {TextColor3=themes[config.theme].primary})
        task.delay(0.35, function() updateCanvasSize(mainPage) end)
    else
        -- Animar cierre
        tw(seedPanel,
           TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
           {Size=UDim2.new(1,0,0,0)})
        tw(plantAllBtn, T_SMOOTH, {Position=UDim2.new(0,0,0,PLANTALL_Y_CLOSED)})
        tw(chooseArrow_, T_FAST,  {Rotation=0})
        tw(chooseCont, T_FAST,
           {BackgroundColor3=themes[config.theme].row, BackgroundTransparency=0.2})
        tw(chooseLbl_, T_FAST, {TextColor3=themes[config.theme].text})
        task.delay(0.25, function() updateCanvasSize(mainPage) end)
    end
end)

-- ── Lógica de plantado ────────────────────────────────────────
local function stopPlanting(silent)
    isPlanting = false
    if plantThread_main then task.cancel(plantThread_main); plantThread_main = nil end
    if not silent then
        statusLabel.Text = "● Plant Seeds: Stopped"
        -- restaurar visual del botón Plant All
        tw(plantAllBtn,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
        tw(plantAllLbl,T_FAST,{TextColor3=themes[config.theme].text})
        plantAllLbl.Text = "🌱  Plant All"
    end
end

local function startPlanting()
    if isPlanting then return end

    -- Obtener remote (auto-detecta tipo: RemoteFunction → InvokeServer, RemoteEvent → FireServer)
    if not plantRemote then
        local remEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if remEvents then
            plantRemote = remEvents:FindFirstChild("PlantSeed")
        end
        if not plantRemote then
            showNotif("Plant Seeds","❌ PlantSeed remote not found",true)
            statusLabel.Text = "● Plant Seeds: Remote not found"
            forceOffPlantSeeds()
            return
        end
    end
    local plantIsFunction = plantRemote:IsA("RemoteFunction")

    -- Construir lista de seeds seleccionadas
    local toPlant = {}
    for _, pt in ipairs(ALL_SEEDS) do
        if selectedPlantSeeds[pt] then table.insert(toPlant, pt) end
    end
    if #toPlant == 0 then
        showNotif("Plant Seeds","⚠ No seeds selected",true)
        statusLabel.Text = "● Plant Seeds: Select seeds first"
        forceOffPlantSeeds()
        return
    end

    isPlanting = true
    plantAllLbl.Text = "⏹  Stop Planting"
    tw(plantAllBtn,T_FAST,{BackgroundColor3=Color3.fromRGB(60,20,20),BackgroundTransparency=0.15})
    tw(plantAllLbl,T_FAST,{TextColor3=Color3.fromRGB(255,100,80)})

    showNotif("Plant Seeds","🌱 Planting "..#toPlant.." types…",false)
    statusLabel.Text = "● Plant Seeds: Planting..."

    plantThread_main = task.spawn(function()
        local RADIUS = 25
        while isPlanting and getPlantSeedsState() do
            -- Re-evaluar lista por si el backpack cambió
            local active = {}
            for _, pt in ipairs(toPlant) do
                if selectedPlantSeeds[pt] and getSeedsInBackpack()[pt] then
                    table.insert(active, pt)
                end
            end

            if #active == 0 then
                statusLabel.Text = "● Plant Seeds: No more seeds"
                break
            end

            for _, plantType in ipairs(active) do
                if not isPlanting then break end

                -- Equipar
                local equipped = equipPlantSeed(plantType)
                if equipped then
                    task.wait(0.15)
                    -- Plantar batch
                    for i = 1, 8 do
                        if not isPlanting then break end
                        local pos = getPlantPosition(RADIUS)
                        if pos then
                            pcall(function()
                                if plantIsFunction then
                                    plantRemote:InvokeServer(plantType, pos)
                                else
                                    plantRemote:FireServer(plantType, pos)
                                end
                            end)
                            statusLabel.Text = "● Planting: "..plantType.." ["..i.."/8]"
                            task.wait(0.15)
                        end
                    end
                else
                    -- Sin esa seed, desmarcar
                    selectedPlantSeeds[plantType] = false
                    setSeedVisual(plantType, false)
                    refreshBadge()
                    task.wait(0.1)
                end
            end
            task.wait(0.4)
        end

        -- Fin del loop
        isPlanting = false
        plantAllLbl.Text = "🌱  Plant All"
        tw(plantAllBtn,T_FAST,{BackgroundColor3=themes[config.theme].row,BackgroundTransparency=0.2})
        tw(plantAllLbl,T_FAST,{TextColor3=themes[config.theme].text})
        if getPlantSeedsState() then
            statusLabel.Text = "● Plant Seeds: Cycle complete ✓"
            showNotif("Plant Seeds","✓ Planting cycle complete",false)
            task.wait(2); forceOffPlantSeeds()
        end
    end)
end

-- ── Botón Plant All ───────────────────────────────────────────
plantAllBtn.MouseButton1Click:Connect(function()
    -- Si ya está plantando, parar
    if isPlanting then
        stopPlanting(false); return
    end

    -- Verificar toggle maestro
    if not getPlantSeedsState() then
        showNotif("Plant Seeds","⚠ Enable 'Plant Seeds' first",true)
        statusLabel.Text = "● Plant Seeds must be ON"
        return
    end

    -- Auto-seleccionar TODAS las seeds disponibles
    local backpackSeeds = getSeedsInBackpack()
    local count = 0
    for _, pt in ipairs(ALL_SEEDS) do
        if backpackSeeds[pt] then
            selectedPlantSeeds[pt] = true; count = count + 1
            setSeedVisual(pt, true)
        end
    end
    refreshBadge()

    if count == 0 then
        showNotif("Plant All","⚠ No seeds in backpack",true)
        statusLabel.Text = "● Plant All: Backpack empty"
        return
    end

    startPlanting()
end)

-- ── Toggle maestro "Plant Seeds" ─────────────────────────────
plantSeedsBtn.MouseButton1Click:Connect(function()
    local nowOn = getPlantSeedsState()
    if not nowOn then
        -- Apagado  → detener si estaba activo
        if isPlanting then
            stopPlanting(false)
            showNotif("Plant Seeds","⏹ Planting stopped",false)
        end
    else
        -- Encendido → solo habilita, no planta automáticamente
        statusLabel.Text = "● Plant Seeds: ON — choose seeds"
        showNotif("Plant Seeds","✓ Select seeds then tap Plant All",false)
    end
end)

--====================================================
-- ★ OTHER PAGE — SHOP MONITOR ★
--====================================================
local seedShopLabel = secLabel(otherPage,"SEED SHOP STOCK",0)

local seedScroll = Instance.new("ScrollingFrame"); seedScroll.Parent = otherPage
seedScroll.Size = UDim2.new(1,-12,0,150); seedScroll.Position = UDim2.new(0,6,0,20)
seedScroll.BackgroundTransparency=1; seedScroll.BorderSizePixel=0
seedScroll.ScrollBarThickness=3; seedScroll.ScrollBarImageColor3=themes[config.theme].accent
seedScroll.ScrollBarImageTransparency=0.3; seedScroll.CanvasSize=UDim2.new(0,0,0,0)
seedScroll.ClipsDescendants=true; seedScroll.ZIndex=4
table.insert(scrollBars, seedScroll)

local seedItems = {}
local function createShopItem(parent,ypos,itemName,initialAmount)
    local t=themes[config.theme]
    local itemFrame=Instance.new("Frame"); itemFrame.Parent=parent
    itemFrame.Size=UDim2.new(1,-12,0,32); itemFrame.Position=UDim2.new(0,6,0,ypos)
    itemFrame.BackgroundColor3=t.row; itemFrame.BackgroundTransparency=0.3; itemFrame.ZIndex=5
    local ic=Instance.new("UICorner",itemFrame); ic.CornerRadius=UDim.new(0,10)
    local is=Instance.new("UIStroke",itemFrame); is.Color=t.stroke; is.Transparency=0.8
    table.insert(rows,{frame=itemFrame,stroke=is})
    local nameLabel=Instance.new("TextLabel"); nameLabel.Parent=itemFrame
    nameLabel.Size=UDim2.new(1,-50,1,0); nameLabel.Position=UDim2.new(0,10,0,0)
    nameLabel.BackgroundTransparency=1; nameLabel.Text=itemName
    nameLabel.Font=Enum.Font.GothamBold; nameLabel.TextSize=11
    nameLabel.TextColor3=t.text; nameLabel.TextXAlignment=Enum.TextXAlignment.Left; nameLabel.ZIndex=6
    table.insert(textMain,nameLabel); table.insert(fontObjs,nameLabel)
    local amountLabel=Instance.new("TextLabel"); amountLabel.Parent=itemFrame
    amountLabel.Size=UDim2.new(0,40,1,0); amountLabel.Position=UDim2.new(1,-46,0,0)
    amountLabel.BackgroundTransparency=1; amountLabel.Text=tostring(initialAmount)
    amountLabel.Font=Enum.Font.GothamBold; amountLabel.TextSize=12
    amountLabel.TextColor3=Color3.fromRGB(255,255,255); amountLabel.TextXAlignment=Enum.TextXAlignment.Right; amountLabel.ZIndex=6
    table.insert(fontObjs,amountLabel)
    return amountLabel
end

local seedLabels,gearLabels,seedItemFrames,gearItemFrames = {},{},{},{}

-- ── Seed scroll canvas helper ─────────────────────────────────
local function recalculateSeedPositions()
    local y=0
    for _,frame in pairs(seedItemFrames) do
        if frame and frame.Parent then frame.Position=UDim2.new(0,6,0,y); y=y+38 end
    end
    if seedScroll and seedScroll.Parent then
        seedScroll.CanvasSize=UDim2.new(0,0,0,math.max(0,y+10))
    end
end

local function addSeedItem(name,amount)
    seedLabels[name]=createShopItem(seedScroll,0,name,amount)
    seedItemFrames[name]=seedLabels[name].Parent; recalculateSeedPositions()
end

-- ── Gear shop section (gearScroll must be created BEFORE recalculateGearPositions) ──
local gearShopLabel = secLabel(otherPage,"GEAR SHOP STOCK",180)

local gearScroll=Instance.new("ScrollingFrame"); gearScroll.Parent=otherPage
gearScroll.Size=UDim2.new(1,-12,0,150); gearScroll.Position=UDim2.new(0,6,0,200)
gearScroll.BackgroundTransparency=1; gearScroll.BorderSizePixel=0
gearScroll.ScrollBarThickness=3; gearScroll.ScrollBarImageColor3=themes[config.theme].accent
gearScroll.ScrollBarImageTransparency=0.3; gearScroll.CanvasSize=UDim2.new(0,0,0,0)
gearScroll.ClipsDescendants=true; gearScroll.ZIndex=4
table.insert(scrollBars,gearScroll)

-- Now gearScroll is in scope — safe to reference inside the function
local function recalculateGearPositions()
    local y=0
    for _,frame in pairs(gearItemFrames) do
        if frame and frame.Parent then frame.Position=UDim2.new(0,6,0,y); y=y+38 end
    end
    if gearScroll and gearScroll.Parent then
        gearScroll.CanvasSize=UDim2.new(0,0,0,math.max(0,y+10))
    end
end

local function addGearItem(name,amount)
    gearLabels[name]=createShopItem(gearScroll,0,name,amount)
    gearItemFrames[name]=gearLabels[name].Parent; recalculateGearPositions()
end

local seedSnapshot,gearSnapshot={},{}

local function updateSeedItem(name,amount)
    if amount<=0 then
        if seedItemFrames[name] and seedItemFrames[name].Parent then seedItemFrames[name]:Destroy() end
        seedLabels[name]=nil; seedItemFrames[name]=nil; seedSnapshot[name]=nil; recalculateSeedPositions()
    else
        if not seedLabels[name] then addSeedItem(name,amount)
        else seedLabels[name].Text=tostring(amount) end
        seedSnapshot[name]=amount
    end
end

local function updateGearItem(name,amount)
    if amount<=0 then
        if gearItemFrames[name] and gearItemFrames[name].Parent then gearItemFrames[name]:Destroy() end
        gearLabels[name]=nil; gearItemFrames[name]=nil; gearSnapshot[name]=nil; recalculateGearPositions()
    else
        if not gearLabels[name] then addGearItem(name,amount)
        else gearLabels[name].Text=tostring(amount) end
        gearSnapshot[name]=amount
    end
end

-- ── Safe remote helper: returns (remote, isFunction) ──────────
local function safeGetRemote(...)
    local cur = ReplicatedStorage
    for _, name in ipairs({...}) do
        if not cur then return nil, false end
        cur = cur:FindFirstChild(name)
    end
    if not cur then return nil, false end
    return cur, cur:IsA("RemoteFunction")
end

-- ── Shop monitor loop ─────────────────────────────────────────
task.spawn(function()
    while true do
        pcall(function()
            local rem, isFn = safeGetRemote("RemoteEvents","GetShopData")
            if not rem or not isFn then return end
            local ok, shopData = pcall(function() return rem:InvokeServer("SeedShop") end)
            if ok and shopData and type(shopData.Items)=="table" then
                for n,tbl in pairs(shopData.Items) do
                    if type(tbl)=="table" and tbl.Amount then updateSeedItem(n, tbl.Amount) end
                end
            end
        end)
        pcall(function()
            local rem, isFn = safeGetRemote("RemoteEvents","GetShopData")
            if not rem or not isFn then return end
            local ok, shopData = pcall(function() return rem:InvokeServer("GearShop") end)
            if ok and shopData and type(shopData.Items)=="table" then
                for n,tbl in pairs(shopData.Items) do
                    if type(tbl)=="table" and tbl.Amount then updateGearItem(n, tbl.Amount) end
                end
            end
        end)
        task.wait(2)  -- reduced frequency to avoid spam
    end
end)

--====================================================
-- ★ MICS PAGE
--====================================================
secLabel(micsPage,"MICS",0)

local micsOption1Btn,getMicsOption1 = checkbox(micsPage,"Misc Option 1",20,false)
micsOption1Btn.MouseButton1Click:Connect(function()
    statusLabel.Text="● Misc Option 1: "..(getMicsOption1() and "ON" or "OFF")
end)

slider(micsPage,"Misc Slider",62,1,100,50,function(val)
    statusLabel.Text="● Misc Slider: "..tostring(math.floor(val))
end)

--====================================================
-- ★ TELEPORTS PAGE
--====================================================
secLabel(teleportsPage,"TELEPORTS",0)

local teleportSpots = {
    {name="SEEDS SHOP", pos=Vector3.new(176.70,204.01,672.00)},
    {name="SELL PLANTS", pos=Vector3.new(149.39,204.01,671.99)},
    {name="QUEST TASK",  pos=Vector3.new(111.53,203.99,635.05)},
    {name="GARDEN"},
}

local function getTeleportSpawn()
    local plots=workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Gardens")
    if not plots then return nil end
    for _,plot in pairs(plots:GetChildren()) do
        if plot:GetAttribute("Owner")==localPlayer.UserId or
           plot:GetAttribute("OwnerName")==localPlayer.Name or
           plot.Name==localPlayer.Name then
            local spawn=plot:FindFirstChild("Spawn")
            if spawn then spawn=spawn:FindFirstChild("Spawn") or spawn end
            return spawn
        end
    end
    return nil
end

local function teleportToGarden()
    local char=localPlayer.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local sp=getTeleportSpawn(); if not sp then warn("Garden spawn not found"); return end
    hrp.Anchored=true; hrp.CFrame=sp.CFrame*CFrame.new(0,3.5,0)
    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0); hrp.Anchored=false
end

local teleportGap=isMobile and 40 or 44
for i,spot in ipairs(teleportSpots) do
    local yp=20+(i-1)*teleportGap
    local btn=actionButton(teleportsPage,spot.name,yp)
    btn.MouseButton1Click:Connect(function()
        if spot.name=="GARDEN" then
            teleportToGarden(); statusLabel.Text="● Teleported to: GARDEN"
        elseif spot.name=="SEEDS SHOP" then
            local char=localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local hrp=char:WaitForChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame=CFrame.new(spot.pos); statusLabel.Text="● Teleported to: "..spot.name
                task.wait(0.5)
                pcall(function()
                    local prompt=workspace.MapPhysical.Shops["Seed Shop"].SeedNPC.HumanoidRootPart:WaitForChild("ProximityPrompt")
                    fireproximityprompt(prompt); statusLabel.Text="● Interacting with Seed Shop..."
                end)
            end
        else
            local hrp=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=CFrame.new(spot.pos); statusLabel.Text="● Teleported to: "..spot.name
            else statusLabel.Text="● Error: Character not found" end
        end
    end)
end

--====================================================
-- SETTINGS PAGE
--====================================================
secLabel(settingsPage,"APPEARANCE",0)
dropdown(settingsPage,"Theme",{"Default","Valentine","Snow","Garden"},config.theme,20,function(v) applyTheme(v) end)
dropdown(settingsPage,"Font Style",{"Modern","Arcade","Rounded","Bold"},config.fontStyle,68,function(v) applyFont(v) end)
secLabel(settingsPage,"BACKGROUND",122)

bgSection=Instance.new("Frame"); bgSection.Parent=settingsPage
bgSection.Size=UDim2.new(1,0,0,48); bgSection.Position=UDim2.new(0,0,0,142)
bgSection.BackgroundColor3=themes[config.theme].row; bgSection.BackgroundTransparency=0.25; bgSection.BorderSizePixel=0; bgSection.ZIndex=5
local bgsc=Instance.new("UICorner",bgSection); bgsc.CornerRadius=UDim.new(0,ROW_R)
bgSectionStroke=Instance.new("UIStroke",bgSection); bgSectionStroke.Color=themes[config.theme].stroke; bgSectionStroke.Transparency=0.88

bgPrefixLbl=Instance.new("TextLabel"); bgPrefixLbl.Parent=bgSection
bgPrefixLbl.Size=UDim2.new(0,75,1,0); bgPrefixLbl.Position=UDim2.new(0,12,0,0)
bgPrefixLbl.BackgroundTransparency=1; bgPrefixLbl.Text="Image ID:"
bgPrefixLbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; bgPrefixLbl.TextSize=FONT_SM
bgPrefixLbl.TextColor3=themes[config.theme].subtext; bgPrefixLbl.TextXAlignment=Enum.TextXAlignment.Left; bgPrefixLbl.ZIndex=6
table.insert(fontObjs,bgPrefixLbl)

bgInput=Instance.new("TextBox"); bgInput.Parent=bgSection
bgInput.Size=UDim2.new(1,-170,0,28); bgInput.Position=UDim2.new(0,90,0.5,-14)
bgInput.BackgroundColor3=themes[config.theme].primary; bgInput.BackgroundTransparency=0.3; bgInput.BorderSizePixel=0
bgInput.Text=config.bgImageId or "108458500083995"; bgInput.PlaceholderText="Image ID..."
bgInput.Font=Enum.Font.GothamMedium; bgInput.TextSize=FONT_SM
bgInput.TextColor3=themes[config.theme].text; bgInput.PlaceholderColor3=themes[config.theme].subtext
bgInput.ZIndex=6; bgInput.ClearTextOnFocus=false
local bic2=Instance.new("UICorner",bgInput); bic2.CornerRadius=UDim.new(0,10)

applyBgBtn=Instance.new("TextButton"); applyBgBtn.Parent=bgSection
applyBgBtn.Size=UDim2.new(0,66,0,28); applyBgBtn.Position=UDim2.new(1,-74,0.5,-14)
applyBgBtn.Text="Apply"; applyBgBtn.Font=Enum.Font.GothamBold; applyBgBtn.TextSize=FONT_SM
applyBgBtn.TextColor3=themes[config.theme].primary; applyBgBtn.BackgroundColor3=themes[config.theme].accent
applyBgBtn.AutoButtonColor=false; applyBgBtn.ZIndex=6
local abc=Instance.new("UICorner",applyBgBtn); abc.CornerRadius=UDim.new(0,10)

applyBgBtn.MouseButton1Click:Connect(function()
    local id=bgInput.Text:match("%d+") or "108458500083995"
    bgImage.Image="rbxassetid://"..id; config.bgImageId=id; saveConfig(config)
    statusLabel.Text="● Background updated!"
    tw(applyBgBtn,T_FAST,{BackgroundTransparency=0.4})
    task.delay(0.15,function() tw(applyBgBtn,T_FAST,{BackgroundTransparency=0}) end)
end)

local removeBg=actionButton(settingsPage,"Remove Background",200)
removeBg.MouseButton1Click:Connect(function()
    bgImage.Image=""; config.bgImageId=""; saveConfig(config); statusLabel.Text="● Background removed"
end)

--====================================================
-- TABS
--====================================================
tabData={
    {name="Main",      icon="⬡", page=mainPage,      isImage=true},
    {name="Mics",      icon="👤", page=micsPage,      isImage=true},
    {name="Other",     icon="📦", page=otherPage,     isImage=false},
    {name="Teleports", icon="✈", page=teleportsPage, isImage=true},
    {name="Settings",  icon="⚙", page=settingsPage,  isImage=true},
}
tabBtns={}
activeTabIdx=nil

local function switchTab(idx)
    if activeTabIdx==idx then return end
    local t=themes[config.theme]
    local pages={mainPage,micsPage,otherPage,teleportsPage,settingsPage}
    if activeTabIdx then
        local out=pages[activeTabIdx]; local dir=(idx>activeTabIdx) and -1 or 1
        tw(out,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(dir*0.07,0,0,0)})
        task.delay(0.2,function() out.Visible=false; out.Position=UDim2.new(0,0,0,0) end)
    end
    task.delay(activeTabIdx and 0.14 or 0,function()
        local inp=pages[idx]; local d2=(activeTabIdx and idx>activeTabIdx) and 1 or -1
        inp.Position=UDim2.new(d2*0.07,0,0,0); inp.Visible=true
        tw(inp,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
    end)
    for i,tb in ipairs(tabBtns) do
        local on=(i==idx)
        tw(tb.bg,TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
            BackgroundColor3=on and t.accent or t.row,
            BackgroundTransparency=on and 0 or 0.55,
            Size=on and UDim2.new(1,-10,0,TAB_H) or UDim2.new(1,-16,0,TAB_H)
        })
        tw(tb.lbl,T_FAST,{TextColor3=on and t.primary or t.text})
        if tb.isImage then tw(tb.ico,T_FAST,{ImageColor3=on and t.primary or t.subtext})
        else tw(tb.ico,T_FAST,{TextColor3=on and t.primary or t.subtext}) end
    end
    activeTabIdx=idx
end

local tabGap=isMobile and 46 or 54
for i,data in ipairs(tabData) do
    local yp=12+(i-1)*tabGap
    local tbg=Instance.new("Frame"); tbg.Parent=sidebar
    tbg.Size=UDim2.new(1,-16,0,TAB_H); tbg.Position=UDim2.new(0,8,0,yp)
    tbg.BackgroundColor3=themes[config.theme].row; tbg.BackgroundTransparency=0.55; tbg.BorderSizePixel=0; tbg.ZIndex=5
    local tc=Instance.new("UICorner",tbg); tc.CornerRadius=UDim.new(0,12)
    local ts=Instance.new("UIStroke",tbg); ts.Color=themes[config.theme].stroke; ts.Transparency=0.94
    table.insert(rows,{frame=tbg,stroke=ts})
    local tico
    if data.isImage then
        tico=Instance.new("ImageLabel"); tico.Name=data.name.."Icon"; tico.Parent=tbg
        tico.Size=UDim2.new(0,TAB_ICON,0,TAB_ICON); tico.Position=UDim2.new(0,10,0.5,-(TAB_ICON/2))
        tico.BackgroundTransparency=1; tico.ScaleType=Enum.ScaleType.Fit; tico.ImageColor3=themes[config.theme].subtext; tico.ZIndex=6
        if data.name=="Main"      then tico.Image="rbxassetid://"..themes[config.theme].mainTabIcon end
        if data.name=="Mics"      then tico.Image="rbxassetid://"..themes[config.theme].micsTabIcon end
        if data.name=="Teleports" then tico.Image="rbxassetid://"..themes[config.theme].teleportTabIcon end
        if data.name=="Settings"  then tico.Image="rbxassetid://"..themes[config.theme].settingsTabIcon end
    else
        tico=Instance.new("TextLabel"); tico.Parent=tbg
        tico.Size=UDim2.new(0,22,1,0); tico.Position=UDim2.new(0,8,0,0)
        tico.BackgroundTransparency=1; tico.Text=data.icon; tico.Font=Enum.Font.GothamBold; tico.TextSize=12
        tico.TextColor3=themes[config.theme].subtext; tico.ZIndex=6; table.insert(textSub,tico)
    end
    local tlbl=Instance.new("TextLabel"); tlbl.Parent=tbg
    tlbl.Size=UDim2.new(1,-30,1,0); tlbl.Position=UDim2.new(0,TAB_ICON+14,0,0)
    tlbl.BackgroundTransparency=1; tlbl.Text=data.name
    tlbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; tlbl.TextSize=FONT_MD-1
    tlbl.TextColor3=themes[config.theme].text; tlbl.TextXAlignment=Enum.TextXAlignment.Left; tlbl.ZIndex=6
    table.insert(textMain,tlbl); table.insert(fontObjs,tlbl)
    local tbtn=Instance.new("TextButton"); tbtn.Parent=tbg
    tbtn.Size=UDim2.fromScale(1,1); tbtn.BackgroundTransparency=1; tbtn.Text=""; tbtn.ZIndex=7
    tabBtns[i]={bg=tbg,lbl=tlbl,ico=tico,isImage=data.isImage,stroke=ts}
    tbtn.MouseEnter:Connect(function() if activeTabIdx~=i then tw(tbg,T_FAST,{BackgroundTransparency=0.25}) end end)
    tbtn.MouseLeave:Connect(function() if activeTabIdx~=i then tw(tbg,T_FAST,{BackgroundTransparency=0.55}) end end)
    tbtn.MouseButton1Click:Connect(function() switchTab(i) end)
end

--====================================================
-- INIT
--====================================================
switchTab(1); applyTheme(config.theme); applyFont(config.fontStyle)
if config.bgImageId and config.bgImageId~="" then bgImage.Image="rbxassetid://"..config.bgImageId end
updateCanvasSize(mainPage)

--====================================================
-- DRAG (mouse + touch)
--====================================================
local dragging=false; local dragStart=nil; local startPos=nil; local touchId=nil

root.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        if activeSlider or sliderTouchDown then return end
        if posInSlider(inp.Position.X,inp.Position.Y) then return end
        dragging=true; dragStart=inp.Position; startPos=root.Position
        local c; c=inp.Changed:Connect(function()
            if inp.UserInputState==Enum.UserInputState.End then dragging=false; c:Disconnect() end
        end)
    end
end)

root.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch then
        if sliderTouchDown or activeSlider then return end
        if posInSlider(inp.Position.X,inp.Position.Y) then return end
        if not dragging then dragging=true; touchId=inp; dragStart=inp.Position; startPos=root.Position end
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or
        (inp.UserInputType==Enum.UserInputType.Touch and inp==touchId)) then
        if activeSlider or sliderTouchDown then return end
        local d=inp.Position-dragStart
        root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
    elseif inp.UserInputType==Enum.UserInputType.Touch then
        if inp==touchId then dragging=false; touchId=nil end
    end
end)

--====================================================
-- ENTRANCE ANIMATION
--====================================================
root.Size=UDim2.new(0,0,0,0)
tw(root,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,UI_W,0,UI_H)})
