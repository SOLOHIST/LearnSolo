local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

-- 1. HELPERS & FINDERS
local function getMyFarm()
    -- Look in workspace.Farm (as seen in the high-end script) or fallback to workspace.Workspace
    local farmFolder = workspace:FindFirstChild("Farm") or workspace:FindFirstChild("Workspace")
    if not farmFolder then return nil end

    for _, farm in pairs(farmFolder:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important then
            local owner = important:FindFirstChild("Data") and important.Data:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer.Name then
                return farm
            end
        end
    end
    return nil
end

local function getFarmArea(basePart)
    local center = basePart.Position
    local size = basePart.Size
    return {
        x1 = math.ceil(center.X - (size.X / 2)),
        z1 = math.ceil(center.Z - (size.Z / 2)),
        x2 = math.floor(center.X + (size.X / 2)),
        z2 = math.floor(center.Z + (size.Z / 2))
    }
end

-- 2. AUTO-PLANT LOGIC (Grid Based)
local function performPlanting()
    local farm = getMyFarm()
    if not farm or not _G.PlantSettings.Enabled then return end

    -- Find Seed Tool
    local seedTool = nil
    for _, selectedName in pairs(_G.PlantSettings.SelectedSeeds) do
        seedTool = LocalPlayer.Backpack:FindFirstChild(selectedName) or
            LocalPlayer.Character:FindFirstChild(selectedName)
        if seedTool then break end
    end
    if not seedTool then return end

    -- Get Dirt Area
    local dirt = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
    if not dirt then return end
    local area = getFarmArea(dirt)

    -- Equip Tool
    if seedTool.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(seedTool)
    end

    local cleanName = seedTool.Name:split(" Seed")[1]

    -- Grid Planting (Logic from depthso)
    for x = area.x1, area.x2, 4 do -- Step of 4 to avoid over-stacking
        for z = area.z1, area.z2, 4 do
            if not _G.PlantSettings.Enabled then break end

            -- Fire Remote
            GameEvents.Plant_RE:FireServer(Vector3.new(x, dirt.Position.Y + 0.5, z), cleanName)
            task.wait(_G.PlantSettings.Delay or 0.1)
        end
    end
end

-- 3. AUTO-HARVEST LOGIC (Prompt Based)
local function performHarvest()
    local farm = getMyFarm()
    if not farm or not _G.FarmSettings.AutoHarvest then return end

    local plants = farm.Important:FindFirstChild("Plants_Physical")
    if not plants then return end

    for _, plant in pairs(plants:GetChildren()) do
        local prompt = plant:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and prompt.Enabled then
            -- Use fireproximityprompt if executor supports it
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                -- Fallback: Teleport to prompt and interact
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
            end
        end
    end
end

-- 4. AUTO-SELL LOGIC
local function performSell()
    if not _G.FarmSettings.AutoSell then return end

    -- Most "Grow a Garden" versions use this remote
    GameEvents.Sell_Inventory:FireServer()
end

-- 5. AUTO-COLLECT (Money/Gems)
local function performCollect()
    if not _G.FarmSettings.AutoCollect then return end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Coin" or obj.Name == "Gem" or obj.Name == "Sheckle" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (obj.Position - hrp.Position).Magnitude < 50 then
                obj.CFrame = hrp.CFrame -- Bring money to player
            end
        end
    end
end

-- 6. CHARACTER MODS (NoClip)
RunService.Stepped:Connect(function()
    if _G.FarmSettings and _G.FarmSettings.AutoHarvest then -- Noclip while harvesting
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 7. MAIN CONTROL LOOPS
task.spawn(function()
    while true do
        task.wait(1) -- Heavy check every 1s
        if _G.PlantSettings.Enabled then
            pcall(performPlanting)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3) -- Fast check for harvesting
        if _G.FarmSettings.AutoHarvest then
            pcall(performHarvest)
        end
        if _G.FarmSettings.AutoSell then
            pcall(performSell)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1) -- Ultra fast for money collection
        if _G.FarmSettings.AutoCollect then
            pcall(performCollect)
        end
    end
end)

print("[MINE HUB] Advanced Logic Loaded: Grid-Planting & Prompt-Harvesting active.")
