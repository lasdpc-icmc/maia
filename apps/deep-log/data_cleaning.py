import re

def clean_sock(lines):
    '''
    Remove unimportant information from the logs lines before parse them using Drain3
    :param lines: list, lines of logs
    :return: clean_log, list with the cleaned log lines
    :return: time_log, list with the time in which the logs were generated

    '''
    clean_log = []
    time_log = []
    apps = []

    time_pattern_remove = r"\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z\]"
    time_pattern_remove2 = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}Z"
    time_pattern_remove3 = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z"
    apps_rgx = r"'app': (.*?(?<!\\)) "

    for i in lines:

        app_tag = re.sub(r"'", '', re.findall(apps_rgx, i)[0]).strip(',')
        i = i[i.index("{'log'"):]

        time = i[i.index("'time': "):]
        time = re.sub(r"'time':", '', time).replace('}', '')

        i = i[:i.index("'stream'")]

        i = re.sub(time_pattern_remove, '', i)
        i = re.sub(time_pattern_remove2, '', i)
        i = re.sub(time_pattern_remove3, '', i)

        i = i.replace('\t', ' ')
        i = i.replace('"', '')

        key = i
        clean_log.append(key)
        time_log.append(time)
        apps.append(app_tag)

    return clean_log, time_log, apps


def write_logs(cluster_list, archive_path):
    '''
    Receives the cluster list of logs, generated by the log parser
    and writes on a .txt file named with archive_path

    :param cluster_list: list,
    :param archive_path: str, path in which to save the .txt file
    :return: None
    '''

    with open(f'{archive_path}', 'a') as f:
        for cluster_id in cluster_list:
            log = str(cluster_id)
            f.write(log)
            f.write(' ')


def read_logs(archive_path):
    '''
    Read .txt file with logs
    :param archive_path: str, path to the .txt file
    :return: list with one per entry
    '''
    with open(f'{archive_path}') as f:
        lines = f.readlines()
        lines = [i.replace('\n', '') for i in lines]

    return lines
