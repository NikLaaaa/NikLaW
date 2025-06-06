local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ====== Флай =======
local flying = false
local speed = 50
local control = {F=0,B=0,L=0,R=0,U=0,D=0}
local bodyGyro
local bodyVelocity

local function startFly()
    if flying then return end
    flying = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.CFrame = HumanoidRootPart.CFrame
    bodyGyro.Parent = HumanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.maxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = HumanoidRootPart

    Humanoid.PlatformStand = true

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not flying then
            connection:Disconnect()
            return
        end

        local cam = workspace.CurrentCamera
        local moveDir = (cam.CFrame.LookVector * (control.F - control.B)) +
                        (cam.CFrame.RightVector * (control.R - control.L)) +
                        Vector3.new(0,1,0) * (control.U - control.D)

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        else
            moveDir = Vector3.new(0,0,0)
        end

        bodyVelocity.Velocity = moveDir * speed
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    if bodyGyro then bodyGyro:Destroy() bodyGyro=nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity=nil end
    Humanoid.PlatformStand = false
end

-- ====== Ноуклип =======
local noclip = false

local function noclipOn()
    noclip = true
end
local function noclipOff()
    noclip = false
end

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- ====== Управление =======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then control.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then control.B = 1 end
    if input.KeyCode == Enum.KeyCode.A then control.L = 1 end
    if input.KeyCode == Enum.KeyCode.D then control.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then control.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then control.D = 1 end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then control.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then control.D = 0 end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    stopFly()
    noclipOff()
end)

-- ====== GUI =======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyNoclipTpGui"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 570)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Fly + Noclip + Телепорт + Поиск"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Frame

local FlyButton = Instance.new("TextButton")
FlyButton.Text = "Включить Флай"
FlyButton.Size = UDim2.new(1, -20, 0, 40)
FlyButton.Position = UDim2.new(0, 10, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
FlyButton.TextColor3 = Color3.new(1,1,1)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 20
FlyButton.Parent = Frame

local NoclipButton = Instance.new("TextButton")
NoclipButton.Text = "Включить Noclip"
NoclipButton.Size = UDim2.new(1, -20, 0, 40)
NoclipButton.Position = UDim2.new(0, 10, 0, 90)
NoclipButton.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
NoclipButton.TextColor3 = Color3.new(1,1,1)
NoclipButton.Font = Enum.Font.SourceSansBold
NoclipButton.TextSize = 20
NoclipButton.Parent = Frame

-- Кнопки телепорта к картам
local PoliceTpButton = Instance.new("TextButton")
PoliceTpButton.Text = "Телепорт к Police Armory Keycard"
PoliceTpButton.Size = UDim2.new(1, -20, 0, 40)
PoliceTpButton.Position = UDim2.new(0, 10, 0, 140)
PoliceTpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
PoliceTpButton.TextColor3 = Color3.new(1,1,1)
PoliceTpButton.Font = Enum.Font.SourceSansBold
PoliceTpButton.TextSize = 20
PoliceTpButton.Parent = Frame

local MilitaryTpButton = Instance.new("TextButton")
MilitaryTpButton.Text = "Телепорт к Military Armory Keycard"
MilitaryTpButton.Size = UDim2.new(1, -20, 0, 40)
MilitaryTpButton.Position = UDim2.new(0, 10, 0, 190)
MilitaryTpButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MilitaryTpButton.TextColor3 = Color3.new(1,1,1)
MilitaryTpButton.Font = Enum.Font.SourceSansBold
MilitaryTpButton.TextSize = 20
MilitaryTpButton.Parent = Frame

-- Поиск и телепорт по имени
local SearchBox = Instance.new("TextBox")
SearchBox.PlaceholderText = "Введите имя предмета"
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 240)
SearchBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.ClearTextOnFocus = false
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 18
SearchBox.Parent = Frame

local ApplyButton = Instance.new("TextButton")
ApplyButton.Text = "Применить"
ApplyButton.Size = UDim2.new(1, -20, 0, 40)
ApplyButton.Position = UDim2.new(0, 10, 0, 280)
ApplyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
ApplyButton.TextColor3 = Color3.new(1,1,1)
ApplyButton.Font = Enum.Font.SourceSansBold
ApplyButton.TextSize = 20
ApplyButton.Parent = Frame

local ItemList = Instance.new("ScrollingFrame")
ItemList.Size = UDim2.new(1, -20, 0, 230)
ItemList.Position = UDim2.new(0, 10, 0, 330)
ItemList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ItemList.BorderSizePixel = 0
ItemList.CanvasSize = UDim2.new(0, 0, 5, 0)
ItemList.ScrollBarThickness = 6
ItemList.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ItemList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function getBasePart(obj)
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") then
        return obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local currentHighlight = nil
local function clearHighlights()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

-- Функция для создания кнопок предметов
local function createItemButton(name, color)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = ItemList
    return btn
end

-- Пример предметов (можешь расширить)
local items = {
    {name = "Police Armory Keycard", color = Color3.fromRGB(0,0,255)},
    {name = "Military Armory Keycard", color = Color3.fromRGB(255,0,0)},
    -- Добавляй свои предметы сюда
}

-- Создаем кнопки в списке
for _, item in ipairs(items) do
    local btn = createItemButton(item.name, item.color)
    btn.MouseButton1Click:Connect(function()
        local foundPart = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == item.name then
                foundPart = getBasePart(obj)
                if foundPart then break end
            end
        end
        if foundPart and HumanoidRootPart then
            clearHighlights()
            currentHighlight = Instance.new("Highlight")
            currentHighlight.Adornee = foundPart
            currentHighlight.FillColor = item.color
            currentHighlight.Parent = foundPart
            HumanoidRootPart.CFrame = foundPart.CFrame + Vector3.new(0,5,0)
        end
    end)
end

-- Телепорт по кнопкам
PoliceTpButton.MouseButton1Click:Connect(function()
    local foundPart = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Police Armory Keycard" then
            foundPart = getBasePart(obj)
            if foundPart then break end
        end
    end
    if foundPart and HumanoidRootPart then
        clearHighlights()
        currentHighlight = Instance.new("Highlight")
        currentHighlight.Adornee = foundPart
        currentHighlight.FillColor = Color3.fromRGB(0, 0, 255)
        currentHighlight.Parent = foundPart
        HumanoidRootPart.CFrame = foundPart.CFrame + Vector3.new(0, 5, 0)
    end
end)

MilitaryTpButton.MouseButton1Click:Connect(function()
    local foundPart = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Military Armory Keycard" then
            foundPart = getBasePart(obj)
            if foundPart then break end
        end
    end
    if foundPart and HumanoidRootPart then
        clearHighlights()
        currentHighlight = Instance.new("Highlight")
        currentHighlight.Adornee = foundPart
        currentHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        currentHighlight.Parent = foundPart
        HumanoidRootPart.CFrame = foundPart.CFrame + Vector3.new(0, 5, 0)
    end
end)

ApplyButton.MouseButton1Click:Connect(function()
    local targetName = SearchBox.Text
    if targetName == "" then return end

    local foundPart = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == targetName then
            foundPart = getBasePart(obj)
            if foundPart then break end
        end
    end

    if foundPart and HumanoidRootPart then
        clearHighlights()
        currentHighlight = Instance.new("Highlight")
        currentHighlight.Adornee = foundPart
        currentHighlight.FillColor = Color3.fromRGB(0, 255, 255)
        currentHighlight.Parent = foundPart
        HumanoidRootPart.CFrame = foundPart.CFrame + Vector3.new(0, 5, 0)
    end
end)

-- Кнопки для включения/выключения флая и ноклипа
FlyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        FlyButton.Text = "Включить Флай"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        startFly()
        FlyButton.Text = "Выключить Флай"
        FlyButton.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)

NoclipButton.MouseButton1Click:Connect(function()
    if noclip then
        noclipOff()
        NoclipButton.Text = "Включить Noclip"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(170,170,0)
    else
        noclipOn()
        NoclipButton.Text = "Выключить Noclip"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0,170,170)
    end
end)
