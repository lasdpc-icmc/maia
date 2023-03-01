 # SPDX-License-Identifier: MIT

import json
import logging
import os
import subprocess
import sys
import time
from os.path import dirname

from drain3 import TemplateMiner
from drain3.template_miner_config import TemplateMinerConfig

logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.INFO, format='%(message)s')

from data_cleaning import clean_sock, read_logs, write_logs







def log_parser(clean_lines):
    '''
    Write parsed logs in .txt files
    book_logs_cluster - .txt with the constant part of logs encoded
    book_logs_values - .txt with the parameter values of logs

    :param clean_lines: list with logs lines to be parsed
    :return: None
    '''

    # initialized Drain3
    config = TemplateMinerConfig()
    config.load(dirname(__file__) + "/drain3.ini")
    config.profiling_enabled = True
    template_miner = TemplateMiner(config=config)

    line_count = 0

    start_time = time.time()
    batch_start_time = start_time
    batch_size = 10000

    cluster_list = []
    value_list = []
    for line in clean_lines:
        line = line.rstrip()
        line = line.partition(": ")[2]
        result = template_miner.add_log_message(line)
        line_count += 1


        params = template_miner.extract_parameters(
            result["template_mined"], line, exact_matching=False)


        cluster_id = result['cluster_id']

        try:
            value = params[0][0]

        except:
            value = ' '


        cluster_list.append(cluster_id)
        value_list.append(value)



        if line_count % batch_size == 0:
            time_took = time.time() - batch_start_time
            rate = batch_size / time_took
            logger.info(f"Processing line: {line_count}, rate {rate:.1f} lines/sec, "
                        f"{len(template_miner.drain.clusters)} clusters so far.")
            batch_start_time = time.time()
        if result["change_type"] != "none":
            result_json = json.dumps(result)
            logger.info(f"Input ({line_count}): " + line)
            logger.info("Result: " + result_json)





    write_logs(cluster_list, 'book_logs_cluster.txt')
    write_logs(value_list, 'book_logs_values.txt')



    time_took = time.time() - start_time
    rate = line_count / time_took
    logger.info(f"--- Done processing file in {time_took:.2f} sec. Total of {line_count} lines, rate {rate:.1f} lines/sec, "
                f"{len(template_miner.drain.clusters)} clusters")

    sorted_clusters = sorted(template_miner.drain.clusters, key=lambda it: it.size, reverse=True)
    for cluster in sorted_clusters:
        logger.info(cluster)

    print("Prefix Tree:")
    template_miner.drain.print_tree()
    template_miner.profiler.report(0)



## Exemplo de utilização:
initial_logs = read_logs('sock-shop_test.txt')
cleansed_logs, time_logs = clean_sock(initial_logs)


log_parser(cleansed_logs)