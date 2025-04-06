import os
import re
import json
import csv

# Diretórios
service_name = "shipping"
input_file = f"../logs_training/{service_name}_2024-09-15 14_45_00.txt"
output_path = f"./labeled_logs/{service_name}/"

os.makedirs(output_path, exist_ok=True)

def normalize_message(message):
    # Remove UUIDs
    message = re.sub(r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}', '<ID>', message)
    # Remove IP addresses
    message = re.sub(r'\d+\.\d+\.\d+\.\d+', '<IP>', message)
    # Remove long numbers (timestamps, etc)
    message = re.sub(r'\d{10,}', '<NUM>', message)
    # Remove file paths
    message = re.sub(r'(/[a-zA-Z0-9_\-\.]+)+', '/<PATH>', message)
    # Remove email addresses
    message = re.sub(r'\S+@\S+\.\S+', '<EMAIL>', message)
    # Remove URLs
    message = re.sub(r'https?://\S+', '<URL>', message)
    # Remove generic numbers
    message = re.sub(r'\d+', '<NUM>', message)
    # Remove quoted strings
    message = re.sub(r"'[^']*'", "'<STR>'", message)
    message = re.sub(r'"[^"]*"', '"<STR>"', message)
    # Remove hex numbers
    message = re.sub(r'0x[a-fA-F0-9]+', '<HEX>', message)
    # Remove key=value patterns
    message = re.sub(r'\b\w+=\S+', '<KEYVAL>', message)
    return message.strip()

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

            parts = line.split(" 'app': 'shipping' ")
            if len(parts) != 2:
                continue

            timestamp, message = parts
            message_norm = normalize_message(message)

            if message_norm not in event_mapping:
                event_mapping[message_norm] = event_counter
                event_counter += 1

            event_id = event_mapping[message_norm]
            rows.append((timestamp, event_id))

    # Write CSV
    with open(os.path.join(output_path, "events.csv"), 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['timestamp', 'event_id'])
        writer.writerows(rows)

    # Write Event Mapping JSON
    with open(os.path.join(output_path, "event_mapping.json"), 'w') as jsonfile:
        json.dump(event_mapping, jsonfile, indent=4)

if __name__ == "__main__":
    process_log(input_file, output_path)
