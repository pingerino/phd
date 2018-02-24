#!/usr/local/bin/python3

# turn mode switch .json files into .inc files for direct inclusion into tex
#
# files: mode_switch.inc

import argparse
import json
import os
import statistics
import sys

import pdb

def init_result(result, stage):
        result[stage] = {}
        result[stage]['missed'] = []
        result[stage]['jobs'] = []

def extract_results(name, output, content):
    for i in content:
        stage = i['stage']
        if stage not in output:
            init_result(output, stage)
        output[stage]['missed'].append(int(i['missed']))
        output[stage]['jobs'].append(int(i['jobs']))

def extract_util(output, content):
    for i in content:
        idle = float(i['idle'])
        total = float(i['total'])
        stage = i['stage']
        if idle == 0:
            output[stage].append(100)
        else:
            output[stage].append(100 - idle / total * 100)

def process_result(content):
    for (key, values) in content.items():
        content[key] = (round(statistics.mean(values), 0), round(statistics.stdev(values), 1))


def process_switch(outdir, benchmark):
    results = {}

    results['utilisation'] = {}
    for i in range(0,3):
        results['utilisation'][i] = []

    for i in range(1, 11):
        input_file_name = 'data/mode-switch-{0}-{1}-haswell3.json'.format(i, benchmark)
        path = os.path.join(os.getcwd(), input_file_name)
        input_file = open(path, 'r')
        content = json.load(input_file)
        for j in content.get('results'):
            result_name = j['Name']
            if result_name not in results:
                results[result_name] = {}
            extract_results(result_name, results[result_name], j['results'])
        extract_util(results['utilisation'], content['utilisation'])
    
    for (key, content) in results.items():
        if key != 'utilisation':
            for (key2, content2) in content.items():
                process_result(content2)
        else:
            process_result(content)

    return results 

def output_result(output, result, ulresult, key):
    output.write('{:0.0f} '.format(result[key][0]))
    if result[key][0] != ulresult[key][0]:
        output.write('\\textbf{')
        output.write('{:0.0f}'.format(ulresult[key][0] - result[key][0]))
        output.write('}')
    output.write('& ({:1.1f}'.format(result[key][1]))
    if result[key][1] != ulresult[key][1]:
        output.write('\\textbf{')
        output.write(' {:0.1f}\t'.format(ulresult[key][1] - result[key][1]))
        output.write('}')
    output.write(')\t') 

def output_row(output, stage, crit, wcet, period, result, ulresult):
    output.write(str(crit))
    output.write(' &\t')
    output.write(str(stage))
    output.write(' &\t')
    output.write(str(wcet))
    output.write(' &\t')
    output.write('{:0.2f}'.format(wcet / period))
    output.write(' &\t')
    output_result(output, result[stage], ulresult[stage], 'jobs')
    output.write(' &\t')
    output_result(output, result[stage], ulresult[stage], 'missed')
    output.write('\\\\ \n')

def output_rows(output, name, results, ulresults):
    result = results[name]
    ulresult = ulresults[name]
    if name == "susan":
        desc = "Image recognition"
        crit = 2
        period = 190
        wcet = {0: 25, 1: 51, 2: 127}
    elif name == "cjpeg":
        name = "jpeg"
        desc = "JPEG encode/decode"
        crit = 1
        period = 100
        wcet = {0: 15, 1: 41, 2:41}
    elif name == "madplay":
        desc = "MP3 player"
        crit = 0
        period = 112
        wcet = {0: 28, 1: 28, 2: 28}

    output.write('{0}\t& '.format(name))
    output.write('{0}\t& '.format(period))
    
    output_row(output, 0, crit, wcet[0], period, result, ulresult)
    output.write('\\rowcolor{gray!25}\n')
    output.write(desc)
    output.write('& \t& ')
    output_row(output, 1, crit, wcet[1], period, result, ulresult)
    output.write('& \t &')
    output_row(output, 2, crit, wcet[2], period, result, ulresult)


def main():
    parser = argparse.ArgumentParser(description='process mode switch data ')
    parser.add_argument('-o', dest='outdir', type=str, help='output dir', required=True)
    args = parser.parse_args()

    # process the data  
    kernel = process_switch(args.outdir, 'Kernel')
    user_level = process_switch(args.outdir, 'User-level')

    # now convert the results that we have into the output table. Put difference in bold. 
    with open(os.path.join(args.outdir, 'mode_switch.inc'), 'w') as output:
        output_rows(output, 'susan', kernel, user_level)
        output.write('\\midrule \n')
        output_rows(output, 'cjpeg', kernel, user_level)
        output.write('\\midrule \n')
        output_rows(output, 'madplay', kernel, user_level)

if __name__ == '__main__':
    sys.exit(main())
