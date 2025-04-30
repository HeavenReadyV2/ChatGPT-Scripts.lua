local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local frame = script.Parent
local runService = game:GetService("RunService")

-- Make UI draggable
local dragging, offset
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        offset = input.Position - frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging then
        frame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
    end
end)

-- Create player list
local selectedPlayer = nil
local listLayout = frame:FindFirstChildWhichIsA("UIListLayout") or Instance.new("UIListLayout", frame)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        local button = Instance.new("TextButton")
        button.Text = "Aim at " .. plr.Name
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = frame

        button.MouseButton1Click:Connect(function()
            selectedPlayer = plr
        end)
    end
end

-- Aim camera at target
runService.RenderStepped:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
        camera.CFrame = CFrame.new(camera.CFrame.Position, selectedPlayer.Character.Head.Position)
    end
end)
