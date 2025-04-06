import re
import os
import csv
import json
from collections import defaultdict

# Diretórios
service_name = "carts"
input_path = f"../logs_training/"
output_path = f"./labeled_logs/{service_name}/"

os.makedirs(output_path, exist_ok=True)

# Nome do arquivo de log
log_file = os.path.join(input_path, "carts_2024-09-15 14_45_00.txt")

# Regex para extrair timestamp e mensagem
log_regex = re.compile(r"\d+\s'app': '([^']+)'\s([\d\-\s:.TZ]+).*\]\s(.*)")

# Mapeamento de eventos
event_mapping = {}
next_event_id = 1

dados_csv = []

def normalizar_mensagem(mensagem):
    mensagem = mensagem.strip()
    mensagem = re.sub(r'\[connectionId\{.*?\}\]', '[connectionId]', mensagem)
    return mensagem

with open(log_file, "r") as f:
    for line in f:
        match = log_regex.search(line)
        if match:
            _, timestamp, mensagem = match.groups()
            mensagem_normalizada = normalizar_mensagem(mensagem)
            
            if mensagem_normalizada not in event_mapping:
                event_mapping[mensagem_normalizada] = next_event_id
                next_event_id += 1
                
            event_id = event_mapping[mensagem_normalizada]
            dados_csv.append([timestamp, event_id])
        else:
            print(f"Linha ignorada: {line.strip()}")

# Arquivos de saída
base_name = os.path.splitext(os.path.basename(log_file))[0]
csv_output = os.path.join(output_path, f"{base_name}.csv")
json_output = os.path.join(output_path, f"{base_name}_event_mapping.json")

# Salvar CSV
with open(csv_output, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["timestamp", "event_id"])
    writer.writerows(dados_csv)

# Salvar JSON
with open(json_output, "w") as f:
    json.dump(event_mapping, f, indent=4)

print(f"Arquivos gerados: {csv_output} e {json_output}")
