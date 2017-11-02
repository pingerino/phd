#!/usr/env/python3

import argparse
import json
import os
import pdb
import sys
import statistics
import logging

def process_results(results_json, output):
    output.write('n tasks\tn results\tmin\tmax\tavg\tstddev\n')
    # for each number of tasks 1 -- 10
    for n_tasks_res in results_json:
        n_tasks = n_tasks_res['n tasks']
        print("tasks {0}".format(n_tasks))
        row = str(n_tasks_res['n tasks']) + '\t'

        # for each task set
        i = 0;
        costs = []
        for task_set in n_tasks_res['results']:
            all_ends=[]
            all_starts=[]
            print("task set {0}".format(i))
            task_id = 0
            for numbers in task_set:
                thread_numbers = []
                # fix the data for any overflows
                overflow_count = 0
                previous_value = 0
                for result in numbers:
                    result += (overflow_count * 0xFFFFFFFF)
                    if (result < previous_value):
                        overflow_count += 1
                        result += 0xFFFFFFFF
                    thread_numbers += [result]
                    previous_value = result

                all_ends += thread_numbers[::2]
                all_starts += thread_numbers[1::2]

                task_id += 1
                logging.debug ("Fixed {0} overflows".format(overflow_count))

            logging.debug ("{0} of {1} n tasks".format(i, n_tasks))
            i += 1


            all_times = [(x, 1) for x in all_starts] + [(x, 0) for x in all_ends]
            all_times.sort()
      #      print (len(all_times))
      #      print (all_times)

            while all_times[0][1] == all_times[1][1]:
                del all_times[0]

            while len(all_times) > 2:
                # 1 is a start, 0 is an end
                #if (all_times[0][1] and all_times[1][1]):
                #    break
                assert all_times[1][0] >= all_times[0][0]
                if all_times[1][1] == all_times[0][1]:
                    break;
                costs += [all_times[1][0] - all_times[0][0]]
                del all_times[0]
                del all_times[0]


        print (len(costs))
        
        costs = [x for x in costs if x < 100000]
        print (costs)

        # calculate values
        # average, min, max, mean and stddev, n results
        row += str(len(costs)) + '\t'
        row += str(min(costs)) + '\t'
        row += str(max(costs)) + '\t'
        row += str(round(statistics.mean(costs),2)) + '\t'
        row += str(round(statistics.stdev(costs),2)) + '\n'

        # output results
        output.write(row)

        # done!


def process_json(input_json, arch, output_dir):
    # load the json
    content = json.load(input_json)
    # process each benchmark
    for result in content:
        filename = arch + '-' + result['Benchmark'] + '.dat'
        with open(os.path.join(output_dir, filename), 'w') as output:
            process_results(result["Results"], output)


def main():
    parser = argparse.ArgumentParser(description="Convert json scheduler data into .dat results")
    parser.add_argument('-i', dest='input_file', type=str, required=True, help='input file')
    parser.add_argument('-o', dest='output_dir', type=str, required=True, help='output dir')
    parser.add_argument('-a', dest='arch', type=str, required=True, help='arch')

    args = parser.parse_args()
   # logging.basicConfig(level=logging.DEBUG)

    with open(args.input_file, 'r') as input_json:
        process_json(input_json, args.arch, args.output_dir)

if __name__ == '__main__':
    sys.exit(main())
