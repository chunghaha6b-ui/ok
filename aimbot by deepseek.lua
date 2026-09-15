-- ═══════════════════════════════════════════════════════════════
-- COMBAT HUB PRO v5 - RIVALS EDITION
-- Auto-detect projectile + Bullet tracer visual
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Cleanup GUI cũ
for _, n in ipairs({"CombatHub", "CombatFOV_UI", "CombatTracer_UI", "CombatInfo_UI", "CombatBulletTracer_UI"}) do
    if PlayerGui:FindFirstChild(n) then PlayerGui[n]:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- SCREEN GUI KHỞI TẠO
-- ═══════════════════════════════════════════════════════════════
local function newGui(name)
    local g = Instance.new("ScreenGui")
    g.Name = name
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.Parent = PlayerGui
    return g
end

local ScreenGui = newGui("CombatHub")
local TracerGui = newGui("CombatTracer_UI")
local InfoGui = newGui("CombatInfo_UI")
local FOVGui = newGui("CombatFOV_UI")
local BulletTracerGui = newGui("CombatBulletTracer_UI")

-- ═══════════════════════════════════════════════════════════════
-- RAYCAST PARAMS
-- ═══════════════════════════════════════════════════════════════
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true
rayParams.RespectCanCollide = false

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE UTILS
-- ═══════════════════════════════════════════════════════════════
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN UI
-- ═══════════════════════════════════════════════════════════════
local ToggleIcon = Instance.new("TextButton", ScreenGui)
ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
ToggleIcon.Position = UDim2.new(0.02, 0, 0.3, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.Text = "COMBAT"
ToggleIcon.Font = Enum.Font.SourceSansBold
ToggleIcon.TextSize = 10
ToggleIcon.Active = true
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)
makeDraggable(ToggleIcon)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 460)
MainFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
makeDraggable(MainFrame)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 20, 25)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.75, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT HUB PRO v5"
Title.TextColor3 = Color3.fromRGB(255, 60, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.88, 0, 0.1, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local function toggleUI() MainFrame.Visible = not MainFrame.Visible end
ToggleIcon.MouseButton1Click:Connect(toggleUI)
CloseBtn.MouseButton1Click:Connect(toggleUI)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", Scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════
local function addToggle(text, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(220, 50, 70) or Color3.fromRGB(35, 30, 35)
        task.spawn(function() callback(state) end)
    end)
    return btn
end

local function addAdjusterWithSteps(titleText, defaultVal, minVal, maxVal, onChange)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(0.9, 0, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(30, 22, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 0.45, 0)
    lbl.Position = UDim2.new(0.04, 0, 0.05, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = titleText .. ": " .. defaultVal

    local steps = {1, 2, 5, 10}
    local stepIndex = 1
    local currentStep = steps[stepIndex]

    local stepBtn = Instance.new("TextButton", frame)
    stepBtn.Size = UDim2.new(0.42, 0, 0.45, 0)
    stepBtn.Position = UDim2.new(0.54, 0, 0.05, 0)
    stepBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 35)
    stepBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
    stepBtn.Text = "Step: ±" .. currentStep
    stepBtn.Font = Enum.Font.SourceSansBold
    stepBtn.TextSize = 10
    Instance.new("UICorner", stepBtn).CornerRadius = UDim.new(0, 4)
    stepBtn.MouseButton1Click:Connect(function()
        stepIndex = stepIndex + 1
        if stepIndex > #steps then stepIndex = 1 end
        currentStep = steps[stepIndex]
        stepBtn.Text = "Step: ±" .. currentStep
    end)

    local currentVal = defaultVal
    local function update(v)
        currentVal = v
        lbl.Text = titleText .. ": " .. v
        onChange(v)
    end

    local btnSub = Instance.new("TextButton", frame)
    btnSub.Size = UDim2.new(0.45, 0, 0.42, 0)
    btnSub.Position = UDim2.new(0.04, 0, 0.52, 0)
    btnSub.BackgroundColor3 = Color3.fromRGB(50, 35, 40)
    btnSub.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSub.Text = "➖ Trừ"
    btnSub.Font = Enum.Font.SourceSansBold
    btnSub.TextSize = 11
    Instance.new("UICorner", btnSub).CornerRadius = UDim.new(0, 4)

    local btnAdd = Instance.new("TextButton", frame)
    btnAdd.Size = UDim2.new(0.45, 0, 0.42, 0)
    btnAdd.Position = UDim2.new(0.51, 0, 0.52, 0)
    btnAdd.BackgroundColor3 = Color3.fromRGB(50, 35, 40)
    btnAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnAdd.Text = "➕ Cộng"
    btnAdd.Font = Enum.Font.SourceSansBold
    btnAdd.TextSize = 11
    Instance.new("UICorner", btnAdd).CornerRadius = UDim.new(0, 4)

    btnSub.MouseButton1Click:Connect(function() update(math.max(minVal, currentVal - currentStep)) end)
    btnAdd.MouseButton1Click:Connect(function() update(math.min(maxVal, currentVal + currentStep)) end)
end

local function addColorSelector(titleText, colorsList, onChange)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local idx = 1
    btn.Text = titleText .. ": " .. colorsList[1].Name
    btn.TextColor3 = colorsList[1].Color
    btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #colorsList then idx = 1 end
        local sel = colorsList[idx]
        btn.Text = titleText .. ": " .. sel.Name
        btn.TextColor3 = sel.Color
        onChange(sel.Color)
    end)
end

local function addSection(text)
    local lbl = Instance.new("TextLabel", Scroll)
    lbl.Size = UDim2.new(0.9, 0, 0, 22)
    lbl.BackgroundColor3 = Color3.fromRGB(50, 25, 35)
    lbl.TextColor3 = Color3.fromRGB(255, 150, 170)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 11
    lbl.Text = "═══ " .. text .. " ═══"
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
end

-- ═══════════════════════════════════════════════════════════════
-- TARGET INFO PANEL
-- ═══════════════════════════════════════════════════════════════
local InfoPanel = Instance.new("Frame", InfoGui)
InfoPanel.Size = UDim2.new(0, 210, 0, 100)
InfoPanel.Position = UDim2.new(0.72, 0, 0.05, 0)
InfoPanel.BackgroundColor3 = Color3.fromRGB(15, 12, 18)
InfoPanel.BackgroundTransparency = 0.2
InfoPanel.BorderSizePixel = 0
InfoPanel.Visible = false
InfoPanel.Active = true
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 8)
local infoStroke = Instance.new("UIStroke", InfoPanel)
infoStroke.Color = Color3.fromRGB(255, 60, 80)
infoStroke.Thickness = 1.5
makeDraggable(InfoPanel)

local infoTitle = Instance.new("TextLabel", InfoPanel)
infoTitle.Size = UDim2.new(1, -10, 0, 22)
infoTitle.Position = UDim2.new(0, 5, 0, 5)
infoTitle.BackgroundTransparency = 1
infoTitle.TextColor3 = Color3.fromRGB(255, 100, 120)
infoTitle.Font = Enum.Font.SourceSansBold
infoTitle.TextSize = 12
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Text = "🎯 TARGET INFO"

local infoName = Instance.new("TextLabel", InfoPanel)
infoName.Size = UDim2.new(1, -10, 0, 20)
infoName.Position = UDim2.new(0, 5, 0, 26)
infoName.BackgroundTransparency = 1
infoName.TextColor3 = Color3.fromRGB(255, 255, 255)
infoName.Font = Enum.Font.SourceSansBold
infoName.TextSize = 13
infoName.TextXAlignment = Enum.TextXAlignment.Left
infoName.Text = "Không có"

local hpBarBg = Instance.new("Frame", InfoPanel)
hpBarBg.Size = UDim2.new(1, -10, 0, 12)
hpBarBg.Position = UDim2.new(0, 5, 0, 48)
hpBarBg.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
hpBarBg.BorderSizePixel = 0
Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 3)

local hpBarFill = Instance.new("Frame", hpBarBg)
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
hpBarFill.BorderSizePixel = 0
Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(0, 3)

local infoHp = Instance.new("TextLabel", InfoPanel)
infoHp.Size = UDim2.new(1, -10, 0, 16)
infoHp.Position = UDim2.new(0, 5, 0, 62)
infoHp.BackgroundTransparency = 1
infoHp.TextColor3 = Color3.fromRGB(220, 220, 220)
infoHp.Font = Enum.Font.SourceSansBold
infoHp.TextSize = 11
infoHp.TextXAlignment = Enum.TextXAlignment.Left
infoHp.Text = "HP: -- / --"

local infoDist = Instance.new("TextLabel", InfoPanel)
infoDist.Size = UDim2.new(1, -10, 0, 16)
infoDist.Position = UDim2.new(0, 5, 0, 80)
infoDist.BackgroundTransparency = 1
infoDist.TextColor3 = Color3.fromRGB(255, 200, 100)
infoDist.Font = Enum.Font.SourceSansBold
infoDist.TextSize = 11
infoDist.TextXAlignment = Enum.TextXAlignment.Left
infoDist.Text = "Khoảng cách: --"

-- ═══════════════════════════════════════════════════════════════
-- FOV UI
-- ═══════════════════════════════════════════════════════════════
local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency = 0.2
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

-- ═══════════════════════════════════════════════════════════════
-- BULLET TRACER VISUAL
-- ═══════════════════════════════════════════════════════════════
local bulletTracerFrame = Instance.new("Frame", BulletTracerGui)
bulletTracerFrame.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
bulletTracerFrame.BorderSizePixel = 0
bulletTracerFrame.AnchorPoint = Vector2.new(0, 0.5)
bulletTracerFrame.Visible = false
bulletTracerFrame.ZIndex = 3

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════
local aimbotEnabled = false
local showFOV = false
local wallCheck = true
local teamCheck = true
local fovRadius = 150
local fovThickness = 2
local aimSmoothness = 10
local targetPart = "Head"

local espActive = false
local espBox = true
local espSkeleton = false
local espTracer = false
local espChams = false
local showInfo = true

local aimPrediction = false
local showBulletTracer = false
local manualSpeed = 1000
local predictionMultiplier = 1.0
local bulletGravity = 0

local colorList = {
    {Name = "Đỏ", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Xanh Lá", Color = Color3.fromRGB(0, 255, 120)},
    {Name = "Xanh Dương", Color = Color3.fromRGB(50, 150, 255)},
    {Name = "Vàng", Color = Color3.fromRGB(255, 220, 0)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "Tím", Color = Color3.fromRGB(200, 50, 255)},
    {Name = "Trắng", Color = Color3.fromRGB(255, 255, 255)}
}
local currentFovColor = colorList[1].Color
local currentEspColor = colorList[1].Color

-- ═══════════════════════════════════════════════════════════════
-- AUTO-DETECT PROJECTILE WEAPONS (RIVALS)
-- ═══════════════════════════════════════════════════════════════
local PROJECTILE_WEAPONS = {
    -- Weapon name (chữ thường để match không phân biệt hoa thường) = config
    ["scepter"]      = { speed = 100, gravity = 0,   lead = 1.0 },
    ["bow"]          = { speed = 250, gravity = 100, lead = 1.0 },
    ["crossbow"]     = { speed = 400, gravity = 50,  lead = 1.0 },
    ["rpg"]          = { speed = 150, gravity = 50,  lead = 1.0 },
    ["grenade"]      = { speed = 80,  gravity = 196, lead = 1.2 },
    ["paintball"]    = { speed = 120, gravity = 80,  lead = 1.0 },
    ["paintball gun"]= { speed = 120, gravity = 80,  lead = 1.0 },
    ["snowball"]     = { speed = 100, gravity = 150, lead = 1.0 },
    ["water balloon"]= { speed = 90,  gravity = 150, lead = 1.0 },
    ["flamethrower"] = { speed = 60,  gravity = 0,   lead = 1.0 },
    -- Thêm vũ khí mới ở đây khi Rivals update
}

local currentWeaponConfig = nil
local currentWeaponName = nil

local function detectCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then
        currentWeaponConfig = nil
        currentWeaponName = nil
        return nil
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        currentWeaponConfig = nil
        currentWeaponName = nil
        return nil
    end
    currentWeaponName = tool.Name
    local key = string.lower(tool.Name)
    local cfg = PROJECTILE_WEAPONS[key]
    if cfg then
        currentWeaponConfig = cfg
        return cfg
    end
    currentWeaponConfig = nil
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- STICKY TARGET + AIM LOGIC
-- ═══════════════════════════════════════════════════════════════
local lockedTarget = nil
local lastSeenTime = 0
local LOST_TOLERANCE = 0.35

local function buildFilterList()
    local list = {Camera}
    if LocalPlayer.Character then table.insert(list, LocalPlayer.Character) end
    return list
end

local function isTargetValid(plr)
    if not plr or not plr.Parent then return false end
    local char = plr.Character
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return false end
    return true
end

local function getAimPart(char)
    return char:FindFirstChild(targetPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function predictPosition(char, part)
    if not aimPrediction then return part.Position end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return part.Position end

    -- Ưu tiên config từ vũ khí auto-detect, fallback về manual
    local speed, gravity
    if currentWeaponConfig then
        speed = currentWeaponConfig.speed
        gravity = currentWeaponConfig.gravity
    else
        speed = manualSpeed
        gravity = bulletGravity
    end

    if not speed or speed <= 0 then return part.Position end

    local dist = (part.Position - Camera.CFrame.Position).Magnitude
    local t = (dist / speed) * predictionMultiplier

    local vel = root.AssemblyLinearVelocity
    local predicted = part.Position + vel * t

    if gravity and gravity > 0 then
        predicted = predicted + Vector3.new(0, 0.5 * gravity * t * t, 0)
    end
    return predicted
end

local function getClosestPlayerInFOV()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Sticky check
    if lockedTarget and isTargetValid(lockedTarget) then
        local char = lockedTarget.Character
        local part = getAimPart(char)
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and screenPos.Z > 0 then
                local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if d <= fovRadius then
                    local blocked = false
                    if wallCheck then
                        rayParams.FilterDescendantsInstances = buildFilterList()
                        local dir = part.Position - Camera.CFrame.Position
                        local res = workspace:Raycast(Camera.CFrame.Position, dir, rayParams)
                        if res and not res.Instance:IsDescendantOf(char) then blocked = true end
                    end
                    if not blocked then
                        lastSeenTime = tick()
                        return lockedTarget
                    end
                end
            end
        end
        if tick() - lastSeenTime > LOST_TOLERANCE then lockedTarget = nil end
    end

    -- Find new
    local closest, shortest = nil, fovRadius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = getAimPart(char)
                if part then
                    local skip = false
                    if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                        skip = true
                    end
                    if not skip then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if d < shortest then
                                local blocked = false
                                if wallCheck then
                                    rayParams.FilterDescendantsInstances = buildFilterList()
                                    local dir = part.Position - Camera.CFrame.Position
                                    local res = workspace:Raycast(Camera.CFrame.Position, dir, rayParams)
                                    if res and not res.Instance:IsDescendantOf(char) then blocked = true end
                                end
                                if not blocked then
                                    shortest = d
                                    closest = plr
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if closest then
        lockedTarget = closest
        lastSeenTime = tick()
    end
    return closest
end

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════
local SKELETON_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local SKELETON_R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local espData = {}

local function clearESP(plr)
    local data = espData[plr]
    if not data then return end
    for _, c in ipairs(data.conns) do pcall(function() c:Disconnect() end) end
    if data.gui then pcall(function() data.gui:Destroy() end) end
    if data.tracerFrame then pcall(function() data.tracerFrame:Destroy() end) end
    if data.skelFolder then pcall(function() data.skelFolder:Destroy() end) end
    if data.chams then pcall(function() data.chams:Destroy() end) end
    espData[plr] = nil
end

local function applyChams(char)
    if not char then return nil end
    local ex = char:FindFirstChild("CombatChams")
    if ex then ex:Destroy() end
    if not espChams then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "CombatChams"
    hl.FillColor = currentEspColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char
    return hl
end

local function createESP(plr)
    if plr == LocalPlayer then return end
    clearESP(plr)
    local data = {conns = {}, skeletonLines = {}}
    espData[plr] = data

    local tracerFrame = Instance.new("Frame", TracerGui)
    tracerFrame.BackgroundColor3 = currentEspColor
    tracerFrame.BorderSizePixel = 0
    tracerFrame.AnchorPoint = Vector2.new(0, 0.5)
    tracerFrame.Visible = false
    tracerFrame.ZIndex = 2
    data.tracerFrame = tracerFrame

    local function setupChar(char)
        if not char then return end
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end

            local bb = Instance.new("BillboardGui")
            bb.Name = "FullESP_Gui"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(4.5, 0, 5.8, 0)
            bb.Adornee = hrp
            bb.Parent = hrp
            data.gui = bb

            local boxFrame = Instance.new("Frame", bb)
            boxFrame.Size = UDim2.new(1, 0, 1, 0)
            boxFrame.BackgroundTransparency = 1
            boxFrame.Visible = espBox
            local boxStroke = Instance.new("UIStroke", boxFrame)
            boxStroke.Color = currentEspColor
            boxStroke.Thickness = 1.5
            data.boxFrame = boxFrame
            data.boxStroke = boxStroke

            local nameLbl = Instance.new("TextLabel", bb)
            nameLbl.Size = UDim2.new(1, 60, 0, 16)
            nameLbl.Position = UDim2.new(-0.2, 0, -0.18, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.Font = Enum.Font.SourceSansBold
            nameLbl.TextSize = 11
            nameLbl.TextStrokeTransparency = 0

            local healthBg = Instance.new("Frame", bb)
            healthBg.Size = UDim2.new(0.06, 0, 1, 0)
            healthBg.Position = UDim2.new(-0.1, 0, 0, 0)
            healthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            healthBg.BorderSizePixel = 0
            local healthFill = Instance.new("Frame", healthBg)
            healthFill.BorderSizePixel = 0

            local function updateStatus()
                if not hum or not hum.Parent then return end
                local hp = math.clamp(hum.Health, 0, hum.MaxHealth)
                local ratio = hum.MaxHealth > 0 and hp / hum.MaxHealth or 0
                healthFill.Size = UDim2.new(1, 0, ratio, 0)
                healthFill.Position = UDim2.new(0, 0, 1 - ratio, 0)
                if ratio > 0.5 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                elseif ratio > 0.2 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                else
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                end
                nameLbl.Text = string.format("%s [%d/%d]", plr.DisplayName, math.floor(hp), math.floor(hum.MaxHealth))
            end
            updateStatus()
            table.insert(data.conns, hum.HealthChanged:Connect(updateStatus))

            local skelFolder = Instance.new("Folder", TracerGui)
            skelFolder.Name = "Skeleton_" .. plr.Name
            data.skelFolder = skelFolder

            local isR15 = char:FindFirstChild("UpperTorso") ~= nil
            local bones = isR15 and SKELETON_R15 or SKELETON_R6
            for i = 1, #bones do
                local line = Instance.new("Frame", skelFolder)
                line.BackgroundColor3 = currentEspColor
                line.BorderSizePixel = 0
                line.AnchorPoint = Vector2.new(0, 0.5)
                line.Visible = false
                line.ZIndex = 1
                data.skeletonLines[i] = {line = line, a = bones[i][1], b = bones[i][2]}
            end

            data.chams = applyChams(char)

            local function cleanup()
                if data.gui then data.gui:Destroy(); data.gui = nil end
                if data.skelFolder then data.skelFolder:Destroy(); data.skelFolder = nil end
                if data.tracerFrame then data.tracerFrame.Visible = false end
                if data.chams then data.chams:Destroy(); data.chams = nil end
            end
            table.insert(data.conns, char.Destroying:Connect(cleanup))
            table.insert(data.conns, hum.Died:Connect(cleanup))
        end)
    end

    if plr.Character then setupChar(plr.Character) end
    table.insert(data.conns, plr.CharacterAdded:Connect(setupChar))
end

local function refreshAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if espActive then createESP(plr) else clearESP(plr) end
        end
    end
end

Players.PlayerAdded:Connect(function(plr) if espActive then createESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) clearESP(plr) end)

-- ═══════════════════════════════════════════════════════════════
-- PER-FRAME VISUALS
-- ═══════════════════════════════════════════════════════════════
local function updateESPVisuals()
    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    local bottomCenter = Vector2.new(viewport.X / 2, viewport.Y)

    for plr, data in pairs(espData) do
        local char = plr.Character
        if not char or not char.Parent then
            if data.tracerFrame then data.tracerFrame.Visible = false end
            if data.skeletonLines then
                for _, s in ipairs(data.skeletonLines) do s.line.Visible = false end
            end
            continue
        end

        if espSkeleton and data.skeletonLines and #data.skeletonLines > 0 then
            for _, s in ipairs(data.skeletonLines) do
                local pA = char:FindFirstChild(s.a)
                local pB = char:FindFirstChild(s.b)
                if pA and pB then
                    local posA, onA = cam:WorldToViewportPoint(pA.Position)
                    local posB, onB = cam:WorldToViewportPoint(pB.Position)
                    if onA and onB and posA.Z > 0 and posB.Z > 0 then
                        local delta = Vector2.new(posB.X - posA.X, posB.Y - posA.Y)
                        local len = delta.Magnitude
                        if len > 0.5 then
                            s.line.Visible = true
                            s.line.Size = UDim2.new(0, len, 0, 2)
                            s.line.Position = UDim2.new(0, posA.X, 0, posA.Y)
                            s.line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                        else
                            s.line.Visible = false
                        end
                    else
                        s.line.Visible = false
                    end
                else
                    s.line.Visible = false
                end
            end
        elseif data.skeletonLines then
            for _, s in ipairs(data.skeletonLines) do s.line.Visible = false end
        end

        if espTracer and data.tracerFrame then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head then
                local sp, on = cam:WorldToViewportPoint(head.Position)
                if on and sp.Z > 0 then
                    local delta = Vector2.new(sp.X - bottomCenter.X, sp.Y - bottomCenter.Y)
                    local len = delta.Magnitude
                    if len > 1 then
                        data.tracerFrame.Visible = true
                        data.tracerFrame.Position = UDim2.new(0, bottomCenter.X, 0, bottomCenter.Y)
                        data.tracerFrame.Size = UDim2.new(0, len, 0, 1.5)
                        data.tracerFrame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    else
                        data.tracerFrame.Visible = false
                    end
                else
                    data.tracerFrame.Visible = false
                end
            else
                data.tracerFrame.Visible = false
            end
        elseif data.tracerFrame then
            data.tracerFrame.Visible = false
        end
    end
end

local function updateBulletTracer(target)
    if not showBulletTracer or not aimbotEnabled or not target then
        bulletTracerFrame.Visible = false
        return
    end
    if not currentWeaponConfig and not aimPrediction then
        bulletTracerFrame.Visible = false
        return
    end

    local char = target.Character
    if not char then
        bulletTracerFrame.Visible = false
        return
    end
    local part = getAimPart(char)
    if not part then
        bulletTracerFrame.Visible = false
        return
    end

    local predictedPos = predictPosition(char, part)
    local originScreen = Camera:WorldToViewportPoint(Camera.CFrame.Position)
    local targetScreen = Camera:WorldToViewportPoint(predictedPos)

    if not originScreen or not targetScreen then
        bulletTracerFrame.Visible = false
        return
    end

    local delta = Vector2.new(targetScreen.X - originScreen.X, targetScreen.Y - originScreen.Y)
    local len = delta.Magnitude

    if len > 1 then
        bulletTracerFrame.Visible = true
        bulletTracerFrame.Position = UDim2.new(0, originScreen.X, 0, originScreen.Y)
        bulletTracerFrame.Size = UDim2.new(0, len, 0, 2)
        bulletTracerFrame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        bulletTracerFrame.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
        bulletTracerFrame.BackgroundTransparency = 0.3
    else
        bulletTracerFrame.Visible = false
    end
end

local function updateInfoPanel(target)
    if not showInfo or not target then
        InfoPanel.Visible = false
        return
    end
    InfoPanel.Visible = true
    local char = target.Character
    if not char then InfoPanel.Visible = false; return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    infoName.Text = target.DisplayName
    if hum then
        local hp = math.floor(math.clamp(hum.Health, 0, hum.MaxHealth))
        local maxHp = math.floor(hum.MaxHealth)
        local ratio = hum.MaxHealth > 0 and (hum.Health / hum.MaxHealth) or 0
        hpBarFill.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)
        if ratio > 0.5 then
            hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        elseif ratio > 0.2 then
            hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
        infoHp.Text = string.format("HP: %d / %d", hp, maxHp)
    end
    if hrp and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local dist = (hrp.Position - myRoot.Position).Magnitude
            infoDist.Text = string.format("Khoảng cách: %d studs", math.floor(dist))
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SINGLE RENDER LOOP
-- ═══════════════════════════════════════════════════════════════
local currentAimTarget = nil
local weaponCheckTimer = 0

RunService.RenderStepped:Connect(function(dt)
    -- Auto-detect vũ khí (mỗi 0.1s để tiết kiệm perf)
    weaponCheckTimer = weaponCheckTimer + dt
    if weaponCheckTimer >= 0.1 then
        weaponCheckTimer = 0
        detectCurrentWeapon()
    end

    -- FOV
    if showFOV then
        FOVFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
        FOVStroke.Thickness = fovThickness
        FOVStroke.Color = currentFovColor
    end
    FOVFrame.Visible = showFOV

    -- Aim
    if aimbotEnabled then
        local target = getClosestPlayerInFOV()
        currentAimTarget = target
        if target and target.Character then
            local char = target.Character
            local part = getAimPart(char)
            if part then
                local aimPos = predictPosition(char, part)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
                if aimSmoothness >= 10 then
                    Camera.CFrame = targetCFrame
                else
                    local alpha = math.clamp(aimSmoothness / 10, 0.05, 0.9)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                end
            end
        end
    else
        currentAimTarget = nil
    end

    -- Info Panel
    if showInfo and currentAimTarget then
        updateInfoPanel(currentAimTarget)
    else
        InfoPanel.Visible = false
    end

    -- Bullet Tracer Visual
    updateBulletTracer(currentAimTarget)

    -- ESP
    if espActive then updateESPVisuals() end
end)

-- ═══════════════════════════════════════════════════════════════
-- UI BUILD
-- ═══════════════════════════════════════════════════════════════
addSection("AIMBOT")
addToggle("Aimbot Lock", function(s)
    aimbotEnabled = s
    if not s then lockedTarget = nil end
end)
addToggle("Vòng Aim FOV", function(s) showFOV = s end)
addToggle("Wall Check (Tường)", function(s) wallCheck = s end)
addToggle("Team Check (Đội)", function(s) teamCheck = s end)

local aimPartBtn
aimPartBtn = addToggle("Aim: Đầu", function(s)
    targetPart = s and "HumanoidRootPart" or "Head"
    aimPartBtn.Text = "Aim: " .. (s and "Thân" or "Đầu") .. (s and ": ON" or ": OFF")
end)

addColorSelector("Màu FOV", colorList, function(c) currentFovColor = c end)
addAdjusterWithSteps("Size FOV", fovRadius, 30, 600, function(v) fovRadius = v end)
addAdjusterWithSteps("Độ dày FOV", fovThickness, 1, 10, function(v) fovThickness = v end)
addAdjusterWithSteps("Độ Mượt Aim", aimSmoothness, 1, 10, function(v) aimSmoothness = v end)

addSection("PREDICTION")
addToggle("Aim Prediction (Auto-detect vũ khí)", function(s)
    aimPrediction = s
    if s then
        detectCurrentWeapon()
        if currentWeaponName then
            print("[Combat Hub] Vũ khí hiện tại: " .. currentWeaponName ..
                (currentWeaponConfig and (" → PROJECTILE (speed=" .. currentWeaponConfig.speed .. ")") or " → HITSCAN (không cần predict)"))
        end
    end
end)
addToggle("Vẽ đường đạn (Bullet Tracer)", function(s) showBulletTracer = s end)
addAdjusterWithSteps("Tốc độ đạn (Manual)", manualSpeed, 100, 5000, function(v) manualSpeed = v end)
addAdjusterWithSteps("Hệ số dự đoán (x10)", math.floor(predictionMultiplier * 10), 1, 30, function(v)
    predictionMultiplier = v / 10
end)
addAdjusterWithSteps("Trọng lực đạn (Manual)", bulletGravity, 0, 200, function(v) bulletGravity = v end)

addSection("INFO PANEL")
addToggle("Hiện Target Info Panel", function(s) showInfo = s end)

addSection("ESP")
addToggle("Full ESP (Tổng)", function(state)
    espActive = state
    refreshAllESP()
end)
addToggle("ESP Box + Health", function(state)
    espBox = state
    for _, data in pairs(espData) do
        if data.boxFrame then data.boxFrame.Visible = state end
    end
end)
addToggle("ESP Skeleton", function(state)
    espSkeleton = state
    if not state then
        for _, data in pairs(espData) do
            if data.skeletonLines then
                for _, s in ipairs(data.skeletonLines) do s.line.Visible = false end
            end
        end
    end
end)
addToggle("ESP Tracer (Line)", function(state)
    espTracer = state
    if not state then
        for _, data in pairs(espData) do
            if data.tracerFrame then data.tracerFrame.Visible = false end
        end
    end
end)
addToggle("ESP Chams (Xuyên tường)", function(state)
    espChams = state
    for plr, data in pairs(espData) do
        local char = plr.Character
        if char then
            local old = char:FindFirstChild("CombatChams")
            if old then old:Destroy() end
            data.chams = state and applyChams(char) or nil
        end
    end
end)
addColorSelector("Màu ESP", colorList, function(c)
    currentEspColor = c
    for _, data in pairs(espData) do
        if data.boxStroke then data.boxStroke.Color = c end
        if data.tracerFrame then data.tracerFrame.BackgroundColor3 = c end
        if data.skeletonLines then
            for _, s in ipairs(data.skeletonLines) do s.line.BackgroundColor3 = c end
        end
        if data.chams then pcall(function() data.chams.FillColor = c end) end
    end
    infoStroke.Color = c
end)

print("═══════════════════════════════════════════")
print("[Combat Hub Pro v5] RIVALS EDITION - Loaded!")
print("→ Auto-detect vũ khí projectile")
print("→ Bullet Tracer Visual")
print("→ Sticky Target + Smooth Aim")
print("→ Full ESP: Box/Health/Skeleton/Tracer/Chams")
print("═══════════════════════════════════════════")