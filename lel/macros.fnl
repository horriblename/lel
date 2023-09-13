(local fennel (require :fennel))
(local format string.format)
(local f format)
(local common (require :lel.common))

(fn dbg! [x] (print "\027[31mdbg!\027[0m" (fennel.view x)) x)
(fn tag! [msg x]
  (print (format "(\027[32m%s\027[0m: %s)" msg (fennel.view x)))
  x)

(fn tag_unwrap! [msg ok val]
  (if (= ok false)
      (print (format "\027[31m%s ERR: \027[0m" msg val))
      (print (format "\027[32m%s\027[0m" msg) (fennel.view val)))
  val)

(macro Tag! [msg x]
  `(do
     (print (format "<\027[33m%s\027[0m>" ,msg))
     (local res# ,x)
     (print (format "</\027[33m%s\027[0m: %s>" ,msg (view res#)))
     res#))

(fn errAttributeMissingValue [attr]
  (error (format "mismatched attribute key without value %s" attr)))

(fn errAttrKeyIsSymbol [attr]
  (error (format "attribute keys must be string literal, got a symbol %s" attr)))

(fn apply_attr_pair [widget sender key value]
  "turns input (widget 'key' value) into (widget.key self value)"
  (assert (and (not (sym? key)) (= (type key) :string))
          (format "widget attribute pair must have string literal key, got: %s"
                  (fennel.view key)))
  (let [keypath (icollect [s (common.split key ".")] s)
        code `((. ,widget ,(unpack keypath)) ,widget ,value)]
     {:init code}))

(fn bracket_attr [widget sender func args] ; (assert (sym? func) (format "bracketed function syntax must contain symbol, got literal: %s"
  ;                             (view func)))
  (assert (sym? sender) (format "assertion failed: 'sender' is not sym: this is a bug!"
                                (view sender)))
  (tag! (format "in bracket_attr: func %s; args =>" func) args)
  (case func
    :sender (tag! "bracketed function: sender"
                  (let [apply_attr `(. (require :lel.macro-util)
                                         :apply_attr)
                        [key value] args]
                    (assert (= (length args) 2)
                            (format "[sender] function accepts have 2 arguments, got %d"
                                    (length args)))
                    {:init `(,apply_attr ,widget ,key
                                           ((fn [,(sym func)]
                                              ,value) ,sender))}))
    a (tag! (f "in apply_attr: init upd with singleton func table: %s" func)
            {:init (and (tag! "init" func.init) `(,func.init ,widget ,sender ,(unpack args)))
             :update_view (and (tag! "update_view" func.update_view)
                               `(,func.update_view ,widget ,(unpack args)))})))

(fn build_widget [widget sender ...]
  {:fnl/docstring "Constructs the init and update_view functions of a component from a widget tree"
   :param {:widget [:GTK_Widget "A GTK widget constructor"]
           :sender [:identifier?
                    "Variable of sender object, when building root widget, this is nil"]
           :... "Widget tree tokens"}
   :return {:init :list :update_view :list}}

  (fn apply_attr [widget sender [cons & args]]
    {:fnl/docstring "Apply a macro to generate code in init and update_view.
    cons can be a GTK widget class or bracketed function [funcname]
    The function must have a signature of `fn(widget, ...): [init_code? update_view_code?]`
    "
     :return [:?init_code :?update_view_code]}
    (case cons
      ;; TODO: error messages, rename 
      [[nil]]
      (error "function attribute can't be empty")
      [[f extra]]
      (error (.. "too many function attributes: " (view cons)))
      [[func]]
      (bracket_attr widget sender func args)
      ;; anything else is treated as widget
      w
      (tag! "built nested widget"
            (let [child (gensym :w)
                  {:init child_init :update_view child_upd} 
                  (build_widget child sender (unpack args))]
              {:init `(: ,widget :add 
                         (let [,child (,w {})] ,child_init)) 
              :update_view child_upd}))))

  (fn collect_attrs [widget sender ...]
    "returns [?init_code ?update_view_code]"
    (var prev nil)
    (let [;; ast is [{: init : upd} {: init2 : upd2} ...]
          ast (icollect [_ v (ipairs [...])]
                (tag! (f "with v %s" v)
                      (if (not= prev nil)
                          (tag! (f "prev not nil; (%s %s)" prev v)
                                (let [tmp prev]
                                  (set prev nil)
                                  (apply_attr_pair widget sender tmp v)))
                          (if (list? v)
                              (tag! (f "is list: %s" v)
                                    (apply_attr widget sender v))
                              (if (sym? v) (errAttrKeyIsSymbol v)
                                  (tag! (f "prev nil; pushing to next token: v = %s"
                                           v)
                                        (set prev v)))))))]
      (if (not= prev nil)
          (errAttributeMissingValue prev)
          ;; "zip" ast so we get {:init init_all :update_view upd_all}
          (let [wrap_do (fn [args] (match (length args)
                                     0 nil
                                     1 (. args 1)
                                     _ `(do
                                          ,(unpack args))))
                init_stmts (icollect [_ {: init} (ipairs (tag! :ast ast))]
                                    init)]
            (table.insert init_stmts widget)
            (tag! "collect_attrs res: "
                  {:init (wrap_do init_stmts)
                   :update_view (wrap_do (icollect [_ {: update_view} (ipairs ast)]
                                           update_view))})))))

  (collect_attrs widget sender ...))

(fn defview [name [model] componentTree]
  (let [[rootWidget & attrList] componentTree
        sender (gensym :sender)
        root (gensym :root)
        {: init : update_view} (build_widget root sender (unpack attrList))]
    `(do
       (tset ,name :init_root (fn [,model]
                                (,rootWidget {})))
       (tset ,name :init
             (fn [,model ,root ,sender]
               ,init
               (: (require :lel.ComponentParts) :new nil [])))
       (tset ,name :update_view (fn [,model widgets#]
                                  ,update_view)))))

{: defview : build_widget : apply_attr_pair}

