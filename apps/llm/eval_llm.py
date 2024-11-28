import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, StoppingCriteria, StoppingCriteriaList
from peft import PeftModel, PeftConfig
from sentence_transformers import SentenceTransformer
from bert_score import score

class StopOnNewline(StoppingCriteria):
    """ StoppingCriteria to stop the generation after a \n character. This is used to make the model generate a log message at a time """
    def __init__(self, tokenizer):
        self.tokenizer = tokenizer
        self.newline_id = tokenizer.encode('\n', add_special_tokens=False)[0]
    
    def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor, **kwargs) -> bool:
        if input_ids[0, -1] == self.newline_id:
            return True
        return False



def load_instantiate_models(gen_model_name,sim_model_name,bnb_config,attn_implementation,finetuned=None):
    """
    Function that loads a HuggingFace model to generate logs and a sentence similarity model to compute similarity scores between generated logs and registered blocks

    Args: gen_model_name (name/path of the model to use for log generation)
          sim_model_name (name/path of the model to use for scoring the similarity of generated and registered logs)
          bnb_config (configuration for the quantization of the models weights using lora)
          attn_implementation (impletation algorithm for the self attention layers of the model)
          finetuned (flag indicating if the provided gen_model_name is a model finetuned on logs or a model from HuggingFace)
    
    Returns: Both loaded log generation and similarity models, and the tokenizer
    """

    print("Loading generation model...")
    
    if finetuned != None:
        try:
            peft_config = PeftConfig.from_pretrained(finetuned)
            gen_model = AutoModelForCausalLM.from_pretrained(
            peft_config.base_model_name_or_path,
            quantization_config=bnb_config,
            device_map="auto",
            attn_implementation=attn_implementation,
            resume_download=True
            )
            model = PeftModel.from_pretrained(gen_model, finetuned)
            print("Fine-tuned model loaded successfully")
    
        except Exception as e:
            print(f"Error loading fine-tuned model: {e}")
            print("Falling back to pretrained model")
            gen_model = AutoModelForCausalLM.from_pretrained(
            gen_model_name,
            quantization_config=bnb_config,
            device_map="auto",
            attn_implementation=attn_implementation,
            resume_download=True
            )
    
    else:
        print(f'Using pretrained generation model: {gen_model_name}')
        gen_model = AutoModelForCausalLM.from_pretrained(
            gen_model_name,
            quantization_config=bnb_config,
            device_map="auto",
            attn_implementation=attn_implementation,
            resume_download=True
            )
    
    print(f"Loading sentence similarity model: {sim_model_name}")

    sim_model = SentenceTransformer(sim_model_name)

    return {
        'gen_model': gen_model,
        'gen_tokenizer': AutoTokenizer.from_pretrained(gen_model_name),
        'sim_model': sim_model
    }


def gen_block(models,context_blocks):
    """
    Funtion that generates a log block. For each given context block, a log message is generated and appended to the generated log block.
    
    Args: models (the log generation and similarity models, as well as the tokenizer)
          context_blocks (the previous windows of logs to generate the new log block)
    
    Returns: the generated log block
    """

    stopping_criteria = StoppingCriteriaList([StopOnNewline(models['gen_tokenizer'])])

    gen_block = []

    for block in context_blocks:
        tokenized_block = models['gen_tokenizer'](block, return_tensors="pt").to(device)
        input_ids = tokenized_block['input_ids']

        outputs = models['gen_model'].generate(**tokenized_block,max_new_tokens=128, stopping_criteria=stopping_criteria, return_dict_in_generate=True, output_scores=True)

        generated_tokens = outputs.sequences[:, input_ids.shape[-1]:]

        gen_log = models['gen_tokenizer'].decode(generated_tokens[0],skip_special_tokens=True)

        gen_block.append(gen_log)
    
    return ''.join(gen_block)

def compute_similarity(models,model_gen_block,registered_block):
    """
    Function that computes the similarity between two log blocks.

    Args: models (the log generation and similarity models, as well as the tokenizer)
          model_gen_block (the generated block)
          registered_block (the registered block)
    
    Returns: the similarity score between the generated score and the registered blocks
    """
    embeddings = models['sim_model'].encode([model_gen_block,registered_block])

    similarity_matrix = models['sim_model'].similarity(embeddings,embeddings)
    sim_score = similarity_matrix[0][1].detach().item()

    with open('out_teste.txt','a') as out_fp:
        out_fp.write('REGISTERED BLOCK: \n'+registered_block)
        out_fp.write('\n')
        out_fp.write('GENERATED BLOCK: \n'+model_gen_block)
        out_fp.write('\n')
        out_fp.write('SIM SCORE ' + str(sim_score))
        out_fp.write('\n')
        out_fp.flush()

    return sim_score

def detect_anomalies(models,context_size,in_file,sim_th):
    num_anomalies = 0
    """
    Function that detects anomalies on blocks of a log file
    
    Args: models (the log generation and similarity models, as well as the tokenizer)
          context_size (the number of log messages that are used to predict the next log message)
          in_file (the file containing the logs that may have anomalies)
          sim_th (the threshold value to consider a log block anomalous)
    
    Returns: void
    """

    print(f'Opening file: {in_file}')

    try:
        in_fp = open(in_file,'r')
        print('File opened successfully')
    
    except FileNotFoundError:
        print('File not found!')
        return
    
    cur_block = []
    context_blocks = []

    while log := in_fp.readline():

        cur_block.append(log)

        if len(cur_block) == context_size:
            cur_block_str = ''.join(cur_block)

            context_blocks.append(cur_block_str)

            if len(context_blocks) == context_size:
                model_gen_block = gen_block(models, context_blocks)

                registered_block = list(cur_block)
                registered_block.pop(0)

                cur_fp = in_fp.tell()
                registered_block.append(in_fp.readline())
                in_fp.seek(cur_fp)

                registered_block = ''.join(registered_block)

                sim_score = compute_similarity(models,model_gen_block,registered_block)

                if sim_score < sim_th:
                    num_anomalies += 1
                context_blocks.pop(0)

            cur_block.pop(0)
    
        print(f'Detected {num_anomalies} anomalies')

    return


bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,
)

if torch.cuda.is_available() and torch.cuda.get_device_capability()[0] >= 8:
        attn_implementation = "flash_attention_2"
        torch_dtype = torch.bfloat16

else:
        attn_implementation = "eager"
        torch_dtype = torch.float16

device = 'cuda' if torch.cuda.is_available() else 'cpu'

models = load_instantiate_models("meta-llama/Meta-Llama-3-8B","sentence-transformers/all-mpnet-base-v2",bnb_config,attn_implementation,finetuned='out/best_model')

detect_anomalies(models,10,"teste.txt",0.8)