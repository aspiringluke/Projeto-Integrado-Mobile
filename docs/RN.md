# Regras de Negócio

## Restrições e Validação de Conteúdo

### RN01 — Limite da Sinopse

  O valor configurado para o limite de caracteres da sinopse deve permanecer abaixo de um limite pré-definido pelo sistema.

  Requisito relacionado: RF23

### RN02 — Modo de Texto Ilimitado

  Quando a configuração de limite global for desativada ("Ilimitado"), o sistema não deve aplicar travas de buffer ou contagem de caracteres nos campos de texto longo (áreas de descrição e notas).

  Requisito relacionado: RF23

### RN03 — Excluir conteúdo da pasta

  Ao excluir uma pasta, o sistema deve excluir o conteúdo dentro dela também com a confirmação do usuário

  Requisito relacionado: RF17

---

# BAIXA PRIORIDADE

## Lógica e Estrutura de Diagramação

### RN04 — Estrutura Mínima para Salvamento de Diagrama

  O sistema só deve permitir o salvamento de diagramas que contenham, no mínimo, dois nós conectados por ao menos uma aresta.

  Requisitos relacionados: RF30, RF34, RF37

### RN05 — Vínculo de Arestas

  Uma aresta não pode existir de forma independente no plano de edição; ela deve obrigatoriamente possuir um nó de origem e um nó de destino vinculados.

  Requisito relacionado: RF34

### RN06 — Exclusão em Cascata de Arestas

  Quando um nó for excluído, todas as suas arestas correspondentes devem ser excluídas também, conforme a regra RN05.
  
  Requisitos relacionados: RF36, RF39

### RN07 — Hierarquia de Nós e Grupos

  Cada nó individual pode ser independente (não pertencer a nenhum grupo) ou pertencer a múltiplos grupos.

  Requisitos relacionados: RF43, RF45, RF46, RF47

### RN08 — Sincronização de Entidades Vinculadas

  Sempre que a entidade persistente vinculada a um nó do diagrama for alterada, as propriedades refletidas nesse nó (como nome e status) devem ser atualizadas automaticamente.

  Requisito relacionado: RF33
