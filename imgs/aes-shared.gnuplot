# Common style definitions
load "imgs/common.inc"

set output "imgs/aes-shared.eps"

arm_file_10 = "data/generated/sabre-shared-aes-10.dat"
x86_file_10 = "data/generated/haswell-shared-aes-10.dat"

arm_file_100 = "data/generated/sabre-shared-aes-100.dat"
x86_file_100 = "data/generated/haswell-shared-aes-100.dat"

arm_file_1000 = "data/generated/sabre-shared-aes-1000.dat"
x86_file_1000 = "data/generated/haswell-shared-aes-1000.dat"

set key top left vertical maxrows 3
set xlabel "A budget (ms)"
set ylabel "Xput (MiB/s)"
set y2label "CPU %"
set ytics nomirror
set y2tics
set size 0.8,1.2
set size 1.04,0.466
set multiplot layout 2,3 
unset title
set y2range [0:100]

# dummy plot outside area to get full control over keys
set key at screen 0.5, screen 0.45 horizontal center maxrows 1 maxcols 4
set origin 0,0.5
set size 1,0.35
plot x86_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_10 using ($1/1000):(100 - $10*100) with errorlines title "CPU" axes x1y2

# now the real plot 
# plot x86 results
#set title "x64 10ms"
unset xlabel
set xtics format ""
unset y2label
set ytics 0,50
set y2tics format ""
set size 0.4,0.2
set origin 0,0.25
unset key
plot x86_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_10 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

#set title "x64 100ms"
unset ylabel
set ytics format ""
set size 0.35,0.2
set origin 0.35,0.25
unset key
plot x86_file_100 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_100 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_100 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_100 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

#set title "x64 1000ms"
set y2tics format "%3g"
set y2label "CPU %"
set size 0.4,0.2
set origin 0.65,0.25
plot x86_file_1000 using ($1/1000):($2):($3) with errorlines title "A", \
     x86_file_1000 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     x86_file_1000 using ($1/1000):($8):($9) with errorlines title "base", \
     x86_file_1000 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

#plot arm results
#set yrange [0:13]
#set title "ARM 10ms"
set xtics format "%3g"
set xlabel "A budget (ms)"
set ylabel "Xput (MiB/s)"
set yrange [0:15]
set ytics 0,5 format "%3g"
set y2tics format ""
set ytics nomirror
unset y2label
set size 0.4,0.25
set origin 0,0
plot arm_file_10 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_10 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_10 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_10 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

#set title "ARM 100ms"
unset ylabel
set ytics format ""
set size 0.35,0.25
set origin 0.35,0
plot arm_file_100 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_100 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_100 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_100 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

#plot arm results
#set title "ARM 1000ms"
set y2tics format "%3g"
set y2label "CPU %"
set size 0.4,0.25
set origin 0.65,0
plot arm_file_1000 using ($1/1000):($2):($3) with errorlines title "A", \
     arm_file_1000 using ($1/1000):($5):($6) with errorlines title "B" axes x2y1, \
     arm_file_1000 using ($1/1000):($8):($9) with errorlines title "base", \
     arm_file_1000 using ($1/1000):(100 - $10*100) with errorlines title "cpu" axes x1y2

unset multiplot
