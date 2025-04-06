import os
import re
import json
import csv

# Diretórios
service_name = "sock-shop"
input_file = f"../logs_training/{service_name}_2024-06-21 11.13.59.618003_5.txt"
output_path = f"./labeled_logs/{service_name}/"

os.makedirs(output_path, exist_ok=True)

def normalize_message(message):
    # Remove informações que não são úteis para distinguir os eventos
    message = re.sub(r'\b\d{15,}\b', '<ID>', message)  # IDs longos
    message = re.sub(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z', '<TIMESTAMP>', message)  # Timestamps
    message = re.sub(r'caller=[^ ]+', 'caller=<CALLER>', message)  # Caller
    message = re.sub(r'\b\d+(\.\d+)?µ?s\b', '<DURATION>', message)  # Duração
    message = re.sub(r'result=\d+', 'result=<RESULT>', message)  # Resultados
    return message.strip()  # Preservar informações únicas, como método e estrutura geral

def process_log(input_file, output_path):
    os.makedirs(output_path, exist_ok=True)

    event_mapping = {}
    event_counter = 1
    rows = []

    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            # Ignorar 'rabbitmq'
            if "'app': 'rabbitmq'" in line:
                continue

            # Divisão e extração de informações
            match = re.search(r"'app': '([^']+)'.*ts=([\d\-T:.Z]+).*method=([^ ]+).*result=(\d+).*", line)
            if not match:
                continue
            
            app_name, timestamp, method, result = match.groups()

            # Combine informações importantes para tornar as mensagens únicas
            normalized_message = normalize_message(f"{app_name} {method} {result}")

            if normalized_message not in event_mapping:
                event_mapping[normalized_message] = event_counter
                event_counter += 1

            event_id = event_mapping[normalized_message]
            rows.append((timestamp, event_id))

    # Escrever CSV
    with open(os.path.join(output_path, "events.csv"), 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['timestamp', 'event_id'])
        writer.writerows(rows)

    # Escrever Event Mapping JSON
    with open(os.path.join(output_path, "event_mapping.json"), 'w') as jsonfile:
        json.dump(event_mapping, jsonfile, indent=4)

if __name__ == "__main__":
    process_log(input_file, output_path)
