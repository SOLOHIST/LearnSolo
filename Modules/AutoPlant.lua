local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ====== HELPERS ======
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then
        return nil
    end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and (owner.Value == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end
    return nil
end

local function getAvailablePlot(mode)
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm:FindFirstChild("Important") and myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then
        return nil
    end

    local spots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        -- Improved check: Ensure it's a planting spot and doesn't have a plant model inside
        if spot.Name == "Can_Plant" and not spot:FindFirstChildWhichIsA("Model") then
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
                dist = d
                nearest = s
            end
        end
        return nearest
    else
        return spots[1] -- Good Position
    end
end

-- ====== AUTO-PLANT LOOP ======
task.spawn(function()
    local seedIndex = 1

    -- Try to find Plant Remote
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true)

    if PlantRemote then
        print("[LearnSolo Debug] Plant remote found: " .. PlantRemote.Name)
    end

    while task.wait(0.1) do -- Faster check loop
        -- Only run if the UI has Enabled the toggle
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]

            -- Check Backpack & Character for seed
            local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)

            if tool then
                -- Equip tool if not equipped
                if tool.Parent == LocalPlayer.Backpack then
                    LocalPlayer.Character.Humanoid:EquipTool(tool)
                    task.wait(0.2) -- allow time to equip
                end

                -- Find target plot
                local targetPlot = getAvailablePlot(_G.PlantSettings.Mode)

                if targetPlot and PlantRemote then
                    PlantRemote:FireServer(targetPlot, seedName)
                    -- Cycle to next seed only AFTER a successful attempt
                    seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
                    task.wait(_G.PlantSettings.Delay or 0.5)
                end
            else
                -- If we don't have the seed, skip to the next one in the list
                seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            end
        end
    end
end)
