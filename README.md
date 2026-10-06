# Aimware v6 UI Library for Roblox

A pixel-perfect, feature-rich 1:1 recreation of the legendary **AIMWARE v6** cheat interface designed specifically for Roblox script developers.

![Aimware v6 UI](original%20ui%20screenshoots/ragebot%20tab.jpg)

---

## ⚡ Quick Start / Loadstring

```lua
local Aimware = loadstring(game:HttpGet("https://raw.githubusercontent.com/Unwalker1337/aimware-v6-ui-library-roblox/main/source.lua"))()

local Window = Aimware:CreateWindow({
    Title = "Aimware",
    Subtitle = "v6.0",
    Size = UDim2.new(0, 820, 0, 530),
    ToggleKey = Enum.KeyCode.Insert,
    AccentColor = Color3.fromRGB(235, 68, 77)
})

local RageTab = Window:CreateTab({
    Name = "Ragebot",
    Icon = "Ragebot", -- or custom asset ID
    MasterSwitch = true,
    Callback = function(enabled)
        print("Ragebot Master Switch:", enabled)
    end
})

local MainSection = RageTab:CreateSection("Main", "Left")

MainSection:CreateToggle({
    Name = "Enabled",
    Default = true,
    Callback = function(val)
        print("Enabled:", val)
    end
})

MainSection:CreateSlider({
    Name = "FOV",
    Min = 0,
    Max = 180,
    Default = 180,
    Suffix = "°",
    Callback = function(val)
        print("FOV:", val)
    end
})
```

---

## 🚀 Features

- **1:1 Visual Fidelity**: Replicated colors, paddings, fonts, acrylic background, and rounded borders matching Aimware v6.
- **Header Master Switch**: Each cheat tab includes an optional master switch right next to the tab header.
- **Sub-Tabs Support**: Horizontal sub-navigation (e.g., `Aimbot | Triggerbot | Weapon` or `Enemy | Team | Weapon | Local`).
- **Comprehensive Widget Library**:
  - **Toggles**: Pill switches with optional sub-gear popups and inline color pickers.
  - **Sliders**: Smooth dragging with custom suffixes (`%`, `°`, `ms`, etc.).
  - **Dropdowns**: Single-select and multi-select comboboxes with top-level overlay rendering.
  - **Keybinds**: Interactive key & mouse button binder with red highlight active state.
  - **Color Pickers**: Full SV palette, Hue bar, Hex input, and inline circle previews.
  - **Pill/Tag Selectors**: Multi-state tags (e.g. `Box >`, `Health >`, `Name >`).
  - **Config / File Manager**: Built-in config manager with Play, Save, Edit, and Delete action buttons.
  - **Buttons**: Aimware-styled action buttons with hover animations.
- **Top-Bar Utilities**:
  - **General Settings Modal**: Quick menu for DPI scaling, themes, keybinds, and UI opacity.
  - **Global Search**: Real-time element filtering.
  - **Watermark & Keybinds List**: Draggable info HUD.
- **Executor Compatibility**: Works smoothly across Synapse X, Wave, Solara, Delta, Codex, Swift, Fluxus, and standard Roblox environments.

---

## 📖 Complete Example

See [`example.lua`](file:///example.lua) for the full 1:1 recreation of all Aimware v6 tabs (Ragebot, Legitbot, Visuals, World, Misc, Configs, and Lua Scripts).

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Unwalker1337/aimware-v6-ui-library-roblox/main/example.lua"))()
```
