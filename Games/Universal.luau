-- Games/Universal.luau
local GameModule = {}

function GameModule.Init(UICore)
    local Hub = UICore.BuildHub("Universal", "UniversalConfig")
    if not Hub then return end
    
    -- Variables to hold toggle and slider states
    local SpeedEnabled = false
    local TargetSpeed = 50
    
    local JumpEnabled = false
    local TargetJumpHeight = 50
    
    local FlyEnabled = false
    local TargetFlySpeed = 50
    
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Main Features Tab
    local MainTab = Hub.Window:CreateTab("Movement", 4483362458)
    
    -------------------------------------------------------
    -- SUPER SPEED SECTION
    -------------------------------------------------------
    MainTab:CreateToggle({
        Name = "Enable Super Speed",
        CurrentValue = false,
        Flag = "Toggle_Speed", 
        Callback = function(Value)
            SpeedEnabled = Value
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid :: any
                humanoid.WalkSpeed = SpeedEnabled and TargetSpeed or 16
            end
        end,
    })
    
    MainTab:CreateSlider({
        Name = "Speed Velocity",
        Min = 16,
        Max = 250,
        DefaultValue = 50,
        Color = Color3.fromRGB(0, 150, 255),
        Increment = 1,
        ValueName = "Studs/s",
        Flag = "Slider_Speed",
        Callback = function(Value)
            TargetSpeed = Value
            local character = LocalPlayer.Character
            if SpeedEnabled and character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid :: any
                humanoid.WalkSpeed = TargetSpeed
            end
        end,
    })
    
    -------------------------------------------------------
    -- SUPER JUMP SECTION
    -------------------------------------------------------
    MainTab:CreateToggle({
        Name = "Enable Super Jump",
        CurrentValue = false,
        Flag = "Toggle_Jump", 
        Callback = function(Value)
            JumpEnabled = Value
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid :: any
                -- Enable UseJumpPower if it isn't already
                humanoid.UseJumpPower = true
                humanoid.JumpPower = JumpEnabled and TargetJumpHeight or 50
            end
        end,
    })
    
    MainTab:CreateSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 300,
        DefaultValue = 100,
        Color = Color3.fromRGB(0, 255, 150),
        Increment = 1,
        ValueName = "Power",
        Flag = "Slider_Jump",
        Callback = function(Value)
            TargetJumpHeight = Value
            local character = LocalPlayer.Character
            if JumpEnabled and character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid :: any
                humanoid.JumpPower = TargetJumpHeight
            end
        end,
    })
    
    -------------------------------------------------------
    -- FLY SECTION
    -------------------------------------------------------
    local bodyVelocity: any = nil
    local flyConnection: RBXScriptConnection? = nil
    
    MainTab:CreateToggle({
        Name = "Enable Fly",
        CurrentValue = false,
        Flag = "Toggle_Fly", 
        Callback = function(Value)
            FlyEnabled = Value
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart
            
            if not rootPart then return end
            
            if FlyEnabled then
                -- Create body velocity physics object to handle movement
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = rootPart
                
                -- Loop connection to continuously change vector direction based on camera angle
                flyConnection = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    if not camera or not bodyVelocity or not rootPart then return end
                    
                    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
                    if not humanoid then return end
                    
                    local moveDirection = humanoid.MoveDirection
                    local camCFrame = camera.CFrame
                    
                    -- Calculate flight vector using camera coordinates relative to directional inputs
                    local flightVector = Vector3.new(0,0,0)
                    if moveDirection.Magnitude > 0 then
                        flightVector = (camCFrame.LookVector * moveDirection.Z) + (camCFrame.RightVector * moveDirection.X)
                        -- Project movement properly depending on forward/backward alignment
                        if moveDirection.Z > 0 then
                            flightVector = (camCFrame.LookVector * -moveDirection.Z) + (camCFrame.RightVector * moveDirection.X)
                        end
                    end
                    
                    bodyVelocity.Velocity = flightVector.Unit * TargetFlySpeed
                    
                    -- If completely static, counteract gravity perfectly so the player floats
                    if moveDirection.Magnitude == 0 then
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            else
                -- Clean up physics and rendering threads when disabled
                if flyConnection then flyConnection:Disconnect() end
                if bodyVelocity then bodyVelocity:Destroy() end
            end
        end,
    })
    
    MainTab:CreateSlider({
        Name = "Flight Speed",
        Min = 20,
        Max = 300,
        DefaultValue = 50,
        Color = Color3.fromRGB(255, 150, 0),
        Increment = 1,
        ValueName = "Speed",
        Flag = "Slider_Fly",
        Callback = function(Value)
            TargetFlySpeed = Value
        end,
    })
    
    -- Ensure hooks re-apply if your player resets/respawns
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        task.wait(0.5) -- Small delay to avoid loading sync race conditions
        
        if SpeedEnabled and char:FindFirstChild("Humanoid") then
            (char.Humanoid :: any).WalkSpeed = TargetSpeed
        end
        if JumpEnabled and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid :: any
            hum.UseJumpPower = true
            hum.JumpPower = TargetJumpHeight
        end
    end)
    
    Hub.Library:Notify({
        Title = "Zenith Hub Active",
        Content = "Movement enhancements injected successfully.",
        Duration = 3
    })
end

return GameModule