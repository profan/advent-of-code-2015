#!/usr/local/bin/apl -s

cmds ← ('<' '>' '^' 'v')
dirs ← ((¯1 0) (1 0) (0 ¯1) (0 1))

in ← ⍞ 
len ← { ⍵ ÷ 2 } ⍴ in
ranks ← (len, 2) ⍴ in ⍝ divide into two rows, odds and evens
houses ← { (0 0) , { ++\⍵ } { dirs[ti] ⊣ ti ← cmds ⍳ ⍵ } ⍵ }
allhouses ← ∪ , { houses ranks[⍵;] } (1 2)

ranks
allhouses
⍴ allhouses

)OFF
