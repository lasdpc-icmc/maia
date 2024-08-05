import pandas as pd
from sklearn.preprocessing import LabelEncoder

def preprocess_and_save(file_path, output_file_path):
    """
    Preprocesses the data by converting categorical columns to numeric,
    converting time columns to numeric timestamps, and handling missing values.
    Then, saves the preprocessed data to a new CSV file.

    Args:
    - file_path (str): The path to the input CSV file.
    - output_file_path (str): The path to save the preprocessed CSV file.

    Returns:
    - pd.DataFrame: The preprocessed DataFrame.
    - dict: A dictionary with LabelEncoders for each categorical column.
    """
    df = pd.read_csv(file_path)

    label_encoders = {}

    for column in df.select_dtypes(include=['object']).columns:
        if column != 'istio.canonical_service':
            le = LabelEncoder()
            df[column] = le.fit_transform(df[column].astype(str))
            label_encoders[column] = le

    if 'startTime' in df.columns:
        df['startTime'] = pd.to_datetime(df['startTime'], unit='ns').astype(int) / 1e9

    df = df.fillna(-1)

    df.to_csv(output_file_path, index=False)

    return df, label_encoders

input_file_path = 'traces/traces.csv'
output_file_path = 'traces/preprocessed_traces.csv'
processed_df, encoders = preprocess_and_save(input_file_path, output_file_path)

print(f"Preprocessed saved: {output_file_path}")
print(processed_df.dtypes)
print(processed_df.head())