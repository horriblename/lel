local LelApp = require('lel.app')
local ComponentParts = require('lel.ComponentParts')
local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')

---@class Model : {counter: number}

---@enum
local Msg = {
    increment = 'increment',
    decrement = 'decrement',
}

---@class Example1 : Component<Msg, nil>
local App = {
    counter = 0,
    widgets = {}, -- TODO: remove
}

function App:init(window, sender)
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
    -- TODO: don't use self.widgets
    -- self.widgets.label.set_label(("Counter: %d"):format(self.counter))
end

local lapp = LelApp:new()
return lapp:run(App)
