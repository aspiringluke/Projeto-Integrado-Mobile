**Documento C - Técnicas e Casos de Teste (Personagens)**

**Projeto:** Wireframe  

**Tecnologia:** Flutter  

**Arquitetura:** MVVM 

**Norma aplicada:** ISO/IEC/IEEE 29119-4

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

**1\. Técnicas Utilizadas**

| **Técnica**                     | **Finalidade**                                                                               |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| Particionamento de Equivalência | Separar entradas válidas e inválidas para campos de personagem                               |
| Valor Limite                    | Validar campos vazios, limites de caracteres e valores extremos                              |
| Transição de Estado             | Validar mudança de estado do sistema (ex.: criação/exclusão de personagens)                  |
| Teste Baseado em Cenário        | Validar fluxo completo entre telas e operações (ex.: criação → edição → seleção para cartão) |

**2\. Derivação das Condições de Teste**

**CT01 - Validar criação e abertura de edição de personagem**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Teste Baseado em Cenário

**Justificativa:**  
Existe uma classe válida de entrada e um fluxo integrado:

- criação de personagem válido
- dados preenchidos corretamente na edição

**TC01 - Criação de personagem e abertura de edição**  
**Entradas (Criação):**

- ação: criar novo personagem

**Resultado Esperado:**

- Personagem criado com sucesso
- Tela de edição aberta imediatamente
- Campos editáveis habilitados (nome, descrição, fichas técnicas)
- Mensagem de confirmação exibida

**CT02 - Validar criação com nome vazio**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Valor Limite

**Justificativa:**  
Nome vazio representa:

- partição inválida
- limite inferior aceitável (campo obrigatório)

**TC02 - Criação de personagem com nome vazio**  
**Entradas:**

- nome = ""

**Resultado Esperado:**

- Mensagem de erro: "Informe um nome para o personagem."
- Personagem não criado

**CT03 - Validar exclusão de personagem**

**Técnica Utilizada:**

- Transição de Estado

**Justificativa:**  
O sistema muda de:

- personagem existente  
   para:
- personagem excluído

**TC03 - Exclusão de personagem existente**  
**Pré-condição:** Personagem existente no sistema.  
**Resultado Esperado:**

- Personagem removido permanentemente
- Mensagem de confirmação exibida
- Lista de personagens atualizada

**CT04 - Validar edição de dados de personagem**

**Técnica Utilizada:**

- Particionamento de Equivalência

**Justificativa:**  
Classe válida: campos de fichas técnicas preenchidos corretamente.

**TC04 - Edição de fichas técnicas com dados válidos**  
**Entradas:**

- nome = "Protagonista"
- descrição = "Personagem principal da história"
- ficha técnica = preenchida com dados válidos

**Resultado Esperado:**

- Dados de personagem atualizados com sucesso
- Alterações salvas

**CT05 - Validar upload de imagem de personagem**

**Técnica Utilizada:**

- Particionamento de Equivalência

**Justificativa:**  
Classe válida: imagem válida selecionada do armazenamento.

**TC05 - Upload de imagem de perfil de personagem**  
**Pré-condição:** Personagem existente.  
**Entradas:**

- ação: selecionar arquivo de imagem válido (JPG/PNG)

**Resultado Esperado:**

- Imagem carregada e exibida no perfil
- Mensagem de sucesso exibida
- Imagem persistida

**CT06 - Validar seleção de personagem para cartão de projeto**

**Técnica Utilizada:**

- Teste Baseado em Cenário

**Justificativa:**  
Cenário: criação de personagem → seleção para aparecer no cartão.

**TC06 - Seleção de personagem para cartão de projeto**  
**Pré-condição:** Personagem com imagem cadastrada.  
**Resultado Esperado:**

- Personagem selecionado para cartão
- Imagem do personagem visível no cartão do projeto
- Alterações refletidas imediatamente

**CT07 - Validar edição com nome vazio**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Valor Limite

**Justificativa:**  
Nome vazio em edição representa:

- partição inválida
- campo obrigatório

**TC07 - Edição de personagem deixando nome vazio**  
**Entradas:**

- nome = "" (limpar campo de nome)

**Resultado Esperado:**

- Mensagem de erro: "O nome do personagem não pode estar vazio."
- Alteração não salva
- Personagem mantém nome anterior

**CT08 - Validar descrição com texto gigantesco**

**Técnica Utilizada:**

- Valor Limite

**Justificativa:**  
Teste de limite superior: descrição extremamente longa.

**TC08 - Edição de personagem com descrição gigantesca**  
**Entradas:**

- descrição = \[texto com milhares de caracteres\]

**Resultado Esperado:**

- Sistema aceita ou exibe mensagem: "Limite de caracteres excedido"
- Comportamento definido (truncar ou rejeitar)

**CT09 - Validar remoção de imagem de personagem**

**Técnica Utilizada:**

- Transição de Estado

**Justificativa:**  
Mudança de estado: personagem com imagem → personagem sem imagem.

**TC09 - Remoção de imagem de personagem**  
**Pré-condição:** Personagem com imagem cadastrada.  
**Resultado Esperado:**

- Imagem removida do perfil
- Imagem padrão ou vazio exibido
- Alteração salva

**CT10 - Validar edição de fichas técnicas com campos vazios**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Valor Limite

**Justificativa:**  
Campos de fichas técnicas vazios podem ser válidos (informações opcionais).

**TC10 - Edição de fichas técnicas deixando campos opcionais vazios**  
**Entradas:**

- campos obrigatórios preenchidos
- campos opcionais vazios

**Resultado Esperado:**

- Dados salvos com sucesso
- Campos opcionais aceitos em branco
- Mensagem de sucesso exibida

**CT11 - Validar deselecção de personagem do cartão**

**Técnica Utilizada:**

- Transição de Estado

**Justificativa:**  
Mudança de estado: personagem selecionado → personagem deseleccionado do cartão.

**TC11 - Remoção de personagem da seleção de cartão**  
**Pré-condição:** Personagem selecionado para cartão de projeto.  
**Resultado Esperado:**

- Personagem deseleccionado do cartão
- Imagem removida do cartão
- Visualização atualizada

**3\. Tabela Consolidada de Técnicas**

| **Condição** | **Técnica**                                                |
| ------------ | ---------------------------------------------------------- |
| CT01         | Particionamento de Equivalência + Teste Baseado em Cenário |
| CT02         | Particionamento de Equivalência + Valor Limite             |
| CT03         | Transição de Estado                                        |
| CT04         | Particionamento de Equivalência                            |
| CT05         | Particionamento de Equivalência                            |
| CT06         | Teste Baseado em Cenário                                   |
| CT07         | Particionamento de Equivalência + Valor Limite             |
| CT08         | Valor Limite                                               |
| CT09         | Transição de Estado                                        |
| CT10         | Particionamento de Equivalência + Valor Limite             |
| CT11         | Transição de Estado                                        |

**4\. Tabela Consolidada de Casos de Teste**

| **ID** | **Caso**                                              |
| ------ | ----------------------------------------------------- |
| TC01   | Criação de personagem e abertura de edição            |
| TC02   | Criação de personagem com nome vazio                  |
| TC03   | Exclusão de personagem existente                      |
| TC04   | Edição de fichas técnicas com dados válidos           |
| TC05   | Upload de imagem de perfil de personagem              |
| TC06   | Seleção de personagem para cartão de projeto          |
| TC07   | Edição de personagem deixando nome vazio              |
| TC08   | Edição de personagem com descrição gigantesca         |
| TC09   | Remoção de imagem de personagem                       |
| TC10   | Edição de fichas técnicas com campos opcionais vazios |                                |
| TC11   | Remoção de personagem da seleção de cartão            |

**5\. Requisitos Funcionais Cobertos**

- **RF18:** Criação de Personagens (TC01, TC02, TC11)
- **RF19:** Edição de Dados de Personagens (TC04, TC07, TC08, TC10)
- **RF20:** Upload de Imagens de Personagem (TC05, TC09)
- **RF21:** Exclusão de personagens (TC03)
- **RF06:** Personagens do cartão de projeto (TC06, TC12)

**6\. Conclusão da Etapa**

As condições de teste para personagens foram derivadas em casos de teste completos utilizando técnicas formais definidas pela ISO/IEC/IEEE 29119-4. Os casos de teste produzidos estão preparados para implementação automatizada no projeto Flutter Wireframe, utilizando testes de unidade e testes de integração, com foco em validação de campos obrigatórios, upload de imagens, edição de fichas técnicas e integração com o cartão de projeto.