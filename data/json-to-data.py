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


def crit_row(row, output):
    output.write(str(row['threads']))
    output.write('\t')
    output.write(str(int(row['Mean'])))
    output.write('\t')
    output.write(str(int(row['Stddev'])))
    output.write('\n')

def crit_graph(results, arch, direction, cache, name):
    with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-' + direction + '-' + name + '-' + cache + '.dat'), 'w') as output:
        output.write('threads\tmean\tstddev\n')
        for result in results:
            crit_row(result, output)

def build_crit_dat(rt, arch):
    with open (rt, 'r') as json_file:
        content = json.load(json_file)

        crit_graph(getbenchmark(content, "Vary lo threads (switch up) HOT"), arch, 'up', 'hot', 'lo')
        crit_graph(getbenchmark(content, "Vary lo threads (switch down) HOT"), arch, 'down', 'hot', 'lo')
        crit_graph(getbenchmark(content, "Vary hi threads (switch up) HOT"), arch, 'up', 'hot', 'hi')
        crit_graph(getbenchmark(content, "Vary hi threads (switch down) HOT"), arch, 'down', 'hot', 'hi')

        crit_graph(getbenchmark(content, "Vary lo threads (switch up) COLD"), arch, 'up', 'cold', 'lo')
        crit_graph(getbenchmark(content, "Vary lo threads (switch down) COLD"), arch, 'down', 'cold', 'lo')
        crit_graph(getbenchmark(content, "Vary hi threads (switch up) COLD"), arch, 'up', 'cold', 'hi')
        crit_graph(getbenchmark(content, "Vary hi threads (switch down) COLD"), arch, 'down', 'cold', 'hi')

        crit_graph(getbenchmark(content, "Set priority COLD"), arch, 'ul', 'cold', 'ul')
        crit_graph(getbenchmark(content, "Set priority HOT"), arch, 'ul', 'hot', 'ul')


def microbenchmark_row(out, name, rt, b, average=False):
    rt_val = int(rt['Mean'])
    b_val = int(b['Mean'])
    out.write('&')
    out.write(name + '&\t')

#    out.write(str(int(b['Min'])))
#    out.write('-')

    out.write(str(b_val))
    out.write('&(')
    if average:
        out.write('*')
    else: 
        out.write(str(int(b['Stddev'])))
    out.write(')&\t')

#    out.write(str(int(rt['Min'])))
#    out.write('-')

    out.write(str(rt_val))
    out.write('&(')
    if average:
        out.write('*')
    else:
        out.write(str(int(rt['Stddev'])))
    out.write(')&\t')

    diff = rt_val - b_val
    out.write(str(diff))
    out.write('&\t')
    out.write(str(round(int(diff / b_val * 100))))
    out.write('\% \\\\ \\cline{2-6}\n')

def build_microbenchmark_dat(rt, baseline, arch):
    with open(rt, 'r') as rt_json, open(baseline, 'r') as b_json:
     
        rt_content = json.load(rt_json)
        b_content = json.load(b_json)

        rt_ipc = getbenchmark(rt_content, 'One way IPC microbenchmarks')
        b_ipc = getbenchmark(b_content, 'One way IPC microbenchmarks')
        
        # ipc data table
        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-fastpath-ipc-micro.inc'), 'w') as out:
            out.write('%Operation\tBaseline\tRT\tDiff\tOverhead\n')
            # call
            microbenchmark_row(out, '\\call', 
                    ipc_result(rt_ipc, 'seL4_Call', 0, 0, 254),
                    ipc_result(b_ipc, 'seL4_Call', 0, 0, 254))

            microbenchmark_row(out, '\\replyrecv', 
                    ipc_result(rt_ipc, 'seL4_ReplyRecv', 0, 254, 0),
                    ipc_result(b_ipc, 'seL4_ReplyRecv', 0, 254, 0))

        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-slowpath-ipc-micro.inc'), 'w') as out:
            microbenchmark_row(out, '\\call', 
                    ipc_result(rt_ipc, 'seL4_Call', 0, 254, 0),
                    ipc_result(b_ipc, 'seL4_Call', 0, 254, 0))

            microbenchmark_row(out, '\\replyrecv', 
                    ipc_result(rt_ipc, 'seL4_ReplyRecv', 0, 0, 254),
                    ipc_result(b_ipc, 'seL4_ReplyRecv', 0, 0, 254))

        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-slowpath-active-ipc-micro.inc'), 'w') as out:
            microbenchmark_row(out, '\\call', 
                    ipc_result(rt_ipc, 'seL4_Call', 0, 254, 0, passive=False),
                    ipc_result(b_ipc, 'seL4_Call', 0, 254, 0))

            microbenchmark_row(out, '\\replyrecv', 
                    ipc_result(rt_ipc, 'seL4_ReplyRecv', 0, 0, 254, passive=False),
                    ipc_result(b_ipc, 'seL4_ReplyRecv', 0, 0, 254))


        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-fault-micro.inc'), 'w') as out:
            # fault
            rt = getbenchmark(rt_content, 'faulter -> fault handler')[0]
            b = getbenchmark(b_content, 'faulter -> fault handler')[0]
            microbenchmark_row(out, 'Fault', rt, b)
             
            rt = getbenchmark(rt_content, 'fault handler -> faulter')[0]
            b = getbenchmark(b_content, 'fault handler -> faulter')[0]
            microbenchmark_row(out, 'Fault reply', rt, b)
           
            rt = getbenchmark(rt_content, 'fault round trip')[0]
            b = getbenchmark(b_content, 'fault round trip')[0]
            microbenchmark_row(out, 'Fault round trip', rt, b)
           # TODO add non-passive numbers 

        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-irq-micro.inc'), 'w') as out:
            rt_irq = getbenchmark(rt_content, 'IRQ path cycle count (measured from user level)')[1]
            b_irq = getbenchmark(b_content, 'IRQ path cycle count (measured from user level)')[1]
            microbenchmark_row(out, 'IRQ lat.', rt_irq, b_irq)

            # signal
            rt_signal = getbenchmark(rt_content, 'Signal to low prio thread')[0]
            b_signal = getbenchmark(b_content, 'Signal to low prio thread')[0]
            microbenchmark_row(out, 'signal()', rt_signal, b_signal)


        with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-schedule-micro.inc'), 'w') as out:
            # schedule
            rt_schedule = getbenchmark(rt_content, 'Signal to high prio thread')[0]
            b_schedule = getbenchmark(b_content, 'Signal to high prio thread')[0]
            microbenchmark_row(out, 'Schedule', rt_schedule, b_schedule)

            # average schedule
            rt = getbenchmark(rt_content, 'Average to reschedule current thread')[7]
            b = getbenchmark(b_content, 'Average to reschedule current thread')[7]
            microbenchmark_row(out, 'schedule', rt, b, True)

            # yield
            rt_yield = getbenchmark(rt_content, 'Thread yield')[0]
            b_yield = getbenchmark(b_content, 'Thread yield')[0]
            microbenchmark_row(out, 'Yield()', rt_yield, b_yield)

            rt_yield = getbenchmark(rt_content, 'Average seL4_Yield (no thread switch)')[7]
            b_yield = getbenchmark(b_content, 'Average seL4_Yield (no thread switch)')[7]
            microbenchmark_row(out, 'yield*', rt_yield, b_yield)


def aes_row(out, name, rt_aes_hot, rt_aes_cold, clk, formatstr):
    out.write(' & ')
    out.write(' \multirow{2}{*}{')
    out.write(name)
    out.write('} & hot &')
    out.write(formatstr.format(rt_aes_hot['Min']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_hot['Max']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_hot['Mean']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_hot['Stddev']/clk))
    out.write("\\\\ \\cline{3-6}\n")
    out.write(' & & cold &')
    out.write(formatstr.format(rt_aes_cold['Min']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_cold['Max']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_cold['Mean']/clk))
    out.write(' & ')
    out.write(formatstr.format(rt_aes_cold['Stddev']/clk))
    out.write("\\\\ \\cline{2-6}\n")



def build_aes_dat(rt, arch, clk):
    with open(rt, 'r') as rt_json, open(os.path.join(os.getcwd(), DATA_DIR, arch + '-aes.inc'), 'w') as out:
        rt_content = json.load(rt_json)
        out.write('%Name\tMin\tMax\tMean\tStddev\n')

        if arch == 'sabre':
            formatstr = '{0:.1f}'
        else:
            formatstr = '{0:.2f}'

        aes_row(out, "RB",  getbenchmark(rt_content, 'aes rollback')[0],  getbenchmark(rt_content, 'aes rollback cold')[0], clk, formatstr)
        aes_row(out, "Emg.", getbenchmark(rt_content, 'aes emergency')[0], getbenchmark(rt_content, 'aes emergency cold')[0], clk, formatstr)
        aes_row(out, "Ext.", getbenchmark(rt_content, 'aes extend')[0], getbenchmark(rt_content, 'aes extend cold')[0], clk, formatstr)
        aes_row(out, "Kill", getbenchmark(rt_content, 'aes kill')[0], getbenchmark(rt_content, 'aes kill cold')[0], clk, formatstr)


def aes_shared_cols(budget, tput_json, clk):
    tput = 0
    stddev = 0
    if budget:
        data = next(x for x in tput_json if x['budget'] == budget)
        if 'Raw results' in data.keys():
            raw_data = data['Raw results']
            for i in range(0, len(raw_data)):
                # convert cycles for 10 * 4096 kilobytes to MiB/s
                raw_data[i] = clk / raw_data[i] * 4  

            tput = statistics.mean(raw_data)
            stddev = statistics.stdev(raw_data)

    return str(budget) + '\t' + str(round(tput, 2)) + '\t' + str(round(stddev, 2)) 

def aes_shared_row(budget_a, period_a, a_tput_json, b_tput_json, baseline_json, clk, idle, total):
    res = aes_shared_cols(budget_a, a_tput_json, clk) + '\t'
    res += aes_shared_cols(period_a - budget_a, b_tput_json, clk) + '\t'
    res += aes_shared_cols( budget_a, baseline_json, clk) + '\t'
    idle_val = next(x for x in idle if x['budget'] == budget_a)['Mean']
    total_val = next(x for x in total if x['budget'] == budget_a)['Mean']
    res += str(round((idle_val/total_val),2)) + '\n'
    return res

def aes_shared_graph(period, rt_content, arch, clk):

    with open(os.path.join(os.getcwd(), DATA_DIR, arch + '-shared-aes-'  + str(period) + '.dat'), 'w') as out:
        A_throughput = getbenchmark(rt_content, 'A-' + str(period))
        B_throughput = getbenchmark(rt_content, 'B-' + str(period))
        baseline     = getbenchmark(rt_content, 'baseline-' + str(period))
        idle     = getbenchmark(rt_content, 'idle-' + str(period))
        total     = getbenchmark(rt_content, 'total-' + str(period))


        # construct a table with the following columns
        out.write('budget_A\ttput_A\tstd_A\t')
        out.write('budget_B\ttput_B\tstd_B\t')
        out.write('budget_baseline\ttput_basleline\tstd_baseline\t')
        out.write('util\n')

        # write out the rows
        for x in range(0, 10001, 1000):
            out.write(aes_shared_row(x * (period / 10), period * 1000, A_throughput, B_throughput,
                baseline, clk, idle, total))
 


def build_aes_shared_dat(rt, arch, clk):
    # convert clk to Hz (was MHz)
    clk = clk * 1000000
    with open(rt, 'r') as rt_json:
        rt_content = json.load(rt_json)

        aes_shared_graph(10, rt_content, arch, clk)
        aes_shared_graph(100, rt_content, arch, clk)
        aes_shared_graph(1000, rt_content, arch, clk)

def main():

    parser = argparse.ArgumentParser(description="Convert json to graph data")
    parser.add_argument('-b', type=str, dest='baseline', help='baseline json to convert', required='True')
    parser.add_argument('-rt', type=str, dest='rt', help='rt json to convert', required='True')
    parser.add_argument('-c', type=str, dest='crit', help='criticality json', required='True')
    parser.add_argument('-aes', type=str, dest='aes', help='aes json', required='True')
    parser.add_argument('-ul', type=str, dest='ul', help='ul json', required='True')
    parser.add_argument('-a', type=str, dest='arch', help='arch', required='True')

    args = parser.parse_args()

    pwd = os.getcwd()
    rt_file = os.path.join(pwd, args.rt)
    baseline_file = os.path.join(pwd, args.baseline)
    crit_file = os.path.join(pwd, args.crit)
    aes_file = os.path.join(pwd, args.aes)
    ul_file = os.path.join(pwd, args.ul)
    outdir = os.path.join(pwd, DATA_DIR)
    if not os.path.exists(outdir):
        os.mkdir(os.path.join(pwd,DATA_DIR))

    clk = 3400      
    if args.arch == 'sabre':
        clk = 996

    build_crit_dat(crit_file, args.arch)
    build_microbenchmark_dat(rt_file, baseline_file, args.arch)
    build_aes_dat(aes_file, args.arch, clk)
    build_aes_shared_dat(aes_file, args.arch, clk)

if __name__ == '__main__':
    sys.exit(main())
