-- Strongest Battle Ground Character Script with More Powers

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- // Player Variables
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- // GUI Elements (Assuming a Hotbar and MagicHealth GUI exist)
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hotbar = playerGui:FindFirstChild("Hotbar")
local backpack = hotbar:FindFirstChild("Backpack")
local hotbarFrame = backpack:FindFirstChild("Hotbar")
local magicHealthFrame = playerGui:FindFirstChild("ScreenGui"):FindFirstChild("MagicHealth")
local ultimateNameLabel = magicHealthFrame:FindFirstChild("TextLabel")

-- // Animation IDs
local move1AnimId = 10468665991
local move2AnimId = 10466974800
local move3AnimId = 10471336737
local move4AnimId = 12510170988
local wallComboAnimId = 15955393872
local ultActivationAnimId = 12447707844
local dashAnimId = 10479335397
local uppercutAnimId = 10503381238
local downslamAnimId = 10470104242
local idleAnimId = "rbxassetid://15099756132"
local runAnimId = "rbxassetid://15962326593"

-- // Replacement Punch Animations
local replacementAnimations = {
    ["10469493270"] = "rbxassetid://17889458563", -- punch1
    ["10469630950"] = "rbxassetid://17889461810", -- punch2
    ["10469639222"] = "rbxassetid://17889471098", -- punch3
    ["10469643643"] = "rbxassetid://17889290569", -- punch4
    ["17859015788"] = "rbxassetid://12684185971", -- downslam finisher
    ["11365563255"] = "rbxassetid://14516273501"  -- punch idk
}

local animationsToStop = {
    [17859015788] = true, -- downslam finisher
    [10469493270] = true, -- punch1
    [10469630950] = true, -- punch2
    [10469639222] = true, -- punch3
    [10469643643] = true, -- punch4
}

local animationQueue = {}
local isPunchAnimating = false

-- // Ultimate Ability Variables
local ultimateName = "Supernova Strike" -- Customize your ultimate name
local isUltimateCharged = false
local ultimateCharge = 0
local maxUltimateCharge = 100 -- Example value

-- // Movement Speed Multiplier for Dash
local dashSpeedMultiplier = 2.5
local isDashing = false

-- // Function to Play Animation
local function playAnim(animId, speed, loop)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animId
    local animTrack = animator:LoadAnimation(animation)
    animTrack:Play(0, false, loop)
    animTrack:AdjustSpeed(speed)
    return animTrack
end

-- // Function to Stop All Playing Animations
local function stopAllAnims()
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

-- // Function to Handle Punch Animations
local function playReplacementPunch(animationId)
    if isPunchAnimating then
        table.insert(animationQueue, animationId)
        return
    end

    isPunchAnimating = true
    local replacementAnimId = replacementAnimations[tostring(animationId)]
    if replacementAnimId then
        local animTrack = playAnim(replacementAnimId, 1, false)
        animTrack.Stopped:Connect(function()
            isPunchAnimating = false
            if #animationQueue > 0 then
                local nextAnimId = table.remove(animationQueue, 1)
                playReplacementPunch(nextAnimId)
            end
        end)
    else
        isPunchAnimating = false
    end
end

local function onAnimationPlayed(animationTrack)
    local animId = tonumber(animationTrack.Animation.AnimationId:match("%d+"))
    if animationsToStop[animId] then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            local currentAnimId = tonumber(track.Animation.AnimationId:match("%d+"))
            if animationsToStop[currentAnimId] then
                track:Stop()
            end
        end
        animationTrack:Stop()
        if replacementAnimations[tostring(animId)] then
            playReplacementPunch(animId)
        end
    end
end
humanoid.AnimationPlayed:Connect(onAnimationPlayed)

-- // Update Hotbar Tool Names
if hotbarFrame then
    if hotbarFrame:FindFirstChild("1") then
        hotbarFrame["1"].Base.ToolName.Text = "Move1"
    end
    if hotbarFrame:FindFirstChild("2") then
        hotbarFrame["2"].Base.ToolName.Text = "Move2"
    end
    if hotbarFrame:FindFirstChild("3") then
        hotbarFrame["3"].Base.ToolName.Text = "Move3"
    end
    if hotbarFrame:FindFirstChild("4") then
        hotbarFrame["4"].Base.ToolName.Text = "Move4"
    end
end

-- // Update Ultimate Name
local function updateUltimateName()
    if ultimateNameLabel then
        ultimateNameLabel.Text = ultimateName
    end
end
playerGui.DescendantAdded:Connect(updateUltimateName)
updateUltimateName()

-- // Movement Functions
local function applyDash()
    if isDashing then return end
    isDashing = true
    local currentSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = currentSpeed * dashSpeedMultiplier
    local dashAnimTrack = playAnim(dashAnimId, 1.3, false)
    wait(1.8)
    if humanoid.Parent then -- Check if the character still exists
        humanoid.WalkSpeed = currentSpeed
    end
    isDashing = false
    if dashAnimTrack then
        dashAnimTrack:Stop()
    end
end

-- // Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyCode = input.KeyCode

        if keyCode == Enum.KeyCode.Alpha1 then
            playAnim(move1AnimId, 1, false)
            playAnim("17838006839", 0.9, false) -- Move 1 Secondary Anim
        elseif keyCode == Enum.KeyCode.Alpha2 then
            playAnim(move2AnimId, 1, false)
            playAnim("18181589384", 1, false) -- Move 2 Secondary Anim
        elseif keyCode == Enum.KeyCode.Alpha3 then
            local move3AnimTrack = playAnim(move3AnimId, 1, false)
            playAnim("17838619895", 1, false) -- Move 3 Secondary Anim
            if move3AnimTrack then
                move3AnimTrack:AdjustSpeed(0)
                move3AnimTrack.TimePosition = 0.3
                move3AnimTrack:AdjustSpeed(1)
                wait(1.8)
                if move3AnimTrack.IsPlaying then
                    move3AnimTrack:Stop()
                end
            end
        elseif keyCode == Enum.KeyCode.Alpha4 then
            local move4AnimTrack = playAnim(move4AnimId, 1, false)
            playAnim("16515850153", 1, false) -- Move 4 Secondary Anim
            if move4AnimTrack then
                move4AnimTrack:AdjustSpeed(0)
                move4AnimTrack.TimePosition = 0
                move4AnimTrack:AdjustSpeed(1)
            end
        elseif keyCode == Enum.KeyCode.Q then
            playAnim(wallComboAnimId, 1, false)
            local wallComboSecondaryAnimTrack = playAnim("15943915877", 1, false)
            if wallComboSecondaryAnimTrack then
                wallComboSecondaryAnimTrack:AdjustSpeed(0)
                wallComboSecondaryAnimTrack.TimePosition = 0.05
                wallComboSecondaryAnimTrack:AdjustSpeed(1)
            end
        elseif keyCode == Enum.KeyCode.E and isUltimateCharged then
            isUltimateCharged = false
            ultimateCharge = 0
            updateUltimateChargeDisplay() -- Implement this function
            playAnim(ultActivationAnimId, 1, false)
            playAnim("17106858586", 1, false) -- Ultimate Secondary Anim
            -- // Implement your ultimate ability logic here
            sendMessage(ultimateName .. " Activated!")
            -- Example: Create a powerful AOE effect
            local shockwave = Instance.new("Part")
            shockwave.Shape = Enum.PartType.Ball
            shockwave.Size = Vector3.new(10, 10, 10)
            shockwave.CFrame = humanoidRootPart.CFrame
            shockwave.Anchored = true
            shockwave.CanCollide = false
            shockwave.Material = Enum.Material.Neon
            shockwave.Color = Color3.fromRGB(255, 255, 0)
            shockwave.Transparency = 0.5
            shockwave.Parent = workspace
            game:GetService("Debris"):AddItem(shockwave, 3)
        elseif keyCode == Enum.KeyCode.LeftShift then
            applyDash()
        elseif keyCode == Enum.KeyCode.F then
            playAnim(uppercutAnimId, 0.7, false)
            local uppercutSecondaryAnimTrack = playAnim("14900168720", 0.7, false)
            if uppercutSecondaryAnimTrack then
                uppercutSecondaryAnimTrack:AdjustSpeed(0)
                uppercutSecondaryAnimTrack.TimePosition = 1.3
                uppercutSecondaryAnimTrack:AdjustSpeed(0.7)
            end
        elseif keyCode == Enum.KeyCode.C then
            local downslamAnimTrack = playAnim(downslamAnimId, 6, false)
            playAnim("12447247483", 6, false) -- Downslam Secondary Anim
            if downslamAnimTrack then
                downslamAnimTrack:AdjustSpeed(0)
                downslamAnimTrack.TimePosition = 0
                wait(0.2)
                downslamAnimTrack:AdjustSpeed(6)
            end
        end
    end
end)

-- // Prevent Root Motion on BodyVelocities (May need adjustments based on your game)
local function onBodyVelocityAdded(bodyVelocity)
    if bodyVelocity:IsA("BodyVelocity") then
        bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, 0, bodyVelocity.Velocity.Z)
    end
end
character.DescendantAdded:Connect(onBodyVelocityAdded)
for _, descendant in pairs(character:GetDescendants()) do
    onBodyVelocityAdded(descendant)
end
localPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    character.DescendantAdded:Connect(onBodyVelocityAdded)
    for _, descendant in pairs(character:GetDescendants()) do
        onBodyVelocityAdded(descendant)
    end
end)

-- // Send Initial Messages
local messagesToSend = {"Entering the Battle!", "Ready for Action!", "Unleashing my Power!", "Prepare to be Amazed!"}
local function sendMessage(text)
    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
end
for _, message in ipairs(messagesToSend) do
    sendMessage(message)
    wait(1.7)
end

-- // Idle Animation
local idleAnimTrack = playAnim(idleAnimId, 1, true)
local function updateIdleAnimation()
    if humanoid.MoveDirection.Magnitude > 0 then
        if idleAnimTrack.IsPlaying then
            idleAnimTrack:Stop()
        end
    else
        if not idleAnimTrack.IsPlaying then
            idleAnimTrack:Play()
        end
    end
end
game:GetService("RunService").RenderStepped:Connect(updateIdleAnimation)

-- // Run Animation
local runAnimTrack = playAnim(runAnimId, 1, true)
local function updateRunAnimation()
    if humanoid.MoveDirection.Magnitude > 0 then
        if not runAnimTrack.IsPlaying then
            runAnimTrack:Play()
        end
    else
        if runAnimTrack.IsPlaying then
            runAnimTrack:Stop()
        end
    end
end
humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(updateRunAnimation)
updateRunAnimation()

-- // Example Ultimate Charge Increase (Replace with your actual charging mechanism)
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    if not isUltimateCharged then
        ultimateCharge = math.min(ultimateCharge + (deltaTime * 5), maxUltimateCharge) -- Increase charge over time
        if ultimateCharge >= maxUltimateCharge then
            isUltimateCharged = true
            sendMessage("Ultimate Ready!")
        end
        updateUltimateChargeDisplay() -- Implement this function to update a GUI element
    end
end)

-- // Placeholder for Ultimate Charge Display Function (Implement your GUI update logic)
local function updateUltimateChargeDisplay()
    -- Find your GUI element to display the ultimate charge and update its text or visual representation
    -- Example:
    -- if magicHealthFrame then
    --     local chargeBar = magicHealthFrame:FindFirstChild("UltimateChargeBar")
    --     if chargeBar:IsA("GuiObject") then
    --         chargeBar.Size = UDim2.new(ultimateCharge / maxUltimateCharge, 0, 1, 0)
    --     end
    -- end
end
