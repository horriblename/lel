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

---@class AppState
---@field counter integer

---@class Example1 : Component<Msg, nil>
---@field init fun(self, window: any, sender: Sender): ComponentParts
---@field update fun(self, message: Msg)
local App = {
    counter = 0
}

function App:init(window, sender)
    window:set_titlebar(Gtk.HeaderBar {
        show_close_button = true,
        title = "GtkLabel",
        subtitle = "Example 1",
    })

    local box = Gtk.VBox { visible = true }
    local label = Gtk.Label {
        label = ("Counter: %d"):format(self.counter),
        visible = true
    }
    box:pack_end(label, true, true, 5)
    local inc = Gtk.Button {
        id = 'increment-btn',
        label = '+',
        visible = true,
    }

    function inc:on_clicked()
        sender:input(Msg.increment)
    end

    local dec = Gtk.Button {
        id = 'decrement-btn',
        label = '-',
    }

    function dec:on_clicked()
        sender:input(Msg.decrement)
    end

    box:pack_end(inc, true, true, 5)
    box:pack_end(dec, true, true, 5)

    window:add(box)

    return ComponentParts:new(nil, { label = label })
end

function App:update(message)
    if message == Msg.increment then
        self.counter = self.counter + 1
    elseif message == Msg.decrement then
        self.counter = self.counter - 1
    end
end

function App:update_view(widgets)
    widgets.label:set_label(("Counter: %d"):format(self.counter))
end

local lapp = LelApp:new()
return lapp:run(App)
