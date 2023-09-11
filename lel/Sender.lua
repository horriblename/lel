---@class Sender<Input, Output>
---@field input fun(self, in: `Input`)
---@field output fun(self, out: `Output`)
---@field set_component_parts fun(self, parts: ComponentParts)
---@field private component Component
---@field private component_parts ComponentParts?
local Sender = {}

---@param component Component
---@return Sender
function Sender:new(component)
    local o = {
        component = component,
    }
    self.__index = self
    setmetatable(o, self)

    return o
end

function Sender:set_component_parts(parts)
    if self.component_parts ~= nil then
        error("Sender: attempted to set component_parts a second time")
    end
    if parts == nil then
        error("Sender: attempted to set component_parts as nil")
    end
    self.component_parts = parts
end

function Sender:input(message)
    if message == nil then
        error("Sender: received nil input")
    end
    if self.component_parts == nil then
        error("Sender: trying to send input before component_parts is set")
    end
    self.component:update(message)
    self.component:update_view(self.component_parts.widgets)
end

return Sender
