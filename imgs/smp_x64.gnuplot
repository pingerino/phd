# Common style definitions
load "imgs/common.inc"
unset size

set output "imgs/smp_x64.eps"

file = "data/generated/smp-haswell.dat"

set key inside top left maxrows 8
set xrange [1:4]
set xtics 1
set yrange[0:3]
set ylabel "x64 IPC Mops/s"

set style line 1  lw 2 lt 1 pt 8  lc rgb "black"
set style line 2  lw 2 lt 2 pt 9  lc rgb "black"
set style line 3  lw 2 lt 1 pt 6  lc rgb "red"
set style line 4  lw 2 lt 2 pt 7  lc rgb "red"
set style line 5  lw 2 lt 1 pt 13  lc rgb "orange"
set style line 6  lw 2 lt 2 pt 14 lc rgb "orange"
set style line 7  lw 2 lt 1 pt 4  lc rgb "blue"
set style line 8  lw 2 lt 2 pt 5  lc rgb "blue"

div=1000000

set xlabel
plot file using ($1):($2/div):($3/div) title "b-500" with errorlines, \
     file using ($1):($4/div):($5/div) title "mcs-500" with errorlines, \
     file using ($1):($6/div):($7/div) title "b-1000" with errorlines, \
     file using ($1):($8/div):($9/div) title "mcs-1000" with errorlines, \
     file using ($1):($10/div):($11/div) title "b-2000" with errorlines, \
     file using ($1):($12/div):($13/div) title "mcs-2000" with errorlines, \
     file using ($1):($14/div):($15/div) title "base-4000" with errorlines, \
     file using ($1):($16/div):($17/div) title "mcs-4000" with errorlines
