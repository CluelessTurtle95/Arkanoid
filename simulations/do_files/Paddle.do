vlib work
vlog Paddle.v
vsim Paddle
log {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {1ns} -r 2ns

force {KEY[0]} 0
run 6ns

force {KEY[0]} 1
run 200ns