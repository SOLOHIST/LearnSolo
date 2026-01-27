local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("[Mine Hub] Active Action: Planting Held Seed Mode")

-- 1. FIND YOUR FARM
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

-- 2. CHECK IF A PLOT IS EMPTY
local function isPlotEmpty(farm, plotPart)
    local plantsPhysical = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then return true end

    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- Check distance to ensure the plot isn't covered by a plant model
        if (plant:GetPivot().Position - plotPart.Position).Magnitude < 2.5 then
            return false
        end
    end
    return true
end

-- 3. FIND THE NEXT AVAILABLE PLOT
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

-- 4. FIND THE CORRECT REMOTE (Avoiding ModuleScripts)
local function getPlantRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name == "PlantSeed" or v.Name == "RequestPlant") then
            return v
        end
    end
    return nil
end

-- 5. THE PLANTING ACTION
local function performPlantAction()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local char = LocalPlayer.Character
    local heldTool = char and char:FindFirstChildWhichIsA("Tool")

    -- Check if the tool held is a seed (standard check)
    if heldTool and (heldTool.Name:lower():find("seed") or heldTool.Name:lower():find("shroom") or heldTool.Name:lower():find("potato")) then
        local targetPlot = getAvailablePlot()
        local remote = getPlantRemote()

        if targetPlot and remote then
            -- Clean the name (e.g., "Carrot Seed [x10]" -> "Carrot Seed")
            local cleanName = heldTool.Name:split(" [")[1]

            -- EXECUTE THE ACTION
            remote:FireServer(targetPlot, cleanName)
            return true
        end
    end
    return false
end

-- 6. CONTINUOUS BACKGROUND LOOP
task.spawn(function()
    while true do
        task.wait(0.1) -- Fast check
        if _G.PlantSettings and _G.PlantSettings.Enabled then
            local success = performPlantAction()
            if success then
                -- Wait the user's specific delay after a successful plant
                task.wait(_G.PlantSettings.Delay or 0.5)
            end
        end
    end
end)

-- 7. CLICK-TO-PLANT OVERRIDE
-- This makes the action feel responsive; if you click, it tries to plant immediately.
LocalPlayer.CharacterChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        child.Activated:Connect(function()
            if _G.PlantSettings and _G.PlantSettings.Enabled then
                performPlantAction()
            end
        end)
    end
end)
