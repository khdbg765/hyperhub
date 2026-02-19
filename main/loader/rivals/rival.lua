local HRSetting = _G.HRSetting
local HRHelper = _G.HRHelper

-- Load Library & Get ScreenUI
local HRSet = HRSetting:onLoad()
local ParentUI = HRSet.ScreenUI -- Ini parent yang lo maksud

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
    Smoothness = 0.5,
    Part = "Head",
    Prediction = 0.05,
    UseMouse = true,
    SilentChance = 100
}
local speedConfig = { value = 16 }

-- // VISUAL FOV (DRAWING API) // --
-- Drawing API biasanya global, tapi kalau lo mau dia sinkron sama ScreenUI:
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

--- // CORE TARGETING (TAKA STYLE) // ---
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
        
        local partPos = targetPart.Position
        if player.Character:FindFirstChild("HumanoidRootPart") then
            partPos = partPos + (player.Character.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
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
    -- FOV Position Adjustment
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togAimbot then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
            local screenPoint = Camera:WorldToScreenPoint(targetPos)
            if screenPoint.Z > 0 then
                local delta = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y))
                mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
            end
        end
    end

    if togSilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if math.random(1, 100) <= AimbotSettings.SilentChance then
            local target = GetClosestTarget()
            if target then
                local targetPos = target.Position + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
                 Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    end

    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedConfig.value
    end

    -- ESP Logic (Tetap Sama)
    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character then continue end
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and char.Humanoid.Health > 0 then
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Highlight = Instance.new("Highlight")}
                end
                local esp = ESP_Cache[player]
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
                    local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                    esp.Box.Visible, esp.Box.Size, esp.Box.Position, esp.Box.Color = true, Vector2.new(sizeX, sizeY), Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2), color
                    esp.Name.Visible, esp.Name.Text, esp.Name.Position, esp.Name.Color = true, player.Name, Vector2.new(pos.X, pos.Y - sizeY / 2 - 15), color
                    esp.Highlight.Enabled, esp.Highlight.Adornee, esp.Highlight.Parent = true, char, ParentUI
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

--- // UI MENU (Pake HRSetting Langsung) // ---
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Speed Slider", 16, 200, "changeSpeed")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addToggle("Combat", "Aimbot Use Mouse", "usemouse")
HRSetting:addSlider("Combat", "Aimbot Range", 50, 800, "changeAimbotRange")
HRSetting:addSlider("Combat", "Aimbot Smoothness", 0.01, 1, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Aimbot Prediction", 0.001, 0.1, "changeAimbotPrediction")
HRSetting:addToggle("Combat", "SilentAim", "silentAim")
HRSetting:addSlider("Combat", "Silent Aim Chances", 1, 100, "changeSilentChance")

HRSetting:addToggle("Visual", "Esp", "esp")

--- // HELPER FUNCTIONS // ---
function HRHelper:speed()
    togSpeed = not togSpeed
    if togSpeed then HRHelper.showToast("Speed : Enabled") else HRHelper.showToast("Speed : Disabled") 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end

function HRHelper:changeSpeed(val) speedConfig.value = val end

function HRHelper:aimbot()
    togAimbot = not togAimbot
    FOVCircle.Visible = togAimbot
    if togAimbot then HRHelper.showToast("Aimbot : Enabled") else HRHelper.showToast("Aimbot : Disabled") end
end

function HRHelper:usemouse()
    AimbotSettings.UseMouse = not AimbotSettings.UseMouse
    if AimbotSettings.UseMouse then HRHelper.showToast("Mode : Mouse Move") else HRHelper.showToast("Mode : Camera Lock") end
end

function HRHelper:changeAimbotRange(val) AimbotSettings.FOV = val end
function HRHelper:changeAimbotSmoothness(val) AimbotSettings.Smoothness = val end
function HRHelper:changeAimbotPrediction(val) AimbotSettings.Prediction = val end
function HRHelper:silentAim()
    togSilentAim = not togSilentAim
    if togSilentAim then HRHelper.showToast("Silent Aim : Enabled") else HRHelper.showToast("Silent Aim : Disabled") end
end
function HRHelper:changeSilentChance(val) AimbotSettings.SilentChance = val end
function HRHelper:esp()
    togEsp = not togEsp
    if togEsp then HRHelper.showToast("Esp : Enabled") else HRHelper.showToast("Esp : Disabled") end
end
