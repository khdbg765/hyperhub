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
local togAimbot, togSilentAim, togEsp, togSpeed, togFly = false, false, false, false, false
local ESP_Cache = {}

-- // SETTINGS // --
local AimbotSettings = {
    TeamCheck = true,
    WallCheck = false,
    FOV = 150,
    Smoothness = 0.5,
    Part = "Head",
    Prediction = 0.05,
}
local speedConfig = { value = 16 }

-- // VISUAL FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

--- // TARGETING LOGIC // ---
local function GetClosestTarget()
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        
        if targetPart and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closest = targetPart
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

--- // MAIN LOOP // ---
RS.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = AimbotSettings.FOV
    
    -- [AIMBOT]
    if togAimbot then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position
            local hrp = target.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then targetPos = targetPos + (hrp.Velocity * AimbotSettings.Prediction) end
            
            local screenPoint = Camera:WorldToViewportPoint(targetPos)
            local mouseLocation = UIS:GetMouseLocation()
            local delta = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation)
            
            -- Tarikan murni
            mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
        end
    end

    -- [SPEED]
    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedConfig.value
    end

    -- [ESP]
    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character then continue end
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
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
                    esp.Highlight.Enabled, esp.Highlight.Adornee, esp.Highlight.FillColor = true, char, color
                else
                    esp.Box.Visible, esp.Name.Visible, esp.Highlight.Enabled = false, false, false
                end
            end
        end
    else
        for p, obs in pairs(ESP_Cache) do
            for _, obj in pairs(obs) do if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end end
            ESP_Cache[p] = nil
        end
    end
end)

--- // UI MENU // ---
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Speed Value", 16, 200, "changeSpeed")
HRSetting:addToggle("Movements", "Fly", "fly")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "Aimbot Range", 50, 800, "changeAimbotRange")
HRSetting:addSlider("Combat", "Smoothness (1-100)", 1, 100, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Prediction (1-100)", 1, 100, "changeAimbotPrediction")

HRSetting:addToggle("Visual", "Esp", "esp")

--- // HELPERS // ---
function HRHelper:speed()
    togSpeed = not togSpeed
    HRHelper.showToast("Speed : " .. (togSpeed and "Enabled" or "Disabled"))
    if not togSpeed and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
end
function HRHelper:changeSpeed(val) speedConfig.value = val end
function HRHelper:fly()
    togFly = not togFly
    HRHelper.showToast("Fly : " .. (togFly and "Enabled" or "Disabled"))
end
function HRHelper:aimbot()
    togAimbot = not togAimbot
    FOVCircle.Visible = togAimbot
    HRHelper.showToast("Aimbot : " .. (togAimbot and "Enabled" or "Disabled"))
end
function HRHelper:changeAimbotRange(val) AimbotSettings.FOV = val end
function HRHelper:changeAimbotSmoothness(val) AimbotSettings.Smoothness = val / 100 end
function HRHelper:changeAimbotPrediction(val) AimbotSettings.Prediction = val / 1000 end
function HRHelper:esp()
    togEsp = not togEsp
    HRHelper.showToast("Esp : " .. (togEsp and "Enabled" or "Disabled"))
end
