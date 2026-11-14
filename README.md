# Glass

Glass is a Luau user interface library for Roblox. It provides a clean, dark interface and a straightforward API for creating and managing script windows.

## Usage

```lua
local Glass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Toluwerr/Glass/main/Glass.luau"))()

local Window = Glass:CreateWindow({
    Name = "Example Script",
    Size = UDim2.fromOffset(760, 500),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.RightControl,
})
```

## Window API

| Method | Description |
| --- | --- |
| `CreateWindow(options)` | Creates a window using the supplied configuration. |
| `Window:SetTitle(title)` | Updates the window title. |
| `Window:SetVisible(visible)` | Shows or hides the window. |
| `Window:IsDestroyed()` | Returns whether the window has been destroyed. |
| `Window:Destroy()` | Destroys the window and disconnects its input handlers. |

Window configuration supports `Id`, `Name`, `Title`, `Size`, `Position`, `ToggleKey`, `Parent`, and `Visible`. The default visibility shortcut is `RightControl`. Windows enforce a minimum size of 620 × 420 pixels.

## Structure

`Glass.luau` is the standalone distribution. The corresponding modular Luau source is maintained in `src/`, and `Example.luau` contains a usage example.
