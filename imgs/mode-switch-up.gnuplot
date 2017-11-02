# Common style definitions
load "imgs/common.inc"
set terminal postscript enhanced
set output "imgs/mode-switch-up.eps"

arm_hi_cold = "data/generated/sabre-up-hi-cold.dat"
arm_hi_hot = "data/generated/sabre-up-hi-hot.dat"
x86_hi_cold = "data/generated/haswell-up-hi-cold.dat"
x86_hi_hot = "data/generated/haswell-up-hi-hot.dat"
arm_ul_cold = "data/generated/sabre-ul-ul-cold.dat"
arm_ul_hot = "data/generated/sabre-ul-ul-hot.dat"
x86_ul_cold = "data/generated/haswell-ul-ul-cold.dat"
x86_ul_hot = "data/generated/haswell-ul-ul-hot.dat"

set key top left vertical maxrows 4
set xlabel "Number of HI threads switched"
set ylabel "Time ({/Symbol m}s)"
set xrange [0:32]

plot arm_hi_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title "Cold HI ARM", \
     arm_hi_hot using 1:($2/arm_clk):($3/arm_clk) with errorlines title "Hot HI ARM", \
     x86_hi_hot using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Hot HI x64', \
     x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Cold HI x64', \
     arm_ul_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title "Cold UL ARM", \
     arm_ul_hot using 1:($2/arm_clk):($3/arm_clk) with errorlines title "Hot UL ARM", \
     x86_ul_hot using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Hot UL x64', \
     x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Cold UL x64'
