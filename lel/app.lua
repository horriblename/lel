---:init, :update, and :update_view must be implemented by derived classes
---@class Component<Input, Output>
---@field init_root fun(): any Accepts a Gtk.Application and returns a Gtk.Window
---@field init fun(init: Component, root: any, sender: Sender): ComponentParts Initialize and add widgets to the window
---@field update fun(self, message: `Input`): `Output`
---@field update_view fun(self, widgets: table)

---@class LelApp
---@field app any Gtk.Application instance
local LelApp = {}

---Returns the global main application instance
---@return any app Gtk.Application instance
function LelApp.main_app()
    if not _G.lel_main_application then
        local Gtk = require('lgi').require('Gtk')
        _G.lel_main_application = Gtk.Application {}
    end
    return _G.lel_main_application
end

---@param app_id string
---@return LelApp
function LelApp:new(app_id)
    if app_id == nil then
        error("LelApp.new: missing argument app_id")
    end
    local o = {
        app = self.main_app()
    }
    o.app:set_application_id(app_id)
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param app any Gtk.Application instance
---@return LelApp
function LelApp:from_app(app)
    local o = { app = app }
    setmetatable(o, self)
    self.__index = self
    return o
end

---starts the Gtk app
---@param component Component
---@return unknown
function LelApp:run(component)
    local Sender = require('lel.Sender')

    local app = self.app

    function app:on_activate()
        local window = component.init_root()
        app:add_window(window)
        local sender = Sender:new(component)
        local parts = component:init(window, sender)
        if parts == nil then
            error("init function return nil component part")
        end
        sender:set_component_parts(parts)

        window:show_all()
    end

    local res = app:run()
    return res
end

return LelApp
