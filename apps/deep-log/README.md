# Deep Log Anomaly Detection System

**Table of Contents:**

1. [Introdução](#introdução)
2. [Visão Geral](#visão-geral)
3. [Requisitos](#requisitos)
4. [Configuração do Ambiente](#configuração-do-ambiente)
5. [Instruções de Uso](#instruções-de-uso)
    - [1. Coleta de Logs com Loki](#1-coleta-de-logs-com-loki)
    - [2. Pré-processamento de Logs com o Drain Parser](#2-pré-processamento-de-logs-com-o-drain-parser)
    - [3. Treinamento do Modelo DeepLog](#3-treinamento-do-modelo-deeplog)
    - [4. Previsão com o Modelo DeepLog](#4-previsão-com-o-modelo-deeplog)
    - [5. Métricas e Avaliação](#5-métricas-e-avaliação)
6. [Manutenção do Modelo](#manutenção-do-modelo)
7. [Licença](#licença)

## 1. Introdução <a name="introdução"></a>

Este é o README para o sistema de Detecção de Anomalias Deep Log, que permite a detecção automática de anomalias em registros de logs de sistemas de software. O sistema utiliza a técnica DeepLog, uma rede neural recorrente (RNN) desenvolvida para a tarefa de detecção de anomalias em logs de sistemas.

Este documento fornece uma visão geral do sistema, os requisitos para executá-lo, instruções detalhadas sobre como configurar e usar o sistema, bem como informações sobre a manutenção do modelo.

## 2. Visão Geral <a name="visão-geral"></a>

O sistema Deep Log é composto por vários componentes que trabalham juntos para detectar anomalias em logs de sistemas. Aqui está uma visão geral dos principais componentes:

- **Loki**: Loki é uma plataforma de agregação e consulta de logs. É usado para coletar registros de log de várias fontes e armazená-los em um local centralizado.

- **Drain Parser**: É responsável pelo pré-processamento dos registros de log brutos coletados pelo Loki. Ele remove informações irrelevantes, como timestamps e identificadores, e extrai os clusters de logs.

- **DeepLog**: DeepLog é o modelo de aprendizado profundo usado para detectar anomalias nos logs pré-processados. Ele é treinado em dados históricos e pode prever se um log é uma anomalia com base em seu padrão.

- **AWS S3**: O Amazon Simple Storage Service (S3) é usado para armazenar os dados de treinamento do modelo, bem como os resultados da detecção de anomalias.

## 3. Requisitos <a name="requisitos"></a>

Antes de usar o sistema Deep Log, você deve atender aos seguintes requisitos:

- Python 3.6 ou superior
- Conta na Amazon Web Services (AWS) com permissões para acessar o Amazon S3
- Uma instância do Loki configurada para coletar logs do sistema alvo

## 4. Configuração do Ambiente <a name="configuração-do-ambiente"></a>

Siga estas etapas para configurar seu ambiente antes de usar o sistema Deep Log:

## Dependencias

* python > 3.9
* Docker

```bash
virtualenv env
source env/bin/activate
pip install -r requirements.txt
```

```bash
docker build -t deep_log:v1 .
```

## Mock

1. [AWS CLI](https://aws.amazon.com/cli/) 
2. [Terraform](https://www.terraform.io/)
3. [tflocal](https://github.com/localstack/terraform-local)