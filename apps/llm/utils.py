import torch
from torch.utils.data import Dataset

class LogDataset(Dataset):
    def __init__(self, data, tokenizer, block_size=512):
        self.data = data
        self.tokenizer = tokenizer
        self.block_size = block_size

    def __len__(self):
        return len(self.data) - 1
    
    def __getitem__(self,idx):
        chunk = self.data[idx:idx + self.block_size + 1]
        chunk_str = "".join(chunk)
        
        encodings = self.tokenizer(chunk_str, truncation=True, max_length=self.block_size + 1, padding="max_length")
        input_ids = encodings["input_ids"][:-1]
        labels = encodings["input_ids"][-1]

        return {
            "input_ids": torch.tensor(input_ids),
            "labels": torch.tensor(labels),
        }

'''
    def __getitem__(self, idx):
        ngrams = []
        labels = []

        for i in range(2, self.block_size + 1):
            if idx + i < len(self.data):
                ngram = self.data[idx:idx + i]
                label = self.data[idx + i]
                ngrams.append(ngram)
                labels.append(label)

        encoded_ngrams = [self.tokenizer.encode_plus(
            ' '.join(ngram),
            add_special_tokens=True,
            padding='max_length',
            max_length=self.block_size,
            truncation=True,
            return_tensors='pt'
        ) for ngram in ngrams]

        # Convert the list of encoded n-grams to a single tensor
        input_ids = torch.stack([e['input_ids'].squeeze() for e in encoded_ngrams])
        attention_mask = torch.stack([e['attention_mask'].squeeze() for e in encoded_ngrams])

        # Tokenize the labels
        encoded_labels = self.tokenizer.batch_encode_plus(
            labels,
            add_special_tokens=False,
            padding='max_length',
            max_length=1,
            truncation=True,
            return_tensors='pt'
        )['input_ids'].squeeze()

        return {
            'input_ids': input_ids,
            'attention_mask': attention_mask,
            'labels': encoded_labels
        }
'''
    
    