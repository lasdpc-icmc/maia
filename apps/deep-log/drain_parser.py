from data_cleaning import clean_sock, read_logs, write_logs
import json
import logging
import sys
import time

logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.INFO,
                    format='%(message)s')


def log_parser(template_miner, clean_lines, file_name, write_txt=True):
    '''
    Write parsed logs in .txt files
    book_logs_cluster - .txt with the constant part of logs encoded
    book_logs_values - .txt with the parameter values of logs

    :param clean_lines: list with logs lines to be parsed
    write_txt: if True, writes clusters id and values on a .txt file, otherwise will return cluster_list, value_list
    :return: cluster_list, value_list, template_list
    '''

    line_count = 0

    start_time = time.time()
    batch_start_time = start_time
    batch_size = 10000

    cluster_list = []
    value_list = []
    template_list = []
    for line in clean_lines:
        line = line.rstrip()
        line = line.partition(": ")[2]
        result = template_miner.add_log_message(line)

        template_mined = result['template_mined']
        line_count += 1

        params = template_miner.extract_parameters(
            result["template_mined"], line, exact_matching=False)

        cluster_id = result['cluster_id']

        try:
            if params and len(params) > 0 and len(params[0]) > 0:
                value = params[0][0]
            else:
                value = ' '
        except Exception as e:
            print(f"Error while extracting value from params: {e}")
            value = ' '


        template_list.append(template_mined)
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

    time_took = time.time() - start_time
    rate = line_count / time_took
    logger.info(f"--- Done processing file in {time_took:.2f} sec. Total of {line_count} lines, rate {rate:.1f} lines/sec, "
                f"{len(template_miner.drain.clusters)} clusters")

    sorted_clusters = sorted(
        template_miner.drain.clusters, key=lambda it: it.size, reverse=True)
    for cluster in sorted_clusters:
        logger.info(cluster)

    print("Prefix Tree:")
    template_miner.drain.print_tree()
    template_miner.profiler.report(0)

    if write_txt:
        write_logs(cluster_list, f'cluster_{file_name}')
        write_logs(value_list, f'values_{file_name}')

    return cluster_list, value_list, template_list

def proccess_logs_files(template_miner, file_name):
    try:
        initial_logs = read_logs(file_name)
        cleansed_logs, time_logs, app = clean_sock(initial_logs)
        cluster_list, value_list, template_list = log_parser(template_miner,
            cleansed_logs, file_name, write_txt=False)
        res_dic = {
            'cluster': cluster_list,
            'value_list': value_list,
            'logs_template': template_list,
            'time': time_logs,
            'app': app
        }

        file_name = file_name[:-4]
        with open(f"cleansed_{file_name}.json", "w") as outfile:
            json.dump(res_dic, outfile)

    except Exception as e:
        print(f"Error in proccess_logs_files: {e}")
        raise
