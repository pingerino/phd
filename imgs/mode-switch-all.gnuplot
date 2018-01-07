# Common style definitions
load "imgs/common.inc"
# output file
set output "imgs/mode-switch-all.eps"

# data
x86_hi_cold = "data/generated/haswell-up-hi-cold.dat"
x86_hi_hot = "data/generated/haswell-up-hi-hot.dat"
x86_lo_cold = "data/generated/haswell-up-lo-cold.dat"
x86_lo_hot = "data/generated/haswell-up-lo-hot.dat"
x86_ul_cold = "data/generated/haswell-ul-ul-cold.dat"
x86_ul_hot = "data/generated/haswell-ul-ul-hot.dat"

arm_hi_cold = "data/generated/sabre-up-hi-cold.dat"
arm_hi_hot = "data/generated/sabre-up-hi-hot.dat"
arm_lo_cold = "data/generated/sabre-up-lo-cold.dat"
arm_lo_hot = "data/generated/sabre-up-lo-hot.dat"
arm_ul_cold = "data/generated/sabre-ul-ul-cold.dat"
arm_ul_hot = "data/generated/sabre-ul-ul-hot.dat"

# dimensions for multiplot
NX=1;NY=2
DX=0.15;DY=0.1;SX=0.6;SY=0.4
M=1
set bmargin M; set tmargin 2; set lmargin M; set rmargin M
set size SX*NX+DX*1.5+0.2,SY*NY+DY*1.8

set multiplot
# all graphs this size
set size SX,SY
# dummy plot to spread keys across full width
set origin 0,NY*2
set key at screen DX+SX, screen SY+DY+DY horizontal left maxcols 1
plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI hot', \
      x86_lo_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO cold', \
      x86_lo_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL hot'
     
# dont mirror tics on both axis
set xtics nomirror
set ytics nomirror
# proper plots
#
# bottom 
unset key
set title "x64"
set xlabel "Number of threads"
set ylabel "Time ({/Symbol m}s)"
set xrange [0:16]

set yrange [0:3]
set ytics 0,0.5
set format y ''
set ytics add (' ' 0, '1' 1, '2' 2)
set origin DX,DY

plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI hot', \
      x86_lo_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO cold', \
      x86_lo_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL hot'
     
# top
set title "Sabre"
set origin DX,DY+SY
set yrange [0:20]
# tick every unit
set ytics 0,1
# but don't label them
set format y ''
# set explicit labels for the ones we want
set ytics add ('0' 0, '5' 5, '10' 10, '15' 15)
unset xlabel
set format x ''
plot  arm_hi_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi cold', \
      arm_hi_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi hot', \
      arm_lo_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Lo cold', \
      arm_lo_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Lo hot', \
      arm_ul_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul cold', \
      arm_ul_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul hot'
