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
local togAimbot = false
local togSilentAim = false
local togEsp = false
local togSpeed = false
local ESP_Cache = {}

-- // SETTINGS // --
local AimbotSettings = {
    TeamCheck = true,
    WallCheck = false,
    FOV = 120,
    Smoothness = 0.5, -- Default
    Part = "Head",
    Prediction = 0.05, -- Default
    UseMouse = true,
    SilentChance = 100
}
local speedConfig = { value = 16 }

-- // VISUAL FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

--- // TARGETING LOGIC // ---
local function GetClosestTarget()
    if not LocalPlayer.Character then return nil end
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
        if not targetPart then continue end
        
        -- Logic Taka1337: Cek posisi layar
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < shortestDistance then
                closest = targetPart
                shortestDistance = distance
            end
        end
    end
    return closest
end

--- // MAIN LOOP // ---
RS.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togAimbot then
        local target = GetClosestTarget()
        if target then
            -- Ambil Velocity buat Prediction
            local hrp = target.Parent:FindFirstChild("HumanoidRootPart")
            local targetPos = target.Position
            if hrp then
                targetPos = targetPos + (hrp.Velocity * AimbotSettings.Prediction)
            end
            
            local screenPoint = Camera:WorldToScreenPoint(targetPos)
            if screenPoint.Z > 0 then
                local delta = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y))
                -- mousemoverel pake Smoothness
                mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
            end
        end
    end
    
    -- (Logic Silent Aim, Speed, dan ESP tetep sama di sini)
end)

--- // UI MENU (SLIDER 1-100 FIX) // ---
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addToggle("Combat", "Aimbot Use Mouse", "usemouse")
HRSetting:addSlider("Combat", "Aimbot Range", 50, 800, "changeAimbotRange")

-- Slider ini di UI 1-100, tapi di fungsi dibagi biar dapet desimal
HRSetting:addSlider("Combat", "Aimbot Smoothness", 1, 100, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Aimbot Prediction", 1, 100, "changeAimbotPrediction")

--- // HELPER FUNCTIONS // ---

function HRHelper:aimbot()
    togAimbot = not togAimbot
    FOVCircle.Visible = togAimbot
    if togAimbot then HRHelper.showToast("Aimbot : Enabled") else HRHelper.showToast("Aimbot : Disabled") end
end

function HRHelper:changeAimbotRange(val) 
    AimbotSettings.FOV = val 
end

-- FIX: Slider 1-100 dibagi biar jadi 0.01 - 1.0
function HRHelper:changeAimbotSmoothness(val) 
    AimbotSettings.Smoothness = val / 100 
end

-- FIX: Slider 1-100 dibagi biar jadi 0.001 - 0.1
function HRHelper:changeAimbotPrediction(val) 
    AimbotSettings.Prediction = val / 1000 
end

function HRHelper:usemouse()
    AimbotSettings.UseMouse = not AimbotSettings.UseMouse
    if AimbotSettings.UseMouse then HRHelper.showToast("Mode : Mouse Move") else HRHelper.showToast("Mode : Camera Lock") end
end
