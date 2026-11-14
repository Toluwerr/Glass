local Glass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Toluwerr/Glass/main/Glass.luau"))()

local Window = Glass:CreateWindow({
    Id = "glass_example",
    Name = "Example Script",
    Size = UDim2.fromOffset(760, 500),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.RightControl,
})
