vlib work
vlog Paddle.v
vsim paddleMovement
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {1ns} -r 2ns

# left 2'b11 , right 2'b01, noMove 2'b10

# NO MOVE
force {reset} 1
run 4ns
force {reset} 0
run 2ns

force {moveDir} 10
run 30ns

# LEFT
force {reset} 1
run 4ns
force {reset} 0
run 2ns

force {moveDir} 11
run 30ns

# RIGHT
force {reset} 1
run 4ns
force {reset} 0
run 2ns

force {moveDir} 01
run 30ns