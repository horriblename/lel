(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local ComponentParts (require :lel.ComponentParts))
(local LelApp (require :lel.app))
(import-macros {: defview} :lel.macros)
(local apply_attr (. (require :lel.macro-util) :apply_attr))

(local format string.format)

;; {:init fun(widget: Gtk.Widget, sender: Sender, setter: string, f: fun(): any)
;;  :update_view (same as above)}
(local watch {:init (lambda [widget sender setter f]
                      (apply_attr widget setter (f)))
              :update_view (lambda [widget setter f]
                             (apply_attr widget setter (f)))})

(local App {:counter 0})

(fn App.update [self message]
  (match message
    :increment (tset self :counter (+ self.counter 1))
    :decrement (tset self :counter (- self.counter 1))
    _ (error (.. "update received unkown message: " message))))

(defview App
  [model]
  (Gtk.Window :set_title "Example App"
              (Gtk.VBox :set_spacing 5
                        (Gtk.Button :set_label "+"
                                    ([sender] :on_clicked.connect
                                              (fn [self]
                                                (sender:input :increment))))
                        (Gtk.Button :set_label "-"
                                    ([sender] :on_clicked.connect
                                              (fn [self]
                                                (sender:input :decrement))))
                        (Gtk.Label ([watch] :set_label
                                            #(format "Counter: %d" App.counter))))))

(local app (LelApp:new))
(app:run App)

