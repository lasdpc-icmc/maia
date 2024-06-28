import torch
from utils import LogDataset
from transformers import AutoTokenizer, AutoModelForCausalLM, Trainer, TrainingArguments
from peft import get_peft_model, LoraConfig, TaskType

# File path and device setup
file_path = r'C:\Users\luism\Desktop\Project MAIA\maia\apps\deep-log\logs\sock-shop_logs\sock-shop_2024-06-17 11.13.59.618003_3.txt'
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load tokenizer and model
tokenizer = AutoTokenizer.from_pretrained("gpt2", bos_token='<|startoftext|>', eos_token='<|endoftext|>', pad_token='<|pad|>')
model = AutoModelForCausalLM.from_pretrained("gpt2").to(device)

# Resize token embeddings to account for new special tokens
model.resize_token_embeddings(len(tokenizer))

# Read data and create dataset
with open(file_path, 'r') as fp:
    data = fp.read()
dataset = LogDataset(data[:10000], tokenizer, block_size=512)

# Configure LoRA
peft_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    inference_mode=False,
    r=32,
    lora_alpha=64,
    lora_dropout=0.1
)
model = get_peft_model(model, peft_config)

# Define training arguments
training_args = TrainingArguments(
    output_dir="./gpt2-lora-finetuned",
    num_train_epochs=1,
    per_device_train_batch_size=2, 
    save_steps=1000,
    save_total_limit=2,
    learning_rate=3e-4,
    warmup_steps=500,
    logging_dir='./logs',
    logging_steps=100,
)

# Create Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
)

# Start training
trainer.train()

# Save the fine-tuned model
model.save_pretrained("./gpt2-lora-finetuned")