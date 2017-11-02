# Common style definitions
load "imgs/common.inc"
set size 0.47,0.22

set output "imgs/redis.eps"

data = "data/generated/redis.dat"

set key top left vertical maxrows 2
#set key at 95, 15 bottom right
set xlabel "Available CPU bandwidth (%)"
set ylabel "Xput (k ops/s)"
set y2label "CPU idle (%)"

set xrange[0:100]
set yrange[0:150]
set ytics 0,50
set y2range[0:10]
set ytics nomirror
set y2tics


plot    data using (100-$1):($2):($3) with errorlines title "Xput" ,\
        data using (100-$1):($4):($5) with errorlines title "Idle" axes x1y2 
