local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

-- 1. DYNAMIC REMOTES (Handles different game versions)
local PlantRemote = GameEvents:FindFirstChild("Plant_RE")
local HarvestRemote = GameEvents:FindFirstChild("Harvest_RE")
local SellRemote = GameEvents:FindFirstChild("Sell_Inventory") or GameEvents:FindFirstChild("Sell_RE")

-- 2. SMART FARM FINDER
local function getMyFarm()
    -- Check common locations: workspace.Farm or workspace.Workspace
    local locations = { workspace:FindFirstChild("Farm"), workspace:FindFirstChild("Workspace"), workspace }

    for _, loc in pairs(locations) do
        if loc then
            local farm = loc:FindFirstChild(LocalPlayer.Name)
            if farm and farm:FindFirstChild("Important") then
                return farm
            end
        end
    end
    return nil
end

-- 3. PROXIMITY HARVEST (The most reliable way)
local function firePrompt(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.Enabled then
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            -- Manual fallback for low-end executors
            task.spawn(function()
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.1)
                prompt:InputHoldEnd()
            end)
        end
        return true
    end
    return false
end

-- 4. AUTO-PLANTING
local function doPlant()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local farm = getMyFarm()
    if not farm then return end

    -- Find the seed tool
    local seedTool = nil
    for _, selected in pairs(_G.PlantSettings.SelectedSeeds) do
        seedTool = LocalPlayer.Backpack:FindFirstChild(selected) or LocalPlayer.Character:FindFirstChild(selected)
        if seedTool then break end
    end

    if not seedTool then return end

    -- Ensure tool is equipped
    if seedTool.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(seedTool)
    end

    -- Clean the name (e.g., "Carrot Seed" -> "Carrot")
    local cleanName = seedTool.Name:gsub(" Seed", ""):gsub(" %[%d+%%]", ""):split(" [")[1]

    -- Find spots to plant
    local locations = farm.Important:FindFirstChild("Plant_Locations")
    if locations then
        for _, spot in pairs(locations:GetChildren()) do
            -- Check if spot is empty (no plant within 1.5 studs)
            local isOccupied = false
            for _, p in pairs(farm.Important.Plants_Physical:GetChildren()) do
                if (p:GetPivot().Position - spot.Position).Magnitude < 2 then
                    isOccupied = true
                    break
                end
            end

            if not isOccupied then
                PlantRemote:FireServer(spot.Position, cleanName)
                task.wait(_G.PlantSettings.Delay or 0.2)
            end
        end
    end
end

-- 5. AUTO-HARVEST
local function doHarvest()
    if not _G.FarmSettings or not _G.FarmSettings.AutoHarvest then return end

    local farm = getMyFarm()
    if not farm then return end

    local plants = farm.Important:FindFirstChild("Plants_Physical")
    if plants then
        for _, plant in pairs(plants:GetChildren()) do
            -- Look for prompts inside the plant or its fruits
            firePrompt(plant)
            local fruits = plant:FindFirstChild("Fruits")
            if fruits then
                for _, fruit in pairs(fruits:GetChildren()) do
                    firePrompt(fruit)
                end
            end
        end
    end
end

-- 6. MAIN LOOPS
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(doHarvest)

        if _G.FarmSettings and _G.FarmSettings.AutoSell then
            pcall(function() SellRemote:FireServer() end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if _G.PlantSettings and _G.PlantSettings.Enabled then
            pcall(doPlant)
        end
    end
end)

-- 7. AUTO-COLLECT SHECKLES (Logic from depthso script)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.FarmSettings and _G.FarmSettings.AutoCollect then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Coin" or obj.Name == "Gem" or obj.Name == "Sheckle" then
                        obj.CFrame = hrp.CFrame
                    end
                end
            end
        end
    end
end)

print("[MINE HUB] Logic Loaded Successfully.")
