import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel, PeftConfig
from utils import LogDataset

# Load the original model and tokenizer
model_name = "gpt2"
file_path = r'C:\Users\luism\Desktop\Project MAIA\maia\apps\deep-log\logs\sock-shop_logs\sock-shop_2024-06-17 11.13.59.618003_3.txt'

tokenizer = AutoTokenizer.from_pretrained(
    "gpt2", 
    bos_token='<|startoftext|>', 
    eos_token='<|endoftext|>', 
    pad_token='<|pad|>'
)
model = AutoModelForCausalLM.from_pretrained(model_name)

model.resize_token_embeddings(len(tokenizer))

with open(file_path, 'r') as fp:
    data = fp.read()
dataset = LogDataset(data, tokenizer, block_size=512)

# Load the LoRA adapter
peft_model_path = "./gpt2-lora-finetuned"
config = PeftConfig.from_pretrained(peft_model_path)
model = PeftModel.from_pretrained(model, peft_model_path)

# Merge the LoRA adapter with the base model
model = model.merge_and_unload()

# Set the model to evaluation mode
model.eval()

# Function to generate text
def generate_text(prompt, max_length=1024):
    ret = tokenizer.encode_plus(prompt, return_tensors="pt")
    
    # Generate
    with torch.no_grad():
        output = model.generate(
            ret['input_ids'],
            attention_mask=ret['attention_mask'],
            max_length=max_length,
            num_return_sequences=1,
            no_repeat_ngram_size=2,
            top_k=50,
            top_p=0.95,
            temperature=0.7
        )
    
    return tokenizer.decode(output[0], skip_special_tokens=True)

# Get a sample from your dataset
sample_idx = 0  # You can change this to sample different entries
sample = dataset[sample_idx]
sample_text = tokenizer.decode(sample['input_ids'], skip_special_tokens=True)

print(sample_text)

# Use the first 50 tokens as a prompt (adjust as needed)
prompt = ''.join(sample_text.split()[:512])

print("Prompt:")
print(prompt)
print("\nGenerated text:")
print(generate_text(prompt))