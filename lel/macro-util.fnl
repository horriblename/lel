(local common (require :lel.common))

(lambda apply_attr [widget key value]
  "for a given key string \"deeply.nested.key\", execute (widget.deeply.nested:key value)"
  (let [keypath (icollect [s (common.split key ".")] s)]
    ((. widget (unpack keypath)) widget value)))

{: apply_attr}
