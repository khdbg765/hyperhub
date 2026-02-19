local HRSetting = HRSetting or _G.HRSetting
local HRHelper = HRHelper or _G.HRHelper
local HRSet = HRSetting:onLoad()

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local togAimbot = false
local togSilentAim = false
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
    UseMouse = true,
    SilentChance = 100
}

local espConfig = { espTarget = "EspAll" }
local speedConfig = { value = 16 }

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = false

--- // FUNGSI TARGETING (FIXED) // ---

local function GetClosestTarget()
    local CurrentCam = workspace.CurrentCamera -- Selalu ambil yang terbaru
    local closest, shortestDistance = nil, AimbotSettings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local part = player.Character:FindFirstChild(AimbotSettings.Part)
        
        if hum and hum.Health > 0 and part then
            local screenPos, onScreen = CurrentCam:WorldToViewportPoint(part.Position)
            if onScreen then
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

--- // LOOP UTAMA // ---

RS.RenderStepped:Connect(function()
    local CurrentCamera = workspace.CurrentCamera
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOV
    
    if togAimbot then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
            if AimbotSettings.UseMouse then
                local screenPoint = CurrentCamera:WorldToScreenPoint(targetPos)
                if screenPoint.Z > 0 then
                    local delta = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)) * AimbotSettings.Smoothness
                    mousemoverel(delta.X, delta.Y)
                end
            else
                CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(CFrame.new(CurrentCamera.CFrame.Position, targetPos), AimbotSettings.Smoothness)
            end
        end
    end

    if togSilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local chance = math.random(1, 100)
        if chance <= AimbotSettings.SilentChance then
            local target = GetClosestTarget()
            if target then
                local targetPos = target.Position + (target.Parent.HumanoidRootPart.Velocity * AimbotSettings.Prediction)
                CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, targetPos)
            end
        end
    end

    if togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedConfig.value
    elseif not togSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end

    if togEsp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                if not ESP_Cache[player] then
                    ESP_Cache[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Highlight = Instance.new("Highlight")
                    }
                end
                local esp = ESP_Cache[player]
                local pos, onScreen = CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onScreen then
                    local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
                    local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                    esp.Box.Visible, esp.Box.Size, esp.Box.Position, esp.Box.Color = true, Vector2.new(sizeX, sizeY), Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2), color
                    esp.Name.Visible, esp.Name.Text, esp.Name.Position, esp.Name.Color = true, player.Name, Vector2.new(pos.X, pos.Y - sizeY / 2 - 15), color
                    esp.Highlight.Enabled, esp.Highlight.Adornee, esp.Highlight.FillColor, esp.Highlight.Parent = true, char, color, char
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
HRSetting:addSlider("Movements", "Speed Slider", 35, 145, "changeSpeed")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addToggle("Combat", "Aimbot Use Mouse", "usemouse")
HRSetting:addSlider("Combat", "Aimbot Range", 50, 500, "changeAimbotRange")
HRSetting:addSlider("Combat", "Aimbot Smoothness", 0.01, 1, "changeAimbotSmoothness")
HRSetting:addSlider("Combat", "Aimbot Prediction", 0.001, 0.05, "changeAimbotPrediction")
HRSetting:addToggle("Combat", "SilentAim", "silentAim")
HRSetting:addSlider("Combat", "Silent Aim Chances", 1, 100, "changeSilentChance")

HRSetting:addToggle("Visual", "Esp", "esp")
HRSetting:addToggle("Visual", "SetEspType", "", true)
HRSetting:addCheckbox("Visual", {{"EspName", "nameesp"}, {"EspBody", "bodyesp"}, {"EspAll", "allesp"}}, "EspAll")

--- // HELPER FUNCTIONS // ---

function HRHelper:speed()
    togSpeed = not togSpeed
    if togSpeed then 
        HRHelper.showToast("Speed : Enabled") 
    else 
        HRHelper.showToast("Speed : Disabled") 
    end
end

function HRHelper:changeSpeed(val)
    speedConfig.value = val
end

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

function HRHelper:changeAimbotRange(val) 
    AimbotSettings.FOV = val
end

function HRHelper:changeAimbotSmoothness(val)
    AimbotSettings.Smoothness = val
end

function HRHelper:changeAimbotPrediction(val)
    AimbotSettings.Prediction = val
end

function HRHelper:silentAim()
    togSilentAim = not togSilentAim
    if togSilentAim then 
        HRHelper.showToast("Silent Aim : Enabled") 
    else 
        HRHelper.showToast("Silent Aim : Disabled") 
    end
end

function HRHelper:changeSilentChance(val)
    AimbotSettings.SilentChance = val
end

function HRHelper:esp()
    togEsp = not togEsp
    if togEsp then 
        HRHelper.showToast("Esp : Enabled") 
    else 
        HRHelper.showToast("Esp : Disabled") 
    end
end

function HRHelper:nameesp() espConfig.espTarget = "EspName" end
function HRHelper:bodyesp() espConfig.espTarget = "EspBody" end
function HRHelper:allesp() espConfig.espTarget = "EspAll" end
