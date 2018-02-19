#!/usr/local/bin/python3

# turn smp.json files into .dat files for gnuplot to consume
#
# format
#
# cores tput-baseline-size tput-rt-siae
# 
# files: smp-plat.dat

import argparse
import json
import os
import statistics
import sys

import pdb

clk = 3400000000

def get_res(json, core, size):
    return next(x for x in json if x['Cores'] == core and x['Cycles'] == size)

def get_benchmark(json, name):
    return next(x for x in json if x['Benchmark'] == name)

def get_result(json, name, cores):
    import pdb
    #pdb.set_trace()
    return next(x for x in json if x['cores'] == cores)[name] 

def output_result(data, cores, out):
    raw_data = get_result(data, 'Raw results', cores);
    for i in range(0, len(raw_data)):
        # convert cycles for 10 * 1025 Kb to MiB/s
        raw_data[i] = clk / raw_data[i] * cores
    out.write('\t{0}'.format(round(statistics.mean(raw_data), 2)))
    out.write('\t{0}'.format(round(statistics.stdev(raw_data), 2)))
 

def main():
    parser = argparse.ArgumentParser(description='process smp data into graph data')
    parser.add_argument('-o', dest='outdir', type=str, help='output dir', required=True)
    parser.add_argument('-p', dest='plat', type=str, help='platform', required=True)
    parser.add_argument('-b', dest='bjson', type=argparse.FileType('r'), help='input file', required=True)
    parser.add_argument('-rt', dest='rtjson', type=argparse.FileType('r'), help='input file', required=True)
    args = parser.parse_args()

    if args.plat == 'sabre':
        clk = 996000000

    rt_content = json.load(args.rtjson)
    b_content = json.load(args.bjson)

    rt_ipc = get_benchmark(rt_content, 'SMP Benchmark')['Results']
    b_ipc = get_benchmark(b_content, 'SMP Benchmark')['Results']
    # smp ipc throughput
    with open(os.path.join(args.outdir, 'smp-{0}.dat'.format(args.plat)), 'w') as output: 
        # write the header
        output.write('core')
        length = 500
        for i in range(1,8):
            output.write('\tb-tput-{0}\tb-std-{0}\trt-tput-{0}\trt-std-{0}'.format(length))
            length = length * 2
        output.write('\n')
        # write the data row
        for core in [1,2,3,4]:
            output.write(str(core))
            length = 500
            for i in range(1,8):
                rt_res = get_res(rt_ipc, core, length)
                b_res = get_res(b_ipc, core, length)

                output.write('\t{0}\t{1}'.format(b_res['Mean'], b_res['Stddev']))
                output.write('\t{0}\t{1}'.format(rt_res['Mean'], rt_res['Stddev']))
                length = length * 2
            output.write('\n')

    # smp aes throughput
    with open(os.path.join(args.outdir, 'smp-aes-{0}.dat'.format(args.plat)), 'w') as output:
        output.write('cores\ttput-1\tstdev-1\tput-n\tstdev-n\n');
        smp = get_benchmark(rt_content, 'smp - 1 server')['Results']
        smp_n = get_benchmark(rt_content, 'smp - N servers')['Results']
        # first row
        for cores in [1,2,3,4]:
            output.write('{0}'.format(cores))
            output_result(smp, cores, output)
            output_result(smp_n, cores, output)
            output.write('\n')
           
    args.rtjson.close()
    args.bjson.close()

if __name__ == '__main__':
    sys.exit(main())
