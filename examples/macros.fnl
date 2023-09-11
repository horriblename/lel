(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local ComponentParts (require :lel.ComponentParts))
(local LelApp (require :lel.app))
(import-macros {: defview} :lel.macros)

(local format string.format)

(local App {:counter 0})

(fn App.update [self message]
  (match message
    :increment (tset self :counter (+ self.counter 1))
    :decrement (tset self :counter (- self.counter 1))
    _ (error "update received unkown message")))

(defview App
  [model sender]
  (Gtk.Window {:set_title "Example App"}
              (Gtk.Box {;:set_orientation Gtk.Orientation.Vertical
                        :set_spacing 5}
                       (Gtk.Button {:set_label "+"
                                    :connect_on_clicked (fn [self]
                                                          (sender:input :increment))})
                       (Gtk.Button {:set_label "-"
                                    :connect_on_clicked (fn [self]
                                                          (sender:input :decrement))})
                       (Gtk.Label {:set_label (watch #(format "Counter: %d" $1)
                                                     model.counter)}))))

(local app (LelApp:new))
(app:run App)

