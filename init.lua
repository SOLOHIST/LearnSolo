-- init.lua

-- 1. SETUP GLOBALS
_G.PlantSettings = {
    Enabled = false,
    SelectedSeeds = {},
    Mode = "Good Position", -- Default Position Mode
    Delay = 0.3,
}
_G.FarmSettings = {
    AutoHarvest = false,
    AutoSell = false,
    SellThreshold = 15,
    AutoBuy = false,
    AutoWalk = false,
    NoClip = false
}
_G.PlayerSettings = {
    WalkSpeed = 16
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MINE HUB | GROW A GARDEN",
    LoadingTitle = "MINE HUB",
    LoadingSubtitle = "Advanced Edition",
    ConfigurationSaving = { Enabled = true, FolderName = "MineHubConfigs", FileName = "GardenConfig" },
    KeySystem = false,
})

-- 2. LOAD LOGIC FROM GITHUB
-- Note: If you are testing locally, ensure the logic below is updated in your AutoPlant.lua file
loadstring(game:HttpGet("https://raw.githubusercontent.com/SOLOHIST/LearnSolo/main/Modules/AutoPlant.lua"))()

-- 3. TABS
local MainTab = Window:CreateTab("Main", "user")
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = { 16, 100 },
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value) _G.PlayerSettings.WalkSpeed = Value end,
})

local AutoTab = Window:CreateTab("Automation", "play")

AutoTab:CreateSection("Planting & Buying")

AutoTab:CreateDropdown({
    Name = "Select Seed",
    Options = { "Carrot Seed", "Strawberry Seed", "Tomato Seed", "Watermelon Seed", "Pumpkin Seed", "Blueberry Seed" },
    CurrentOption = { "Carrot Seed" },
    MultipleOptions = false,
    Callback = function(Option) _G.PlantSettings.SelectedSeeds = Option end,
})

-- NEW: POSITION MODE DROPDOWN
AutoTab:CreateDropdown({
    Name = "Select Position",
    Options = { "Good Position", "Random", "Player Position" },
    CurrentOption = { "Good Position" },
    MultipleOptions = false,
    Callback = function(Option)
        _G.PlantSettings.Mode = Option[1]
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(Value) _G.PlantSettings.Enabled = Value end,
})

AutoTab:CreateToggle({
    Name = "Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoBuy = Value end,
})

AutoTab:CreateSection("Harvesting & Selling")
AutoTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoHarvest = Value end,
})

AutoTab:CreateToggle({
    Name = "Auto Walk to Plants",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoWalk = Value end,
})

AutoTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.AutoSell = Value end,
})

AutoTab:CreateSlider({
    Name = "Sell at X Crops",
    Range = { 1, 100 },
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) _G.FarmSettings.SellThreshold = Value end,
})

AutoTab:CreateToggle({
    Name = "Noclip (Use with Auto-Walk)",
    CurrentValue = false,
    Callback = function(Value) _G.FarmSettings.NoClip = Value end,
})

Rayfield:LoadConfiguration()
