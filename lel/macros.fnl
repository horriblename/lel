(local lgi (require :lgi))
(local Gtk (lgi.require :Gtk :3.0))

(fn strip_prefix [str prefix]
  (let [plen (length prefix)]
    (if (= (str:sub 0 plen) prefix)
        (str:sub (+ plen 1)))))

(strip_prefix :connect_on_clicked :connect_)
(strip_prefix :connect_on_clicked :conn_)

(macro apply_attr [widget key value]
  (if (not= (string.find key :^connect_) nil)
      `(tset ,widget ,(key:sub (+ (length :connect_) 1)) ,value)
      `((: ,widget ,key) ,value)))

(local btn (Gtk.Button {}))
;; pass
(macrodebug (apply_attr btn :set_label :hi))
(macrodebug (apply_attr btn :connect_on_clicked
                        (fn [self] (sender.input :increment))))

(macro build_widget [widget attrs ...]
  (assert-compile (table? attrs) "expected table for attrs" attrs)
  (let [apply_attr (fn [widget key value]
                     (if (not= (string.find key :^connect_) nil)
                         `(tset ,widget ,(key:sub (+ (length :connect_) 1))
                                ,value)
                         `((: ,widget ,key) ,value)))
                   collect_attrs (fn [widget attrs]
                                   (icollect [k v (pairs attrs)]
                                     (apply_attr widget k v)))
                   do_attrs (fn [widget attrs]
                                 `(do ,(unpack (collect_attrs widget attrs))))
                   apply_attrs (fn [widget attrs]
                                 `(let [w# (,widget {})]
                                    ,(do_attrs `w# attrs)
                                    w#))]
    (apply_attrs widget attrs)))

(macrodebug (build_widget Gtk.Button
                          {:set_label "+"
                           :set_use_underline true
                           :connect_on_clicked (fn [self] (print :clicked))}))

(fn view [name [model sender] tree]
  `(fn ,name.init))

