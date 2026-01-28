local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. THE REVEALED REMOTE
local PlantRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE")

-- 2. FIND YOUR FARM (Based on detector: workspace.Workspace.PlayerName)
local function getMyFarm()
    -- The detector showed your farm path is: workspace.Workspace.redroom277
    local workspaceFolder = workspace:FindFirstChild("Workspace") or workspace
    local farm = workspaceFolder:FindFirstChild(LocalPlayer.Name)

    if farm and farm:FindFirstChild("Important") then
        return farm
    else
        -- Fallback: search all models for an owner value
        for _, v in pairs(workspaceFolder:GetChildren()) do
            if v:FindFirstChild("Important") and (v.Name == LocalPlayer.Name or (v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer.Name)) then
                return v
            end
        end
    end
    return nil
end

-- 3. CHECK IF PLOT IS EMPTY
local function isPlotEmpty(farm, plotPosition)
    local plantsPhysical = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then return true end

    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- Check if a plant model is already at this position
        if (plant:GetPivot().Position - plotPosition).Magnitude < 1.5 then
            return false
        end
    end
    return true
end

-- 4. CLEAN SEED NAME (Turns "Carrot Seed [X19]" into "Carrot")
local function getCleanName(fullName)
    local name = fullName:split(" Seed")[1] -- Removes everything after the crop name
    return name
end

-- 5. THE MAIN ACTION
local function performPlantAction()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local myFarm = getMyFarm()
    if not myFarm then return end

    -- Find the Seed in inventory
    local seedTool = nil
    for _, selectedName in pairs(_G.PlantSettings.SelectedSeeds) do
        -- Search backpack for a tool that starts with the selected name
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool.Name:find(selectedName) then
                seedTool = tool
                break
            end
        end
        if seedTool then break end
    end

    if not seedTool then return end

    -- Find an empty plot
    local plantLocations = myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then return end

    for _, spot in pairs(plantLocations:GetChildren()) do
        if spot.Name == "Can_Plant" and isPlotEmpty(myFarm, spot.Position) then
            local cleanCropName = getCleanName(seedTool.Name)

            -- FIRE SERVER (Vector3, String)
            PlantRemote:FireServer(spot.Position, cleanCropName)

            return true -- Success
        end
    end
end

-- 6. CONTINUOUS LOOP
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

print("[MINE HUB] Auto-Plant Active: Using Position-Vector Mode.")
