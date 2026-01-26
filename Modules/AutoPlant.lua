local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ====== HELPERS ======
local function getMyFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then
        print("[DEBUG] Farm container not found in workspace.")
        return nil
    end

    for _, farmModel in pairs(farmContainer:GetChildren()) do
        local important = farmModel:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and (owner.Value == LocalPlayer.Name or tostring(owner.Value) == tostring(LocalPlayer.UserId)) then
            return farmModel
        end
    end

    print("[DEBUG] No farm owned by player found.")
    return nil
end

local function getAvailablePlot(mode)
    local myFarm = getMyFarm()
    if not myFarm then return nil end

    local plantLocations = myFarm:FindFirstChild("Important") and myFarm.Important:FindFirstChild("Plant_Locations")
    if not plantLocations then
        print("[DEBUG] Plant_Locations not found in farm.")
        return nil
    end

    local spots = {}
    for _, spot in pairs(plantLocations:GetChildren()) do
        if spot.Name == "Can_Plant" and #spot:GetChildren() == 0 then
            table.insert(spots, spot)
        end
    end

    if #spots == 0 then
        print("[DEBUG] No empty plots available.")
        return nil
    end

    if mode == "Random" then
        return spots[math.random(1, #spots)]
    elseif mode == "Player Position" then
        local nearest = nil
        local dist = math.huge
        for _, s in pairs(spots) do
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - s.Position).Magnitude
            if d < dist then
                dist = d; nearest = s
            end
        end
        return nearest
    else
        return spots[1]
    end
end

-- ====== MAIN LOOP ======
task.spawn(function()
    local seedIndex = 1

    -- Attempt to find Plant Remote
    local PlantRemote = ReplicatedStorage:FindFirstChild("PlantSeed", true) or
        ReplicatedStorage:FindFirstChild("Plant", true) or
        ReplicatedStorage:FindFirstChild("RequestPlant", true)

    if not PlantRemote then
        print("[DEBUG] Plant remote not found in ReplicatedStorage.")
        return
    else
        print("[DEBUG] Plant remote found:", PlantRemote:GetFullName())
    end

    while task.wait(0.5) do
        -- Check if planting is enabled
        if not (_G.PlantSettings and _G.PlantSettings.Enabled and #_G.PlantSettings.SelectedSeeds > 0) then
            print("[DEBUG] Planting is disabled or no seeds selected.")
            task.wait(1)
            continue
        end

        local seedName = _G.PlantSettings.SelectedSeeds[seedIndex]
        print("[DEBUG] Attempting to plant seed:", seedName)

        local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)
        if not tool then
            print("[DEBUG] Seed tool not found in Backpack or Character:", seedName)
            seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
            continue
        end

        if tool.Parent == LocalPlayer.Backpack then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            print("[DEBUG] Equipped seed tool:", seedName)
            task.wait(0.5) -- Give time to equip
        end

        local targetPlot = getAvailablePlot(_G.PlantSettings.Mode)
        if not targetPlot then
            print("[DEBUG] No valid plot found to plant.")
            task.wait(1)
            continue
        end

        print("[DEBUG] Planting at plot:", targetPlot.Name)
        PlantRemote:FireServer(targetPlot, seedName)

        -- Cycle to next seed
        seedIndex = (seedIndex % #_G.PlantSettings.SelectedSeeds) + 1
        task.wait(_G.PlantSettings.Delay or 1)
    end
end)
