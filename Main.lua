local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local basePos = nil
local useAir = false
local speed = 16
local height = 40
local tweening = false
local noClip = false

-- GUI
if game.CoreGui:FindFirstChild("TweenTPGui") then
    game.CoreGui:FindFirstChild("TweenTPGui"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TweenTPGui"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 330)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function createBtn(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    return btn
end

local btnSetBase = createBtn("📍 Установить базу", 10)
local btnTweenTP = createBtn("➡ Tween TP к базе", 55)
local btnMode = createBtn("☁️ Режим: Воздух", 100)
local btnNoClip = createBtn("🚫 No Clip: Выкл", 145)

-- Ползунок скорости
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 190)
speedLabel.Text = "Скорость: 16"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14

local speedSlider = Instance.new("Frame", frame)
speedSlider.Size = UDim2.new(1, -20, 0, 10)
speedSlider.Position = UDim2.new(0, 10, 0, 215)
speedSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local speedHandle = Instance.new("ImageButton", speedSlider)
speedHandle.Size = UDim2.new(0, 20, 1, 0)
speedHandle.Position = UDim2.new((speed - 5) / 95, 0, 0, 0)
speedHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
speedHandle.Image = ""

-- Ползунок высоты
local heightLabel = Instance.new("TextLabel", frame)
heightLabel.Size = UDim2.new(1, -20, 0, 20)
heightLabel.Position = UDim2.new(0, 10, 0, 235)
heightLabel.Text = "Высота (только воздух): 40"
heightLabel.TextColor3 = Color3.new(1, 1, 1)
heightLabel.BackgroundTransparency = 1
heightLabel.Font = Enum.Font.Gotham
heightLabel.TextSize = 14

local heightSlider = Instance.new("Frame", frame)
heightSlider.Size = UDim2.new(1, -20, 0, 10)
heightSlider.Position = UDim2.new(0, 10, 0, 260)
heightSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local heightHandle = Instance.new("ImageButton", heightSlider)
heightHandle.Size = UDim2.new(0, 20, 1, 0)
heightHandle.Position = UDim2.new((height - 10) / 90, 0, 0, 0)
heightHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
heightHandle.Image = ""

-- Логика ползунков
local draggingSpeed, draggingHeight = false, false

speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingSpeed = false end
        end)
    end
end)

heightHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingHeight = true
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingHeight = false end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingSpeed then
            local relX = input.Position.X - speedSlider.AbsolutePosition.X
            local clampX = math.clamp(relX, 0, speedSlider.AbsoluteSize.X)
            speedHandle.Position = UDim2.new(0, clampX, 0, 0)
            local pct = clampX / speedSlider.AbsoluteSize.X
            speed = math.floor(5 + pct * 95)
            speedLabel.Text = "Скорость: " .. speed
        elseif draggingHeight then
            local relX = input.Position.X - heightSlider.AbsolutePosition.X
            local clampX = math.clamp(relX, 0, heightSlider.AbsoluteSize.X)
            heightHandle.Position = UDim2.new(0, clampX, 0, 0)
            local pct = clampX / heightSlider.AbsoluteSize.X
            height = math.floor(10 + pct * 90)
            heightLabel.Text = "Высота (только воздух): " .. height
        end
    end
end)

-- Tween функция
local function tweenTo(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (pos - hrp.Position).Magnitude
    local time = distance / speed
    local ti = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(pos)}
    local tw = TweenService:Create(hrp, ti, goal)
    tw:Play()
    tweening = true
    tw.Completed:Wait()
    tweening = false
end

-- Кнопки
btnSetBase.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePos = char.HumanoidRootPart.Position
        btnSetBase.Text = "✅ База установлена"
        task.wait(1)
        btnSetBase.Text = "📍 Установить базу"
    end
end)

btnMode.MouseButton1Click:Connect(function()
    useAir = not useAir
    btnMode.Text = useAir and "☁️ Режим: Воздух" or "🌍 Режим: Земля"
end)

btnTweenTP.MouseButton1Click:Connect(function()
    if basePos and not tweening then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        if useAir then
            -- вверх
            hrp.CFrame = hrp.CFrame + Vector3.new(0, height, 0)
            task.wait(0.1)
            -- полёт
            local airPos = Vector3.new(basePos.X, basePos.Y + height, basePos.Z)
            tweenTo(airPos)
            task.wait(0.05)
            -- падение
            hrp.Anchored = false
        else
            tweenTo(basePos)
        end
    end
end)

btnNoClip.MouseButton1Click:Connect(function()
    noClip = not noClip
    btnNoClip.Text = noClip and "✅ No Clip: Вкл" or "🚫 No Clip: Выкл"
end)

RunService.Stepped:Connect(function()
    if noClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)
