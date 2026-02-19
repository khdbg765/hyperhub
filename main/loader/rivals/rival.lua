local HRSetting = _G.HRSetting
local HRHelper = _G.HRHelper
local HRSet = HRSetting:onLoad()
local ParentUI = HRSet.ScreenUI

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // STATES // --
local aimbotEnabled, togEsp, togSpeed, togFly = false, false, false, false
local ESP_Cache = {}
local aimbotConnection

-- // SETTINGS // --
local AimbotSettings = {
    TeamCheck = true,
    FOV = 150,
    Smoothness = 0.5,
    Part = "Head",
    Prediction = 0.05
}
local speedConfig = { value = 16 }

-- // VISUAL FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

--- // TARGETING LOGIC (WORK VERSION) // ---
local function GetClosestTarget()
    if not LocalPlayer.Character then return nil end
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
        if not targetPart then continue end
        
        local partPos = targetPart.Position
        if player.Character:FindFirstChild("HumanoidRootPart") then
            partPos = partPos + (player.Character.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = targetPart
            end
        end
    end
    return closest
end

--- // AIMBOT CONNECTION // ---
local function StartAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RS.RenderStepped:Connect(function()
        if not aimbotEnabled or not LocalPlayer.Character then return end
        local target = GetClosestTarget()
        if target then
            local targetPosition = target.Position
            if target.Parent:FindFirstChild("HumanoidRootPart") then
                targetPosition = targetPosition + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
            end
            local screenPoint = Camera:WorldToScreenPoint(targetPosition)
            if screenPoint.Z > 0 then
                local delta = Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)
                mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
            end
        end
    end)
end

local function StopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
end

--- // OTHER LOGICS (ESP & SPEED) // ---
RS.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedConfig.value
    end

    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character then continue end
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Highlight = Instance.new("Highlight", ParentUI)}
                end
                local esp = ESP_Cache[player]
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
                    local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                    esp.Box.Visible, esp.Box.Size, esp.Box.Position, esp.Box.Color = true, Vector2.new(sizeX, sizeY), Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2), color
                    esp.Name.Visible, esp.Name.Text, esp.Name.Position, esp.Name.Color = true, player.Name, Vector2.new(pos.X, pos.Y - sizeY / 2 - 15), color
                    esp.Highlight.Enabled, esp.Highlight.Adornee = true, char
                else
                    esp.Box.Visible, esp.Name.Visible, esp.Highlight.Enabled = false, false, false
                end
            end
        end
    end
end)

--- // UI MENU // ---
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Speed Val", 16, 200, "changeSpeed")
HRSetting:addToggle("Movements", "Fly", "fly")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "FOV Range", 50, 800, "changeAimbotRange")
HRSetting:addSlider("Combat", "Smoothness", 1, 100, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Prediction", 1, 100, "changeAimbotPrediction")

HRSetting:addToggle("Visual", "Esp", "esp")

--- // HELPERS // ---
function HRHelper:speed()
    togSpeed = not togSpeed
    HRHelper.showToast("Speed: " .. (togSpeed and "ON" or "OFF"))
    if not togSpeed and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
end
function HRHelper:changeSpeed(val) speedConfig.value = val end
function HRHelper:fly() togFly = not togFly HRHelper.showToast("Fly: " .. (togFly and "ON" or "OFF")) end

function HRHelper:aimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    HRHelper.showToast("Aimbot: " .. (aimbotEnabled and "Enabled" or "Disabled"))
    if aimbotEnabled then StartAimbot() else StopAimbot() end
end

function HRHelper:changeAimbotRange(val) AimbotSettings.FOV = val end
function HRHelper:changeAimbotSmoothness(val) AimbotSettings.Smoothness = val / 100 end
function HRHelper:changeAimbotPrediction(val) AimbotSettings.Prediction = val / 1000 end
function HRHelper:esp()
    togEsp = not togEsp
    HRHelper.showToast("ESP: " .. (togEsp and "ON" or "OFF"))
    if not togEsp then
        for p, obs in pairs(ESP_Cache) do
            for _, obj in pairs(obs) do if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end end
            ESP_Cache[p] = nil
        end
    end
end

HRHelper.showToast("Rivals Script Loaded")
