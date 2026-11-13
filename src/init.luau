local Window = require(script.Parent.Window)

local Glass = {}

function Glass:CreateWindow(options)
    return Window.new(options)
end

return table.freeze(Glass)
