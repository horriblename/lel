(fn build_widget [widget attrs ...]

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
    (assert-compile (table? attrs) "expected table for attrs" attrs)
    `(let [w# (,widget {})]
       ,(do_attrs `w# attrs)
       (do ,(unpack (icollect [_ child (ipairs [...])]
                  `(w#:add ,(build_recursively (unpack child))))))
       w#))

  (build_recursively widget attrs ...))

(fn defview [name [model sender] tree]
  (let [[rootWidget rootConfig & children] tree
        {: build_widget} (require :lel.macros)]
    `(do
       (tset ,name :init_root
             (fn [self#]
               ,(build_widget rootWidget rootConfig)))
       (tset ,name :init
             (fn [self# window# ,sender]
               ,(unpack (icollect [_ child (ipairs children)]
                          `(window#:add ,(build_widget (unpack child)))))
               (: (require :lel.ComponentParts) :new nil [])))
       (tset ,name :update_view (fn [self# widgets#])))))

{: defview : build_widget}

