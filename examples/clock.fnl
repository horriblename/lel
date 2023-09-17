(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local LelApp (require :lel.app))
(import-macros {: defview} :lel)
(local GLib (lgi.require :GLib :2.0))
(local Pango (lgi.require :Pango :1.0))
(local apply_attr (. (require :lel.macro-util) :apply_attr))

(local format string.format)

;; {:init fun(widget: Gtk.Widget, sender: Sender, setter: string, f: fun(): any)
;;  :update_view (same as above)}
(local watch {:init (lambda [widget sender setter f]
                      (apply_attr widget setter (f)))
              :update_view (lambda [widget setter f]
                             (apply_attr widget setter (f)))})

(local App {:time :0})

(fn App.update [self message]
  (print :time message.time)
  (match message
    {: time} (tset self :time time)
    _ (error (.. "update received unkown message: " message))))

(local clock {:init (lambda [_ {: sender} ?interval]
                      (let [interval (or ?interval 1)]
                        (GLib.timeout_add_seconds GLib.PRIORITY_DEFAULT
                                                  interval
                                                  (fn []
                                                    (sender:input (os.date "%H:%M:%S"
                                                                           (os.time)))
                                                    true))))})

; (local attrs (doto (Pango.AttrList) #($:insert (Pango.attr_scale_new 3))))
(local attrs (doto (Pango.AttrList)
               (: :insert (Pango.attr_scale_new 3))))

(defview App
  [model]
  (Gtk.Window :set_title "Example App" ([clock] 1)
              (Gtk.VBox :set_spacing 5
                        (Gtk.Label :set_attributes attrs
                                   ([watch] :set_label
                                            #(format "Time: %s" model.time))))))

(local app (LelApp:new :com.github.horriblename.lel.clock))
(app:run App)

