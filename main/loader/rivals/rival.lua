local HRSetting = _G.HRSetting
local HRHelper = _G.HRHelper
local HRSet = HRSetting:onLoad()
local ParentUI = HRSet.ScreenUI
local GuiService = game:GetService("GuiService")

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
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Visible = false

--- // TARGETING LOGIC // ---
local function GetClosestTarget()
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(AimbotSettings.Part)
        if targetPart then
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if distance < shortestDistance then
                    closest = targetPart
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

--- // AIMBOT EXECUTION (THE FIX) // ---
local function StartAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RS.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        local target = GetClosestTarget()
        if target then
            local predictionOffset = Vector3.new(0,0,0)
            if target.Parent:FindFirstChild("HumanoidRootPart") then
                predictionOffset = target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position + predictionOffset)
            if onScreen then
                local inset = GuiService:GetGuiInset()
                local mousePos = UIS:GetMouseLocation()
                local targetPoint = Vector2.new(screenPos.X, screenPos.Y)
                
                -- Kalkulasi Delta murni
                local delta = (targetPoint - mousePos)
                mousemoverel(delta.X * AimbotSettings.Smoothness, delta.Y * AimbotSettings.Smoothness)
            end
        end
    end)
end

--- // LOOP UTAMA (ESP & SPEED) // ---
RS.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togSpeed and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedConfig.value
    end

    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {Box = Drawing.new("Square"), Highlight = Instance.new("Highlight", ParentUI)}
                end
                local esp = ESP_Cache[player]
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X/2, pos.Y - esp.Box.Size.Y/2)
                    esp.Box.Color = Color3.new(1,0,0)
                    esp.Highlight.Enabled, esp.Highlight.Adornee = true, player.Character
                else
                    esp.Box.Visible, esp.Highlight.Enabled = false, false
                end
            end
        end
    end
end)

--- // UI & HELPERS // ---
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "Range", 50, 800, "changeAimbotRange")
HRSetting:addSlider("Combat", "Smoothness", 1, 100, "changeAimbotSmoothness")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Value", 16, 200, "changeSpeed")

HRSetting:addToggle("Visual", "Esp", "esp")

function HRHelper:aimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    HRHelper.showToast("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"))
    if aimbotEnabled then StartAimbot() else if aimbotConnection then aimbotConnection:Disconnect() end end
end

function HRHelper:changeAimbotSmoothness(val) AimbotSettings.Smoothness = val / 100 end
function HRHelper:changeAimbotRange(val) AimbotSettings.FOV = val end
function HRHelper:speed() togSpeed = not togSpeed end
function HRHelper:changeSpeed(val) speedConfig.value = val end
function HRHelper:esp() togEsp = not togEsp end
HRHelper.showToast("Rivals Script Loaded")
