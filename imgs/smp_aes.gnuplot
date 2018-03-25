# Common style definitions
load "imgs/common.inc"

set output "imgs/smp_aes.eps"
NX=2; NY=1
DX=0.15; DY=0.1; SX=0.4; SY=0.4
M=1
set bmargin M; set tmargin M; set lmargin M; set rmargin M
set size SX*NX+DX*1.5,SY*NY+DY*1.8+0.1

file = "data/generated/smp-aes-haswell.dat"
arm_file = "data/generated/smp-aes-sabre.dat"

set xrange [1:4]
set xtics 1
set yrange[0:650]

div=1

set multiplot
# dummy plot outside area to get full control over keys
set key at screen 0.25, screen 0.6 left maxrows 1
set origin 0, NY*2
set size SX, SY
plot file using ($1):($2/div):($3/div) title "Single" with errorlines, \
     file using ($1):($4/div):($5/div) title "Multiple" with errorlines


unset key

# x64 plot
set xlabel "Cores"
set ylabel "Throughput MiB/s"
set title "x64"
set size SX,SY
set origin DX,DY      
plot file using ($1):($2/div):($3/div) title "Single" with errorlines, \
     file using ($1):($4/div):($5/div) title "Multiple" with errorlines

# arm plot
set ylabel
set format y ''
set origin DX+SX,DY
set title "Sabre"
plot arm_file using ($1):($2/div):($3/div) title "Single" with errorlines, \
     arm_file using ($1):($4/div):($5/div) title "Multiple" with errorlines

unset multiplot
