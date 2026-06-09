local GameModule = {}

function GameModule.Init(UICore)
    local Hub = UICore.BuildHub("Universal", "UniversalConfig")
    if not Hub then return end
    
    local MainTab = Hub.Window:CreateTab("Main", 4483362458)
    
    MainTab:CreateToggle({
        Name = "Super Speed",
        CurrentValue = false,
        Flag = "Toggle_Speed", 
        Callback = function(Value)
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid :: any
                humanoid.WalkSpeed = Value and 50 or 16
            end
        end,
    })
    
    Hub.Library:Notify({
        Title = "Zenith Active",
        Content = "Universal profile loaded effortlessly.",
        Duration = 3
    })
end

return GameModule