# Common style definitions
load "imgs/common.inc"
#set size 0.47,0.27

set output "imgs/smp.eps"

x86_file = "data/generated/smp-haswell.dat"
arm_file = "data/generated/smp-sabre.dat"

set key top left vertical maxrows 4 maxcols 1
#set key outside top center horizontal maxrows 1
set xlabel "Cores"
set ylabel "IPC Throughput "
#set yrange [0:11]
#set y2range [0:100]
#set y2label "CPU utilisation (%)"
#set ytics nomirror
#set y2tics

plot x86_file using ($1):($2) title "baseline-500" with lines, \
     x86_file using ($1):($3) title "rt-500" with lines
