(macro build [widget attrs ...]
  (print widget attrs) ; (assert-compile (table? attrs) "expected table for attrs" attrs)
  (let [apply_attr (fn [widget key value]
                     (print :apply_attr key value)
                     (if (not= (string.find key :^connect_) nil)
                         `(tset ,widget
                                ,(string.sub key (+ (length :connect_) 1))
                                ,value)
                         `((: ,widget ,key) ,value)))
        collect_attrs (fn [widget attrs]
                        (print :collect_attrs)
                        (icollect [k v (pairs attrs)]
                          (do
                            (print k v)
                            (apply_attr widget k v))))
        do_attrs (fn [widget attrs]
                   (print :do_attrs)
                   `(do
                      ,(unpack (collect_attrs widget attrs))))]
    (fn build_widget [widget attrs ...]
      `(let [w# (,widget {})]
         ,(do_attrs `w# attrs)
         ,(unpack (icollect [_ child (ipairs [...])]
                    `(w#:add ,(build_widget (unpack child)))))
         w#))

    (build_widget widget attrs ...)))


