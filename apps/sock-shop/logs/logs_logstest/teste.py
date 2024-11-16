import json

json_file = "users-failure.json"

output_file = "parsed/users-failure.txt"

with open(json_file, 'r') as file:
    data = json.load(file)

with open(output_file, 'w') as txt_file:
    for stream_entry in data.get("data", {}).get("result", []):
        for value in stream_entry.get("values", []):
            timestamp, event = value
            txt_file.write(f"{event}\n")