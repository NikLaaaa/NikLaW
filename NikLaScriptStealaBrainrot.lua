local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = character:WaitForChild("HumanoidRootPart")
	hum = character:WaitForChild("Humanoid")
end)

local gui = Instance.new("ScreenGui")
gui.Name = "NikLaScriptGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Основной фрейм с GUI
local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = gui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

local uistroke = Instance.new("UIStroke", frame)
uistroke.Thickness = 2
uistroke.Color = Color3.fromRGB(70, 70, 70)
uistroke.Transparency = 0.5

-- Заголовок с радужным эффектом
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Text = "NikLaStore"
title.TextStrokeTransparency = 0.7
title.TextWrapped = true

local colors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(75, 0, 130),
	Color3.fromRGB(148, 0, 211)
}

spawn(function()
	local i = 1
	local t = 0
	while true do
		local nextIndex = i + 1
		if nextIndex > #colors then nextIndex = 1 end
		while t < 1 do
			title.TextColor3 = colors[i]:Lerp(colors[nextIndex], t)
			t = t + 0.01
			task.wait(0.03)
		end
		t = 0
		i = nextIndex
	end
end)

-- Кнопка переключения GUI
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "—"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 24
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.Parent = gui
toggleButton.ZIndex = 10

local guiVisible = true

toggleButton.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	frame.Visible = guiVisible
	if guiVisible then
		toggleButton.Text = "—"
	else
		toggleButton.Text = "+"
	end
end)

-- Кнопка скорости
local speedEnabled = false
local defaultSpeed = hum and hum.WalkSpeed or 16
local customSpeed = 50

local speedButton = Instance.new("TextButton", frame)
speedButton.Position = UDim2.new(0, 20, 0, 50)
speedButton.Size = UDim2.new(1, -40, 0, 40)
speedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedButton.TextColor3 = Color3.fromRGB(240, 240, 240)
speedButton.Font = Enum.Font.Gotham
speedButton.TextSize = 16
speedButton.Text = "Speed Off"

local function updateSpeedButton()
	if speedEnabled then
		speedButton.Text = "Speed On"
		speedButton.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
	else
		speedButton.Text = "Speed Off"
		speedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end

speedButton.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	updateSpeedButton()
	if hum then
		if speedEnabled then
			hum.WalkSpeed = customSpeed
		else
			hum.WalkSpeed = defaultSpeed
		end
	end
end)

updateSpeedButton()

-- TP Up / TP Down
local function createTPButton(text, yPos, offsetY)
	local btn = Instance.new("TextButton", frame)
	btn.Position = UDim2.new(0, 20, 0, yPos)
	btn.Size = UDim2.new(1, -40, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.Text = text

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		if hrp then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, offsetY, 0)
		end
	end)

	return btn
end

local tpUpButton = createTPButton("TP Up", 100, 195)
local tpDownButton = createTPButton("TP Down", 150, -180)

-- TP10Up
local tp10UpActive = false
local tp10Height = 0

local tp10UpButton = Instance.new("TextButton", frame)
tp10UpButton.Position = UDim2.new(0, 20, 0, 200)
tp10UpButton.Size = UDim2.new(1, -40, 0, 40)
tp10UpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tp10UpButton.TextColor3 = Color3.fromRGB(240, 240, 240)
tp10UpButton.Font = Enum.Font.Gotham
tp10UpButton.TextSize = 16
tp10UpButton.Text = "TP10Up Off"

local uicorner = Instance.new("UICorner", tp10UpButton)
uicorner.CornerRadius = UDim.new(0, 6)

tp10UpButton.MouseButton1Click:Connect(function()
	tp10UpActive = not tp10UpActive
	if tp10UpActive and hrp then
		tp10Height = hrp.Position.Y + 10
		tp10UpButton.Text = "TP10Up On"
		tp10UpButton.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
	else
		tp10UpButton.Text = "TP10Up Off"
		tp10UpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

-- AutoStealth
local autoStealthEnabled = false
local stealthHeight = 5 -- Уменьшил высоту до 5 юнитов
local highTeleportHeight = 195
local driftSpeed = 75 -- Быстрая скорость
local bodyPosition = nil
local lastPosition = nil

local autoStealthButton = Instance.new("TextButton", frame)
autoStealthButton.Position = UDim2.new(0, 20, 0, 250)
autoStealthButton.Size = UDim2.new(1, -40, 0, 40)
autoStealthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoStealthButton.TextColor3 = Color3.fromRGB(240, 240, 240)
autoStealthButton.Font = Enum.Font.Gotham
autoStealthButton.TextSize = 16
autoStealthButton.Text = "AutoStealth Off"

local uicorner = Instance.new("UICorner", autoStealthButton)
uicorner.CornerRadius = UDim.new(0, 6)

-- Функция проверки крыши
local function isRoofOpen()
	local rayOrigin = hrp.Position + Vector3.new(0, stealthHeight + 2, 0)
	local rayDirection = Vector3.new(0, 100, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if not result then
		warn("Roof is open!")
		return true
	else
		warn("Roof is closed, hit: " .. tostring(result.Instance))
		return false
	end
end

local function updateStealthButton()
	if autoStealthEnabled then
		autoStealthButton.Text = "AutoSteal BETA On"
		autoStealthButton.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
	else
		autoStealthButton.Text = "AutoSteal BETA Off"
		autoStealthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end

autoStealthButton.MouseButton1Click:Connect(function()
	autoStealthEnabled = not autoStealthEnabled
	updateStealthButton()
	if autoStealthEnabled and hrp then
		local pos = hrp.Position
		lastPosition = pos
		-- Создаем BodyPosition для зависания
		bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(0, 30000, 0) -- Уменьшил силу
		bodyPosition.Position = Vector3.new(pos.X, pos.Y + stealthHeight, pos.Z)
		bodyPosition.D = 800 -- Меньше демпфирование для плавности
		bodyPosition.P = 8000 -- Меньше сила для обхода античита
		bodyPosition.Parent = hrp
	else
		if bodyPosition then
			bodyPosition:Destroy()
			bodyPosition = nil
		end
		hrp.Velocity = Vector3.new(0, 0, 0)
		lastPosition = nil
	end
end)

-- Обновление в Heartbeat
RunService.Heartbeat:Connect(function(deltaTime)
	if speedEnabled and hum and hum.WalkSpeed ~= customSpeed then
		hum.WalkSpeed = customSpeed
	elseif not speedEnabled and hum and hum.WalkSpeed ~= defaultSpeed then
		hum.WalkSpeed = defaultSpeed
	end

	if tp10UpActive and hrp then
		local pos = hrp.Position
		if pos.Y < tp10Height then
			hrp.CFrame = CFrame.new(pos.X, tp10Height, pos.Z)
		else
			hrp.Velocity = Vector3.new(hrp.Velocity.X, math.max(hrp.Velocity.Y, 0), hrp.Velocity.Z)
		end
	end

	if autoStealthEnabled and hrp and hum then
		local camera = Workspace.CurrentCamera
		local pos = hrp.Position

		-- Проверка на телепорт назад
		if lastPosition and (pos - lastPosition).Magnitude > 10 then
			warn("Teleport back detected! Disabling AutoStealth. Distance: " .. (pos - lastPosition).Magnitude)
			if bodyPosition then
				bodyPosition:Destroy()
				bodyPosition = nil
			end
			hrp.Velocity = Vector3.new(0, 0, 0)
			lastPosition = nil
			autoStealthEnabled = false
			updateStealthButton()
			return
		end

		-- Обновление позиции BodyPosition
		if bodyPosition then
			bodyPosition.Position = Vector3.new(pos.X, lastPosition.Y + stealthHeight, pos.Z)
		end

		-- Движение по направлению камеры через CFrame
		if camera then
			local cameraDirection = camera.CFrame.LookVector
			local horizontalDirection = Vector3.new(cameraDirection.X, 0, cameraDirection.Z).Unit
			local moveVector = horizontalDirection * driftSpeed * deltaTime
			-- Проверка на столкновение
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {character}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			local rayResult = Workspace:Raycast(pos, moveVector * 2, raycastParams)
			if not rayResult then
				hrp.CFrame = hrp.CFrame + moveVector
			else
				warn("Movement blocked by: " .. tostring(rayResult.Instance)) -- Отладка застревания
			end
		end

		-- Обновляем последнюю позицию
		lastPosition = pos

		-- Проверка крыши и телепорт на 195 юнитов
		if isRoofOpen() then
			if bodyPosition then
				bodyPosition:Destroy()
				bodyPosition = nil
			end
			hrp.CFrame = CFrame.new(pos.X, pos.Y + highTeleportHeight, pos.Z)
			hrp.Velocity = Vector3.new(0, 0, 0)
			lastPosition = nil
			autoStealthEnabled = false
			updateStealthButton()
		end
	end
end)
