#!/usr/local/bin/apl -s

'Day 3: Perfectly Spherical Houses in a Vacuum'

i ← (0 0)
cmds ← ('<' '>' '^' 'v')
dirs ← ((¯1 0) (1 0) (0 ¯1) (0 1))
set ← i { ⍺ ,+/⍵ ⍺ ++/⍵ } { dirs[ti] ⊣ ti ← cmds ⍳ ⍵ } ⍞

set
i

)OFF
