# Regras de Negócio

## Restrições e Validação de Conteúdo

### RN01 — Excluir conteúdo da pasta

  Ao excluir uma pasta, o sistema deve excluir o conteúdo dentro dela também com a confirmação do usuário

  Requisito relacionado: RF17

### RN02 — Limite de Upload de Imagens

  Os arquivos de imagem armazenados em ideias e perfis de personagens devem respeitar o limite máximo de 5 MB por arquivo para garantir a estabilidade do aplicativo.

  Requisitos relacionados: RF11, RF20

### RN03 — Nome Obrigatório para Personagem

  O sistema só deve permitir o cadastro de personagem quando o campo de nome estiver preenchido.

  Requisitos relacionados: RF18, RF19

### RN04 — Relevância Obrigatória para Personagem

  O sistema só deve permitir o cadastro de personagem quando a relevância estiver definida.

  Requisitos relacionados: RF18, RF19

### RN05 — Validação de Altura e Peso

  O sistema só deve permitir valores positivos para altura e peso no cadastro e na edição de personagens.

  Requisitos relacionados: RF18, RF19

### RN06 — Nome Obrigatório para Projeto

  O sistema só deve permitir a criação e edição de projeto quando o campo de nome estiver preenchido.

  Requisitos relacionados: RF01, RF02

### RN07 — Criação Automática de Pasta Raiz do Projeto

  Ao criar um novo projeto, o sistema deve criar automaticamente a pasta raiz correspondente na página de notas para organização dos conteúdos do projeto.

  Requisitos relacionados: RF01, RF14

### RN08 — Sincronização de Renomeação entre Projeto e Pasta Raiz

  Ao renomear um projeto, o sistema deve atualizar automaticamente o nome e os metadados da pasta raiz vinculada na página de notas.

  Requisitos relacionados: RF02, RF15

---

# BAIXA PRIORIDADE

## Lógica e Estrutura de Diagramação

### RN09 — Estrutura Mínima para Salvamento de Diagrama

  O sistema só deve permitir o salvamento de diagramas que contenham, no mínimo, dois nós conectados por ao menos uma aresta.

  Requisitos relacionados: RF30, RF34, RF37

### RN10 — Vínculo de Arestas

  Uma aresta não pode existir de forma independente no plano de edição; ela deve obrigatoriamente possuir um nó de origem e um nó de destino vinculados.

  Requisito relacionado: RF34

### RN11 — Exclusão em Cascata de Arestas

  Quando um nó for excluído, todas as suas arestas correspondentes devem ser excluídas também, conforme a regra RN10.
  
  Requisitos relacionados: RF36, RF39

### RN12 — Hierarquia de Nós e Grupos

  Cada nó individual pode ser independente (não pertencer a nenhum grupo) ou pertencer a múltiplos grupos.

  Requisitos relacionados: RF43, RF45, RF46, RF47

### RN13 — Sincronização de Entidades Vinculadas

  Sempre que a entidade persistente vinculada a um nó do diagrama for alterada, as propriedades refletidas nesse nó (como nome e status) devem ser atualizadas automaticamente.

  Requisito relacionado: RF33
