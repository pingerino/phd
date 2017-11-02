#!/usr/bin/python3
# parse a ipbench data file and extract key results into gnuplot file

import argparse
import os
import sys

import pdb
import statistics

BUDGET=0
PERIOD=1
RT=2
AT=3
ST=4
SIZE=5
MIN=6
AVG=7
MAX=8
STDDEV=9
MED=10

UTIL_BUDGET=0
UTIL_PERIOD=1
IDLE=2
TOTAL=3


def main():

    parser = argparse.ArgumentParser(description="Convert ipbench output to graph data")
    parser.add_argument('-i', type=str, dest='infile', help='input file with latency', required='True')
    parser.add_argument('-u', type=str, dest='util_infile', help='input file with utilisation', required='True')
    parser.add_argument('-o', type=str, dest='outfile', help='output file', required='True')

    args = parser.parse_args()

    pwd = os.getcwd()
    input_file = open(os.path.join(pwd, args.infile), 'r')
    output_file = open(os.path.join(pwd, args.outfile), 'w')
    util_file = open(os.path.join(pwd, args.util_infile))

    # skip the header
    input_file.readline()
    util_file.readline()
    output_file.write('#Budget\tavg-latency\tavg-std\tMax-latency\tmax-std\tavg-util\tmax-util\n')

    budget = 1000
    avg_lat = []
    max_lat = []
    util = []
    while True:
        line = input_file.readline()
        util_line = util_file.readline()

        cols = line.rstrip().split(',')
        util_cols = util_line.rstrip().split(',')

        if not line or int(cols[BUDGET]) != budget:
            assert(not line or int(cols[BUDGET]) == int(cols[UTIL_BUDGET]))
            # write out the last row
            avg_avg = statistics.mean(avg_lat)
            avg_max = statistics.mean(max_lat)
            util_avg = statistics.mean(util)
            std_avg = statistics.stdev(avg_lat)
            std_max = statistics.stdev(max_lat)
            util_std = statistics.stdev(util)

            output_file.write("{0}\t{1:.2f}\t{2:.2f}\t{3:.2f}\t{4:.2f}\t{5:.2f}\t{6:.2f}\n".format(budget, avg_avg, std_avg,
                avg_max, std_max, util_avg, util_std))

            avg_lat = []
            max_lat = []
            util = []

        if not line:
            break
        
        avg_lat += [int(cols[AVG])]
        max_lat += [int(cols[MAX])]


        idle = float(util_cols[IDLE])
        total = float(util_cols[TOTAL])
        print ("idle pc {0}".format(idle/total*100))
        
        util += [(1.0-(idle/total))*100]
        budget = int(cols[BUDGET])

    output_file.close()
    input_file.close()

if __name__ == '__main__':
    sys.exit(main())
