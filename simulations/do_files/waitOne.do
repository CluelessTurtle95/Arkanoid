vlib work
vlog src/Levels/brickCollision.v
vsim halfclk
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {1ns} -r 2ns

force {reset} 1
run 2ns

force {reset} 0
run 2ns
#force {brickBallCollide} 0 0ns, 1 {1ns} -r 2ns

run 10ns
#force {brickBallCollide} 0
#run 5ns

#force {brickBallCollide} 1
#run 2ns
#force {brickBallCollide} 0
#run 6ns