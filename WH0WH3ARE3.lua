    do --V2
    local Players          = game:GetService("Players")
    local TweenService     = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService       = game:GetService("RunService")
    local HttpService      = game:GetService("HttpService")

    local localPlayer = Players.LocalPlayer
    local PlayerGui   = localPlayer:WaitForChild("PlayerGui")

    --====================================================
    -- MOBILE DETECTION
    --====================================================
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local UI_W      = isMobile and 340 or 470
    local UI_H      = isMobile and 290 or 365
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
    local defaultConfig = {
    theme="Default", 
    fontStyle="Modern", 
    bgImageId="108458500083995", 
    bgTransparency = 0.82 -- 0 = visible, 1 = invisible 
}
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
            mainTabIcon="97378928892774",
            teleportTabIcon="124656414586890",
            settingsTabIcon="84417015405492",
            micsTabIcon="129896879015985",
            bgId="108458500083995",
        },
        Valentine = {
            primary=Color3.fromRGB(18,5,10), secondary=Color3.fromRGB(35,10,18),
            accent=Color3.fromRGB(220,60,100), text=Color3.fromRGB(255,200,215),
            subtext=Color3.fromRGB(180,100,130), sidebar=Color3.fromRGB(25,5,12),
            row=Color3.fromRGB(30,8,18), stroke=Color3.fromRGB(220,60,100),
            snow=false, valentine=true, logoId="128713599886538",
            mainTabIcon="118293451431629",
            teleportTabIcon="93867203416430",
            settingsTabIcon="92027932993173",
            micsTabIcon="81212960677084",
            bgId="86406538802929",
        },
        Snow = {
            primary=Color3.fromRGB(8,10,18), secondary=Color3.fromRGB(14,18,30),
            accent=Color3.fromRGB(200,220,255), text=Color3.fromRGB(220,235,255),
            subtext=Color3.fromRGB(140,160,200), sidebar=Color3.fromRGB(10,13,22),
            row=Color3.fromRGB(16,20,35), stroke=Color3.fromRGB(180,210,255),
            snow=true, valentine=false, logoId="105877636667273",
            mainTabIcon="86228203034983",
            teleportTabIcon="99769954902270",
            settingsTabIcon="98653576343548",
            micsTabIcon="96765613903347",
            bgId="103508032104468",
        },
        Garden = {
            primary=Color3.fromRGB(25,20,10), secondary=Color3.fromRGB(45,35,20),
            accent=Color3.fromRGB(150,200,80), text=Color3.fromRGB(245,245,230),
            subtext=Color3.fromRGB(180,160,120), sidebar=Color3.fromRGB(30,25,15),
            row=Color3.fromRGB(40,32,18), stroke=Color3.fromRGB(150,200,80),
            snow=false, valentine=false, garden=true, logoId="121057068601747",
            mainTabIcon="97378928892774",
            teleportTabIcon="124656414586890",
            settingsTabIcon="84417015405492",
            micsTabIcon="129896879015985",
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
 
 local _threads = {} 
 local _connections = {} 
 
 local function _trackThread(t) table.insert(_threads, t) return t end 
 local function _trackConn(c) table.insert(_connections, c) return c end 
 
 _G.WH01_SHUTDOWN_TEMPLATE = function() 
     -- Matar todos los threads 
     for _, t in ipairs(_threads) do pcall(task.cancel, t) end 
     table.clear(_threads) 
     -- Desconectar todos los connections 
     for _, c in ipairs(_connections) do pcall(function() c:Disconnect() end) end 
     table.clear(_connections) 
     -- Limpiar partículas 
     pcall(clearParticles) 
     -- Destruir GUI 
     pcall(function() 
         for _, v in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do 
             if v:GetAttribute("__mt") == true then v:Destroy() end 
         end 
     end) 
     _G.WH01_SHUTDOWN_TEMPLATE = nil 
 end

    local function randomStr(len) -- el monte everes no tiene nada en contra de mi 
        local words = {"PlotSelector", "LuckyBlockGui", "BackpackGui", "PreloadContainerGui", "ChangelogVersion", "FloraBook", "FriendBoost", "GearShop", "GiftModal", "HarvestButton", "Hud_UI", "Notification", "PlantTooltip", "UpdateIn", "Quests", "RNGPack", "RobuxShop", "SeedShop", "Settings", "ShillingsCurrency", "ShovelConfirmation", "SprinklerTooltip", "Tutorial", "WeatherDisplay", "Cmdr", "TopbarCenteredClipped", "TopbarStandardClipped", "TopbarStandard", "ProximityPrompts"}
        return words[math.random(1, #words)]
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
    local scrollBars = {}
    local tabBtns     = {}
    local tabData     = {}
    local accentFrames= {}
    local categoryButtons = {}
    local activeCategory = nil
    local gameName    = nil
    local root, rootStroke, bgImage
    local header, headerBottom, headerDivider
    local sidebar, sidebarTopCover, sideDiv
    local titleLabel, subtitleLabel, statusLabel, logo
    local minimize, minimizeStroke, close, closeStroke
    local contentArea, body
    local populateSeedList -- Forward declaration
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
        pConn=_trackConn(RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=0.9 then timer=0; spawn() end end))
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
        pConn=_trackConn(RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=1.6 then timer=0; spawn() end end))
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
        pConn=_trackConn(RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=1.6 then timer=0; spawn() end end))
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

    if bgImage then 
        bgImage.ImageTransparency = math.clamp(tonumber(config.bgTransparency) or 0.82, 0, 1) 
    end
        tw(titleLabel,T_SMOOTH,{TextColor3=t.text}); tw(subtitleLabel,T_SMOOTH,{TextColor3=t.subtext})
        tw(statusLabel,T_SMOOTH,{TextColor3=t.subtext})
        tw(minimize,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text}); minimizeStroke.Color=t.stroke
        tw(close,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text}); closeStroke.Color=t.stroke
        for _, scroll in ipairs(scrollBars) do 
            if scroll and scroll.Parent then 
                scroll.ScrollBarImageColor3 = t.accent 
            end 
        end
        for _,r in ipairs(rows) do
            if r.frame and r.frame.Parent then
                tw(r.frame,T_SMOOTH,{BackgroundColor3=t.row})
                if r.stroke then r.stroke.Color=t.stroke end
            end
        end
        for _, f in ipairs(accentFrames) do
            if f and f.Parent then
                tw(f, T_SMOOTH, {BackgroundColor3 = t.accent})
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

        for name, button in pairs(categoryButtons) do
            local isActive = (name == activeCategory)
            tw(button, T_SMOOTH, {
                BackgroundColor3 = isActive and t.accent or t.row,
                TextColor3 = isActive and t.primary or t.text
            })
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
        for _,b in pairs(categoryButtons) do if b and b.Parent then b.Font=f end end
    end

    --====================================================
    -- AUTO-PLANT LOGIC
    --====================================================
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local plantRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlantSeed")

    local plantLogic = {}
    plantLogic.isPlanting = false
    plantLogic.plantThread = nil
    plantLogic.seedsToPlant = {}
    plantLogic.ui = {
        forceOffPlantSeeds = nil,
        showNotif = nil
    }

    function plantLogic.getSeedsInBackpack()
        local seeds = {}
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("IsSeed") then
                    local plantType = item.Name
                    seeds[plantType] = { count = item.Stack.Value }
                end
            end
        end
        return seeds
    end

    function plantLogic.togglePlanting(enabled)
        if enabled then
            if plantLogic.plantThread then return end -- ya está corriendo
            plantLogic.plantThread = task.spawn(plantLogic.plantLoop)
        else
            if not plantLogic.plantThread then return end -- ya está detenido
            task.cancel(plantLogic.plantThread)
            plantLogic.plantThread = nil
        end
    end

    function plantLogic.plantLoop()
        while task.wait(0.2) do
            local seeds = {}
            for s, _ in pairs(plantLogic.seedsToPlant) do table.insert(seeds, s) end

            if #seeds == 0 then
                plantLogic.ui.forceOffPlantSeeds()
                plantLogic.ui.setStatus("● Auto Plant: No Seeds")
                break
            end

            local seedToPlant = seeds[tick() % #seeds + 1]
            local backpackSeeds = plantLogic.getSeedsInBackpack()
            local seedData = backpackSeeds[seedToPlant]

            if not seedData or (seedData.count or 0) <= 0 then
                plantLogic.seedsToPlant[seedToPlant] = nil
                plantLogic.ui.setStatus("● Auto Plant: Ran out of " .. seedToPlant)
                populateSeedList() -- Refresh UI
            else
                plantLogic.ui.setStatus("● Auto Plant: Planting " .. seedToPlant)
                plantRemote:FireServer(seedToPlant)
            end
        end
    end

    plantLogic.seedsToPlant = {} -- A table of plantTypes to plant
    plantLogic.ui = {
        getPlantSeeds = getPlantSeeds,
        forceOffPlantSeeds = forceOffPlantSeeds,
        setStatus = function(text) statusLabel.Text = text end,
    }

    -- Lista maestra de todas las seeds
    plantLogic.ALL_SEEDS = {
        "Wheat", "Amberpine", "Apple", "Banana", "Beetroot", "Bellpepper", "Birch",
        "Cabbage", "Carrot", "Cherry", "Corn", "Dandelion", "Dawnblossom", "Dawnfruit",
        "Emberwood", "Goldenberry", "Mushroom", "Olive", "Onion", "Orange", "Plum",
        "Pomaganit", "Potato", "Rose", "Strawberry", "Sunpetal", "Tomato",
    }

    -- Extrae el PlantType de cualquier tool de seed
    function plantLogic.getPlantTypeFromTool(tool)
        if not tool:IsA("Tool") then return nil end
        local pt = tool:GetAttribute("PlantType")
        if pt and pt ~= "" then return pt end
        local bn = tool:GetAttribute("BaseName")
        if bn then
            local stripped = bn:match("^(.+)%s+Seed$")
            if stripped then return stripped end
        end
        local name = tool.Name
        local clean = name:match("^x%d+%s+(.+)$") or name
        local stripped = clean:match("^(.+)%s+Seed$")
        if stripped then return stripped end
        return nil
    end

    -- Obtener seeds en backpack + personaje
    function plantLogic.getSeedsInBackpack()
        local found = {}
        local function checkTool(tool)
            if tool:GetAttribute("IsHarvested") or tool:GetAttribute("HarvestedFrom") or tool:GetAttribute("FruitValue") then return end
            local pt = plantLogic.getPlantTypeFromTool(tool)
            if not pt then return end
            local valid = false
            for _, knownType in ipairs(plantLogic.ALL_SEEDS) do
                if knownType == pt then valid = true; break end
            end
            if not valid then return end
            local count = tool:GetAttribute("ItemCount") or 1
            if not found[pt] then
                found[pt] = { tool = tool, count = count }
            else
                found[pt].count = found[pt].count + count
            end
        end
        for _, t in ipairs(localPlayer.Backpack:GetChildren()) do pcall(checkTool, t) end
        if localPlayer.Character then
            for _, t in ipairs(localPlayer.Character:GetChildren()) do
                if t:IsA("Tool") then pcall(checkTool, t) end
            end
        end
        return found
    end

    -- Equipar una seed
    function plantLogic.equipSeed(plantType)
        for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
            if plantLogic.getPlantTypeFromTool(tool) == plantType then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
                    return true
                end
            end
        end
        if localPlayer.Character then
            for _, t in ipairs(localPlayer.Character:GetChildren()) do
                if t:IsA("Tool") and plantLogic.getPlantTypeFromTool(t) == plantType then
                    return true
                end
            end
        end
        return false
    end

    -- Obtener una posición aleatoria cerca del jugador
    function plantLogic.getRandomPositionAroundPlayer(radius)
        local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return nil end
        local playerPos = rootPart.Position
        local angle = math.random() * 2 * math.pi
        local randomRadius = math.random() * radius
        local offsetX = math.cos(angle) * randomRadius
        local offsetZ = math.sin(angle) * randomRadius
        return playerPos + Vector3.new(offsetX, 0, offsetZ)
    end

    -- Iniciar/detener el proceso de plantado
    function plantLogic.togglePlanting(enable)
        plantLogic.isPlanting = enable
        if enable then
            if plantLogic.plantThread then task.cancel(plantLogic.plantThread) end
            plantLogic.plantThread = _trackThread(task.spawn(function()
                -- Bucle externo: se ejecuta mientras haya tipos de semillas en la lista
                while plantLogic.isPlanting and next(plantLogic.seedsToPlant) ~= nil do
                    -- 1. Escoger el *primer* tipo de semilla de la lista para enfocarse
                    local seedToPlant = next(plantLogic.seedsToPlant)
                    if not seedToPlant then break end -- Seguridad

                    statusLabel.Text = "● Auto Plant: Focusing on " .. seedToPlant
                    task.wait(0.5) -- Pequeña pausa antes de empezar

                    -- 2. Bucle interno: plantar solo este tipo de semilla hasta que se acabe
                    while plantLogic.isPlanting do
                        local backpackSeeds = plantLogic.getSeedsInBackpack()
                        local seedData = backpackSeeds[seedToPlant]

                        if not seedData or (seedData.count or 0) <= 0 then
                            -- Se acabaron las semillas de este tipo
                            statusLabel.Text = "● Auto Plant: Finished " .. seedToPlant
                            plantLogic.seedsToPlant[seedToPlant] = nil -- Eliminar de la lista de tareas
                            populateSeedList() -- Actualizar la UI para desmarcarlo
                            task.wait(0.5)
                            break -- Salir del bucle interno para que el externo elija otra semilla
                        end

                        -- Lógica de plantado (equipar y disparar remote)
                        statusLabel.Text = "● Auto Plant: Planting " .. seedToPlant
                        local equipSuccess = plantLogic.equipSeed(seedToPlant)
                        task.wait(0.05) -- SPEED-UP: Reducido de 0.2

                        if equipSuccess then
                            local pos = plantLogic.getRandomPositionAroundPlayer(20)
                            if pos then
                                plantRemote:InvokeServer(seedToPlant, pos)
                                task.wait(0.15) -- SPEED-UP: Reducido de 0.6
                            end
                        else
                            -- Si falla al equipar, probablemente ya no hay, salir del bucle
                            plantLogic.seedsToPlant[seedToPlant] = nil
                            populateSeedList()
                            break
                        end
                    end
                end

                -- 3. Cuando el bucle externo termina, ya no hay más semillas que plantar
                plantLogic.isPlanting = false
                statusLabel.Text = "● Auto Plant: off"
                if plantLogic.ui.showNotif then plantLogic.ui.showNotif("✅ Auto Plant", "COMPLETE", false) end
                task.defer(function()
                    if plantLogic.ui.forceOffPlantSeeds then
                        plantLogic.ui.forceOffPlantSeeds()
                    end
                end)
            end))
         else
             if plantLogic.plantThread then
                task.cancel(plantLogic.plantThread)
                plantLogic.plantThread = nil
            end
        end
    end

    --====================================================
    -- AUTO HARVEST LOGIC
    --====================================================
    local harvestRemote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("HarvestFruit")

    local harvestLogic = {}
    harvestLogic.isHarvesting = false
    harvestLogic.harvestThread = nil
    harvestLogic.ui = {
        forceOffAutoHarvest = nil,
        showNotif = nil,
        setStatus = function(text) statusLabel.Text = text end,
    }

    local MAX_BACKPACK_ITEMS = 300

    local function getBackpackItemCount()
        local count = 0
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then count = count + 1 end
            end
        end
        if localPlayer.Character then
            for _, item in ipairs(localPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then count = count + 1 end
            end
        end
        return count
    end

    local function getHarvestableItems()
        local items = {}
        local clientPlants = workspace:FindFirstChild("ClientPlants")
        if not clientPlants then return items end

        for _, plant in ipairs(clientPlants:GetDescendants()) do
            if (plant:IsA("Model") and plant.Parent) then
                local ownerUserId = plant:GetAttribute("OwnerUserId")

                -- Planta simple (isSingleHarvest)
                if plant:GetAttribute("HarvestablePlant") == true and plant:GetAttribute("FullyGrown") == true then
                    local uuid = plant:GetAttribute("Uuid")
                    if uuid then
                        table.insert(items, {Uuid = uuid, GrowthAnchorIndex = nil, plant = plant})
                    end
                end

                -- Frutas individuales (fruitTemplate plants)
                if plant:GetAttribute("FullyGrown") == true then
                    for _, child in ipairs(plant:GetChildren()) do
                        if child:IsA("Model") then
                            local growthAnchorIndex = child:GetAttribute("GrowthAnchorIndex")
                            local fullyGrown = child:GetAttribute("FullyGrown")
                            if growthAnchorIndex and fullyGrown == true then
                                local uuid = plant:GetAttribute("Uuid")
                                if uuid then
                                    table.insert(items, {Uuid = uuid, GrowthAnchorIndex = growthAnchorIndex, plant = child})
                                end
                            end
                        end
                    end
                end
            end
        end
        return items
    end

    local function harvestOptimized()
        local items = getHarvestableItems()
        if #items == 0 then return 0 end

        local harvested = 0
        local BATCH_SIZE = 10

        local i = 1
        while i <= #items and harvestLogic.isHarvesting do
            local batch = {}
            local batchEnd = math.min(i + BATCH_SIZE - 1, #items)

            local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local firstItem = items[i]
            if hrp and firstItem.plant and firstItem.plant.Parent then
                local pos = firstItem.plant:GetPivot().Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.05)
            end

            for j = i, batchEnd do
                local item = items[j]
                if item.plant and item.plant.Parent then
                    table.insert(batch, {
                        Uuid = item.Uuid,
                        GrowthAnchorIndex = item.GrowthAnchorIndex
                    })
                    harvested = harvested + 1
                end
            end

            if #batch > 0 then
                harvestRemote:FireServer(batch)
                statusLabel.Text = "● Auto Harvest: " .. harvested .. "/" .. #items
                task.wait(0.1)
            end

            i = batchEnd + 1
        end

        return harvested
    end

    function harvestLogic.toggleHarvesting(enable)
        harvestLogic.isHarvesting = enable
        if enable then
            if harvestLogic.harvestThread then task.cancel(harvestLogic.harvestThread) end
            harvestLogic.harvestThread = _trackThread(task.spawn(function()
                while harvestLogic.isHarvesting do
                    local countBefore = getBackpackItemCount()
                    if countBefore >= MAX_BACKPACK_ITEMS then
                        harvestLogic.isHarvesting = false
                        if harvestLogic.ui.showNotif then harvestLogic.ui.showNotif("⚠️ Backpack full", "Backpack full! Sell first.", true) end
                        task.defer(function()
                            if harvestLogic.ui.forceOffAutoHarvest then harvestLogic.ui.forceOffAutoHarvest() end
                        end)
                        break
                    end

                    local totalHarvested = harvestOptimized()

                    local countAfter = getBackpackItemCount()
                    if countAfter >= MAX_BACKPACK_ITEMS then
                        harvestLogic.isHarvesting = false
                        if harvestLogic.ui.showNotif then harvestLogic.ui.showNotif("⚠️ Backpack full", "Backpack full! Sell first.", true) end
                        task.defer(function()
                            if harvestLogic.ui.forceOffAutoHarvest then harvestLogic.ui.forceOffAutoHarvest() end
                        end)
                        break
                    end

                    if totalHarvested == 0 then
                        harvestLogic.isHarvesting = false
                        statusLabel.Text = "● Auto Harvest: No plants"
                        task.defer(function()
                            if harvestLogic.ui.forceOffAutoHarvest then harvestLogic.ui.forceOffAutoHarvest() end
                        end)
                        break
                    else
                        task.wait(0.5)
                    end
                end
             end))
         else
             if harvestLogic.harvestThread then
                task.cancel(harvestLogic.harvestThread)
                harvestLogic.harvestThread = nil
            end
        end
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
    bgImage.ScaleType=Enum.ScaleType.Crop 
 bgImage.ImageTransparency = math.clamp(tonumber(config.bgTransparency) or 0.82, 0, 1) 
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
    local contentPad=SIDEBAR_W+10
contentArea=Instance.new("ScrollingFrame"); contentArea.Parent=body
contentArea.Size=UDim2.new(1,-(contentPad+10),1,-62); contentArea.Position=UDim2.new(0,contentPad,0,48)
    contentArea.BackgroundTransparency=1; contentArea.ZIndex=3
    contentArea.ScrollBarThickness=isMobile and 2 or 4
    contentArea.ScrollBarImageColor3=themes[config.theme].accent; contentArea.ScrollBarImageTransparency=0.3
    contentArea.CanvasSize=UDim2.new(0,0,0,0); contentArea.ClipsDescendants=true; contentArea.BorderSizePixel=0
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

    local function main()
    local mainPage      = makePage(); mainPage.Visible=true
    local micsPage      = makePage()
    local settingsPage  = makePage()
    local teleportsPage = makePage()
    local otherPage     = makePage()

    local function updateCanvasSize(page)
        task.defer(function()
            if not page or not page.Parent or not page.Visible then return end

            local layout = page:FindFirstChildOfClass("UIListLayout")
            if layout then
                contentArea.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                return
            end

            local maxY = 0
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("GuiObject") then
                    local bottom = child.Position.Y.Offset + child.Size.Y.Offset
                    if bottom > maxY then
                        maxY = bottom
                    end
                end
            end
            contentArea.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
        end)
    end

    mainPage:GetPropertyChangedSignal("Visible"):Connect(function() if mainPage.Visible then updateCanvasSize(mainPage) end end)
    micsPage:GetPropertyChangedSignal("Visible"):Connect(function() if micsPage.Visible then updateCanvasSize(micsPage) end end)
    settingsPage:GetPropertyChangedSignal("Visible"):Connect(function() if settingsPage.Visible then updateCanvasSize(settingsPage) end end)
    teleportsPage:GetPropertyChangedSignal("Visible"):Connect(function() if teleportsPage.Visible then updateCanvasSize(teleportsPage) end end)
    otherPage:GetPropertyChangedSignal("Visible"):Connect(function() if otherPage.Visible then updateCanvasSize(otherPage) end end)

    --====================================================
    -- WIDGET HELPERS
    --====================================================
    local function secLabel(parent,text)
        local l=Instance.new("TextLabel"); l.Parent=parent
        l.Size=UDim2.new(1,0,0,16) 
        l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBold
        l.TextSize=FONT_SM; l.TextColor3=themes[config.theme].subtext
        l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
        table.insert(textSub,l); table.insert(fontObjs,l); return l
    end

    local function checkbox(parent,text,yp,defaultOn)
        local t=themes[config.theme]; local state=defaultOn or false
        local row=Instance.new("Frame"); row.Parent=parent
        row.Size=UDim2.new(1,0,0,ROW_H); row.Position=UDim2.new(0,0,0,yp or 0)
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
        local function forceOn()
            if not state then
                state = true
                chk.Visible=true; tw(box,T_FAST,{BackgroundColor3=themes[config.theme].accent})
            end
        end

        return row, btn, function() return state end, forceOff, forceOn
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

    local function actionButton(parent,text,yp,icon)
        local t=themes[config.theme]
        local btn=Instance.new("TextButton"); btn.Parent=parent
        btn.Size=UDim2.new(1,0,0,ROW_H); btn.Position=UDim2.new(0,0,0,yp or 0)
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
        arr.BackgroundTransparency=1; arr.Text=icon or "▼"; arr.Font=Enum.Font.GothamBold
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
    local notifTimer = nil

    local function showNotif(title,message,isError)
        -- Cancelar timer anterior si existe
        if notifTimer then task.cancel(notifTimer) end
        
        -- Destruir notificación anterior SI EXISTE
        if currentNotif and currentNotif.Parent then
            pcall(function() currentNotif:Destroy() end)
        end
        
        local t=themes[config.theme]
        local notif=Instance.new("Frame"); notif.Parent=gui
        notif.Size=UDim2.new(0,240,0,65); notif.Position=UDim2.new(0,-260,0,100)
        notif.BackgroundColor3=t.primary; notif.BackgroundTransparency=0.08; notif.BorderSizePixel=0; notif.ZIndex=100; notif.ClipsDescendants=true
        local nc=Instance.new("UICorner",notif); nc.CornerRadius=UDim.new(0,16)
        
        -- Agregar imagen de fondo del tema
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
        if hrp then
            hrp.CFrame = CFrame.new(position)
            return true
        end
        return false
    end

    --====================================================
    -- ★ MAIN PAGE — PON TUS OPCIONES AQUÍ ★
    --====================================================
    local mainListLayout = Instance.new("UIListLayout")
    mainListLayout.Parent = mainPage
    mainListLayout.Padding = UDim.new(0, 8)
    mainListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- =================================================================
    -- CATEGORY TABS SYSTEM
    -- =================================================================
    local categoryButtonsContainer = Instance.new("Frame")
categoryButtonsContainer.Name = "CategoryButtonsContainer"
categoryButtonsContainer.Parent = body
categoryButtonsContainer.BackgroundTransparency = 1
categoryButtonsContainer.Size = UDim2.new(1,-(contentPad+10), 0, 36)
categoryButtonsContainer.Position = UDim2.new(0,contentPad, 0, 6)
categoryButtonsContainer.ZIndex = 10

    local categoryButtonsLayout = Instance.new("UIListLayout")
    categoryButtonsLayout.Parent = categoryButtonsContainer
    categoryButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    categoryButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    categoryButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    categoryButtonsLayout.Padding = UDim.new(0, isMobile and 4 or 10)

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Parent = mainPage
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, 0) -- altura suficiente para el contenido
    contentContainer.Position = UDim2.new(0, 0, 0, 0)
    contentContainer.ClipsDescendants = true
    contentContainer.LayoutOrder = 2



    local optionFrames = {}
    categoryButtons = {}
    activeCategory = "SELL OPTIONS" -- Default active category

    local categoryOrder = {"SELL OPTIONS", "PLANT OPTIONS", "HARVEST"}
    local activeCategoryIdx = 1

    local function switchCategory(categoryName)
        if activeCategory == categoryName then return end

        -- Encontrar índices viejo y nuevo para saber la dirección
        local newIdx, oldIdx = 1, 1
        for i, name in ipairs(categoryOrder) do
            if name == categoryName then newIdx = i end
            if name == activeCategory then oldIdx = i end
        end

        local t = themes[config.theme]

        -- Animar la salida del frame actual
        if activeCategory then
            local outFrame = optionFrames[activeCategory]
            if outFrame then
                local dir = (newIdx > oldIdx) and -1 or 1
                tw(outFrame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    {Position = UDim2.new(dir * 0.07, 0, 0, 0)}
                )
                task.delay(0.2, function()
                    outFrame.Visible = false
                    outFrame.Position = UDim2.new(0, 0, 0, 0)
                end)
            end
        end

        activeCategory = categoryName
        activeCategoryIdx = newIdx

        -- Animar la entrada del nuevo frame
        task.delay(0.14, function()
            local inFrame = optionFrames[categoryName]
            if inFrame then
                local d2 = (newIdx > oldIdx) and 1 or -1
                inFrame.Position = UDim2.new(d2 * 0.07, 0, 0, 0)
                inFrame.Visible = true
                tw(inFrame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    {Position = UDim2.new(0, 0, 0, 0)}
                )
            end
        end)

        -- Actualizar estilos de botones
        for name, button in pairs(categoryButtons) do
            local isActive = (name == categoryName)
            tw(button, T_FAST, {
                BackgroundColor3 = isActive and t.accent or t.row,
                TextColor3 = isActive and t.primary or t.text
            })
        end
    end

    local function createCategoryButton(title, order) 
     local t = themes[config.theme] 
     local button = Instance.new("TextButton") 
     button.Name = title .. "Button" 
     button.Parent = categoryButtonsContainer 
     button.Text = title 
     button.Font = fonts.Modern 
     button.TextSize = isMobile and 7 or FONT_LG 
     button.TextScaled = false 
     button.LayoutOrder = order 
     button.Size = UDim2.new(0, isMobile and 72 or 100, 1, 0) 
     button.BackgroundColor3 = t.row 
     button.TextColor3 = t.text 
     button.TextWrapped = false 
     button.ClipsDescendants = true 
     
     local corner = Instance.new("UICorner", button) 
     corner.CornerRadius = UDim.new(0, 12) 
     
     button.MouseButton1Click:Connect(function() 
         switchCategory(title) 
     end) 

     button.InputBegan:Connect(function(inp) 
         if inp.UserInputType == Enum.UserInputType.Touch then 
             switchCategory(title) 
         end 
     end) 
     
     categoryButtons[title] = button 
     return button 
 end

    createCategoryButton("SELL OPTIONS", 1)
    createCategoryButton("PLANT OPTIONS", 2)
    createCategoryButton("HARVEST", 3)

    local function createOptionsFrame(name)
        local frame = Instance.new("Frame")
        frame.Name = name .. "Frame"
        frame.Parent = contentContainer
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)  -- posición base explícita
        frame.Visible = false

        local layout = Instance.new("UIListLayout")
        layout.Parent = frame
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        
        optionFrames[name] = frame
        return frame
    end

    local sellOptionsContainer = createOptionsFrame("SELL OPTIONS")
    local plantOptionsContainer = createOptionsFrame("PLANT OPTIONS")
    local harvestOptionsContainer = createOptionsFrame("HARVEST")

    -- Set default visible tab
   -- Set default visible tab
task.wait()
activeCategory = nil  -- reset temporal para que switchCategory no haga early return
switchCategory("SELL OPTIONS")

    -- =================================================================
    -- POPULATE SECTIONS
    -- =================================================================
    
    local option1Row, option1Btn, getOption1, forceOffOption1, forceOnOption1 = checkbox(sellOptionsContainer,"Sell Single",0,false)
    option1Row.LayoutOrder = 3
    local selling = false

    option1Btn.MouseButton1Click:Connect(function()
        local isNowOn = getOption1()
        
        if not isNowOn then
            -- PRENDIDO - Ejecutar función
            if selling then return end
            selling = true
            
            task.spawn(function()
                local tool = getEquippedTool()
                if not tool then
                    showNotif("Sell Single","⚠️ Nothing TO sell",true)
                    statusLabel.Text="● Sell Single: Nothing To Sell"
                    selling = false
                    task.wait(2.5)
                    forceOffOption1()
                    return
                end
                
                showNotif("Sell Single","🛒 Plant Found: "..tool.Name,false)
                statusLabel.Text="● Sell Single:Saving..."
                local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        showNotif("Sell All","❌ HumanoidRootPart not found",true)
        statusLabel.Text = "● Sell All: Character Error"
        sellAllFlag = false
        forceOffOption2()
        return
    end

    initialPosition = hrp.Position
                
                -- Capturar dinero inicial
                local initialMoney = 0 
    local leaderstats = Players.LocalPlayer:FindFirstChild("leaderstats") 
    if leaderstats then 
        local shillings = leaderstats:FindFirstChild("Shillings") 
        if shillings then 
            initialMoney = shillings.Value 
        end 
    end
                
                task.wait(0.3)
                
                if not selling then 
                    showNotif("Sell Single","⏹️ Cancelled ",false)
                    selling = false
                    return 
                end
                
                statusLabel.Text="● Sell Single: TP "
                if not teleportTo(SELL_POSITION) then
                    showNotif("Sell Single","❌ Error At TP",true)
                    statusLabel.Text="● Sell Single: Error"
                    selling = false
                    task.wait(2.5)
                    forceOffOption1()
                    return
                end
                
                task.wait(0.6)
                
                if not selling then 
                    showNotif("Sell Single","⏹️ Cancelled",false)
                    statusLabel.Text="● Sell Single: Cancelled"
                    if initialPosition then teleportTo(initialPosition) end
                    selling = false
                    return
                end
                
                pcall(function()
                    if not sellRemote then 
        local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") 
        if not remoteFolder then 
            showNotif("Sell All","❌ RemoteEvents not found",true) 
            sellAllFlag = false 
            forceOffOption2() 
            return 
        end 

        sellRemote = remoteFolder:FindFirstChild("SellItems") 
        if not sellRemote then 
            showNotif("Sell All","❌ SellItems remote not found",true) 
            sellAllFlag = false 
            forceOffOption2() 
            return 
        end 
    end
                    
                    statusLabel.Text="● Sell Single: Selling"
                    local result = sellRemote:InvokeServer("SellSingle")
                    
                    task.wait(0.4)
                    
                    if initialPosition then
                        statusLabel.Text="● Sell Single: Regresando..."
                        teleportTo(initialPosition)
                        task.wait(0.3)
                    end
                    
                    -- Capturar dinero final y calcular ganancia
                    local finalMoney = 0 
    local leaderstats = Players.LocalPlayer:FindFirstChild("leaderstats") 
    if leaderstats then 
        local shillings = leaderstats:FindFirstChild("Shillings") 
        if shillings then 
            finalMoney = shillings.Value 
        end 
    end
                    local moneyEarned = finalMoney - initialMoney
                    
                    showNotif("Sell Single","📦 Sell Complete | +$"..tostring(moneyEarned),false)
                    statusLabel.Text="● Sell Single: Complete"
                    selling = false
                    task.wait(2.5)
                    forceOffOption1()
                end)
            end)
        else
            -- APAGADO - Cancelar función
            selling = false
            statusLabel.Text="● Sell Single: Cancelado"
            if initialPosition then
                teleportTo(initialPosition)
            end
        end
    end)

    local option2Row, option2Btn, getOption2, forceOffOption2, forceOnOption2 = checkbox(sellOptionsContainer,"Sell All",0,false)
    option2Row.LayoutOrder = 2
    local sellAllFlag = false

    -- Blacklist de items que no se pueden vender
    local blacklist = {
        "Basic Sprinkler",
        "Turbo Sprinkler",
        "Super Sprinkler",
        "Favorite Tool",
        "Harvest Bell",
        "Watering Can",
        "Shovel",
    }

    local function isBlacklisted(toolName)
        for _, blacklistedName in ipairs(blacklist) do
            if string.find(toolName, blacklistedName) then
                return true
            end
        end
        return false
    end

    local function getBackpackTools()
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        local validTools = {}
        
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and not isBlacklisted(tool.Name) then
                    table.insert(validTools, tool)
                end
            end
        end
        
        return validTools
    end

    option2Btn.MouseButton1Click:Connect(function()
        local isNowOn = getOption2()
        
        if not isNowOn then
            -- PRENDIDO - Ejecutar función
            if sellAllFlag then return end
            sellAllFlag = true
            
            task.spawn(function()
                local validTools = getBackpackTools()
                
                -- Si solo hay herramientas en blacklist
                if #validTools == 0 then
                    showNotif("Sell All","⚠️ Nothing TO sell",true)
                    statusLabel.Text="● Sell All: Nothing To Sell"
                    sellAllFlag = false
                    task.wait(2.5)
                    forceOffOption2()
                    return
                end
                
                showNotif("Sell All","🛒 Found "..#validTools.." items",false)
                statusLabel.Text="● Sell All: Saving..."
                initialPosition = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
                
                -- Capturar dinero inicial
                local initialMoney = 0
                pcall(function()
                    initialMoney = Players.LocalPlayer.leaderstats.Shillings.Value
                end)
                
                task.wait(0.3)
                
                if not sellAllFlag then 
                    showNotif("Sell All","⏹️ Cancelled",false)
                    sellAllFlag = false
                    return 
                end
                
                statusLabel.Text="● Sell All: TP"
                if not teleportTo(SELL_POSITION) then
                    showNotif("Sell All","❌ Error At TP",true)
                    statusLabel.Text="● Sell All: Error"
                    sellAllFlag = false
                    task.wait(2.5)
                    forceOffOption2()
                    return
                end
                
                task.wait(0.6)
                
                if not sellAllFlag then 
                    showNotif("Sell All","⏹️ Cancelled",false)
                    statusLabel.Text="● Sell All: Cancelled"
                    if initialPosition then teleportTo(initialPosition) end
                    sellAllFlag = false
                    return
                end
                
                pcall(function()
                    if not sellRemote then
                        sellRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SellItems")
                    end
                    
                    statusLabel.Text="● Sell All: Selling"
                    local result = sellRemote:InvokeServer("SellAll")
                    
                    task.wait(0.4)
                    
                    if initialPosition then
                        statusLabel.Text="● Sell All: Returning..."
                        teleportTo(initialPosition)
                        task.wait(0.3)
                    end
                    
                    -- Capturar dinero final y calcular ganancia
                    local finalMoney = 0
                    pcall(function()
                        finalMoney = Players.LocalPlayer.leaderstats.Shillings.Value
                    end)
                    local moneyEarned = finalMoney - initialMoney
                    
                    showNotif("Sell All","📦 Sell Complete | +$"..tostring(moneyEarned),false)
                    statusLabel.Text="● Sell All: Complete"
                    sellAllFlag = false
                    task.wait(2.5)
                    forceOffOption2()
                end)
            end)
        else
            -- APAGADO - Cancelar función
            sellAllFlag = false
            statusLabel.Text="● Sell All: Cancelled"
            if initialPosition then
                teleportTo(initialPosition)
            end
        end
    end)

    -- Master Toggle
    local plantSeedsRow, plantSeedsBtn, getPlantSeeds, forceOffPlantSeeds, forceOnPlantSeeds = checkbox(plantOptionsContainer,"PLANT SEEDS",0,false)
    plantSeedsRow.LayoutOrder = 5

        plantLogic.ui.getPlantSeeds = getPlantSeeds
        plantLogic.ui.forceOffPlantSeeds = forceOffPlantSeeds
        plantLogic.ui.setStatus = function(text) statusLabel.Text = text end

    plantSeedsBtn.MouseButton1Click:Connect(function()
    task.wait() -- wait for checkbox state to update

    local isEnabled = getPlantSeeds()

    if isEnabled then
        local backpackSeeds = plantLogic.getSeedsInBackpack()
        local hasValidSelected = false

        -- limpiar selección inválida y verificar si hay algo que sí exista
        for plantType, _ in pairs(plantLogic.seedsToPlant) do
            local data = backpackSeeds[plantType]
            if data and (data.count or 0) > 0 then
                hasValidSelected = true
            else
                plantLogic.seedsToPlant[plantType] = nil
            end
        end

        if not hasValidSelected then
            forceOffPlantSeeds()
            showNotif("Auto Plant", "⚠️ Select seeds from your inventory", true)
            statusLabel.Text = "● Auto Plant: No Seeds"
            populateSeedList()
            return
        end
    end

    plantLogic.togglePlanting(isEnabled)
    plantLogic.isPlanting = isEnabled

    statusLabel.Text = "● Auto Plant: " .. (isEnabled and "ON" or "OFF")
end)

    -- Botón para mostrar/ocultar las semillas
    local chooseSeedsBtn = actionButton(plantOptionsContainer, "CHOSEE SEEDS", 0)
chooseSeedsBtn.LayoutOrder = 6

local seedOptionsContainer = Instance.new("Frame")
seedOptionsContainer.Name = "SeedOptionsContainer"
seedOptionsContainer.Parent = plantOptionsContainer
    seedOptionsContainer.BackgroundTransparency = 1
    seedOptionsContainer.ClipsDescendants = true
    seedOptionsContainer.LayoutOrder = 7
    seedOptionsContainer.Size = UDim2.new(1, 0, 0, 0)

    local seedOptionsLayout = Instance.new("UIListLayout")
    seedOptionsLayout.Parent = seedOptionsContainer
    seedOptionsLayout.Padding = UDim.new(0, 4)
    seedOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Botón "PLANT ALL" dentro del contenedor
    local plantAllBtn = actionButton(seedOptionsContainer, "PLANT ALL", 0, "→")
    plantAllBtn.LayoutOrder = 1
    plantAllBtn.Size = UDim2.new(1, 0, 0, ROW_H)

    -- ScrollingFrame para la lista de semillas (ALTURA FIJA DENTRO DEL DROPDOWN)
    local seedsScrollFrame = Instance.new("ScrollingFrame")
    seedsScrollFrame.Name = "SeedsScrollFrame"
    seedsScrollFrame.Parent = seedOptionsContainer
    seedsScrollFrame.LayoutOrder = 2
    seedsScrollFrame.Size = UDim2.new(1, 0, 0, 172) -- << FIX: altura fija (no scale)
    seedsScrollFrame.BackgroundTransparency = 1
    seedsScrollFrame.BorderSizePixel = 0
    seedsScrollFrame.ScrollBarThickness = 4
    seedsScrollFrame.ScrollBarImageColor3 = themes[config.theme].accent
    seedsScrollFrame.ScrollBarImageTransparency = 0.2
    seedsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    seedsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
    seedsScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    seedsScrollFrame.ClipsDescendants = true
    seedsScrollFrame.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    seedsScrollFrame.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    seedsScrollFrame.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    table.insert(scrollBars, seedsScrollFrame)

    -- FIX: nested scroll conflict (outer contentArea steals seed list scroll)
    seedsScrollFrame.Active = true
    seedsScrollFrame.ScrollingEnabled = true

    local _hoveringSeedsScroll = false
    local _holdingSeedsScroll = false

    local function _setOuterContentScroll(enabled)
        if contentArea and contentArea.Parent then
            contentArea.ScrollingEnabled = enabled
        end
    end

    seedsScrollFrame.MouseEnter:Connect(function()
        _hoveringSeedsScroll = true
        _setOuterContentScroll(false)
    end)

    seedsScrollFrame.MouseLeave:Connect(function()
        _hoveringSeedsScroll = false
        if not _holdingSeedsScroll then
            _setOuterContentScroll(true)
        end
    end)

    seedsScrollFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _holdingSeedsScroll = true
            _setOuterContentScroll(false)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _holdingSeedsScroll = false
            _setOuterContentScroll(not _hoveringSeedsScroll)
        end
    end)

    local seedsScrollLayout = Instance.new("UIListLayout")
    seedsScrollLayout.Parent = seedsScrollFrame
    seedsScrollLayout.Padding = UDim.new(0, 2)
    seedsScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local seedCheckboxes = {}

    -- Alturas del dropdown (cerrado / abierto)
    local DROPDOWN_LIST_H = 172
    local DROPDOWN_OPEN_H = ROW_H + 4 + DROPDOWN_LIST_H -- botón + padding + scroll

    -- Función robusta para refrescar canvas del scroll de seeds
    local function refreshSeedScrollCanvas()
    task.defer(function()
        if seedsScrollFrame and seedsScrollFrame.Parent and seedsScrollLayout then
            local contentY = math.max(0, seedsScrollLayout.AbsoluteContentSize.Y + 4)
            seedsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentY)

            local maxScrollY = math.max(0, contentY - seedsScrollFrame.AbsoluteSize.Y)
            seedsScrollFrame.CanvasPosition = Vector2.new(
                0,
                math.clamp(seedsScrollFrame.CanvasPosition.Y, 0, maxScrollY)
            )
        end
    end)
end

    -- Lógica para poblar la lista de semillas (UI) - MOSTRAR TODAS
    populateSeedList = function()
        for _, v in ipairs(seedsScrollFrame:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
        table.clear(seedCheckboxes)

        local availableSeeds = plantLogic.getSeedsInBackpack()

        -- Limpia selecciones que ya no existen en inventario
        for plantType, _ in pairs(plantLogic.seedsToPlant) do
            local data = availableSeeds[plantType]
            if not data or (data.count or 0) <= 0 then
                plantLogic.seedsToPlant[plantType] = nil
            end
        end

        -- 1. Clasificar semillas en dos grupos: las que tienes y las que no
        local seedsInInventory = {}
        local seedsNotInInventory = {}

        for _, plantType in ipairs(plantLogic.ALL_SEEDS) do
            if availableSeeds[plantType] and availableSeeds[plantType].count > 0 then
                table.insert(seedsInInventory, plantType)
            else
                table.insert(seedsNotInInventory, plantType)
            end
        end

        -- 2. Unir las listas, poniendo las que tienes primero
        local sortedSeedList = {}
        for _, plantType in ipairs(seedsInInventory) do table.insert(sortedSeedList, plantType) end
        for _, plantType in ipairs(seedsNotInInventory) do table.insert(sortedSeedList, plantType) end

        local order = 1

        -- 3. IMPORTANTE: recorrer la nueva lista ordenada
        for _, plantType in ipairs(sortedSeedList) do
            local seedData = availableSeeds[plantType]
            local count = (seedData and seedData.count) or 0
            local hasSeed = count > 0

            local initialValue = hasSeed and (plantLogic.seedsToPlant[plantType] or false) or false

            local row, btn, getValue, forceOff, forceOn = checkbox(
                seedsScrollFrame,
                plantType .. " (" .. tostring(count) .. ")",
                0,
                initialValue
            )

            row.LayoutOrder = order
            order = order + 1

            seedCheckboxes[plantType] = {
                row = row,
                button = btn,
                getValue = getValue,
                forceOff = forceOff,
                forceOn = forceOn,
                hasSeed = hasSeed
            }

            if not hasSeed then
                -- Estilo visual de "sin inventario"
                row.BackgroundTransparency = 0.45

                -- Deshabilitar clicks encima de esa fila
                local blocker = Instance.new("TextButton")
                blocker.Name = "DisabledBlocker"
                blocker.Parent = row
                blocker.Size = UDim2.fromScale(1,1)
                blocker.Position = UDim2.fromScale(0,0)
                blocker.BackgroundTransparency = 1
                blocker.Text = ""
                blocker.AutoButtonColor = false
                blocker.ZIndex = 20

                blocker.MouseButton1Click:Connect(function()
                    -- Asegura que nunca quede marcada
                    forceOff()
                    plantLogic.seedsToPlant[plantType] = nil
                    statusLabel.Text = "● " .. plantType .. ": No está en inventario"
                end)

                -- Etiqueta "NO INVENTORY"
                local tag = Instance.new("TextLabel")
                tag.Name = "NoInventoryTag"
                tag.Parent = row
                tag.Size = UDim2.new(0, 92, 0, 16)
                tag.Position = UDim2.new(1, -145, 0.5, -8)
                tag.BackgroundTransparency = 1
                tag.Text = "NO INVENTORY"
                tag.Font = Enum.Font.GothamBold
                tag.TextSize = 9
                tag.TextColor3 = themes[config.theme].subtext
                tag.TextXAlignment = Enum.TextXAlignment.Right
                tag.ZIndex = 21

                table.insert(textSub, tag)
                table.insert(fontObjs, tag)
            else
                -- Solo las que sí tienes pueden cambiar selección
                btn.MouseButton1Click:Connect(function()
                    task.wait()
                    local isSelected = getValue()

                    if isSelected then
                        plantLogic.seedsToPlant[plantType] = true
                    else
                        plantLogic.seedsToPlant[plantType] = nil
                    end
                end)
            end
        end

        refreshSeedScrollCanvas()
    end

    -- Recalcular canvas del panel principal cuando cambie el dropdown
    local function refreshMainAfterDropdown()
        task.defer(function()
            if mainPage.Visible then
                updateCanvasSize(mainPage)
            end
        end)
    end

    -- Mantener tamaños sincronizados si cambia el contenido
    seedOptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        -- mientras está abierto, asegurar que el contenedor mantenga la altura correcta
        if seedOptionsContainer.Size.Y.Offset > 0 then
            -- forzamos la altura estable del dropdown (evita saltos)
            seedOptionsContainer.Size = UDim2.new(1, 0, 0, DROPDOWN_OPEN_H)
            refreshMainAfterDropdown()
        end
    end)

    seedsScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        refreshSeedScrollCanvas()
        refreshMainAfterDropdown()
    end)

    -- Lógica para el botón "PLANT ALL"
plantAllBtn.MouseButton1Click:Connect(function()
    local backpackSeeds = plantLogic.getSeedsInBackpack()

    -- Limpiar selección previa
    table.clear(plantLogic.seedsToPlant)

    local selectedTypes = 0

    -- Solo marcar las que existen en inventario (y siguiendo el orden de ALL_SEEDS)
    for _, plantType in ipairs(plantLogic.ALL_SEEDS) do
        local data = backpackSeeds[plantType]
        if data and (data.count or 0) > 0 then
            plantLogic.seedsToPlant[plantType] = true
            selectedTypes = selectedTypes + 1
        end
    end

    -- Refrescar UI para que SOLO se vean marcadas las que tienes
    populateSeedList()

    if selectedTypes <= 0 then
        plantLogic.togglePlanting(false)
        if getPlantSeeds() then
            forceOffPlantSeeds()
        end
        showNotif("Plant All", "⚠️ No seeds in inventory", true)
        statusLabel.Text = "● Auto Plant: No Seeds"
        return
    end

    -- Force master checkbox ON
    if not getPlantSeeds() then
        forceOnPlantSeeds()
        task.wait()
    end

    -- Start planting
    plantLogic.togglePlanting(true)

    statusLabel.Text = "● Auto Plant: ON (" .. tostring(selectedTypes) .. " types)"
end)

    -- Lógica para mostrar/ocultar el panel de semillas (FIXED)
    local areSeedOptionsVisible = false
    chooseSeedsBtn.MouseButton1Click:Connect(function()
        areSeedOptionsVisible = not areSeedOptionsVisible

        if areSeedOptionsVisible then
            populateSeedList()

            -- Asegura estado visual antes de animar
            seedsScrollFrame.CanvasPosition = Vector2.new(0, 0)

            tw(seedOptionsContainer, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, DROPDOWN_OPEN_H)
            })

            task.delay(0.24, function()
                refreshSeedScrollCanvas()
                refreshMainAfterDropdown()
            end)
        else
            _setOuterContentScroll(true) -- Re-enable outer scroll

            tw(seedOptionsContainer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 0)
            })

            task.delay(0.20, function()
                refreshMainAfterDropdown()
            end)
        end
    end)

    local autoHarvestRow, autoHarvestBtn, getAutoHarvest, forceOffAutoHarvest, forceOnAutoHarvest = checkbox(harvestOptionsContainer,"AUTO HARVEST",0,false)
    autoHarvestRow.LayoutOrder = 9

    harvestLogic.ui.forceOffAutoHarvest = forceOffAutoHarvest
    harvestLogic.ui.showNotif = showNotif
    plantLogic.ui.showNotif = showNotif

    autoHarvestBtn.MouseButton1Click:Connect(function()
        -- Verificar backpack ANTES de que el checkbox cambie de estado
        local currentCount = getBackpackItemCount()
        if currentCount >= MAX_BACKPACK_ITEMS then
            -- No dejar que se prenda, apagar inmediatamente
            task.wait() -- dejar que el checkbox se actualice visualmente
            forceOffAutoHarvest() -- apagarlo de vuelta
            harvestLogic.isHarvesting = false
            showNotif("⚠️ Backpack full", "BACKPACK IS FULL U GOT 300/300 items. Sell First!", true)
            return
        end

        task.wait()
        local isEnabled = getAutoHarvest()

        if isEnabled then
            showNotif("Auto Harvest", "🌾 Starting harvest loop...", false)
            statusLabel.Text = "● Auto Harvest: ON"
        else
            statusLabel.Text = "● Auto Harvest: OFF"
            showNotif("Auto Harvest", "⏹️ Harvest stopped", false)
        end

        harvestLogic.toggleHarvesting(isEnabled)
    end)
--====================================================
-- ★ OTHER PAGE — SHOP MONITOR (STYLE ONLY)
--====================================================

-- Forward declarations (same names so your logic below still works)
local seedShopLabel, gearShopLabel
local seedScroll, gearScroll

-- Card-style stock panel (same WH01 theme, cleaner panel look)
local function createStockCard(parent, yPos, titleText)
    local t = themes[config.theme]

    local card = Instance.new("Frame")
    card.Parent = parent
    card.Size = UDim2.new(1, -12, 0, 170)
    card.Position = UDim2.new(0, 6, 0, yPos)
    card.BackgroundColor3 = t.secondary
    card.BackgroundTransparency = 0.18
    card.BorderSizePixel = 0
    card.ZIndex = 4
    card.ClipsDescendants = true

    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, 16)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = t.stroke
    cardStroke.Transparency = 0.88
    cardStroke.Thickness = 1

    -- Register as "secondary" style container so applyTheme updates it
    table.insert(dropLists, {frame = card, stroke = cardStroke})

    -- Soft inner overlay (keeps your style)
    local innerGlow = Instance.new("Frame")
    innerGlow.Parent = card
    innerGlow.Size = UDim2.new(1, -2, 1, -2)
    innerGlow.Position = UDim2.new(0, 1, 0, 1)
    innerGlow.BackgroundColor3 = t.primary
    innerGlow.BackgroundTransparency = 0.72
    innerGlow.BorderSizePixel = 0
    innerGlow.ZIndex = 4

    local innerGlowCorner = Instance.new("UICorner", innerGlow)
    innerGlowCorner.CornerRadius = UDim.new(0, 15)

    -- Header bar
    local headerBar = Instance.new("Frame")
    headerBar.Parent = card
    headerBar.Size = UDim2.new(1, 0, 0, 34)
    headerBar.Position = UDim2.new(0, 0, 0, 0)
    headerBar.BackgroundColor3 = t.row
    headerBar.BackgroundTransparency = 0.06
    headerBar.BorderSizePixel = 0
    headerBar.ZIndex = 5

    local headerCorner = Instance.new("UICorner", headerBar)
    headerCorner.CornerRadius = UDim.new(0, 16)

    local headerCover = Instance.new("Frame")
    headerCover.Parent = headerBar
    headerCover.Size = UDim2.new(1, 0, 0, 16)
    headerCover.Position = UDim2.new(0, 0, 1, -16)
    headerCover.BackgroundColor3 = t.row
    headerCover.BackgroundTransparency = 0.06
    headerCover.BorderSizePixel = 0
    headerCover.ZIndex = 5

    -- Register header as row-style so applyTheme updates it
    table.insert(dropRows, {frame = headerBar, stroke = nil})
    table.insert(dropRows, {frame = headerCover, stroke = nil})

    -- Small icon on header (visual only)
    local headerIcon = Instance.new("TextLabel")
    headerIcon.Parent = headerBar
    headerIcon.Size = UDim2.new(0, 20, 0, 20)
    headerIcon.Position = UDim2.new(0, 10, 0.5, -10)
    headerIcon.BackgroundTransparency = 1
    headerIcon.Text = "◧"
    headerIcon.Font = Enum.Font.GothamBold
    headerIcon.TextSize = 12
    headerIcon.TextColor3 = t.accent
    headerIcon.TextTransparency = 0.1
    headerIcon.ZIndex = 6
    table.insert(textSub, headerIcon)
    table.insert(fontObjs, headerIcon)

    -- Title label (keep same var names for applyTheme)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = headerBar
    titleLabel.Size = UDim2.new(1, -42, 1, 0)
    titleLabel.Position = UDim2.new(0, 30, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.Font = fonts[config.fontStyle] or Enum.Font.GothamBold
    titleLabel.TextSize = FONT_SM + 1
    titleLabel.TextColor3 = t.subtext
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 6
    table.insert(textSub, titleLabel)
    table.insert(fontObjs, titleLabel)

    -- Thin separator line
    local sep = Instance.new("Frame")
    sep.Parent = card
    sep.Size = UDim2.new(1, -16, 0, 1)
    sep.Position = UDim2.new(0, 8, 0, 34)
    sep.BackgroundColor3 = t.stroke
    sep.BackgroundTransparency = 0.92
    sep.BorderSizePixel = 0
    sep.ZIndex = 5

    -- Scroll area inside card
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = card
    scroll.Size = UDim2.new(1, -12, 1, -46)
    scroll.Position = UDim2.new(0, 6, 0, 38)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = isMobile and 2 or 3
    scroll.ScrollBarImageColor3 = t.accent
    scroll.ScrollBarImageTransparency = 0.25
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ClipsDescendants = true
    scroll.ZIndex = 5
    table.insert(scrollBars, scroll)

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.Name

    return card, titleLabel, scroll
end

-- Create the two card panels
local seedCard
seedCard, seedShopLabel, seedScroll = createStockCard(otherPage, 0, "SEED SHOP STOCK")

local gearCard
gearCard, gearShopLabel, gearScroll = createStockCard(otherPage, 182, "GEAR SHOP STOCK")

-- (Optional) make sure the page canvas can fit both cards nicely
otherPage.Size = UDim2.new(1, 0, 0, 360)

-- NEW ITEM ROW STYLE (same logic, only visual style changed)
local function createShopItem(parent, itemName, initialAmount)
    local t = themes[config.theme]

    local itemFrame = Instance.new("Frame")
    itemFrame.Parent = parent
    itemFrame.Size = UDim2.new(1, -8, 0, 34)

    itemFrame.BackgroundColor3 = t.row
    itemFrame.BackgroundTransparency = 0.14
    itemFrame.BorderSizePixel = 0
    itemFrame.ZIndex = 6

    local itemCorner = Instance.new("UICorner", itemFrame)
    itemCorner.CornerRadius = UDim.new(0, 12)

    local itemStroke = Instance.new("UIStroke", itemFrame)
    itemStroke.Color = t.stroke
    itemStroke.Transparency = 0.86
    itemStroke.Thickness = 1

    -- Register for theme updates
    table.insert(rows, {frame = itemFrame, stroke = itemStroke})

    -- Small accent line on the left (visual detail)
    local accentLine = Instance.new("Frame")
    accentLine.Parent = itemFrame
    accentLine.Size = UDim2.new(0, 3, 0, 18)
    accentLine.Position = UDim2.new(0, 8, 0.5, -9)
    accentLine.BackgroundColor3 = t.accent
    accentLine.BackgroundTransparency = 0.25
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 7

    local accentCorner = Instance.new("UICorner", accentLine)
    accentCorner.CornerRadius = UDim.new(1, 0)
    table.insert(accentFrames, accentLine)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = itemFrame
    nameLabel.Size = UDim2.new(1, -86, 1, 0)
    nameLabel.Position = UDim2.new(0, 18, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = itemName
    nameLabel.Font = fonts[config.fontStyle] or Enum.Font.GothamBold
    nameLabel.TextSize = FONT_MD
    nameLabel.TextColor3 = t.text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 7
    table.insert(textMain, nameLabel)
    table.insert(fontObjs, nameLabel)

    -- Count pill on the right
    local amountPill = Instance.new("Frame")
    amountPill.Parent = itemFrame
    amountPill.Size = UDim2.new(0, 44, 0, 22)
    amountPill.Position = UDim2.new(1, -52, 0.5, -11)
    amountPill.BackgroundColor3 = t.primary
    amountPill.BackgroundTransparency = 0.22
    amountPill.BorderSizePixel = 0
    amountPill.ZIndex = 7

    local pillCorner = Instance.new("UICorner", amountPill)
    pillCorner.CornerRadius = UDim.new(0, 9)

    local pillStroke = Instance.new("UIStroke", amountPill)
    pillStroke.Color = t.stroke
    pillStroke.Transparency = 0.80
    pillStroke.Thickness = 1

    -- Also theme-aware
    table.insert(rows, {frame = amountPill, stroke = pillStroke})

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Parent = amountPill
    amountLabel.Size = UDim2.fromScale(1, 1)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = tostring(initialAmount)
    amountLabel.Font = Enum.Font.GothamBold
    amountLabel.TextSize = FONT_MD
    amountLabel.TextColor3 = t.accent
    amountLabel.TextXAlignment = Enum.TextXAlignment.Center
    amountLabel.ZIndex = 8

    table.insert(textMain, amountLabel)
    table.insert(fontObjs, amountLabel)

    return itemFrame, amountLabel
end

local seedLabels = {}
local gearLabels = {}
local seedItemFrames = {}
local gearItemFrames = {}

local function recalculateSeedPositions()
    task.defer(function()
        if seedScroll and seedScroll.Parent then
            local listLayout = seedScroll:FindFirstChildOfClass("UIListLayout")
            if listLayout then
                seedScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end
        end
    end)
end

local function recalculateGearPositions()
    task.defer(function()
        if gearScroll and gearScroll.Parent then
            local listLayout = gearScroll:FindFirstChildOfClass("UIListLayout")
            if listLayout then
                gearScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end
        end
    end)
end

local function addSeedItem(name, amount)
    local frame, label = createShopItem(seedScroll, name, amount)
    seedItemFrames[name] = frame
    seedLabels[name] = label
    recalculateSeedPositions()
end

local function addGearItem(name, amount)
    gearLabels[name] = createShopItem(gearScroll, name, amount)
    gearItemFrames[name] = gearLabels[name].Parent
    recalculateGearPositions()
end

    -- Monitor de shops mejorado
    local seedSnapshot = {}
    local gearSnapshot = {}

    local function updateSeedItem(name, amount)
        if amount <= 0 then
            -- Eliminar si está en 0
            if seedItemFrames[name] and seedItemFrames[name].Parent then
                seedItemFrames[name]:Destroy()
            end
            seedLabels[name] = nil
            seedItemFrames[name] = nil
            seedSnapshot[name] = nil
            recalculateSeedPositions()
        else
            -- Si no existe pero tiene stock, crear
            if not seedLabels[name] then
                addSeedItem(name, amount)
            else
                seedLabels[name].Text = tostring(amount)
            end
            seedSnapshot[name] = amount
        end
    end

    local function updateGearItem(name, amount)
        if amount <= 0 then
            -- Eliminar si está en 0
            if gearItemFrames[name] and gearItemFrames[name].Parent then
                gearItemFrames[name]:Destroy()
            end
            gearLabels[name] = nil
            gearItemFrames[name] = nil
            gearSnapshot[name] = nil
            recalculateGearPositions()
        else
            -- Si no existe pero tiene stock, crear
            if not gearLabels[name] then
                addGearItem(name, amount)
            else
                gearLabels[name].Text = tostring(amount)
            end
            gearSnapshot[name] = amount
        end
    end

    -- Monitor loop
    _trackThread(task.spawn(function()
        while true do
            pcall(function()
                local shopData = ReplicatedStorage.RemoteEvents.GetShopData:InvokeServer("SeedShop")
                local newItems = {}
                if shopData and shopData.Items then
                    for seedName, seedTable in pairs(shopData.Items) do
                        newItems[seedName] = true
                        updateSeedItem(seedName, seedTable.Amount)
                    end
                end
                
                -- Collect items to remove
                local itemsToRemove = {}
                for oldName, _ in pairs(seedSnapshot) do
                    if not newItems[oldName] then
                        table.insert(itemsToRemove, oldName)
                    end
                end

                -- Act on the collected items
                for _, nameToRemove in ipairs(itemsToRemove) do
                    updateSeedItem(nameToRemove, 0)
                end
            end)
            
            pcall(function()
                local shopData = ReplicatedStorage.RemoteEvents.GetShopData:InvokeServer("GearShop")
                local newItems = {}
                if shopData and shopData.Items then
                    for itemName, itemTable in pairs(shopData.Items) do
                        newItems[itemName] = true
                        updateGearItem(itemName, itemTable.Amount)
                    end
                end

                -- Collect items to remove
                local itemsToRemove = {}
                for oldName, _ in pairs(gearSnapshot) do
                    if not newItems[oldName] then
                        table.insert(itemsToRemove, oldName)
                    end
                end

                -- Act on the collected items
                for _, nameToRemove in ipairs(itemsToRemove) do
                    updateGearItem(nameToRemove, 0)
                end
            end)
            
            task.wait(1)
        end
    end))

    --====================================================
    -- ★ MICS PAGE — PON TUS OPCIONES AQUÍ ★
    --====================================================
    secLabel(micsPage,"MICS",0)

    --====================================================
-- ★ MICS PAGE — MOVEMENT FEATURES ★
--====================================================
local micsListLayout = Instance.new("UIListLayout")
micsListLayout.Parent = micsPage
micsListLayout.Padding = UDim.new(0, 8)
micsListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- MOVEMENT SECTION
local movementLabel = secLabel(micsPage, "MOVEMENT")
movementLabel.LayoutOrder = 1

-- ============================================
-- C WALK (CFrame Bypass) - PC & MOBILE
-- ============================================
getgenv().Multiplier = 0.5
local walkSpeedActive = false
local walkSpeedConnection = nil

local walkSpeedRow, walkSpeedBtn, getWalkSpeed, forceOffWalkSpeed = checkbox(micsPage, "C WALK", 0, false)
walkSpeedRow.LayoutOrder = 2

local walkSpeedSlider, getWalkSpeedVal, setWalkSpeedVal = slider(
    micsPage,
    "CFrame Speed",
    0,
    0.1,
    2.0,
    0.5,
    function(val)
        getgenv().Multiplier = val
        statusLabel.Text = "● CFrame Speed: " .. tostring(math.floor(val * 100) / 100)
    end
)
walkSpeedSlider.LayoutOrder = 3

local function startCFrameSpeed()
    if walkSpeedConnection then return end
    
    walkSpeedActive = true
    
    walkSpeedConnection = _trackConn(RunService.Stepped:Connect(function()
        if walkSpeedActive then
            pcall(function()
                local char = localPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hrp = char.HumanoidRootPart
                    local hum = char.Humanoid
                    
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * getgenv().Multiplier)
                end
            end)
        end
    end))
end

local function stopCFrameSpeed()
    walkSpeedActive = false
    
    if walkSpeedConnection then
        walkSpeedConnection:Disconnect()
        walkSpeedConnection = nil
    end
end

walkSpeedBtn.MouseButton1Click:Connect(function()
    task.wait()
    local isEnabled = getWalkSpeed()
    
    if isEnabled then
        startCFrameSpeed()
        statusLabel.Text = "● C Walk: ON (" .. tostring(math.floor(getgenv().Multiplier * 100) / 100) .. ")"
    else
        stopCFrameSpeed()
        statusLabel.Text = "● C Walk: OFF"
    end
end)

_trackConn(localPlayer.CharacterAdded:Connect(function(character)
    if walkSpeedActive then
        task.wait(0.5)
        stopCFrameSpeed()
        task.wait(0.1)
        startCFrameSpeed()
    end
end))

-- ============================================
-- C FLY - PC & MOBILE (FIXED - CONTROLES NORMALES)
-- ============================================
local flyEnabled = false
local flySpeed = 50
local flyThread = nil

local flyRow, flyBtn, getFly, forceOffFly = checkbox(micsPage, "C FLY", 0, false)
flyRow.LayoutOrder = 4

local flySpeedSlider, getFlySpeedVal, setFlySpeedVal = slider(
    micsPage,
    "Fly Speed",
    0,
    10,
    150,
    50,
    function(val)
        flySpeed = val
        statusLabel.Text = "● Fly Speed: " .. tostring(math.floor(val))
    end
)
flySpeedSlider.LayoutOrder = 5

local function stopFly()
    flyEnabled = false
    
    if flyThread then
        task.cancel(flyThread)
        flyThread = nil
    end
    
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        
        if root:FindFirstChild("FlyMover") then root.FlyMover:Destroy() end
        if root:FindFirstChild("FlyRotator") then root.FlyRotator:Destroy() end
        
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    
    statusLabel.Text = "● C Fly: OFF"
end

local function startFly()
    flyEnabled = true
    statusLabel.Text = isMobile and "● C Fly: ON (Joystick)" or "● C Fly: ON (WASD + E/Q)"
    
    local char = localPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyMover"
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyRotator"
    bg.Parent = root
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.D = 100
    
    flyThread = _trackThread(task.spawn(function()
        while flyEnabled and char.Parent do
            pcall(function()
                if char then
                    char:SetAttribute("KM_TELEPORT_TRUST_SCORE", 100)
                    char:SetAttribute("KM_SPEED_TRUST_SCORE", 100)
                end
                
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)
                
                if isMobile then
                    -- MOBILE: Controles NORMALES (como caminar)
                    local joyDir = hum.MoveDirection
                    
                    if joyDir.Magnitude > 0 then
                        -- Obtener vectores de cámara
                        local camCF = cam.CFrame
                        local camLook = camCF.LookVector
                        local camRight = camCF.RightVector
                        
                        -- Proyectar en plano horizontal (ignorar Y para movimiento horizontal)
                        local camLookFlat = Vector3.new(camLook.X, 0, camLook.Z).Unit
                        local camRightFlat = Vector3.new(camRight.X, 0, camRight.Z).Unit
                        
                        -- CORREGIDO: Usar joyDir directamente SIN invertir
                        -- joyDir.Z es el componente forward/backward del joystick
                        -- joyDir.X es el componente left/right del joystick
                        moveDir = (camLookFlat * joyDir.Z) + (camRightFlat * joyDir.X)
                        
                        -- Subir/bajar basado en inclinación de cámara (opcional)
                        if math.abs(camLook.Y) > 0.2 then
                            local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                            local dot = joyDir:Dot(flatLook)
                            
                            -- Si empujas hacia adelante y la cámara mira arriba -> sube
                            if dot > 0.5 then
                                moveDir = moveDir + Vector3.new(0, camLook.Y, 0)
                            -- Si empujas hacia atrás y la cámara mira arriba -> baja
                            elseif dot < -0.5 then
                                moveDir = moveDir - Vector3.new(0, camLook.Y, 0)
                            end
                        end
                    end
                else
                    -- PC: Teclas WASD + E/Q
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + look
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - look
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - right
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + right
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end
                end
                
                -- Boost con Shift
                local currentSpeed = flySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    currentSpeed = flySpeed * 3
                end
                
                -- Normalizar dirección
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end
                
                -- Aplicar movimiento
                bg.CFrame = cam.CFrame
                bv.Velocity = moveDir * currentSpeed
                
                hum.PlatformStand = true
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end)
            
            RunService.Heartbeat:Wait()
        end
        
        -- Cleanup
        if root:FindFirstChild("FlyMover") then root.FlyMover:Destroy() end
        if root:FindFirstChild("FlyRotator") then root.FlyRotator:Destroy() end
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end))
end

flyBtn.MouseButton1Click:Connect(function()
    local shouldEnable = not flyEnabled
    
    if shouldEnable then
        startFly()
    else
        stopFly()
    end
end)

-- ============================================
-- INF JUMP - PC & MOBILE
-- ============================================
local infJumpEnabled = false
local infJumpConnection = nil

local infJumpRow, infJumpBtn, getInfJump, forceOffInfJump = checkbox(micsPage, "INF JUMP", 0, false)
infJumpRow.LayoutOrder = 6

local function setupInfJump(character)
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
    
    if not infJumpEnabled then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    infJumpConnection = _trackConn(humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if infJumpEnabled and humanoid.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

infJumpBtn.MouseButton1Click:Connect(function()
    task.wait()
    infJumpEnabled = getInfJump()
    
    if infJumpEnabled then
        local character = localPlayer.Character
        if character then
            setupInfJump(character)
        end
        statusLabel.Text = "● Inf Jump: ON"
    else
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
        statusLabel.Text = "● Inf Jump: OFF"
    end
end)

_trackConn(localPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if infJumpEnabled then
        setupInfJump(character)
    end
end))

-- ============================================
-- CLEANUP AL CERRAR SCRIPT
-- ============================================
local originalShutdown = _G.WH01_SHUTDOWN_TEMPLATE

_G.WH01_SHUTDOWN_TEMPLATE = function()
    -- Apagar todos los features de MICS
    if walkSpeedActive then
        stopCFrameSpeed()
    end
    
    if flyEnabled then
        stopFly()
    end
    
    if infJumpEnabled then
        infJumpEnabled = false
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
    end
    
    -- Llamar al shutdown original
    if originalShutdown then
        originalShutdown()
    end
end

    --====================================================
    -- ★ TELEPORTS PAGE — PON TUS SPOTS AQUÍ ★
    --====================================================
    secLabel(teleportsPage,"TELEPORTS",0)

    local teleportSpots = {
        -- {name="Nombre", pos=Vector3.new(X, Y, Z)},
        {name="SEEDS SHOP", pos=Vector3.new(176.70, 204.01, 672.00)},
        {name="SELL PLANTS", pos=Vector3.new(149.39, 204.01, 671.99)},
        {name="QUEST TASK", pos=Vector3.new(111.53, 203.99, 635.05)},
        {name="GARDEN"},
    }

    local function getTeleportSpawn()
        local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Gardens")
        if not plots then
            warn("No se encontró la carpeta de plots")
            return nil
        end
        for _, plot in pairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == localPlayer.UserId or plot:GetAttribute("OwnerName") == localPlayer.Name or plot.Name == localPlayer.Name then
                local spawn = plot:FindFirstChild("Spawn")
                if spawn then
                    spawn = spawn:FindFirstChild("Spawn") or spawn
                end
                return spawn
            end
        end
        warn("No se encontró tu plot")
        return nil
    end

    local function teleportToGarden()
        local character = localPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end
        local spawnPart = getTeleportSpawn()
        if not spawnPart then
            warn("No se encontró el spawn del garden!")
            return
        end
        hrp.Anchored = true
        hrp.CFrame = spawnPart.CFrame * CFrame.new(0, 3.5, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.Anchored = false
    end

    local teleportGap=isMobile and 40 or 44
    for i,spot in ipairs(teleportSpots) do
        local yp=20+(i-1)*teleportGap
        local btn=actionButton(teleportsPage,spot.name,yp, "→")
        btn.MouseButton1Click:Connect(function()
            if spot.name == "GARDEN" then
                teleportToGarden()
                statusLabel.Text="● Teleported to: "..spot.name
            elseif spot.name == "SEEDS SHOP" then
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(spot.pos)
                    statusLabel.Text="● Teleported to: "..spot.name
                    task.wait(0.5)
                    pcall(function()
                        local prompt = workspace.MapPhysical.Shops["Seed Shop"].SeedNPC.HumanoidRootPart:WaitForChild("ProximityPrompt")
                        fireproximityprompt(prompt)
                        statusLabel.Text="● Interacting with Seed Shop..."
                    end)
                else
                    statusLabel.Text="● Error: Character not found"
                end
            else
                local char=Players.LocalPlayer.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
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

    local _bgSaveStamp = 0
 
    local bgSliderRow, getBgSliderVal, setBgSliderVal = slider( 
        settingsPage, 
        "BG Transparency", 
        198,          -- Y position 
        0,            -- min 
        100,          -- max 
        math.floor((1 - (tonumber(config.bgTransparency) or 0.82)) * 100), 
        function(val) 
            local alpha = math.clamp(1 - (val / 100), 0, 1) 
            bgImage.ImageTransparency = alpha 
            config.bgTransparency = alpha 
            statusLabel.Text = "● BG Transparency: " .. tostring(math.floor(val)) .. "%" 

            -- mini debounce para no spamear writefile 
            local stamp = tick() 
            _bgSaveStamp = stamp 
            task.delay(0.12, function() 
                if _bgSaveStamp == stamp then 
                    saveConfig(config) 
                end 
            end) 
        end 
    )

    local removeBg=actionButton(settingsPage,"Remove Background",256, "→")
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
    categoryButtonsContainer.Visible = (idx == 1)
    if idx == 1 then
        contentArea.Size = UDim2.new(1,-(contentPad+10),1,-62)
        contentArea.Position = UDim2.new(0,contentPad,0,48)
    else
        contentArea.Size = UDim2.new(1,-(contentPad+10),1,-24)
        contentArea.Position = UDim2.new(0,contentPad,0,10)
    end
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
 -- DRAG (mouse + touch) 
 --==================================================== 
 local dragging=false; local dragStart=nil; local startPos=nil; local touchId=nil 
 local dragThresholdMet = false  -- FIX MOBILE: solo arrastra si se mueve suficiente 
 
 root.InputBegan:Connect(function(inp) 
     if inp.UserInputType==Enum.UserInputType.MouseButton1 then 
         if activeSlider or sliderTouchDown then return end 
         if posInSlider(inp.Position.X,inp.Position.Y) then return end 
         dragging=true; dragThresholdMet=true; dragStart=inp.Position; startPos=root.Position 
         local c; c=inp.Changed:Connect(function() 
             if inp.UserInputState==Enum.UserInputState.End then dragging=false; c:Disconnect() end 
         end) 
     end 
 end) 
 
 root.InputBegan:Connect(function(inp) 
     if inp.UserInputType==Enum.UserInputType.Touch then 
         if sliderTouchDown or activeSlider then return end 
         if posInSlider(inp.Position.X,inp.Position.Y) then return end 
         if not dragging then 
             dragging=true 
             dragThresholdMet=false  -- aún no confirmamos drag 
             touchId=inp 
             dragStart=inp.Position 
             startPos=root.Position 
         end 
     end 
 end) 
 
 UserInputService.InputChanged:Connect(function(inp) 
     if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or 
         (inp.UserInputType==Enum.UserInputType.Touch and inp==touchId)) then 
         if activeSlider or sliderTouchDown then return end 
         local d=inp.Position-dragStart 
         -- FIX MOBILE: solo mover si el dedo se alejó más de 10px 
         if not dragThresholdMet then 
             if math.abs(d.X) > 10 or math.abs(d.Y) > 10 then 
                 dragThresholdMet = true 
             else 
                 return  -- aún no hay suficiente movimiento, ignorar 
             end 
         end 
         root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) 
     end 
 end) 
 
 UserInputService.InputEnded:Connect(function(inp) 
     if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; dragThresholdMet=false 
     elseif inp.UserInputType==Enum.UserInputType.Touch then 
         if inp==touchId then dragging=false; touchId=nil; dragThresholdMet=false end 
     end 
 end)

    --====================================================
    -- ENTRANCE ANIMATION
    --====================================================
    root.Size=UDim2.new(0,0,0,0)
    tw(root,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,UI_W,0,UI_H)})

    --====================================================
    -- INIT
    --====================================================
    switchTab(1); applyTheme(config.theme); applyFont(config.fontStyle)
    if config.bgImageId and config.bgImageId~="" then bgImage.Image="rbxassetid://"..config.bgImageId end
    updateCanvasSize(mainPage)

    end

    main()




    end
