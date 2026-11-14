local Theme = (function()
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
end)()

local Window = (function(Theme)

    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")

    local Window = {}
    Window.__index = Window

    local MINIMIZE_IMAGE = "rbxassetid://7734000129"
    local CLOSE_IMAGE = "rbxassetid://7743878857"
    local RESIZE_IMAGE = "rbxassetid://7743870505"

    local allowed = {
        Id = true,
        Name = true,
        Title = true,
        Position = true,
        Size = true,
        ToggleKey = true,
        Parent = true,
        Visible = true,
    }

    local function create(className, properties, parent)
        local object = Instance.new(className)
        for key, value in pairs(properties) do
            object[key] = value
        end
        object.Parent = parent
        return object
    end

    local function rounded(object, radius)
        create("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
    end

    local function validate(value)
        if value == nil then
            value = {}
        end
        assert(type(value) == "table", "Glass: window options must be a table")

        for key in pairs(value) do
            assert(allowed[key], ("Glass: unknown window option '%s'"):format(tostring(key)))
        end

        for _, name in ipairs({ "Id", "Name", "Title" }) do
            assert(value[name] == nil or type(value[name]) == "string", ("Glass: %s must be a string"):format(name))
        end

        assert(value.Size == nil or typeof(value.Size) == "UDim2", "Glass: Size must be UDim2")
        assert(value.Position == nil or typeof(value.Position) == "UDim2", "Glass: Position must be UDim2")
        assert(value.Parent == nil or typeof(value.Parent) == "Instance", "Glass: Parent must be an Instance")
        assert(value.Visible == nil or type(value.Visible) == "boolean", "Glass: Visible must be a boolean")

        if value.ToggleKey ~= nil then
            assert(
                typeof(value.ToggleKey) == "EnumItem" and value.ToggleKey.EnumType == Enum.KeyCode,
                "Glass: ToggleKey must be an Enum.KeyCode"
            )
        end

        return value
    end

    local function resolveParent(explicit)
        if explicit then
            return explicit
        end

        if type(gethui) == "function" then
            local ok, result = pcall(gethui)
            if ok and typeof(result) == "Instance" then
                return result
            end
        end

        local player = Players.LocalPlayer
        if player then
            return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
        end

        return game:GetService("CoreGui")
    end

    local function viewportSize()
        local camera = workspace.CurrentCamera
        return camera and camera.ViewportSize or nil
    end

    local function clampCenter(center, size)
        local viewport = viewportSize()
        if not viewport then
            return center
        end

        local function clampAxis(position, length, available)
            local half = length * 0.5
            return math.clamp(
                position,
                math.min(half, available * 0.5),
                math.max(available - half, available * 0.5)
            )
        end

        return Vector2.new(
            clampAxis(center.X, size.X, viewport.X),
            clampAxis(center.Y, size.Y, viewport.Y)
        )
    end

    local function titlebarButton(parent, name, image, offset)
        local button = create("ImageButton", {
            Name = name,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, offset, 0.5, 0),
            Size = UDim2.fromOffset(30, 30),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ImageTransparency = 1,
        }, parent)

        create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            Image = image,
            ImageColor3 = Theme.Text,
            ImageTransparency = 0.36,
            ScaleType = Enum.ScaleType.Fit,
        }, button)

        return button
    end

    function Window.new(input)
        local options = validate(input)
        local name = options.Name or options.Title or "Glass"
        local key = options.ToggleKey or Enum.KeyCode.RightControl
        local parent = resolveParent(options.Parent)

        local screen = create("ScreenGui", {
            Name = options.Id or "GlassUI",
            DisplayOrder = 100,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, nil)

        local surface = create("CanvasGroup", {
            Name = "Window",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = options.Position or UDim2.fromScale(0.5, 0.5),
            Size = options.Size or Theme.DefaultSize,
            BackgroundColor3 = Theme.Window,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            GroupTransparency = 0,
        }, screen)

        rounded(surface, Theme.CornerRadius)
        create("UISizeConstraint", { MinSize = Theme.MinimumSize }, surface)

        local header = create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, Theme.HeaderHeight),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 2,
        }, surface)

        local title = create("TextLabel", {
            Name = "Title",
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -108, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Theme.Font,
            Text = name,
            TextSize = 20,
            TextColor3 = Theme.Text,
            TextTransparency = 0.04,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, header)

        local minimize = titlebarButton(header, "Minimize", MINIMIZE_IMAGE, -50)
        minimize.Active = false
        minimize.Selectable = false
        local close = titlebarButton(header, "Close", CLOSE_IMAGE, -10)

        local content = create("Frame", {
            Name = "Content",
            Position = UDim2.fromOffset(0, Theme.HeaderHeight),
            Size = UDim2.new(1, 0, 1, -Theme.HeaderHeight),
            BackgroundColor3 = Theme.Content,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, surface)

        local resize = create("ImageButton", {
            Name = "Resize",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -9, 1, -9),
            Size = UDim2.fromOffset(32, 32),
            BackgroundTransparency = 1,
            ImageTransparency = 1,
            AutoButtonColor = false,
            ZIndex = 5,
        }, surface)

        create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -5, 1, -5),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Image = RESIZE_IMAGE,
            ImageColor3 = Theme.Text,
            ImageTransparency = 0.4,
            ScaleType = Enum.ScaleType.Fit,
        }, resize)

        local self = setmetatable({
            ScreenGui = screen,
            Frame = surface,
            Content = content,
            ToggleKey = key,
            _titleLabel = title,
            _connections = {},
            _pointer = nil,
            _destroyed = false,
            _visible = options.Visible ~= false,
        }, Window)

        local mounted, mountError = pcall(function()
            screen.Parent = parent
        end)
        if not mounted then
            screen:Destroy()
            error(("Glass: could not mount window: %s"):format(tostring(mountError)), 2)
        end

        local function bind(signal, callback)
            local connection = signal:Connect(callback)
            table.insert(self._connections, connection)
        end

        bind(header.InputBegan, function(inputObject)
            if not self._visible then
                return
            end
            local kind = inputObject.UserInputType
            if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
                return
            end
            if inputObject.Position.X >= surface.AbsolutePosition.X + surface.AbsoluteSize.X - 86 then
                return
            end
            self:_beginPointer("drag", inputObject)
        end)

        bind(resize.InputBegan, function(inputObject)
            local kind = inputObject.UserInputType
            if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                self:_beginPointer("resize", inputObject)
            end
        end)

        bind(UserInputService.InputChanged, function(inputObject)
            local pointer = self._pointer
            if not pointer then
                return
            end
            if pointer.Touch then
                if inputObject ~= pointer.Input then
                    return
                end
            elseif inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            self:_movePointer(Vector2.new(inputObject.Position.X, inputObject.Position.Y))
        end)

        bind(UserInputService.InputEnded, function(inputObject)
            local pointer = self._pointer
            if not pointer then
                return
            end
            if pointer.Touch then
                if inputObject == pointer.Input then
                    self:_endPointer()
                end
            elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                self:_endPointer()
            end
        end)

        bind(UserInputService.WindowFocusReleased, function()
            self:_endPointer()
        end)

        bind(UserInputService.InputBegan, function(inputObject, processed)
            if processed or UserInputService:GetFocusedTextBox() then
                return
            end
            if inputObject.KeyCode == self.ToggleKey then
                self:SetVisible(not self._visible)
            end
        end)

        bind(close.Activated, function()
            self:Destroy()
        end)

        surface.Visible = self._visible
        return self
    end

    function Window:_beginPointer(mode, inputObject)
        if self._destroyed or not self._visible or self._pointer then
            return
        end

        local frame = self.Frame
        self._pointer = {
            Mode = mode,
            Input = inputObject,
            Touch = inputObject.UserInputType == Enum.UserInputType.Touch,
            Start = Vector2.new(inputObject.Position.X, inputObject.Position.Y),
            Size = frame.Size,
            Position = frame.Position,
            AbsoluteSize = frame.AbsoluteSize,
            TopLeft = frame.AbsolutePosition,
        }
    end

    function Window:_endPointer()
        self._pointer = nil
    end

    function Window:_movePointer(position)
        local pointer = self._pointer
        if not pointer or self._destroyed then
            return
        end

        local delta = position - pointer.Start
        if pointer.Mode == "drag" then
            local center = clampCenter(pointer.TopLeft + pointer.AbsoluteSize * 0.5 + delta, pointer.AbsoluteSize)
            self.Frame.Position = UDim2.fromOffset(center.X, center.Y)
            return
        end

        local width = math.max(Theme.MinimumSize.X, pointer.AbsoluteSize.X + delta.X)
        local height = math.max(Theme.MinimumSize.Y, pointer.AbsoluteSize.Y + delta.Y)
        local viewport = viewportSize()

        if viewport then
            width = math.min(width, math.max(Theme.MinimumSize.X, viewport.X - pointer.TopLeft.X))
            height = math.min(height, math.max(Theme.MinimumSize.Y, viewport.Y - pointer.TopLeft.Y))
        end

        local changeX = math.round(width - pointer.AbsoluteSize.X)
        local changeY = math.round(height - pointer.AbsoluteSize.Y)

        if changeX == 0 and changeY == 0 then
            return
        end

        self.Frame.Size = UDim2.new(
            pointer.Size.X.Scale, pointer.Size.X.Offset + changeX,
            pointer.Size.Y.Scale, pointer.Size.Y.Offset + changeY
        )

        self.Frame.Position = UDim2.new(
            pointer.Position.X.Scale, pointer.Position.X.Offset + changeX * 0.5,
            pointer.Position.Y.Scale, pointer.Position.Y.Offset + changeY * 0.5
        )
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
        if not value then
            self:_endPointer()
        end
        self._visible = value
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

        self:_endPointer()
        self._destroyed = true
        for _, connection in ipairs(self._connections) do
            connection:Disconnect()
        end
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
        self.Frame = nil
        self.Content = nil
    end

    return Window
end)(Theme)

local Glass = (function(Window)

    local Glass = {}

    function Glass:CreateWindow(options)
        return Window.new(options)
    end

    return table.freeze(Glass)
end)(Window)

return Glass
