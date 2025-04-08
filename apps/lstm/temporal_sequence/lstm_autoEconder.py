import os
import ast
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, LSTM, RepeatVector
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split

# Configuração
dataset_path = './datasets/dataset.csv'
model_save_path = './treinamento/lstm_autoencoder.h5'
latent_dim = 64
epochs = 50
batch_size = 32
window_size = 10  # Tamanho fixo das sequências

# Carregar Dataset
df = pd.read_csv(dataset_path)

# Converter string para lista
def safe_literal_eval(x):
    try:
        return ast.literal_eval(x)
    except (ValueError, SyntaxError):
        return []

df['sequence'] = df['sequence'].apply(safe_literal_eval)

# Filtra sequências válidas
df = df[df['sequence'].map(lambda x: len(x) > 0)]

print(f'Total de amostras válidas: {len(df)}')

# Pré-processar as sequências
X = df['sequence'].tolist()

# Converte todos os itens para int (ignorando erros)
def convert_sequence(seq):
    return [int(item) for item in seq if str(item).isdigit()]

X = [convert_sequence(seq) for seq in X]

# Padding
X = [seq[:window_size] if len(seq) >= window_size else seq + [0]*(window_size - len(seq)) for seq in X]
X = np.array(X)
print(f'Tamanho das sequências (timesteps): {X.shape[1]}')

# Redimensionar para (samples, timesteps, features)
X = np.expand_dims(X, axis=2)

# Separar treino e teste
X_train, X_test = train_test_split(X, test_size=0.2, random_state=42)
print(f'Train shape: {X_train.shape} | Test shape: {X_test.shape}')

# Criar o Modelo AutoEncoder LSTM
inputs = Input(shape=(window_size, 1))
encoded = LSTM(latent_dim)(inputs)
decoded = RepeatVector(window_size)(encoded)
decoded = LSTM(1, return_sequences=True)(decoded)

autoencoder = Model(inputs, decoded)
autoencoder.compile(optimizer=Adam(), loss='mse')

# Treinamento
autoencoder.fit(X_train, X_train,
                epochs=epochs,
                batch_size=batch_size,
                validation_data=(X_test, X_test))

# Salvar o modelo treinado
os.makedirs(os.path.dirname(model_save_path), exist_ok=True)
autoencoder.save(model_save_path)

print(f'Modelo treinado e salvo em: {model_save_path}')

print("Treinamento concluído com sucesso!")