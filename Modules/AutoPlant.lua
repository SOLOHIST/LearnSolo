local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[MINE HUB] Logic Loaded. Checking for Remotes...")

-- 1. IMPROVED REMOTE FINDER
local function getPlantRemote()
    -- These are the most common locations in Grow a Garden
    local possiblePaths = {
        ReplicatedStorage:FindFirstChild("Plant", true),
        ReplicatedStorage:FindFirstChild("PlantSeed", true),
        ReplicatedStorage:FindFirstChild("Communication") and ReplicatedStorage.Communication:FindFirstChild("Events") and
        ReplicatedStorage.Communication.Events:FindFirstChild("Plant")
    }

    for _, remote in pairs(possiblePaths) do
        if remote and remote:IsA("RemoteEvent") then
            print("[MINE HUB] Found Remote: " .. remote:GetFullName())
            return remote
        end
    end
    warn("[MINE HUB] Could not find Plant Remote!")
    return nil
end

-- 2. IMPROVED FARM FINDER
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm") or workspace:FindFirstChild("Farms")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            local owner = (data and data:FindFirstChild("Owner")) or farmModel:FindFirstChild("Owner")

            if owner and (tostring(owner.Value) == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
                return farmModel
            end
        end
    end
    return nil
end

-- 3. USE THE "Plants_Physical" INFO FROM YOUR SCREENSHOT
local function isPlotEmpty(farm, plotPart)
    local plantsPhysical = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then return true end

    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- If a model (like your Carrot) is within 2.5 studs of the plot, it's occupied
        if plant:IsA("Model") and (plant:GetPivot().Position - plotPart.Position).Magnitude < 2.5 then
            return false
        end
    end
    return true
end

-- 4. THE PLANTING ACTION
local function performPlantAction()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local myFarm = getMyFarm()
    local remote = getPlantRemote()
    if not myFarm or not remote then return end

    -- 4a. Find a Seed in your inventory (so you don't have to hold it)
    local seedTool = nil
    for _, seedName in pairs(_G.PlantSettings.SelectedSeeds) do
        seedTool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)
        if seedTool then break end
    end

    if not seedTool then
        -- Optimization: If not holding it, don't spam the console
        return
    end

    -- 4b. Find an empty plot
    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return end

    for _, spot in pairs(plantLocations:GetChildren()) do
        if spot.Name == "Can_Plant" and isPlotEmpty(myFarm, spot) then
            -- Clean the name for the remote
            local cleanName = seedTool.Name:split(" [")[1]

            -- Equip tool if it's in backpack
            if seedTool.Parent == LocalPlayer.Backpack then
                seedTool.Parent = LocalPlayer.Character
            end

            -- FIRE ACTION
            remote:FireServer(spot, cleanName)
            print("[MINE HUB] Planted: " .. cleanName)
            return true
        end
    end
end

-- 5. LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.PlantSettings and _G.PlantSettings.Enabled then
            local success = performPlantAction()
            if success then
                task.wait(_G.PlantSettings.Delay or 0.5)
            end
        end
    end
end)
