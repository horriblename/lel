---@class ComponentParts<Model>
---@field model Model
---@field widgets table<any, any>
local ComponentParts = {}

---comment
---@param model `Model`
---@param widgets any
function ComponentParts:new(model, widgets)
	local o = {
		model = model,
		widgets = widgets,
	}

	o.__index = self
	setmetatable(o, self)
	return o
end

return ComponentParts
