# Requisitos Funcionais (RF)

## Tela Inicial

### RF01 - Criação de Projeto

  O sistema deve permitir ao usuário a criação de novos projetos.

### RF02 - Exclusão de Projeto

  O sistema deve permitir a exclusão de um projeto existente



## Edição de projeto

### RF02 - Editar informações

  O sistema deve permitir ao usuário alterar o nome e a sinopse do projeto.

### RF03 - Imagem do projeto

  O sistema deve permitir ao usuário enviar ou remover uma imagem do cartão do projeto, podendo alterar o modo de mesclagem.

### RF04 - Cor do projeto

  O sistema deve permitir ao usuário escolher uma cor de fundo para aparecer no cartão do projeto, podendo alterar o modo de mesclagem.

### RF05 - Tags do projeto

  O sistema deve permitir ao usuário inserir e remover tags do projeto.

### RF06 - Personagens do cartão de projeto

  O sistema deve permitir ao usuário selecionar personagens do projeto cujas imagens aparecerão no respectivo cartão.


---


## Gerenciamento de notas

### RF07 - Criação de notas

  O sistema deve permitir ao usuário o registro de notas de texto

### RF08 - Exclusão de notas

  O sistema deve permitir a exclusão permanente de registros de notas.

### RF09 - Organizar notas em pastas

  O sistema deve permitir ao usuário organizar suas notas em pastas.


---


## Edição de Notas

### RF10 - Editar texto da nota

  O sistema deve permitir ao usuário editar o texto das notas.

### RF11 - Adicionar imagens às notas

  O sistema deve permitir o armazenamento de arquivos de imagem referentes às notas.

### RF12 - Atribuir títulos às notas

  O sistema deve permitir ao usuário adicionar títulos às notas criadas.

### RF13 - Adicionar tags às notas

  O sistema deve permitir ao usuário adicionar e atribuir tags às notas criadas.


---


## Gerenciamento de Pastas

### RF14 - Criação de Pastas

  O sistema deve permitir ao usuário a criação de diretórios para organizar o conteúdo geral do projeto.

### RF15 - Renomear pastas

  O sistema deve permitir a alteração dos nomes identificadores de pastas já existentes.

### RF16 - Mover itens para uma pasta

  O sistema deve permitir a alteração da localização de arquivos e itens entre diferentes pastas.

### RF17 - Exclusão de pastas

  O sistema deve permitir a remoção de pastas

### RF18 - Alterar cor da pasta

  O sistema deve permitir alterar a cor de realce das pastas

---

## Edição de Projeto (Aba de Gerenciamento de Personagens)

### RF18 - Criação de Personagens

  O sistema deve permitir ao usuário a inclusão de novos personagens no banco de dados do projeto.

### RF19 (Pers.) - Edição de Dados de Personagens

  O sistema deve permitir a modificação das fichas técnicas e campos cadastrais dos personagens.

### RF20 (Pers.) - Upload de Imagens de Personagem

  O sistema deve permitir o armazenamento de arquivos de imagem no perfil do personagem.

### RF21 - Alterar cores do personagem

  O sistema deve permitir ao usuário alterar as cores de capa e realce do personagem

### RF21 - Exclusão de personagens

  O sistema deve permitir a remoção definitiva de personagens do projeto.
 

---


## Configurações gerais

### RF22 - Configuração de Senha de Acesso

  O sistema deve permitir ao usuário definir uma senha para o aplicativo.

### RF24 - Seleção de Idiomas

  O sistema deve permitir a troca de idiomas de acordo com a preferência do usuário.

### RF25 - Modo Desempenho

  O sistema deve possuir um "Modo Desempenho".


---

## Modelo de IA

### RF26 - Conversação interativa com modelo de IA

  O usuário poderá conversar com um modelo de inteligência artificial através de mensagens de texto

### RF27 - Envio de contexto ao modelo de IA

  O sistema deve poder enviar dados do aplicativo ao modelo de IA como contexto aos pedidos do usuário

### RF28 - Histórico de conversas

  O sistema deve armazenar as conversas do usuário de forma persistente, permitindo-o revisitar contextos anteriores. O sistema também deve permitir a renomeação e a exclusão de conversas


---


## Funções de Busca

### RF27 (Busca) - Filtrar itens por atributos ou tags

  O sistema deve permitir a filtragem de elementos do projeto com base em categorias ou etiquetas pré-definidas.

### RF28 (Busca) - Ordenar itens por atributos ou tags

  O sistema deve permitir a organização da visualização de itens por ordem alfabética, data ou tags.

### RF29 (Busca) - Buscar itens por atributos ou tags

  O sistema deve oferecer um campo de pesquisa global para encontrar itens (notas, personagens e demais elementos do projeto) via metadados.


---


# BAIXA PRIORIDADE

---


## Gerenciamento de Diagramas

### RF30 - Criar diagramas

  O sistema deve permitir ao usuário criar diagramas.

### RF31 - Excluir diagramas

  O sistema deve permitir ao usuário excluir diagramas.

### RF32 - Organizar diagramas em pastas

  O sistema deve permitir a criação de pastas específicas para o armazenamento e categorização de diferentes diagramas.


---


## Edição de Diagramas

### RF33 - Vincular nó a entidade persistente

  O sistema deve permitir vincular um nó do diagrama a uma entidade persistente do projeto, como Personagem ou Ideia.

### RF34 - Criar arestas

  O sistema deve permitir a criação e manipulação de arestas para conectar nós no diagrama.

### RF35 - Adicionar descrição à aresta

  O sistema deve permitir ao usuário a inserção de textos detalhados ou notas explicativas vinculadas a uma aresta.

### RF36 - Exclusão de arestas

  O sistema deve excluir automaticamente arestas

### RF37 - Inserir nó

  O sistema deve permitir a adição de novos pontos de informação (nós) no plano de edição do diagrama.

### RF38 - Mover nó

  O sistema deve permitir o reposicionamento espacial dos nós através de interface de arrastar e soltar.

### RF39 - Excluir nó

  O sistema deve permitir a remoção definitiva de um nó do diagrama.

### RF40 - Renomear nó

  O sistema deve permitir a alteração do rótulo textual de identificação de um nó.

### RF41 - Alterar tag do nó

  O sistema deve permitir a atribuição ou modificação de etiquetas de categorização em um nó.

### RF42 - Adicionar descrição ao nó

  O sistema deve permitir a inserção de textos detalhados ou notas explicativas vinculadas a um nó.

### RF43 - Criar grupo de nós

  O sistema deve permitir o agrupamento de múltiplos nós para tratamento coletivo.

### RF44 - Renomear grupo de nós

  O sistema deve permitir a edição do nome identificador de um grupo de nós.

### RF45 - Inserir nós em grupos

  O sistema deve permitir a inclusão de nós individuais dentro de grupos já existentes.

### RF46 - Remover nós de grupo

  O sistema deve permitir retirar um nó de um grupo sem excluí-lo do diagrama.

### RF47 - Alternar visibilidade do grupo

  O sistema deve permitir ocultar ou exibir grupos inteiros para facilitar a navegação no diagrama.

### RF48 - Excluir grupo

  O sistema deve permitir ao usuário excluir grupos de nós.

### RF49 - Aplicar buscas em diagramas

  O sistema deve permitir a localização de elementos específicos dentro de um diagrama através de palavras-chave.

