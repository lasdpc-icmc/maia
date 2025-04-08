import os
import csv

# Configurações
input_path = "../temporal_sequence/labeled_logs/"  # Pasta onde estão os logs por serviço
output_path = "./datasets/"  # Pasta onde será salvo o dataset final
window_size = 10  # Tamanho da janela (sequência de eventos)

os.makedirs(output_path, exist_ok=True)

def gerar_dataset():
    sequences = []

    for service_dir in os.listdir(input_path):
        service_path = os.path.join(input_path, service_dir)

        if os.path.isdir(service_path):
            for file in os.listdir(service_path):
                if file.endswith(".csv"):
                    file_path = os.path.join(service_path, file)

                    with open(file_path, "r") as f:
                        reader = csv.reader(f)
                        events = [row[0] for row in reader if row]

                        # Gera as janelas de tamanho window_size
                        for i in range(len(events) - window_size + 1):
                            window = events[i:i + window_size]
                            sequences.append({
                                "sequence": window,
                                "label": "normal"
                            })

    print(f"Total de sequências geradas: {len(sequences)}")

    output_file = os.path.join(output_path, "dataset.csv")
    with open(output_file, "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["sequence", "label"])

        for seq in sequences:
            writer.writerow([seq["sequence"], seq["label"]])

    print(f"Dataset salvo em: {output_file}")

if __name__ == "__main__":
    gerar_dataset()
