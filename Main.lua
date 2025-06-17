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
local noClipSpeed = 0  -- изменено: начальное значение в диапазоне [-10,10]
local noClip = false
local tweening = false

-- Удаляем старый GUI если есть
if game.CoreGui:FindFirstChild("TweenTPGui") then
    game.CoreGui:FindFirstChild("TweenTPGui"):Destroy()
end

-- Создаём новый GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TweenTPGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Функции для создания меток и слайдеров
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

-- Создание кнопок
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

-- Слежение за движением слайдеров
local draggingSpeed = false
local draggingNoClip = false

local function updateSlider(sliderFrame, fill, handle, mouseX, minVal, maxVal)
    local absPos = sliderFrame.AbsolutePosition.X
    local absSize = sliderFrame.AbsoluteSize.X
    local relativeX = math.clamp(mouseX - absPos, 0, absSize)
    local percent = relativeX / absSize
    fill.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -8, 0, 0)
    local value = math.floor(minVal + percent * (maxVal - minVal))
    return value
end

speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)
speedHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)

noclipHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingNoClip = true
    end
end)
noclipHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingNoClip = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingSpeed then
            tweenSpeed = updateSlider(speedSliderFrame, speedFill, speedHandle, input.Position.X, 5, 100)
            speedLabel.Text = "Скорость Tween TP: "..tweenSpeed
        elseif draggingNoClip then
            noClipSpeed = updateSlider(noclipSliderFrame, noclipFill, noclipHandle, input.Position.X, -10, 10)
            noclipLabel.Text = "Скорость No Clip: "..noClipSpeed
        end
    end
end)

-- Кнопки

btnNoClip.MouseButton1Click:Connect(function()
    noClip = not noClip
    btnNoClip.Text = noClip and "✅ No Clip: Вкл" or "🚫 No Clip: Выкл"
end)

btnMode.MouseButton1Click:Connect(function()
    useAir = not useAir
    btnMode.Text = useAir and "☁️ Режим: Воздух" or "🌍 Режим: Земля"
end)

btnSetBase.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePos = char.HumanoidRootPart.Position
        btnSetBase.Text = "✅ База установлена"
        task.wait(1)
        btnSetBase.Text = "📍 Установить базу"
    end
end)

btnTweenTP.MouseButton1Click:Connect(function()
    if not basePos or tweening then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local targetPos = basePos
    if useAir then
        targetPos = Vector3.new(basePos.X, basePos.Y + 40, basePos.Z)
    end

    local distance = (targetPos - hrp.Position).Magnitude
    local time = distance / tweenSpeed
    tweening = true
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    tweening = false
end)

-- Server Hop кнопка
btnServerHop.MouseButton1Click:Connect(function()
    btnServerHop.Text = "🔍 Поиск..."
    local cursor = ""
    local found = false
    repeat
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor))
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing <= 2 and server.maxPlayers > 2 and server.id ~= game.JobId then
                    found = true
                    btnServerHop.Text = "🔁 Переход..."
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            cursor = response.nextPageCursor or ""
        else
            break
        end
    until cursor == "" or found

    btnServerHop.Text = found and "✅ Найден" or "❌ Не найдено"
    task.wait(2)
    btnServerHop.Text = "🔄 Server Hop (1-2 игрока)"
end)

-- No Clip движение и управление клавишами
local activeKeys = {}
local moveDirections = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
}

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if moveDirections[input.KeyCode] then
        activeKeys[input.KeyCode] = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if moveDirections[input.KeyCode] then
        activeKeys[input.KeyCode] = nil
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if noClip then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            local hrp = char.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            for key, active in pairs(activeKeys) do
                if active then
                    dir += moveDirections[key]
                end
            end
            if dir.Magnitude > 0 then
                local moveVec = cam.CFrame:VectorToWorldSpace(dir.Unit)
                hrp.CFrame = hrp.CFrame + moveVec * noClipSpeed * dt
            end
        end
    end
end)
