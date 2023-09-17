(local {: apply_attr} (require :lel.macro-util))

;; use weak references
(local tracker {:__mode :v})

(lambda tracker.new [model]
  (set tracker.__index tracker)
  (doto {:changelist {} : model}
    (setmetatable tracker)))

(lambda tracker.set [self key value]
  "sets model.key to value, if the new value differs from the old one, mark this key as changed 
and return true, otherwise return false"
  (if (= (. self.model key) value)
      false
      (do
        (tset self.changelist key true)
        (tset self.model key value)
        true)))

(lambda tracker.reset [self]
  (set self.changelist {}))

(lambda tracker.changed [self key]
  "returns true if a tracking change model.key was made (via tracker.set), false otherwise"
  (or (. self.changelist key) false))

;; a bracket function
(local track {:init (fn [widget _sender _cond setter f]
         (apply_attr widget setter (f)))
 :update_view (fn [widget cond setter f]
                (when (cond)
                (apply_attr widget setter (f))))})

;; sets the value to result of (f) on every update
(local watch {:init (lambda [widget sender setter f]
                      (apply_attr widget setter (f)))
              :update_view (lambda [widget setter f]
                             (apply_attr widget setter (f)))})

{: tracker : track : watch}
