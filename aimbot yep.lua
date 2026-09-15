-- COMBAT HUB PRO (Fixed WallCheck + Instant Head Lock + Auto-Switch Target)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

if PlayerGui:FindFirstChild("CombatHub") then PlayerGui.CombatHub:Destroy() end
if PlayerGui:FindFirstChild("CombatFOV_UI") then PlayerGui.CombatFOV_UI:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "CombatHub"
ScreenGui.ResetOnSpawn = false

-- Raycast Params tái sử dụng để tối ưu hiệu năng
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- Draggable UI Utility
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
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

-- Toggle Icon Tròn
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

-- Frame Chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 390)
MainFrame.Position = UDim2.new(0.15, 0, 0.3, 0)
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
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT HUB PRO"
Title.TextColor3 = Color3.fromRGB(255, 60, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", Scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

    btnSub.MouseButton1Click:Connect(function()
        currentVal = math.max(minVal, currentVal - currentStep)
        lbl.Text = titleText .. ": " .. currentVal
        onChange(currentVal)
    end)
    btnAdd.MouseButton1Click:Connect(function()
        currentVal = math.min(maxVal, currentVal + currentStep)
        lbl.Text = titleText .. ": " .. currentVal
        onChange(currentVal)
    end)
end

local function addColorSelector(titleText, colorsList, onChange)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local currentIndex = 1
    btn.Text = titleText .. ": " .. colorsList[1].Name
    btn.TextColor3 = colorsList[1].Color

    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #colorsList then currentIndex = 1 end
        local selected = colorsList[currentIndex]
        btn.Text = titleText .. ": " .. selected.Name
        btn.TextColor3 = selected.Color
        onChange(selected.Color)
    end)
end

-- ==================== CẤU HÌNH COMBAT & FOV ====================
local aimbotEnabled = false
local showFOV = false
local wallCheck = true
local teamCheck = true
local fovRadius = 150
local fovThickness = 2
local aimSmoothness = 10 -- Mặc định 10 là Ghim Trực Tiếp / Instant Lock
local targetPart = "Head"

local fovColorList = {
    {Name = "Đỏ", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Xanh Lá", Color = Color3.fromRGB(0, 255, 120)},
    {Name = "Xanh Dương", Color = Color3.fromRGB(50, 150, 255)},
    {Name = "Vàng", Color = Color3.fromRGB(255, 220, 0)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "Tím", Color = Color3.fromRGB(200, 50, 255)},
    {Name = "Trắng", Color = Color3.fromRGB(255, 255, 255)}
}
local currentFovColor = fovColorList[1].Color

-- Khởi tạo Vòng FOV GUI
local FOVGui = Instance.new("ScreenGui", PlayerGui)
FOVGui.Name = "CombatFOV_UI"
FOVGui.ResetOnSpawn = false

local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false

local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Transparency = 0.2

local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)

-- Thuật toán tìm đối thủ trong FOV (Đã sửa triệt để WallCheck & Auto-Switch)
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(targetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            
            -- Bắt buộc Máu > 0 và Nhân vật còn tồn tại để tự đổi mục tiêu khi địch chết
            if hum and hum.Health > 0 and part and char.Parent then
                if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                    continue
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if distFromCenter < shortestDistance then
                        if wallCheck then
                            -- Chỉ loại trừ Bản thân + Camera
                            local filterList = {Camera}
                            if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
                            rayParams.FilterDescendantsInstances = filterList

                            local direction = part.Position - Camera.CFrame.Position
                            local rayResult = workspace:Raycast(Camera.CFrame.Position, direction, rayParams)
                            
                            -- Nếu va chạm với vật cản KHÔNG thuộc về đối thủ -> Bị cản tường
                            if rayResult and not rayResult.Instance:IsDescendantOf(char) then
                                continue
                            end
                        end

                        shortestDistance = distFromCenter
                        closestPlayer = plr
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Vòng lặp cập nhật FOV & Aimbot
RunService.RenderStepped:Connect(function()
    FOVFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    FOVStroke.Thickness = fovThickness
    FOVStroke.Color = currentFovColor
    FOVFrame.Visible = showFOV

    if aimbotEnabled then
        local target = getClosestPlayerInFOV()
        if target and target.Character then
            local part = target.Character:FindFirstChild(targetPart) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                if aimSmoothness >= 10 then
                    -- Smoothness = 10 -> Ghim cứng vào Đầu lập tức
                    Camera.CFrame = targetCFrame
                else
                    -- Smoothness < 10 -> Di chuyển mượt dần
                    local alpha = math.clamp(aimSmoothness / 10, 0.05, 0.9)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                end
            end
        end
    end
end)

-- Giao diện Tùy chỉnh Nút bấm
addToggle("Aimbot Lock", function(s) aimbotEnabled = s end)
addToggle("Vòng Aim FOV", function(s) showFOV = s end)
addToggle("Wall Check (Tường)", function(s) wallCheck = s end)
addToggle("Team Check (Đội)", function(s) teamCheck = s end)

addToggle("Aim Part: Thân (Off: Đầu)", function(s)
    targetPart = s and "HumanoidRootPart" or "Head"
end)

addColorSelector("Màu FOV", fovColorList, function(c) currentFovColor = c end)
addAdjusterWithSteps("Size FOV", fovRadius, 30, 600, function(v) fovRadius = v end)
addAdjusterWithSteps("Độ dày FOV", fovThickness, 1, 10, function(v) fovThickness = v end)
addAdjusterWithSteps("Độ Mượt Aim", aimSmoothness, 1, 10, function(v) aimSmoothness = v end)

-- ==================== FULL ESP INTEGRATION ====================
local espActive = false

local function applyFullESP(plr)
    if plr == LocalPlayer then return end

    local function setupChar(char)
        if not char then return end
        pcall(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end

            if hrp:FindFirstChild("FullESP_Gui") then hrp.FullESP_Gui:Destroy() end

            local bb = Instance.new("BillboardGui")
            bb.Name = "FullESP_Gui"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(4.5, 0, 5.8, 0)
            bb.StudsOffset = Vector3.new(0, 0, 0)
            bb.Adornee = hrp
            bb.Parent = hrp

            local boxFrame = Instance.new("Frame", bb)
            boxFrame.Size = UDim2.new(1, 0, 1, 0)
            boxFrame.BackgroundTransparency = 1
            
            local boxStroke = Instance.new("UIStroke", boxFrame)
            boxStroke.Color = Color3.fromRGB(255, 60, 80)
            boxStroke.Thickness = 1.5

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
                local maxHp = hum.MaxHealth
                local ratio = hp / maxHp

                healthFill.Size = UDim2.new(1, 0, ratio, 0)
                healthFill.Position = UDim2.new(0, 0, 1 - ratio, 0)

                if ratio > 0.5 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                elseif ratio > 0.2 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                else
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                end

                nameLbl.Text = string.format("%s [%d/%d]", plr.DisplayName, math.floor(hp), math.floor(maxHp))
            end

            updateStatus()
            local conn = hum.HealthChanged:Connect(updateStatus)

            hum.Died:Connect(function()
                if conn then conn:Disconnect() end
                if bb then bb:Destroy() end
            end)
        end)
    end

    if plr.Character then setupChar(plr.Character) end
    plr.CharacterAdded:Connect(setupChar)
end

local function removeFullESP(plr)
    pcall(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart:FindFirstChild("FullESP_Gui") then
            plr.Character.HumanoidRootPart.FullESP_Gui:Destroy()
        end
    end)
end

addToggle("Full ESP (Box/Health)", function(state)
    espActive = state
    for _, plr in pairs(Players:GetPlayers()) do
        if state then
            applyFullESP(plr)
        else
            removeFullESP(plr)
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if espActive then applyFullESP(plr) end
end)
