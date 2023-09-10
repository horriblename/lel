local AppModel = require('lel.app')
local ComponentParts = require('lel.ComponentParts')
local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')

---@class Model : {counter: number}

---@alias Msg nil
-- local Msg = {
-- 	increment = 'increment',
-- 	decrement = 'decrement',
-- }

---@class Example1 : AppModel<Msg, nil, Model>
local App = AppModel:new()

function App:init(window)
    window:set_titlebar(Gtk.HeaderBar {
        show_close_button = true,
        title = "GtkLabel",
        subtitle = "Example 1",
    })

    local box = Gtk.Box { visible = true }
    local btn = Gtk.Button {
        id = 'button',
        label = 'Breach',
        visible = true,
    }

    function btn:on_clicked()
        print('btn clicked!')
    end

    box:add(btn)
end

function App:update(message)
end

function App:update_view(widgets)
    widgets.label.set_label(("Counter: %d"):format(self.state.counter))
end

local app = App:new()
return app:run()
