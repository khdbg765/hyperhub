local HRSetting = _G.HRSetting
local HRHelper = _G.HRHelper
local HRSet = HRSetting:onLoad()
local ParentUI = HRSet.ScreenUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // SETTINGS PERSIS TAKA // --
local aimbotEnabled = false
local AimbotSettings = {
    FOV = 150,
    Smoothness = 0.5,
    Prediction = 0.05,
    Part = "Head",
    TeamCheck = true
}

-- // STATES // --
local togSpeed = false
local speedConfig = { value = 16 }
local togEsp = false
local ESP_Cache = {}

-- // VISUAL FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

-- // CORE LOGIC PERSIS TAKA // --
local function GetClosestTarget()
    local closest = nil
    local shortestDistance = AimbotSettings.FOV
    
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if AimbotSettings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local targetPart = v.Character:FindFirstChild(AimbotSettings.Part)
            if targetPart then
                local pos = targetPart.Position
                if v.Character:FindFirstChild("HumanoidRootPart") then
                    pos = pos + (v.Character.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
                end
                
                local screenPoint, onScreen = Camera:WorldToScreenPoint(pos)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = screenPoint
                    end
                end
            end
        end
    end
    return closest
end

-- // MAIN LOOP PERSIS TAKA // --
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    -- AIMBOT LOGIC
    if aimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local x = (target.X - Mouse.X) * AimbotSettings.Smoothness
            local y = (target.Y - Mouse.Y) * AimbotSettings.Smoothness
            mousemoverel(x, y)
        end
    end

    -- SPEED LOGIC
    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedConfig.value
    end

    -- ESP LOGIC (DIBALIKIN!)
    if togEsp then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {
                        Box = Drawing.new("Square"),
                        Highlight = Instance.new("Highlight", ParentUI)
                    }
                end
                local esp = ESP_Cache[player]
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen and char.Humanoid.Health > 0 then
                    local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
                    local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                    
                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(sizeX, sizeY)
                    esp.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    esp.Box.Color = color
                    
                    esp.Highlight.Enabled = true
                    esp.Highlight.Adornee = char
                    esp.Highlight.FillColor = color
                else
                    esp.Box.Visible = false
                    esp.Highlight.Enabled = false
                end
            end
        end
    else
        -- Clean ESP Cache
        for p, obs in pairs(ESP_Cache) do
            obs.Box.Visible = false
            obs.Highlight.Enabled = false
        end
    end
end)

-- // UI INTEGRATION // --
HRSetting:addTab("Combat")
HRSetting:addTab("Movements")
HRSetting:addTab("Visual")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "Range", 50, 800, "changeRange")
HRSetting:addSlider("Combat", "Smoothness", 1, 100, "changeSmooth")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Value", 16, 200, "changeSpeed")

HRSetting:addToggle("Visual", "ESP", "esp")

-- // HELPERS // --
function HRHelper:aimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    HRHelper.showToast("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"))
end
function HRHelper:changeRange(v) AimbotSettings.FOV = v end
function HRHelper:changeSmooth(v) AimbotSettings.Smoothness = v / 100 end

function HRHelper:speed()
    togSpeed = not togSpeed
    HRHelper.showToast("Speed: " .. (togSpeed and "ON" or "OFF"))
    if not togSpeed and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
end
function HRHelper:changeSpeed(v) speedConfig.value = v end

function HRHelper:esp()
    togEsp = not togEsp
    HRHelper.showToast("ESP: " .. (togEsp and "ON" or "OFF"))
end
