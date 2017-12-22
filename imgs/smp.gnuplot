# Common style definitions
load "imgs/common.inc"
unset size

set output "imgs/smp.eps"

x86_file = "data/generated/smp-haswell.dat"
arm_file = "data/generated/smp-sabre.dat"

#set key bottom right vertical maxrows 4 maxcols 1
#maxrows 2
set xrange [1:4]
#set yrange [0:2]
#set y2range [0:100]
#set ytics nomirror
#set y2tics

set style line 1  lw 2 lt 1 pt 3  lc rgb "black"
set style line 2  lw 2 lt 2 pt 4  lc rgb "red"
set style line 3  lw 2 lt 1 pt 6  lc rgb "black"
set style line 4  lw 2 lt 2 pt 7  lc rgb "red"
set style line 5  lw 2 lt 1 pt 8  lc rgb "black"
set style line 6  lw 2 lt 2 pt 7  lc rgb "red"
set style line 7  lw 2 lt 1 pt 6  lc rgb "black"
set style line 8  lw 2 lt 2 pt 7  lc rgb "red"
set style line 9  lw 2 lt 1 pt 15 lc rgb "black"
set style line 10 lw 2 lt 2 pt 15 lc rgb "red"
#

div=1000000

set tmargin 5
set rmargin 3
set lmargin 6
set bmargin 1
set multiplot layout 2,4
unset key
set xtics 1
set format x ''
set format y ''
set yrange[0:3]
set xlabel
set ylabel "x64 IPC Mops/s"
set title '500'
plot x86_file using ($1):($2/div):($3/div) title "b:w-500" with errorlines, \
     x86_file using ($1):($4/div):($5/div) title "rt-500" with errorlines
set ylabel
set title '2000'
set lmargin 3
plot x86_file using ($1):($6/div):($7/div) title "b-2000" with errorlines, \
     x86_file using ($1):($8/div):($8/div) title "rt-2000" with errorlines
set title '8000'
plot x86_file using ($1):($10/div):($9/div) title "b-8000" with errorlines, \
     x86_file using ($1):($12/div):($13/div) title "rt-8000" with errorlines

set key outside top center horizontal 
set title '32000'
set rmargin 6
set y2tics
set format y2 '%g'
plot x86_file using ($1):($14/div):($14/div) title "base" with errorlines, \
     x86_file using ($1):($16/div):($17/div) title "MCS" with errorlines
 
set lmargin 6
set tmargin 1
set rmargin 3
set bmargin 5
unset title
unset key
set format x '%g'
set format y2 ''
set xlabel "Cores"
set ylabel "Sabre IPC Mops/s"
plot arm_file using ($1):($2/div):($3/div) title "b:w-500" with errorlines, \
     arm_file using ($1):($4/div):($5/div) title "rt-500" with errorlines
set ylabel
set format y ''
set lmargin 3
set xlabel
plot arm_file using ($1):($6/div):($7/div) title "b-2000" with errorlines, \
     arm_file using ($1):($8/div):($8/div) title "rt-2000" with errorlines
plot arm_file using ($1):($10/div):($9/div) title "b-8000" with errorlines, \
     arm_file using ($1):($12/div):($13/div) title "rt-8000" with errorlines
set rmargin 6
set format y2 '%g'
plot arm_file using ($1):($14/div):($14/div) title "b-32000" with errorlines, \
     arm_file using ($1):($16/div):($17/div) title "rt-32000" with errorlines

unset multiplot
