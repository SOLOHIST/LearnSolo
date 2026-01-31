local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

--// FIND FARM (Checks workspace.Farm as per Depso's script)
local function GetMyFarm()
    local farmFolder = workspace:FindFirstChild("Farm") or workspace:FindFirstChild("Workspace")
    for _, farm in pairs(farmFolder:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            local owner = data and data:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer.Name then
                return farm
            end
        end
    end
    return nil
end

--// AREA MATH (From Example)
local function GetArea(Base)
    local Center = Base.Position
    local Size = Base.Size
    local X1 = math.ceil(Center.X - (Size.X / 2))
    local Z1 = math.ceil(Center.Z - (Size.Z / 2))
    local X2 = math.floor(Center.X + (Size.X / 2))
    local Z2 = math.floor(Center.Z + (Size.Z / 2))
    return X1, Z1, X2, Z2
end

--// AUTO SELL (Teleport logic from Example)
local IsSelling = false
local function SellInventory()
    if IsSelling then return end
    IsSelling = true
    local char = LocalPlayer.Character
    local prevPos = char:GetPivot()

    char:PivotTo(CFrame.new(62, 4, -26)) -- Shop Location
    task.wait(0.5)
    GameEvents.Sell_Inventory:FireServer()
    task.wait(0.5)
    char:PivotTo(prevPos)
    IsSelling = false
end

--// MAIN HARVEST & WALK LOGIC
task.spawn(function()
    while task.wait(0.5) do
        local farm = GetMyFarm()
        if not farm or not _G.FarmSettings.AutoHarvest then continue end

        local plants = farm.Important.Plants_Physical:GetChildren()
        for _, plant in pairs(plants) do
            local prompt = plant:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                -- Auto Walk Logic
                if _G.FarmSettings.AutoWalk and not IsSelling then
                    LocalPlayer.Character.Humanoid:MoveTo(plant:GetPivot().Position)
                end

                -- Fast Harvest
                fireproximityprompt(prompt)
            end
        end
    end
end)

--// AUTO BUY & PLANT LOGIC
task.spawn(function()
    while task.wait(1) do
        if _G.FarmSettings.AutoBuy and _G.PlantSettings.SelectedSeeds[1] then
            GameEvents.BuySeedStock:FireServer(_G.PlantSettings.SelectedSeeds[1])
        end

        if _G.PlantSettings.Enabled and _G.PlantSettings.SelectedSeeds[1] then
            local farm = GetMyFarm()
            local dirt = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
            local x1, z1, x2, z2 = GetArea(dirt)
            local seedName = _G.PlantSettings.SelectedSeeds[1]:gsub(" Seed", "")

            -- Grid Planting
            for x = x1, x2, 4 do
                for z = z1, z2, 4 do
                    GameEvents.Plant_RE:FireServer(Vector3.new(x, dirt.Position.Y + 0.5, z), seedName)
                    task.wait(_G.PlantSettings.Delay)
                end
            end
        end
    end
end)

--// SELL CHECK
LocalPlayer.Backpack.ChildAdded:Connect(function()
    local crops = 0
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:FindFirstChild("Item_String") then crops = crops + 1 end
    end
    if crops >= _G.FarmSettings.SellThreshold and _G.FarmSettings.AutoSell then
        SellInventory()
    end
end)

--// NOCLIP & SPEED
game:GetService("RunService").Stepped:Connect(function()
    if _G.FarmSettings.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.PlayerSettings.WalkSpeed
    end
end)
