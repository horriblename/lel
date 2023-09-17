(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local LelApp (require :lel.app))
(local {: watch} (require :lel.state))
(import-macros {: defview} :lel)
(local GLib (lgi.require :GLib :2.0))
(local Pango (lgi.require :Pango :1.0))

(local format string.format)

(local App {:time :0})

(fn App.update [self message]
  (match message
    {: time} (tset self :time time)
    _ (error (.. "update received unkown message: " message))))

(local clock {:init (lambda [_ {: sender}]
                      (let [interval 1
                            wrap #{:time $}]
                        (GLib.timeout_add_seconds GLib.PRIORITY_DEFAULT
                                                  interval
                                                  (fn []
                                                    (->> (os.time)
                                                         (os.date "%H:%M:%S")
                                                         (wrap)
                                                         (sender:input))
                                                    true))))})

; (local attrs (doto (Pango.AttrList) #($:insert (Pango.attr_scale_new 3))))
(local attrs (doto (Pango.AttrList)
               (: :insert (Pango.attr_scale_new 3))))

(defview App
  [model]
  (Gtk.Window :set_title "Example App" ([clock])
              (Gtk.VBox :set_spacing 5
                        (Gtk.Label :set_attributes attrs
                                   ([watch] :set_label
                                            #(format "Time: %s" model.time))))))

(local app (LelApp:new :com.github.horriblename.lel.clock))
(app:run App)

