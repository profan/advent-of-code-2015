#!/usr/local/bin/apl -s

cmds ← ('<' '>' '^' 'v')
dirs ← ((¯1 0) (1 0) (0 ¯1) (0 1))

in ← ⍞ 
len ← ⍴ in
hlen ← { ⍵ ÷ 2 } ⍴ in
ranks ← ⍉ (hlen, 2) ⍴ (1, len) ⍴ in ⍝ divide into two rows, odds and evens
houses ← { (0 0) , { ++\⍵ } { dirs[cmds ⍳ ⍵] } ⍵ }
allhouses ← ∪ , { houses ranks[⍵;] } (1 2)

⍴ allhouses ~ 0

)OFF
