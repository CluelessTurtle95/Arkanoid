vlib work
vlog src/Levels/brickCollision.v
vsim collisionCheck
log {/*}
add wave {/*}

#property wave -radix unsigned 

## force {CLOCK_50} 0 0ns, 1 {1ns} -r 2ns

force {objectA_X_lim} 'd12
force {objectA_Y_lim} 'd6

force {objectB_X_lim} 'd6
force {objectB_Y_lim} 'd6

force {objectA_X} 'd30
force {objectA_Y} 'd35
run 2ns

force {objectB_X} 'd50
force {objectB_Y} 'd50
run 2ns

force {objectB_X} 'd28
force {objectB_Y} 'd28
run 2ns

force {objectB_X} 'd34
force {objectB_Y} 'd40
run 2ns