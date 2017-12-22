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
import sys

import pdb

def get_res(json, core, size):
    return next(x for x in json if x['Cores'] == core and x['Cycles'] == size)

def main():
    parser = argparse.ArgumentParser(description='process smp data into graph data')
    parser.add_argument('-o', dest='outdir', type=str, help='output dir', required=True)
    parser.add_argument('-p', dest='plat', type=str, help='platform', required=True)
    parser.add_argument('-b', dest='bjson', type=argparse.FileType('r'), help='input file', required=True)
    parser.add_argument('-rt', dest='rtjson', type=argparse.FileType('r'), help='input file', required=True)
    args = parser.parse_args()

    rt_content = json.load(args.rtjson)[0]['Results']
    b_content = json.load(args.bjson)[0]['Results']

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
                rt_res = get_res(rt_content, core, length)
                b_res = get_res(b_content, core, length)

                output.write('\t{0}\t{1}'.format(b_res['Mean'], b_res['Stddev']))
                output.write('\t{0}\t{1}'.format(rt_res['Mean'], rt_res['Stddev']))
                length = length * 2
            output.write('\n')

    args.rtjson.close()
    args.bjson.close()

if __name__ == '__main__':
    sys.exit(main())
