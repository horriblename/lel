---@module "lel.ComponentParts"

---:init, :update, and :update_view must be implemented by derived classes
---@class AppModel<Msg, Cmd, State>
---@field state `State`
---@field componentParts ComponentParts
---@field msgQueue `Msg`[]
---@field private init_root fun(self, app: any): any Accepts a Gtk.Application and returns a Gtk.Window
---@field private init fun(self, window: any): ComponentParts, `Msg`?, table Initialize and add widgets to the window; third return
---@field private update fun(self, message: `Msg`): `Cmd`
---@field private update_view fun(self, widgets: any)
local AppModel = {}

---@return AppModel
function AppModel:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param app any A Gtk.Application
---@return any window The initial Gtk.Window
function AppModel.init_root(app)
    local Gtk = require('lgi').require('Gtk', '3.0')
    return Gtk.ApplicationWindow({
        type = Gtk.WindowType.TOPLEVEL,
        title = "Example app",
        application = app,
    })
end

function AppModel:init(window)
    error("unimplemented")
end

function AppModel:update(message)
    error("unimplemented")
end

function AppModel:update_view(widgets)
    error("unimplemented")
end

---starts the Gtk app
function AppModel:run()
    local appModel = self:new()
    local lgi = require('lgi')
    local Gtk = lgi.require('Gtk', '3.0')

    local app = Gtk.Application({
        application_id = "com.github.horriblename.example",
    })

    print('set on_activate')
    function app:on_activate()
        local window = appModel.init_root()
        app:add_window(window)
        appModel:init(window)
        -- window:set_visible(true)
        window:show_all()
    end

    print('app:run')
    local res = app:run()
    print('done')
    return res
end

return AppModel
