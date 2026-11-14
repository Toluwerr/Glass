local Theme = {
    Accent = Color3.fromRGB(44, 103, 197),
    Window = Color3.fromRGB(24, 24, 24),
    Content = Color3.fromRGB(24, 24, 24),
    RaisedSurface = Color3.fromRGB(36, 36, 36),
    Divider = Color3.fromRGB(56, 56, 56),
    Text = Color3.fromRGB(255, 255, 255),
    CornerRadius = 8,
    HeaderHeight = 48,
    MinimumSize = Vector2.new(620, 420),
    DefaultSize = UDim2.fromOffset(760, 500),
    Font = Font.fromId(12187365364, Enum.FontWeight.SemiBold),
}

return table.freeze(Theme)
