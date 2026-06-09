local PlaceId = game.PlaceId
local BaseURL = "https://raw.githubusercontent.com/YourUsername/MyScriptHub/main/"

local function fetchScript(path)
    local success, result = pcall(function()
        local data = (game :: any):HttpGet(BaseURL .. path)
        return loadstring(data)
    end)
    if success and type(result) == "function" then
        return result()
    end
    return nil
end

local UICore = fetchScript("UI_Core.luau")
if not UICore then
    error("Critical Error: Failed to load UI Core framework.")
end

local gameModule = fetchScript("Games/" .. tostring(PlaceId) .. ".luau")

if not gameModule then
    warn("Game profile not found. Falling back to Universal...")
    gameModule = fetchScript("Games/Universal.luau")
end

if gameModule and type(gameModule.Init) == "function" then
    gameModule.Init(UICore)
else
    warn("Failed to initialize game modules.")
end