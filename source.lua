--[[
    AIMWARE v6 UI Library for Roblox
    1:1 Pixel-Perfect Recreation
    Author: Unwalker1337 / Aimware Team
    Repository: https://github.com/Unwalker1337/aimware-v6-ui-library-roblox
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Safe Parent Resolver
local function GetSafeGuiParent()
    if gethui then
        return gethui()
    end
    local success, coreGui = pcall(function() return CoreGui end)
    if success and coreGui then
        local robloxGui = coreGui:FindFirstChild("RobloxGui")
        if robloxGui then return robloxGui end
        return coreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Cleanup Previous Instances
if getgenv and getgenv().AimwareV6_Instance then
    pcall(function()
        getgenv().AimwareV6_Instance:Destroy()
    end)
end

local Aimware = {
    Theme = {
        WindowBg = Color3.fromRGB(24, 30, 40),       -- Acrylic slate dark
        WindowStroke = Color3.fromRGB(40, 50, 66),   -- Subtle window stroke
        SidebarBg = Color3.fromRGB(18, 22, 30),      -- Deep navy-slate sidebar
        SidebarStroke = Color3.fromRGB(32, 40, 54),  -- Sidebar divider
        SectionBg = Color3.fromRGB(22, 28, 38),      -- Card background
        SectionStroke = Color3.fromRGB(32, 40, 54),  -- Card border
        ControlBg = Color3.fromRGB(16, 21, 29),      -- Inputs / tracks
        ControlStroke = Color3.fromRGB(28, 36, 48),  -- Input borders
        Accent = Color3.fromRGB(235, 68, 77),        -- Aimware Signature Red
        AccentDark = Color3.fromRGB(195, 48, 56),
        TextPrimary = Color3.fromRGB(235, 240, 248),
        TextSecondary = Color3.fromRGB(130, 145, 165),
        SwitchOff = Color3.fromRGB(44, 54, 68),
        SwitchThumbOff = Color3.fromRGB(160, 172, 188),
        SwitchThumbOn = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(28, 36, 48),
    },
    ActivePopups = {}
}

-- ========================================================
-- Custom Asset Manager for 1:1 Authentic Aimware Icons
-- ========================================================
local ICONS_BASE_URL = "https://raw.githubusercontent.com/Unwalker1337/aimware-v6-ui-library-roblox/main/icons/clean/"
local IconCache = {}

local function ResolveIcon(name, fallbackId)
    if IconCache[name] then
        return IconCache[name]
    end
    local getasset = getcustomasset or getsynasset
    if getasset and writefile and isfile and makefolder then
        local folder = "aimware_v6_assets"
        if not isfolder(folder) then
            pcall(makefolder, folder)
        end
        local filePath = folder .. "/" .. name .. ".png"
        if not isfile(filePath) then
            local success, body = pcall(function()
                return game:HttpGet(ICONS_BASE_URL .. name .. ".png?raw=true")
            end)
            if success and body and #body > 50 then
                pcall(writefile, filePath, body)
            end
        end
        if isfile(filePath) then
            local success, asset = pcall(getasset, filePath)
            if success and asset then
                IconCache[name] = asset
                return asset
            end
        end
    end
    IconCache[name] = fallbackId
    return fallbackId
end

Aimware.Icons = {
    Logo = ResolveIcon("logo", "rbxassetid://10709818534"),
    Legitbot = ResolveIcon("legitbot", "rbxassetid://10734975692"),
    Ragebot = ResolveIcon("ragebot", "rbxassetid://10734962068"),
    Visuals = ResolveIcon("visuals", "rbxassetid://10723346959"),
    World = ResolveIcon("world", "rbxassetid://10723346959"),
    Inventory = ResolveIcon("inventory", "rbxassetid://10734909540"),
    Misc = ResolveIcon("misc", "rbxassetid://10747383470"),
    Configs = ResolveIcon("configs", "rbxassetid://10734941499"),
    Lua = ResolveIcon("lua", "rbxassetid://10709810463"),
    Settings = ResolveIcon("settings", "rbxassetid://10734950309"),
    Search = ResolveIcon("search", "rbxassetid://10734943674"),
    Play = "rbxassetid://10734923549",
    Save = ResolveIcon("configs", "rbxassetid://10734941499"),
    Trash = "rbxassetid://10747362393",
    Refresh = "rbxassetid://10734933222",
    ChevronDown = "rbxassetid://10709790948",
    Pistol = ResolveIcon("legitbot", "rbxassetid://10709818534")
}

local function Create(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(inst, info, props)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

-- Window Construction
function Aimware:CreateWindow(cfg)
    cfg = cfg or {}
    local Title = cfg.Title or "Aimware"
    local Size = cfg.Size or UDim2.new(0, 830, 0, 540)
    local ToggleKey = cfg.ToggleKey or Enum.KeyCode.Insert
    local AccentColor = cfg.AccentColor or self.Theme.Accent

    self.Theme.Accent = AccentColor

    local ScreenGui = Create("ScreenGui", {
        Name = "AimwareV6_UI",
        Parent = GetSafeGuiParent(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    })

    if getgenv then
        getgenv().AimwareV6_Instance = ScreenGui
    end

    -- Main Container Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = Size,
        Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2),
        BackgroundColor3 = self.Theme.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", {
            Color = self.Theme.WindowStroke,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })

    -- Ambient Drop Shadow
    Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 6),
        Size = UDim2.new(1, 44, 1, 44),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1
    })

    -- Draggable Header & Sidebar
    local Dragging = false
    local DragInput, DragStart, StartPos

    local function UpdateDrag(input)
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
    end

    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position
            if pos.Y <= MainFrame.AbsolutePosition.Y + 48 or (pos.X <= MainFrame.AbsolutePosition.X + 54 and pos.Y <= MainFrame.AbsolutePosition.Y + 60) then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateDrag(input)
        end
    end)

    -- Toggle Menu Key
    local MenuVisible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            MenuVisible = not MenuVisible
            MainFrame.Visible = MenuVisible
        end
    end)

    -- Overlay Layer for Dropdowns & Menus
    local OverlayLayer = Create("Frame", {
        Name = "OverlayLayer",
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 500,
        ClipsDescendants = false
    })

    -- Point inside GuiObject check
    local function IsPointInside(pos, guiObj)
        if not guiObj or not guiObj.Visible then return false end
        local absPos = guiObj.AbsolutePosition
        local absSize = guiObj.AbsoluteSize
        return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
           and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
    end

    -- Smart Outside-Click Dispasser: Never closes when clicking on the trigger button or inside popup!
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local clickPos = input.Position
            for popupId, data in pairs(Aimware.ActivePopups) do
                local insidePopup = IsPointInside(clickPos, data.Popup)
                local insideTrigger = IsPointInside(clickPos, data.TriggerBtn)
                if not insidePopup and not insideTrigger then
                    if data.Close then
                        data.Close()
                    end
                    Aimware.ActivePopups[popupId] = nil
                end
            end
        end
    end)

    -- ====================
    -- LEFT SIDEBAR
    -- ====================
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 52, 1, 0),
        BackgroundColor3 = self.Theme.SidebarBg,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) })
    })

    -- Right Border Line for Sidebar
    Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = self.Theme.SidebarStroke,
        BorderSizePixel = 0
    })

    -- Aimware Top Red-to-Dark Gradient on Sidebar (1:1 with Aimware v6)
    local SidebarGradient = Create("Frame", {
        Name = "SidebarGradient",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = Color3.fromRGB(240, 75, 85),
        BorderSizePixel = 0,
        ZIndex = 1
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(240, 75, 85)),
                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180, 50, 60)),
                ColorSequenceKeypoint.new(0.65, Color3.fromRGB(80, 28, 38)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(18, 22, 30))
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.0, 0.0),
                NumberSequenceKeypoint.new(0.4, 0.05),
                NumberSequenceKeypoint.new(0.75, 0.5),
                NumberSequenceKeypoint.new(1.0, 1.0)
            })
        })
    })

    -- Aimware Target Crosshair Logo (Centered at top directly on the red gradient)
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 2
    }, {
        Create("ImageLabel", {
            Name = "LogoIcon",
            Size = UDim2.new(0, 24, 0, 24),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = self.Icons.Logo,
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        })
    })

    -- Nav Buttons Container (Top / Middle tabs)
    local NavContainer = Create("Frame", {
        Name = "NavContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -150),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    -- Bottom Nav Buttons (Pinned: Configs & Lua)
    local BottomNavContainer = Create("Frame", {
        Name = "BottomNavContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 1, -90),
        Size = UDim2.new(1, 0, 0, 84),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    -- ====================
    -- TOP HEADER BAR
    -- ====================
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        Position = UDim2.new(0, 52, 0, 0),
        Size = UDim2.new(1, -52, 0, 48),
        BackgroundTransparency = 1
    })

    local HeaderLeft = Create("Frame", {
        Name = "HeaderLeft",
        Parent = Header,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Tab Title Label
    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = HeaderLeft,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Ragebot",
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1
    })

    -- Master Switch Pill next to Title
    local MasterSwitchFrame = Create("TextButton", {
        Name = "MasterSwitch",
        Parent = HeaderLeft,
        Size = UDim2.new(0, 28, 0, 15),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 2
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local MasterSwitchThumb = Create("Frame", {
        Name = "Thumb",
        Parent = MasterSwitchFrame,
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(1, -13, 0.5, -5.5),
        BackgroundColor3 = self.Theme.SwitchThumbOn,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    -- Sub-Tabs (In Header)
    local SubTabsBar = Create("Frame", {
        Name = "SubTabsBar",
        Parent = HeaderLeft,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = 3
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 18),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Header Right Icons (Order in Aimware: [Gear] [Search])
    local HeaderRight = Create("Frame", {
        Name = "HeaderRight",
        Parent = Header,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 240, 0, 32),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Search Bar Input Box
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Parent = HeaderRight,
        Size = UDim2.new(0, 150, 0, 24),
        BackgroundColor3 = self.Theme.ControlBg,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Visible = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 })
    })

    local SearchBox = Create("TextBox", {
        Name = "SearchBox",
        Parent = SearchContainer,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        PlaceholderText = "Search...",
        PlaceholderColor3 = self.Theme.TextSecondary,
        Text = "",
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    -- Settings Gear Button (FIRST in Header Right)
    local SettingsBtn = Create("ImageButton", {
        Name = "SettingsBtn",
        Parent = HeaderRight,
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = self.Icons.Settings,
        ImageColor3 = self.Theme.TextSecondary,
        LayoutOrder = 2
    })

    -- Search Lens Button (SECOND in Header Right)
    local SearchBtn = Create("ImageButton", {
        Name = "SearchBtn",
        Parent = HeaderRight,
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = self.Icons.Search,
        ImageColor3 = self.Theme.TextSecondary,
        LayoutOrder = 3
    })

    SearchBtn.MouseButton1Click:Connect(function()
        SearchContainer.Visible = not SearchContainer.Visible
        if SearchContainer.Visible then
            SearchBox:CaptureFocus()
        else
            SearchBox.Text = ""
        end
    end)

    -- UIScale for DPI scaling support
    local WindowScale = Create("UIScale", {
        Parent = MainFrame,
        Scale = 1.0
    })

    -- General Settings Modal (1:1 with Aimware v6 screenshot)
    local SettingsPopup = Create("Frame", {
        Name = "SettingsPopup",
        Parent = OverlayLayer,
        Position = UDim2.new(1, -225, 0, 46),
        Size = UDim2.new(0, 215, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.WindowBg,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        ZIndex = 900
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = self.Theme.WindowStroke, Thickness = 1 }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
    })

    local settingsOpen = false
    local lastSettingsToggle = 0

    local function CloseSettings()
        if not settingsOpen then return end
        settingsOpen = false
        lastSettingsToggle = tick()
        SettingsPopup.Visible = false
        SettingsBtn.ImageColor3 = self.Theme.TextSecondary
        Aimware.ActivePopups[SettingsPopup] = nil
    end

    local function OpenSettings()
        if settingsOpen then return end
        settingsOpen = true
        lastSettingsToggle = tick()
        SettingsPopup.Visible = true
        SettingsBtn.ImageColor3 = self.Theme.Accent
        Aimware.ActivePopups[SettingsPopup] = {
            Popup = SettingsPopup,
            TriggerBtn = SettingsBtn,
            Close = CloseSettings
        }
    end

    local function ToggleSettingsMenu()
        if tick() - lastSettingsToggle < 0.12 then return end
        if settingsOpen then
            CloseSettings()
        else
            OpenSettings()
        end
    end

    SettingsBtn.MouseButton1Click:Connect(ToggleSettingsMenu)

    -- Row Builder Helper
    local function AddSettingsRow(lbl, order)
        local row = Create("Frame", {
            Parent = SettingsPopup,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            LayoutOrder = order or 1
        })
        Create("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = lbl,
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        return row
    end

    -- 1. Dpi Scale (Dropdown)
    local dpiRow = AddSettingsRow("Dpi Scale", 1)
    local dpiBtn = Create("TextButton", {
        Parent = dpiRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 100, 0, 20),
        BackgroundColor3 = self.Theme.ControlBg,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 }),
        Create("TextLabel", {
            Name = "SelectedText",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "100% (default)",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Image = self.Icons.ChevronDown,
            ImageColor3 = self.Theme.TextSecondary
        })
    })

    dpiBtn.MouseButton1Click:Connect(function()
        if WindowScale.Scale == 1.0 then
            WindowScale.Scale = 1.25
            dpiBtn.SelectedText.Text = "125%"
        elseif WindowScale.Scale == 1.25 then
            WindowScale.Scale = 0.85
            dpiBtn.SelectedText.Text = "85%"
        else
            WindowScale.Scale = 1.0
            dpiBtn.SelectedText.Text = "100% (default)"
        end
    end)

    -- 2. Theme (Dropdown)
    local themeRow = AddSettingsRow("Theme", 2)
    local themeBtn = Create("TextButton", {
        Parent = themeRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 100, 0, 20),
        BackgroundColor3 = self.Theme.ControlBg,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 }),
        Create("TextLabel", {
            Name = "SelectedText",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "Default",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Image = self.Icons.ChevronDown,
            ImageColor3 = self.Theme.TextSecondary
        })
    })

    -- 3. Menu Key (Red Pill Keybind default Insert)
    local menuKeyRow = AddSettingsRow("Menu Key", 3)
    local menuKeyBtn = Create("TextButton", {
        Parent = menuKeyRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 65, 0, 18),
        BackgroundColor3 = self.Theme.Accent,
        Font = Enum.Font.GothamBold,
        Text = ToggleKey.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 10,
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })

    menuKeyBtn.MouseButton1Click:Connect(function()
        menuKeyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                ToggleKey = input.KeyCode
                menuKeyBtn.Text = ToggleKey.Name
                conn:Disconnect()
            end
        end)
    end)

    -- 4. Console Key (Dark Button default None)
    local consoleKeyRow = AddSettingsRow("Console Key", 4)
    local consoleKeyBtn = Create("TextButton", {
        Parent = consoleKeyRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 18),
        BackgroundColor3 = self.Theme.ControlBg,
        Font = Enum.Font.GothamMedium,
        Text = "None",
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 10,
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 })
    })

    -- 5. Show Binds (Dropdown)
    local bindsRow = AddSettingsRow("Show Binds", 5)
    local bindsBtn = Create("TextButton", {
        Parent = bindsRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 20),
        BackgroundColor3 = self.Theme.ControlBg,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 }),
        Create("TextLabel", {
            Name = "SelectedText",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "Off",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Image = self.Icons.ChevronDown,
            ImageColor3 = self.Theme.TextSecondary
        })
    })

    -- 6. Show UI Hints (Toggle)
    local hintsRow = AddSettingsRow("Show UI Hints", 6)
    local hintsState = true
    local hintsSwitch = Create("TextButton", {
        Parent = hintsRow,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 15),
        BackgroundColor3 = self.Theme.Accent,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local hintsThumb = Create("Frame", {
        Parent = hintsSwitch,
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(1, -13, 0.5, -5.5),
        BackgroundColor3 = self.Theme.SwitchThumbOn,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    hintsSwitch.MouseButton1Click:Connect(function()
        hintsState = not hintsState
        local targetColor = hintsState and self.Theme.Accent or self.Theme.SwitchOff
        local targetPos = hintsState and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
        Tween(hintsSwitch, TweenInfo.new(0.18), { BackgroundColor3 = targetColor })
        Tween(hintsThumb, TweenInfo.new(0.18), { Position = targetPos })
    end)

    -- 7. UI Opacity (Compact Slider 1:1 Aimware)
    local opacityRow = Create("Frame", {
        Parent = SettingsPopup,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = 7
    })

    Create("TextLabel", {
        Parent = opacityRow,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "UI Opacity",
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local opacityContainer = Create("Frame", {
        Parent = opacityRow,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 3),
        Size = UDim2.new(0, 95, 1, -3),
        BackgroundTransparency = 1
    })

    local opacityTrack = Create("TextButton", {
        Parent = opacityContainer,
        Position = UDim2.new(0, 0, 0, 3),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = self.Theme.ControlBg,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 })
    })

    local opacityFill = Create("Frame", {
        Parent = opacityTrack,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local opacityValLabel = Create("TextLabel", {
        Parent = opacityContainer,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "100%",
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local opacitySliding = false
    local function UpdateOpacity(input)
        local trackAbs = opacityTrack.AbsolutePosition
        local trackSize = opacityTrack.AbsoluteSize
        local pct = math.clamp((input.Position.X - trackAbs.X) / trackSize.X, 0, 1)
        local val = math.floor(pct * 100)
        opacityFill.Size = UDim2.new(pct, 0, 1, 0)
        opacityValLabel.Text = val .. "%"
        MainFrame.BackgroundTransparency = (1 - pct) * 0.7
        Sidebar.BackgroundTransparency = (1 - pct) * 0.7
    end

    opacityTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacitySliding = true
            UpdateOpacity(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacitySliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if opacitySliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacity(input)
        end
    end)

    -- ====================
    -- MAIN CONTENT PAGES
    -- ====================
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        Position = UDim2.new(0, 52, 0, 48),
        Size = UDim2.new(1, -52, 1, -48),
        BackgroundTransparency = 1
    })

    -- Watermark Bar
    local Watermark = Create("Frame", {
        Name = "AimwareWatermark",
        Parent = ScreenGui,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(0, 280, 0, 24),
        BackgroundColor3 = self.Theme.WindowBg,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = self.Theme.WindowStroke, Thickness = 1 }),
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = self.Theme.Accent,
            BorderSizePixel = 0
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) })
        }),
        Create("TextLabel", {
            Name = "WatermarkText",
            Size = UDim2.new(1, -16, 1, -2),
            Position = UDim2.new(0, 8, 0, 2),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "AIMWARE.net | roblox | " .. LocalPlayer.Name .. " | 60 fps",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local frameCount = 0
    local lastFpsUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsUpdate >= 1 then
            local fps = math.floor(frameCount / (now - lastFpsUpdate))
            frameCount = 0
            lastFpsUpdate = now
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            pcall(function()
                Watermark.WatermarkText.Text = string.format("AIMWARE.net | roblox | %s | %d fps | %d ms", LocalPlayer.Name, fps, ping)
            end)
        end
    end)

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        OverlayLayer = OverlayLayer,
        Tabs = {},
        ActiveTab = nil,
        TitleLabel = TitleLabel,
        MasterSwitch = MasterSwitchFrame,
        SubTabsBar = SubTabsBar,
        ContentContainer = ContentContainer,
        SearchBox = SearchBox,
    }

    -- Search Filtering
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if WindowObj.ActiveTab and WindowObj.ActiveTab.ActivePage then
            for _, sec in ipairs(WindowObj.ActiveTab.ActivePage.Sections or {}) do
                local anyMatch = false
                for _, elem in ipairs(sec.Elements or {}) do
                    if query == "" or (elem.Name and elem.Name:lower():find(query)) then
                        elem.Frame.Visible = true
                        anyMatch = true
                    else
                        elem.Frame.Visible = false
                    end
                end
                sec.Frame.Visible = anyMatch
            end
        end
    end)

    -- Tab Builder
    function WindowObj:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local TabName = tabCfg.Name or "Tab"
        local TabIcon = tabCfg.Icon
        if type(TabIcon) == "string" then
            if Aimware.Icons[TabIcon] then
                TabIcon = Aimware.Icons[TabIcon]
            else
                local titleCase = TabIcon:sub(1,1):upper() .. TabIcon:sub(2):lower()
                if Aimware.Icons[titleCase] then
                    TabIcon = Aimware.Icons[titleCase]
                end
            end
        end
        TabIcon = TabIcon or Aimware.Icons.Ragebot
        local IsPinned = tabCfg.Pinned or false
        local HasMasterSwitch = tabCfg.MasterSwitch ~= false
        local MasterCallback = tabCfg.Callback or function() end

        local TabObj = {
            Name = TabName,
            Icon = TabIcon,
            HasMasterSwitch = HasMasterSwitch,
            MasterState = true,
            SubTabs = {},
            ActiveSubTab = nil,
            Pages = {},
            ActivePage = nil,
        }

        local parentNav = IsPinned and BottomNavContainer or NavContainer
        local TabBtn = Create("TextButton", {
            Name = TabName .. "_Btn",
            Parent = parentNav,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })

        -- Left Active Indicator Bar (Red Stripe)
        local ActiveBar = Create("Frame", {
            Name = "ActiveBar",
            Parent = TabBtn,
            Position = UDim2.new(0, 0, 0.5, -11),
            Size = UDim2.new(0, 3, 0, 22),
            BackgroundColor3 = Aimware.Theme.Accent,
            BorderSizePixel = 0,
            Visible = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) })
        })

        local IconImg = Create("ImageLabel", {
            Name = "Icon",
            Parent = TabBtn,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image = TabIcon,
            ImageColor3 = Aimware.Theme.TextSecondary
        })

        -- Page Container (2 Columns)
        local DefaultPage = Create("ScrollingFrame", {
            Name = TabName .. "_DefaultPage",
            Parent = ContentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(45, 56, 72),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
            Visible = false
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 14)
            })
        })

        -- 2 Columns (Width ~360px each, 18px horizontal gap, 16px vertical spacing)
        local LeftCol = Create("Frame", {
            Name = "LeftColumn",
            Parent = DefaultPage,
            Size = UDim2.new(0.5, -9, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 16)
            })
        })

        local RightCol = Create("Frame", {
            Name = "RightColumn",
            Parent = DefaultPage,
            Size = UDim2.new(0.5, -9, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0.5, 9, 0, 0),
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 16)
            })
        })

        TabObj.DefaultPage = {
            Frame = DefaultPage,
            LeftCol = LeftCol,
            RightCol = RightCol,
            Sections = {}
        }
        TabObj.ActivePage = TabObj.DefaultPage

        function TabObj:Select()
            for _, t in pairs(WindowObj.Tabs) do
                if t.ActiveBar then t.ActiveBar.Visible = false end
                if t.IconImg then t.IconImg.ImageColor3 = Aimware.Theme.TextSecondary end
                if t.DefaultPage and t.DefaultPage.Frame then
                    t.DefaultPage.Frame.Visible = false
                end
                for _, p in pairs(t.Pages) do
                    p.Frame.Visible = false
                end
            end

            WindowObj.ActiveTab = TabObj
            ActiveBar.Visible = true
            IconImg.ImageColor3 = Aimware.Theme.Accent
            TitleLabel.Text = TabName

            if HasMasterSwitch then
                MasterSwitchFrame.Visible = true
                MasterSwitchFrame.BackgroundColor3 = TabObj.MasterState and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                MasterSwitchThumb.Position = TabObj.MasterState and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
            else
                MasterSwitchFrame.Visible = false
            end

            for _, child in ipairs(SubTabsBar:GetChildren()) do
                if child:IsA("GuiObject") then child:Destroy() end
            end

            if #TabObj.SubTabs > 0 then
                SubTabsBar.Visible = true
                for idx, subName in ipairs(TabObj.SubTabs) do
                    local isSubActive = (TabObj.ActiveSubTab == subName)
                    local subBtn = Create("TextButton", {
                        Name = subName .. "_SubBtn",
                        Parent = SubTabsBar,
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Font = isSubActive and Enum.Font.GothamBold or Enum.Font.GothamMedium,
                        Text = subName,
                        TextColor3 = isSubActive and Color3.fromRGB(255, 255, 255) or Aimware.Theme.TextSecondary,
                        TextSize = 13,
                        LayoutOrder = idx
                    })

                    subBtn.MouseButton1Click:Connect(function()
                        TabObj:SelectSubTab(subName)
                    end)
                end
            else
                SubTabsBar.Visible = false
            end

            if TabObj.ActivePage then
                TabObj.ActivePage.Frame.Visible = true
                TabObj.ActivePage.Frame.CanvasPosition = Vector2.new(0, 0)
            else
                DefaultPage.Visible = true
                DefaultPage.CanvasPosition = Vector2.new(0, 0)
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Select()
        end)

        TabObj.TabBtn = TabBtn
        TabObj.ActiveBar = ActiveBar
        TabObj.IconImg = IconImg

        MasterSwitchFrame.MouseButton1Click:Connect(function()
            if WindowObj.ActiveTab == TabObj and HasMasterSwitch then
                TabObj.MasterState = not TabObj.MasterState
                local targetColor = TabObj.MasterState and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                local targetPos = TabObj.MasterState and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)

                Tween(MasterSwitchFrame, TweenInfo.new(0.18), { BackgroundColor3 = targetColor })
                Tween(MasterSwitchThumb, TweenInfo.new(0.18), { Position = targetPos })

                MasterCallback(TabObj.MasterState)
            end
        end)

        function TabObj:CreateSubTab(subName)
            table.insert(TabObj.SubTabs, subName)

            local SubPage = Create("ScrollingFrame", {
                Name = subName .. "_Page",
                Parent = ContentContainer,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Color3.fromRGB(45, 56, 72),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                Visible = false
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14),
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 14)
                })
            })

            local SubLeftCol = Create("Frame", {
                Name = "LeftColumn",
                Parent = SubPage,
                Size = UDim2.new(0.5, -9, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 16)
                })
            })

            local SubRightCol = Create("Frame", {
                Name = "RightColumn",
                Parent = SubPage,
                Size = UDim2.new(0.5, -9, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0.5, 9, 0, 0),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 16)
                })
            })

            local PageData = {
                Frame = SubPage,
                LeftCol = SubLeftCol,
                RightCol = SubRightCol,
                Sections = {}
            }
            TabObj.Pages[subName] = PageData

            if not TabObj.ActiveSubTab then
                TabObj.ActiveSubTab = subName
                TabObj.ActivePage = PageData
            end

            local SubTabObj = { Name = subName }
            function SubTabObj:CreateSection(secTitle, colSide, secIcon)
                return TabObj:CreateSection(secTitle, colSide, secIcon, PageData)
            end

            return SubTabObj
        end

        function TabObj:SelectSubTab(subName)
            TabObj.ActiveSubTab = subName
            TabObj.ActivePage = TabObj.Pages[subName]
            TabObj:Select()
        end

        -- SECTION BUILDER
        function TabObj:CreateSection(secTitle, colSide, secIcon, targetPage)
            targetPage = targetPage or TabObj.ActivePage or TabObj.DefaultPage
            local parentCol = (colSide == "Right" or colSide == 2) and targetPage.RightCol or targetPage.LeftCol

            local SectionCard = Create("Frame", {
                Name = secTitle .. "_Section",
                Parent = parentCol,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Aimware.Theme.SectionBg,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Create("UIStroke", { Color = Aimware.Theme.SectionStroke, Thickness = 1 })
            })

            local SecHeader = Create("Frame", {
                Name = "SecHeader",
                Parent = SectionCard,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            }, {
                Create("TextLabel", {
                    Name = "Title",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = secTitle,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            if secIcon then
                Create("ImageLabel", {
                    Name = "SecIcon",
                    Parent = SecHeader,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Image = secIcon,
                    ImageColor3 = Aimware.Theme.TextSecondary
                })
            end

            local ElementsList = Create("Frame", {
                Name = "ElementsList",
                Parent = SectionCard,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14),
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 14)
                }),
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
            })

            local SectionObj = {
                Frame = SectionCard,
                Elements = {},
                ElementsList = ElementsList
            }
            table.insert(targetPage.Sections, SectionObj)

            -- ==========================
            -- WIDGET: TOGGLE
            -- ==========================
            function SectionObj:CreateToggle(tCfg)
                tCfg = tCfg or {}
                local Name = tCfg.Name or "Toggle"
                local State = tCfg.Default or false
                local Callback = tCfg.Callback or function() end
                local HasGear = tCfg.SubGear ~= nil
                local HasColor = tCfg.ColorPicker ~= nil

                local Row = Create("Frame", {
                    Name = Name .. "_ToggleRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1
                })

                Create("TextLabel", {
                    Parent = Row,
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local RightControls = Create("Frame", {
                    Parent = Row,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 70, 1, 0),
                    BackgroundTransparency = 1
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                })

                if HasColor then
                    local colorVal = tCfg.ColorPicker.Default or Color3.fromRGB(255, 255, 255)
                    Create("TextButton", {
                        Parent = RightControls,
                        Size = UDim2.new(0, 12, 0, 12),
                        BackgroundColor3 = colorVal,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = 1
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                        Create("UIStroke", { Color = Color3.fromRGB(50, 60, 75), Thickness = 1 })
                    })
                end

                if HasGear then
                    local gearBtn = Create("ImageButton", {
                        Parent = RightControls,
                        Size = UDim2.new(0, 13, 0, 13),
                        BackgroundTransparency = 1,
                        Image = Aimware.Icons.Settings,
                        ImageColor3 = Aimware.Theme.TextSecondary,
                        LayoutOrder = 2
                    })
                    gearBtn.MouseButton1Click:Connect(function()
                        tCfg.SubGear()
                    end)
                end

                -- Pill Switch (Aimware 1:1 compact size)
                local Switch = Create("TextButton", {
                    Name = "Switch",
                    Parent = RightControls,
                    Size = UDim2.new(0, 28, 0, 15),
                    BackgroundColor3 = State and Aimware.Theme.Accent or Aimware.Theme.SwitchOff,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = 3
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                local Thumb = Create("Frame", {
                    Parent = Switch,
                    Size = UDim2.new(0, 11, 0, 11),
                    Position = State and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5),
                    BackgroundColor3 = State and Aimware.Theme.SwitchThumbOn or Aimware.Theme.SwitchThumbOff,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                local function SetToggle(val)
                    State = val
                    local targetColor = State and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                    local thumbColor = State and Aimware.Theme.SwitchThumbOn or Aimware.Theme.SwitchThumbOff
                    local targetPos = State and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)

                    Tween(Switch, TweenInfo.new(0.18), { BackgroundColor3 = targetColor })
                    Tween(Thumb, TweenInfo.new(0.18), { Position = targetPos, BackgroundColor3 = thumbColor })
                    Callback(State)
                end

                Switch.MouseButton1Click:Connect(function()
                    SetToggle(not State)
                end)

                local ToggleObj = {
                    Name = Name,
                    Frame = Row,
                    SetValue = SetToggle,
                    GetValue = function() return State end
                }
                table.insert(SectionObj.Elements, ToggleObj)
                return ToggleObj
            end

            -- ==========================
            -- WIDGET: SLIDER (1:1 AIMWARE COMPACT RIGHT-ALIGNED)
            -- ==========================
            function SectionObj:CreateSlider(sCfg)
                sCfg = sCfg or {}
                local Name = sCfg.Name or "Slider"
                local Min = sCfg.Min or 0
                local Max = sCfg.Max or 100
                local Value = sCfg.Default or Min
                local Suffix = sCfg.Suffix or ""
                local Decimals = sCfg.Decimals or 0
                local Callback = sCfg.Callback or function() end

                -- In Aimware v6: Label is Left, Slider Track is Right (~150px wide), Value is directly below the track!
                local Row = Create("Frame", {
                    Name = Name .. "_SliderRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1
                })

                Create("TextLabel", {
                    Parent = Row,
                    Size = UDim2.new(1, -165, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                -- Right-aligned slider container (Width: 155px)
                local SliderContainer = Create("Frame", {
                    Parent = Row,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 3),
                    Size = UDim2.new(0, 155, 1, -3),
                    BackgroundTransparency = 1
                })

                -- Slider Track (Height 4px)
                local Track = Create("TextButton", {
                    Name = "Track",
                    Parent = SliderContainer,
                    Position = UDim2.new(0, 0, 0, 3),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = Aimware.Theme.ControlBg,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                })

                local percent = math.clamp((Value - Min) / (Max - Min), 0, 1)
                local Fill = Create("Frame", {
                    Name = "Fill",
                    Parent = Track,
                    Size = UDim2.new(percent, 0, 1, 0),
                    BackgroundColor3 = Aimware.Theme.Accent,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                -- Value Label (Positioned right below the track, matching Aimware v6!)
                local ValLabel = Create("TextLabel", {
                    Parent = SliderContainer,
                    Position = UDim2.new(0, 0, 0, 10),
                    Size = UDim2.new(1, 0, 0, 12),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and ("" .. Suffix) or ""),
                    TextColor3 = Aimware.Theme.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local Sliding = false
                local function UpdateValue(input)
                    local trackAbs = Track.AbsolutePosition
                    local trackSize = Track.AbsoluteSize
                    local mouseX = input.Position.X
                    local pct = math.clamp((mouseX - trackAbs.X) / trackSize.X, 0, 1)
                    local rawVal = Min + (Max - Min) * pct
                    local step = 10 ^ (-Decimals)
                    Value = math.floor(rawVal / step + 0.5) * step

                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValLabel.Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and ("" .. Suffix) or "")
                    Callback(Value)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = true
                        UpdateValue(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateValue(input)
                    end
                end)

                local SliderObj = {
                    Name = Name,
                    Frame = Row,
                    SetValue = function(v)
                        Value = math.clamp(v, Min, Max)
                        local pct = (Value - Min) / (Max - Min)
                        Fill.Size = UDim2.new(pct, 0, 1, 0)
                        ValLabel.Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and ("" .. Suffix) or "")
                        Callback(Value)
                    end,
                    GetValue = function() return Value end
                }
                table.insert(SectionObj.Elements, SliderObj)
                return SliderObj
            end

            -- ==========================
            -- WIDGET: DROPDOWN
            -- ==========================
            function SectionObj:CreateDropdown(dCfg)
                dCfg = dCfg or {}
                local Name = dCfg.Name or "Dropdown"
                local Options = dCfg.Options or {}
                local IsMulti = dCfg.Multi or false
                local Selected = dCfg.Default or (IsMulti and {} or Options[1] or "")
                local Callback = dCfg.Callback or function() end

                local Row = Create("Frame", {
                    Name = Name .. "_DropdownRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1
                })

                Create("TextLabel", {
                    Parent = Row,
                    Size = UDim2.new(1, -165, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local DropBtn = Create("TextButton", {
                    Parent = Row,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 155, 0, 20),
                    BackgroundColor3 = Aimware.Theme.ControlBg,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                })

                local SelectedText = Create("TextLabel", {
                    Parent = DropBtn,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -26, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 11,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Chevron = Create("ImageLabel", {
                    Name = "Chevron",
                    Parent = DropBtn,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundTransparency = 1,
                    Image = Aimware.Icons.ChevronDown,
                    ImageColor3 = Aimware.Theme.TextSecondary,
                    Rotation = 0
                })

                local function UpdateDisplayText()
                    if IsMulti then
                        local activeList = {}
                        for opt, enabled in pairs(Selected) do
                            if enabled then table.insert(activeList, opt) end
                        end
                        SelectedText.Text = #activeList > 0 and table.concat(activeList, ", ") or "None"
                    else
                        SelectedText.Text = tostring(Selected)
                    end
                end
                UpdateDisplayText()

                local DropList = Create("ScrollingFrame", {
                    Name = Name .. "_DropList",
                    Parent = OverlayLayer,
                    Size = UDim2.new(0, 155, 0, 0),
                    BackgroundColor3 = Aimware.Theme.WindowBg,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 700,
                    ClipsDescendants = true,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Color3.fromRGB(45, 56, 72),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Aimware.Theme.WindowStroke, Thickness = 1 }),
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 4),
                        PaddingTop = UDim.new(0, 4),
                        PaddingBottom = UDim.new(0, 4)
                    }),
                    Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2)
                    })
                })

                local isOpen = false
                local lastToggleTime = 0

                local function CloseDropdown()
                    if not isOpen then return end
                    isOpen = false
                    lastToggleTime = tick()
                    Tween(Chevron, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Rotation = 0,
                        ImageColor3 = Aimware.Theme.TextSecondary
                    })
                    local closeTw = Tween(DropList, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 155, 0, 0),
                        BackgroundTransparency = 1
                    })
                    closeTw.Completed:Connect(function()
                        if not isOpen then
                            DropList.Visible = false
                        end
                    end)
                    Aimware.ActivePopups[DropList] = nil
                end

                local function PopulateOptions()
                    for _, child in ipairs(DropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for idx, opt in ipairs(Options) do
                        local isOptActive = IsMulti and (Selected[opt] == true) or (Selected == opt)
                        local optBtn = Create("TextButton", {
                            Name = "Option_" .. opt,
                            Parent = DropList,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = isOptActive and Aimware.Theme.Hover or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = isOptActive and 0 or 1,
                            Font = Enum.Font.GothamMedium,
                            Text = (IsMulti and (isOptActive and "✓ " or "   ") or "") .. opt,
                            TextColor3 = isOptActive and Aimware.Theme.Accent or Aimware.Theme.TextPrimary,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            LayoutOrder = idx
                        }, {
                            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                            Create("UIPadding", { PaddingLeft = UDim.new(0, 6) })
                        })

                        optBtn.MouseButton1Click:Connect(function()
                            if IsMulti then
                                Selected[opt] = not Selected[opt]
                                PopulateOptions()
                                UpdateDisplayText()
                                Callback(Selected)
                            else
                                Selected = opt
                                UpdateDisplayText()
                                CloseDropdown()
                                Callback(Selected)
                            end
                        end)
                    end
                end

                local function OpenDropdown()
                    if isOpen then return end
                    isOpen = true
                    lastToggleTime = tick()
                    PopulateOptions()

                    local btnAbs = DropBtn.AbsolutePosition
                    local mainAbs = MainFrame.AbsolutePosition
                    DropList.Position = UDim2.new(0, btnAbs.X - mainAbs.X, 0, (btnAbs.Y - mainAbs.Y) + DropBtn.AbsoluteSize.Y + 4)

                    local targetHeight = math.clamp(#Options * 22 + 8, 20, 180)
                    DropList.Size = UDim2.new(0, 155, 0, 0)
                    DropList.BackgroundTransparency = 1
                    DropList.Visible = true

                    Tween(Chevron, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Rotation = 180,
                        ImageColor3 = Aimware.Theme.Accent
                    })
                    Tween(DropList, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 155, 0, targetHeight),
                        BackgroundTransparency = 0
                    })

                    Aimware.ActivePopups[DropList] = {
                        Popup = DropList,
                        TriggerBtn = DropBtn,
                        Close = CloseDropdown
                    }
                end

                DropBtn.MouseButton1Click:Connect(function()
                    if tick() - lastToggleTime < 0.12 then return end
                    if isOpen then
                        CloseDropdown()
                    else
                        OpenDropdown()
                    end
                end)

                local DropdownObj = {
                    Name = Name,
                    Frame = Row,
                    SetValue = function(val)
                        Selected = val
                        UpdateDisplayText()
                        Callback(Selected)
                    end,
                    GetValue = function() return Selected end
                }
                table.insert(SectionObj.Elements, DropdownObj)
                return DropdownObj
            end

            -- ==========================
            -- WIDGET: KEYBIND
            -- ==========================
            function SectionObj:CreateKeybind(kCfg)
                kCfg = kCfg or {}
                local Name = kCfg.Name or "Keybind"
                local CurrentKey = kCfg.Default or Enum.KeyCode.Unknown
                local AllowMouse = kCfg.AllowMouse ~= false
                local Callback = kCfg.Callback or function() end

                local Row = Create("Frame", {
                    Name = Name .. "_KeybindRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1
                })

                Create("TextLabel", {
                    Parent = Row,
                    Size = UDim2.new(1, -75, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local isBound = CurrentKey ~= Enum.KeyCode.Unknown
                local KeyBtn = Create("TextButton", {
                    Parent = Row,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 65, 0, 18),
                    BackgroundColor3 = isBound and Aimware.Theme.Accent or Aimware.Theme.ControlBg,
                    Font = Enum.Font.GothamBold,
                    Text = isBound and (CurrentKey.Name or tostring(CurrentKey)) or "None",
                    TextColor3 = isBound and Color3.fromRGB(255, 255, 255) or Aimware.Theme.TextSecondary,
                    TextSize = 10,
                    AutoButtonColor = false
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                })

                local binding = false
                KeyBtn.MouseButton1Click:Connect(function()
                    binding = true
                    KeyBtn.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            CurrentKey = input.KeyCode
                            KeyBtn.Text = CurrentKey.Name
                            KeyBtn.BackgroundColor3 = Aimware.Theme.Accent
                            KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            binding = false
                            conn:Disconnect()
                            Callback(CurrentKey)
                        elseif AllowMouse and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3) then
                            local mouseName = (input.UserInputType == Enum.UserInputType.MouseButton1 and "Mouse1")
                                or (input.UserInputType == Enum.UserInputType.MouseButton2 and "Mouse2")
                                or "Mouse3"
                            CurrentKey = input.UserInputType
                            KeyBtn.Text = mouseName
                            KeyBtn.BackgroundColor3 = Aimware.Theme.Accent
                            KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            binding = false
                            conn:Disconnect()
                            Callback(CurrentKey)
                        end
                    end)
                end)

                local KeybindObj = {
                    Name = Name,
                    Frame = Row,
                    GetValue = function() return CurrentKey end
                }
                table.insert(SectionObj.Elements, KeybindObj)
                return KeybindObj
            end

            -- ==========================
            -- WIDGET: BUTTON
            -- ==========================
            function SectionObj:CreateButton(bCfg)
                bCfg = bCfg or {}
                local Name = bCfg.Name or "Button"
                local Callback = bCfg.Callback or function() end

                local Row = Create("Frame", {
                    Name = Name .. "_BtnRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1
                })

                local Btn = Create("TextButton", {
                    Parent = Row,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Aimware.Theme.ControlBg,
                    Font = Enum.Font.GothamBold,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 11,
                    AutoButtonColor = false
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                })

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Aimware.Theme.Hover })
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Aimware.Theme.ControlBg })
                end)

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, TweenInfo.new(0.08), { BackgroundColor3 = Aimware.Theme.Accent })
                    task.delay(0.12, function()
                        Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Aimware.Theme.ControlBg })
                    end)
                    Callback()
                end)

                local BtnObj = { Name = Name, Frame = Row }
                table.insert(SectionObj.Elements, BtnObj)
                return BtnObj
            end

            -- ==========================
            -- WIDGET: TAGS / PILL SELECTOR (Visuals Overlay)
            -- ==========================
            function SectionObj:CreateTagList(tCfg)
                tCfg = tCfg or {}
                local Name = tCfg.Name or "Tags"
                local Options = tCfg.Options or {}
                local Selected = tCfg.Selected or {}
                local Callback = tCfg.Callback or function() end

                local SelectedMap = {}
                for _, item in ipairs(Selected) do
                    SelectedMap[item] = true
                end

                local Row = Create("Frame", {
                    Name = Name .. "_TagRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1
                }, {
                    Create("UIGridLayout", {
                        CellSize = UDim2.new(0, 72, 0, 20),
                        CellPadding = UDim2.new(0, 6, 0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                })

                for idx, tag in ipairs(Options) do
                    local active = SelectedMap[tag] == true
                    local Pill = Create("TextButton", {
                        Name = "Tag_" .. tag,
                        Parent = Row,
                        BackgroundColor3 = active and Aimware.Theme.Accent or Aimware.Theme.ControlBg,
                        Font = Enum.Font.GothamMedium,
                        Text = tag .. " >",
                        TextColor3 = active and Color3.fromRGB(255, 255, 255) or Aimware.Theme.TextSecondary,
                        TextSize = 10,
                        AutoButtonColor = false,
                        LayoutOrder = idx
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                    })

                    Pill.MouseButton1Click:Connect(function()
                        SelectedMap[tag] = not SelectedMap[tag]
                        local nowActive = SelectedMap[tag]
                        Pill.BackgroundColor3 = nowActive and Aimware.Theme.Accent or Aimware.Theme.ControlBg
                        Pill.TextColor3 = nowActive and Color3.fromRGB(255, 255, 255) or Aimware.Theme.TextSecondary

                        local res = {}
                        for k, v in pairs(SelectedMap) do
                            if v then table.insert(res, k) end
                        end
                        Callback(res)
                    end)
                end

                local TagObj = { Name = Name, Frame = Row }
                table.insert(SectionObj.Elements, TagObj)
                return TagObj
            end

            -- ==========================
            -- WIDGET: FILE LIST (Configs & Lua manager)
            -- ==========================
            function SectionObj:CreateFileList(fCfg)
                fCfg = fCfg or {}
                local Name = fCfg.Name or "Local"
                local Files = fCfg.Files or {}
                local OnLoad = fCfg.OnLoad or function() end
                local OnSave = fCfg.OnSave or function() end
                local OnDelete = fCfg.OnDelete or function() end
                local OnAdd = fCfg.OnAdd or function() end

                local Container = Create("Frame", {
                    Name = Name .. "_FileManager",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1
                })

                local Toolbar = Create("Frame", {
                    Parent = Container,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1
                }, {
                    Create("TextLabel", {
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = Name,
                        TextColor3 = Aimware.Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                })

                local ToolRight = Create("Frame", {
                    Parent = Toolbar,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 50, 1, 0),
                    BackgroundTransparency = 1
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = UDim.new(0, 8)
                    })
                })

                Create("ImageButton", {
                    Parent = ToolRight,
                    Size = UDim2.new(0, 15, 0, 15),
                    BackgroundTransparency = 1,
                    Image = Aimware.Icons.Refresh,
                    ImageColor3 = Aimware.Theme.TextSecondary
                })

                local AddBtn = Create("ImageButton", {
                    Parent = ToolRight,
                    Size = UDim2.new(0, 15, 0, 15),
                    BackgroundTransparency = 1,
                    Image = Aimware.Icons.Play,
                    ImageColor3 = Aimware.Theme.TextSecondary
                })
                AddBtn.MouseButton1Click:Connect(OnAdd)

                local ListFrame = Create("Frame", {
                    Parent = Container,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1
                }, {
                    Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                })

                local function PopulateFileList()
                    for _, child in ipairs(ListFrame:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end

                    for idx, fileData in ipairs(Files) do
                        local fileName = type(fileData) == "table" and fileData.Name or tostring(fileData)
                        local dateStr = type(fileData) == "table" and fileData.Date or "2026-08-06 02:11:15"
                        local isLoaded = type(fileData) == "table" and fileData.Loaded or false

                        local FileRow = Create("Frame", {
                            Name = "File_" .. fileName,
                            Parent = ListFrame,
                            Size = UDim2.new(1, 0, 0, 34),
                            BackgroundColor3 = Aimware.Theme.ControlBg,
                            BorderSizePixel = 0
                        }, {
                            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                            Create("UIStroke", { Color = Aimware.Theme.ControlStroke, Thickness = 1 })
                        })

                        Create("ImageLabel", {
                            Parent = FileRow,
                            Position = UDim2.new(0, 8, 0.5, -9),
                            Size = UDim2.new(0, 18, 0, 18),
                            BackgroundTransparency = 1,
                            Image = Aimware.Icons.Configs,
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })

                        local TextCol = Create("Frame", {
                            Parent = FileRow,
                            Position = UDim2.new(0, 32, 0, 3),
                            Size = UDim2.new(1, -130, 1, -6),
                            BackgroundTransparency = 1
                        })

                        Create("TextLabel", {
                            Parent = TextCol,
                            Size = UDim2.new(1, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.GothamBold,
                            Text = fileName,
                            TextColor3 = isLoaded and Color3.fromRGB(80, 220, 120) or Aimware.Theme.TextPrimary,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        Create("TextLabel", {
                            Parent = TextCol,
                            Position = UDim2.new(0, 0, 0, 14),
                            Size = UDim2.new(1, 0, 0, 12),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.GothamMedium,
                            Text = "Last Modified: " .. dateStr,
                            TextColor3 = Aimware.Theme.TextSecondary,
                            TextSize = 9,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        local Actions = Create("Frame", {
                            Parent = FileRow,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -6, 0.5, 0),
                            Size = UDim2.new(0, 80, 0, 18),
                            BackgroundTransparency = 1
                        }, {
                            Create("UIListLayout", {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(0, 8)
                            })
                        })

                        local PlayBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 13, 0, 13),
                            BackgroundTransparency = 1,
                            Image = Aimware.Icons.Play,
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        PlayBtn.MouseButton1Click:Connect(function() OnLoad(fileName) end)

                        local SaveBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 13, 0, 13),
                            BackgroundTransparency = 1,
                            Image = Aimware.Icons.Save,
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        SaveBtn.MouseButton1Click:Connect(function() OnSave(fileName) end)

                        local TrashBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 13, 0, 13),
                            BackgroundTransparency = 1,
                            Image = Aimware.Icons.Trash,
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        TrashBtn.MouseButton1Click:Connect(function() OnDelete(fileName) end)
                    end
                end

                PopulateFileList()

                local FileListObj = {
                    Name = Name,
                    Frame = Container,
                    Refresh = PopulateFileList
                }
                table.insert(SectionObj.Elements, FileListObj)
                return FileListObj
            end

            return SectionObj
        end

        table.insert(WindowObj.Tabs, TabObj)

        if #WindowObj.Tabs == 1 then
            TabObj:Select()
        end

        return TabObj
    end

    -- Notification Toast System
    function Aimware:Notify(notifCfg)
        notifCfg = notifCfg or {}
        local Title = notifCfg.Title or "AIMWARE"
        local Text = notifCfg.Message or "Notification"
        local Duration = notifCfg.Duration or 3

        local Toast = Create("Frame", {
            Parent = ScreenGui,
            Position = UDim2.new(1, -270, 1, 100),
            Size = UDim2.new(0, 250, 0, 48),
            BackgroundColor3 = Aimware.Theme.WindowBg,
            BorderSizePixel = 0,
            ZIndex = 9999
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Create("UIStroke", { Color = Aimware.Theme.WindowStroke, Thickness = 1 }),
            Create("Frame", {
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = Aimware.Theme.Accent,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 2) })
            }),
            Create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -20, 0, 15),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = Title,
                TextColor3 = Aimware.Theme.TextPrimary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 22),
                Size = UDim2.new(1, -20, 0, 20),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = Text,
                TextColor3 = Aimware.Theme.TextSecondary,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            })
        })

        Tween(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -270, 1, -64)
        })

        task.delay(Duration, function()
            local tw = Tween(Toast, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -270, 1, 100)
            })
            tw.Completed:Connect(function()
                Toast:Destroy()
            end)
        end)
    end

    return WindowObj
end

return Aimware
