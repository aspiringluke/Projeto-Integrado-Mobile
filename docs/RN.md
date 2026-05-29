# Regras de Negócio

## Tela Inicial

### RN01 — Nome Obrigatório para Projeto

  O sistema só deve permitir a criação e edição de projeto quando o campo de nome estiver preenchido.

  Requisitos relacionados: RF01, RF03

### RN02 — Criação Automática de Pasta Raiz do Projeto

  Ao criar um novo projeto, o sistema deve criar automaticamente a pasta raiz correspondente na página de notas para organização dos conteúdos do projeto.

  Requisitos relacionados: RF01, RF15

### RN03 — Bloquear exclusão de pasta de projeto

  O sistema deve impedir a exclusão da pasta de um projeto enquanto este ainda existir

## Edição de projeto

### RN04 — Sincronização de Renomeação entre Projeto e Pasta Raiz

  Ao renomear um projeto, o sistema deve atualizar automaticamente o nome e os metadados da pasta raiz vinculada na página de notas.

  Requisitos relacionados: RF03, RF16

### RN05 — Nome Obrigatório para Tag e Grupo de Tags

  O sistema só deve permitir criar tags e grupos de tags quando o nome estiver preenchido.

  Requisitos relacionados: RF06, RF14

### RN06 — Não Repetir Tag Igual no Mesmo Grupo

  O sistema não deve permitir duas tags com o mesmo nome dentro do mesmo grupo.

  Requisitos relacionados: RF06, RF14

### RN07 — Reaproveitar Tag e Grupo Já Existentes

  Quando o usuário informar o nome de uma tag ou grupo que já existe, o sistema deve reaproveitar o cadastro existente em vez de criar outro.

  Requisitos relacionados: RF06, RF14

### RN08 — Criar Grupo Automaticamente ao Salvar Tag

  Se uma tag for salva para um grupo que ainda não existe, o sistema deve criar esse grupo antes de salvar a tag.

  Requisitos relacionados: RF06, RF14

## Gerenciamento de notas

## Edição de Notas

### RN09 — Vinculação de Nota ao Projeto por Pasta Raiz

  Ao vincular uma nota a um projeto, o sistema deve direcioná-la para a pasta raiz correspondente na página de notas, criando essa pasta quando necessário.

  Requisitos relacionados: RF08, RF17

### RN10 — Título Efetivo para Nota

  O sistema deve garantir que toda nota tenha um título efetivo, aplicando "Sem título" quando o usuário salvar sem informar título.

  Requisitos relacionados: RF08, RF13

### RN11 — Não Repetir Tag na Mesma Classificação da Nota

  Dentro da mesma classificação da nota, o sistema não deve permitir tags com nomes repetidos.

  Requisitos relacionados: RF14

## Gerenciamento de Pastas

### RN12 — Nome Obrigatório para Pasta

  O sistema só deve permitir a criação e edição de pastas quando o campo de nome estiver preenchido.

  Requisitos relacionados: RF15, RF16

### RN13 — Restrição de Auto-Contenção de Pasta

  O sistema não deve permitir mover uma pasta para dentro dela mesma.

  Requisitos relacionados: RF17

### RN14 — Excluir conteúdo da pasta

  Ao excluir uma pasta, o sistema deve excluir o conteúdo dentro dela também com a confirmação do usuário

  Requisito relacionado: RF18

### RN15 — Proteção de Pasta Raiz de Projeto

  A pasta raiz vinculada ao projeto na página de notas não pode ser excluída.

  Requisitos relacionados: RF18

### RN16 — Exclusão de Conteúdo da Pasta Raiz de Projeto

  Para pastas raiz de projeto na página de notas, o sistema deve permitir apenas a exclusão do conteúdo interno, preservando a pasta raiz.

  Requisitos relacionados: RF18

## Edição de Projeto (Aba de Gerenciamento de Personagens)

### RN17 — Nome Obrigatório para Personagem

  O sistema só deve permitir o cadastro de personagem quando o campo de nome estiver preenchido.

  Requisitos relacionados: RF20, RF21

### RN18 — Relevância Obrigatória para Personagem

  O sistema só deve permitir o cadastro de personagem quando a relevância estiver definida.

  Requisitos relacionados: RF20, RF21

### RN19 — Validação de Altura e Peso

  O sistema só deve permitir valores positivos para altura e peso no cadastro e na edição de personagens.

  Requisitos relacionados: RF20, RF21

### RN20 — Limite de Upload de Imagens

  Os arquivos de imagem armazenados em ideias e perfis de personagens devem respeitar o limite máximo de 30 MB por arquivo para garantir a estabilidade do aplicativo.

  Requisitos relacionados: RF12, RF22

## Configurações gerais

## Modelo de IA

### RN21 — Restrição de nulidade

  As mensagens enviadas para o chatbot não podem ser vazias.

  Requisitos relacionados: RF28

# BAIXA PRIORIDADE

## Gerenciamento de Diagramas

### RN22 — Estrutura Mínima para Salvamento de Diagrama

  O sistema só deve permitir o salvamento de diagramas que contenham, no mínimo, dois nós conectados por ao menos uma aresta.

  Requisitos relacionados: RF34, RF38, RF41

## Edição de Diagramas

### RN23 — Vínculo de Arestas

  Uma aresta não pode existir de forma independente no plano de edição; ela deve obrigatoriamente possuir um nó de origem e um nó de destino vinculados.

  Requisito relacionado: RF38

### RN24 — Exclusão em Cascata de Arestas

  Quando um nó for excluído, todas as suas arestas correspondentes devem ser excluídas também, conforme a regra RN22.
  
  Requisitos relacionados: RF40, RF43

### RN25 — Hierarquia de Nós e Grupos

  Cada nó individual pode ser independente (não pertencer a nenhum grupo) ou pertencer a múltiplos grupos.

  Requisitos relacionados: RF47, RF49, RF50, RF51

### RN26 — Sincronização de Entidades Vinculadas

  Sempre que a entidade persistente vinculada a um nó do diagrama for alterada, as propriedades refletidas nesse nó (como nome e status) devem ser atualizadas automaticamente.

  Requisito relacionado: RF37
