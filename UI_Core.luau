-- UI_Core.luau
local UICore = {}

function UICore.BuildHub(hubTitle, configName)
    local rayfieldSource = (game :: any):HttpGet('https://sirius.menu/rayfield')
    local loaderFunction = loadstring(rayfieldSource)
    
    if type(loaderFunction) ~= "function" then
        warn("Failed to load Rayfield UI library.")
        return nil
    end
    
    local Rayfield = loaderFunction()
    
    local Window = Rayfield:CreateWindow({
        Name = "Zenith Hub | " .. hubTitle,
        LoadingTitle = "Assembling Zenith...",
        LoadingSubtitle = "by Sam",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ZenithHub_Configs",
            FileName = configName or "DefaultConfig"
        },
        KeySystem = false
    })
    
    return {
        Library = Rayfield,
        Window = Window
    }
end

return UICore