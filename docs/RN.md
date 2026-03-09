# Regra de Negócios

## Restrições e Validação de Conteúdo

- ### RN01 — Valor Mínimo da Sinopse
  O campo de sinopse do projeto deve validar a entrada de dados para garantir que o texto possua, no mínimo, X caracteres antes da confirmação de salvamento.

- ### RN02 — Modo de Texto Ilimitado
  Quando a configuração de limite global for desativada ("Ilimitado"), o sistema não deve aplicar travas de buffer ou contagem de caracteres nos campos de texto longo (áreas de descrição e notas).

## Lógica e Estrutura de Diagramação

- ### RN03 — Composição do Diagrama
  Todo diagrama deve ser obrigatoriamente composto por um conjunto de nós (representando entidades ou conceitos) e arestas (representando as conexões lógicas entre eles).

- ### RN04 — Vínculo de Arestas
  Uma aresta não pode existir de forma independente no plano de edição; ela deve obrigatoriamente possuir um nó de origem e um nó de destino vinculados.

- ### RN05 — Hierarquia de Nós e Grupos
  Cada nó individual pode ser independente (não pertencer a nenhum grupo) ou estar contido em apenas um único grupo por vez, evitando redundância hierárquica na visualização.

- ### RN06 — Multiplicidade de Grupos
  Um grupo é uma entidade de contêiner que deve ser capaz de hospedar um ou mais nós simultaneamente, permitindo ações em lote (mover, ocultar ou excluir).

- ### RN07 — Relação entre Entidades
  Os nós de um diagrama podem ser vinculados a entidades persistentes do sistema (Personagens ou Ideias), garantindo que alterações no nome ou status da entidade sejam refletidas automaticamente no diagrama.

## Organização e Metadados

- ### RN08 — Multiplicidade de Tags
  O sistema deve permitir que um único item (personagem, ideia ou pasta) receba múltiplas etiquetas (tags) para facilitar a indexação e filtragem multidimensional.

- ### RN09 — Estrutura de Pastas
  Itens do sistema podem ser organizados em uma estrutura de diretórios, onde uma pasta pode conter itens ou subpastas, respeitando a lógica de que um item pertence a apenas um local físico no sistema de arquivos do projeto.
