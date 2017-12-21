# Common style definitions
load "imgs/common.inc"
#set size 0.47,0.27

set output "imgs/smp.eps"

x86_file = "data/generated/smp-haswell.dat"
arm_file = "data/generated/smp-sabre.dat"

#set key bottom right vertical maxrows 4 maxcols 1
set key outside top center horizontal 
#maxrows 2
set xlabel "Cores"
set xrange [1:4]
set xtics 1
set ylabel "IPC Throughput "
set yrange [0:1800]
#set y2range [0:100]
#set y2label "CPU utilisation (%)"
#set ytics nomirror
#set y2tics

plot x86_file using ($1):($2/1000) title "b:w-500" with lines, \
     x86_file using ($1):($3/1000) title "rt-500" with lines, \
     x86_file using ($1):($6/1000) title "b-2000" with lines, \
     x86_file using ($1):($7/1000) title "rt-2000" with lines, \
     x86_file using ($1):($10/1000) title "b-8000" with lines, \
     x86_file using ($1):($11/1000) title "rt-8000" with lines, \
     x86_file using ($1):($13/1000) title "b-32000" with lines, \
     x86_file using ($1):($14/1000) title "rt-32000" with lines
