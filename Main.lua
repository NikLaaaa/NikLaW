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

-- Удаляем старый GUI
if game.CoreGui:FindFirstChild("TweenTPGui") then
    game.CoreGui:FindFirstChild("TweenTPGui"):Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TweenTPGui"
gui.ResetOnSpawn = false

-- Кнопка переключения GUI
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.Text = "+"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 24
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true
toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.ClipsDescendants = true
toggleButton.BackgroundTransparency = 0
toggleButton.ZIndex = 10
toggleButton.TextScaled = true
toggleButton.Name = "ToggleGUI"
toggleButton.Visible = true
toggleButton:SetAttribute("Open", false)
toggleButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
toggleButton.ClipsDescendants = false
toggleButton.TextWrapped = true
toggleButton.TextStrokeTransparency = 0.8
toggleButton.TextStrokeColor3 = Color3.new(1,1,1)
toggleButton.TextStrokeTransparency = 0.8
toggleButton.TextXAlignment = Enum.TextXAlignment.Center
toggleButton.TextYAlignment = Enum.TextYAlignment.Center
toggleButton.TextTransparency = 0
toggleButton.BackgroundTransparency = 0
toggleButton.BorderMode = Enum.BorderMode.Outline
toggleButton.BorderSizePixel = 0
toggleButton.BackgroundColor3 = Color3.new(0,0,0)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Text = "≡"
toggleButton.AutoButtonColor = true
toggleButton.ZIndex = 10
toggleButton.Name = "OpenButton"
toggleButton.ClipsDescendants = false
toggleButton.TextScaled = true
toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.TextWrapped = true
toggleButton.TextSize = 30
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "≡"
toggleButton.AutoButtonColor = true
toggleButton.ZIndex = 10
toggleButton.Name = "ToggleGUI"
toggleButton.ClipsDescendants = false
toggleButton.TextScaled = true
toggleButton.TextWrapped = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextStrokeTransparency = 0.5
toggleButton.TextStrokeColor3 = Color3.new(1,1,1)
toggleButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
toggleButton.BorderMode = Enum.BorderMode.Outline
toggleButton.TextXAlignment = Enum.TextXAlignment.Center
toggleButton.TextYAlignment = Enum.TextYAlignment.Center
toggleButton.TextTransparency = 0
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.BackgroundColor3 = Color3.new(0,0,0)
toggleButton.TextColor3 = Color3.new(1,1,1)

-- Окно GUI
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- изначально скрыто

-- Открытие/Закрытие GUI
toggleButton.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- === Ниже добавляй весь остальной твой GUI код (createLabel, createSlider, кнопки и т.п.)
-- НЕ забудь, что теперь `frame` - это родитель всех элементов GUI
-- Они будут скрываться/открываться по нажатию на кнопку-круг
