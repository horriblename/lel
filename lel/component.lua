local componentModule = {}
local Sender = require('lel.Sender')

---comment
---@param widget any
---@param component_context {sender: Sender, widgets: table}
---@param Component Component
function componentModule.init(widget, component_context, Component)
    local sender = Sender:new(Component, component_context.sender)
    local root = Component:init_root()
    local parts = Component:init(root, sender)
    sender:set_component_parts(parts)

    widget:add(root)
    widget:show_all()
end

return { componentModule = componentModule }
