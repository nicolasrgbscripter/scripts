local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Efeito de ColorCorrection para contraste
local colorEffect = Instance.new("ColorCorrectionEffect")
colorEffect.Parent = Lighting
colorEffect.Enabled = false
colorEffect.Saturation = 0
colorEffect.Contrast = 0

-- Função tween para Lighting
local function tweenLighting(properties, duration)
    local tween = TweenService:Create(Lighting, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), properties)
    tween:Play()
    return tween
end

-- Fase 1: tudo preto suavemente
tweenLighting({
    Brightness = 0,
    ClockTime = 0,
    FogColor = Color3.new(0, 0, 0),
    Ambient = Color3.new(0, 0, 0),
    OutdoorAmbient = Color3.new(0, 0, 0),
    FogStart = 0,
    FogEnd = 25,
}, 4)

task.wait(4) -- Espera 4 segundos antes de executar o resto

-- Fase 2: vermelho e contraste alto
tweenLighting({
    Brightness = 5,
    ClockTime = 0,
    FogColor = Color3.fromRGB(255, 0, 0),
    Ambient = Color3.fromRGB(255, 0, 0),
    OutdoorAmbient = Color3.fromRGB(255, 0, 0),
    FogStart = 0,
    FogEnd = 100000,
}, 3)

-- Ativa contraste extremo
colorEffect.Enabled = true
TweenService:Create(colorEffect, TweenInfo.new(2), {Contrast = 2, Saturation = 1}):Play()

-- ================================
-- RESTO DO SCRIPT ORIGINAL
-- ================================

local function getCharacter()
    if LocalPlayer.Character then
        return LocalPlayer.Character
    end
    return LocalPlayer.CharacterAdded:Wait()
end

local char = getCharacter()
local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")

for _, item in ipairs(char:GetChildren()) do
    if item:IsA("Accessory") or item:IsA("Clothing") or item:IsA("Shirt") or item:IsA("Pants") then
        item:Destroy()
    elseif item:IsA("Decal") and item.Name == "face" then
        item:Destroy()
    end
end

for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("Decal") and part.Name == "face" then
        part:Destroy()
    elseif part:IsA("BasePart") then
        part.Transparency = 1
    end
end

local fogGui
if torso then
    fogGui = Instance.new("BillboardGui", torso)
    fogGui.Name = "Unknown"
    fogGui.Size = UDim2.new(15, 0, 15, 0)
    fogGui.StudsOffset = Vector3.new(0, 3.5, 0)
    fogGui.AlwaysOnTop = true

    local img = Instance.new("ImageLabel", fogGui)
    img.Name = "פרחים"
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://100116330752193"

    -- Vira horizontalmente usando UIGradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 180
    gradient.Parent = img

    local light = Instance.new("PointLight", torso)
    light.Color = Color3.new(0.6, 0, 0)
    light.Range = 15
    light.Brightness = 5
end

local sound = Instance.new("Sound", char)
sound.SoundId = "rbxassetid://9041745502"
sound.Volume = 5
sound.Looped = true
sound:Play()

local humanoid = char:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.WalkSpeed = 1
    humanoid.JumpPower = 0
    humanoid.Died:Connect(function()
        LocalPlayer:Kick("Client Initiate Disconected")
    end)
end

Lighting.ClockTime = 0
Lighting.Brightness = 2
Lighting.FogEnd = 100000
Lighting.FogStart = 0
Lighting.FogColor = Color3.new(1, 1, 1)
Lighting.Ambient = Color3.new(1, 1, 1)
Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

local kickTool = Instance.new("Tool")
kickTool.Name = "Do You HeAr IT?"
kickTool.RequiresHandle = false
kickTool.Parent = LocalPlayer.Backpack

local teleportTool = Instance.new("Tool")
teleportTool.Name = "No scaPe"
teleportTool.RequiresHandle = false
teleportTool.Parent = LocalPlayer.Backpack

local function setupDoubleClick(tool, onDoubleClick, onDeactivate)
    local clicks = 0
    local lastClickTime = 0

    local function resetClicks()
        clicks = 0
    end

    local function onClick()
        local now = tick()
        if now - lastClickTime < 0.4 then
            clicks = clicks + 1
        else
            clicks = 1
        end
        lastClickTime = now

        if clicks == 1 then
            onDoubleClick()
            resetClicks()
        end
    end

    tool.Activated:Connect(onClick)
    tool.Deactivated:Connect(onDeactivate)
end

local deleteLoop = false
local function startDeletingOthers()
    deleteLoop = true
    task.spawn(function()
        while deleteLoop do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character:Destroy()
                end
            end
            for _, item in ipairs(Players:GetChildren()) do
                if item:IsA("Player") and item ~= LocalPlayer then
                    item:Destroy()
                end
            end
            for _, model in ipairs(workspace:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model ~= char then
                    model:Destroy()
                end
            end
            task.wait(0.25)
        end
    end)
end

local function stopDeletingOthers()
    deleteLoop = false
end

setupDoubleClick(kickTool, startDeletingOthers, stopDeletingOthers)

setupDoubleClick(teleportTool, function()
    if mouse and mouse.Hit then
        char:MoveTo(mouse.Hit.Position)
    end
end, function() end)

if torso then
    torso.Touched:Connect(function(hit)
        local h = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
        if h and h ~= humanoid then
            h.Health = 0
        end
    end)
end

task.delay(0, function()
    local s = Instance.new("Sound", workspace)
    s.SoundId = "rbxassetid://105563161022755"
    s.Volume = 5
    s:Play()
    task.delay(100000000000000000000000, function()
        LocalPlayer:Kick("Client initiated disconnected")
    end)
end)
