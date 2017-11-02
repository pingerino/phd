#!/usr/bin/env python

import os
import sys
import json
import argparse
import tempfile
import shutil
import numpy
import sh

RUMP_URL_FORMAT_STRING = "http://bamboo/browse/RUMP-BENCH-%d/artifact/shared/rt-redis-rumprun-x86_64_defconfig%d-results%d.json/results.json"
LINUX_URL_FORMAT_STRING = "http://bamboo.keg.ertos.in.nicta.com.au/browse/SEL4BENCH-REDL-%d/artifact/shared/linuxnative-results%d.json/results.json"



def other_rump(args, platform):
    pwd = os.getcwd()
    with open("generated/%s-redis.dat" % platform, "w") as result_file:
        results = dict()
        averaged = dict()
        result_file.writelines("throughput (t/s)\tstddev\tidle\tstddev\n")
        throughput = []
        utilisation = []
        for i in range(args.num_runs):
            # print("%d %d" %(j,i))
            filename = os.path.join(pwd, "redis", "%sredis%d.json"%(platform, i))
            with open(filename) as json_data:
                results["%d"%(i)] = json.load(json_data)
            utilisation.append(1-(results["%d"%(i)]["utilisation"]["idle"]/results["%d"%(i)]["utilisation"]["total"]))
            throughput.append(results["%d"%(i)]["throughput"])
        print(numpy.mean(utilisation)*100)
        result_file.writelines("%f\t%f\t%f\t%f\n" % ( 
                                                            numpy.mean(throughput)/1000, 
                                                            numpy.std(throughput)/1000, 
                                                            100-(numpy.mean(utilisation)*100), 
                                                            numpy.std(utilisation)*100))


def seL4_rump(args):
    pwd = os.getcwd()
    with open("generated/redis.dat", "w") as result_file:

        results = dict()
        averaged = dict()
        result_file.writelines("Hog utilisation\tthroughput (t/s)\tstddev\tidle\tstddev\n")
        for j in [0, 5, 25, 45, 55, 65, 85]:
            throughput = []
            utilisation = []
            for i in range(3):
                # print("%d %d" %(j,i))
                filename = os.path.join(pwd, "redis", "results-%d-%d.json"%(j, i))
                if args.build_number:
                    sh.wget(RUMP_URL_FORMAT_STRING %(args.build_number, j, i), "-O", filename)
                with open(filename) as json_data:
                    results["%d-%d"%(j,i)] = json.load(json_data)
                utilisation.append(1-(results["%d-%d"%(j,i)]["utilisation"]["idle"]/results["%d-%d"%(j,i)]["utilisation"]["total"]))
                throughput.append(results["%d-%d"%(j,i)]["throughput"])
            result_file.writelines("%d\t%f\t%f\t%f\t%f\n" % (j, 
                                                             numpy.mean(throughput)/1000, 
                                                             numpy.std(throughput)/1000, 
                                                             100-numpy.mean(utilisation)*100, 
                                                             numpy.std(utilisation)*100))



def main():
    parser = argparse.ArgumentParser(
        description='Pull redis benchmarks off of bamboo')
    parser.add_argument('--build-number', dest="build_number", type=int)
    parser.add_argument('--platform', dest="platform", type=str)
    parser.add_argument('--num_runs', dest="num_runs", type=int, default=9)
    args = parser.parse_args(sys.argv[1:])
    pwd = os.getcwd()

    if args.platform.lower() == "sel4":
        seL4_rump(args)
    else:
        other_rump(args, args.platform.lower())

if __name__ == "__main__":
    main()
