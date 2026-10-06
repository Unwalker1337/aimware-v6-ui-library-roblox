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
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Global Protection / Parent Selection
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

-- Clean previous instances
if getgenv and getgenv().AimwareV6_Instance then
    pcall(function()
        getgenv().AimwareV6_Instance:Destroy()
    end)
end

local Aimware = {
    Theme = {
        WindowBg = Color3.fromRGB(20, 26, 36),
        WindowStroke = Color3.fromRGB(38, 48, 64),
        SidebarBg = Color3.fromRGB(15, 20, 28),
        SectionBg = Color3.fromRGB(24, 32, 43),
        SectionStroke = Color3.fromRGB(32, 42, 56),
        ControlBg = Color3.fromRGB(17, 23, 31),
        ControlStroke = Color3.fromRGB(30, 40, 53),
        Accent = Color3.fromRGB(235, 68, 77),
        AccentDark = Color3.fromRGB(195, 48, 56),
        TextPrimary = Color3.fromRGB(240, 245, 252),
        TextSecondary = Color3.fromRGB(130, 145, 165),
        SwitchOff = Color3.fromRGB(48, 59, 74),
        SwitchThumb = Color3.fromRGB(225, 232, 242),
        Hover = Color3.fromRGB(28, 38, 52),
    },
    Icons = {
        Logo = "rbxassetid://6031094678",
        Legitbot = "rbxassetid://6034684937",
        Ragebot = "rbxassetid://6031265976",
        Visuals = "rbxassetid://6031075931",
        World = "rbxassetid://6031075931",
        Inventory = "rbxassetid://6031082533",
        Misc = "rbxassetid://6031280882",
        Configs = "rbxassetid://6031075929",
        Lua = "rbxassetid://6034837562",
        Settings = "rbxassetid://6031280882",
        Search = "rbxassetid://6031154871",
        Play = "rbxassetid://6031097227",
        Save = "rbxassetid://6031075929",
        Edit = "rbxassetid://6031082531",
        Trash = "rbxassetid://6031094678",
        Plus = "rbxassetid://6031094670",
        Refresh = "rbxassetid://6031098485",
        ChevronDown = "rbxassetid://6034818379",
        Pistol = "rbxassetid://6034684937"
    },
    ActivePopups = {},
    Open = true,
}

-- Utility Functions
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
    local Subtitle = cfg.Subtitle or "v6.0"
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

    -- Main Container Frame with Shadow
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

    -- Drop Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1
    })

    -- Make Window Draggable
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
            -- Only allow drag from top header or sidebar empty spaces
            if pos.Y <= MainFrame.AbsolutePosition.Y + 48 or (pos.X <= MainFrame.AbsolutePosition.X + 56 and pos.Y <= MainFrame.AbsolutePosition.Y + 60) then
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

    -- Toggle Menu Visibility
    local MenuVisible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            MenuVisible = not MenuVisible
            MainFrame.Visible = MenuVisible
        end
    end)

    -- Overlay Layer for popups, colorpickers, dropdown menus
    local OverlayLayer = Create("Frame", {
        Name = "OverlayLayer",
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 500,
        ClipsDescendants = false
    })

    -- Dismiss all active popups when clicking outside
    OverlayLayer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for popup, closeFunc in pairs(Aimware.ActivePopups) do
                if closeFunc then closeFunc() end
            end
            table.clear(Aimware.ActivePopups)
        end
    end)

    -- ====================
    -- LEFT SIDEBAR
    -- ====================
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 56, 1, 0),
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
        BackgroundColor3 = self.Theme.WindowStroke,
        BorderSizePixel = 0
    })

    -- Top Aimware Logo
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("ImageLabel", {
            Name = "LogoIcon",
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3926307971",
            ImageRectOffset = Vector2.new(684, 84),
            ImageRectSize = Vector2.new(36, 36),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        })
    })

    -- Middle Nav Buttons Container
    local NavContainer = Create("Frame", {
        Name = "NavContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 58),
        Size = UDim2.new(1, 0, 1, -165),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    -- Bottom Nav Buttons Container (Pinned: Configs & Lua)
    local BottomNavContainer = Create("Frame", {
        Name = "BottomNavContainer",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 1, -96),
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    -- ====================
    -- TOP HEADER BAR
    -- ====================
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        Position = UDim2.new(0, 56, 0, 0),
        Size = UDim2.new(1, -56, 0, 48),
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
            Padding = UDim.new(0, 14),
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
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1
    })

    -- Header Master Switch
    local MasterSwitchFrame = Create("TextButton", {
        Name = "MasterSwitch",
        Parent = HeaderLeft,
        Size = UDim2.new(0, 32, 0, 16),
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
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -14, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    -- Sub-Tabs Bar (In Header)
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
            Padding = UDim.new(0, 20),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Header Right Icons (Settings Gear, Search)
    local HeaderRight = Create("Frame", {
        Name = "HeaderRight",
        Parent = Header,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 240, 0, 32),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Search Bar Input
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Parent = HeaderRight,
        Size = UDim2.new(0, 160, 0, 26),
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
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    -- Search Button
    local SearchBtn = Create("ImageButton", {
        Name = "SearchBtn",
        Parent = HeaderRight,
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031154871",
        ImageColor3 = self.Theme.TextSecondary,
        LayoutOrder = 2
    })

    SearchBtn.MouseButton1Click:Connect(function()
        SearchContainer.Visible = not SearchContainer.Visible
        if SearchContainer.Visible then
            SearchBox:CaptureFocus()
        else
            SearchBox.Text = ""
        end
    end)

    -- Settings Gear Button
    local SettingsBtn = Create("ImageButton", {
        Name = "SettingsBtn",
        Parent = HeaderRight,
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031280882",
        ImageColor3 = self.Theme.TextSecondary,
        LayoutOrder = 3
    })

    -- General Settings Dropdown Popup (Matching screenshot `menu eneral settings element.jpg`)
    local SettingsPopup = Create("Frame", {
        Name = "SettingsPopup",
        Parent = OverlayLayer,
        Position = UDim2.new(1, -225, 0, 46),
        Size = UDim2.new(0, 215, 0, 260),
        BackgroundColor3 = self.Theme.WindowBg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 600
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = self.Theme.WindowStroke, Thickness = 1 }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
    })

    local function ToggleSettingsMenu()
        SettingsPopup.Visible = not SettingsPopup.Visible
        if SettingsPopup.Visible then
            SettingsBtn.ImageColor3 = self.Theme.Accent
            Aimware.ActivePopups[SettingsPopup] = function()
                SettingsPopup.Visible = false
                SettingsBtn.ImageColor3 = self.Theme.TextSecondary
            end
        else
            SettingsBtn.ImageColor3 = self.Theme.TextSecondary
            Aimware.ActivePopups[SettingsPopup] = nil
        end
    end

    SettingsBtn.MouseButton1Click:Connect(ToggleSettingsMenu)

    -- Populate General Settings items
    local function AddSettingsRow(labelText, controlCreator, order)
        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            LayoutOrder = order or 1
        })
        local label = Create("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = labelText,
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local ctrl = controlCreator(row)
        return row
    end

    -- 1. DPI Scale
    AddSettingsRow("Dpi Scale", function(row)
        local btn = Create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 95, 0, 20),
            BackgroundColor3 = self.Theme.ControlBg,
            Font = Enum.Font.GothamMedium,
            Text = "100% (default)",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 10,
            AutoButtonColor = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 })
        })
        return btn
    end, 1)

    -- 2. Theme
    AddSettingsRow("Theme", function(row)
        local btn = Create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 95, 0, 20),
            BackgroundColor3 = self.Theme.ControlBg,
            Font = Enum.Font.GothamMedium,
            Text = "Default",
            TextColor3 = self.Theme.TextPrimary,
            TextSize = 11,
            AutoButtonColor = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = self.Theme.ControlStroke, Thickness = 1 })
        })
        return btn
    end, 2)

    -- 3. Menu Key (Red pill button default Insert)
    AddSettingsRow("Menu Key", function(row)
        local keyBtn = Create("TextButton", {
            Parent = row,
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

        local listening = false
        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    ToggleKey = input.KeyCode
                    keyBtn.Text = ToggleKey.Name
                    listening = false
                    conn:Disconnect()
                end
            end)
        end)
        return keyBtn
    end, 3)

    -- 4. Console Key
    AddSettingsRow("Console Key", function(row)
        local keyBtn = Create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 50, 0, 18),
            BackgroundColor3 = self.Theme.ControlBg,
            Font = Enum.Font.GothamMedium,
            Text = "None",
            TextColor3 = self.Theme.TextSecondary,
            TextSize = 10,
            AutoButtonColor = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) })
        })
        return keyBtn
    end, 4)

    -- 5. Show Binds
    AddSettingsRow("Show Binds", function(row)
        local btn = Create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 75, 0, 20),
            BackgroundColor3 = self.Theme.ControlBg,
            Font = Enum.Font.GothamMedium,
            Text = "Off",
            TextColor3 = self.Theme.TextSecondary,
            TextSize = 11,
            AutoButtonColor = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) })
        })
        return btn
    end, 5)

    -- 6. Show UI Hints
    AddSettingsRow("Show UI Hints", function(row)
        local sw = Create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 14),
            BackgroundColor3 = self.Theme.Accent,
            Text = "",
            AutoButtonColor = false
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("Frame", {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(1, -12, 0.5, -5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
        })
        return sw
    end, 6)

    -- 7. UI Opacity Slider
    local OpacityRow = Create("Frame", {
        Parent = SettingsPopup,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = 7
    })
    Create("TextLabel", {
        Parent = OpacityRow,
        Size = UDim2.new(0.5, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "UI Opacity",
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local OpacityVal = Create("TextLabel", {
        Parent = OpacityRow,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 14),
        Size = UDim2.new(0, 40, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "100%",
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    local OpacityTrack = Create("TextButton", {
        Parent = OpacityRow,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -44, 0, 18),
        Size = UDim2.new(0, 60, 0, 4),
        BackgroundColor3 = self.Theme.ControlBg,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    local OpacityFill = Create("Frame", {
        Parent = OpacityTrack,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    -- ====================
    -- MAIN CONTENT PAGES
    -- ====================
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        Position = UDim2.new(0, 56, 0, 48),
        Size = UDim2.new(1, -56, 1, -48),
        BackgroundTransparency = 1
    })

    -- Watermark Window (Optional / Toggleable)
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
            Name = "TopAccent",
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

    -- Real-time FPS & Ping for Watermark
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

    -- Window Object
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

    -- Global Search Listener
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if WindowObj.ActiveTab and WindowObj.ActiveTab.ActivePage then
            for _, section in ipairs(WindowObj.ActiveTab.ActivePage.Sections or {}) do
                local anyMatch = false
                for _, elem in ipairs(section.Elements or {}) do
                    if query == "" or (elem.Name and elem.Name:lower():find(query)) then
                        elem.Frame.Visible = true
                        anyMatch = true
                    else
                        elem.Frame.Visible = false
                    end
                end
                section.Frame.Visible = anyMatch
            end
        end
    end)

    -- Tab Creation Function
    function WindowObj:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local TabName = tabCfg.Name or "Tab"
        local TabIcon = tabCfg.Icon or Aimware.Icons.Ragebot
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

        -- Sidebar Button
        local parentNav = IsPinned and BottomNavContainer or NavContainer
        local TabBtn = Create("TextButton", {
            Name = TabName .. "_Btn",
            Parent = parentNav,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })

        -- Left Active Indicator Bar (Aimware red bar)
        local ActiveBar = Create("Frame", {
            Name = "ActiveBar",
            Parent = TabBtn,
            Position = UDim2.new(0, 0, 0.5, -12),
            Size = UDim2.new(0, 3, 0, 24),
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

        -- Page Container (holds 2 columns)
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

        -- 2 Columns (Left & Right)
        local LeftCol = Create("Frame", {
            Name = "LeftColumn",
            Parent = DefaultPage,
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })

        local RightCol = Create("Frame", {
            Name = "RightColumn",
            Parent = DefaultPage,
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0.5, 8, 0, 0),
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })

        TabObj.DefaultPage = {
            Frame = DefaultPage,
            LeftCol = LeftCol,
            RightCol = RightCol,
            Sections = {}
        }
        TabObj.ActivePage = TabObj.DefaultPage

        -- Select Tab Action
        function TabObj:Select()
            for _, t in pairs(WindowObj.Tabs) do
                t.ActiveBar.Visible = false
                t.IconImg.ImageColor3 = Aimware.Theme.TextSecondary
                if t.DefaultPage and t.DefaultPage.Frame then
                    t.DefaultPage.Frame.Visible = false
                end
                for _, p in pairs(t.Pages) do
                    p.Frame.Visible = false
                end
            end

            WindowObj.ActiveTab = TabObj
            ActiveBar.Visible = true
            IconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.Text = TabName

            -- Header Master Switch Display
            if HasMasterSwitch then
                MasterSwitchFrame.Visible = true
                MasterSwitchFrame.BackgroundColor3 = TabObj.MasterState and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                MasterSwitchThumb.Position = TabObj.MasterState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            else
                MasterSwitchFrame.Visible = false
            end

            -- Update Sub-Tabs Display in Header
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
            else
                DefaultPage.Visible = true
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Select()
        end)

        TabObj.TabBtn = TabBtn
        TabObj.ActiveBar = ActiveBar
        TabObj.IconImg = IconImg

        -- Master Switch Click Handler
        MasterSwitchFrame.MouseButton1Click:Connect(function()
            if WindowObj.ActiveTab == TabObj and HasMasterSwitch then
                TabObj.MasterState = not TabObj.MasterState
                local targetColor = TabObj.MasterState and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                local targetPos = TabObj.MasterState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)

                Tween(MasterSwitchFrame, TweenInfo.new(0.2), { BackgroundColor3 = targetColor })
                Tween(MasterSwitchThumb, TweenInfo.new(0.2), { Position = targetPos })

                MasterCallback(TabObj.MasterState)
            end
        end)

        -- SubTab Management
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
                Size = UDim2.new(0.5, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
            })

            local SubRightCol = Create("Frame", {
                Name = "RightColumn",
                Parent = SubPage,
                Size = UDim2.new(0.5, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0.5, 8, 0, 0),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
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

            -- Create Section method on SubTab
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

        -- Section Creation Function (Card / Groupbox)
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
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Aimware.Theme.SectionStroke, Thickness = 1 })
            })

            -- Header of Section Card
            local SecHeader = Create("Frame", {
                Name = "SecHeader",
                Parent = SectionCard,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1
            }, {
                Create("TextLabel", {
                    Name = "Title",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = secTitle,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            -- Optional Mini Icon in Section Header (e.g., pistol icon)
            if secIcon then
                Create("ImageLabel", {
                    Name = "SecIcon",
                    Parent = SecHeader,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Image = secIcon,
                    ImageColor3 = Aimware.Theme.TextSecondary
                })
            end

            -- Elements Container inside Card
            local ElementsList = Create("Frame", {
                Name = "ElementsList",
                Parent = SectionCard,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 12)
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
            -- WIDGETS
            -- ==========================

            -- 1. TOGGLE (Pill switch)
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

                local Label = Create("TextLabel", {
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

                -- Inline Color Picker Circle
                local ColorBtn
                if HasColor then
                    local colorVal = tCfg.ColorPicker.Default or Color3.fromRGB(255, 255, 255)
                    ColorBtn = Create("TextButton", {
                        Parent = RightControls,
                        Size = UDim2.new(0, 13, 0, 13),
                        BackgroundColor3 = colorVal,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = 1
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                        Create("UIStroke", { Color = Color3.fromRGB(60, 70, 85), Thickness = 1 })
                    })
                end

                -- Inline Sub-Gear Button
                if HasGear then
                    local gearBtn = Create("ImageButton", {
                        Parent = RightControls,
                        Size = UDim2.new(0, 14, 0, 14),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://6031280882",
                        ImageColor3 = Aimware.Theme.TextSecondary,
                        LayoutOrder = 2
                    })
                    gearBtn.MouseButton1Click:Connect(function()
                        tCfg.SubGear()
                    end)
                end

                -- Pill Switch
                local Switch = Create("TextButton", {
                    Name = "Switch",
                    Parent = RightControls,
                    Size = UDim2.new(0, 32, 0, 16),
                    BackgroundColor3 = State and Aimware.Theme.Accent or Aimware.Theme.SwitchOff,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = 3
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                local Thumb = Create("Frame", {
                    Parent = Switch,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Aimware.Theme.SwitchThumb,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                local function SetToggle(val)
                    State = val
                    local targetColor = State and Aimware.Theme.Accent or Aimware.Theme.SwitchOff
                    local targetPos = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                    Tween(Switch, TweenInfo.new(0.18), { BackgroundColor3 = targetColor })
                    Tween(Thumb, TweenInfo.new(0.18), { Position = targetPos })
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

            -- 2. SLIDER
            function SectionObj:CreateSlider(sCfg)
                sCfg = sCfg or {}
                local Name = sCfg.Name or "Slider"
                local Min = sCfg.Min or 0
                local Max = sCfg.Max or 100
                local Value = sCfg.Default or Min
                local Suffix = sCfg.Suffix or ""
                local Decimals = sCfg.Decimals or 0
                local Callback = sCfg.Callback or function() end

                local Row = Create("Frame", {
                    Name = Name .. "_SliderRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1
                })

                local TopSub = Create("Frame", {
                    Parent = Row,
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1
                })

                local Label = Create("TextLabel", {
                    Parent = TopSub,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Aimware.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValLabel = Create("TextLabel", {
                    Parent = TopSub,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and (" " .. Suffix) or ""),
                    TextColor3 = Aimware.Theme.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                -- Slider Bar Track
                local Track = Create("TextButton", {
                    Name = "Track",
                    Parent = Row,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = Aimware.Theme.ControlBg,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) })
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
                    ValLabel.Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and (" " .. Suffix) or "")
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
                        ValLabel.Text = string.format("%." .. Decimals .. "f", Value) .. (Suffix ~= "" and (" " .. Suffix) or "")
                        Callback(Value)
                    end,
                    GetValue = function() return Value end
                }
                table.insert(SectionObj.Elements, SliderObj)
                return SliderObj
            end

            -- 3. DROPDOWN / COMBOBOX
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
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1
                })

                local Label = Create("TextLabel", {
                    Parent = Row,
                    Size = UDim2.new(1, -150, 1, 0),
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
                    Size = UDim2.new(0, 140, 0, 22),
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
                    Parent = DropBtn,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6034818379",
                    ImageColor3 = Aimware.Theme.TextSecondary
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

                -- Overlay Dropdown Floating List
                local DropList = Create("Frame", {
                    Name = Name .. "_DropList",
                    Parent = OverlayLayer,
                    Size = UDim2.new(0, 140, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Aimware.Theme.WindowBg,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 700
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
                                DropList.Visible = false
                                Aimware.ActivePopups[DropList] = nil
                                Callback(Selected)
                            end
                        end)
                    end
                end

                DropBtn.MouseButton1Click:Connect(function()
                    DropList.Visible = not DropList.Visible
                    if DropList.Visible then
                        local btnAbs = DropBtn.AbsolutePosition
                        local mainAbs = MainFrame.AbsolutePosition
                        DropList.Position = UDim2.new(0, btnAbs.X - mainAbs.X, 0, (btnAbs.Y - mainAbs.Y) + DropBtn.AbsoluteSize.Y + 4)
                        PopulateOptions()
                        Aimware.ActivePopups[DropList] = function()
                            DropList.Visible = false
                        end
                    else
                        Aimware.ActivePopups[DropList] = nil
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

            -- 4. KEYBIND (Aimware styled pill button)
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

                local Label = Create("TextLabel", {
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

            -- 5. BUTTON (Aimware action button)
            function SectionObj:CreateButton(bCfg)
                bCfg = bCfg or {}
                local Name = bCfg.Name or "Button"
                local Callback = bCfg.Callback or function() end

                local Row = Create("Frame", {
                    Name = Name .. "_BtnRow",
                    Parent = ElementsList,
                    Size = UDim2.new(1, 0, 0, 26),
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
                    -- Flash effect
                    Tween(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Aimware.Theme.Accent })
                    task.delay(0.12, function()
                        Tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Aimware.Theme.ControlBg })
                    end)
                    Callback()
                end)

                local BtnObj = {
                    Name = Name,
                    Frame = Row
                }
                table.insert(SectionObj.Elements, BtnObj)
                return BtnObj
            end

            -- 6. TAGS / PILL SELECTOR (Matching Visuals Overlay tags: `Box >`, `Health >`, etc.)
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
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) })
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

            -- 7. CONFIG / LUA FILE MANAGER LIST (1:1 replica of `config tab.jpg` & `lua tab.jpg`)
            function SectionObj:CreateFileList(fCfg)
                fCfg = fCfg or {}
                local Name = fCfg.Name or "Local"
                local Extension = fCfg.Extension or ".cfg"
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

                -- Top toolbar (Refresh, Add +)
                local Toolbar = Create("Frame", {
                    Parent = Container,
                    Size = UDim2.new(1, 0, 0, 24),
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

                local RefreshBtn = Create("ImageButton", {
                    Parent = ToolRight,
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031098485",
                    ImageColor3 = Aimware.Theme.TextSecondary
                })

                local AddBtn = Create("ImageButton", {
                    Parent = ToolRight,
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031094670",
                    ImageColor3 = Aimware.Theme.TextSecondary
                })

                AddBtn.MouseButton1Click:Connect(function()
                    OnAdd()
                end)

                -- File Rows
                local ListFrame = Create("Frame", {
                    Parent = Container,
                    Position = UDim2.new(0, 0, 0, 26),
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
                            Size = UDim2.new(1, 0, 0, 36),
                            BackgroundColor3 = Aimware.Theme.ControlBg,
                            BorderSizePixel = 0
                        }, {
                            Create("UICorner", { CornerRadius = UDim.new(0, 4) })
                        })

                        -- File Page Icon with badge
                        local FileIcon = Create("ImageLabel", {
                            Parent = FileRow,
                            Position = UDim2.new(0, 8, 0.5, -12),
                            Size = UDim2.new(0, 24, 0, 24),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6031075929",
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })

                        -- File Name & Last Modified Date
                        local TextCol = Create("Frame", {
                            Parent = FileRow,
                            Position = UDim2.new(0, 38, 0, 3),
                            Size = UDim2.new(1, -150, 1, -6),
                            BackgroundTransparency = 1
                        })

                        Create("TextLabel", {
                            Parent = TextCol,
                            Size = UDim2.new(1, 0, 0, 16),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.GothamBold,
                            Text = fileName,
                            TextColor3 = isLoaded and Color3.fromRGB(80, 220, 120) or Aimware.Theme.TextPrimary,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        Create("TextLabel", {
                            Parent = TextCol,
                            Position = UDim2.new(0, 0, 0, 15),
                            Size = UDim2.new(1, 0, 0, 12),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.GothamMedium,
                            Text = "Last Modified: " .. dateStr,
                            TextColor3 = Aimware.Theme.TextSecondary,
                            TextSize = 9,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        -- Action Buttons on Right (Play, Save, Trash)
                        local Actions = Create("Frame", {
                            Parent = FileRow,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -8, 0.5, 0),
                            Size = UDim2.new(0, 95, 0, 20),
                            BackgroundTransparency = 1
                        }, {
                            Create("UIListLayout", {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(0, 8)
                            })
                        })

                        -- Play / Load Button
                        local PlayBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 14, 0, 14),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6031097227",
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        PlayBtn.MouseButton1Click:Connect(function()
                            OnLoad(fileName)
                        end)

                        -- Save / Overwrite Button
                        local SaveBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 14, 0, 14),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6031075929",
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        SaveBtn.MouseButton1Click:Connect(function()
                            OnSave(fileName)
                        end)

                        -- Delete / Trash Button
                        local TrashBtn = Create("ImageButton", {
                            Parent = Actions,
                            Size = UDim2.new(0, 14, 0, 14),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6031094678",
                            ImageColor3 = Aimware.Theme.TextSecondary
                        })
                        TrashBtn.MouseButton1Click:Connect(function()
                            OnDelete(fileName)
                        end)
                    end
                end

                PopulateFileList()
                RefreshBtn.MouseButton1Click:Connect(PopulateFileList)

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

        -- If first tab, auto select
        if #WindowObj.Tabs == 1 then
            TabObj:Select()
        end

        return TabObj
    end

    -- Toast Notification System
    function Aimware:Notify(notifCfg)
        notifCfg = notifCfg or {}
        local Title = notifCfg.Title or "AIMWARE"
        local Text = notifCfg.Message or "Notification"
        local Duration = notifCfg.Duration or 3

        local Toast = Create("Frame", {
            Parent = ScreenGui,
            Position = UDim2.new(1, -270, 1, 100),
            Size = UDim2.new(0, 250, 0, 50),
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
                Size = UDim2.new(1, -20, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = Title,
                TextColor3 = Aimware.Theme.TextPrimary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 22),
                Size = UDim2.new(1, -20, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = Text,
                TextColor3 = Aimware.Theme.TextSecondary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            })
        })

        Tween(Toast, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -270, 1, -70)
        })

        task.delay(Duration, function()
            local tw = Tween(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
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
