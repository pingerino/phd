# Common style definitions
load "imgs/common.inc"

set output "imgs/aes-shared.eps"
# NX,NY are the number of graphs horizontally and vertically
NX=3;NY=2
# DX,DY are the offset into the page that the graphs start at
# SX,SY are the dimensios of the graphs themselves
DX=0.15;DY=0.1;SX=0.3;SY=0.3
set bmargin 1; set tmargin 1; set lmargin 1; set rmargin 1
set size SX*NX+DX*1.5+0.05,SY*NY+DY*1.8+0.1

# data files
arm_file_10 = "data/generated/sabre-shared-aes-10.dat"
x86_file_10 = "data/generated/haswell-shared-aes-10.dat"
arm_file_100 = "data/generated/sabre-shared-aes-100.dat"
x86_file_100 = "data/generated/haswell-shared-aes-100.dat"
arm_file_1000 = "data/generated/sabre-shared-aes-1000.dat"
x86_file_1000 = "data/generated/haswell-shared-aes-1000.dat"

#set xlabel "A budget (ms)"
set ytics nomirror
set y2tics
set multiplot
set y2range [0:100]

# set the size of all of the plots
set size SX,SY

# dummy plot outside area to get full control over keys
set key at screen 0.6, screen 0.8 center maxrows 1
set origin 0,NY*2
plot x86_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_10 using ($1/1000):(100 - $10*100) with errorlines title "CPU" axes x1y2

# turn off the key for the rest of the plots, we already drew it
unset key

# plot x86 results
#set title "x64 10ms"
set ylabel "x64 Xput (MiB/s)"
set ytics 0,50
# Turn off y2 tick labels
set format y2 ''
# Turn off y2 axis label
set y2label
set origin DX,DY
plot x86_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_10 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

# x64 100ms
set xlabel "A budget (ms)"
set xtics 0,25
# turn off y axis label
set ylabel
# turn off the y tick labels
set format y ''
set origin DX+SX,DY
plot x86_file_100 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_100 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_100 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_100 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

# "x64 1000ms"
set xlabel
set xtics 0,250
set format y2 '%3g'
set y2label "CPU %"
set origin DX+SX*2,DY
plot x86_file_1000 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_1000 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_1000 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_1000 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

# plot arm results
set yrange [0:15]
set title "10ms period"
# turn off x tick labels
set format x ''
set xtics 0,1
set ylabel "Sabre Xput (MiB/s)"
set ytics 0,5 
# Turn off y2 tick labels
set format y2 ''
# Turn off y2 axis label
set y2label
# Turn on y tick labels
set format y '%3.1f'

set origin DX,DY+SY
plot arm_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_10 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

set title "100ms period"
set ylabel
set xtics 0,25
set format y ''
set origin DX+SX,DY+SY
plot arm_file_100 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_100 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_100 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_100 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

set title "1000ms period"
set format y2 '%3g'
set xtics 0,250
set y2label "CPU %"
set origin DX+SX*2,DY+SY
plot arm_file_1000 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_1000 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_1000 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_1000 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

unset multiplot
