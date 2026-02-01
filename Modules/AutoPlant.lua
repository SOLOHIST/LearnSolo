-- AutoPlant.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

-- Helper: Find player's farm
local function GetMyFarm()
    local farm = workspace.Farm:FindFirstChild(LocalPlayer.Name)
    if farm and farm:FindFirstChild("Important") then
        return farm
    end
    return nil
end

-- Helper: Get coordinates of the dirt patch
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

local function performPlanting()
    local farm = GetMyFarm()
    if not farm then return end

    -- 1. Identify Seed Tool
    local seedName = _G.PlantSettings.SelectedSeeds
    local seedTool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)

    if not seedTool then return end

    -- 2. Equip if not equipped
    if seedTool.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(seedTool)
    end

    -- Clean the name for the Remote (e.g., "Carrot Seed" -> "Carrot")
    local remoteSeedName = seedTool.Name:gsub(" Seed", ""):split(" [")[1]

    local dirt = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
    local area = GetArea(dirt)
    local mode = _G.PlantSettings.Mode

    if mode == "Good Position" then
        -- Fill the whole farm in a clean grid
        for x = area.x1, area.x2, 4 do
            for z = area.z1, area.z2, 4 do
                -- Stop if the user toggles off mid-process
                if not _G.PlantSettings.Enabled or _G.PlantSettings.Mode ~= "Good Position" then return end

                GameEvents.Plant_RE:FireServer(Vector3.new(x, area.y, z), remoteSeedName)
                task.wait(_G.PlantSettings.Delay)
            end
        end
    elseif mode == "Random" then
        -- Pick a random spot inside the farm bounds
        local rx = math.random(area.x1, area.x2)
        local rz = math.random(area.z1, area.z2)
        GameEvents.Plant_RE:FireServer(Vector3.new(rx, area.y, rz), remoteSeedName)
        task.wait(_G.PlantSettings.Delay)
    elseif mode == "Player Position" then
        -- Plant exactly where the player is standing
        local pPos = LocalPlayer.Character.HumanoidRootPart.Position
        GameEvents.Plant_RE:FireServer(Vector3.new(pPos.X, area.y, pPos.Z), remoteSeedName)
        task.wait(_G.PlantSettings.Delay)
    end
end

-- THE MAIN LOOP
task.spawn(function()
    while true do
        task.wait(0.1) -- Fast check
        if _G.PlantSettings.Enabled then
            -- Wrap in pcall to prevent the whole script from breaking on error
            pcall(performPlanting)
        end
    end
end)
