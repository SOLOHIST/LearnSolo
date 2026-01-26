local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HELPER: FIND YOUR FARM
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        -- Navigate the exact path from your console screenshot:
        -- Farm (Folder) -> Important -> Data -> Owner
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and (owner.Value == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end
    return nil
end

-- HELPER: FIND THE DIRT STRIP
local function getAvailablePlot(mode)
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    local spots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        -- Verified Name from your Console: Can_Plant
        if spot.Name == "Can_Plant" and #spot:GetChildren() == 0 then
            table.insert(spots, spot)
        end
    end

    if #spots == 0 then return nil end

    if mode == "Random" then
        return spots[math.random(1, #spots)]
    elseif mode == "Player Position" then
        local nearest = nil
        local dist = math.huge
        for _, s in pairs(spots) do
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - s.Position).Magnitude
            if d < dist then
                dist = d; nearest = s
            end
        end
        return nearest
    else
        return spots[1] -- "Good Position"
    end
end

-- MAIN LOOP
task.spawn(function()
    local seedIndex = 1
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- We need to verify this name with SimpleSpy!
    local PlantRemote = ReplicatedStorage:FindFirstChild("Plant_Seed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true)

    while task.wait() do
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]
            local targetPlot = getAvailablePlot(_G.PlantSettings.Mode)

            if targetPlot and seedName and seedName ~= "NONE" then
                -- Inventory Check
                local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or
                    LocalPlayer.Character:FindFirstChild(seedName)

                if tool then
                    if tool.Parent == LocalPlayer.Backpack then
                        LocalPlayer.Character.Humanoid:EquipTool(tool)
                        task.wait(0.1)
                    end

                    -- FIRE REMOTE
                    if PlantRemote then
                        -- !! This line might need changing based on your SimpleSpy result !!
                        PlantRemote:FireServer(targetPlot, seedName)
                    end
                end
            end

            seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            task.wait(_G.PlantSettings.Delay)
        end
    end
end)
