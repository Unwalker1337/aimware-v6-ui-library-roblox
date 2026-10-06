--[[
    AIMWARE v6 - 1:1 Complete Example Replicating Screenshots
    Author: Unwalker1337 / Aimware Team
    Run in Roblox via loadstring or executor
]]

local Aimware
if not pcall(function()
    Aimware = loadstring(game:HttpGet("https://raw.githubusercontent.com/Unwalker1337/aimware-v6-ui-library-roblox/main/source.lua?nocache=" .. tick()))()
end) or not Aimware then
    -- Fallback to local file if running within studio / testing environment
    local currentSource = script and script.Parent and script.Parent:FindFirstChild("source")
    if currentSource then
        Aimware = require(currentSource)
    else
        error("Unable to load Aimware v6 source.")
    end
end

-- Create Window
local Window = Aimware:CreateWindow({
    Title = "Aimware",
    Subtitle = "v6.0",
    Size = UDim2.new(0, 830, 0, 540),
    ToggleKey = Enum.KeyCode.Insert,
    AccentColor = Color3.fromRGB(235, 68, 77)
})

Aimware:Notify({
    Title = "AIMWARE.net",
    Message = "Welcome, " .. game:GetService("Players").LocalPlayer.Name .. "! Press [Insert] to toggle menu.",
    Duration = 4
})

-- ========================================================
-- TAB 1: RAGEBOT
-- ========================================================
local RageTab = Window:CreateTab({
    Name = "Ragebot",
    Icon = Aimware.Icons.Ragebot,
    MasterSwitch = true,
    Callback = function(enabled)
        Aimware:Notify({ Title = "Ragebot", Message = "Master Switch: " .. (enabled and "ON" or "OFF"), Duration = 2 })
    end
})

-- Left Column: Main
local RageMain = RageTab:CreateSection("Main", "Left")

RageMain:CreateToggle({ Name = "Enabled", Default = true })
RageMain:CreateToggle({ Name = "Refine Shot", Default = false })
RageMain:CreateToggle({ Name = "Double Precision", Default = false })
RageMain:CreateToggle({ Name = "Silent Aim", Default = true })
RageMain:CreateToggle({ Name = "Backtrack", Default = true })
RageMain:CreateToggle({ Name = "Anti-Recoil", Default = true })

RageMain:CreateDropdown({
    Name = "Anti-Spread Mode",
    Options = {"Off", "Default", "Roll"},
    Default = "Off"
})

RageMain:CreateToggle({ Name = "Double-Tap", Default = false })

RageMain:CreateSlider({
    Name = "Max extrapolation ticks",
    Min = 0,
    Max = 16,
    Default = 0
})

RageMain:CreateDropdown({
    Name = "Target Selection",
    Options = {"Closest To Crosshair", "Lowest Health", "Field of View", "Threat"},
    Default = "Closest To Crosshair"
})

RageMain:CreateSlider({
    Name = "FOV",
    Min = 0,
    Max = 180,
    Default = 180,
    Suffix = "°"
})

RageMain:CreateDropdown({
    Name = "Knifebot",
    Options = {"Off", "Trigger", "Full"},
    Default = "Off"
})

RageMain:CreateKeybind({
    Name = "Duck Peek assist",
    Default = Enum.KeyCode.Unknown
})

-- Left Column: Anti-Aim
local AntiAimSec = RageTab:CreateSection("Anti-Aim", "Left")

AntiAimSec:CreateToggle({ Name = "Enabled", Default = true })

AntiAimSec:CreateDropdown({
    Name = "Pitch Angle",
    Options = {"Down", "Up", "Zero", "Custom"},
    Default = "Down"
})

AntiAimSec:CreateDropdown({
    Name = "Yaw Base",
    Options = {"View Direction", "At Targets", "Spin"},
    Default = "View Direction"
})

AntiAimSec:CreateSlider({
    Name = "Yaw Offset",
    Min = -180,
    Max = 180,
    Default = 0,
    Suffix = "°"
})

-- Right Column: Accuracy
local AccuracySec = RageTab:CreateSection("Accuracy", "Right", Aimware.Icons.Pistol)

AccuracySec:CreateSlider({
    Name = "Min Damage",
    Min = 1,
    Max = 100,
    Default = 14
})

AccuracySec:CreateDropdown({
    Name = "Min Damage Options",
    Options = {"Auto Wall", "Adaptive Damage", "Visible Only"},
    Default = {["Auto Wall"] = true, ["Adaptive Damage"] = true},
    Multi = true
})

AccuracySec:CreateSlider({
    Name = "Hit Chance",
    Min = 0,
    Max = 100,
    Default = 18,
    Suffix = "%"
})

-- Right Column: Hitbox
local HitboxSec = RageTab:CreateSection("Hitbox", "Right", Aimware.Icons.Pistol)

HitboxSec:CreateDropdown({
    Name = "Head",
    Options = {"Priority", "Normal", "Ignore"},
    Default = "Priority"
})

HitboxSec:CreateDropdown({
    Name = "Body",
    Options = {"Exposed", "Center", "Stomach", "Pelvis"},
    Default = {["Exposed"] = true, ["Center"] = true},
    Multi = true
})

HitboxSec:CreateDropdown({
    Name = "Limbs",
    Options = {"Arms", "Legs", "Feet"},
    Default = {},
    Multi = true
})

-- Right Column: Automate
local AutomateSec = RageTab:CreateSection("Automate", "Right", Aimware.Icons.Pistol)

AutomateSec:CreateDropdown({
    Name = "Auto Fire",
    Options = {"Auto Pistol", "Full Auto", "Off"},
    Default = "Auto Pistol"
})

AutomateSec:CreateDropdown({
    Name = "Auto Stop",
    Options = {"Full Stop", "Early Stop", "Off"},
    Default = "Off"
})

-- Right Column: Auto Peek
local AutoPeekSec = RageTab:CreateSection("Auto Peek", "Right")

AutoPeekSec:CreateToggle({
    Name = "Enable",
    Default = false,
    SubGear = function()
        Aimware:Notify({ Title = "Auto Peek", Message = "Opening advanced auto peek parameters...", Duration = 2 })
    end
})

-- ========================================================
-- TAB 2: LEGITBOT
-- ========================================================
local LegitTab = Window:CreateTab({
    Name = "Legitbot",
    Icon = Aimware.Icons.Legitbot,
    MasterSwitch = true
})

local LegitAimbot = LegitTab:CreateSubTab("Aimbot")
LegitTab:CreateSubTab("Triggerbot")
LegitTab:CreateSubTab("Weapon")

local LegitMain = LegitAimbot:CreateSection("Main", "Left")
LegitMain:CreateToggle({ Name = "Enable", Default = false })
LegitMain:CreateKeybind({ Name = "Aim Key", Default = Enum.UserInputType.MouseButton1 })
LegitMain:CreateToggle({ Name = "Auto aim", Default = false })
LegitMain:CreateSlider({ Name = "Auto Pistol Interval", Min = 0, Max = 500, Default = 150, Suffix = "ms" })

local LegitHitbox = LegitAimbot:CreateSection("Hitbox Selection", "Right", Aimware.Icons.Pistol)
LegitHitbox:CreateSlider({ Name = "Hitbox Advance Multiplier", Min = 0.1, Max = 3.0, Default = 1.5, Decimals = 1 })
LegitHitbox:CreateSlider({ Name = "Min Damage", Min = 1, Max = 100, Default = 100 })
LegitHitbox:CreateToggle({ Name = "Nearest To Crosshair", Default = false })

-- ========================================================
-- TAB 3: VISUALS
-- ========================================================
local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = Aimware.Icons.Visuals,
    MasterSwitch = true
})

local VisEnemy = VisualsTab:CreateSubTab("Enemy")
VisualsTab:CreateSubTab("Team")
VisualsTab:CreateSubTab("Weapon")
VisualsTab:CreateSubTab("Local")

local VisOverlay = VisEnemy:CreateSection("Overlay", "Left")
VisOverlay:CreateTagList({
    Name = "Overlay Elements",
    Options = {"Box", "Ammo", "Health", "Name", "Skeleton", "Armor", "Money", "Ping", "Flags", "Barrel", "Weapon"},
    Selected = {"Health", "Name", "Skeleton", "Weapon"},
    Callback = function(selectedTags)
        print("Active ESP tags:", table.concat(selectedTags, ", "))
    end
})

local VisChams = VisEnemy:CreateSection("Chams", "Right")
VisChams:CreateDropdown({
    Name = "Model Visible",
    Options = {"Glow", "Plastic", "Textured", "Off"},
    Default = "Glow"
})
VisChams:CreateDropdown({
    Name = "Model Occluded",
    Options = {"Plastic", "Glow", "Off"},
    Default = "Plastic"
})
VisChams:CreateDropdown({
    Name = "Model Glow",
    Options = {"On", "Off"},
    Default = "On"
})
VisChams:CreateDropdown({
    Name = "Attachments Visible",
    Options = {"Textured", "Flat", "Off"},
    Default = "Textured"
})
VisChams:CreateDropdown({
    Name = "Attachments Occluded",
    Options = {"Off", "Textured"},
    Default = "Off"
})
VisChams:CreateDropdown({
    Name = "Ragdoll Visible",
    Options = {"Glow", "Off"},
    Default = "Glow"
})
VisChams:CreateDropdown({
    Name = "Backtrack Visible",
    Options = {"Off", "Glow"},
    Default = "Off"
})
VisChams:CreateDropdown({
    Name = "Shot Visible",
    Options = {"Off", "Solid"},
    Default = "Off"
})

-- ========================================================
-- TAB 4: WORLD
-- ========================================================
local WorldTab = Window:CreateTab({
    Name = "World",
    Icon = Aimware.Icons.World,
    MasterSwitch = true
})

local WorldCam = WorldTab:CreateSection("Camera", "Left")
WorldCam:CreateSlider({ Name = "Third Person Distance", Min = 0, Max = 200, Default = 52 })
WorldCam:CreateSlider({ Name = "View FOV", Min = 60, Max = 130, Default = 100 })
WorldCam:CreateSlider({ Name = "Viewmodel FOV", Min = 50, Max = 100, Default = 61 })

local WorldAmbience = WorldTab:CreateSection("Ambience", "Left")
WorldAmbience:CreateToggle({ Name = "Apply on Main Menu", Default = true })
WorldAmbience:CreateDropdown({
    Name = "Weather",
    Options = {"Off", "Rain", "Snow", "Ash"},
    Default = "Off"
})
WorldAmbience:CreateDropdown({
    Name = "Skybox",
    Options = {"Default", "Night", "Sunset", "Galaxy"},
    Default = "Default"
})
WorldAmbience:CreateToggle({ Name = "World Color", Default = true, ColorPicker = { Default = Color3.fromRGB(240, 235, 210) } })
WorldAmbience:CreateToggle({ Name = "Sky Color", Default = true, ColorPicker = { Default = Color3.fromRGB(255, 248, 220) } })
WorldAmbience:CreateToggle({ Name = "Clouds Color", Default = true, ColorPicker = { Default = Color3.fromRGB(255, 200, 150) } })
WorldAmbience:CreateToggle({ Name = "Sun Color", Default = true, ColorPicker = { Default = Color3.fromRGB(180, 180, 180) } })
WorldAmbience:CreateToggle({ Name = "Light Color", Default = false, ColorPicker = { Default = Color3.fromRGB(245, 245, 220) } })
WorldAmbience:CreateToggle({ Name = "Explosion Color", Default = false, ColorPicker = { Default = Color3.fromRGB(200, 200, 200) } })
WorldAmbience:CreateToggle({ Name = "Fire Color", Default = false, ColorPicker = { Default = Color3.fromRGB(220, 80, 255) } })
WorldAmbience:CreateToggle({ Name = "Muzzle Flash Color", Default = false, ColorPicker = { Default = Color3.fromRGB(255, 50, 50) } })
WorldAmbience:CreateToggle({ Name = "Override Fog", Default = true })

local WorldExtra = WorldTab:CreateSection("Extra", "Right")
WorldExtra:CreateToggle({ Name = "Visualize Aimbot", Default = true, ColorPicker = { Default = Color3.fromRGB(255, 100, 150) } })
WorldExtra:CreateToggle({ Name = "Sniper Crosshair", Default = true })
WorldExtra:CreateToggle({ Name = "Bullet Impacts", Default = false, SubGear = function() end })
WorldExtra:CreateDropdown({ Name = "Crosshair Recoil", Options = {"Off", "Dot", "Cross"}, Default = "Off" })
WorldExtra:CreateDropdown({
    Name = "Effects Removal",
    Options = {"No Flash", "No Smoke", "No Recoil", "No Scope"},
    Default = {["No Flash"] = true, ["No Smoke"] = true, ["No Recoil"] = true},
    Multi = true
})

local WorldHelper = WorldTab:CreateSection("Helper", "Right")
WorldHelper:CreateDropdown({ Name = "Wallbang Info", Options = {"Damage", "Penetration", "Off"}, Default = "Damage" })
WorldHelper:CreateDropdown({ Name = "Out Of View", Options = {"Arrow", "Circle", "Off"}, Default = "Arrow" })
WorldHelper:CreateSlider({ Name = "Out Of View Scale", Min = 1, Max = 100, Default = 11, Suffix = "%" })
WorldHelper:CreateDropdown({
    Name = "Indicators",
    Options = {"Double-Tap", "Anti Spread", "Min Damage"},
    Default = {["Double-Tap"] = true, ["Anti Spread"] = true, ["Min Damage"] = true},
    Multi = true
})
WorldHelper:CreateToggle({ Name = "Smoke", Default = false, ColorPicker = { Default = Color3.fromRGB(180, 200, 255) } })
WorldHelper:CreateDropdown({
    Name = "Grenade Tracer",
    Options = {"Local", "Friendly", "Enemy", "Color Fade"},
    Default = {["Local"] = true, ["Friendly"] = true, ["Enemy"] = true, ["Color Fade"] = true},
    Multi = true
})
WorldHelper:CreateToggle({ Name = "Damage Indicator", Default = true })
WorldHelper:CreateDropdown({ Name = "Kill Effect", Options = {"Off", "Lightning", "Headshot Pop"}, Default = "Off" })

-- ========================================================
-- TAB 5: MISCELLANEOUS
-- ========================================================
local MiscTab = Window:CreateTab({
    Name = "Miscellaneous",
    Icon = Aimware.Icons.Misc,
    MasterSwitch = true
})

local MiscFeatures = MiscTab:CreateSection("Features", "Left")
MiscFeatures:CreateDropdown({ Name = "Secure Mode", Options = {"Off", "Low", "High"}, Default = "Off" })
MiscFeatures:CreateToggle({ Name = "Chat Spam", Default = false })
MiscFeatures:CreateToggle({ Name = "Auto-Accept Match", Default = true })
MiscFeatures:CreateToggle({ Name = "Preserve Killfeed", Default = false })
MiscFeatures:CreateToggle({ Name = "Show Spectators", Default = true })
MiscFeatures:CreateToggle({ Name = "Anti-OBS", Default = false })
MiscFeatures:CreateToggle({ Name = "Show Watermark", Default = true })
MiscFeatures:CreateToggle({ Name = "Quick Plant", Default = true })
MiscFeatures:CreateToggle({ Name = "Straight Throw", Default = true })
MiscFeatures:CreateDropdown({ Name = "Log", Options = {"Damage", "Purchases", "Votes", "Off"}, Default = "Damage" })
MiscFeatures:CreateDropdown({
    Name = "Vote Revealer",
    Options = {"Console (Aimware), HUD (On Screen)", "Console Only", "Off"},
    Default = "Console (Aimware), HUD (On Screen)"
})

local MiscMovement = MiscTab:CreateSection("Movement", "Right")
MiscMovement:CreateToggle({ Name = "Auto Strafe", Default = true, SubGear = function() end })
MiscMovement:CreateDropdown({ Name = "Auto Jump", Options = {"Perfect", "Legit", "Directional", "Off"}, Default = "Perfect" })
MiscMovement:CreateDropdown({ Name = "Jump Bug", Options = {"Always On", "On Key", "Off"}, Default = "Always On" })
MiscMovement:CreateKeybind({ Name = "Edge Jump", Default = Enum.KeyCode.Unknown })
MiscMovement:CreateKeybind({ Name = "Slow Walk Key", Default = Enum.KeyCode.LeftShift })
MiscMovement:CreateSlider({ Name = "Slow Walk Speed", Min = 10, Max = 100, Default = 60, Suffix = "%" })
MiscMovement:CreateToggle({ Name = "Fast ladder", Default = true })
MiscMovement:CreateToggle({ Name = "Quick Stop", Default = true })

-- ========================================================
-- TAB 6: CONFIGURATIONS (PINNED)
-- ========================================================
local ConfigTab = Window:CreateTab({
    Name = "Configurations",
    Icon = Aimware.Icons.Configs,
    Pinned = true,
    MasterSwitch = false
})

local ConfigSec = ConfigTab:CreateSection("Local", "Left")
ConfigSec:CreateFileList({
    Name = "Local",
    Extension = ".cfg",
    Files = {
        { Name = "HVHBEST.cfg", Date = "2026-08-06 02:11:15" },
        { Name = "SAVE2.cfg", Date = "2026-08-16 00:52:56" },
        { Name = "dt.cfg", Date = "2026-08-17 09:58:58" },
        { Name = "kaka owner (1).cfg", Date = "2026-08-02 20:34:25" },
        { Name = "legit2.cfg", Date = "2026-08-13 01:42:52" },
        { Name = "legitCFG.cfg", Date = "2026-08-23 16:02:06" },
        { Name = "save.cfg", Date = "2026-08-23 21:39:11" },
        { Name = "semiLEGIT.cfg", Date = "2026-10-05 21:29:22" },
        { Name = "semik ya hz.cfg", Date = "2026-07-23 22:22:10" },
        { Name = "souljaenjoyer.cfg", Date = "2026-07-29 13:21:27" },
    },
    OnLoad = function(cfgName)
        Aimware:Notify({ Title = "Config Manager", Message = "Loaded configuration: " .. cfgName, Duration = 3 })
    end,
    OnSave = function(cfgName)
        Aimware:Notify({ Title = "Config Manager", Message = "Saved configuration: " .. cfgName, Duration = 3 })
    end,
    OnDelete = function(cfgName)
        Aimware:Notify({ Title = "Config Manager", Message = "Deleted: " .. cfgName, Duration = 3 })
    end,
    OnAdd = function()
        Aimware:Notify({ Title = "Config Manager", Message = "Creating new config...", Duration = 3 })
    end
})

-- ========================================================
-- TAB 7: LUA SCRIPTS (PINNED)
-- ========================================================
local LuaTab = Window:CreateTab({
    Name = "Lua Scripts",
    Icon = Aimware.Icons.Lua,
    Pinned = true,
    MasterSwitch = false
})

local LuaLocalSec = LuaTab:CreateSection("Local", "Left")
LuaLocalSec:CreateFileList({
    Name = "Local",
    Extension = ".lua",
    Files = {
        { Name = "ADVANDED ANTII AIIM.lua", Date = "2026-08-02 19:25:48", Loaded = false },
        { Name = "BEST.lua", Date = "2026-08-06 02:07:14", Loaded = false },
        { Name = "Name changer.lua", Date = "2026-07-28 14:39:54", Loaded = false },
        { Name = "loader.lua", Date = "2026-07-29 22:22:02", Loaded = true },
        { Name = "rgnweapons_preview_engine_cache.lua", Date = "2026-10-05 21:26:58", Loaded = false },
        { Name = "vote reveal.lua", Date = "2026-07-28 14:39:55", Loaded = true },
    },
    OnLoad = function(scriptName)
        Aimware:Notify({ Title = "Lua Engine", Message = "Executing script: " .. scriptName, Duration = 3 })
    end,
    OnSave = function(scriptName)
        Aimware:Notify({ Title = "Lua Engine", Message = "Saved script: " .. scriptName, Duration = 3 })
    end,
    OnDelete = function(scriptName)
        Aimware:Notify({ Title = "Lua Engine", Message = "Deleted script: " .. scriptName, Duration = 3 })
    end,
    OnAdd = function()
        Aimware:Notify({ Title = "Lua Engine", Message = "Creating new Lua script...", Duration = 3 })
    end
})

local LuaSecuritySec = LuaTab:CreateSection("Security", "Right")
LuaSecuritySec:CreateToggle({ Name = "Allow scripts to edit lua files", Default = true })
LuaSecuritySec:CreateToggle({ Name = "Allow scripts to edit cfg files", Default = true })
LuaSecuritySec:CreateToggle({ Name = "Allow internet connections", Default = true })
LuaSecuritySec:CreateToggle({ Name = "Allow game scripting", Default = true })
LuaSecuritySec:CreateToggle({ Name = "Allow insecure FFI", Default = true })
LuaSecuritySec:CreateButton({
    Name = "Save Lua Permissions",
    Callback = function()
        Aimware:Notify({ Title = "Security", Message = "Lua permissions successfully saved.", Duration = 2.5 })
    end
})

local LuaOtherSec = LuaTab:CreateSection("Other", "Right")
LuaOtherSec:CreateToggle({ Name = "Load With Configurations", Default = true })
