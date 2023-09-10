(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local ComponentParts (require :lel.ComponentParts))
(local LelApp (require :lel.app))

(local format string.format)

(local App {:counter 0})

(fn App.init [self window sender]
  (do
    (window:set_titlebar (Gtk.HeaderBar {:show_close_button true
                                         :title "Counter Example"}))
    (let [box (Gtk.VBox {})
          label (Gtk.Label {:label (format "Counter: %d" self.counter)})
          incBtn (Gtk.Button {:id :increment-btn :label "+"})
          decBtn (Gtk.Button {:id :decrement-btn :label "-"})]
      (do
        (fn incBtn.on_clicked [self] (sender:input :increment))
        (fn decBtn.on_clicked [self] (sender:input :decrement))

        (box:add label)
        (box:add incBtn)
        (box:add decBtn)
        (window:add box)
        (ComponentParts:new nil {: label})))))

(fn App.update [self message]
  (match message
    :increment (tset self :counter (+ 1 self.counter))
    :decrement (tset self :counter (- 1 self.counter))
    _ (error "received unkown message")))

(fn App.update_view [self widgets]
  (widgets.label:set_label (format "Counter: %d" self.counter)))

(local lapp (LelApp:new))
(lapp:run App)

