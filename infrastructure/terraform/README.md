# Kubernetes Service - EKS

**Visão Geral**
-------------------

O Amazon Elastic Kubernetes Service (Amazon EKS) é um serviço gerenciado de containers para executar e dimensionar aplicativos Kubernetes na nuvem.

**Infraestrutura**

- [Terraform EKS](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) ✅ - A base do cluster, usando o módulo Terraform **eks**, construímos o cluster na AWS com 2 node-pools, um on-demand e outro spot. Atualmente, temos 100% do cluster em uma máquina do tipo spot para economizar custos, com persistência de dados no **EBS**.
  
- [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) ✅ - O Ingress Nginx atua como um proxy para cargas de trabalho expostas por meio de objetos **ingress**. Além do ingress-nginx, temos um balanceador de carga de rede (**NLB**) L4, que apenas repassa para o ingress-nginx que pode analisar pacotes em L7.

- [EBS CSI](https://docs.aws.amazon.com/pt_br/eks/latest/userguide/ebs-csi.html) ✅ - O driver Container Storage Interface (CSI) do Amazon Elastic Block Store (Amazon EBS) gerencia o ciclo de vida dos volumes do Amazon EBS como armazenamento para Kubernetes Volumes que você criar. O driver CSI do Amazon EBS cria volumes do Amazon EBS para esses tipos de volumes: volumes efêmeros genéricos e Kubernetes volumes persistentes.


**Serviços de Aplicação**

- [Vault](https://www.vaultproject.io/) ✅ - O Hashicorp Vault protege, armazena e controla estritamente o acesso a tokens, senhas, certificados, chaves de API e outros segredos na computação moderna. Usamos o Vault como a principal fonte de arquivos sensíveis em geral. O **KMS** gerencia todos os tokens e os desbloqueia quando algum nó do Vault fica indisponível.

- [Cert Manager](https://cert-manager.io/) ✅ - O Cert Manager é uma ferramenta essencial no ecossistema do Kubernetes, projetada para simplificar e automatizar a gestão de certificados TLS (Transport Layer Security) em ambientes de contêineres. Sua função principal é facilitar a emissão, renovação e revogação de certificados digitais, proporcionando segurança na comunicação entre os componentes do Kubernetes.
  
- [External Secrets](https://external-secrets.io/v0.6.0-rc1/) - O External Secrets Operator é um operador Kubernetes que integra sistemas externos de gerenciamento de segredos, como o AWS Secrets Manager e o HashiCorp Vault. O operador lê informações de APIs externas e injeta automaticamente os valores em um Segredo do Kubernetes. O External Secrets se comunica com o Vault para mapear segredos em arquivos interpretados por aplicativos dentro do Kubernetes.
  
- [Velero](https://velero.io/docs/v1.9/) - O Velero atua como uma ferramenta de recuperação de desastres e backup para todos os componentes do EKS. O Velero usa o S3 como backend de armazenamento que persiste todos os backups salvos. Existem cron jobs configurados para que backups regulares sejam feitos diariamente para garantir a integridade do cluster.

**Monitoramento**

- [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) ✅ - Promtail é um agente que envia o conteúdo dos logs locais para uma instância privada do Grafana Loki ou Grafana Cloud. Geralmente é implantado em todas as máquinas que executam aplicativos que precisam ser monitorados. (**MSK**).
  
- [Kube Prometheus + Loki](https://github.com/prometheus-operator/kube-prometheus) ✅ - Esta stack é destinada ao monitoramento do cluster, sendo pré-configurada para coletar métricas de todos os componentes do Kubernetes. Além disso, oferece um conjunto padrão de dashboards e regras de alerta. Muitos dos painéis e alertas úteis vêm do projeto kubernetes-mixin, semelhante a este projeto, que fornece jsonnet componível como uma biblioteca para usuários personalizarem conforme necessário.
  
- [Kube Ops](https://github.com/hjacobs/kube-ops-view) - É uma stack de monitoramento dos componentes do EKS. O objetivo do kube-ops é fornecer uma imagem operacional comum para vários clusters Kubernetes, mostrando a capacidade do nó, renderizando nós e indicando seu status geral.
  
- [OpenCost](https://www.opencost.io/) ✅ - É uma solução de monitoramento de custos em níveis extremamente granulares (até o nível de custo do pod), para que possamos medir os custos de acordo com as cargas de trabalho, tags, componentes e sistemas.
  
- [Kube-Bench](https://blog.aquasec.com/announcing-kube-bench-an-open-source-tool-for-running-kubernetes-cis-benchmark-tests) - É uma ferramenta que verifica se o Kubernetes está implantado com segurança, executando as verificações documentadas no CIS Kubernetes Benchmark.
  
- [Prometheus BlackBox](https://github.com/prometheus/blackbox_exporter) - O blackbox exporter permite a sondagem de pontos de extremidade por meio de HTTP, HTTPS, DNS, TCP, ICMP e gRPC. Usamos como uma solução externa de monitoramento para atingir todos os serviços públicos, como Vault e Kubecost.