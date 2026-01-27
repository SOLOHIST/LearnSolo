local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- HELPER: FIND YOUR FARM
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and (tostring(owner.Value) == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end
    return nil
end

-- HELPER: FIND THE DIRT STRIP
local function getAvailablePlot()
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    for _, spot in pairs(plantLocations:GetChildren()) do
        -- If no models (plants) are inside, it's empty
        if spot.Name == "Can_Plant" and not spot:FindFirstChildWhichIsA("Model") then
            return spot
        end
    end
    return nil
end

-- MAIN AUTOMATION LOOP
task.spawn(function()
    local seedIndex = 1
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true)

    while task.wait(0.1) do
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local selectedName = _G.PlantSettings.SelectedSeeds[seedIndex]

            -- FIX: Look for tool that CONTAINS the name (handles the [X43] part)
            local tool = nil
            local searchPlace = LocalPlayer.Backpack:GetChildren()
            table.insert(searchPlace, LocalPlayer.Character:FindFirstChildWhichIsA("Tool"))

            for _, item in pairs(searchPlace) do
                if item and item:IsA("Tool") and item.Name:find(selectedName) then
                    tool = item
                    break
                end
            end

            if tool then
                -- Equip if in backpack
                if tool.Parent == LocalPlayer.Backpack then
                    LocalPlayer.Character.Humanoid:EquipTool(tool)
                    task.wait(0.3)
                end

                local targetPlot = getAvailablePlot()
                if targetPlot and PlantRemote then
                    -- ACTION
                    print("[LearnSolo] Planting " .. tool.Name .. " on " .. targetPlot.Name)
                    PlantRemote:FireServer(targetPlot, selectedName)

                    -- Cycle to next seed
                    seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
                    task.wait(_G.PlantSettings.Delay)
                end
            else
                -- If we don't have this seed, skip it
                seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            end
        end
    end
end)
