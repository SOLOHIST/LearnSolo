local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

--// HELPERS
local function GetMyFarm()
    local locations = { workspace:FindFirstChild("Farm"), workspace:FindFirstChild("Workspace"), workspace }
    for _, loc in pairs(locations) do
        if loc then
            local farm = loc:FindFirstChild(LocalPlayer.Name)
            if farm and farm:FindFirstChild("Important") then return farm end
        end
    end
    return nil
end

local function GetArea(Base)
    local Center = Base.Position
    local Size = Base.Size
    return {
        x1 = math.ceil(Center.X - (Size.X / 2)),
        z1 = math.ceil(Center.Z - (Size.Z / 2)),
        x2 = math.floor(Center.X + (Size.X / 2)),
        z2 = math.floor(Center.Z + (Size.Z / 2)),
        y = Center.Y + 0.5
    }
end

--// MAIN PLANTING FUNCTION
local function performPlanting()
    if not _G.PlantSettings or not _G.PlantSettings.Enabled then return end

    local farm = GetMyFarm()
    if not farm then return end

    -- 1. Find the seed
    local seedTool = nil
    for _, selected in pairs(_G.PlantSettings.SelectedSeeds) do
        seedTool = LocalPlayer.Backpack:FindFirstChild(selected) or LocalPlayer.Character:FindFirstChild(selected)
        if seedTool then break end
    end
    if not seedTool then return end

    -- 2. Equip tool
    if seedTool.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(seedTool)
    end

    local cleanName = seedTool.Name:gsub(" Seed", ""):split(" [")[1]
    local dirt = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
    local area = GetArea(dirt)

    -- 3. HANDLE MODES
    local mode = _G.PlantSettings.Mode

    if mode == "Good Position" then
        -- GRID PLANTING (Perfect Rows)
        for x = area.x1, area.x2, 4 do
            for z = area.z1, area.z2, 4 do
                if not _G.PlantSettings.Enabled or _G.PlantSettings.Mode ~= "Good Position" then break end
                GameEvents.Plant_RE:FireServer(Vector3.new(x, area.y, z), cleanName)
                task.wait(_G.PlantSettings.Delay or 0.2)
            end
        end
    elseif mode == "Random" then
        -- RANDOM POSITIONS (Within farm bounds)
        local randomX = math.random(area.x1, area.x2)
        local randomZ = math.random(area.z1, area.z2)
        GameEvents.Plant_RE:FireServer(Vector3.new(randomX, area.y, randomZ), cleanName)
        task.wait(_G.PlantSettings.Delay or 0.2)
    elseif mode == "Player Position" then
        -- AT PLAYER FEET
        local pPos = LocalPlayer.Character.HumanoidRootPart.Position
        GameEvents.Plant_RE:FireServer(Vector3.new(pPos.X, area.y, pPos.Z), cleanName)
        task.wait(_G.PlantSettings.Delay or 0.2)
    end
end

--// LOOP FOR PLANTING
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.PlantSettings and _G.PlantSettings.Enabled then
            pcall(performPlanting)
        end
    end
end)

--// HARVESTING LOGIC (Using ProximityPrompts)
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.FarmSettings and _G.FarmSettings.AutoHarvest then
            local farm = GetMyFarm()
            if farm then
                for _, plant in pairs(farm.Important.Plants_Physical:GetChildren()) do
                    local prompt = plant:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end
end)

--// AUTO SELL & COLLECT
task.spawn(function()
    while true do
        task.wait(1)
        if _G.FarmSettings and _G.FarmSettings.AutoSell then
            local sellRemote = GameEvents:FindFirstChild("Sell_Inventory") or GameEvents:FindFirstChild("Sell_RE")
            if sellRemote then sellRemote:FireServer() end
        end
    end
end)
