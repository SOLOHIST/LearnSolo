local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. Create the Window FIRST
local Window = Rayfield:CreateWindow({
    Name = "LearnSolo Hub | Grow a Garden",
    LoadingTitle = "Loading...",
    ConfigurationSaving = { Enabled = true, FolderName = "LearnSoloConfigs", FileName = "PlantConfig" },
    KeySystem = false,
})

-- 2. Create the Global Settings
_G.PlantSettings = {
    Enabled = false,
    SelectedSeeds = {},
    Mode = "Good Position",
    Delay = 0.5
}

-- 3. NOW load the logic from GitHub
loadstring(game:HttpGet("https://raw.githubusercontent.com/SOLOHIST/LearnSolo/main/Modules/AutoPlant.lua"))()

-- 4. Create the Tab
local AutoTab = Window:CreateTab("Automatically", "play")
-- ... (rest of your dropdown/toggle code)
