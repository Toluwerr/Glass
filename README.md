# Glass

A modular Luau user interface library for Roblox.

Glass maintains a standalone distribution in `Glass.luau` and module sources in `src/`.

## Usage

```lua
local Glass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Toluwerr/Glass/main/Glass.luau"))()

local Window = Glass:CreateWindow({
    Title = "Glass",
    Size = UDim2.fromOffset(650, 450),
})

Window:SetTitle("Glass")
```

The current foundation provides window creation, title and visibility updates, and safe destruction. Navigation and interactive components will be added incrementally.

The window maintains a minimum size of 620 × 420 pixels. No external build tools are required.
