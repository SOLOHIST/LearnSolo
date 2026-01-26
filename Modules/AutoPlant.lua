local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HELPER: FIND YOUR FARM (Verified from your Console Screenshot)
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        -- Path: Farm -> Important -> Data -> Owner
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and (owner.Value == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end
    return nil
end

-- HELPER: FIND AN EMPTY PLOT (The dirt strips in your photo)
local function getAvailablePlot(mode)
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    local spots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        -- Logic: A spot is empty if it has no children (no plant growing on it)
        if spot.Name == "Can_Plant" and #spot:GetChildren() == 0 then
            table.insert(spots, spot)
        end
    end

    if #spots == 0 then return nil end

    -- Position Modes
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

-- MAIN AUTOMATION LOOP
task.spawn(function()
    local seedIndex = 1
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Grow a Garden typically uses one of these names for the Remote
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true)

    while task.wait() do
        -- Only run if Toggle is ON and Seeds are Selected
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]

            -- 1. SEARCH BACKPACK FOR THE SEED
            local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)

            if tool then
                -- 2. EQUIP TOOL (Must be holding it to plant)
                if tool.Parent == LocalPlayer.Backpack then
                    LocalPlayer.Character.Humanoid:EquipTool(tool)
                    task.wait(0.2) -- Delay to ensure tool is equipped
                end

                -- 3. FIND THE PLOT STRIP
                local targetPlot = getAvailablePlot(_G.PlantSettings.Mode)

                if targetPlot then
                    -- 4. FIRE THE REMOTE
                    if PlantRemote then
                        -- Arg1: The Plot Strip (Object), Arg2: The Seed Name (String)
                        PlantRemote:FireServer(targetPlot, seedName)
                    end
                end
            end

            -- Cycle to next seed in multi-select
            seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            task.wait(_G.PlantSettings.Delay)
        end
    end
end)
