(local fennel (require :fennel))
(local format string.format)
(local f format)
(local common (require :lel.common))

(fn tag! [msg x]
  ;; still figuring out how to handle this
  (when false
    (print (string.format "(\027[32m%s\027[0m: %s)" msg (view x))))
   x)

(lambda errAttributeMissingValue [attr]
  (error (format "mismatched attribute key without value %s" attr)))

(lambda errAttrKeyIsSymbol [attr]
  (error (format "attribute keys must be string literal, got a symbol %s" attr)))

(lambda apply_attr_pair [widget key value]
  {:fnl/docstring "turns input (widget 'deeply.nested.key' value) into (widget.deeply.nested.key self value)"
   :param/widget sym
   :param/key [string "The key/key-path of the function"]
   :param/value [:any "Argument to pass into the `widget:key` function"]
   :return {:init list}}
  (assert (and (not (sym? key)) (= (type key) :string))
          (format "widget attribute pair must have string literal key, got: %s"
                  (fennel.view key)))
  (let [keypath (icollect [s (common.split key ".")] s)
        code `((. ,widget ,(unpack keypath)) ,widget ,value)]
     {:init code}))

(lambda bracket_func [widget {: sender : widgets}])

(lambda bracket_attr [widget {: sender : widgets} func args] ; (assert (sym? func) (format "bracketed function syntax must contain symbol, got literal: %s"
  {:param/widget sym
   :param/sender :Sender
   :param/widgets table
   :param/func (fn [widget ...])
   :param/args "any[]"}
  ;                             (view func)))
  (assert (sym? sender) (format "assertion failed: 'sender' is not sym: this is a bug!"
                                (view sender)))
  (tag! (format "in bracket_attr: func %s; args =>" func) args)
  (case func
    :sender (tag! "bracketed function: sender"
                  (let [[key value] args]
                    (assert (= (length args) 2)
                            (format "[sender] function accepts have 2 arguments, got %d"
                                    (length args)))
                    {:init (apply_attr_pair widget key `(let [,(sym :sender) ,sender] ,value))}))
    (where a (= (string.sub a 1 1) :!))
      `(do
           (tset ,widgets ,(tostring widget) ,widget)
           ,(macroexpand (sym (string.sub a 2)) 
                         widget 
                    (sym string.format :%s.%s widgets widget)
                   func (unpack args)))
      ;; TODO: extract + docs
    a (tag! (f "bracket_attr calling %s with args %s" func (view args))
            {:init `(if (. ,(sym func) :init) 
                        (do
                          (tset ,widgets ,(tostring widget) ,widget)
                          ((. ,(sym func) :init) 
                           ,widget 
                           {:sender ,sender :widgets ,widgets}
                           ,(unpack args))))
             :update_view `(if (. ,(sym func) :update_view) 
                               ((. ,(sym func) :update_view) 
                                ,(sym (format :%s.%s widgets widget)) 
                                ,(unpack args)))})))

(lambda build_widget [widget context-syms ...]
  {:fnl/docstring "Constructs the init and update_view functions of a component from a widget tree"
   :param {:widget [:GTK_Widget "A GTK widget constructor"]
           :context-syms [{:sender :identifier :widgets :identifier}
                    "Variable of 'sender' and 'widgets'"]
           :... "Widget tree tokens"}
   :return {:init :list :update_view :list}}

  (lambda apply_attr [widget context-syms [cons & args]]
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
      (bracket_attr widget context-syms func args)
      ;; anything else is treated as widget
      w
      (tag! "built nested widget"
            (let [child (gensym :w)
                  {:init child_init :update_view child_upd} 
                  (build_widget child context-syms (unpack args))]
              {:init `(: ,widget :add 
                         (let [,child (,w {})] ,child_init)) 
              :update_view child_upd}))))

  (fn collect_attrs [widget context-syms ...]
    "returns [?init_code ?update_view_code]"
    (var prev nil)
    (let [;; ast is [{: init : upd} {: init2 : upd2} ...]
          ast (icollect [_ v (ipairs [...])]
                (tag! (f "with v %s" v)
                      (if (not= prev nil)
                          (tag! (f "prev not nil; (%s %s)" prev v)
                                (let [tmp prev]
                                  (set prev nil)
                                  (apply_attr_pair widget tmp v)))
                          (if (list? v)
                              (tag! (f "is list: %s" v)
                                    (apply_attr widget context-syms v))
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

  (collect_attrs widget context-syms ...))

(fn defview [name [model] componentTree]
  ;; component context items: model, sender, widgets
  ;; model should be available to init and update_view
  ;; widgets should be available to init and update_view
  ;; sender should be available to init only?
  (let [[rootWidget & attrList] componentTree
        context-syms {:sender (gensym :sender) :widgets (gensym :widgets)}
        root (gensym :root)
        {: init : update_view} (build_widget root context-syms
                                             (unpack attrList))]
    `(do
       (tset ,name :init_root (fn [,model]
                                (,rootWidget {})))
       (tset ,name :init
             (fn [,model ,root ,context-syms.sender]
               (let [,context-syms.widgets {}]
                 ,init
                 (: (require :lel.ComponentParts) :new nil
                    ,context-syms.widgets))))
       (tset ,name :update_view (fn [,model ,context-syms.widgets]
                                  ,update_view)))))

{: defview : build_widget : apply_attr_pair}

