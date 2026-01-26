-- 1. SETUP GLOBALS
_G.PlantSettings = {
    Enabled = false,
    SelectedSeeds = {},
    Mode = "Good Position",
    Delay = 0.5
}
_G.PlayerSettings = {
    WalkSpeed = 16
}

-- 2. GET UI LIBRARY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 3. CREATE WINDOW
local Window = Rayfield:CreateWindow({
    Name = "MINE HUB | GROW A GARDEN",
    LoadingTitle = "MINE HUB",
    LoadingSubtitle = "by LearnSolo",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LearnSoloConfigs",
        FileName = "PlantConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "YOUR_DISCORD_INVITE",
        RememberJoins = true
    },
    KeySystem = false,
})

-- 4. LOAD LOGIC FROM GITHUB
task.wait(0.5)
loadstring(game:HttpGet("https://raw.githubusercontent.com/SOLOHIST/LearnSolo/main/Modules/AutoPlant.lua"))()

-- 5. CREATE TABS

-- MAIN TAB (Local Player)
local MainTab = Window:CreateTab("Main", "user")
local PlayerSection = MainTab:CreateSection("Local Player")

local SpeedSlider = MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = { 16, 300 },
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        _G.PlayerSettings.WalkSpeed = Value
    end,
})

MainTab:CreateButton({
    Name = "Reset Speed",
    Info = "Sets your speed back to 16",
    Callback = function()
        _G.PlayerSettings.WalkSpeed = 16
        SpeedSlider:Set(16) -- This moves the slider handle back to 16
    end,
})

-- AUTOMATICALLY TAB (Planting)
local AutoTab = Window:CreateTab("Automatically", "play")
AutoTab:CreateSection("Automation Plants")

AutoTab:CreateDropdown({
    Name = "Select Seeds",
    Options = { "Carrot Seed", "Strawberry Seed", "Horned Redrose", "Blueberry Seed", "Buttercup Seed", "Orange Tulip", "Rose", "Autumn Shroom", "Orange Delight", "Banana Orchid", "Olive", "Gem Fruit", "Coinfruit", "Tomato Seed", "Corn Seed", "Daffodil Seed", "Cauliflower", "Foxglove", "Mandrake", "Fall Berry", "Banesberry", "Viburnum Berry", "Fissure Berry", "Pomegranate", "Watermelon Seed", "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Rafflesia", "Green Apple", "Avocado", "Banana", "Lilac", "Broccoli", "Speargrass", "Buddhas Hand", "Protea", "Coilvine", "Sherrybloom", "Coconut Seed", "Cactus Seed", "Dragon Fruit Seed", "Mango Seed", "Peach", "Pineapple", "Kiwi", "Bell Pepper", "Prickly Pear", "Pink Lily", "Purple Dahlia", "Potato", "Torchflare", "Auburn Pine", "Kniphofia", "Ghost Pepper", "Hollow Bamboo", "Wild Pineapple", "Grape Seed", "Mushroom Seed", "Pepper Seed", "Cacao Seed", "Sunflower Seed", "Loquat", "Feijoa", "Pitcher Plant", "Legacy Sunflower", "Brussels Sprout", "Firewell", "Baobab", "Thornspire", "Yarrow", "Asteris", "Pinkside Dandelion", "Beanstalk Seed", "Ember Lily Seed", "Sugar Apple Seed", "Burning Bud Seed", "Giant Pinecone Seed", "Elder Strawberry Seed", "Romanesco Seed", "Cocomango", "Wyrmvine", "Crimson Thorn Seed", "Zebrazinkle Seed", "Octobloom Seed", "Bamboo Tree", "Lumin Bloom", "Raspberry", "Horsetail", "Blue Raspberry" },
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SeedsDropdown",
    Callback = function(Options) _G.PlantSettings.SelectedSeeds = Options end,
})

AutoTab:CreateDropdown({
    Name = "Select Position",
    Options = { "Good Position", "Player Position", "Random" },
    CurrentOption = { "Good Position" },
    MultipleOptions = false,
    Flag = "PosModeDropdown",
    Callback = function(Option) _G.PlantSettings.Mode = Option[1] end,
})

AutoTab:CreateInput({
    Name = "Delay To Plants",
    PlaceholderText = "Default: 0.5",
    Callback = function(Text) _G.PlantSettings.Delay = tonumber(Text) or 0.5 end,
})

AutoTab:CreateToggle({
    Name = "Auto Plants Seed",
    CurrentValue = false,
    Flag = "AutoPlantToggle",
    Callback = function(Value) _G.PlantSettings.Enabled = Value end,
})

-- 6. LOOPS & UTILITIES

-- WalkSpeed Loop
task.spawn(function()
    while task.wait() do
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = _G.PlayerSettings.WalkSpeed
            end
        end)
    end
end)

-- UI TOGGLE KEY (H)
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.H then
        if Window.Visible then Window:Minimize() else Window:Maximize() end
    end
end)
