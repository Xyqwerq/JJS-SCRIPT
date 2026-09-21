--// ============================================
--// JJS Script v2 for Delta Executor
--// + AutoAttack | + Target Selector | + Target HUD
--// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// ============ НАСТРОЙКИ ЦВЕТОВ ============
local THEME = {
    Background   = Color3.fromRGB(35, 35, 40),
    Stroke       = Color3.fromRGB(160, 60, 255),
    Text         = Color3.fromRGB(255, 255, 255),
    SubText      = Color3.fromRGB(200, 200, 210),
    Accent       = Color3.fromRGB(160, 60, 255),
    ButtonOff    = Color3.fromRGB(55, 55, 65),
    ButtonOn     = Color3.fromRGB(120, 50, 200),
    Green        = Color3.fromRGB(90, 255, 130),
    Red          = Color3.fromRGB(255, 90, 90),
}

--// ============ УДАЛЯЕМ СТАРЫЙ GUI ============
if game.CoreGui:FindFirstChild("JJSScriptGui") then
    game.CoreGui.JJSScriptGui:Destroy()
end
if game.CoreGui:FindFirstChild("JJSTargetHud") then
    game.CoreGui.JJSTargetHud:Destroy()
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
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Stroke
MainStroke.Thickness = 2
MainStroke.Transparency = 1
MainStroke.Parent = MainFrame

local InnerStroke = Instance.new("UIStroke")
InnerStroke.Color = THEME.Stroke
InnerStroke.Thickness = 1
InnerStroke.Transparency = 1
InnerStroke.Parent = MainFrame

--// Заголовок (перетаскивание)
local DragBar = Instance.new("TextLabel")
DragBar.Size = UDim2.new(1, 0, 0, 28)
DragBar.Position = UDim2.new(0, 0, 0, 0)
DragBar.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
DragBar.BackgroundTransparency = 1
DragBar.BorderSizePixel = 0
DragBar.Text = "JJS Script v2"
DragBar.TextColor3 = THEME.Accent
DragBar.Font = Enum.Font.GothamBold
DragBar.TextSize = 13
DragBar.TextTransparency = 1
DragBar.Parent = MainFrame

--// ============ ГЛАВНЫЙ ТЕКСТ ============
local HelloLabel = Instance.new("TextLabel")
HelloLabel.Size = UDim2.new(1, -40, 0, 36)
HelloLabel.Position = UDim2.new(0, 20, 0, 45)
HelloLabel.BackgroundTransparency = 1
HelloLabel.Text = ""
HelloLabel.TextColor3 = THEME.Text
HelloLabel.Font = Enum.Font.GothamBold
HelloLabel.TextSize = 22
HelloLabel.TextTransparency = 1
HelloLabel.TextXAlignment = Enum.TextXAlignment.Center
HelloLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 16)
StatusLabel.Position = UDim2.new(0, 20, 0, 82)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = THEME.SubText
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local ScanLabel = Instance.new("TextLabel")
ScanLabel.Size = UDim2.new(1, -40, 0, 16)
ScanLabel.Position = UDim2.new(0, 20, 0, 100)
ScanLabel.BackgroundTransparency = 1
ScanLabel.Text = ""
ScanLabel.TextColor3 = THEME.Text
ScanLabel.Font = Enum.Font.GothamMedium
ScanLabel.TextSize = 12
ScanLabel.TextTransparency = 1
ScanLabel.TextXAlignment = Enum.TextXAlignment.Center
ScanLabel.Parent = MainFrame

--// ============ РАЗДЕЛИТЕЛЬ ============
local function makeSeparator(y)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -40, 0, 1)
    sep.Position = UDim2.new(0, 20, 0, y)
    sep.BackgroundColor3 = THEME.Stroke
    sep.BackgroundTransparency = 1
    sep.BorderSizePixel = 0
    sep.Parent = MainFrame
    return sep
end
local Sep1 = makeSeparator(122)

--// ============ КНОПКА AUTO FARM ============
local AutoFarmBtn = Instance.new("TextButton")
AutoFarmBtn.Size = UDim2.new(1, -40, 0, 36)
AutoFarmBtn.Position = UDim2.new(0, 20, 0, 135)
AutoFarmBtn.BackgroundColor3 = THEME.ButtonOff
AutoFarmBtn.Text = "Enable AutoFarm"
AutoFarmBtn.TextColor3 = THEME.Text
AutoFarmBtn.Font = Enum.Font.GothamBold
AutoFarmBtn.TextSize = 14
AutoFarmBtn.TextTransparency = 1
AutoFarmBtn.BackgroundTransparency = 1
AutoFarmBtn.AutoButtonColor = false
AutoFarmBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = AutoFarmBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = THEME.Stroke
BtnStroke.Thickness = 1.5
BtnStroke.Transparency = 1
BtnStroke.Parent = AutoFarmBtn

--// ============ КНОПКА AUTO ATTACK ============
local AutoAttackBtn = Instance.new("TextButton")
AutoAttackBtn.Size = UDim2.new(1, -40, 0, 36)
AutoAttackBtn.Position = UDim2.new(0, 20, 0, 180)
AutoAttackBtn.BackgroundColor3 = THEME.ButtonOff
AutoAttackBtn.Text = "Enable AutoAttack"
AutoAttackBtn.TextColor3 = THEME.Text
AutoAttackBtn.Font = Enum.Font.GothamBold
AutoAttackBtn.TextSize = 14
AutoAttackBtn.TextTransparency = 1
AutoAttackBtn.BackgroundTransparency = 1
AutoAttackBtn.AutoButtonColor = false
AutoAttackBtn.Parent = MainFrame

local Btn2Corner = Instance.new("UICorner")
Btn2Corner.CornerRadius = UDim.new(0, 8)
Btn2Corner.Parent = AutoAttackBtn

local Btn2Stroke = Instance.new("UIStroke")
Btn2Stroke.Color = THEME.Stroke
Btn2Stroke.Thickness = 1.5
Btn2Stroke.Transparency = 1
Btn2Stroke.Parent = AutoAttackBtn

--// ============ СТАТУСЫ ============
local ToggleStatus = Instance.new("TextLabel")
ToggleStatus.Size = UDim2.new(1, -40, 0, 14)
ToggleStatus.Position = UDim2.new(0, 20, 0, 220)
ToggleStatus.BackgroundTransparency = 1
ToggleStatus.Text = "AutoFarm: OFF  |  AutoAttack: OFF"
ToggleStatus.TextColor3 = THEME.Red
ToggleStatus.Font = Enum.Font.Gotham
ToggleStatus.TextSize = 11
ToggleStatus.TextTransparency = 1
ToggleStatus.TextXAlignment = Enum.TextXAlignment.Center
ToggleStatus.Parent = MainFrame

local Sep2 = makeSeparator(240)

--// ============ ВЫБОР ТАРГЕТА ============
local TargetTitle = Instance.new("TextLabel")
TargetTitle.Size = UDim2.new(1, -40, 0, 16)
TargetTitle.Position = UDim2.new(0, 20, 0, 250)
TargetTitle.BackgroundTransparency = 1
TargetTitle.Text = "Target Selector"
TargetTitle.TextColor3 = THEME.Accent
TargetTitle.Font = Enum.Font.GothamBold
TargetTitle.TextSize = 12
TargetTitle.TextTransparency = 1
TargetTitle.TextXAlignment = Enum.TextXAlignment.Left
TargetTitle.Parent = MainFrame

local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Size = UDim2.new(1, -40, 0, 32)
TargetDropdown.Position = UDim2.new(0, 20, 0, 270)
TargetDropdown.BackgroundColor3 = THEME.ButtonOff
TargetDropdown.Text = "Auto (Nearest)"
TargetDropdown.TextColor3 = THEME.Text
TargetDropdown.Font = Enum.Font.GothamMedium
TargetDropdown.TextSize = 13
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

-- Стрелка
local DDArrow = Instance.new("TextLabel")
DDArrow.Size = UDim2.new(0, 30, 1, 0)
DDArrow.Position = UDim2.new(1, -30, 0, 0)
DDArrow.BackgroundTransparency = 1
DDArrow.Text = "▼"
DDArrow.TextColor3 = THEME.Accent
DDArrow.Font = Enum.Font.GothamBold
DDArrow.TextSize = 12
DDArrow.TextTransparency = 1
DDArrow.Parent = TargetDropdown

-- Список игроков (выпадающий)
local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -40, 0, 0)
DropdownList.Position = UDim2.new(0, 20, 0, 305)
DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
DropdownList.BackgroundTransparency = 1
DropdownList.BorderSizePixel = 0
DropdownList.ClipsDescendants = true
DropdownList.ScrollBarThickness = 3
DropdownList.ScrollBarImageColor3 = THEME.Stroke
DropdownList.Visible = false
DropdownList.ZIndex = 5
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

--// ============ ФУТЕР ============
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 16)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundTransparency = 1
Footer.Text = "Delta Executor • JJS v2"
Footer.TextColor3 = Color3.fromRGB(120, 120, 130)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 11
Footer.TextTransparency = 1
Footer.Parent = MainFrame

--// ============================================
--// TARGET HUD (ник игрока сверху экрана)
--// ============================================
local TargetHud = Instance.new("ScreenGui")
TargetHud.Name = "JJSTargetHud"
TargetHud.ResetOnSpawn = false
TargetHud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TargetHud.Parent = game.CoreGui

local HudFrame = Instance.new("Frame")
HudFrame.Size = UDim2.new(0, 220, 0, 48)
HudFrame.Position = UDim2.new(0.5, -110, 0, 40)
HudFrame.BackgroundColor3 = THEME.Background
HudFrame.BackgroundTransparency = 0.15
HudFrame.BorderSizePixel = 0
HudFrame.Visible = false
HudFrame.Parent = TargetHud

local HudCorner = Instance.new("UICorner")
HudCorner.CornerRadius = UDim.new(0, 10)
HudCorner.Parent = HudFrame

local HudStroke = Instance.new("UIStroke")
HudStroke.Color = THEME.Stroke
HudStroke.Thickness = 1.5
HudStroke.Parent = HudFrame

-- Аватар цели
local HudAvatar = Instance.new("ImageLabel")
HudAvatar.Size = UDim2.new(0, 36, 0, 36)
HudAvatar.Position = UDim2.new(0, 6, 0, 6)
HudAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
HudAvatar.BorderSizePixel = 0
HudAvatar.Image = ""
HudAvatar.Parent = HudFrame

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = HudAvatar

-- Ник
local HudName = Instance.new("TextLabel")
HudName.Size = UDim2.new(1, -50, 0, 16)
HudName.Position = UDim2.new(0, 48, 0, 7)
HudName.BackgroundTransparency = 1
HudName.Text = "Target"
HudName.TextColor3 = THEME.Text
HudName.Font = Enum.Font.GothamBold
HudName.TextSize = 13
HudName.TextXAlignment = Enum.TextXAlignment.Left
HudName.Parent = HudFrame

-- HP Bar
local HudHpBg = Instance.new("Frame")
HudHpBg.Size = UDim2.new(1, -56, 0, 8)
HudHpBg.Position = UDim2.new(0, 48, 0, 28)
HudHpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
HudHpBg.BorderSizePixel = 0
HudHpBg.Parent = HudFrame

local HudHpBgCorner = Instance.new("UICorner")
HudHpBgCorner.CornerRadius = UDim.new(0, 4)
HudHpBgCorner.Parent = HudHpBg

local HudHpFill = Instance.new("Frame")
HudHpFill.Size = UDim2.new(1, 0, 1, 0)
HudHpFill.BackgroundColor3 = THEME.Green
HudHpFill.BorderSizePixel = 0
HudHpFill.Parent = HudHpBg

local HudHpFillCorner = Instance.new("UICorner")
HudHpFillCorner.CornerRadius = UDim.new(0, 4)
HudHpFillCorner.Parent = HudHpFill

local HudHpText = Instance.new("TextLabel")
HudHpText.Size = UDim2.new(1, -56, 0, 10)
HudHpText.Position = UDim2.new(0, 48, 0, 38)
HudHpText.BackgroundTransparency = 1
HudHpText.Text = "100 / 100"
HudHpText.TextColor3 = THEME.SubText
HudHpText.Font = Enum.Font.Gotham
HudHpText.TextSize = 9
HudHpText.TextXAlignment = Enum.TextXAlignment.Left
HudHpText.Parent = HudFrame

--// ============================================
--// ЛОГИКА
--// ============================================
local AutoFarmEnabled = false
local AutoAttackEnabled = false
local CurrentTarget = nil
local ManualTarget = nil -- выбранный вручную игрок

-- Получить живых игроков
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

-- Найти ближайшего к нам
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

-- Сменить таргет
local function switchTarget()
    if ManualTarget and ManualTarget.Character then
        local hum = ManualTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            CurrentTarget = ManualTarget
            return
        end
    end
    
    -- Auto режим
    local alive = getAlivePlayers()
    if #alive == 0 then
        CurrentTarget = nil
        return
    end
    
    -- Ищем следующего, кроме текущего
    local nextT = nil
    for _, p in ipairs(alive) do
        if p ~= CurrentTarget then
            nextT = p
            break
        end
    end
    if not nextT then nextT = alive[1] end
    
    CurrentTarget = nextT
end

-- Обновление Target HUD
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
    HudName.Text = CurrentTarget.Name .. " (@" .. CurrentTarget.DisplayName .. ")"
    HudHpText.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    HudHpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
    
    -- Цвет HP
    local ratio = hum.Health / hum.MaxHealth
    if ratio > 0.6 then
        HudHpFill.BackgroundColor3 = THEME.Green
    elseif ratio > 0.3 then
        HudHpFill.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    else
        HudHpFill.BackgroundColor3 = THEME.Red
    end
    
    -- Аватар через thumbnails API
    local userId = CurrentTarget.UserId
    HudAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
end

-- ============ СЛЕЖЕНИЕ ЗА СМЕРТЬЮ ЦЕЛИ ============
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

-- ============ СТОЯТЬ СЗАДИ ЦЕЛИ ============
local function positionBehindTarget()
    if not AutoFarmEnabled then return end
    if not CurrentTarget or not CurrentTarget.Character then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local behindPos = targetRoot.CFrame * CFrame.new(0, 0, 3)
    myRoot.CFrame = myRoot.CFrame:Lerp(behindPos, 0.35)
end

-- ============ AUTO ATTACK ============
-- Универсальный метод: клик через VirtualUser + активация инструмента
local VirtualUser = game:GetService("VirtualUser")

local function tryAttack()
    if not CurrentTarget or not CurrentTarget.Character then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    local targetHum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return end
    
    -- 1) Активируем текущий инструмент (если есть)
    local tool = myChar:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end
    
    -- 2) Симулируем клик мышью (для M1 атак)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- Цикл авто-атаки
task.spawn(function()
    while true do
        if AutoAttackEnabled then
            if CurrentTarget and CurrentTarget.Character then
                local hum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
                local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Health > 0 and hrp and myHrp then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist <= 15 then
                        tryAttack()
                    end
                end
            end
            task.wait(0.12)
        else
            task.wait(0.2)
        end
    end
end)

-- ============ ЦИКЛ AUTOFARM ============
task.spawn(function()
    while true do
        if AutoFarmEnabled then
            positionBehindTarget()
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end)

-- ============ ОБНОВЛЕНИЕ HUD ============
task.spawn(function()
    while true do
        updateHud()
        task.wait(0.15)
    end
end)

-- ============ КНОПКИ ============
local function refreshStatus()
    ToggleStatus.Text = "AutoFarm: " .. (AutoFarmEnabled and "ON" or "OFF") ..
                        "  |  AutoAttack: " .. (AutoAttackEnabled and "ON" or "OFF")
    if AutoFarmEnabled or AutoAttackEnabled then
        ToggleStatus.TextColor3 = THEME.Green
    else
        ToggleStatus.TextColor3 = THEME.Red
    end
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

-- Ховер-эффекты
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

-- ============ DROPDOWN — ВЫБОР ТАРГЕТА ============
local DropdownOpen = false

local function rebuildDropdown()
    for _, c in ipairs(DropdownList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    -- Пункт "Auto"
    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, -4, 0, 26)
    autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    autoBtn.BackgroundTransparency = 0.4
    autoBtn.Text = "  Auto (Nearest)"
    autoBtn.TextColor3 = THEME.Accent
    autoBtn.Font = Enum.Font.GothamMedium
    autoBtn.TextSize = 12
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
    
    -- Список игроков
    for _, p in ipairs(getAlivePlayers()) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, -4, 0, 26)
        item.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        item.BackgroundTransparency = 0.4
        item.Text = "  " .. p.Name
        item.TextColor3 = THEME.Text
        item.Font = Enum.Font.Gotham
        item.TextSize = 12
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
            -- Автовключение функций при выборе цели
            if not AutoFarmEnabled and not AutoAttackEnabled then
                AutoAttackEnabled = true
                AutoAttackBtn.Text = "Disable AutoAttack"
                TweenService:Create(AutoAttackBtn, TweenInfo.new(0.25), {BackgroundColor3 = THEME.ButtonOn}):Play()
                refreshStatus()
            end
        end)
    end
    
    local contentH = (#DropdownList:GetChildren() - 1) * 28 -- минус UIListLayout
    local maxH = 120
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, math.max(contentH, 5))
    DropdownList.Size = UDim2.new(1, -40, 0, math.min(math.max(contentH, 26), maxH))
end

TargetDropdown.MouseButton1Click:Connect(function()
    DropdownOpen = not DropdownOpen
    if DropdownOpen then
        rebuildDropdown()
        DropdownList.Visible = true
        DropdownList.Size = UDim2.new(1, -40, 0, DropdownList.Size.Y.Offset)
        TweenService:Create(DropdownList, TweenInfo.new(0.25), {
            BackgroundTransparency = 0.05
        }):Play()
    else
        DropdownList.Visible = false
    end
end)

-- ============ ПЕРЕТАСКИВАНИЕ ============
local dragging, dragInput, dragStart, startPos
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
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============ АНИМАЦИЯ ПОЯВЛЕНИЯ ============
local function tween(obj, time, props)
    return TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

task.spawn(function()
    tween(MainFrame, 0.8, {BackgroundTransparency = 0}):Play()
    tween(MainStroke, 0.8, {Transparency = 0.1}):Play()
    tween(InnerStroke, 0.8, {Transparency = 0.7}):Play()
    tween(DragBar, 0.6, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    tween(Sep1, 0.8, {BackgroundTransparency = 0.3}):Play()
    tween(Sep2, 0.8, {BackgroundTransparency = 0.3}):Play()
    task.wait(0.15)
    
    HelloLabel.Text = "Hello, " .. LocalPlayer.Name
    tween(HelloLabel, 0.6, {TextTransparency = 0}):Play()
    local origPos = HelloLabel.Position
    HelloLabel.Position = UDim2.new(0, 20, 0, 60)
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
    
    StatusLabel.Text = "Script loaded successfully"
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
    tween(Footer, 0.5, {TextTransparency = 0}):Play()
    
    refreshStatus()
end)

print("[JJS Script v2] Loaded for " .. LocalPlayer.Name)
