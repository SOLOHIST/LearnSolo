local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HELPER: FIND YOUR FARM
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        -- Check if the farm belongs to you
        if owner and (owner.Value == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end
    return nil
end

-- HELPER: FIND EMPTY STRIPS (The strips in your photo)
local function getAvailablePlot(mode)
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    local spots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        -- 1. Must be named Can_Plant
        -- 2. Must be empty (no plant model inside it)
        -- 3. Must be "unlocked" (Transparency is usually 1 for unlocked, 0.5+ for locked)
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
    else                -- "Good Position"
        return spots[1] -- Plants in order from first plot to last
    end
end

-- MAIN LOOP
task.spawn(function()
    local seedIndex = 1
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- The game usually stores the planting event here
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true)

    while task.wait() do
        -- Check if UI settings exist and Toggle is ON
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]
            local targetPlot = getAvailablePlot(_G.PlantSettings.Mode)

            if targetPlot and seedName and seedName ~= "NONE" then
                -- CHECK INVENTORY FOR SEED
                local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or
                    LocalPlayer.Character:FindFirstChild(seedName)

                if tool then
                    -- Equip if in backpack
                    if tool.Parent == LocalPlayer.Backpack then
                        LocalPlayer.Character.Humanoid:EquipTool(tool)
                        task.wait(0.1)
                    end

                    -- FIRE REMOTE
                    -- Arg 1: The strip of dirt, Arg 2: The name of the seed
                    if PlantRemote then
                        PlantRemote:FireServer(targetPlot, seedName)
                    end
                end
            end

            -- Move to next seed in your multi-select list
            seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            task.wait(_G.PlantSettings.Delay)
        end
    end
end)
