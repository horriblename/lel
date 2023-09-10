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
		error("attempted to set component_parts on Sender a second time")
	end
	self.component_parts = parts
end

function Sender:input(message)
	if self.component_parts == nil then
		error("trying to send input before component_parts is set")
	end
	self.component:update(message)
	self.component:update_view(self.component_parts.widgets)
end

return Sender
