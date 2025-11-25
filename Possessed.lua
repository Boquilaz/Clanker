local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local INTRO_ANIM = "rbxassetid://127163904142732"
local IDLE_ANIM = "rbxassetid://75794256017298"
local WALK_ANIM = "rbxassetid://88508412373927"
local OUTRO_ANIM = "rbxassetid://127163904142732"

local isActive = false
local introInProgress = false
local introTrack = nil
local idleTrack = nil
local walkTrack = nil
local runTrack = nil
local outroTrack = nil
local speedConnection = nil
local idleLoopConnection = nil
local walkSpeedMonitor = nil

local introAnimation = Instance.new("Animation")
introAnimation.AnimationId = INTRO_ANIM

local idleAnimation = Instance.new("Animation")
idleAnimation.AnimationId = IDLE_ANIM

local walkAnimation = Instance.new("Animation")
walkAnimation.AnimationId = WALK_ANIM

local outroAnimation = Instance.new("Animation")
outroAnimation.AnimationId = OUTRO_ANIM

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YutaIsABitch!!"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "Possessed By The Femboy Demon"
title.TextColor3 = Color3.fromRGB(255, 100, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0, 55)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

local creditText = Instance.new("TextLabel")
creditText.Name = "CreditText"
creditText.Size = UDim2.new(1, 0, 0, 25)
creditText.Position = UDim2.new(0, 0, 1, -30)
creditText.BackgroundTransparency = 1
creditText.Text = "Made by Boquilaz"
creditText.TextColor3 = Color3.fromRGB(150, 150, 150)
creditText.TextSize = 14
creditText.Font = Enum.Font.Gotham
creditText.Parent = mainFrame

local dragging = false
local dragInput, mousePos, framePos

local function update(input)
	local delta = input.Position - mousePos
	mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		framePos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

local function stopDefaultAnimations()
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = true
	end
	
	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end

local function restoreDefaultAnimations()
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = false
	end
end

local function stopAllCustomAnimations()
	if introTrack then introTrack:Stop() end
	if idleTrack then idleTrack:Stop() end
	if walkTrack then walkTrack:Stop() end
	if runTrack then runTrack:Stop() end
	if outroTrack then outroTrack:Stop() end
	
	if speedConnection then speedConnection:Disconnect() end
	if idleLoopConnection then idleLoopConnection:Disconnect() end
	if walkSpeedMonitor then walkSpeedMonitor:Disconnect() end
end

local function disableMovement()
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoJumpEnabled = false
end

local function enableLimitedMovement()
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoJumpEnabled = false
end

local function restoreMovement()
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.JumpHeight = 7.2
	humanoid.AutoJumpEnabled = true
end

local function setupIdleLoop()
	if idleLoopConnection then
		idleLoopConnection:Disconnect()
	end
	
	if idleTrack then
		idleTrack:Stop()
	end
	
	local reversing = false
	
	idleTrack = animator:LoadAnimation(idleAnimation)
	idleTrack.Priority = Enum.AnimationPriority.Action
	idleTrack.Looped = false
	idleTrack:Play(0, 1, 1)
	
	idleLoopConnection = RunService.Heartbeat:Connect(function()
		if not isActive or not idleTrack then return end
		
		if not idleTrack.IsPlaying then
			idleTrack:Play(0, 1, 1)
			reversing = false
			return
		end
		
		local length = idleTrack.Length
		local timePos = idleTrack.TimePosition
		
		if not reversing and timePos >= length - 0.1 then
			reversing = true
			idleTrack:Play(0, 1, -1)
		elseif reversing and timePos <= 0.1 then
			reversing = false
			idleTrack:Play(0, 1, 1)
		end
	end)
end

local function setupWalkMonitor()
	if walkSpeedMonitor then
		walkSpeedMonitor:Disconnect()
	end
	
	walkTrack = animator:LoadAnimation(walkAnimation)
	walkTrack.Priority = Enum.AnimationPriority.Action
	walkTrack.Looped = true
	
	local isWalking = false
	
	walkSpeedMonitor = RunService.Heartbeat:Connect(function()
		if not isActive then return end
		
		local moving = humanoid.MoveDirection.Magnitude > 0
		
		if moving and not isWalking then
			isWalking = true
			if idleTrack then 
				idleTrack:Stop() 
				if idleLoopConnection then
					idleLoopConnection:Disconnect()
				end
			end
			walkTrack:Play()
		elseif not moving and isWalking then
			isWalking = false
			walkTrack:Stop()
			setupIdleLoop()
		end
		
		if isWalking then
			local speed = humanoid.WalkSpeed
			if speed >= 16 then
				walkTrack:AdjustSpeed(2.5)
			else
				walkTrack:AdjustSpeed(1)
			end
		end
	end)
end

local function playIntro()
	introInProgress = true
	disableMovement()
	
	stopDefaultAnimations()
	
	introTrack = animator:LoadAnimation(introAnimation)
	introTrack.Looped = false
	introTrack.Priority = Enum.AnimationPriority.Action4
	introTrack:Play()
	
	task.wait(3.5)
	
	setupIdleLoop()
	
	task.wait(0.5)
	
	introTrack:Stop()
	
	enableLimitedMovement()
	setupWalkMonitor()
	
	introInProgress = false
end

local function playOutro()
	disableMovement()
	
	stopAllCustomAnimations()
	
	outroTrack = animator:LoadAnimation(outroAnimation)
	outroTrack.Looped = false
	outroTrack.Priority = Enum.AnimationPriority.Action4
	outroTrack:Play()
	
	outroTrack.TimePosition = 3
	
	outroTrack.Ended:Wait()
	
	restoreDefaultAnimations()
	restoreMovement()
end

toggleButton.MouseButton1Click:Connect(function()
	if introInProgress then
		return
	end
	
	isActive = not isActive
	
	if isActive then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		playIntro()
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		playOutro()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.T then
		if introInProgress then
			return
		end
		
		isActive = not isActive
		
		if isActive then
			toggleButton.Text = "ON"
			toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			playIntro()
		else
			toggleButton.Text = "OFF"
			toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			playOutro()
		end
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	animator = humanoid:WaitForChild("Animator")
	isActive = false
	introInProgress = false
	stopAllCustomAnimations()
	toggleButton.Text = "OFF"
	toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)
