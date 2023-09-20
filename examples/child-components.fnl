(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local LelApp (require :lel.app))
(import-macros {: defview} :lel)
(local {: watch} (require :lel.state))
(local {:componentModule component} (require :lel.component))

(local format string.format)

(local Counter {:counter 0})
(set Counter.__index Counter)
(fn Counter.new []
  (setmetatable {:counter 0} Counter))

(fn Counter.update [self message]
  (match message
    :increment (tset self :counter (+ self.counter 1))
    :decrement (tset self :counter (- self.counter 1))
    _ (error (.. "update received unkown message: " message))))

(defview Counter
  [model]
  (Gtk.Box (Gtk.VBox {:spacing 5 :hexpand true}
                     (Gtk.Button {:label "+"}
                                 ([sender] :on_clicked.connect
                                           (fn []
                                             (sender:input :increment))))
                     (Gtk.Button {:label "-"}
                                 ([sender] :on_clicked.connect
                                           (fn [_self]
                                             (sender:input :decrement))))
                     (Gtk.Label ([watch] :set_label
                                         #(format "Counter: %d" model.counter))))))

(local App {})

(fn App.update [_self _message])

(defview App
  [model]
  (Gtk.Window {:title "Components Example"}
              (Gtk.VBox {:hexpand true}
                (Gtk.Label {:label :Hello!})
                        ([component] (Counter.new)))))

(local app (LelApp:new :com.github.horriblename.lel.MacroExample))
(app:run App)

