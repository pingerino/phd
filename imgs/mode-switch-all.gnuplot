# Common style definitions
load "imgs/common.inc"
# output file
set output "imgs/mode-switch-all.eps"

# data
x86_hi_cold = "data/generated/haswell-up-hi-cold.dat"
x86_hi_hot = "data/generated/haswell-up-hi-hot.dat"
x86_ul_cold = "data/generated/haswell-ul-ul-cold.dat"
x86_ul_hot = "data/generated/haswell-ul-ul-hot.dat"

arm_hi_cold = "data/generated/sabre-up-hi-cold.dat"
arm_hi_hot = "data/generated/sabre-up-hi-hot.dat"
arm_ul_cold = "data/generated/sabre-ul-ul-cold.dat"
arm_ul_hot = "data/generated/sabre-ul-ul-hot.dat"

tx1_hi_cold = "data/generated/tx1-up-hi-cold.dat"
tx1_hi_hot = "data/generated/tx1-up-hi-hot.dat"
tx1_ul_cold = "data/generated/tx1-ul-ul-cold.dat"
tx1_ul_hot = "data/generated/tx1-ul-ul-hot.dat"

hikey_hi_cold = "data/generated/hikey64-up-hi-cold.dat"
hikey_hi_hot = "data/generated/hikey64-up-hi-hot.dat"
hikey_ul_cold = "data/generated/hikey64-ul-ul-cold.dat"
hikey_ul_hot = "data/generated/hikey64-ul-ul-hot.dat"

# dimensions for multiplot
NX=2;NY=2
DX=0.15;DY=0.1;SX=0.5;SY=0.4
M=1
set bmargin M; set tmargin 2; set lmargin M; set rmargin M
set size SX*NX+DX*1.5,SY*NY+DY*1.8+DY

set multiplot
# all graphs this size
set size SX,SY
# dummy plot to spread keys across full width
set origin 0,NY*2
set key at screen SX+0.1, screen SY+SY+0.2 center maxrows 2
plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Kernel cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Kernel hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'User-level cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'User-level hot'
     
# proper plots
#
# top left 
unset key
set title "x64"
set ylabel "Time ({/Symbol m}s)"
set xrange [0:16]
unset ytics
set ytics 1
set format y ''
set ytics add ('0' 0, '2'2, '4' 4, '6' 6, '8' 8)

set yrange [0:8]
set format x ''
set origin DX,DY+SY

plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Kernel cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'Kernel hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'User-level cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'User-level hot'

# top right 
set title "TX1"
unset ylabel 
set origin DX+SX,DY+SY
# dont label y units
set format y ''
unset ytics
set ytics 1

plot  tx1_hi_cold using 1:($2/tx1_clk):($3/tx1_clk) with errorlines title 'Kernel cold', \
      tx1_hi_hot  using 1:($2/tx1_clk):($3/tx1_clk) with errorlines title 'Kernel hot', \
      tx1_ul_cold using 1:($2/tx1_clk):($3/tx1_clk) with errorlines title 'User-level cold', \
      tx1_ul_hot  using 1:($2/tx1_clk):($3/tx1_clk) with errorlines title 'User-level hot'

# bottom left 
set xlabel "Number of threads"
unset xtics
set xtics 2
set format x '%g'
unset key
set title "Hikey64"
set ylabel "Time ({/Symbol m}s)"
set xrange [0:16]
set yrange [0:30]
set ytics 2.5
set ytics add ('0' 0, '5' 5, '10' 10, '15' 15, '20' 20, '25' 25, '30' 30)
set origin DX,DY


plot  hikey_hi_cold using 1:($2/hikey_clk):($3/hikey_clk) with errorlines title 'Kernel cold', \
      hikey_hi_hot  using 1:($2/hikey_clk):($3/hikey_clk) with errorlines title 'Kernel hot', \
      hikey_ul_cold using 1:($2/hikey_clk):($3/hikey_clk) with errorlines title 'User-level cold', \
      hikey_ul_hot  using 1:($2/hikey_clk):($3/hikey_clk) with errorlines title 'User-level hot'
 

# bottom right
set ylabel ""
set title "Sabre"
unset ytics
set ytics 2.5 
set origin DX+SX,DY
plot  arm_hi_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi cold', \
      arm_hi_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi hot', \
      arm_ul_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul cold', \
      arm_ul_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul hot'
