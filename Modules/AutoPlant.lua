local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Mine Hub] Logic Updated: Planting held seed only.")

-- 1. FIND YOUR FARM
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            local owner = data and data:FindFirstChild("Owner")

            if owner and (tostring(owner.Value) == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
                return farmModel
            end
        end
    end
    return nil
end

-- 2. CHECK IF A PLOT IS EMPTY
local function isPlotEmpty(farm, plotPart)
    local plantsPhysical = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then return true end

    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- If a plant model is within 3 studs of the dirt, it's full
        if (plant:GetPivot().Position - plotPart.Position).Magnitude < 3 then
            return false
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
    -- Find the remote (Ensures we get the RemoteEvent, not the ModuleScript)
    local function getRemote()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name == "PlantSeed" or v.Name == "RequestPlant") then
                return v
            end
        end
        return nil
    end

    local PlantRemote = getRemote()

    while task.wait(0.1) do
        -- Only run if the Toggle is ON in your UI
        if _G.PlantSettings and _G.PlantSettings.Enabled then
            -- CHECK WHAT YOU ARE HOLDING IN YOUR HAND
            local char = LocalPlayer.Character
            local heldTool = char and char:FindFirstChildWhichIsA("Tool")

            if heldTool then
                local targetPlot = getAvailablePlot()

                if targetPlot and PlantRemote then
                    -- CLEAN NAME: Removes "[x50]" suffix so the server accepts the name
                    local cleanName = heldTool.Name:split(" [")[1]

                    -- FIRE THE REMOTE
                    PlantRemote:FireServer(targetPlot, cleanName)

                    print("[Mine Hub] Planted held seed: " .. cleanName)

                    -- Wait the delay set in your UI before trying the next plot
                    task.wait(_G.PlantSettings.Delay or 0.5)
                end
            end
        end
    end
end)
