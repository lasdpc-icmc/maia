from drain3 import TemplateMiner
from drain3.file_persistence import FilePersistence
import re
import os
log_files = [
    "../logs_training/carts_2024-09-15 14_45_00.txt",
    "../logs_training/carts-db_2024-09-15 14_45_00.txt",
    "../logs_training/front-end_2024-09-15 14_45_00.txt",
    "../logs_training/orders_2024-09-15 14_45_00.txt",
    "../logs_training/orders-db_2024-09-15 14_45_00.txt",
    "../logs_training/session-db_2024-09-15 14_45_00.txt",
    "../logs_training/shipping_2024-09-15 14_45_00.txt",
    "../logs_training/sock-shop_2024-06-21 11.13.59.618003_5.txt",
]

persistence = FilePersistence("./drain3_state.bin")
template_miner = TemplateMiner(persistence)
    
parsed_sequences = []

for file_path in log_files:
    with open(file_path, "r") as file:
        for line in file:
            line = line.strip()
            result = template_miner.add_log_message(line)
            if result["change_type"] is not None:
                parsed_sequences.append(result["cluster_id"])

print("Total de Templates Extraidos:", len(set(parsed_sequences)))
