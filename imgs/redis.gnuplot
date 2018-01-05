# Common style definitions
load "imgs/common.inc"
set output "imgs/redis.eps"

data = "data/generated/redis.dat"
set size 0.9,0.5
set key top left vertical
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


plot    data using (100-$1):($2):($3) with errorlines title "Throughput" ,\
        data using (100-$1):($4):($5) with errorlines title "Idle utilisation" axes x1y2 
