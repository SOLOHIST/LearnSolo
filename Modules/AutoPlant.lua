local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HELPER: FIND THE PLAYER'S FARM
local function getMyFarm()
    local farmFolder = workspace:FindFirstChild("Farm")
    if farmFolder then
        for _, farm in pairs(farmFolder:GetChildren()) do
            local ownerValue = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data") and
                farm.Important.Data:FindFirstChild("Owner")
            if ownerValue and (ownerValue.Value == LocalPlayer.Name or tostring(ownerValue.Value) == tostring(LocalPlayer.UserId)) then
                return farm
            end
        end
    end
    return nil
end

-- HELPER: FIND AVAILABLE 'CAN_PLANT' SPOT
local function getTargetSpot(mode)
    local farm = getMyFarm()
    if not farm then return nil end
    local plantLocations = farm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    local availableSpots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        if spot.Name == "Can_Plant" and #spot:GetChildren() == 0 then
            table.insert(availableSpots, spot)
        end
    end

    if #availableSpots == 0 then return nil end

    if mode == "Good Position" then
        return availableSpots[1]                               -- Returns the first empty spot in order
    elseif mode == "Random" then
        return availableSpots[math.random(1, #availableSpots)] -- Picks random empty spot
    elseif mode == "Player Position" then
        local nearest = nil
        local dist = math.huge
        for _, spot in pairs(availableSpots) do
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - spot.Position).Magnitude
            if d < dist then
                dist = d
                nearest = spot
            end
        end
        return nearest
    end
end

-- MAIN AUTOMATION LOOP
task.spawn(function()
    local seedIndex = 1
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true)

    while task.wait() do
        if _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local spot = getTargetSpot(_G.PlantSettings.Mode)
            local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]

            if spot and seedName and seedName ~= "NONE" then
                -- 1. Equip Tool
                local tool = LocalPlayer.Backpack:FindFirstChild(seedName)
                if tool then LocalPlayer.Character.Humanoid:EquipTool(tool) end

                -- 2. Plant
                if PlantRemote then
                    PlantRemote:FireServer(spot, seedName)
                end

                -- 3. Cycle Index
                seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            end
            task.wait(_G.PlantSettings.Delay)
        end
    end
end)
