# Casos de Uso do Projeto

## UC01 — Criar um novo projeto

### Ator Principal

- Usuário

### Objetivos

- Criar um novo projeto.

### Pré-condições

- Tela inicial aberta.

### Pós-condições

- Novo projeto criado.

### Fluxo Principal

1. O aplicativo abre a tela inicial.
2. O usuário clica no botão "Novo Projeto".
3. Um novo projeto é criado.

### RF Relacionadas

- RF01

---

## UC02 — Criar Diagrama de Relacionamento de Entidades

### Ator Principal

- Usuário

### Objetivos

- Permitir que o autor visualize e conecte personagens ou ideias de forma lógica e espacial.

### Pré-condições

- O usuário deve estar dentro de um projeto ativo.

### Pós-condições

- Um novo diagrama é persistido no banco de dados local.

### Fluxo Principal

1. O usuário acessa a seção "Diagramas".
2. O usuário seleciona "Criar Novo Diagrama".
3. O sistema abre o plano de edição.
4. O usuário insere dois nós e os conecta através de uma aresta.
5. O usuário aciona o botão "Salvar".
6. O sistema valida as regras de estrutura mínima e persiste os dados.

### Fluxo Alternativo

- **A1 — Tentativa de salvamento inválido:**

    Se o usuário tentar salvar com menos de dois nós ou sem conexão, o sistema exibe alerta baseado na RN03 e bloqueia a persistência.

### RF Relacionadas

- RF05
- RF08
- RF09
- RF12

### RN Relacionadas

- RN03
- RN04

### RNF Relacionadas

- RNF04
- RNF06

---

## UC04 — Organizar Elementos via Drag-and-Drop

### Ator Principal

- Usuário

### Objetivos

- Facilitar a organização visual e hierárquica do projeto através de interação direta.

### Pré-condições

- Interface de listagem (projetos/ideias) ou editor de diagramas aberto.

### Pós-condições

- Nova posição espacial ou hierárquica salva.

### Fluxo Principal

1. O usuário pressiona e segura um item (nó ou arquivo).
2. O usuário arrasta o item para uma nova coordenada (diagrama) ou para cima de uma pasta.
3. O sistema fornece feedback visual imediato durante o movimento.
4. O usuário solta o item.
5. O sistema valida a nova posição e confirma a alteração.

### Fluxo Alternativo

- **A1 — Cancelamento de movimento:**

    O usuário arrasta o item para uma área inválida e o sistema retorna o item à posição original.

### RF Relacionadas

- RF13
- RF34

### RN Relacionadas

- RN06

### RNF Relacionadas

- RNF01
- RNF04

---

## UC05 — Busca Global com Filtros e Tags

### Ator Principal

- Usuário

### Objetivos

- Localizar rapidamente qualquer elemento do projeto em meio a grandes volumes de dados.

### Pré-condições

- Existirem itens (ideias, personagens, diagramas) cadastrados.

### Pós-condições

- Listagem filtrada exibida na tela.

### Fluxo Principal

1. O usuário acessa o campo de pesquisa global.
2. O usuário digita uma palavra-chave ou seleciona uma tag específica.
3. O sistema aplica a latência de *debounce*.
4. O sistema consulta o cache/banco e retorna os itens correspondentes.

### Fluxo Alternativo

- **A1 — Nenhum resultado encontrado:**

    O sistema exibe uma mensagem amigável sugerindo a revisão dos termos da busca.

### RF Relacionadas

- RF02
- RF04
- RF24

### RNF Relacionadas

- RNF03

---

## UC06 — Configurar e Utilizar Modo Desempenho

### Ator Principal

- Usuário

### Objetivos

- Otimizar a experiência em dispositivos com hardware limitado.

### Pós-condições

- Interface simplificada e consumo de recursos reduzido.

### Fluxo Principal

1. O usuário acessa as "Configurações Gerais".
2. O usuário ativa o botão "Modo Desempenho".
3. O sistema desabilita sombras dinâmicas, transparências e animações complexas.
4. O sistema limita o uso da memória para o teto definido.

### Fluxo Alternativo

- **A1 — Desativação do Modo:**

    O usuário desativa o modo e o sistema restaura imediatamente a fidelidade visual total.

### RF Relacionadas

- RF44

### RNF Relacionadas

- RNF02

---

## UC07 — Gestão de Grupos de Nós em Diagramas

### Ator Principal

- Usuário

### Objetivos

- Agrupar conceitos relacionados (ex: um núcleo de personagens) para organização em larga escala.

### Pré-condições

- Diagrama com múltiplos nós existentes.

### Pós-condições

- Grupo criado.

### Fluxo Principal

1. O usuário seleciona múltiplos nós no editor.
2. O usuário aciona a função "Criar Grupo de Nós".
3. O usuário define um nome e cor para o grupo.

### Fluxo Alternativo

- **A1 — Remoção de nó do grupo:**

    1. O usuário seleciona um nó dentro do grupo.
    2. O usuário aciona "Remover do Grupo". 
    3. O sistema mantém o nó no diagrama de forma independente.

- **A2 — Exclusão de grupo:**

    1. O usuário seleciona o grupo.
    2. O usuário aciona "Excluir Grupo".
    3. O sistema remove o grupo do diagrama.
    4. O sistema mantém os nós do grupo no diagrama de forma independente.

### RF Relacionadas

- RF18
- RF19
- RF20
- RF21
- RF23

### RN Relacionadas

- RN06

### RNF Relacionadas

- RNF04

---

## UC08 — Upload e Compressão de Imagens de Personagens

### Ator Principal

- Usuário

### Objetivos

- Adicionar referências visuais aos personagens sem comprometer o armazenamento do celular.

### Pré-condições

- Ficha de personagem aberta em modo de edição.
- Permissão para acessar imagens na galeria concedida.

### Pós-condições

- Imagem comprimida e exibida no perfil do personagem.

### Fluxo Principal

1. O usuário clica na área de imagem do personagem.
2. O usuário seleciona uma imagem da galeria (até 5MB).
3. O sistema realiza a compressão *lossy* em segundo plano.
4. O sistema salva a versão otimizada no banco/storage local.
5. O usuário confirma a edição salvando o personagem.

### Fluxo Alternativo

- **A1 — Arquivo excedendo limite:**

    O usuário tenta subir um arquivo de 10MB; o sistema bloqueia e exibe mensagem de erro baseada no RNF05.

### RF Relacionadas

- RF38

### RNF Relacionadas

- RNF05

---

## UC09 — Criação e Categorização de Ideias (Markdown)

### Ator Principal

- Usuário

### Objetivos

- Registrar e estilizar fragmentos criativos rapidamente.

### Pós-condições

- Ideia persistida com formatação e tags.

### Fluxo Principal

1. O usuário acessa "Gerenciamento de Ideias".
2. O usuário cria uma nova ideia e insere um título.
3. O usuário escreve o texto utilizando sintaxe Markdown.
4. O usuário adiciona tags de categoria.
5. O usuário clica em "Salvar".

### Fluxo Alternativo

- **A1 — Adição de Imagens:**

    1. O usuário aciona "Adicionar imagem" entre ideias
    2. O sistema exibe duas opções de upload: "Tirar foto" e "Acessar fotos da galeria"
    3. O usuário escolhe a opção desejada
    4. O sistema verifica se o tamanho da imagem respeita o limite de tamanho definido na RNF05
    5. A imagem é adicionada entre ideias com sucesso

### RF Relacionadas

- RF25
- RF28
- RF29
- RF30
- RF31

### RN Relacionadas

- RN02

### RNF Relacionadas

- RNF06

---

## UC10 — Proteção de Acesso ao Aplicativo

### Ator Principal

- Usuário

### Objetivos

- Garantir a privacidade do conteúdo criativo do autor.

### Pós-condições

- Senha de acesso configurada e ativa.

### Fluxo Principal

1. O usuário acessa "Configurações Gerais".
2. O usuário seleciona "Definir Senha de Acesso".
3. O usuário insere e confirma a senha.
4. Ao reiniciar o app, o sistema solicita a senha antes de abrir a Tela Inicial.

### Fluxo Alternativo

- **A1 — Erro de Senha:**

    O usuário insere a senha incorreta e o sistema bloqueia o acesso, permitindo nova tentativa.

### RF Relacionadas

- RF41

---

## UC11 — Excluir Nó e Tratar Arestas Órfãs

### Ator Principal

- Usuário

### Objetivos

- Manter a integridade lógica do diagrama durante a limpeza de elementos.

### Pré-condições

- Diagrama aberto com ao menos dois nós conectados a cada aresta existente.

### Pós-condições

- Nó e arestas vinculadas removidos permanentemente.

### Fluxo Principal

1. O usuário seleciona um nó no editor de diagrama.
2. O usuário clica em "Excluir".
3. O sistema identifica todas as arestas vinculadas a esse nó (origem ou destino).
4. O sistema remove o nó e todas as arestas órfãs simultaneamente.
5. O sistema persiste a alteração após confirmação (Salvar).

### Fluxo Alternativo

- **A1 — Exclusão de Aresta Individual:**

    O usuário seleciona apenas a aresta e a exclui, mantendo os nós intactos.

### RF Relacionadas

- RF14

### RN Relacionadas

- RN04
- RN05

### RNF Relacionadas

- RNF06

---

## UC12 — Exclusão de Pastas e Conteúdo

### Ator Principal

- Usuário

### Objetivos

- Permitir a reorganização estrutural do projeto através da edição e exclusão de diretórios.

### Pré-condições

- Exisitir pelo menos uma pasta criada.

### Pós-condições

- Estrutura de diretórios atualizada ou removida.

### Fluxo Principal

1. O usuário acessa a listagem de itens (Personagens, Ideias ou Diagramas).
2. O usuário seleciona o ícone de configurações de uma pasta específica.
3. O usuário altera o título da pasta.
4. O usuário seleciona a opção "Excluir Pasta".
5. O sistema solicita confirmação, perguntando se deseja excluir apenas a pasta ou a pasta e todo o seu conteúdo.
6. O usuário confirma a exclusão.

### Fluxo Alternativo

- **A1 — Mover conteúdo antes da exclusão:**

1. O usuário seleciona a opção de excluir apenas a pasta.
2. O sistema move todos os itens contidos nela para o diretório raiz antes de deletar o diretório vazio.

### RF Relacionadas

- RF34
- RF35

---

## UC13 — Gestão de Atributos Detalhados no Diagrama

### Ator Principal

- Usuário

### Objetivos

- Enriquecer a lógica narrativa inserindo descrições em nós e arestas dentro do editor gráfico.

### Pré-condições

- Editor de diagrama aberto com elementos (nós e arestas) presentes.

### Pós-condições

- Metadados salvos nos elementos do diagrama.

### Fluxo Principal

1. O usuário clica duas vezes (ou pressiona longamente) sobre uma aresta de conexão.
2. O sistema abre uma janela flutuante para inserção de texto.
3. O usuário descreve a relação (ex: "Rivalidade de infância") e salva.
4. O usuário clica sobre um nó e seleciona "Adicionar Descrição".
5. O usuário insere notas rápidas que não pertencem à ficha principal do personagem.
6. O sistema exibe um ícone indicativo de que aquele elemento possui notas adicionais.

### Fluxo Alternativo

- **A1 — Visualização rápida:**

    O usuário apenas passa o mouse (ou toca levemente) e o sistema exibe um tooltip com a descrição salva sem abrir o editor.

### RF Relacionadas

- RF10
- RF17

---

## UC14 — Personalização e Configurações de Escrita

### Ator Principal

- Usuário

### Objetivos

- Adaptar a interface e as restrições de texto às preferências e necessidades do autor.

### Pré-condições

- Aplicativo aberto na tela de configurações.

### Pós-condições

- Preferências de sistema e limites de validação alterados conforme a escolha do usuário.

### Fluxo Principal

1. O usuário acessa o menu de "Configurações Gerais".
2. O sistema apresenta as opções disponíveis (Idioma, Limites de Texto, Modo Desempenho, etc.).
3. O usuário seleciona e altera a configuração desejada.
4. O sistema valida a alteração e aplica as novas preferências globalmente.
5. O usuário confirma ou retorna ao menu anterior.

### Fluxo Alternativo

- **A1 — Alterar Idioma (RF44):**
    1. O usuário seleciona a opção de "Idioma".
    2. O sistema exibe a lista de idiomas suportados.
    3. O usuário seleciona o novo idioma e o sistema atualiza todos os rótulos e menus imediatamente.
- **A2 — Configurar Limite de Sinopse:**
    1. O usuário seleciona "Limite de Sinopse".
    2. O usuário define um valor numérico dentro do intervalo permitido.
    3. O sistema atualiza a regra de validação para campos de sinopse.
- **A3 — Desativar Limite de Sinopse (RN02):**
    1. O usuário ativa a opção "Ilimitado" no campo de limite global.
    2. O sistema desativa as travas de buffer para campos de texto longo.

### RF Relacionadas

- RF42
- RF43

### RN Relacionadas

- RN01
- RN02

---

## UC15 — Exclusão de Entidades e Itens do Projeto

### Ator Principal

- Usuário

### Objetivos

- Remover definitivamente registros de personagens, ideias ou diagramas do banco de dados.

### Pré-condições

- Listagem de itens aberta.

### Pós-condições

- Item removido e memória liberada.

### Fluxo Principal

1. O usuário localiza o item (Ideia, Personagem ou Diagrama) que deseja remover.
2. O usuário aciona a opção "Excluir".
3. O sistema exibe um alerta de confirmação irreversível.
4. O usuário confirma a ação.
5. O sistema remove o registro e atualiza a interface instantaneamente.

### Fluxo Alternativo

- **A1 — Ordenação antes da exclusão:**

    1. O usuário utiliza a função de ordenação para encontrar itens antigos por data facilitando a remoção filtrada
    2. O usuário executa a exclusão.

### RF Relacionadas

- RF03
- RF06
- RF26
- RF40

---

## UC16 — Gerenciamento de Segurança (Senha)

### Ator Principal

- Usuário

### Objetivos

- Configurar, alterar ou remover a camada de proteção por senha do aplicativo.

### Pré-condições

- Acesso às configurações gerais.
- Proteção estar ativa.

### Pós-condições

- Status de segurança do app atualizado.

### Fluxo Principal

1. O usuário acessa o menu de segurança.
2. O usuário seleciona "Alterar Senha".
3. O sistema solicita a senha antiga para validação.
4. O usuário insere a nova combinação e confirma.
5. O sistema criptografa e salva a nova credencial.

### Fluxo Alternativo

- **A1 — Remover Senha:**

    O usuário seleciona "Desativar Proteção", confirma sua identidade e o sistema remove a obrigatoriedade de senha no login.

### RF Relacionadas

- RF41

---

## UC17 — Gerar Insights Contextuais via IA

### Ator Principal

- Usuário
- Serviço de IA

### Objetivos

- Fornecer análises e sugestões baseados no conteúdo da tela onde o usuário se encontra.
- Gerar perfis automáticos de personagens para auxiliar na organização e construção de mundo.
- Centralizar métricas e insights em uma tela de relatórios (Dashboards) por projeto.

### Pré-condições

- O usuário deve estar em uma página de conteúdo (Projeto, Personagem, Ideia ou Diagrama).
- Conexão ativa com o serviço de IA.

### Pós-condições

- Os insights são armazenados e exibidos na tela de relatórios do projeto.
- Novos perfis de personagens podem ser criados a partir das sugestões.

### Fluxo Principal

1. O usuário clica no ícone de "IA" em qualquer parte do projeto
2. O sistema coleta os dados da hierarquia atual e envia para o serviço de IA
3. O serviço de IA processa o contexto e gera categorias de análise (Ex: Coerência, Criatividade, Organização, etc)
4. O sistema redireciona o usuário para a tela de relatórios
5. O sistema renderiza os Dashboards com gráficos e cards contendo os insights e sugestões de novos perfis

### Fluxo Alternativo

- **A1 — IA fora de contexto:**
    1. O usuário aciona a IA em uma tela vazia ou sem dados suficientes
    2. A IA retorna uma mensagem sugerindo que o usuário adicione mais informações para uma análise precisa
- **A2 — Falha de conexão:**
    1. O sistema detecta que o serviço de IA está offline
    2. O sistema exibe mensagem de erro e informa que os insights não podem ser gerados no momento
- **A3 — Consulta de relatórios anteriores:**
    1. O usuário acessa diretamente a tela de relatórios sem acionar um novo processamento
    2. O sistema carrega os últimos dashboards salvos localmente
- **A4 — Falha na geração de perfil:**
    1. A IA sugere um personagem, mas o usuário já atingiu o limite de armazenamento
    2. O sistema alerta sobre a necessidade de limpeza antes de salvar o novo pérfil
- **A5 — Aviso por falta de tokens:**
    1. O sistema detecta o esgotamento de tokens do serviço de IA
    2. O sistema alerta o usuário sobre o esgotamento dos tokens
    3. O sistema solicita que o usuário agaurde a renovação dos tokens

### RF Relacionadas

- RF36
- RF45

---

```md
UC01 - NECESSITA REALOCAMENTO
- **A1 — Modificar o atributo de ideias:**
    1. O usuário clica no botão da guia de ideias.
    2. O aplicativo abre a tela de ideias.
    3. O usuário pode criar pastas e textos para as ideias. Além disso, pode também criar diagramas de ideias.
- **A2 — Modificar o atributo de personagens:**
    1. Na página inicial, o usuário clica em um dos ícones de personagem.
    2. O aplicativo abre a tela de gerenciamento de personagens.
    3. O usuário pode modificar os atributos de personagens, como nome, apelido, data de nascimento, etc. Além disso, pode também criar diagramas de personagens.
```

```md
SERÁ RECONSIDERADO
## UC03 — Sincronizar Dados entre Entidade e Diagrama

### Ator Principal

- Usuário

### Objetivos

- Garantir que alterações em fichas de personagens ou ideias sejam refletidas visualmente nos diagramas existentes.

### Pré-condições

- Existir um diagrama onde um nó está vinculado a uma entidade persistente (Personagem/Ideia).

### Pós-condições

- A representação visual do nó no diagrama é atualizada.

### Fluxo Principal

1. O usuário acessa a aba de "Gerenciamento de Personagens".
2. O usuário altera o nome de um personagem específico.
3. O usuário clica em "Salvar".
4. O sistema identifica todos os diagramas que contêm o nó vinculado a este personagem.
5. O sistema atualiza o rótulo textual (label) de todos os nós correspondentes automaticamente.

### Fluxo Alternativo

- **A1 — Entidade Excluída:**

    Se o personagem for excluído, o sistema remove o vínculo do nó no diagrama, mas mantém o nó como um elemento genérico.

### RF Relacionadas

- RF09
- RF15
- RF37

### RN Relacionadas

- RN07

### RNF Relacionadas

- RNF06

```
