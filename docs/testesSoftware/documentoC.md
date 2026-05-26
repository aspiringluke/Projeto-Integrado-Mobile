**Documento C - Técnicas e Casos de Teste**

**Projeto:** Wireframe  
**Tecnologia:** Flutter  
**Arquitetura:** MVC  
**Norma aplicada:** ISO/IEC/IEEE 29119-4

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

**1\. Técnicas Utilizadas**

| **Técnica**                     | **Finalidade**                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------------ |
| Particionamento de Equivalência | Separar entradas válidas e inválidas para campos de texto e seleção                  |
| Valor Limite                    | Validar campos vazios, limites de caracteres e valores extremos                      |
| Transição de Estado             | Validar mudança de estado do sistema (ex.: criação/exclusão de notas/pastas)         |
| Teste Baseado em Cenário        | Validar fluxo completo entre telas e operações (ex.: criação → edição → organização) |

**2\. Derivação das Condições de Teste**

**CT01 - Validar a criação e abertura de edição de nota**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Teste Baseado em Cenário

**Justificativa:**  
Existe uma classe válida de entrada e um fluxo integrado:

- criação de nota válida
- abertura automática da tela de edição
- dados preenchidos corretamente na edição

**TC01 - Criação de nota e abertura de edição**  
**Entradas (Criação):**

- ação: criar nova nota

**Resultado Esperado:**

- Nota criada com sucesso
- Tela de edição aberta imediatamente
- Campos editáveis habilitados e vazios (título, texto, cores)
- Mensagem de confirmação exibida

**CT02 - Validar criação com título vazio em pasta**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Valor Limite

**Justificativa:**  
Título vazio representa:

- partição inválida
- limite inferior aceitável (campo obrigatório)

**TC02 - Criação de pasta com título vazio**  
**Entradas:**

- nome = ""

**Resultado Esperado:**

- Mensagem de erro: "Informe um nome para a pasta."
- Pasta não criada

**CT03 - Validar exclusão de nota**

**Técnica Utilizada:**

- Transição de Estado

**Justificativa:**  
O sistema muda de:

- nota existente  
   para:
- nota excluída

**TC03 - Exclusão de nota existente**  
**Pré-condição:** Nota existente no sistema.  
**Resultado Esperado:**

- Nota removida permanentemente
- Mensagem de confirmação exibida
- Lista de notas atualizada

**CT04 - Validar criação de pasta**

**Técnica Utilizada:**

- Particionamento de Equivalência

**Justificativa:**  
Classe válida: nome da pasta preenchido e único.

**TC04 - Criação de pasta com nome válido**  
**Entradas:**

- nome = "Pasta Teste"

**Resultado Esperado:**

- Pasta criada com sucesso
- Mensagem de sucesso exibida
- Pasta visível na lista

**CT05 - Validar exclusão de pasta**

**Técnica Utilizada:**

- Transição de Estado

**Justificativa:**  
Mudança de estado: pasta existente → pasta excluída.

**TC05 - Exclusão de pasta existente**  
**Pré-condição:** Pasta existente e vazia.  
**Resultado Esperado:**

- Pasta removida
- Mensagem de confirmação exibida
- Lista de pastas atualizada

**CT06 - Validar organização de nota em pasta**

**Técnica Utilizada:**

- Teste Baseado em Cenário

**Justificativa:**  
Cenário: criação de nota → movimentação para pasta.

**TC06 - Movimentação de nota para pasta**  
**Pré-condição:** Nota e pasta existentes.  
**Resultado Esperado:**

- Nota movida para a pasta selecionada
- Estrutura de organização atualizada

**CT07 - Validar seleção de cor das notas**

**Técnica Utilizada:**

- Particionamento de Equivalência

**Justificativa:**  
Classe válida: seleção de cor disponível através da interface.

**TC07 - Alteração de cor da nota selecionando bolinha**  
**Entradas:**

- ação: tocar na interface visual na cor desejada

**Resultado Esperado:**

- Cor da nota alterada para a escolhida
- Visualização atualizada

**CT08 - Validar seleção de cor de pastas**

**Técnica Utilizada:**

- Particionamento de Equivalência

**Justificativa:**  
Classe válida: seleção de cor para pasta.

**TC08 - Alteração de cor da pasta selecionando bolinha**  
**Entradas:**

- ação: tocar na bolinha de cor verde (interface visual)

**Resultado Esperado:**

- Cor da pasta alterada para verde
- Visualização atualizada

**CT09 - Validar edição de texto com limite**

**Técnica Utilizada:**

- Valor Limite

**Justificativa:**  
Limite: texto não vazio e dentro de limites aceitáveis.

**TC09 - Edição de texto válido da nota**  
**Entradas:**

- texto = "Texto editado com sucesso"

**Resultado Esperado:**

- Texto da nota atualizado
- Alterações salvas

**CT10 - Validar edição com texto gigantesco**

**Técnica Utilizada:**

- Valor Limite

**Justificativa:**  
Teste de limite superior: texto extremamente longo.

**TC10 - Edição de nota com texto gigantesco**  
**Entradas:**

- texto = \[texto com milhares de caracteres\]

**Resultado Esperado:**

- Sistema aceita ou exibe mensagem: "Limite de caracteres excedido"
- Comportamento definido (truncar ou rejeitar)

**CT11 - Validar título vazio ao editar nota**

**Técnica Utilizada:**

- Particionamento de Equivalência
- Valor Limite

**Justificativa:**  
Título vazio em edição representa:

- partição inválida
- campo obrigatório

**TC11 - Edição de nota deixando título vazio**  
**Entradas:**

- título = "" (limpar campo de título)

**Resultado Esperado:**

- Mensagem de erro: "título vazio."
- Alteração não salva
- Nota mantém título anterior

**CT12 - Validar movimentação de pasta para outra pasta**

**Técnica Utilizada:**

- Teste Baseado em Cenário

**Justificativa:**  
Cenário: criação de pastas → movimentação entre hierarquias.

**TC12 - Movimentação de pasta para outra pasta**  
**Pré-condição:** Duas pastas existentes ("Pasta A" e "Pasta B").  
**Resultado Esperado:**

- Pasta A movida para dentro de Pasta B
- Hierarquia de pastas atualizada
- Visualização reflete nova estrutura

**3\. Tabela Consolidada de Técnicas**

| **Condição** | **Técnica**                                                |
| ------------ | ---------------------------------------------------------- |
| CT01         | Particionamento de Equivalência + Teste Baseado em Cenário |
| CT02         | Particionamento de Equivalência + Valor Limite             |
| CT03         | Transição de Estado                                        |
| CT04         | Particionamento de Equivalência                            |
| CT05         | Transição de Estado                                        |
| CT06         | Teste Baseado em Cenário                                   |
| CT07         | Particionamento de Equivalência                            |
| CT08         | Particionamento de Equivalência                            |
| CT09         | Valor Limite                                               |
| CT10         | Valor Limite                                               |
| CT11         | Particionamento de Equivalência + Valor Limite             |
| CT12         | Teste Baseado em Cenário                                   |

**4\. Tabela Consolidada de Casos de Teste**

| **ID** | **Caso**                                       |
| ------ | ---------------------------------------------- |
| TC01   | Criação de nota e abertura de edição           |
| TC02   | Criação de pasta com título vazio              |
| TC03   | Exclusão de nota existente                     |
| TC04   | Criação de pasta com nome válido               |
| TC05   | Exclusão de pasta existente                    |
| TC06   | Movimentação de nota para pasta                |
| TC07   | Alteração de cor da nota selecionando bolinha  |
| TC08   | Alteração de cor da pasta selecionando bolinha |
| TC09   | Edição de nota com texto válido                |
| TC10   | Edição de nota com texto gigantesco            |
| TC11   | Edição de nota deixando título vazio           |
| TC12   | Movimentação de pasta para outra pasta         |

**5\. Conclusão da Etapa**

As condições de teste identificadas no Documento A foram derivadas em casos de teste completos utilizando técnicas formais definidas pela ISO/IEC/IEEE 29119-4. Os casos de teste produzidos estão preparados para implementação automatizada no projeto Flutter Wireframe, utilizando testes de unidade e testes de integração, com foco em validação de campos, estados, limites extremos e fluxos de criação, edição e organização de notas e pastas.