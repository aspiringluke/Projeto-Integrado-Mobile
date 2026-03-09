# Requisitos Não Funcionais (RNF)

## Portabilidade

- ### RNF01 (Portabilidade - Adaptabilidade) — Tela Responsiva:
  A interface deve ser responsiva e manter a integridade do layout em diferentes tamanhos de tela.

## Eficiência de Desempenho

- ### RNF02 (Eficiência de Desempenho — Utilização de Recursos) — Modo Desempenho:
  O sistema deve possuir um "Modo Desempenho" em que o sistema consome até X MB de RAM.

- ### RNF03 (Eficiência de Desempenho — Comportamento em Relação ao Tempo) — Latência de Busca:
  O mecanismo de busca interna deve processar as consultas e retornar os resultados na interface do usuário em um tempo de resposta inferior a 500ms.

- ### RNF04 (Eficiência de Desempenho — Comportamento em Relação ao Tempo) — Renderização em Tempo Real:
  O motor gráfico do editor de diagramas deve suportar atualizações visuais instantâneas (abaixo de 100ms de latência) durante a manipulação de elementos.

- ### RNF05 (Eficiência de Desempenho — Capacidade) — Limite de Upload:
  O sistema deve processar e armazenar arquivos de imagem de referência, respeitando o limite máximo de X MB por arquivo para garantir a estabilidade do servidor.

## Usabilidade

- ### RNF06 (Usabilidade — Operacionalidade) — Interatividade Drag-and-Drop:
  A interface de edição de diagramas deve implementar a funcionalidade de "arrastar e soltar" para a movimentação de nós e organização de itens em pastas, visando a facilidade de uso.

## Confiabilidade

- ### RNF07 (Confiabilidade — Recuperabilidade) — Persistência Automática:
  O editor deve garantir a integridade dos dados através de salvamento automático em intervalos regulares ou acionamento imediato sob comando do usuário, prevenindo a perda de progresso em caso de falha.
