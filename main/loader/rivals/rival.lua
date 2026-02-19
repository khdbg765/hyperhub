local HRSetting = _G.HRSetting
local HRHelper = _G.HRHelper
local HRSet = HRSetting:onLoad()

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // STATES // --
local aimbotEnabled = false
local togSpeed = false
local togEsp = false

-- // SETTINGS // --
local AimbotSettings = {
    FOV = 150,
    Smoothness = 0.5,
    Prediction = 0.05,
    Part = "Head",
    TeamCheck = true
}
local speedConfig = { value = 16 }

-- // VISUAL FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

--- // LOGIKA TARGETING TAKA1337 // ---
local function GetClosestTarget()
    local closest = nil
    local shortestDistance = AimbotSettings.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
            if targetPart then
                -- Prediksi murni gaya Taka
                local pos = targetPart.Position
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    pos = pos + (player.Character.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
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

--- // MAIN LOOP // ---
RS.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    -- Aimbot Logic Taka Style
    if aimbotEnabled then
        local targetPoint = GetClosestTarget()
        if targetPoint then
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local delta = (Vector2.new(targetPoint.X, targetPoint.Y) - mousePos)
            -- mousemoverel murni tanpa hambatan
            mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
        end
    end

    -- Speed & ESP
    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedConfig.value
    end
end)

--- // UI MENU (HRSetting) // ---
HRSetting:addTab("Combat")
HRSetting:addTab("Movements")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "Range", 50, 800, "changeRange")
HRSetting:addSlider("Combat", "Smoothness", 1, 100, "changeSmooth")
HRSetting:addSlider("Combat", "Prediction", 1, 100, "changePred")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Speed Val", 16, 200, "changeSpeed")

--- // HELPERS // ---
function HRHelper:aimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    HRHelper.showToast("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"))
end

function HRHelper:changeRange(v) AimbotSettings.FOV = v end
function HRHelper:changeSmooth(v) AimbotSettings.Smoothness = v / 100 end
function HRHelper:changePred(v) AimbotSettings.Prediction = v / 1000 end

function HRHelper:speed()
    togSpeed = not togSpeed
    HRHelper.showToast("Speed: " .. (togSpeed and "ON" or "OFF"))
    if not togSpeed and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
end
function HRHelper:changeSpeed(v) speedConfig.value = v end
