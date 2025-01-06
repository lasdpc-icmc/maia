import os
import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix

def create_confusion_matrices_from_directory(directory, output_dir, file_pattern="*.txt"):

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    file_paths = glob.glob(os.path.join(directory, file_pattern))

    if not file_paths:
        print(f"No files matching '{file_pattern}' found in directory '{directory}'")
        return

    for file_path in file_paths:
        print(f"\nProcessing file: {file_path}")
        cm = create_confusion_matrix(file_path, output_dir)
        if cm is not None:
            print("Confusion Matrix:")
            print(cm)
            try:
                tn, fp, fn, tp = cm.ravel()
                accuracy = (tp + tn) / (tp + tn + fp + fn)
                print(f"Accuracy: {accuracy}")
                precision = tp / (tp + fp) if (tp + fp) != 0 else 0
                print(f"Precision: {precision}")
                recall = tp / (tp + fn) if (tp + fn) != 0 else 0
                print(f"Recall: {recall}")
                f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) != 0 else 0
                print(f"F1-score: {f1}")
            except ValueError as e:
                print(f"Error calculating metrics: {e}. Check if the confusion matrix has the expected shape.")
        else:
            print(f"Could not generate confusion matrix for {file_path}")

def create_confusion_matrix(file_path, output_dir):
    true_labels = []
    predicted_labels = []

    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()

        i = 0
        while i < len(lines):
            label_line = None
            score_line = None

            while i < len(lines) and not (label_line and score_line):
                line = lines[i].strip()
                if line.startswith("A") or line.startswith("N"):
                    label_line = line[0]
                elif line.startswith("SIM SCORE"):
                    try:
                        score_line = float(line.split()[-1])
                    except ValueError:
                        print(f"Warning: Invalid score format: {line}")
                i += 1

            if label_line and score_line is not None:
                predicted_label = 'N' if score_line >= 0.8 else 'A'
                true_labels.append(label_line)
                predicted_labels.append(predicted_label)
            elif label_line:
                 print(f"Warning: Missing SIM SCORE for label {label_line}")
            elif score_line:
                print(f"Warning: Missing Label for SIM SCORE {score_line}")

    except FileNotFoundError:
        print(f"Error: File not found: {file_path}")
        return None

    if not true_labels:
        print("Error: No valid data found in the file.")
        return None

    labels = sorted(list(set(true_labels + predicted_labels)))
    cm = confusion_matrix(true_labels, predicted_labels, labels=labels)

    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=labels, yticklabels=labels)
    plt.xlabel('Predicted Label')
    plt.ylabel('True Label')

    file_name = os.path.basename(file_path)
    name, ext = os.path.splitext(file_name)
    title = name.replace("_", " ").title() + " Confusion Matrix"
    plt.title(title)

    output_path = os.path.join(output_dir, f"{name}.png")
    plt.savefig(output_path)
    plt.close()

    return cm

input_directory = "labeled_logs/"
output_directory = "confusion_matrix_images"
file_pattern = "*.txt"
create_confusion_matrices_from_directory(input_directory, output_directory, file_pattern)