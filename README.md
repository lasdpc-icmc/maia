# Projeto de Iniciação Cientifica - Análise conceitual e comparativa de métricas de aplicação em microsserviços

As constantes evoluções e integrações de tecnologias de sistemas complexos têm criado riscos relacionados a performance e confiabilidade, e podem comprometer a atribuição assumida por uma empresa ou prestador de serviços de tecnologia da informação perante um cliente.

Cada linguagem de programação tem sua particularidade e utiliza recursos conforme a expressividade de linguagem permitem. Como linguagens de programação são utilizadas para os mais diversos propósitos, convém que as métricas provenientes das execuções sigam o mesmo padrão, existem milhares de métricas passíveis de coleta em diversas stacks de desenvolvimento.

Uma métrica pode ser definida como um dado, ou uma agregação de dados que tem como finalidade trazer alguma informação relacionada ao estado de algum componente . Um conjunto de métricas pode ajudar a compor indicadores de desempenho como SLA (Service Level Agreement), SLI (Service Level Indicator) e SLO (Service Level Objective). A melhor maneira de monitorar o estado de um componente é coletar uma (ou mais) métricas referentes aos indicadores de desempenho, por exemplo: o consumo de memória RAM de uma instância virtual é uma métrica que pode ser coletada e utilizada com diagnóstico de saturação do recurso que está sendo monitorado.
 
 Ocorre que, o numero excessivo de métricas de runtime disponibilizadas por agentes coletores podem ser um problema na hora de escolher e agrupar quais destes indicadores são realmente importantes para que se possa visualizar, interpretar ou até mesmo predizer o comportamento de um microsserviço.

Na literatura não existem definições formais e descritivas de quais métricas, no contexto de cloud, devem ser levadas em consideração para realização de algum diagnóstico. O motivo para isso é simples, as diferentes soluções e arquiteturas presente em provedores de cloud têm comportamentos e contextos diferentes, o que torna complexa a tarefa de criar métricas genéricas que sejam incorporadas a qualquer ambiente.
