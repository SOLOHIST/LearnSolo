local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- GLOBAL SETTINGS (Controlled by UI, used by Logic)
_G.PlantSettings = {
    Enabled = false,
    SelectedSeeds = {},
    Mode = "Good Position",
    Delay = 0.5
}

local Window = Rayfield:CreateWindow({
    Name = "LearnSolo Hub | Grow a Garden",
    LoadingTitle = "Loading Auto-Plant Module...",
    ConfigurationSaving = { Enabled = true, FolderName = "LearnSoloConfigs", FileName = "PlantConfig" },
    KeySystem = false,
})

-- LOAD THE LOGIC MODULE FROM YOUR GITHUB
-- Replace the URL below with your actual Raw GitHub link for Part 2
loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/Repo/main/Modules/AutoPlant.lua"))()

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
