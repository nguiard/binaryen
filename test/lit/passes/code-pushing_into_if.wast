;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --code-pushing -S -o - | filecheck %s

(module
  ;; CHECK:      (func $if-nop (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-nop (param $p i32)
    (local $x i32)
    ;; The set local is not used in any if arm; do nothing.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (nop)
    )
  )

  ;; CHECK:      (func $if-nop-nop (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-nop-nop (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (nop)
      (nop) ;; add a nop here compared to the last testcase (no output change)
    )
  )

  ;; CHECK:      (func $if-use (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use (param $p i32)
    (local $x i32)
    ;; The set local is used in one arm and nowhere else; push it there.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
    )
  )

  ;; CHECK:      (func $if-use-nop (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-nop (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
      (nop) ;; add a nop here compared to the last testcase (no output change)
    )
  )

  ;; CHECK:      (func $if-else-use (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-else-use (param $p i32)
    (local $x i32)
    ;; The set local is used in one arm and nowhere else; push it there.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (nop)
      (drop (local.get $x))
    )
  )

  ;; CHECK:      (func $unpushed-interference (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local $y i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $y
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $unpushed-interference (param $p i32)
    (local $x i32)
    (local $y i32)
    (local.set $x (i32.const 1))
    ;; This set is not pushed (as it is not used in the if) and it will then
    ;; prevent the previous set of $x from being pushed, since we can't push a
    ;; set of $x past a get of it.
    (local.set $y (local.get $x))
    (if
      (local.get $p)
      (drop (local.get $x))
    )
  )

  ;; CHECK:      (func $if-use-use (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-use (param $p i32)
    (local $x i32)
    ;; The set local is used in both arms, so we can't do anything.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
      (drop (local.get $x))
    )
  )

  ;; CHECK:      (func $if-use-after (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-after (param $p i32)
    (local $x i32)
    ;; The use after the if prevents optimization.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )

  ;; CHECK:      (func $if-use-after-nop (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-after-nop (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
      (nop) ;; add a nop here compared to the last testcase (no output change)
    )
    (drop (local.get $x))
  )

  ;; CHECK:      (func $if-else-use-after (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-else-use-after (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (nop)
      (drop (local.get $x)) ;; now the use in the if is in the else arm
    )
    (drop (local.get $x))
  )

  ;; CHECK:      (func $if-use-after-unreachable (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-after-unreachable (param $p i32)
    (local $x i32)
    ;; A use after the if is ok as the other arm is unreachable.
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (drop (local.get $x))
      (return)
    )
    (drop (local.get $x))
  )

  ;; CHECK:      (func $if-use-after-unreachable-else (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-use-after-unreachable-else (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 1))
    (if
      (local.get $p)
      (return) ;; as above, but with arms flipped
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )

  ;; CHECK:      (func $optimize-many (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local $y i32)
  ;; CHECK-NEXT:  (local $z i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (local.set $z
  ;; CHECK-NEXT:     (i32.const 3)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $z)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $y
  ;; CHECK-NEXT:     (i32.const 2)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $y)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $optimize-many (param $p i32)
    (local $x i32)
    (local $y i32)
    (local $z i32)
    ;; Multiple things we can push, to various arms.
    (local.set $x (i32.const 1))
    (local.set $y (i32.const 2))
    (local.set $z (i32.const 3))
    (if
      (local.get $p)
      (block
        (drop (local.get $x))
        (drop (local.get $z))
      )
      (drop (local.get $y))
    )
  )

  ;; CHECK:      (func $past-other (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local $t i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (local.get $t)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $past-other (param $p i32)
    (local $x i32)
    (local $t i32)
    ;; We can push this past the drop after it.
    (local.set $x (local.get $t))
    (drop (i32.const 2))
    (if
      (local.get $p)
      (drop (local.get $x))
    )
  )

  ;; CHECK:      (func $past-other-no (param $p i32)
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (local $t i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (local.get $t)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.tee $t
  ;; CHECK-NEXT:    (i32.const 2)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $p)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $past-other-no (param $p i32)
    (local $x i32)
    (local $t i32)
    ;; We cannot push this due to the tee, which interferes with us.
    (local.set $x (local.get $t))
    (drop (local.tee $t (i32.const 2)))
    (if
      (local.get $p)
      (drop (local.get $x))
    )
  )
)
