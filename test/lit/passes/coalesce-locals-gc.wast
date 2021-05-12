;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --coalesce-locals -all -S -o - \
;; RUN:   | filecheck %s

(module
 ;; CHECK:      (func $test-dead-get-non-nullable (param $0 dataref)
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (local.get $0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $test-dead-get-non-nullable (param $func (ref data))
  (unreachable)
  (drop
   ;; A useless get (that does not read from any set, or from the inputs to the
   ;; function). Normally we replace such gets with nops as best we can, but in
   ;; this case the type is non-nullable, so we must leave it alone.
   (local.get $func)
  )
 )
)