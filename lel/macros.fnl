(local fennel (require :fennel))
(fn defview [name [model sender] tree]
  (let [[rootWidget rootConfig & children] tree
        {: build_widget} (require :lel.macros.build_widget)]
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


{: defview}

