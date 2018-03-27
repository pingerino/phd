#!/usr/local/bin/python3
#
#  We want to create a table like this
#  
#  Metric/Plat | KZM | Sabre | Hikey | x64 | TX1 ... 
#  cycles        +4    +3       +4
#  o/h           x%    x% 
#  l1-cache miss +1     -2 
# ... 
 
# for all average benchmarks 
# which are 
import os
import json
import pdb
from collections import deque

BENCHMARKS=['avg slowpath round trip passive',
    'avg slowpath round trip',
    'avg fault round trip passive',
    'avg fault round trip',
    'schedule process average',
    'Average seL4_Yield (no thread switch)']

PLATS=['kzm', 'sabre', 'hikey32', 'hikey64', 'tx1', 'ia32', 'haswell']
PLAT_NAMES=['KZM', 'Sabre', 'Hikey32', 'Hikey64', 'TX1', 'ia32', 'x64']
COUNTERS=['Baseline', 'Overhead (\%)', 'Cycle count', 'L1 I-miss', 'L1 D-miss', 'TLB I-miss', 'TLB D-miss',
'Instructions',
        'Branch mispredict', 'Memory access']

def get_result(json, name):
    return (next(x for x in json if x['Event'] == name))

def get_diff(b, rt, name):
    b_val = get_result(b, name)
    rt_val = get_result(rt, name)
    return (int(rt_val['Mean']) - int(b_val['Mean']), round(float(rt_val['Stddev'],) -
        float(b_val['Stddev']),0))

def get_benchmark(json, name):
    matches = [x for x in json if x['Benchmark'] == name]
    if len(matches):
        return matches[0]['Results']
    else:
        pdb.set_trace()

def process_result(benchmark, b_json, rt_json):
    b = get_benchmark(b_json, benchmark)
    rt = get_benchmark(rt_json, benchmark)

    col = deque()

    # baseline cycles
    b_val = get_result(b, 'Cycle counter')
    rt_val = get_result(rt, 'Cycle counter')
    col.append((int(b_val['Mean']), int(b_val['Stddev'])))
    b_mean = float(b_val['Mean'])
    if b_mean:
        diff = float(rt_val['Mean']) - b_mean
        col.append((round(diff/b_mean*100, 0), ' '))
    else:
        col.append(('$\\infty$', ' '))
    col.append(get_diff(b, rt, 'Cycle counter'))
    col.append(get_diff(b, rt, 'L1 i-cache misses'))
    col.append(get_diff(b, rt, 'L1 d-cache misses'))
    col.append(get_diff(b, rt, 'L1 i-tlb misses'))
    col.append(get_diff(b, rt, 'L1 d-tlb misses'))
    col.append(get_diff(b, rt, 'Instructions'))
    col.append(get_diff(b, rt, 'Branch mispredict'))
    col.append(get_diff(b, rt, 'Memory access'))
    print(col)
    return col 



results = {}
for benchmark in BENCHMARKS:
    results[benchmark] = {}

for plat in PLATS:
    b_file = 'baseline-' + plat + '.json'
    rt_file = 'rt-' + plat + '.json'
    # load json
    with open(os.path.join(os.getcwd(),'data',b_file), 'r') as b:
        b_json = json.load(b)
    with open(os.path.join(os.getcwd(),'data',rt_file), 'r') as rt:
        rt_json = json.load(rt)

    # create a column for each benchmark
    for benchmark in BENCHMARKS:
        if plat != 'kzm' or not 'fault' in benchmark:
            results[benchmark][plat] = process_result(benchmark, b_json, rt_json)
            
# now output a table for each benchmark
for benchmark in BENCHMARKS:
    filename = benchmark.replace(' ', '_').replace('(','').replace(')','')
    with open(os.path.join(os.getcwd() + '/data/generated', filename + '.inc'), 'w') as out:
        print(filename)
        out.write(' & ')
        for plat in PLAT_NAMES:
            if plat is not 'KZM' or 'fault' not in benchmark:
                out.write('\\textsc{' + plat + '}' )
                if plat is not 'x64':
                    out.write(' & ')
                else:
                    out.write(' \\\\ \\midrule \n')

        for counter in COUNTERS:
            out.write('{0} &'.format(counter))
            # results
            stddev_row = 'stddev '
            for plat in PLATS:
                if plat is not 'kzm' or 'fault' not in benchmark:
                    (res, std) = results[benchmark][plat].popleft()
                    if 'Overhead' in counter:
                        out.write('{:.0f}\%'.format(res))
                    elif 'Baseline' in counter:
                        out.write('{:.0f}'.format(res))
                    else:
                        out.write('{:+.0f}'.format(res))
                    stddev_row += ' ({0}) '.format(std)
                    if plat is not 'haswell':
                        out.write(' & ')
                        stddev_row += ' &'
                    else:
                        out.write(' \\\\ \n')
                        stddev_row += ' \\\\ \n'
#            out.write(stddev_row) 
            





