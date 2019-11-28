vlib work
vlog Arkanoid.v
vsim Control
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {1ns} -r 2ns
force {go} 1
force {reset} 1
run 4ns

force {reset} 0

# NO MOVE - DRAW TEST
force {moveInputLeft} 0
force {moveInputRight} 0
force {paddleDrawEnd} 0
force {screenDrawEnd} 0
run 20ns

# MOVE LEFT - DRAW TEST
force {reset} 1
run 4ns

force {reset} 0

force {moveInputLeft} 1
force {moveInputRight} 0
force {paddleDrawEnd} 0
force {screenDrawEnd} 0
run 20ns

force {moveInputLeft} 0
force {moveInputRight} 0
force {paddleDrawEnd} 0
force {screenDrawEnd} 1
run 20ns
