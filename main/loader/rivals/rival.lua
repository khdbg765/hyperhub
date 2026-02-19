local HRSetting = HRSetting or _G.HRSetting
local HRHelper = HRHelper or _G.HRHelper
local HRSet = HRSetting:onLoad()

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local togAimbot = false
local togEsp = false
local togSpeed = false
local ESP_Cache = {}

local AimbotSettings = {
    TeamCheck = true,
    WallCheck = true,
    FOV = 120,
    Smoothness = 0.2,
    Part = "Head",
    Prediction = 0.01,
    UseMouse = true
}

local espConfig = {
    espTarget = "EspAll"
}

local speedConfig = {
    value = 16
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

local function IsVisible(part, character)
    return #Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, character}) == 0
end

local function GetClosestTarget()
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        local hum = player.Character:FindFirstChild("Humanoid")
        local part = player.Character:FindFirstChild(AimbotSettings.Part)
        if hum and hum.Health > 0 and part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                if AimbotSettings.WallCheck and not IsVisible(part, player.Character) then continue end
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = part
                end
            end
        end
    end
    return closest
end

RS.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togAimbot then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
            if AimbotSettings.UseMouse then
                local screenPoint = Camera:WorldToScreenPoint(targetPos)
                if screenPoint.Z > 0 then
                    local delta = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)) * AimbotSettings.Smoothness
                    mousemoverel(delta.X, delta.Y)
                end
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), AimbotSettings.Smoothness)
            end
        end
    end

    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedConfig.value
    elseif not togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end

    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Highlight = Instance.new("Highlight")
                    }
                end
                local esp = ESP_Cache[player]
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
                    local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                    
                    local showName = (espConfig.espTarget == "EspName" or espConfig.espTarget == "EspAll")
                    local showBody = (espConfig.espTarget == "EspBody" or espConfig.espTarget == "EspAll")

                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(sizeX, sizeY)
                    esp.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    esp.Box.Color = color
                    esp.Name.Visible = showName
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 15)
                    esp.Name.Outline = true
                    esp.Name.Center = true
                    esp.Name.Color = color
                    esp.Highlight.Enabled = showBody
                    esp.Highlight.Adornee = char
                    esp.Highlight.FillColor = color
                    esp.Highlight.Parent = char
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Highlight.Enabled = false
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

HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Movements", "Speed", "speed", true)
HRSetting:addSlider("Movements", "Speed Slider", 35, 145, "changeSpeed")
HRSetting:addToggle("Movements", "InfiniteJump", "infJump", true)
HRSetting:addToggle("Movements", "Fly", "fly", true)

HRSetting:addToggle("Combat", "Aimbot", "aimbot", true)
HRSetting:addToggle("Combat", "Aimbot Use Mouse", "usemouse", true)
HRSetting:addSlider("Combat", "Aimbot Range", 50, 500, "changeAimbotRange")
HRSetting:addSlider("Combat", "Aimbot Smoothness", 0.01, 1, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Aimbot Prediction", 0.001, 0.05, "changeAimbotPrediction")
HRSetting:addToggle("Combat", "SilentAim", "silentAim", true)

HRSetting:addToggle("Visual", "Esp", "esp", true)
HRSetting:addToggle("Visual", "SetEspType", "", false)
HRSetting:addCheckbox("Visual", {
    {"EspName", "nameesp"},
    {"EspBody", "bodyesp"},
    {"EspAll",  "allesp"}
}, "EspAll")

function HRHelper:aimbot()
    togAimbot = not togAimbot
    FOVCircle.Visible = togAimbot
    if togAimbot then 
        HRHelper.showToast("Aimbot : Enabled") 
    else 
        HRHelper.showToast("Aimbot : Disabled") 
    end
end

function HRHelper:usemouse()
    AimbotSettings.UseMouse = not AimbotSettings.UseMouse
    if AimbotSettings.UseMouse then 
        HRHelper.showToast("Mode : Mouse Move") 
    else 
        HRHelper.showToast("Mode : Camera Lock") 
    end
end

function HRHelper:esp()
    togEsp = not togEsp
    if togEsp then 
        HRHelper.showToast("Visual : Enabled") 
    else 
        HRHelper.showToast("Visual : Disabled") 
    end
end

function HRHelper:speed()
    togSpeed = not togSpeed
    if togSpeed then 
        HRHelper.showToast("Speed : Enabled") 
    else 
        HRHelper.showToast("Speed : Disabled") 
    end
end

function HRHelper:changeAimbotRange(val) 
    AimbotSettings.FOV = val
end

function HRHelper:changeAimbotSmoothness(val) 
    AimbotSettings.Smoothness = val 
end

function HRHelper:changeAimbotPrediction(val) 
    AimbotSettings.Prediction = val 
end

function HRHelper:changeSpeed(val) 
    speedConfig.value = val 
end

function HRHelper:nameesp() 
    espConfig.espTarget = "EspName" 
end

function HRHelper:bodyesp() 
    espConfig.espTarget = "EspBody" 
end

function HRHelper:allesp() 
    espConfig.espTarget = "EspAll" 
end
