-- Script3.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local FLING_FORCE = 50000
local FLING_RADIUS = 25

for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and not part.Anchored and (part.Position - root.Position).Magnitude <= FLING_RADIUS then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = (part.Position - root.Position).Unit * FLING_FORCE
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = part
        game.Debris:AddItem(bv, 0.2)
    end
end
