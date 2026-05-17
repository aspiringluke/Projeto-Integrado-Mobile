# Casos de Uso

Documento consolidado dos casos de uso.

## Índice

### Prioridade principal

- [UC01 - Criar novo projeto](#uc01)
- [UC02 - Editar dados do projeto](#uc02)
- [UC03 - Criar personagem](#uc03)
- [UC04 - Editar dados do personagem](#uc04)
- [UC05 - Upload de imagem](#uc05)
- [UC06 - Criar nota de texto](#uc06)
- [UC07 - Criar pasta](#uc07)
- [UC08 - Organizar elementos via drag-and-drop](#uc08)
- [UC09 - Exclusão de entidades e itens do projeto](#uc09)
- [UC10 - Exclusão de pastas e conteúdo](#uc10)
- [UC11 - Personalização e configurações de escrita](#uc11)
- [UC12 - Interagir com chatbot de IA](#uc12)

### Baixa prioridade

- [UC13 - Busca global com filtros e tags](#uc13)
- [UC14 - Criar diagrama de relacionamento de entidades](#uc14)
- [UC15 - Configurar e usar modo desempenho](#uc15)
- [UC16 - Gestão de grupos de nós em diagramas](#uc16)
- [UC17 - Proteção de acesso ao aplicativo](#uc17)
- [UC18 - Excluir nó e tratar arestas órfãs](#uc18)
- [UC19 - Gestão de atributos detalhados no diagrama](#uc19)
- [UC20 - Gerenciamento de segurança (senha)](#uc20)

## Prioridade principal

<a id="uc01"></a>

# UC01 - Criar novo projeto

- Ator principal: Usuário
- Objetivo: Criar um novo projeto.
- Pré-condições: Tela inicial aberta.
- Pós-condições: Projeto criado.

## Fluxo principal

1. Abrir a tela inicial.
2. Clicar em "Novo Projeto".
3. Informar nome do projeto.
4. Adicionar tags ao projeto (opcional).
5. Sistema cria o projeto.

## Fluxo alternativo

- A1 - Nome não informado: sistema exibe validação de nome obrigatório e bloqueia a criação.
- A2 - Tag já cadastrada informada na criação: sistema reaproveita a tag existente e a associa ao projeto.

## Requisitos relacionados

- RF01
- RN06
- RN07

---

<a id="uc02"></a>

# UC02 - Editar dados do projeto

- Ator principal: Usuário
- Objetivo: Atualizar informações e apresentação do projeto.
- Pré-condições: Projeto existente aberto para edição.
- Pós-condições: Dados do projeto atualizados e salvos.

## Fluxo principal

1. Acessar a tela de edição do projeto.
2. Alterar nome e/ou sinopse do projeto.
3. Atualizar imagem do cartão do projeto, quando necessário.
4. Ajustar cor de fundo e modo de mesclagem do cartão.
5. Adicionar ou remover tags do projeto.
6. Selecionar personagens que aparecem no cartão.
7. Salvar alterações.

## Fluxo alternativo

- A2 - Remover imagem do cartão: sistema remove a imagem e mantém as demais alterações.

## Requisitos relacionados

- RF02
- RF03
- RF04
- RF05
- RF06
- RN06
- RN08
- RN15
- RN16
- RN17
- RN18

---

<a id="uc03"></a>

# UC03 - Criar personagem

- Ator principal: Usuário
- Objetivo: Cadastrar um novo personagem no projeto.
- Pré-condições: Projeto ativo com acesso à área de personagens.
- Pós-condições: Novo personagem criado e salvo.

## Fluxo principal

1. Acessar a lista de personagens do projeto.
2. Acionar a opção "Criar personagem".
3. Preencher os dados principais da ficha do personagem.
4. Adicionar imagem ao perfil (includes UC05 - Upload de imagem), quando necessário.
5. Confirmar criação.

## Fluxos alternativos

- A1 - Campos obrigatórios ausentes: sistema destaca os campos pendentes e bloqueia a criação.
- A2 - Cancelar criação: sistema descarta os dados preenchidos e retorna à lista de personagens.
- A3 - Tag já cadastrada informada no seletor: sistema reaproveita a opção existente.

## Requisitos relacionados

- RF18
- RF20
- RN03
- RN04
- RN05
- RNF05

---

<a id="uc04"></a>

# UC04 - Editar dados do personagem

- Ator principal: Usuário
- Objetivo: Atualizar informações da ficha de um personagem existente.
- Pré-condições: Personagem existente.
- Pós-condições: Dados do personagem atualizados e salvos.

## Fluxo principal

1. Acessar a lista de personagens.
2. Selecionar o personagem desejado.
3. Alterar os dados da ficha.
4. Atualizar imagem do perfil (includes UC05 - Upload de imagem), quando necessário.
5. Salvar alterações.

## Fluxo alternativo

- A2 - Remover imagem do perfil: sistema remove a imagem e mantém as demais alterações.

## Requisitos relacionados

- RF19
- RF20
- RNF05

---

<a id="uc05"></a>

# UC05 - Upload de imagem

- Ator principal: Usuário
- Objetivo: Adicionar uma imagem ao item em edição.
- Pré-condições: Tela de edição aberta e permissão de galeria concedida.
- Pós-condições: Imagem salva no item.

## Fluxo principal

1. Abrir área de imagem do item.
2. Selecionar imagem (até 5 MB).
3. Sistema valida o arquivo selecionado.
4. Sistema salva a imagem no item.
5. Usuário confirma salvamento.

## Fluxo alternativo

- A1 - Arquivo acima do limite: sistema bloqueia upload e exibe erro.
- A2 - Permissão negada: sistema solicita permissão de acesso à mídia e não conclui o upload.
- A3 - Formato inválido: sistema bloqueia o arquivo e solicita uma imagem em formato permitido.

## Requisitos relacionados

- RF11
- RF20
- RNF05

---

<a id="uc06"></a>

# UC06 - Criar nota de texto

- Ator principal: Usuário
- Objetivo: Registrar notas com formatação e tags.
- Pré-condições: Nenhuma.
- Pós-condições: Nota salva com título (informado pelo usuário ou definido automaticamente), conteúdo e categorização.

## Fluxo principal

1. Acessar tela de listagem de notas.
2. Criar nova nota e informar título (opcional).
3. Escrever conteúdo.
4. Adicionar tags (opcional).
5. Salvar.

## Fluxo alternativo

A1 - Adicionar imagem (includes UC05 - Upload de imagem):

1. Usuário aciona a opção de adicionar imagem na nota.
2. Sistema executa o UC05 para seleção e validação da imagem.
3. Sistema associa a imagem à nota.

A2 - Nota sem título:
1. Usuário salva nota sem título
2. Sistema define automaticamente o título como "Sem título" e conclui o salvamento.

## Requisitos relacionados

- RF07
- RF10
- RF11
- RF12
- RF13
- RN02
- RN10
- RN14
- RN15
- RN17
- RN19
- RNF05

---

<a id="uc07"></a>

# UC07 - Criar pasta

- Ator principal: Usuário
- Objetivo: Criar uma pasta para organizar itens do projeto.
- Pré-condições: Usuário em uma tela de listagem com suporte a pastas.
- Pós-condições: Nova pasta criada na estrutura atual.

## Fluxo principal

1. Acessar a tela de listagem de itens.
2. Acionar a opção "Criar pasta".
3. Informar nome da pasta.
4. Definir classificações e tags da pasta (opcional).
5. Confirmar criação.
6. Sistema exibe a pasta na listagem.

## Fluxos alternativos

- A1 - Nome inválido: sistema exibe mensagem e solicita novo nome.
- A2 - Cancelar criação: sistema encerra a ação sem criar pasta.

## Requisitos relacionados

- RF14
- RF09
- RF32
- RN09

---

<a id="uc08"></a>

# UC08 - Organizar elementos via drag-and-drop

- Ator principal: Usuário
- Objetivo: Reorganizar itens visualmente.
- Pré-condições: Lista de itens ou editor de diagrama aberto.
- Pós-condições: Nova posição salva.

## Fluxo principal

1. Pressionar e segurar item.
2. Arrastar para nova posição.
3. Soltar item.
4. Sistema valida e confirma alteração.

## Fluxo alternativo

- A1 - Área inválida: sistema retorna item para posição original.

## Requisitos relacionados

- RF39
- RF16
- RN13
- RN23
- RNF01
- RNF04

---

<a id="uc09"></a>

# UC09 - Exclusão de entidades e itens do projeto

- Ator principal: Usuário
- Objetivo: Remover registros de personagens, notas ou diagramas.
- Pré-condições: Listagem de itens aberta.
- Pós-condições: Item removido do banco e da interface.

## Fluxo principal

1. Localizar item.
2. Acionar "Excluir".
3. Confirmar alerta irreversível.
4. Sistema remove registro e atualiza lista.

## Fluxo alternativo

- A1 - Ordenação antes da exclusão: usuário ordena itens para facilitar limpeza.
- A2 - Exclusão com impacto: sistema exibe aviso de impacto quando o item possui vínculos relevantes.

## Requisitos relacionados

- RF08
- RF21
- RF31

---

<a id="uc10"></a>

# UC10 - Exclusão de pastas e conteúdo

- Ator principal: Usuário
- Objetivo: Editar ou remover diretórios do projeto.
- Pré-condições: Existir ao menos uma pasta.
- Pós-condições: Estrutura atualizada.

## Fluxo principal

1. Acessar listagem de itens.
2. Abrir configurações da pasta.
3. Selecionar "Excluir pasta".
4. Escolher excluir só a pasta ou pasta com conteúdo.
5. Confirmar.

## Fluxo alternativo

- A1 - Excluir apenas pasta: sistema move conteúdo para raiz e remove diretório vazio.

## Requisitos relacionados

- RF15
- RF16
- RF17
- RN01
- RN11
- RN12

---

<a id="uc11"></a>

# UC11 - Personalização e configurações de escrita

- Ator principal: Usuário
- Objetivo: Ajustar preferências gerais do aplicativo.
- Pré-condições: Tela de configurações aberta.
- Pós-condições: Preferências atualizadas.

## Fluxo principal

1. Acessar "Configurações Gerais".
2. Selecionar configuração desejada.
3. Alterar preferência.
4. Sistema valida e aplica globalmente.

## Fluxos alternativos

- A1 - Valor inválido: sistema bloqueia alteração e exibe mensagem de validação.

## Requisitos relacionados

- RF24
- RF25

---

<a id="uc12"></a>

# UC12 - Interagir com chatbot de IA

- Ator principal: Usuário
- Ator secundário: Serviço de IA
- Objetivo: Permitir que o usuário converse com a IA para obter apoio no projeto.
- Pré-condições: Projeto aberto e conexão com o serviço de IA disponível.
- Pós-condições: Resposta da IA exibida no chat.

## Fluxo principal

1. Acessar o chat de IA.
2. Digitar uma pergunta ou solicitação.
3. Enviar mensagem.
4. Sistema encaminha a solicitação para a IA.
5. Sistema exibe a resposta no chat.

## Fluxos alternativos

- A1 - Falha de conexão: sistema informa indisponibilidade e orienta nova tentativa.
- A2 - Mensagem vazia: sistema solicita que o usuário informe um texto válido.

## Requisitos relacionados

- RF26

---

## Baixa prioridade

<a id="uc13"></a>

# UC13 - Busca global com filtros e tags

- Ator principal: Usuário
- Objetivo: Localizar itens rapidamente.
- Pré-condições: Itens já cadastrados.
- Pós-condições: Lista filtrada exibida.

## Fluxo principal

1. Acessar campo de busca global.
2. Informar palavra-chave ou tag.
3. Sistema aplica debounce.
4. Sistema retorna resultados.

## Fluxo alternativo

- A1 - Sem resultados: sistema exibe mensagem para revisar termos.
- A2 - Consulta vazia: sistema exibe itens recentes.

## Requisitos relacionados

- RF27
- RF28
- RF29
- RNF03

---

<a id="uc14"></a>

# UC14 - Criar diagrama de relacionamento de entidades

- Ator principal: Usuário
- Objetivo: Criar e conectar entidades em um diagrama.
- Pré-condições: Projeto ativo aberto.
- Pós-condições: Diagrama salvo no banco local.

## Fluxo principal

1. Acessar a seção "Diagramas".
2. Selecionar "Criar novo diagrama".
3. Inserir ao menos dois nós e conectar com uma aresta.
4. Clicar em "Salvar".
5. Sistema valida e persiste.

## Fluxo alternativo

- A1 - Salvamento inválido: se houver menos de dois nós ou sem conexão, sistema bloqueia e exibe alerta.

## Requisitos relacionados

- RF30
- RF34
- RF37
- RN20
- RNF04
- RNF05

---

<a id="uc15"></a>

# UC15 - Configurar e usar modo desempenho

- Ator principal: Usuário
- Objetivo: Reduzir consumo de recursos.
- Pré-condições: Nenhuma.
- Pós-condições: Interface simplificada ativada.

## Fluxo principal

1. Acessar "Configurações Gerais".
2. Ativar "Modo Desempenho".
3. Sistema reduz efeitos visuais e otimiza recursos.

## Fluxo alternativo

- A1 - Desativar modo: sistema restaura configurações visuais padrão.
- A2 - Falha na aplicação: sistema mantém configuração anterior e informa o usuário.

## Requisitos relacionados

- RF25
- RNF02

---

<a id="uc16"></a>

# UC16 - Gestão de grupos de nós em diagramas

- Ator principal: Usuário
- Objetivo: Agrupar nós para organização.
- Pré-condições: Diagrama com múltiplos nós.
- Pós-condições: Grupo criado, alterado ou removido.

## Fluxo principal

1. Selecionar múltiplos nós.
2. Acionar "Criar grupo de nós".
3. Definir nome e cor.

## Fluxos alternativos

- A1 - Remover nó do grupo: nó volta a ser independente.
- A2 - Excluir grupo: grupo é removido e nós permanecem no diagrama.

## Requisitos relacionados

- RF44
- RF45
- RF46
- RF47
- RF49
- RN23
- RNF04

---

<a id="uc17"></a>

# UC17 - Proteção de acesso ao aplicativo

- Ator principal: Usuário
- Objetivo: Proteger acesso ao app por senha.
- Pré-condições: Nenhuma.
- Pós-condições: Senha ativa.

## Fluxo principal

1. Acessar "Configurações Gerais".
2. Selecionar "Definir senha de acesso".
3. Informar e confirmar senha.
4. No próximo acesso, sistema solicita senha.

## Fluxo alternativo

- A1 - Senha incorreta: sistema bloqueia entrada e permite nova tentativa.
- A2 - Senha inválida no cadastro: sistema rejeita a senha e solicita correção.
- A3 - Confirmação divergente: sistema bloqueia cadastro até que senha e confirmação coincidam.

## Requisitos relacionados

- RF22

---

<a id="uc18"></a>

# UC18 - Excluir nó e tratar arestas órfãs

- Ator principal: Usuário
- Objetivo: Manter integridade lógica do diagrama ao excluir nós.
- Pré-condições: Diagrama com nós conectados.
- Pós-condições: Nó e arestas vinculadas removidos.

## Fluxo principal

1. Selecionar nó.
2. Clicar em "Excluir".
3. Sistema identifica arestas ligadas ao nó.
4. Sistema remove nó e arestas relacionadas.
5. Usuário confirma salvamento.

## Fluxo alternativo

- A1 - Exclusão de aresta individual: remove aresta e mantém nós.
- A2 - Cancelamento da exclusão de nó: sistema mantém o estado atual do diagrama.

## Requisitos relacionados

- RF36
- RF39
- RN21
- RN22
- RNF05

---

<a id="uc19"></a>

# UC19 - Gestão de atributos detalhados no diagrama

- Ator principal: Usuário
- Objetivo: Adicionar descrições em nós e arestas.
- Pré-condições: Editor com nós e arestas.
- Pós-condições: Metadados salvos nos elementos.

## Fluxo principal

1. Selecionar aresta e abrir edição.
2. Inserir descrição da relação e salvar.
3. Selecionar nó e adicionar descrição.
4. Sistema indica visualmente elementos com nota.

## Fluxo alternativo

- A1 - Visualização rápida: sistema mostra descrição sem abrir editor completo.

## Requisitos relacionados

- RF35
- RF42

---

<a id="uc20"></a>

# UC20 - Gerenciamento de segurança (senha)

- Ator principal: Usuário
- Objetivo: Alterar ou remover senha do aplicativo.
- Pré-condições: Acesso às configurações e proteção ativa.
- Pós-condições: Status de segurança atualizado.

## Fluxo principal

1. Acessar menu de segurança.
2. Selecionar "Alterar senha".
3. Informar senha atual.
4. Informar e confirmar nova senha.
5. Sistema criptografa e salva.

## Fluxo alternativo

- A1 - Remover senha: usuário desativa proteção após confirmar identidade.
- A2 - Senha atual incorreta: sistema bloqueia alteração e solicita nova tentativa.
- A3 - Nova senha inválida: sistema rejeita a senha e solicita correção.
- A4 - Identidade não confirmada na remoção: sistema cancela a desativação da proteção.

## Requisitos relacionados

- RF22
