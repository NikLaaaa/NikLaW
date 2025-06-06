-- Main.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "CustomMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "OHIO Hub"
title.Size = UDim2.new(1, 0, 0, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

-- Button helper
local function createButton(text, yPos, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 20
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Teleport buttons
createButton("🛡 Полицейская карта", 40, function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "Police Armory Keycard" and obj:IsA("BasePart") then
			HRP.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
			break
		end
	end
end)

createButton("🎖 Военная карта", 80, function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "Military Armory Keycard" and obj:IsA("BasePart") then
			HRP.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
			break
		end
	end
end)

-- Fly
local flying = false
local UIS = game:GetService("UserInputService")
local velocity = Vector3.zero

local function flyFunc()
	if not flying then
		flying = true
		local bv = Instance.new("BodyVelocity", HRP)
		bv.Name = "FlyVelocity"
		bv.MaxForce = Vector3.new(1, 1, 1) * 1e9
		bv.Velocity = Vector3.zero

		UIS.InputBegan:Connect(function(input)
			if not flying then return end
			if input.KeyCode == Enum.KeyCode.W then velocity = Vector3.new(0, 0, -1)
			elseif input.KeyCode == Enum.KeyCode.S then velocity = Vector3.new(0, 0, 1)
			elseif input.KeyCode == Enum.KeyCode.A then velocity = Vector3.new(-1, 0, 0)
			elseif input.KeyCode == Enum.KeyCode.D then velocity = Vector3.new(1, 0, 0)
			elseif input.KeyCode == Enum.KeyCode.Space then velocity = Vector3.new(0, 1, 0)
			elseif input.KeyCode == Enum.KeyCode.LeftControl then velocity = Vector3.new(0, -1, 0)
			end
		end)

		UIS.InputEnded:Connect(function(input)
			velocity = Vector3.zero
		end)

		while flying and bv.Parent do
			bv.Velocity = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(velocity)) * 100
			task.wait()
		end
	else
		local bv = HRP:FindFirstChild("FlyVelocity")
		if bv then bv:Destroy() end
		flying = false
	end
end

createButton("✈ Флай (переключатель)", 120, flyFunc)

-- Speed Slider
local sliderText = Instance.new("TextLabel", frame)
sliderText.Text = "Скорость: 16"
sliderText.Size = UDim2.new(1, -20, 0, 30)
sliderText.Position = UDim2.new(0, 10, 0, 160)
sliderText.BackgroundTransparency = 1
sliderText.TextColor3 = Color3.new(1, 1, 1)
sliderText.Font = Enum.Font.SourceSans
sliderText.TextSize = 18

local slider = Instance.new("TextBox", frame)
slider.Position = UDim2.new(0, 10, 0, 190)
slider.Size = UDim2.new(1, -20, 0, 30)
slider.Text = "16"
slider.TextColor3 = Color3.new(1, 1, 1)
slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
slider.Font = Enum.Font.SourceSans
slider.TextSize = 20
slider.ClearTextOnFocus = false

slider.FocusLost:Connect(function()
	local speed = tonumber(slider.Text)
	if speed then
		Humanoid.WalkSpeed = speed
		sliderText.Text = "Скорость: " .. speed
	end
end)

-- Автообновление персонажа после смерти
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HRP = char:WaitForChild("HumanoidRootPart")
end)
