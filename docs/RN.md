# Regra de Negócios

## Restrições e Validação de Conteúdo

### RN01 — Valor Mínimo da Sinopse
  O campo de sinopse do projeto deve validar a entrada de dados para garantir que o texto possua, no mínimo, X caracteres antes da confirmação de salvamento.

### RN02 — Modo de Texto Ilimitado
  Quando a configuração de limite global for desativada ("Ilimitado"), o sistema não deve aplicar travas de buffer ou contagem de caracteres nos campos de texto longo (áreas de descrição e notas).

## Lógica e Estrutura de Diagramação

### RN03 — Composição do Diagrama
  Todo diagrama deve ser obrigatoriamente composto por um conjunto de nós (representando entidades ou conceitos) e arestas (representando as conexões lógicas entre eles).

### RN04 — Vínculo de Arestas
  Uma aresta não pode existir de forma independente no plano de edição; ela deve obrigatoriamente possuir um nó de origem e um nó de destino vinculados.

### RN05 — Hierarquia de Nós e Grupos
  Cada nó individual pode ser independente (não pertencer a nenhum grupo) ou pertencer a múltiplos grupos.

### RN06 — Relação entre Entidades
  Os nós de um diagrama podem ser vinculados a entidades persistentes do sistema (Personagens ou Ideias), garantindo que alterações no nome ou status da entidade sejam refletidas automaticamente no diagrama.
