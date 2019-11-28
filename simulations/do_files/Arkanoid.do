vlib work
vlog Arkanoid.v 
vlog PaddleMem.v
vlog PaddleMem_bb.v
vlog BackgroundMem.v
vlog BackgroundMem_bb.v
vsim Game
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {1ns} -r 2ns
force {go} 1
force {reset} 1
run 4ns
force {reset} 0
run 2ns

force {moveInputLeft} 0
force {moveInputRight} 0
run 20000ns


force {moveInputLeft} 1
force {moveInputRight} 0
run 20000ns