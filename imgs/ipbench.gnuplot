# Common style definitions
load "imgs/common.inc"
set size 2,1
set output "imgs/ipbench.eps"

file = "data/generated/ipbench.dat"

set key top left vertical maxrows 4 maxcols 1
#set key outside top center horizontal maxrows 1
set xlabel "Budget (ms)"
set ylabel "Latency (ms)"
#set yrange [0:11]
set y2range [0:100]
set y2label "CPU utilisation (%)"
set ytics nomirror
set y2tics

plot file using ($1/1000.0):($4/1000.0):($5/1000.0) with errorlines title "Max", \
     file using ($1/1000.0):($2/1000.0):($3/1000.0) with errorlines title "Mean", \
     file using ($1/1000.0):($1/1000.0) with errorlines title "Budget", \
     file using ($1/1000.0):($6):($7) with errorlines title "CPU %" axes x1y2
