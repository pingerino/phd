#!/usr/local/bin/python3
# parse a benchmark file and extract key results
import statistics
import argparse
import json
import os
import sys

import pdb
DATA_DIR = 'data/generated'

def getbenchmark(json, name):
    print(name)
    return next(x for x in json if x['Benchmark'] == name)['Results']

def ipc_result(json, name, length, client, server, passive=True):
    return next(x for x in json if x['Function'] == name and not x['Same vspace?'] and 
            x['IPC length'] == length and x['Client Prio'] == client and x['Server Prio'] == server and
        ('passive?' not in x.keys() or x['passive?'] == passive))


def microbenchmark_cells(out, field, rt, b):
    rt_val = int(rt[field])
    b_val = int(b[field])
    out.write('\t& {0} \t& {1}'.format(b_val, rt_val))

def microbenchmark_row(out, rt, b):
    microbenchmark_cells(out, 'Min', rt, b)
    microbenchmark_cells(out, 'Max', rt, b)
    microbenchmark_cells(out, 'Mean', rt, b)
    microbenchmark_cells(out, 'Stddev', rt, b)

def build_microbenchmark_table(rt, baseline, out, slowpath=False, passive=True, replyRecv=False):
    with open(rt, 'r') as rt_json, open(baseline, 'r') as b_json:
     
        rt_content = json.load(rt_json)
        b_content = json.load(b_json)

        rt_ipc = getbenchmark(rt_content, 'One way IPC microbenchmarks')
        b_ipc = getbenchmark(b_content, 'One way IPC microbenchmarks')

        op =  'seL4_ReplyRecv' if replyRecv else 'seL4_Call'
       
        # Client is high prio if we are not replying, or we're calling and its the slowpath
        client_higher = (replyRecv and not slowpath) or (not replyRecv and slowpath)

        if client_higher:
            client_prio = 254
            server_prio = 0
        else:
            client_prio = 0
            server_prio = 254

        # call fastpath
        print ("Getting {0} {1} {2}".format(client_prio, server_prio, passive))
        microbenchmark_row(out, 
                ipc_result(rt_ipc, op, 0, client_prio, server_prio, passive=passive),
                ipc_result(b_ipc, op, 0, client_prio, server_prio))



counters = [
    "Cache L1I miss    ",
    "Cache L1D miss    ",
    "TLB   L1I miss    ",
    "TLB   L1D miss    ",
    "Instruction exec. ",
    "Branch misspredict",
    "memory access     "
]

def gen_arch_table(arch, output, slowpath, passive, replyRecv, name):
    
    output.write('\\begin{table}[ht]\centering\n')
    output.write('\\begin{tabular}{|l|c|c|c|c|c|c|c|c|}\\hline\n')
    output.write('counter & min(b) & min(rt) & max(b) & max(rt) & avg(b) & avg(rt) & std(b) & std(rt) \\\\\\hline\n')
    # cycles first
    output.write("cycles")
    print("Name {0} r cycles".format(name))
    rt_file = os.path.join(os.getcwd(), 'data', 'rt-{0}.json'.format(arch))
    baseline_file = os.path.join(os.getcwd(), 'data', 'baseline-{0}.json'.format(arch))
    build_microbenchmark_table(rt_file, baseline_file, output, slowpath=slowpath, passive=passive,
            replyRecv=replyRecv)
    output.write(' \\\\\\hline\n')

    for i in range(0, 7):
        output.write(counters[i])
        print("Name {0} r {1}".format(name, counters[i]))
        rt_file = os.path.join(os.getcwd(), 'data', 'ipc-perf-{0}-rt-{1}.json'.format(i, arch))
        baseline_file = os.path.join(os.getcwd(), 'data', 'ipc-perf-{0}-baseline-{1}.json'.format(i, arch))
        build_microbenchmark_table(rt_file, baseline_file, output, slowpath=slowpath,
                passive=passive, replyRecv=replyRecv)
        output.write(' \\\\\\hline\n')

    output.write('\\end{tabular}\n')
    output.write('\\caption{' + name + '}\n')
    output.write('\\end{table}\n')


def main():

    parser = argparse.ArgumentParser(description="Convert ipc perf data to graph data")
    parser.add_argument('-o', dest='outdir', type=str, help='dir to generate files in', required=True);
    args = parser.parse_args()

    arches = ['haswell', 'sabre', 'odroidxu', 'zynq7000']
    
    with open(os.path.join(os.getcwd(), args.outdir, 'ipc-perf.inc'), 'w') as output:
        for arch in arches:

            output.write('\\clearpage')
            gen_arch_table(arch, output, False, True, False, arch + " Call fastpath")
            gen_arch_table(arch, output, True, True, False, arch + " Call passive slowpath")
            gen_arch_table(arch, output, True, False, False, arch + " Call active slowpath")
            
            gen_arch_table(arch, output, False, True, True, arch + " Reply recv fastpath")
            gen_arch_table(arch, output, True, True, True, arch + " Reply passive slowpath")
            gen_arch_table(arch, output, True, False, True, arch + " Reply active slowpath")
            output.write('\\clearpage')



if __name__ == '__main__':
    sys.exit(main())
