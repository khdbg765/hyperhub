local HRSetting = HRSetting or _G.HRSetting
local HRHelper = HRHelper or _G.HRHelper

--Rivals

if game.GameId ~= 17625359962 then return end
HRSetting:addTab("Movements")
HRSetting:addTab("Combat")
HRSetting:addTab("Visual")

HRSetting:addToggle("Movements", "Speed", "speed")
HRSetting:addSlider("Movements", "Speed Slider", 35, 145, "changeSpeed")
HRSetting:addToggle("Movements", "InfiniteJump", "infJump")
HRSetting:addToggle("Movements", "Fly", "fly")
--HRSetting:addToggle("Movements", "", "")

HRSetting:addToggle("Combat", "Aimbot", "aimbot")
HRSetting:addSlider("Combat", "changeAimbotRange", 50, 200, "changeAimbotRange")
HRSetting:addToggle("Combat", "Speed Of Aimbot", "", false)
HRSetting:addCheckbox("Combat", {
    {"Fast", "fast"},
    {"Normal", "Normal"},
    {"Slow",  "slow"}
}, "Fast")
HRSetting:addToggle("Combat", "SilentAim", "silentAim")

HRSetting:addToggle("Visual", "Esp", "esp")
HRSetting:addToggle("Visual", "SetEspType", "", false)
HRSetting:addCheckbox("Visual", {
    {"EspName", "nameesp"},
    {"EspBody", "bodyesp"},
    {"EspAll",  "allesp"}
}, "EspAll")
