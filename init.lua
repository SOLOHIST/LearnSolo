-- init.lua

-- 1. SETUP GLOBALS
_G.PlantSettings = {
    Enabled = false,
    SelectedSeeds = "Carrot Seed", -- Default seed
    Mode = "Good Position",        -- Default position
    Delay = 0.3,
}
_G.FarmSettings = {
    AutoHarvest = false,
    AutoSell = false,
    SellThreshold = 15,
    AutoBuy = false,
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MINE HUB | GROW A GARDEN",
    LoadingTitle = "MINE HUB",
    LoadingSubtitle = "Advanced Edition",
    ConfigurationSaving = { Enabled = true, FolderName = "MineHubConfigs", FileName = "GardenConfig" },
    KeySystem = false,
})

-- 2. LOAD LOGIC
-- Make sure your AutoPlant.lua (below) is hosted or placed correctly
loadstring(game:HttpGet("https://raw.githubusercontent.com/SOLOHIST/LearnSolo/main/Modules/AutoPlant.lua"))()

-- 3. TABS
local AutoTab = Window:CreateTab("Automation", "play")

AutoTab:CreateSection("Planting Configuration")

-- Seed Selection
AutoTab:CreateDropdown({
    Name = "Select Seed",
    Options = { "Carrot Seed", "Strawberry Seed", "Tomato Seed", "Watermelon Seed", "Pumpkin Seed", "Blueberry Seed" },
    CurrentOption = { "Carrot Seed" },
    MultipleOptions = false,
    Callback = function(Option)
        _G.PlantSettings.SelectedSeeds = Option[1]
    end,
})

-- Position Selection
AutoTab:CreateDropdown({
    Name = "Select Position",
    Options = { "Good Position", "Random", "Player Position" },
    CurrentOption = { "Good Position" },
    MultipleOptions = false,
    Callback = function(Option)
        _G.PlantSettings.Mode = Option[1]
    end,
})

-- The Master Toggle
AutoTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(Value)
        _G.PlantSettings.Enabled = Value
    end,
})

AutoTab:CreateSection("Other Settings")
AutoTab:CreateToggle({
    Name = "Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoBuy = Value end,
})

AutoTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoHarvest = Value end,
})
