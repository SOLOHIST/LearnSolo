local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. FIX THE REMOTE (Specific to Grow a Garden)
-- The game usually uses a remote named "Plant" or "PlantSeed"
local function getPlantRemote()
    -- Common paths for this specific game
    local paths = {
        ReplicatedStorage:FindFirstChild("Plant", true),
        ReplicatedStorage:FindFirstChild("PlantSeed", true),
        ReplicatedStorage:FindFirstChild("RequestPlant", true)
    }
    for _, remote in pairs(paths) do
        if remote and remote:IsA("RemoteEvent") then return remote end
    end
    return nil
end

-- 2. FIND YOUR FARM
local function getMyFarm()
    local farms = workspace:FindFirstChild("Farms") or workspace:FindFirstChild("Plots")
    if not farms then return nil end

    for _, farm in pairs(farms:GetChildren()) do
        -- Check for owner (Game usually uses a StringValue or Attribute)
        local owner = farm:FindFirstChild("Owner") or farm:GetAttribute("Owner")
        if tostring(owner) == LocalPlayer.Name then
            return farm
        end
    end
    return nil
end

-- 3. CHECK IF PLOT IS EMPTY
local function isPlotEmpty(plot)
    -- Most versions of this game have a "Planted" or "Occupied" value
    if plot:FindFirstChild("Plant") or plot:FindFirstChild("Occupied") then
        return false
    end
    -- Fallback to your distance check if no values found
    return #plot:GetChildren() == 0
end

-- 4. THE MAIN ACTION
local function performPlantAction()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local remote = getPlantRemote()
    local myFarm = getMyFarm()
    if not remote or not myFarm then return end

    -- Find an empty plot
    local targetPlot = nil
    local locations = myFarm:FindFirstChild("PlantLocations") or myFarm:FindFirstChild("Plots")
    if not locations then return end

    for _, spot in pairs(locations:GetChildren()) do
        if isPlotEmpty(spot) then
            targetPlot = spot
            break
        end
    end

    if not targetPlot then return end

    -- EQUIP THE SEED AUTOMATICALLY
    -- This looks through your inventory for the seeds you selected in the UI
    local seedToUse = nil
    for _, seedName in pairs(_G.PlantSettings.SelectedSeeds) do
        local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)
        if tool then
            seedToUse = tool
            break
        end
    end

    if seedToUse then
        -- Ensure tool is equipped
        if seedToUse.Parent == LocalPlayer.Backpack then
            seedToUse.Parent = LocalPlayer.Character
        end

        -- FIRE THE REMOTE
        -- Argument 1: The Plot, Argument 2: The Seed Name
        remote:FireServer(targetPlot, seedToUse.Name)
    end
end

-- 5. LOOP
task.spawn(function()
    while true do
        task.wait(_G.PlantSettings.Delay or 0.5)
        if _G.PlantSettings.Enabled then
            pcall(performPlantAction)
        end
    end
end)
