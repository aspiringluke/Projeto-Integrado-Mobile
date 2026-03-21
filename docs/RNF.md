# Requisitos Não Funcionais (RNF)

## Portabilidade

### RNF01 (Portabilidade — Adaptabilidade) - Tela Responsiva

  A interface deve ser responsiva e manter a integridade do layout em diferentes tamanhos de tela.

#### Critérios de Avaliação

- C1: O layout deve se adaptar sem perda de funcionalidade ou sobreposição de elementos em viewports que variam de 320dp (smartphones pequenos) a 1280dp (tablets em modo paisagem).
- C2: Elementos de interação (botões e nós de diagramas) devem manter uma área de toque mínima de 48x48dp para garantir acessibilidade em dispositivos móveis.

#### Relacionados aos Requisitos Funcionais

- RF01
- RF05
- RF13
- RF35

## Eficiência de Desempenho

### RNF02 (Eficiência de Desempenho — Utilização de Recursos) - Modo Desempenho

  No "Modo Desempenho" o sistema deve consumir até 150 MB de RAM.

#### Critérios de Avaliação

- C1: Quando ativado, o consumo de memória do aplicativo não deve exceder 150MB em dispositivos de entrada (Android Go/iOS antigo).
- C2: O sistema deve suspender animações de transição de tela e reduzir a fidelidade visual de sombras no editor de diagramas para priorizar a CPU.

#### Relacionados aos Requisitos Funcionais

- RF35
- RF45

### RNF03 (Eficiência de Desempenho — Comportamento em Relação ao Tempo) - Latência de Busca

  O mecanismo de busca interna deve processar as consultas e retornar os resultados na interface do usuário em um tempo de resposta inferior a 200 ms.
  
#### Critérios de Avaliação

- C1: Buscas locais (em cache) devem retornar resultados em menos de 200ms.
- C2: A interface de busca deve implementar "Debounce" de 300ms para evitar chamadas excessivas ao banco de dados enquanto o usuário digita.

#### Relacionados aos Requisitos Funcionais

- RF02
- RF03
- RF04
- RF23

### RNF04 (Eficiência de Desempenho — Comportamento em Relação ao Tempo) - Renderização em Tempo Real

  O motor gráfico do editor de diagramas deve suportar atualizações visuais instantâneas (abaixo de 16.6 ms de latência) durante a manipulação de elementos.

#### Critérios de Avaliação

- C1: A movimentação de nós (Drag-and-Drop) deve manter uma taxa de quadros de 60 FPS (latência de renderização < 16.6ms por quadro).
- C2: A reconexão visual de arestas durante o movimento do nó deve ser processada sem "ghosting" ou atraso perceptível ao olho humano.

#### Relacionados aos Requisitos Funcionais

- RF10
- RF13

#### Relacionados às Regras de Negócio

- RN03
- RN04

### RNF05 (Eficiência de Desempenho — Capacidade) - Limite de Upload

  Os arquivos de imagem armazenados no perfil dos personagens devem respeitar o limite máximo de 5 MB por arquivo para garantir a estabilidade do servidor.

#### Critérios de Avaliação

- C1: O sistema deve validar e impedir o upload de arquivos maiores que 5MB por imagem.
- C2: O aplicativo deve realizar compressão automática (Lossy compression) em imagens de perfil para garantir que o armazenamento interno do dispositivo não seja sobrecarregado.

#### Relacionados aos Requisitos Funcionais

- RF28
- RF38

## Confiabilidade

### RNF06 (Confiabilidade — Recuperabilidade) - Persistência Automática

  O editor deve garantir a integridade dos dados através de salvamento automático após o usuário finalizar alguma adição ou alteração de dados.
  
#### Critérios de Avaliação

- C1: O sistema deve processar a persistência dos dados no banco local em até 500ms após o acionamento dos gatilhos de confirmação.
- C2: Em caso de fechamento abrupto do app (crash ou kill pelo SO), o usuário não deve perder mais do que as últimas 2 alterações realizadas.

#### Relacionados aos Requisitos Funcionais

- RF09
- RF27

#### Relacionados às Regras de Negócio

- RN07
