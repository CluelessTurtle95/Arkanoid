vlib work
vlog Paddle.v
vsim -L altera_mf_ver paddleDatapath
log {/*}
add wave {/*}


force {clk} 0 0ns, 1 {1ns} -r 2ns

force {reset} 1
run 6ns

force {reset} 0
run 2ns

force {moveDir} 10
force {enable} 1
run 200ns