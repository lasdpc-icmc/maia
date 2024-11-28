from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, Trainer, TrainingArguments, TrainerCallback, DataCollatorWithPadding, DataCollatorForLanguageModeling
from trl import SFTTrainer
from peft import PeftConfig, PeftModel, LoraConfig
from datasets import load_dataset, Dataset
import torch
import numpy as np
from torch.nn import functional as F
import random

random.seed(10)

class MetricsCallback(TrainerCallback):
    """Callback for the performance metrics"""
    def on_evaluate(self, args, state, control, metrics, **kwargs):
        if state.is_world_process_zero:
            print(f"\nStep {state.global_step}:")
            print(f"  Loss: {metrics['eval_loss']:.4f}")

class PrintTrainLossCallback(TrainerCallback):
    """Callback to print training loss"""
    def on_log(self, args, state, control, logs=None, **kwargs):
        if state.is_world_process_zero and "loss" in logs:
            print(f"Step {state.global_step}: Training Loss: {logs['loss']:.4f}")



class SaveBestModelCallback(TrainerCallback):
    """Callback to save the best model to date"""
    def on_evaluate(self, args, state, control, metrics, **kwargs):
        metric_to_check = args.metric_for_best_model
        if not metric_to_check.startswith("eval_"):
            metric_to_check = f"eval_{metric_to_check}"
        
        metric_value = metrics.get(metric_to_check)
        
        if state.best_metric is None or (state.best_metric > metric_value and not args.greater_is_better) or (state.best_metric < metric_value and args.greater_is_better):
            print(f"\nNew best model! Saving model with {args.metric_for_best_model}: {metric_value}")
            state.best_metric = metric_value
            
            # Save the best model
            output_dir = f"{args.output_dir}/best_model"
            trainer.save_model(output_dir)


def load_model(model_path, bnb_config, attn_implementation):
    """ 
    Function that loads the specified model from HuggingFace

    Args: model_path (path of the model to be loaded from HF's transformers library)
          bnb_config (configuration for the quantization of the models weights using lora)
          attn_implementation (impletation algorithm for the self attention layers of the model)
    
    Returns: loaded model and tokenizer according to the specified input
    """

    print(f'Loading model: {model_path}')

    try:
        model= AutoModelForCausalLM.from_pretrained(model_path,quantization_config=bnb_config,
            device_map="auto",
            attn_implementation=attn_implementation,
            resume_download=True)
        tokenizer= AutoTokenizer.from_pretrained(model_path) 
    
    except Exception as e:
        print(f'Exception {e}! Unable to load model')
    
    return model, tokenizer


def load_split_dataset(train_path, val_path):
    """ 
    Function that loads the train and validation datasets

    Args: train_path (path of the training dataset)
          val_path (path of the validation dataset)
    
    Returns: Dataset objects containing the training and validation datasets
    """

    train_data = load_dataset("text", data_files={'data': train_path}, split="data[:100%]")
    val_data = load_dataset('text', data_files={'data': val_path}, split="data[:100%]")
    return train_data, val_data

train_data, val_data= load_split_dataset("/new/*.txt", 'out_val.txt')

model_name = 'meta-llama/Meta-Llama-3-8B'

bnb_config = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4", bnb_4bit_compute_dtype=torch.bfloat16, bnb_4bit_use_double_quant=True,)

if torch.cuda.is_available() and torch.cuda.get_device_capability()[0] >= 8:
        attn_implementation = "flash_attention_2"
        torch_dtype = torch.bfloat16

else:
        attn_implementation = "eager"
        torch_dtype = torch.float16

model, tokenizer = load_model(model_name, bnb_config, attn_implementation)


peft_config = LoraConfig(
        r=64,
        lora_alpha=16,
        lora_dropout=0.1,
        bias="none",
        task_type="CAUSAL_LM",
        target_modules=['up_proj', 'down_proj', 'gate_proj', 'k_proj', 'q_proj', 'v_proj', 'o_proj']
    )


args = TrainingArguments(
    output_dir="out",
    num_train_epochs=10,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8, 
    auto_find_batch_size=True,
    gradient_accumulation_steps=1,
    gradient_checkpointing=True,
    optim="adamw_torch",
    logging_steps=1,
    learning_rate=1e-4,
    bf16=True,
    tf32=False,
    weight_decay=0.01,
    max_grad_norm=0.3,
    lr_scheduler_type="cosine",
    logging_dir="out/logs",
    save_strategy="steps",
    save_steps=100,
    ddp_find_unused_parameters=False,
    dataloader_num_workers=4, 
    eval_strategy="steps",
    eval_steps=20,
    metric_for_best_model="loss",
    greater_is_better=False,
    save_total_limit=1,

tokenizer.pad_token = tokenizer.eos_token

trainer = SFTTrainer(
    model=model,
    args=args,
    train_dataset=train_data,
    eval_dataset=val_data,
    callbacks=[MetricsCallback(), SaveBestModelCallback(), PrintTrainLossCallback()],
    peft_config=peft_config,
    max_seq_length=256,
    tokenizer=tokenizer,
    dataset_text_field='text'
)

trainer.evaluate()

trainer.train()