local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Mine Hub] Logic starting for Grow a Garden...")

-- 1. FIND YOUR FARM
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            local owner = data and data:FindFirstChild("Owner")

            -- Checks if name matches or UserId matches
            if owner and (tostring(owner.Value) == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
                return farmModel
            end
        end
    end
    return nil
end

-- 2. CHECK IF A PLOT IS EMPTY
-- In this game, plants are in 'Plants_Physical', not inside the 'Can_Plant' part.
local function isPlotEmpty(farm, plotPart)
    local plantsPhysical = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then return true end

    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- Check if a plant is sitting at the same position as the plot
        if (plant:GetPivot().Position - plotPart.Position).Magnitude < 2 then
            return false -- Someone is already growing here
        end
    end
    return true
end

-- 3. GET NEXT AVAILABLE PLOT
local function getAvailablePlot()
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return nil end

    for _, spot in pairs(plantLocations:GetChildren()) do
        if spot.Name == "Can_Plant" and isPlotEmpty(myFarm, spot) then
            return spot
        end
    end
    return nil
end

-- 4. MAIN LOOP
task.spawn(function()
    local seedIndex = 1

    -- Find the remote (It is usually in ReplicatedStorage)
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true) or
        ReplicatedStorage:FindFirstChild("Plant", true)

    while task.wait(0.1) do
        if _G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0 then
            local selectedName = _G.PlantSettings.SelectedSeeds[seedIndex]

            -- Find tool in Backpack or Character
            local tool = nil
            local search = LocalPlayer.Backpack:GetChildren()
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do table.insert(search, v) end

            for _, item in pairs(search) do
                if item:IsA("Tool") and item.Name:find(selectedName) then
                    tool = item
                    break
                end
            end

            if tool then
                -- Equip tool if not held
                if tool.Parent == LocalPlayer.Backpack then
                    LocalPlayer.Character.Humanoid:EquipTool(tool)
                    task.wait(0.2)
                end

                local targetPlot = getAvailablePlot()
                if targetPlot and PlantRemote then
                    -- The Remote call for this game:
                    -- Argument 1: The Plot Part (Can_Plant)
                    -- Argument 2: The Seed Name
                    PlantRemote:FireServer(targetPlot, selectedName)

                    print("[Mine Hub] Successfully planted: " .. selectedName)

                    seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
                    task.wait(_G.PlantSettings.Delay or 0.5)
                end
            else
                -- Skip seed if you don't have it
                seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            end
        end
    end
end)
