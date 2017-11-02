# Common style definitions
load "imgs/common.inc"
set terminal postscript enhanced
set output "imgs/mode-switch-all.eps"

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

set size 0.585,0.35
set multiplot layout 1,2

# dummy plot to spread keys across full width
set key at screen 0.31, screen 0.32 horizontal center maxrows 2 maxcols 3
set size 0.7,0.3
set origin 0,0.4
plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI hot', \
      x86_lo_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO cold', \
      x86_lo_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL hot'
     


# proper plots
unset key
#set title "x64"
set xlabel "Number of threads"
set ylabel "Time ({/Symbol m}s)"
set xrange [0:16]

set yrange [0:3]
set size 0.33,0.3
set origin 0,0

plot  x86_hi_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI cold', \
      x86_hi_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'HI hot', \
      x86_lo_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO cold', \
      x86_lo_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'LO hot', \
      x86_ul_cold using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL cold', \
      x86_ul_hot  using 1:($2/x86_clk):($3/x86_clk) with errorlines title 'UL hot'
     

#set title "ARM"
set size 0.3,0.3
set origin 0.3,0
set yrange [0:20]
unset ylabel
plot  arm_hi_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi cold', \
      arm_hi_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Hi hot', \
      arm_lo_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Lo cold', \
      arm_lo_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'Lo hot', \
      arm_ul_cold using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul cold', \
      arm_ul_hot  using 1:($2/arm_clk):($3/arm_clk) with errorlines title 'ul hot'
