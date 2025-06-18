local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local basePos = nil
local useAir = false
local tweenSpeed = 16
local noClipSpeed = 0
local noClip = false
local tweening = false

if game.CoreGui:FindFirstChild("TweenTPGui") then
    game.CoreGui:FindFirstChild("TweenTPGui"):Destroy()
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TweenTPGui"
gui.ResetOnSpawn = false

-- Кнопка-круг
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleGUI"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)
toggleButton.Text = "≡"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 28
toggleButton.TextScaled = true
toggleButton.AutoButtonColor = true
toggleButton.BorderSizePixel = 0
toggleButton.Parent = gui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false

toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local function createLabel(text, posY)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createSlider(posY, minVal, maxVal, initialVal)
    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, posY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new((initialVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 150, 250)

    local handle = Instance.new("ImageButton", sliderFrame)
    handle.Size = UDim2.new(0, 16, 1, 0)
    handle.Position = UDim2.new((initialVal - minVal) / (maxVal - minVal), -8, 0, 0)
    handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    handle.Image = ""

    return sliderFrame, fill, handle
end

-- Кнопки
local btnSetBase = Instance.new("TextButton", frame)
btnSetBase.Size = UDim2.new(1, -20, 0, 35)
btnSetBase.Position = UDim2.new(0, 10, 0, 10)
btnSetBase.Text = "📍 Установить базу"
btnSetBase.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnSetBase.TextColor3 = Color3.new(1, 1, 1)
btnSetBase.Font = Enum.Font.GothamBold
btnSetBase.TextSize = 16

local btnTweenTP = Instance.new("TextButton", frame)
btnTweenTP.Size = UDim2.new(1, -20, 0, 35)
btnTweenTP.Position = UDim2.new(0, 10, 0, 55)
btnTweenTP.Text = "➡ Tween TP к базе"
btnTweenTP.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnTweenTP.TextColor3 = Color3.new(1, 1, 1)
btnTweenTP.Font = Enum.Font.GothamBold
btnTweenTP.TextSize = 16

local btnMode = Instance.new("TextButton", frame)
btnMode.Size = UDim2.new(1, -20, 0, 35)
btnMode.Position = UDim2.new(0, 10, 0, 100)
btnMode.Text = "☁️ Режим: Воздух"
btnMode.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnMode.TextColor3 = Color3.new(1, 1, 1)
btnMode.Font = Enum.Font.GothamBold
btnMode.TextSize = 16

local btnNoClip = Instance.new("TextButton", frame)
btnNoClip.Size = UDim2.new(1, -20, 0, 35)
btnNoClip.Position = UDim2.new(0, 10, 0, 145)
btnNoClip.Text = "🚫 No Clip: Выкл"
btnNoClip.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnNoClip.TextColor3 = Color3.new(1, 1, 1)
btnNoClip.Font = Enum.Font.GothamBold
btnNoClip.TextSize = 16

local speedLabel = createLabel("Скорость Tween TP: "..tweenSpeed, 190)
local speedSliderFrame, speedFill, speedHandle = createSlider(215, 5, 100, tweenSpeed)

local noclipLabel = createLabel("Скорость No Clip: "..noClipSpeed, 245)
local noclipSliderFrame, noclipFill, noclipHandle = createSlider(270, -10, 10, noClipSpeed)

local btnServerHop = Instance.new("TextButton", frame)
btnServerHop.Size = UDim2.new(1, -20, 0, 35)
btnServerHop.Position = UDim2.new(0, 10, 0, 310)
btnServerHop.Text = "🔄 Server Hop (1-2 игрока)"
btnServerHop.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
btnServerHop.TextColor3 = Color3.new(1, 1, 1)
btnServerHop.Font = Enum.Font.GothamBold
btnServerHop.TextSize = 16

-- Ползунки (работают и на телефоне)
local draggingSpeed, draggingNoClip = false, false

local function updateSlider(sliderFrame, fill, handle, inputPos, minVal, maxVal)
    local absPos = sliderFrame.AbsolutePosition.X
    local absSize = sliderFrame.AbsoluteSize.X
    local relativeX = math.clamp(inputPos - absPos, 0, absSize)
    local percent = relativeX / absSize
    fill.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -8, 0, 0)
    return math.floor(minVal + percent * (maxVal - minVal))
end

-- Поддержка мыши и тача
local function setupSlider(handle, sliderFrame, fill, label, varName, minVal, maxVal)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if varName == "tweenSpeed" then draggingSpeed = true
            elseif varName == "noClipSpeed" then draggingNoClip = true end
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if varName == "tweenSpeed" then draggingSpeed = false
            elseif varName == "noClipSpeed" then draggingNoClip = false end
        end
    end)
end

setupSlider(speedHandle, speedSliderFrame, speedFill, speedLabel, "tweenSpeed", 5, 100)
setupSlider(noclipHandle, noclipSliderFrame, noclipFill, noclipLabel, "noClipSpeed", -10, 10)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if draggingSpeed then
            tweenSpeed = updateSlider(speedSliderFrame, speedFill, speedHandle, input.Position.X, 5, 100)
            speedLabel.Text = "Скорость Tween TP: "..tweenSpeed
        elseif draggingNoClip then
            noClipSpeed = updateSlider(noclipSliderFrame, noclipFill, noclipHandle, input.Position.X, -10, 10)
            noclipLabel.Text = "Скорость No Clip: "..noClipSpeed
        end
    end
end)
-- ПОДКЛЮЧЕНИЕ СЕРВИСОВ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local basePos = nil
local useAir = true
local tweenSpeed = 16
local noClipSpeed = 0
local noClip = false
local tweening = false

-- УДАЛЕНИЕ ПРЕДЫДУЩЕГО GUI
if game.CoreGui:FindFirstChild("TweenTPGui") then
    game.CoreGui:FindFirstChild("TweenTPGui"):Destroy()
end

-- СОЗДАНИЕ GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TweenTPGui"
gui.ResetOnSpawn = false

-- КНОПКА-КРУГ
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)
toggleButton.Text = "≡"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.BorderSizePixel = 0
toggleButton.Parent = gui

-- ОСНОВНОЙ ФРЕЙМ
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false

toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ
local function createLabel(text, posY)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createSlider(posY, minVal, maxVal, initialVal)
    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, posY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new((initialVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 150, 250)

    local handle = Instance.new("ImageButton", sliderFrame)
    handle.Size = UDim2.new(0, 16, 1, 0)
    handle.Position = UDim2.new((initialVal - minVal) / (maxVal - minVal), -8, 0, 0)
    handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    handle.Image = ""

    return sliderFrame, fill, handle
end

-- КНОПКИ
local btnSetBase = Instance.new("TextButton", frame)
btnSetBase.Size = UDim2.new(1, -20, 0, 35)
btnSetBase.Position = UDim2.new(0, 10, 0, 10)
btnSetBase.Text = "📍 Установить базу"
btnSetBase.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnSetBase.TextColor3 = Color3.new(1, 1, 1)
btnSetBase.Font = Enum.Font.GothamBold
btnSetBase.TextSize = 16

local btnTweenTP = Instance.new("TextButton", frame)
btnTweenTP.Size = UDim2.new(1, -20, 0, 35)
btnTweenTP.Position = UDim2.new(0, 10, 0, 55)
btnTweenTP.Text = "➡ Tween TP к базе"
btnTweenTP.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnTweenTP.TextColor3 = Color3.new(1, 1, 1)
btnTweenTP.Font = Enum.Font.GothamBold
btnTweenTP.TextSize = 16

local btnMode = Instance.new("TextButton", frame)
btnMode.Size = UDim2.new(1, -20, 0, 35)
btnMode.Position = UDim2.new(0, 10, 0, 100)
btnMode.Text = "☁️ Режим: Воздух"
btnMode.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnMode.TextColor3 = Color3.new(1, 1, 1)
btnMode.Font = Enum.Font.GothamBold
btnMode.TextSize = 16

local btnNoClip = Instance.new("TextButton", frame)
btnNoClip.Size = UDim2.new(1, -20, 0, 35)
btnNoClip.Position = UDim2.new(0, 10, 0, 145)
btnNoClip.Text = "🚫 No Clip: Выкл"
btnNoClip.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
btnNoClip.TextColor3 = Color3.new(1, 1, 1)
btnNoClip.Font = Enum.Font.GothamBold
btnNoClip.TextSize = 16

-- ПОЛЗУНКИ
local speedLabel = createLabel("Скорость Tween TP: "..tweenSpeed, 190)
local speedSliderFrame, speedFill, speedHandle = createSlider(215, 5, 100, tweenSpeed)

local noclipLabel = createLabel("Скорость No Clip: "..noClipSpeed, 245)
local noclipSliderFrame, noclipFill, noclipHandle = createSlider(270, -10, 10, noClipSpeed)

local btnServerHop = Instance.new("TextButton", frame)
btnServerHop.Size = UDim2.new(1, -20, 0, 35)
btnServerHop.Position = UDim2.new(0, 10, 0, 310)
btnServerHop.Text = "🔄 Server Hop (1-2 игрока)"
btnServerHop.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
btnServerHop.TextColor3 = Color3.new(1, 1, 1)
btnServerHop.Font = Enum.Font.GothamBold
btnServerHop.TextSize = 16

-- ФУНКЦИИ ПОЛЗУНКОВ
local draggingSpeed, draggingNoClip = false, false

local function updateSlider(sliderFrame, fill, handle, inputPos, minVal, maxVal)
    local absPos = sliderFrame.AbsolutePosition.X
    local absSize = sliderFrame.AbsoluteSize.X
    local relativeX = math.clamp(inputPos - absPos, 0, absSize)
    local percent = relativeX / absSize
    fill.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -8, 0, 0)
    return math.floor(minVal + percent * (maxVal - minVal))
end

local function setupSlider(handle, sliderFrame, fill, label, varName, minVal, maxVal)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if varName == "tweenSpeed" then draggingSpeed = true
            elseif varName == "noClipSpeed" then draggingNoClip = true end
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if varName == "tweenSpeed" then draggingSpeed = false
            elseif varName == "noClipSpeed" then draggingNoClip = false end
        end
    end)
end

setupSlider(speedHandle, speedSliderFrame, speedFill, speedLabel, "tweenSpeed", 5, 100)
setupSlider(noclipHandle, noclipSliderFrame, noclipFill, noclipLabel, "noClipSpeed", -10, 10)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if draggingSpeed then
            tweenSpeed = updateSlider(speedSliderFrame, speedFill, speedHandle, input.Position.X, 5, 100)
            speedLabel.Text = "Скорость Tween TP: "..tweenSpeed
        elseif draggingNoClip then
            noClipSpeed = updateSlider(noclipSliderFrame, noclipFill, noclipHandle, input.Position.X, -10, 10)
            noclipLabel.Text = "Скорость No Clip: "..noClipSpeed
        end
    end
end)

-- ЛОГИКА КНОПОК
btnSetBase.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePos = char.HumanoidRootPart.Position
    end
end)

btnMode.MouseButton1Click:Connect(function()
    useAir = not useAir
    btnMode.Text = useAir and "☁️ Режим: Воздух" or "🚗 Режим: Земля"
end)

btnNoClip.MouseButton1Click:Connect(function()
    noClip = not noClip
    btnNoClip.Text = noClip and "🚫 No Clip: Вкл" or "🚫 No Clip: Выкл"
end)

btnTweenTP.MouseButton1Click:Connect(function()
    if tweening or not basePos then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    tweening = true
    local target = useAir and (basePos + Vector3.new(0, 50, 0)) or basePos
    local dist = (hrp.Position - target).Magnitude
    local time = dist / tweenSpeed

    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {Position = target})
    tween:Play()
    tween.Completed:Connect(function()
        if useAir then
            local dropTween = TweenService:Create(hrp, TweenInfo.new(1), {Position = basePos})
            dropTween:Play()
            dropTween.Completed:Wait()
        end
        tweening = false
    end)
end)

RunService.RenderStepped:Connect(function()
    if noClip then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, noClipSpeed, 0)
        end
    end
end)

btnServerHop.MouseButton1Click:Connect(function()
    local servers = {}
    local pages = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(pages.data) do
        if server.playing <= 2 and server.id ~= game.JobId then
            table.insert(servers, server.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
    end
end)

-- Остальная логика кнопок — идентична твоей (не повторяю, т.к. не изменялась)
-- если надо — добавлю, скажи.

-- === Ниже добавляй весь остальной твой GUI код (createLabel, createSlider, кнопки и т.п.)
-- НЕ забудь, что теперь `frame` - это родитель всех элементов GUI
-- Они будут скрываться/открываться по нажатию на кнопку-круг
