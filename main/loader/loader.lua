local gameid = game.GameId
local domains = nil
local list = {
  [17625359962] = "rivals/rival.lua", --rivals
}

for id, domain in pairs(list) do
    if domain and gameid == id then
        domains = domain
        break
    end
end

if domains then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/khdbg765/hyperhub/refs/heads/main/main/loader/gui/main.lua"))()

    if HRSetting or _G.HRSetting then
       local format = string.format("https://raw.githubusercontent.com/khdbg765/hyperhub/refs/heads/main/main/loader/%s", domains)
       loadstring(game:HttpGet(format))()
    end
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/khdbg765/hyperhub/refs/heads/main/main/loader/gui/main.lua"))()
    if _G.HRHelper or HRHelper then
        HRHelper.showToast("Game Not Supported")
    end
end
