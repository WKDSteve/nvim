;; extends

; `{ … }` of a struct literal is not a `block`, and neither are array or tuple
; expressions.
(struct_expression) @block.outer
(array_expression) @block.outer
(tuple_expression) @block.outer

; The body of a `match` is a `match_block` and the bodies of `impl`, `trait`
; and `mod` are `declaration_list`s, none of them a `block`: without these the
; climb skips the match and stops at the `fn`.
(match_expression) @block.outer
(impl_item) @block.outer
(trait_item) @block.outer
(mod_item) @block.outer
