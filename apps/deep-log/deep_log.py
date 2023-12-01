import aws_tools
import os
import deep_log_train
import deep_log_predict
import drain_parser

from loki import get_loki_logs

LOKI_URL = os.environ['LOKI_URL']
APP_NAME = os.environ['APP_NAME']
TIME_RANGE = int(os.environ['TIME_RANGE'])
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']

file_name = get_loki_logs(LOKI_URL, APP_NAME, TIME_RANGE,
                          AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

def main():
    drain_parser.proccess_logs_files(file_name)
    deep_log_train.train_model(file_name)
    deep_log_predict.model_predict(file_name)

    print(f"Processing completed for {file_name}")


if __name__ == "__main__":
    main()
    aws_tools.sync_data(file_name)
