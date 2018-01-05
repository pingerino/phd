# Common style definitions
load "imgs/common.inc"

set output "imgs/smp.eps"
NX=2; NY=1
DX=0.1; DY=0.1; SX=0.5; SY=0.4
M=1
set bmargin M; set tmargin M; set lmargin M; set rmargin M
set size SX*NX+DX*1.5,SY*NY+DY*1.8+0.1
LW=4

file = "data/generated/smp-haswell.dat"
arm_file = "data/generated/smp-sabre.dat"

set xrange [1:4]
set xtics 1
set yrange[0:3000]

set style line 1  lw LW lt 1 pt 8  lc rgb "black"
set style line 2  lw LW lt 2 pt 9  lc rgb "black"
set style line 3  lw LW lt 1 pt 6  lc rgb "red"
set style line 4  lw LW lt 2 pt 7  lc rgb "red"
set style line 5  lw LW lt 1 pt 13  lc rgb "orange"
set style line 6  lw LW lt 2 pt 14 lc rgb "orange"
set style line 7  lw LW lt 1 pt 4  lc rgb "blue"
set style line 8  lw LW lt 2 pt 5  lc rgb "blue"

div=1000

set multiplot
# dummy plot outside area to get full control over keys
set key at screen -0.04, screen 0.11 left maxrows 2
set origin 0, NY*2
set size SX, SY
plot file using ($1):($2/div):($3/div) title "b-500" with errorlines, \
     file using ($1):($4/div):($5/div) title "mcs-500" with errorlines, \
     file using ($1):($6/div):($7/div) title "b-1000" with errorlines, \
     file using ($1):($8/div):($9/div) title "mcs-1000" with errorlines, \
     file using ($1):($10/div):($11/div) title "b-2000" with errorlines, \
     file using ($1):($12/div):($13/div) title "mcs-2000" with errorlines, \
     file using ($1):($14/div):($15/div) title "base-4000" with errorlines, \
     file using ($1):($16/div):($17/div) title "mcs-4000" with errorlines


unset key

# x64 plot
set xlabel "Cores"
set ylabel "IPC Kops/s"
set title "x64"
set size SX,SY
set origin DX,DY+0.1      
plot file using ($1):($2/div):($3/div) title "b-500" with errorlines, \
     file using ($1):($4/div):($5/div) title "mcs-500" with errorlines, \
     file using ($1):($6/div):($7/div) title "b-1000" with errorlines, \
     file using ($1):($8/div):($9/div) title "mcs-1000" with errorlines, \
     file using ($1):($10/div):($11/div) title "b-2000" with errorlines, \
     file using ($1):($12/div):($13/div) title "mcs-2000" with errorlines, \
     file using ($1):($14/div):($15/div) title "base-4000" with errorlines, \
     file using ($1):($16/div):($17/div) title "mcs-4000" with errorlines

# arm plot
set ylabel
set format y ''
set origin DX+SX,DY+0.1
set title "Sabre"
plot arm_file using ($1):($2/div):($3/div) title "b-500" with errorlines, \
     arm_file using ($1):($4/div):($5/div) title "mcs-500" with errorlines, \
     arm_file using ($1):($6/div):($7/div) title "b-1000" with errorlines, \
     arm_file using ($1):($8/div):($9/div) title "mcs-1000" with errorlines, \
     arm_file using ($1):($10/div):($11/div) title "b-2000" with errorlines, \
     arm_file using ($1):($12/div):($13/div) title "mcs-2000" with errorlines, \
     arm_file using ($1):($14/div):($15/div) title "base-4000" with errorlines, \
     arm_file using ($1):($16/div):($17/div) title "mcs-4000" with errorlines

unset multiplot
