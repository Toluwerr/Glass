local Theme = require(script.Parent.Theme)

local Window = {}
Window.__index = Window

local allowedOptions = {
    Title = true,
    Size = true,
    Parent = true,
    Visible = true,
}

local function validateOptions(options)
    if options == nil then
        return {}
    end

    assert(type(options) == "table", "Glass: window options must be a table")

    for key in pairs(options) do
        assert(allowedOptions[key], ("Glass: unknown window option '%s'"):format(tostring(key)))
    end

    if options.Title ~= nil then
        assert(type(options.Title) == "string", "Glass: Title must be a string")
    end

    if options.Size ~= nil then
        assert(typeof(options.Size) == "UDim2", "Glass: Size must be a UDim2")
        assert(options.Size.X.Offset >= 0 and options.Size.Y.Offset >= 0, "Glass: Size offsets must not be negative")
        assert(options.Size.X.Scale >= 0 and options.Size.Y.Scale >= 0, "Glass: Size scales must not be negative")
    end

    if options.Parent ~= nil then
        assert(typeof(options.Parent) == "Instance", "Glass: Parent must be an Instance")
    end

    if options.Visible ~= nil then
        assert(type(options.Visible) == "boolean", "Glass: Visible must be a boolean")
    end

    return options
end

local function resolveParent(explicitParent)
    if explicitParent then
        return explicitParent
    end

    if type(gethui) == "function" then
        local success, result = pcall(gethui)
        if success and typeof(result) == "Instance" then
            return result
        end
    end

    local player = game:GetService("Players").LocalPlayer
    if player then
        local playerGui = player:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            return playerGui
        end
    end

    return game:GetService("CoreGui")
end

local function createInstance(className, properties, parent)
    local instance = Instance.new(className)

    for property, value in pairs(properties) do
        instance[property] = value
    end

    instance.Parent = parent
    return instance
end

function Window.new(rawOptions)
    local options = validateOptions(rawOptions)
    local parent = resolveParent(options.Parent)

    local screenGui = createInstance("ScreenGui", {
        Name = "GlassUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 100,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, nil)

    local surface = createInstance("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size or Theme.DefaultSize,
        BackgroundColor3 = Theme.Window,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = options.Visible ~= false,
        ZIndex = 1,
    }, screenGui)

    createInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
    }, surface)

    createInstance("UISizeConstraint", {
        MinSize = Theme.MinimumSize,
    }, surface)

    local header = createInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, surface)

    local title = createInstance("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.new(1, -40, 0, 25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = Theme.Font,
        TextSize = 16,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = options.Title or "Glass",
        ZIndex = 3,
    }, header)

    createInstance("Frame", {
        Name = "HeaderDivider",
        Position = UDim2.new(0, 0, 0, Theme.HeaderHeight),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, surface)

    local content = createInstance("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 0, 0, Theme.HeaderHeight + 1),
        Size = UDim2.new(1, 0, 1, -(Theme.HeaderHeight + 1)),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, surface)

    local self = setmetatable({
        ScreenGui = screenGui,
        Frame = surface,
        Content = content,
        _titleLabel = title,
        _destroyed = false,
    }, Window)

    local mounted, mountError = pcall(function()
        screenGui.Parent = parent
    end)

    if not mounted then
        screenGui:Destroy()
        error(("Glass: could not mount window: %s"):format(tostring(mountError)), 2)
    end

    return self
end

function Window:SetTitle(value)
    assert(not self._destroyed, "Glass: window has been destroyed")
    assert(type(value) == "string", "Glass: title must be a string")
    self._titleLabel.Text = value
    return self
end

function Window:SetVisible(value)
    assert(not self._destroyed, "Glass: window has been destroyed")
    assert(type(value) == "boolean", "Glass: visibility must be a boolean")
    self.Frame.Visible = value
    return self
end

function Window:IsDestroyed()
    return self._destroyed
end

function Window:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.ScreenGui = nil
    self.Frame = nil
    self.Content = nil
    self._titleLabel = nil
end

return Window
