import re
import os
import json
import csv
from collections import defaultdict

# Configurações
service_name = "carts-db"
input_file = f"../logs_training/{service_name}_2024-09-15 14_45_00.txt"
output_dir = f"./labeled_logs/{service_name}/"

os.makedirs(output_dir, exist_ok=True)

# Regex para capturar timestamp e mensagem
log_regex = re.compile(r"\d+\s'app': '([^']+)'\s([\d\-\s:.TZ]+).*\]\s(.*)")

# Função para normalizar a mensagem do log
def normalizar_mensagem(mensagem):
    if "Opened connection" in mensagem:
        return "Opened connection to DB"
    elif "connected to delta upstream XDS" in mensagem:
        return "Connected to XDS"
    else:
        return mensagem.strip()

event_mapping = defaultdict(lambda: len(event_mapping) + 1)
sequencia_eventos = []

with open(input_file, "r") as file:
    for line in file:
        match = log_regex.search(line)
        if match:
            app_name, timestamp, mensagem = match.groups()
            evento_normalizado = normalizar_mensagem(mensagem)
            event_id = event_mapping[evento_normalizado]
            sequencia_eventos.append((timestamp, event_id))
        else:
            print(f"Linha ignorada (formato inesperado): {line.strip()}")

# Gerar arquivo CSV com a sequência temporal
csv_file = os.path.join(output_dir, "events_sequence.csv")

with open(csv_file, mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["timestamp", "event_id"])
    for timestamp, event_id in sequencia_eventos:
        writer.writerow([timestamp, event_id])

# Gerar arquivo JSON com o mapeamento dos eventos
json_file = os.path.join(output_dir, "event_mapping.json")

with open(json_file, "w") as f:
    json.dump(event_mapping, f, indent=4)

print(f"Arquivos salvos em: {output_dir}")
