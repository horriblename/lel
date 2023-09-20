---@class Sender<Input, Output>
---@field input fun(self, in: `Input`)
---@field output fun(self, out: `Output`)
---@field set_component_parts fun(self, parts: ComponentParts)
---@field private component Component
---@field private component_parts ComponentParts?
---@field private out_pipe Sender?
local Sender = {}

---@param component Component
---@param out_pipe Sender?
---@return Sender
function Sender:new(component, out_pipe)
    local o = {
        component = component,
        out_pipe = out_pipe,
    }
    self.__index = self
    self.__mode = 'v'
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

function Sender:output(message)
    if self.out_pipe == nil then
        error("Sender: attempted to send output to nil object (output() may only be used by nesetd components)")
    end
    self.out_pipe:input(message)
end

return Sender
