;; Demonstrates trackers and listening on external commands (I should really split these up)
(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))
(local LelApp (require :lel.app))
(import-macros {: defview} :lel)
(local GLib (lgi.require :GLib :2.0))
(local Pango (lgi.require :Pango :1.0))
(local {: tracker : track} (require :lel.state))

(local format string.format)

;; watch command output
(local ffi (require :ffi))
(ffi.cdef "int fileno(struct FILE* stream);")
(local getfd ffi.C.fileno)

(lambda startListen [sender command ?transformer]
  (let [fd (getfd (io.popen command :r))
        io_channel (GLib.IOChannel.unix_new fd false)
        f (or ?transformer #$)
        on_data_available (fn [ch _cond]
                            (-> (select 2 (ch:read_line))
                                (string.match "(.-)[%s]*$")
                                f
                                sender:input)
                            true)]
    (GLib.io_add_watch io_channel GLib.PRIORITY_DEFAULT GLib.IOCondition.IN
                       on_data_available ; nil 
                       ;; doesn't seem necessary
                       ; #(out:close)
                       )))

(local listen
       {:init (lambda [_ {: sender} command ?transformer]
                (startListen sender command ?transformer))})

(local attrs (doto (Pango.AttrList)
               (: :insert (Pango.attr_scale_new 3))))

;; App

(local App {:time :0 :output ""})

(set App.tracker (tracker.new App))

(defview App
  [model]
  (Gtk.Window :set_title "Example App"
              ([listen] "for i in 1 2 3 4 5; do echo $i; sleep $i; done" #{:output $})
              (Gtk.VBox :set_spacing 5
                        (Gtk.Label :set_attributes attrs
                                   ([track] #(model.tracker:changed :output)
                                            :set_label
                                            #(format "Last Output: %s"
                                                     model.output))))))

(fn App.update [self message]
  (self.tracker:reset self)
  (match message
    {: output} (self.tracker:set :output output)
    _ (error (.. "update received unkown message: "
                 ((. (require :fennel) :view) message)))))

(local app (LelApp:new :com.github.horriblename.lel.test))
(app:run App)

