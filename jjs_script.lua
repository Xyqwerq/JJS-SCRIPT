--// ============================================
--// JJS Script v11 for Delta Executor
--// + WORKING AutoAttack (Multi-Method) | + CFrame-Step AutoFarm
--// Made by Xyqwerq
--// ============================================

--// ============ ЗАЩИТА ОТ ПОВТОРНОГО ЗАПУСКА ============
if _G.JJS_SCRIPT_LOADED then
    warn("[JJS Script] Уже запущен! Удаляю старый экземпляр...")
    if _G.JJS_CLEANUP then pcall(_G.JJS_CLEANUP) end
end
_G.JJS_SCRIPT_LOADED = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// ============ ЦВЕТА ============
local THEME = {
    Background     = Color3.fromRGB(35, 35, 40),
    BackgroundDark = Color3.fromRGB(28, 28, 33),
    Stroke         = Color3.fromRGB(160, 60, 255),
    Text           = Color3.fromRGB(255, 255, 255),
    SubText        = Color3.fromRGB(200, 200, 210),
    Accent         = Color3.fromRGB(160, 60, 255),
    ButtonOff      = Color3.fromRGB(55, 55, 65),
    ButtonOn       = Color3.fromRGB(120, 50, 200),
    Green          = Color3.fromRGB(90, 255, 130),
    Red            = Color3.fromRGB(255, 90, 90),
    Credit         = Color3.fromRGB(180, 120, 255),
    DropdownBg     = Color3.fromRGB(45, 45, 52),
}

local HOTKEY = Enum.KeyCode.RightShift
local GUI_W = 240
local GUI_H = 350
local MIN_WIDTH = 210
local MIN_HEIGHT = 320

--// ============ НАСТРОЙКИ AUTOFARM ============
local CONFIG = {
    FOLLOW_DISTANCE = 1.5,     -- очень близко
    STEP_INTERVAL   = 0.04,
    STEP_SPEED      = 0.45,
    MAX_STEP        = 2,
    DEADZONE        = 1,
    JUMP_ON_STUCK   = true,
}

--// ============ УДАЛЯЕМ СТАРЫЕ GUI ============
for _, name in ipairs({"JJSScriptGui", "JJSTargetHud"}) do
    if game.CoreGui:FindFirstChild(name) then
        game.CoreGui[name]:Destroy()
    end
end

--// ============================================
--// ГЛАВНОЕ GUI
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
DragBar.Text = "JJS Script v11"
DragBar.TextColor3 = THEME.Accent
DragBar.Font = Enum.Font.GothamBold
DragBar.TextSize = 11
DragBar.TextTransparency = 1
DragBar.Parent = MainFrame

local DragBarCorner = Instance.new("UICorner")
DragBarCorner.CornerRadius = UDim.new(0, 10)
DragBarCorner.Parent = DragBar

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

local HelloLabel = Instance.new("TextLabel")
HelloLabel.Size = UDim2.new(1, -20, 0, 26)
HelloLabel.Position = UDim2.new(0, 10, 0, 28)
HelloLabel.BackgroundTransparency = 1
HelloLabel.Text = ""
HelloLabel.TextColor3 = THEME.Text
HelloLabel.Font = Enum.Font.GothamBold
HelloLabel.TextSize = 16
HelloLabel.TextTransparency = 1
HelloLabel.TextXAlignment = Enum.TextXAlignment.Center
HelloLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 12)
StatusLabel.Position = UDim2.new(0, 10, 0, 56)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = THEME.SubText
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local ScanLabel = Instance.new("TextLabel")
ScanLabel.Size = UDim2.new(1, -20, 0, 12)
ScanLabel.Position = UDim2.new(0, 10, 0, 70)
ScanLabel.BackgroundTransparency = 1
ScanLabel.Text = ""
ScanLabel.TextColor3 = THEME.Text
ScanLabel.Font = Enum.Font.GothamMedium
ScanLabel.TextSize = 10
ScanLabel.TextTransparency = 1
ScanLabel.TextXAlignment = Enum.TextXAlignment.Center
ScanLabel.Parent = MainFrame

local function makeSeparator(y)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, y)
    sep.BackgroundColor3 = THEME.Stroke
    sep.BackgroundTransparency = 1
    sep.BorderSizePixel = 0
    sep.Parent = MainFrame
    return sep
end
local Sep1 = makeSeparator(90)

local AutoFarmBtn = Instance.new("TextButton")
AutoFarmBtn.Size = UDim2.new(1, -20, 0, 28)
AutoFarmBtn.Position = UDim2.new(0, 10, 0, 100)
AutoFarmBtn.BackgroundColor3 = THEME.ButtonOff
AutoFarmBtn.Text = "Enable AutoFarm"
AutoFarmBtn.TextColor3 = THEME.Text
AutoFarmBtn.Font = Enum.Font.GothamBold
AutoFarmBtn.TextSize = 11
AutoFarmBtn.TextTransparency = 1
AutoFarmBtn.BackgroundTransparency = 1
AutoFarmBtn.AutoButtonColor = false
AutoFarmBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = AutoFarmBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = THEME.Stroke
BtnStroke.Thickness = 1
BtnStroke.Transparency = 1
BtnStroke.Parent = AutoFarmBtn

local AutoAttackBtn = Instance.new("TextButton")
AutoAttackBtn.Size = UDim2.new(1, -20, 0, 28)
AutoAttackBtn.Position = UDim2.new(0, 10, 0, 134)
AutoAttackBtn.BackgroundColor3 = THEME.ButtonOff
AutoAttackBtn.Text = "Enable AutoAttack"
AutoAttackBtn.TextColor3 = THEME.Text
AutoAttackBtn.Font = Enum.Font.GothamBold
AutoAttackBtn.TextSize = 11
AutoAttackBtn.TextTransparency = 1
AutoAttackBtn.BackgroundTransparency = 1
AutoAttackBtn.AutoButtonColor = false
AutoAttackBtn.Parent = MainFrame

local Btn2Corner = Instance.new("UICorner")
Btn2Corner.CornerRadius = UDim.new(0, 6)
Btn2Corner.Parent = AutoAttackBtn

local Btn2Stroke = Instance.new("UIStroke")
Btn2Stroke.Color = THEME.Stroke
Btn2Stroke.Thickness = 1
Btn2Stroke.Transparency = 1
Btn2Stroke.Parent = AutoAttackBtn

local ToggleStatus = Instance.new("TextLabel")
ToggleStatus.Size = UDim2.new(1, -20, 0, 12)
ToggleStatus.Position = UDim2.new(0, 10, 0, 168)
ToggleStatus.BackgroundTransparency = 1
ToggleStatus.Text = "AutoFarm: OFF  |  AutoAttack: OFF"
ToggleStatus.TextColor3 = THEME.Red
ToggleStatus.Font = Enum.Font.Gotham
ToggleStatus.TextSize = 9
ToggleStatus.TextTransparency = 1
ToggleStatus.TextXAlignment = Enum.TextXAlignment.Center
ToggleStatus.Parent = MainFrame

local Sep2 = makeSeparator(184)

local TargetTitle = Instance.new("TextLabel")
TargetTitle.Size = UDim2.new(1, -20, 0, 14)
TargetTitle.Position = UDim2.new(0, 10, 0, 192)
TargetTitle.BackgroundTransparency = 1
TargetTitle.Text = "Target Selector"
TargetTitle.TextColor3 = THEME.Accent
TargetTitle.Font = Enum.Font.GothamBold
TargetTitle.TextSize = 11
TargetTitle.TextTransparency = 1
TargetTitle.TextXAlignment = Enum.TextXAlignment.Left
TargetTitle.Parent = MainFrame

local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Size = UDim2.new(1, -20, 0, 26)
TargetDropdown.Position = UDim2.new(0, 10, 0, 210)
TargetDropdown.BackgroundColor3 = THEME.ButtonOff
TargetDropdown.Text = "Auto (Nearest)"
TargetDropdown.TextColor3 = THEME.Text
TargetDropdown.Font = Enum.Font.GothamMedium
TargetDropdown.TextSize = 11
TargetDropdown.TextTransparency = 1
TargetDropdown.BackgroundTransparency = 1
TargetDropdown.AutoButtonColor = false
TargetDropdown.Parent = MainFrame

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
DropdownList.Position = UDim2.new(0, 10, 0, 240)
DropdownList.BackgroundColor3 = THEME.DropdownBg
DropdownList.BackgroundTransparency = 1
DropdownList.BorderSizePixel = 0
DropdownList.ClipsDescendants = true
DropdownList.ScrollBarThickness = 3
DropdownList.ScrollBarImageColor3 = THEME.Stroke
DropdownList.Visible = false
DropdownList.ZIndex = 10
DropdownList.Parent = MainFrame

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
Footer.Text = "[RightShift] • AntiKick ON • v11"
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

--// HUD
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
--// ЛОГИКА
--// ============================================
local AutoFarmEnabled = false
local AutoAttackEnabled = false
local CurrentTarget = nil
local ManualTarget = nil

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
        HudHpFill.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    else
        HudHpFill.BackgroundColor3 = THEME.Red
    end
    HudAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. CurrentTarget.UserId .. "&width=150&height=150&format=png"
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if not AutoFarmEnabled and not AutoAttackEnabled then continue end
        if CurrentTarget then
            local char = CurrentTarget.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                task.wait(0.2)
                switchTarget()
            end
        else
            switchTarget()
        end
    end
end)

--// ============================================
--// 🚀 AUTOFARM — CFrame Stepping
--// ============================================
local stuckTimer = 0
local lastPos = nil

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

    -- Позиция сзади впритык
    local behindCF = targetRoot.CFrame * CFrame.new(0, 0, CONFIG.FOLLOW_DISTANCE)
    local behindPos = behindCF.Position
    local dist = (behindPos - myPos).Magnitude

    if dist < CONFIG.DEADZONE then
        stuckTimer = 0
        return
    end

    local direction = (behindPos - myPos).Unit
    local stepSize = math.min(dist * CONFIG.STEP_SPEED, CONFIG.MAX_STEP)
    local newPos = myPos + direction * stepSize

    local newCF = CFrame.new(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
    myRoot.CFrame = newCF

    if CONFIG.JUMP_ON_STUCK then
        if lastPos and (myPos - lastPos).Magnitude < 0.3 then
            stuckTimer = stuckTimer + CONFIG.STEP_INTERVAL
            if stuckTimer > 0.5 then
                pcall(function() myHum.Jump = true end)
                stuckTimer = 0
            end
        else
            stuckTimer = 0
        end
        lastPos = myPos
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    stuckTimer = 0
    lastPos = nil
end)

task.spawn(function()
    while true do
        if AutoFarmEnabled then
            positionBehindTarget()
            task.wait(CONFIG.STEP_INTERVAL)
        else
            stuckTimer = 0
            lastPos = nil
            task.wait(0.2)
        end
    end
end)

--// ============================================
--// ⚔️ AUTOATTACK v11 — Multi-Method
--// ============================================

-- Нажатие клавиши через VirtualInputManager
local function pressKey(keyCode)
    pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

-- Активация всех инструментов
local function activateAllTools()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    -- Инструменты в руках
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
        end
    end
    
    -- Инструменты в рюкзаке
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool.Parent = myChar end)
                task.wait(0.02)
                pcall(function() tool:Activate() end)
            end
        end
    end
end

-- Прямой вызов remote'ов атаки
local function fireAttackRemotes(targetChar)
    if not targetChar then return end
    
    local remotePaths = {
        {"ReplicatedStorage", "Remotes", "Attack"},
        {"ReplicatedStorage", "Remotes", "Combat", "Attack"},
        {"ReplicatedStorage", "Remotes", "Combat", "M1"},
        {"ReplicatedStorage", "Remotes", "Skill"},
        {"ReplicatedStorage", "Remotes", "UseSkill"},
        {"ReplicatedStorage", "Remotes", "Hit"},
        {"ReplicatedStorage", "RemoteEvents", "Attack"},
        {"ReplicatedStorage", "Packages", "Combat", "Attack"},
        {"ReplicatedStorage", "Events", "Attack"},
        {"ReplicatedStorage", "Shared", "Attack"},
    }
    
    for _, path in ipairs(remotePaths) do
        local obj = game
        local ok = true
        for _, name in ipairs(path) do
            if obj then
                obj = obj:FindFirstChild(name)
            else
                ok = false
                break
            end
        end
        if ok and obj then
            if obj:IsA("RemoteEvent") then
                pcall(function() obj:FireServer() end)
                pcall(function() obj:FireServer(targetChar) end)
                pcall(function() obj:FireServer(targetChar, "M1") end)
            elseif obj:IsA("RemoteFunction") then
                pcall(function() obj:InvokeServer() end)
                pcall(function() obj:InvokeServer(targetChar) end)
            end
        end
    end
end

-- Основная функция атаки
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
    if dist > 12 then return end

    -- Метод 1: Клик M1
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)

    -- Метод 2: Активация Tool'ов
    activateAllTools()

    -- Метод 3: Нажатие клавиш 1-4 (скиллы)
    pressKey(Enum.KeyCode.One)
    pressKey(Enum.KeyCode.Two)
    pressKey(Enum.KeyCode.Three)
    pressKey(Enum.KeyCode.Four)

    -- Метод 4: Remote'ы
    fireAttackRemotes(CurrentTarget.Character)
end

task.spawn(function()
    while true do
        if AutoAttackEnabled and CurrentTarget then
            tryAttack()
            task.wait(0.15)
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

--// ============================================
--// 🛡️ ANTIKICK
--// ============================================
local antiKickEnabled = true

LocalPlayer.Idled:Connect(function()
    if not antiKickEnabled then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

task.spawn(function()
    while antiKickEnabled do
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
        if antiKickEnabled and method == "Kick" and self == LocalPlayer then
            warn("[JJS AntiKick] Попытка кика заблокирована!")
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

--// ============================================
--// СКРЫТИЕ / ПОКАЗ
--// ============================================
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

--// Перетаскивание
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

--// Кнопки
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
end)

AutoAttackBtn.MouseButton1Click:Connect(function()
    AutoAttackEnabled = not AutoAttackEnabled
    AutoAttackBtn.Text = AutoAttackEnabled and "Disable AutoAttack" or "Enable AutoAttack"
    TweenService:Create(AutoAttackBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = AutoAttackEnabled and THEME.ButtonOn or THEME.ButtonOff
    }):Play()
    if AutoAttackEnabled and not CurrentTarget then switchTarget() end
    refreshStatus()
end)

local function addHover(btn, getState)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = getState() and Color3.fromRGB(140, 60, 220) or Color3.fromRGB(75, 75, 90)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = getState() and THEME.ButtonOn or THEME.ButtonOff
        }):Play()
    end)
end
addHover(AutoFarmBtn, function() return AutoFarmEnabled end)
addHover(AutoAttackBtn, function() return AutoAttackEnabled end)

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

--// АНИМАЦИЯ
local function tween(obj, time, props)
    return TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

task.spawn(function()
    tween(MainFrame, 0.8, {BackgroundTransparency = 0}):Play()
    tween(MainStroke, 0.8, {Transparency = 0.1}):Play()
    tween(DragBar, 0.6, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    tween(Sep1, 0.8, {BackgroundTransparency = 0.3}):Play()
    tween(Sep2, 0.8, {BackgroundTransparency = 0.3}):Play()
    task.wait(0.15)

    HelloLabel.Text = "Hello, " .. LocalPlayer.Name
    tween(HelloLabel, 0.6, {TextTransparency = 0}):Play()
    local origPos = HelloLabel.Position
    HelloLabel.Position = UDim2.new(0, 10, 0, 38)
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

    StatusLabel.Text = "Loaded • AntiKick ON"
    StatusLabel.TextColor3 = THEME.Green

    tween(AutoFarmBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(BtnStroke, 0.5, {Transparency = 0.3}):Play()
    tween(AutoAttackBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(Btn2Stroke, 0.5, {Transparency = 0.3}):Play()
    tween(ToggleStatus, 0.5, {TextTransparency = 0}):Play()
    tween(TargetTitle, 0.5, {TextTransparency = 0}):Play()
    tween(TargetDropdown, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(DDStroke, 0.5, {Transparency = 0.3}):Play()
    tween(DDArrow, 0.5, {TextTransparency = 0}):Play()
    tween(CreditLabel, 0.6, {TextTransparency = 0}):Play()
    tween(Footer, 0.5, {TextTransparency = 0}):Play()
    tween(CloseBtn, 0.5, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    tween(ResizeIcon, 0.5, {TextTransparency = 0.2}):Play()

    refreshStatus()
end)

_G.JJS_CLEANUP = function()
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() TargetHud:Destroy() end)
end

print("[JJS Script v11] Loaded for " .. LocalPlayer.Name)
print("[JJS Script v11] Made by Xyqwerq | CFrame-step AutoFarm + Multi-method AutoAttack")
