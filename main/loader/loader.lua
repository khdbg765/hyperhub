local g = game.GameId
local guiLink = "https://raw.githubusercontent.com/khdbg765/hyperhub/refs/heads/main/main/loader/gui/main.lua"

local tryCheck = function()
    local HRH = HRHelper or _G.HRHelper
    local HRS = HRSetting or _G.HRSetting
    if HRH and HRS then return true, HRS, HRH end
    return false, nil, nil
end

local hyper = {
    load = function(http)
        local link = game:HttpGet(http)
        return loadstring(link)()
    end,
    loadGUI = function()
        local link = game:HttpGet(guiLink)
        loadstring(link)()
    end,
    list = function()
        if g == 17625359962 then return "rivals/rival" end
        return nil
    end,
    fail = function()
        local re, set, help = tryCheck()
        if re then
            help.showToast("Game Not Supported")
            help.showToast("U Can Only Use Some Function")
        end
    end
}

hyper.loadGUI()
wait(1.5)
local res, set, help = tryCheck()
local github = "https://raw.githubusercontent.com/khdbg765/hyperhub/refs/heads/main/"

if res then
    local listRes = hyper.list()
    if not listRes then hyper.fail() return end
    local format = string.format("%smain/loader/%s.lua", github, listRes)
    hyper.load(format)
end
