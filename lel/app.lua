---:init, :update, and :update_view must be implemented by derived classes
---@class Component<Input, Output>
---@field componentParts ComponentParts
---@field init_root fun(self, app: any): any Accepts a Gtk.Application and returns a Gtk.Window
---@field init fun(self, window: any, sender: Sender): ComponentParts Initialize and add widgets to the window
---@field update fun(self, message: `Input`): `Output`
---@field update_view fun(self, widgets: any)


---@class LelApp
local LelApp = {}

---@return LelApp
function LelApp:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param app any A Gtk.Application
---@return any window The initial Gtk.Window
local function default_init_root(app)
    local Gtk = require('lgi').require('Gtk', '3.0')
    return Gtk.ApplicationWindow({
        type = Gtk.WindowType.TOPLEVEL,
        title = "Example app",
        application = app,
    })
end


---starts the Gtk app
---@param component Component
---@return unknown
function LelApp:run(component)
    local lgi = require('lgi')
    local Gtk = lgi.require('Gtk', '3.0')
    local Sender = require('lel.Sender')

    local app = Gtk.Application({
        application_id = "com.github.horriblename.example",
    })

    print('set on_activate')
    function app:on_activate()
        local window = (component.init_root or default_init_root)()
        app:add_window(window)
        local sender = Sender:new(component)
        local parts = component:init(window, sender)
        if parts == nil then
            error("init function return nil component part")
        end
        sender:set_component_parts(parts)

        window:show_all()
    end

    print('app:run')
    local res = app:run()
    print('done')
    return res
end

return LelApp
