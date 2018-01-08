# Common style definitions
load "imgs/common.inc"

set output "imgs/edf.eps"

set yrange [0:10]

arm_file_preempt = "data/generated/sabre-EDF-preempt.dat"
arm_file_coop = "data/generated/sabre-EDF-coop.dat"
x86_file_preempt = "data/generated/haswell-EDF-preempt.dat"
x86_file_coop = "data/generated/haswell-EDF-coop.dat"
linux_file = "data/linux-edf.dat"

#set key top left maxrows 3
set key outside top center horizontal maxrows 2
set xlabel "Number of threads"
set ylabel "Time ({/Symbol m}s)"
set grid noxtics noytics
set yrange [0:8.5]
set size 0.8,0.8
# plot arm_file using 1:($4/1000):($6/1000) with errorlines title "ARM"
plot arm_file_preempt using 1:($5/arm_clk):($6/arm_clk) with errorlines title "Sabre-pre", \
     x86_file_preempt using 1:($5/x86_clk):($6/x86_clk) with errorlines title 'x64-pre', \
     arm_file_coop using 1:($5/arm_clk):($6/arm_clk) with errorlines title "Sabre-coop", \
     x86_file_coop using 1:($5/x86_clk):($6/x86_clk) with errorlines title 'x64-coop', \
     linux_file using 1:($4/x86_clk):($5/x86_clk) with errorlines title 'x64-LITMUS'
