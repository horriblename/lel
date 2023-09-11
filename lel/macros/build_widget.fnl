(fn build_widget [widget attrs ...]
  (assert-compile (table? attrs) "expected table for attrs" attrs)

  (fn apply_attr [widget key value]
    (if (not= (string.find key :^connect_) nil)
        `(tset ,widget ,(string.sub key (+ (length :connect_) 1)) ,value)
        `(: ,widget ,key ,value)))

  (fn collect_attrs [widget attrs]
    (icollect [k v (pairs attrs)]
      (do
        (apply_attr widget k v))))

  (fn do_attrs [widget attrs]
    `(do
       ,(unpack (collect_attrs widget attrs))))

  (fn build_recursively [widget attrs ...]
    `(let [w# (,widget {})]
       ,(do_attrs `w# attrs)
       ,(unpack (icollect [_ child (ipairs [...])]
                  `(w#:add ,(build_recursively (unpack child)))))
       w#))

  (build_recursively widget attrs ...))

{: build_widget}
