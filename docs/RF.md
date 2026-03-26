# Requisitos Funcionais (RF)

## Tela Inicial

### RF01 - Criação de Projeto

  O sistema deve permitir ao usuário a criação de novos projetos


---


## Funções de Busca

### RF02 (Busca) - Filtrar itens por atributos ou tags

  O sistema deve permitir a filtragem de elementos do projeto com base em categorias ou etiquetas pré-definidas.

### RF03 (Busca) - Ordenar itens por atributos ou tags

  O sistema deve permitir a organização da visualização de itens por ordem alfabética, data ou tags.

### RF04 (Busca) - Buscar itens por atributos ou tags

  O sistema deve oferecer um campo de pesquisa global para encontrar itens (ideias/personagens) via metadados.


---


## Gerenciamento de Diagramas

### RF05 - Criar diagramas

  O sistema deve permitir ao usuário criar diagramas

### RF06 - Excluir diagrmas

  O sistema deve permitir ao usuário excluir diagramas

### RF07 - Organizar diagramas em pastas

  O sistema deve permitir a criação de pastas específicas para o armazenamento e categorização de diferentes diagramas.


---


## Edição de Diagramas

### RF08 - Estrutura Mínima de um Diagrama

  O sistema deve impedir o salvamento de diagramas que não contenham, no mínimo, dois nós conectados por ao menos uma aresta, garantindo a integridade da relação lógica.

### RF09 - Sincronização de Dados de Entidades no Diagrama

  O sistema deve atualizar automaticamente as propriedades visualizadas nos nós do diagrama (como nome e status) sempre que a entidade persistente correspondente (Personagem ou Ideia) for alterada em qualquer outra parte do sistema.

### RF10 - Criar arestas

  O sistema deve permitir a criação e manipulação de arestas para conectar nós no diagrama, impedindo a existência de conexões órfãs no plano de edição.

### RF11 - Adicionar descrição à aresta

  O sistema deve permitir ao usuário a inserção de textos detalhados ou notas explicativas vinculadas a uma aresta.

### RF12 - Inserir nó

  O sistema deve permitir a adição de novos pontos de informação (nós) no plano de edição do diagrama.

### RF13 - Mover nó

  O sistema deve permitir o reposicionamento espacial dos nós através de interface de arrastar e soltar.

### RF14 - Excluir nó

  O sistema deve permitir a remoção definitiva de um nó e suas conexões associadas.

### RF15 - Renomear nó

  O sistema deve permitir a alteração do rótulo textual de identificação de um nó.

### RF16 - Alterar tag do nó

  O sistema deve permitir a atribuição ou modificação de etiquetas de categorização em um nó.

### RF17 - Adicionar descrição ao nó

  O sistema deve permitir a inserção de textos detalhados ou notas explicativas vinculadas a um nó.

### RF18 - Criar grupo de nós

  O sistema deve permitir o agrupamento de múltiplos nós para tratamento coletivo.

### RF19 - Renomear grupo de nós

  O sistema deve permitir a edição do nome identificador de um grupo de nós.

### RF20 - Inserir nós em grupos

  O sistema deve permitir a inclusão de nós individuais dentro de grupos já existentes.

### RF21 - Remover nós de grupo

  O sistema deve permitir retirar um nó de um grupo sem excluí-lo do diagrama.

### RF22 - Alternar visibilidade do grupo

  O sistema deve permitir ocultar ou exibir grupos inteiros para facilitar a navegação no diagrama.

### RF23 - Excluir grupo

  O sistema deve permitir ao usuário excluir grupos de nós

### RF24 - Aplicar buscas em diagramas

  O sistema deve permitir a localização de elementos específicos dentro de um diagrama através de palavras-chave.


---


## Gerenciamento de Ideias

### RF25 - Criação de Ideias

  O sistema deve permitir ao usuário o registro inicial de novos conceitos ou fragmentos de história.

### RF26 - Exclusão de ideias

  O sistema deve permitir a exclusão permanente de registros de ideias.

### RF27 - Organizar ideias em Pastas

  O sistema deve permitir ao usuário organizar suas ideias em pastas


---


## Edição de Ideias

### RF28 - Editar Texto da Ideia

  O sistema deve permitir ao usuário editar o texto das ideias

### RF29 - Adicionar Imagens às Ideias

  O sistema deve permitir o armazenamento de arquivos de imagem referentes às ideias

### RF30 - Atribuir títulos às Ideias

  O sistema deve permitir ao usuário adicionar títulos às ideias criadas

### RF31 - Adicionar tags às ideias

  O sistema deve permitir ao usuário adicionar e atribuir tags às ideias criadas


---


## Gerenciamento de Pastas

### RF32 - Criação de Pastas

  O sistema deve permitir ao usuário a criação de diretórios para organizar o conteúdo geral do projeto.

### RF33 - Definir título de Pastas

  O sistema deve permitir a atribuição de nomes identificadores às pastas criadas.

### RF34 - Mover itens para uma Pasta

  O sistema deve permitir a alteração da localização de arquivos e itens entre diferentes pastas.

### RF35 - Exclusão de pastas

  O sistema deve permitir a remoção de pastas e, opcionalmente, de seu conteúdo.

### RF36 - Interatividade Drag-and-Drop

  O sistema deve implementar a funcionalidade de "arrastar e soltar" para a movimentação de nós e organização de itens em pastas, visando a facilidade de uso.


---


## Edição de Projeto (Aba de Gerenciamento de Personagens)

### RF37 - Criação de Personagens

  O sistema deve permitir ao usuário a inclusão de novos personagens no banco de dados do projeto.

### RF38 (Pers.) - Edição de Dados de Personagens

  O sistema deve permitir a modificação das fichas técnicas e campos cadastrais dos personagens.

### RF39 (Pers.) - Upload de Imagens de Personagem

  O sistema deve permitir o armazenamento de arquivos de imagem no perfil do personagem.

### RF40 (Pers.) - Organizar personagens em pastas

  O sistema deve permitir a categorização de personagens em pastas.

### RF41 - Criar diagramas para relacionar personagens

  O sistema deve permitir a criação de mapas visuais focados na árvore genealógica ou relações interpessoais.

### RF42 - Exclusão de personagens

  O sistema deve permitir a remoção definitiva de personagens do projeto.
 

---


## Configuração gerais

### RF43 - Configuração de Senha de Acesso

  O sistema deve permitir ao usuário definir uma senha para o aplicativo.

### RF44 - Configuração de limite de caracteres

  O sistema deve permitir que o usuário configure o limite de caracteres da sinopse, dentro de um intervalo pré-definido.
  
### RF45 - Seleção de Idiomas

  O sistema deve permitir a troca de idiomas de acordo com a preferência do usuário.

### RF46 - Modo Desempenho

  O sistema deve possuir um "Modo Desempenho"

### RF47 - Assistente de Insights Contextuais (IA)

  O sistema deve fornecer uma funcionalidade de inteligência artificial que, ao ser acionada, analisa o conteúdo da página ou diretório atual
  (Projetos, Personagens, Ideias ou Diagramas) para gerar insights, perfis de personagem e auxílio na organização


---


## Edição de projeto

### RF48 - Editar informações
O usuário poderá alterar o **nome** e a **sinopse** do projeto

### RF49 - Imagem do projeto
O usuário poderá enviar uma imagem para aparecer no cartão do projeto, bem como removê-la, podendo alterar o modo de mesclagem

### RF50 - Cor do projeto
O usuário poderá escolher uma cor de fundo para aparecer no cartão do projeto, podendo alterar o modo de mesclagem

### RF51 - Tags do projeto
O usário poderá inserir e remover tags ao projeto

### RF52 - Personagens do cartão de projeto
O usuário poderá selecionar personagens do projeto cujas imagens aparecerão no respectivo cartão
