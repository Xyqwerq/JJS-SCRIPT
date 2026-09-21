--// ============================================
--// JJS Script v17 for Delta Executor
--// + Fast Movement (no slow-down) | + Smart Target Lock
--// Made by Xyqwerq
--// ============================================

--// ============ FORCE CLEANUP ============
if _G.JJS_SCRIPT_LOADED then
    warn("[JJS] Cleaning old instance...")
    pcall(function()
        if _G.JJS_CLEANUP then _G.JJS_CLEANUP() end
    end)
end
_G.JJS_SCRIPT_LOADED = nil
_G.JJS_CLEANUP = nil
_G.JJS_SCRIPT_LOADED = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// ============ THEME ============
local THEME = {
    Background     = Color3.fromRGB(35, 35, 40),
    BackgroundDark = Color3.fromRGB(28, 28, 33),
    Stroke         = Color3.fromRGB(160, 60, 255),
    Text           = Color3.fromRGB(255, 255, 255),
    SubText        = Color3.fromRGB(200, 200, 210),
    Accent         = Color3.fromRGB(160, 60, 255),
    ButtonOff      = Color3.fromRGB(55, 55, 65),
    ButtonOn       = Color3.fromRGB(120, 50, 200),
    ButtonOffHover = Color3.fromRGB(80, 80, 100),
    ButtonOnHover  = Color3.fromRGB(150, 70, 240),
    Green          = Color3.fromRGB(90, 255, 130),
    Red            = Color3.fromRGB(255, 90, 90),
    Yellow         = Color3.fromRGB(255, 200, 80),
    Credit         = Color3.fromRGB(180, 120, 255),
    DropdownBg     = Color3.fromRGB(45, 45, 52),
    InputBg        = Color3.fromRGB(45, 45, 52),
}

local HOTKEY = Enum.KeyCode.RightShift
local GUI_W = 260
local GUI_H = 340
local MIN_WIDTH = 220
local MIN_HEIGHT = 250

do
    local viewport = workspace.CurrentCamera.ViewportSize
    if GUI_H > viewport.Y - 80 then GUI_H = viewport.Y - 80 end
    if GUI_W > viewport.X - 40 then GUI_W = viewport.X - 40 end
end

--// ============ CONFIG PATHS ============
local CONFIG_FOLDER = "JJS_XyqwHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/Xyqwerq/JJS-SCRIPT/main/jjs_script.lua"

--// ============ FILE SYSTEM ============
local hasFileSystem = false
pcall(function()
    if typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function" then
        hasFileSystem = true
    end
end)

--// ============ ✅ MOVEMENT CONFIG (fixed speed) ============
local CONFIG = {
    FOLLOW_DISTANCE = 1.5,
    STEP_INTERVAL   = 0.03,       -- ✅ было 0.04 — чуть чаще
    STEP_SPEED      = 0.65,       -- ✅ было 0.45 — больше за шаг
    MAX_STEP        = 6,          -- ✅ было 2 — большой шаг при далёкой цели
    MIN_STEP        = 2,          -- ✅ минимальный шаг (вблизи)
    DEADZONE        = 1,
    JUMP_ON_STUCK   = true,
    REPATH_INTERVAL = 0.3,
    WAYPOINT_REACH  = 3,
}

-- ✅ TARGET LOCK
local TargetLockConfig = {
    EngageDistance = 20,
    DropDistance   = 40,
    SwitchMargin   = 8,
}

-- SERVER HOP
local ServerHopConfig = {
    Enabled = false,
    MinPlayers = 3,
    CheckInterval = 15,
    LastHop = 0,
}

--// ============ STATE ============
local AutoFarmEnabled = false
local AutoAttackEnabled = false
local CurrentTarget = nil
local ManualTarget = nil
local InCombat = false

--// ============ FILE HELPERS ============
local function saveConfig()
    if not hasFileSystem then return end
    local data = {
        AutoFarmEnabled     = AutoFarmEnabled,
        AutoAttackEnabled   = AutoAttackEnabled,
        ServerHopEnabled    = ServerHopConfig.Enabled,
        ServerHopMinPlayers = ServerHopConfig.MinPlayers,
    }
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return end
    pcall(function()
        if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
            if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        end
        writefile(CONFIG_FILE, encoded)
    end)
end

local function loadConfig()
    if not hasFileSystem then return nil end
    local data = nil
    pcall(function()
        if isfile(CONFIG_FILE) then
            data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        end
    end)
    return data
end

--// ============ REMOVE OLD GUI ============
for _, name in ipairs({"JJSScriptGui", "JJSTargetHud"}) do
    pcall(function()
        local obj = game.CoreGui:FindFirstChild(name)
        if obj then obj:Destroy() end
    end)
end

--// ============================================
--// MAIN GUI
--// ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJSScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, GUI_W, 0, GUI_H)
MainFrame.Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Stroke
MainStroke.Thickness = 1.5
MainStroke.Transparency = 1
MainStroke.Parent = MainFrame

local DragBar = Instance.new("TextLabel")
DragBar.Size = UDim2.new(1, -50, 0, 22)
DragBar.BackgroundColor3 = THEME.BackgroundDark
DragBar.BackgroundTransparency = 1
DragBar.BorderSizePixel = 0
DragBar.Text = "JJS Script v17"
DragBar.TextColor3 = THEME.Accent
DragBar.Font = Enum.Font.GothamBold
DragBar.TextSize = 11
DragBar.TextTransparency = 1
DragBar.Parent = MainFrame

local DragBarCorner = Instance.new("UICorner")
DragBarCorner.CornerRadius = UDim.new(0, 10)
DragBarCorner.Parent = DragBar

--// CLOSE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -24, 0, 2)
CloseBtn.BackgroundColor3 = THEME.ButtonOff
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.TextTransparency = 1
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Red}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.ButtonOff}):Play()
end)

--// RESIZE
local resizing = false
local resizeStart, resizeStartSize

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
ResizeHandle.Position = UDim2.new(1, -18, 1, -18)
ResizeHandle.BackgroundColor3 = THEME.Stroke
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = ""
ResizeHandle.AutoButtonColor = false
ResizeHandle.Parent = MainFrame

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 5)
ResizeCorner.Parent = ResizeHandle

local ResizeIcon = Instance.new("TextLabel")
ResizeIcon.Size = UDim2.new(1, 0, 1, 0)
ResizeIcon.BackgroundTransparency = 1
ResizeIcon.Text = "◢"
ResizeIcon.TextColor3 = THEME.Stroke
ResizeIcon.Font = Enum.Font.GothamBold
ResizeIcon.TextSize = 11
ResizeIcon.TextTransparency = 1
ResizeIcon.Parent = ResizeHandle

ResizeHandle.MouseEnter:Connect(function()
    TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
end)
ResizeHandle.MouseLeave:Connect(function()
    if not resizing then
        TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end
end)

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        resizeStartSize = MainFrame.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
                TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end)
    end
end)

--// SCROLL FRAME
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollFrame.Position = UDim2.new(0, 0, 0, 26)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = THEME.Stroke
ScrollFrame.ScrollBarImageTransparency = 0.2
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 420)
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
ScrollFrame.Parent = MainFrame

--// HEADER
local HelloLabel = Instance.new("TextLabel")
HelloLabel.Size = UDim2.new(1, -20, 0, 26)
HelloLabel.Position = UDim2.new(0, 10, 0, 2)
HelloLabel.BackgroundTransparency = 1
HelloLabel.Text = ""
HelloLabel.TextColor3 = THEME.Text
HelloLabel.Font = Enum.Font.GothamBold
HelloLabel.TextSize = 16
HelloLabel.TextTransparency = 1
HelloLabel.TextXAlignment = Enum.TextXAlignment.Center
HelloLabel.Parent = ScrollFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 12)
StatusLabel.Position = UDim2.new(0, 10, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = THEME.SubText
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ScrollFrame

local ScanLabel = Instance.new("TextLabel")
ScanLabel.Size = UDim2.new(1, -20, 0, 12)
ScanLabel.Position = UDim2.new(0, 10, 0, 44)
ScanLabel.BackgroundTransparency = 1
ScanLabel.Text = ""
ScanLabel.TextColor3 = THEME.Text
ScanLabel.Font = Enum.Font.GothamMedium
ScanLabel.TextSize = 10
ScanLabel.TextTransparency = 1
ScanLabel.TextXAlignment = Enum.TextXAlignment.Center
ScanLabel.Parent = ScrollFrame

--// UI HELPERS
local function makeSeparator(y)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, y)
    sep.BackgroundColor3 = THEME.Stroke
    sep.BackgroundTransparency = 1
    sep.BorderSizePixel = 0
    sep.Parent = ScrollFrame
    return sep
end

local function makeButton(text, y, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, height or 28)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = THEME.ButtonOff
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextTransparency = 1
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Parent = ScrollFrame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    local s = Instance.new("UIStroke"); s.Color = THEME.Stroke; s.Thickness = 1; s.Transparency = 1; s.Parent = btn
    return btn, s
end

local function makeLabel(text, y, color, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or THEME.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = size or 11
    lbl.TextTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ScrollFrame
    return lbl
end

local function makeInput(placeholder, y, default)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5, -15, 0, 26)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = THEME.InputBg
    box.BackgroundTransparency = 1
    box.Text = default or ""
    box.PlaceholderText = placeholder
    box.TextColor3 = THEME.Text
    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 11
    box.TextTransparency = 1
    box.ClearTextOnFocus = false
    box.Parent = ScrollFrame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = box
    local s = Instance.new("UIStroke"); s.Color = THEME.Stroke; s.Thickness = 1; s.Transparency = 1; s.Parent = box
    return box, s
end

--// MAIN BUTTONS
local Sep1 = makeSeparator(64)
local AutoFarmBtn, AutoFarmStroke = makeButton("Enable AutoFarm", 74, 28)
local AutoAttackBtn, AutoAttackStroke = makeButton("Enable AutoAttack", 108, 28)

local ToggleStatus = Instance.new("TextLabel")
ToggleStatus.Size = UDim2.new(1, -20, 0, 12)
ToggleStatus.Position = UDim2.new(0, 10, 0, 142)
ToggleStatus.BackgroundTransparency = 1
ToggleStatus.Text = "AutoFarm: OFF  |  AutoAttack: OFF"
ToggleStatus.TextColor3 = THEME.Red
ToggleStatus.Font = Enum.Font.Gotham
ToggleStatus.TextSize = 9
ToggleStatus.TextTransparency = 1
ToggleStatus.TextXAlignment = Enum.TextXAlignment.Center
ToggleStatus.Parent = ScrollFrame

local Sep2 = makeSeparator(158)

--// TARGET SELECTOR
local TargetTitle = makeLabel("Target Selector", 168)

local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Size = UDim2.new(1, -20, 0, 26)
TargetDropdown.Position = UDim2.new(0, 10, 0, 186)
TargetDropdown.BackgroundColor3 = THEME.ButtonOff
TargetDropdown.Text = "Auto (Nearest)"
TargetDropdown.TextColor3 = THEME.Text
TargetDropdown.Font = Enum.Font.GothamMedium
TargetDropdown.TextSize = 11
TargetDropdown.TextTransparency = 1
TargetDropdown.BackgroundTransparency = 1
TargetDropdown.AutoButtonColor = false
TargetDropdown.Parent = ScrollFrame

local DDCorner = Instance.new("UICorner")
DDCorner.CornerRadius = UDim.new(0, 6)
DDCorner.Parent = TargetDropdown

local DDStroke = Instance.new("UIStroke")
DDStroke.Color = THEME.Stroke
DDStroke.Thickness = 1
DDStroke.Transparency = 1
DDStroke.Parent = TargetDropdown

local DDArrow = Instance.new("TextLabel")
DDArrow.Size = UDim2.new(0, 24, 1, 0)
DDArrow.Position = UDim2.new(1, -24, 0, 0)
DDArrow.BackgroundTransparency = 1
DDArrow.Text = "▼"
DDArrow.TextColor3 = THEME.Accent
DDArrow.Font = Enum.Font.GothamBold
DDArrow.TextSize = 10
DDArrow.TextTransparency = 1
DDArrow.Parent = TargetDropdown

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -20, 0, 0)
DropdownList.Position = UDim2.new(0, 10, 0, 216)
DropdownList.BackgroundColor3 = THEME.DropdownBg
DropdownList.BackgroundTransparency = 1
DropdownList.BorderSizePixel = 0
DropdownList.ClipsDescendants = true
DropdownList.ScrollBarThickness = 3
DropdownList.ScrollBarImageColor3 = THEME.Stroke
DropdownList.Visible = false
DropdownList.ZIndex = 10
DropdownList.Parent = ScrollFrame

local DDListCorner = Instance.new("UICorner")
DDListCorner.CornerRadius = UDim.new(0, 6)
DDListCorner.Parent = DropdownList

local DDListStroke = Instance.new("UIStroke")
DDListStroke.Color = THEME.Stroke
DDListStroke.Thickness = 1
DDListStroke.Transparency = 1
DDListStroke.Parent = DropdownList

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = DropdownList

local Sep3 = makeSeparator(250)

--// SERVER HOP
local ServerHopTitle = makeLabel("Auto Server Hop", 260)
local ServerHopBtn, ServerHopStroke = makeButton("Enable Auto Server Hop", 278, 28)
local MinPlayersLabel = makeLabel("Hop when players count below:", 312, THEME.SubText, 10)
local MinPlayersInput, MinPlayersStroke = makeInput("3", 328, "3")

local Sep4 = makeSeparator(362)

--// FOOTER
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 14)
CreditLabel.Position = UDim2.new(0, 0, 1, -32)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Made by Xyqwerq"
CreditLabel.TextColor3 = THEME.Credit
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.TextSize = 10
CreditLabel.TextTransparency = 1
CreditLabel.TextXAlignment = Enum.TextXAlignment.Center
CreditLabel.Parent = MainFrame

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 12)
Footer.Position = UDim2.new(0, 0, 1, -18)
Footer.BackgroundTransparency = 1
Footer.Text = "[RightShift] Hide • v17"
Footer.TextColor3 = Color3.fromRGB(120, 120, 130)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.TextTransparency = 1
Footer.TextXAlignment = Enum.TextXAlignment.Center
Footer.Parent = MainFrame

--// DOCK
local DockBtn = Instance.new("TextButton")
DockBtn.Size = UDim2.new(0, 42, 0, 42)
DockBtn.Position = UDim2.new(0, 15, 0.5, -21)
DockBtn.BackgroundColor3 = THEME.Background
DockBtn.Text = "JJS"
DockBtn.TextColor3 = THEME.Accent
DockBtn.Font = Enum.Font.GothamBold
DockBtn.TextSize = 13
DockBtn.TextTransparency = 1
DockBtn.BackgroundTransparency = 1
DockBtn.AutoButtonColor = false
DockBtn.Visible = false
DockBtn.Active = true
DockBtn.Parent = ScreenGui

local DockCorner = Instance.new("UICorner")
DockCorner.CornerRadius = UDim.new(0, 10)
DockCorner.Parent = DockBtn

local DockStroke = Instance.new("UIStroke")
DockStroke.Color = THEME.Stroke
DockStroke.Thickness = 1.5
DockStroke.Transparency = 1
DockStroke.Parent = DockBtn

--// HOVER
local function addStateHover(btn, getState)
    btn.MouseEnter:Connect(function()
        local on = getState()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = on and THEME.ButtonOnHover or THEME.ButtonOffHover
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        local on = getState()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = on and THEME.ButtonOn or THEME.ButtonOff
        }):Play()
    end)
end

addStateHover(AutoFarmBtn, function() return AutoFarmEnabled end)
addStateHover(AutoAttackBtn, function() return AutoAttackEnabled end)
addStateHover(ServerHopBtn, function() return ServerHopConfig.Enabled end)

--// TARGET HUD
local TargetHud = Instance.new("ScreenGui")
TargetHud.Name = "JJSTargetHud"
TargetHud.ResetOnSpawn = false
TargetHud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TargetHud.Parent = game.CoreGui

local HudFrame = Instance.new("Frame")
HudFrame.Size = UDim2.new(0, 170, 0, 38)
HudFrame.Position = UDim2.new(0.5, -85, 0, 15)
HudFrame.BackgroundColor3 = THEME.Background
HudFrame.BackgroundTransparency = 0.15
HudFrame.BorderSizePixel = 0
HudFrame.Visible = false
HudFrame.Active = true
HudFrame.Parent = TargetHud

local HudCorner = Instance.new("UICorner")
HudCorner.CornerRadius = UDim.new(0, 8)
HudCorner.Parent = HudFrame

local HudStroke = Instance.new("UIStroke")
HudStroke.Color = THEME.Stroke
HudStroke.Thickness = 1.5
HudStroke.Parent = HudFrame

local HudAvatar = Instance.new("ImageLabel")
HudAvatar.Size = UDim2.new(0, 28, 0, 28)
HudAvatar.Position = UDim2.new(0, 5, 0, 5)
HudAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
HudAvatar.BorderSizePixel = 0
HudAvatar.Image = ""
HudAvatar.Parent = HudFrame

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = HudAvatar

local HudName = Instance.new("TextLabel")
HudName.Size = UDim2.new(1, -40, 0, 12)
HudName.Position = UDim2.new(0, 38, 0, 5)
HudName.BackgroundTransparency = 1
HudName.Text = "Target"
HudName.TextColor3 = THEME.Text
HudName.Font = Enum.Font.GothamBold
HudName.TextSize = 11
HudName.TextXAlignment = Enum.TextXAlignment.Left
HudName.Parent = HudFrame

local HudHpBg = Instance.new("Frame")
HudHpBg.Size = UDim2.new(1, -46, 0, 6)
HudHpBg.Position = UDim2.new(0, 38, 0, 22)
HudHpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
HudHpBg.BorderSizePixel = 0
HudHpBg.Parent = HudFrame

local HudHpBgCorner = Instance.new("UICorner")
HudHpBgCorner.CornerRadius = UDim.new(0, 3)
HudHpBgCorner.Parent = HudHpBg

local HudHpFill = Instance.new("Frame")
HudHpFill.Size = UDim2.new(1, 0, 1, 0)
HudHpFill.BackgroundColor3 = THEME.Green
HudHpFill.BorderSizePixel = 0
HudHpFill.Parent = HudHpBg

local HudHpFillCorner = Instance.new("UICorner")
HudHpFillCorner.CornerRadius = UDim.new(0, 3)
HudHpFillCorner.Parent = HudHpFill

local HudHpText = Instance.new("TextLabel")
HudHpText.Size = UDim2.new(1, -46, 0, 10)
HudHpText.Position = UDim2.new(0, 38, 0, 28)
HudHpText.BackgroundTransparency = 1
HudHpText.Text = "100 / 100"
HudHpText.TextColor3 = THEME.SubText
HudHpText.Font = Enum.Font.Gotham
HudHpText.TextSize = 8
HudHpText.TextXAlignment = Enum.TextXAlignment.Left
HudHpText.Parent = HudFrame

--// ============================================
--// LOGIC
--// ============================================
local function getAlivePlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(list, p)
            end
        end
    end
    return list
end

local function getNearestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    local nearest, minDist = nil, math.huge
    for _, p in ipairs(getAlivePlayers()) do
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = p
            end
        end
    end
    return nearest
end

local function getDistanceToTarget()
    if not CurrentTarget or not CurrentTarget.Character then return math.huge end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return math.huge end
    local tr = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return math.huge end
    return (tr.Position - myChar.HumanoidRootPart.Position).Magnitude
end

local function switchTarget()
    if ManualTarget and ManualTarget.Character then
        local hum = ManualTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            CurrentTarget = ManualTarget
            return
        end
    end
    CurrentTarget = getNearestPlayer() or getAlivePlayers()[1]
end

local function updateHud()
    if not CurrentTarget or not CurrentTarget.Character then
        HudFrame.Visible = false
        return
    end
    local hum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        HudFrame.Visible = false
        return
    end
    HudFrame.Visible = true
    HudName.Text = CurrentTarget.Name
    HudHpText.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    HudHpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
    local ratio = hum.Health / hum.MaxHealth
    if ratio > 0.6 then
        HudHpFill.BackgroundColor3 = THEME.Green
    elseif ratio > 0.3 then
        HudHpFill.BackgroundColor3 = THEME.Yellow
    else
        HudHpFill.BackgroundColor3 = THEME.Red
    end
    HudAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. CurrentTarget.UserId .. "&width=150&height=150&format=png"
end

--// SMART TARGET LOCK
task.spawn(function()
    while true do
        task.wait(0.25)
        if not AutoFarmEnabled and not AutoAttackEnabled then continue end

        if ManualTarget then
            if ManualTarget.Character then
                local mHum = ManualTarget.Character:FindFirstChildOfClass("Humanoid")
                if mHum and mHum.Health > 0 then
                    CurrentTarget = ManualTarget
                    continue
                end
            end
            ManualTarget = nil
        end

        if not CurrentTarget or not CurrentTarget.Character then
            switchTarget()
            continue
        end

        local curHum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
        if not curHum or curHum.Health <= 0 then
            InCombat = false
            switchTarget()
            continue
        end

        local dist = getDistanceToTarget()

        if not AutoAttackEnabled then
            if dist > TargetLockConfig.DropDistance then
                local nearest = getNearestPlayer()
                if nearest and nearest ~= CurrentTarget then
                    CurrentTarget = nearest
                end
            end
            continue
        end

        if dist <= TargetLockConfig.EngageDistance then
            InCombat = true
            continue
        end

        InCombat = false

        if dist > TargetLockConfig.DropDistance then
            local nearest = getNearestPlayer()
            if nearest and nearest ~= CurrentTarget then
                CurrentTarget = nearest
            end
        else
            local nearest = getNearestPlayer()
            if nearest and nearest ~= CurrentTarget then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local nRoot = nearest.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and nRoot then
                    local newDist = (nRoot.Position - myRoot.Position).Magnitude
                    if newDist < dist - TargetLockConfig.SwitchMargin and newDist < TargetLockConfig.EngageDistance then
                        CurrentTarget = nearest
                    end
                end
            end
        end
    end
end)

--// AUTOFARM
local stuckTimer = 0
local lastPos = nil
local currentPath = nil
local currentWaypointIndex = 1
local lastRepathTime = 0

local function computePath(fromPos, toPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 4,
    })
    local ok = pcall(function()
        path:ComputeAsync(fromPos, toPos)
    end)
    if ok and path.Status == Enum.PathStatus.Success then
        return path
    end
    return nil
end

-- ✅ FIXED: скорость НЕ зависит от дистанции
local function positionBehindTarget()
    if not AutoFarmEnabled then return end
    if not CurrentTarget or not CurrentTarget.Character then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then return end
    if myHum.Health <= 0 then return end

    local targetRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local myPos = myRoot.Position
    local targetPos = targetRoot.Position

    local behindCF = targetRoot.CFrame * CFrame.new(0, 0, CONFIG.FOLLOW_DISTANCE)
    local behindPos = behindCF.Position
    local dist = (behindPos - myPos).Magnitude

    if dist < CONFIG.DEADZONE then
        stuckTimer = 0
        return
    end

    -- ✅ Если путь уже есть — идём по waypoint'ам, не сбрасываем
    if currentPath and dist > 15 then
        local waypoints = currentPath:GetWaypoints()
        if currentWaypointIndex <= #waypoints then
            local wp = waypoints[currentWaypointIndex]
            if wp then
                if wp.Action == Enum.PathWaypointAction.Jump then
                    pcall(function() myHum.Jump = true end)
                end
                local wpPos = wp.Position
                local wpDist = (wpPos - myPos).Magnitude
                
                if wpDist < CONFIG.WAYPOINT_REACH then
                    currentWaypointIndex = currentWaypointIndex + 1
                else
                    -- ✅ ФИКСИРОВАННЫЙ шаг — не зависит от дистанции
                    local direction = (wpPos - myPos).Unit
                    local stepSize = CONFIG.MAX_STEP  -- всегда макс
                    local newPos = myPos + direction * stepSize
                    local newCF = CFrame.new(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
                    myRoot.CFrame = newCF
                end
                return
            end
        end
        currentPath = nil
    end

    -- ✅ Если цель рядом (< 15 studs) — прямое движение БЕЗ pathfinding
    if dist <= 15 then
        local direction = (behindPos - myPos).Unit
        -- ✅ Не уменьшаем шаг по дистанции — фиксированный MAX_STEP
        local stepSize = math.max(CONFIG.MIN_STEP, math.min(dist, CONFIG.MAX_STEP))
        local newPos = myPos + direction * stepSize
        local newCF = CFrame.new(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
        myRoot.CFrame = newCF
        return
    end

    -- ✅ Цель далеко — обновляем path (не чаще REPATH_INTERVAL)
    local now = tick()
    if now - lastRepathTime > CONFIG.REPATH_INTERVAL or not currentPath then
        lastRepathTime = now
        currentPath = computePath(myPos, behindPos)
        currentWaypointIndex = 1
    end

    -- Если path построился — на след кадре пойдём по waypoint
    if currentPath then
        return
    end

    -- ✅ Fallback — прямое движение фиксированным шагом
    local direction = (behindPos - myPos).Unit
    local stepSize = CONFIG.MAX_STEP
    local newPos = myPos + direction * stepSize
    local newCF = CFrame.new(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
    myRoot.CFrame = newCF
end

-- Anti-stuck
task.spawn(function()
    while true do
        task.wait(0.5)
        if not AutoFarmEnabled then continue end
        local myChar = LocalPlayer.Character
        if not myChar then continue end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum then continue end
        
        if lastPos and (myRoot.Position - lastPos).Magnitude < 0.5 then
            stuckTimer = stuckTimer + 0.5
            if stuckTimer > 1 then
                pcall(function() myHum.Jump = true end)
                currentPath = nil
                lastRepathTime = 0
                stuckTimer = 0
            end
        else
            stuckTimer = 0
        end
        lastPos = myRoot.Position
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    stuckTimer = 0
    lastPos = nil
    currentPath = nil
    lastRepathTime = 0
end)

task.spawn(function()
    while true do
        if AutoFarmEnabled then
            positionBehindTarget()
            task.wait(CONFIG.STEP_INTERVAL)
        else
            stuckTimer = 0
            lastPos = nil
            currentPath = nil
            task.wait(0.2)
        end
    end
end)

--// AUTOATTACK
local function clickMouse()
    pcall(function()
        if typeof(mouse1click) == "function" then
            mouse1click()
        elseif typeof(mouse1down) == "function" and typeof(mouse1up) == "function" then
            mouse1down()
            task.wait(0.02)
            mouse1up()
        end
    end)
end

local function virtualClick()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(Mouse.X, Mouse.Y))
    end)
end

local function pressKey(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function activateTools()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
        end
    end
end

local function fireAllAttackRemotes()
    local targetChar = CurrentTarget and CurrentTarget.Character
    local keywords = {"attack", "hit", "m1", "combat", "damage", "swing", "punch", "melee"}
    local function matches(name)
        local lower = string.lower(name)
        for _, kw in ipairs(keywords) do
            if string.find(lower, kw) then return true end
        end
        return false
    end
    local function scanAndFire(container, depth)
        if depth > 4 then return end
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("RemoteEvent") and matches(obj.Name) then
                pcall(function() obj:FireServer() end)
                if targetChar then
                    pcall(function() obj:FireServer(targetChar) end)
                end
            elseif obj:IsA("RemoteFunction") and matches(obj.Name) then
                pcall(function() obj:InvokeServer() end)
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                scanAndFire(obj, depth + 1)
            end
        end
    end
    pcall(function() scanAndFire(game:GetService("ReplicatedStorage"), 0) end)
end

local function tryAttack()
    if not CurrentTarget or not CurrentTarget.Character then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return end

    local targetHum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end

    local dist = (myRoot.Position - targetRoot.Position).Magnitude
    if dist > 15 then return end

    pcall(function()
        myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
    end)
    task.wait(0.01)

    clickMouse()
    virtualClick()
    activateTools()
    pressKey(Enum.KeyCode.One)
    pressKey(Enum.KeyCode.Two)
    pressKey(Enum.KeyCode.Three)
    pressKey(Enum.KeyCode.Four)
    fireAllAttackRemotes()
end

task.spawn(function()
    while true do
        if AutoAttackEnabled and CurrentTarget then
            tryAttack()
            task.wait(0.12)
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while true do
        updateHud()
        task.wait(0.15)
    end
end)

--// SERVER HOP
local function getServerList()
    local servers = {}
    local placeId = game.PlaceId
    local ok, result = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
        )
    end)
    if ok and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing and server.playing > 1
               and server.playing < server.maxPlayers
               and server.id ~= game.JobId then
                table.insert(servers, {
                    id = server.id,
                    playing = server.playing,
                    maxPlayers = server.maxPlayers,
                })
            end
        end
    end
    table.sort(servers, function(a, b) return a.playing > b.playing end)
    return servers
end

local function attemptServerHop()
    local servers = getServerList()
    if #servers == 0 then
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        return false
    end
    local poolSize = math.min(#servers, 5)
    local chosen = servers[math.random(1, poolSize)]
    print("[JJS] Hop → " .. chosen.playing .. "/" .. chosen.maxPlayers)
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LocalPlayer)
    end)
    return ok
end

local function scheduleRejoinQueue()
    pcall(saveConfig)
    local restoreCode = 'task.wait(5)\n'
        .. 'if _G.JJS_SCRIPT_LOADED then _G.JJS_SCRIPT_LOADED = nil end\n'
        .. 'loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()'
    local queued = false
    pcall(function()
        if typeof(queue_on_teleport) == "function" then
            queue_on_teleport(restoreCode); queued = true
        end
    end)
    if not queued then
        pcall(function()
            if typeof(queueonteleport) == "function" then
                queueonteleport(restoreCode); queued = true
            end
        end)
    end
    if not queued then
        pcall(function()
            if syn and typeof(syn.queue_on_teleport) == "function" then
                syn.queue_on_teleport(restoreCode); queued = true
            end
        end)
    end
    if not queued then
        pcall(function()
            if fluxus and typeof(fluxus.queue_on_teleport) == "function" then
                fluxus.queue_on_teleport(restoreCode); queued = true
            end
        end)
    end
    if queued then
        print("[JJS] Rejoin queue ✓")
    end
end

task.spawn(function()
    while true do
        task.wait(ServerHopConfig.CheckInterval)
        if not ServerHopConfig.Enabled then continue end
        if tick() - ServerHopConfig.LastHop < 20 then continue end

        local playerCount = #Players:GetPlayers()
        if playerCount < ServerHopConfig.MinPlayers then
            print("[JJS] Only " .. playerCount .. " players → hop")
            ServerHopConfig.LastHop = tick()
            scheduleRejoinQueue()
            task.wait(0.5)
            local oldJob = game.JobId
            pcall(attemptServerHop)
            task.wait(5)
            if game.JobId == oldJob then
                warn("[JJS] Retry...")
                pcall(attemptServerHop)
                task.wait(5)
                if game.JobId == oldJob then
                    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
                end
            end
        end
    end
end)

--// ANTIKICK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" and self == LocalPlayer then
            warn("[JJS AntiKick] Kick blocked!")
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

--// HIDE / SHOW
local GuiHidden = false

local function hideGui()
    if GuiHidden then return end
    GuiHidden = true
    HudFrame.Visible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    task.wait(0.3)
    MainFrame.Visible = false
    DockBtn.Visible = true
    TweenService:Create(DockBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0, TextTransparency = 0
    }):Play()
    TweenService:Create(DockStroke, TweenInfo.new(0.4), {Transparency = 0.2}):Play()
end

local function showGui()
    if not GuiHidden then return end
    GuiHidden = false
    TweenService:Create(DockBtn, TweenInfo.new(0.25), {
        BackgroundTransparency = 1, TextTransparency = 1
    }):Play()
    TweenService:Create(DockStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
    task.wait(0.25)
    DockBtn.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, GUI_W, 0, GUI_H),
        Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.4), {Transparency = 0.1}):Play()
end

CloseBtn.MouseButton1Click:Connect(hideGui)

--// DRAGGING
local dragging, dragInput, dragStart, startPos
local dockDragging, dockDragInput, dockDragStart, dockStartPos, dockMoved
local hudDragging, hudDragInput, hudDragStart, hudStartPos

DockBtn.MouseButton1Click:Connect(function()
    if not dockMoved then showGui() end
end)

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
DragBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

DockBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dockDragging = true
        dockMoved = false
        dockDragStart = input.Position
        dockStartPos = DockBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dockDragging = false
                task.wait(0.05)
                dockMoved = false
            end
        end)
    end
end)
DockBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dockDragInput = input
    end
end)

HudFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hudDragging = true
        hudDragStart = input.Position
        hudStartPos = HudFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then hudDragging = false end
        end)
    end
end)
HudFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        hudDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    if input == dockDragInput and dockDragging then
        local delta = input.Position - dockDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then dockMoved = true end
        DockBtn.Position = UDim2.new(dockStartPos.X.Scale, dockStartPos.X.Offset + delta.X, dockStartPos.Y.Scale, dockStartPos.Y.Offset + delta.Y)
    end
    if input == hudDragInput and hudDragging then
        local delta = input.Position - hudDragStart
        HudFrame.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y)
    end
    if resizing then
        local delta = input.Position - resizeStart
        local newW = math.max(MIN_WIDTH, resizeStartSize.X + delta.X)
        local newH = math.max(MIN_HEIGHT, resizeStartSize.Y + delta.Y)
        MainFrame.Size = UDim2.new(0, newW, 0, newH)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == HOTKEY then
        if GuiHidden then showGui() else hideGui() end
    end
end)

--// BUTTON LOGIC
local function refreshStatus()
    ToggleStatus.Text = "AutoFarm: " .. (AutoFarmEnabled and "ON" or "OFF") ..
                        " | AutoAttack: " .. (AutoAttackEnabled and "ON" or "OFF")
    ToggleStatus.TextColor3 = (AutoFarmEnabled or AutoAttackEnabled) and THEME.Green or THEME.Red
end

AutoFarmBtn.MouseButton1Click:Connect(function()
    AutoFarmEnabled = not AutoFarmEnabled
    AutoFarmBtn.Text = AutoFarmEnabled and "Disable AutoFarm" or "Enable AutoFarm"
    TweenService:Create(AutoFarmBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = AutoFarmEnabled and THEME.ButtonOn or THEME.ButtonOff
    }):Play()
    if AutoFarmEnabled and not CurrentTarget then switchTarget() end
    refreshStatus()
    pcall(saveConfig)
end)

AutoAttackBtn.MouseButton1Click:Connect(function()
    AutoAttackEnabled = not AutoAttackEnabled
    AutoAttackBtn.Text = AutoAttackEnabled and "Disable AutoAttack" or "Enable AutoAttack"
    TweenService:Create(AutoAttackBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = AutoAttackEnabled and THEME.ButtonOn or THEME.ButtonOff
    }):Play()
    if AutoAttackEnabled and not CurrentTarget then switchTarget() end
    refreshStatus()
    pcall(saveConfig)
end)

ServerHopBtn.MouseButton1Click:Connect(function()
    ServerHopConfig.Enabled = not ServerHopConfig.Enabled
    ServerHopBtn.Text = ServerHopConfig.Enabled and "Disable Auto Server Hop" or "Enable Auto Server Hop"
    TweenService:Create(ServerHopBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = ServerHopConfig.Enabled and THEME.ButtonOn or THEME.ButtonOff
    }):Play()
    pcall(saveConfig)
end)

MinPlayersInput.FocusLost:Connect(function()
    local val = tonumber(MinPlayersInput.Text)
    if val and val > 0 then ServerHopConfig.MinPlayers = math.floor(val)
    else MinPlayersInput.Text = tostring(ServerHopConfig.MinPlayers) end
    pcall(saveConfig)
end)

DockBtn.MouseEnter:Connect(function()
    TweenService:Create(DockBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ButtonOn}):Play()
end)
DockBtn.MouseLeave:Connect(function()
    TweenService:Create(DockBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Background}):Play()
end)

--// DROPDOWN
local DropdownOpen = false

local function rebuildDropdown()
    for _, c in ipairs(DropdownList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, -4, 0, 22)
    autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    autoBtn.BackgroundTransparency = 0.4
    autoBtn.Text = "  Auto (Nearest)"
    autoBtn.TextColor3 = THEME.Accent
    autoBtn.Font = Enum.Font.GothamMedium
    autoBtn.TextSize = 10
    autoBtn.TextXAlignment = Enum.TextXAlignment.Left
    autoBtn.AutoButtonColor = false
    autoBtn.Parent = DropdownList
    local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 4); c1.Parent = autoBtn
    autoBtn.MouseButton1Click:Connect(function()
        ManualTarget = nil
        TargetDropdown.Text = "Auto (Nearest)"
        switchTarget()
        DropdownList.Visible = false
        DropdownOpen = false
    end)
    for _, p in ipairs(getAlivePlayers()) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, -4, 0, 22)
        item.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        item.BackgroundTransparency = 0.4
        item.Text = "  " .. p.Name
        item.TextColor3 = THEME.Text
        item.Font = Enum.Font.Gotham
        item.TextSize = 10
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.AutoButtonColor = false
        item.Parent = DropdownList
        local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 4); c2.Parent = item
        item.MouseEnter:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = THEME.ButtonOn, BackgroundTransparency = 0}):Play()
        end)
        item.MouseLeave:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70), BackgroundTransparency = 0.4}):Play()
        end)
        item.MouseButton1Click:Connect(function()
            ManualTarget = p
            CurrentTarget = p
            TargetDropdown.Text = p.Name
            DropdownList.Visible = false
            DropdownOpen = false
        end)
    end
    local contentH = (#DropdownList:GetChildren() - 1) * 24
    local maxH = 100
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, math.max(contentH, 5))
    DropdownList.Size = UDim2.new(1, -20, 0, math.min(math.max(contentH, 22), maxH))
end

TargetDropdown.MouseButton1Click:Connect(function()
    DropdownOpen = not DropdownOpen
    if DropdownOpen then
        rebuildDropdown()
        DropdownList.Visible = true
        TweenService:Create(DropdownList, TweenInfo.new(0.25), {BackgroundTransparency = 0.05}):Play()
    else
        DropdownList.Visible = false
    end
end)

--// ANIMATION
local function tween(obj, time, props)
    return TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

task.spawn(function()
    tween(MainFrame, 0.8, {BackgroundTransparency = 0}):Play()
    tween(MainStroke, 0.8, {Transparency = 0.1}):Play()
    tween(DragBar, 0.6, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    tween(Sep1, 0.8, {BackgroundTransparency = 0.3}):Play()
    tween(Sep2, 0.8, {BackgroundTransparency = 0.3}):Play()
    tween(Sep3, 0.8, {BackgroundTransparency = 0.3}):Play()
    tween(Sep4, 0.8, {BackgroundTransparency = 0.3}):Play()
    task.wait(0.15)

    HelloLabel.Text = "Hello, " .. LocalPlayer.Name
    tween(HelloLabel, 0.6, {TextTransparency = 0}):Play()
    local origPos = HelloLabel.Position
    HelloLabel.Position = UDim2.new(0, 10, 0, 12)
    tween(HelloLabel, 0.6, {Position = origPos}):Play()

    task.wait(0.3)
    StatusLabel.Text = "Script for JJS starting..."
    tween(StatusLabel, 0.5, {TextTransparency = 0}):Play()

    task.wait(0.5)
    ScanLabel.Text = "Scanning Players..."
    tween(ScanLabel, 0.4, {TextTransparency = 0}):Play()
    local total = #Players:GetPlayers()
    for i = 1, total do
        ScanLabel.Text = "Scanning Players.. " .. i .. "/" .. total
        task.wait(0.08)
    end
    ScanLabel.Text = "Scanning Players.. " .. total .. "/" .. total .. " ✓"
    task.wait(0.4)

    local saved = nil
    pcall(function() saved = loadConfig() end)
    if saved then
        StatusLabel.Text = "Restoring settings..."
        StatusLabel.TextColor3 = THEME.Accent
        task.wait(0.6)

        if saved.AutoFarmEnabled then
            AutoFarmEnabled = true
            AutoFarmBtn.Text = "Disable AutoFarm"
            AutoFarmBtn.BackgroundColor3 = THEME.ButtonOn
        end
        if saved.AutoAttackEnabled then
            AutoAttackEnabled = true
            AutoAttackBtn.Text = "Disable AutoAttack"
            AutoAttackBtn.BackgroundColor3 = THEME.ButtonOn
        end
        if saved.ServerHopEnabled then
            ServerHopConfig.Enabled = true
            ServerHopConfig.MinPlayers = saved.ServerHopMinPlayers or 3
            ServerHopBtn.Text = "Disable Auto Server Hop"
            ServerHopBtn.BackgroundColor3 = THEME.ButtonOn
            MinPlayersInput.Text = tostring(ServerHopConfig.MinPlayers)
        end

        StatusLabel.Text = "Settings restored ✓"
        StatusLabel.TextColor3 = THEME.Green
        task.wait(0.5)

        if AutoFarmEnabled or AutoAttackEnabled then
            switchTarget()
        end
    end

    StatusLabel.Text = "Loaded • v17"
    StatusLabel.TextColor3 = THEME.Green

    tween(AutoFarmBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(AutoFarmStroke, 0.5, {Transparency = 0.3}):Play()
    tween(AutoAttackBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(AutoAttackStroke, 0.5, {Transparency = 0.3}):Play()
    tween(ToggleStatus, 0.5, {TextTransparency = 0}):Play()
    tween(TargetTitle, 0.5, {TextTransparency = 0}):Play()
    tween(TargetDropdown, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(DDStroke, 0.5, {Transparency = 0.3}):Play()
    tween(DDArrow, 0.5, {TextTransparency = 0}):Play()

    tween(ServerHopTitle, 0.5, {TextTransparency = 0}):Play()
    tween(ServerHopBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(ServerHopStroke, 0.5, {Transparency = 0.3}):Play()
    tween(MinPlayersLabel, 0.5, {TextTransparency = 0}):Play()
    tween(MinPlayersInput, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(MinPlayersStroke, 0.5, {Transparency = 0.3}):Play()

    tween(CreditLabel, 0.6, {TextTransparency = 0}):Play()
    tween(Footer, 0.5, {TextTransparency = 0}):Play()
    tween(CloseBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(ResizeIcon, 0.5, {TextTransparency = 0.2}):Play()

    refreshStatus()
end)

_G.JJS_CLEANUP = function()
    pcall(function() saveConfig() end)
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() TargetHud:Destroy() end)
end

print("[JJS Script v17] Loaded for " .. LocalPlayer.Name)
print("[JJS Script v17] Made by Xyqwerq | Fast Movement")
