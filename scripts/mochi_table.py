# -*- coding: utf-8 -*-
######################################################################
# Copyright 2019 Yusen Su. All Rights Reserved.
# Net id: ys3547
######################################################################
import sys, os
import re
import csv
import argparse

testdir = '../outputs/MoCHi'
parser = argparse.ArgumentParser()
parser.add_argument('-csv', type=str, help='give an output csv name', required=True)
args = parser.parse_args()

table_file = args.csv + '.csv'
pattern = re.compile(".*ml$")
attrs = ['subdir', 'file name', 'test class', 'timing (milseconds)', 'res (true/false)']

def read_info_from_file(file_name):
    try:
        file = open(file_name, 'r')
    except:
        sys.exit("index file does not exits. Exit!")
    data = file.readlines()
    data = [d.replace(" ", "").replace("\t", "").replace("\n", "") for d in data]
    res_data = []
    safe_regexp = re.compile(r'Safe!')
    unsafe_regexp = re.compile(r'Unsafe')
    error_regexp = re.compile(r'FPAT')
    for i in range(len(data)):
        if safe_regexp.search(data[i]) or unsafe_regexp.search(data[i]):
            if safe_regexp.search(data[i]): # safe
                res_data.append('T')
            elif unsafe_regexp.search(data[i]): # state unsafe, but safe
                res_data.append('F')
            elif error_regexp.search(data[i]): # error
                res_data.append('ER')
            _, timing = data[-1].split(":")
            try:
                time = float(timing) / 1000
                res_data.append(round(time,2))
            except:
                res_data.append(timing)
            break
        elif i == len(data) - 1: # Timeout
            _, timing = data[-1].split(":")
            res_data.append('F')
            res_data.append(timing)
    return res_data

def read_false_info_from_file(file_name):
    try:
        file = open(file_name, 'r')
    except:
        sys.exit("index file does not exits. Exit!")
    data = file.readlines()
    data = [d.replace(" ", "").replace("\t", "").replace("\n", "") for d in data]
    res_data = []
    safe_regexp = re.compile(r'Safe!')
    unsafe_regexp = re.compile(r'Unsafe')
    error_regexp = re.compile(r'FPAT')
    for i in range(len(data)):
        if safe_regexp.search(data[i]) or unsafe_regexp.search(data[i]) or error_regexp.search(data[i]):
            if safe_regexp.search(data[i]):
                res_data.append('F')
            elif unsafe_regexp.search(data[i]):
                res_data.append('T')
            elif error_regexp.search(data[i]): # error
                res_data.append('ER')
            _, timing = data[-1].split(":")
            try:
                time = float(timing) / 1000
                res_data.append(round(time,2))
            except:
                res_data.append(timing)
            break
        elif i == len(data) - 1: # Timeout
            _, timing = data[-1].split(":")
            res_data.append('F')
            res_data.append(timing)
    return res_data

def dispatch(subdir, dict):
    for root, dirs, files in os.walk(testdir+'/'+subdir):
        dict[subdir] = [(os.path.join(root, file), file, root) for file in files if pattern.match(file)]
    for file_path in dict[subdir]:
        _, dir = file_path[2].split('outputs/MoCHi/')
        if dir == "negative":
            res_data = read_false_info_from_file(file_path[0])
            res_data.append("Neg")
        else:
            res_data = read_info_from_file(file_path[0])
            res_data.append("Pos")
        test_case = file_path[1][4:-3]
        res_data.append(test_case)
        res_data.append(subdir)
        res_data.reverse()
        dict[subdir][dict[subdir].index(file_path)] = res_data

def search_all_outputs_file(table_dict):
    subdirs = next(os.walk(testdir))[1]
    for subdir in subdirs:
        dispatch(subdir, table_dict)

def write_info_into_csv(table_dict):
    try:
        file = open(table_file, 'w')
    except:
        sys.exit("output table file does not exits. Exit!")
    strs = ','.join(attrs)
    file.write(strs+'\n')
    file.close()
    with open(table_file, 'a', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',',
                        quotechar='|', quoting=csv.QUOTE_MINIMAL)
        for k in table_dict.keys():
            for d in table_dict[k]:
                writer.writerow(d)

def main():
    table_dict = {}
    search_all_outputs_file(table_dict)
    write_info_into_csv(table_dict)

if __name__ == '__main__':
	main()
