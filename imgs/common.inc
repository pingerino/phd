# Common definitions for plots

# Styles
set terminal postscript size 3.0in,2.25in eps enhanced color font "Helvetica" 11
set border linewidth 1

set style line 1  lw 2 lt 10 pt 3  lc rgb "red"
set style line 2  lw 2 lt 12 pt 4  lc rgb "blue"
set style line 3  lw 2 lt 12 pt 6  lc rgb "black"
set style line 4  lw 2 lt 10 pt 7  lc rgb "#006400"
set style line 5  lw 2 lt 10 pt 8  lc rgb "purple"
set style line 6  lw 2 lt 10 pt 7  lc rgb "blue"
set style line 7  lw 2 lt 10 pt 6  lc rgb "blue"
set style line 8  lw 2 lt 10 pt 7  lc rgb "blue"
set style line 9  lw 2 lt 10 pt 15 lc rgb "red"
set style line 10 lw 2 lt 10 pt 15 lc rgb "red"
#set pointsize 1 
set grid noxtics noytics
set style increment user

# Data parameters
arm_clk = 996
x86_clk = 3400
