**Documento D - Execução e Resultados dos Testes**

**Projeto:** Wireframe  
**Tecnologia:** Flutter  
**Arquitetura:** MVC  
**Norma aplicada:** ISO/IEC/IEEE 29119

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

## 1. Objetivo

Registrar a execução da suíte de testes automatizados do projeto, documentando o ambiente utilizado, a estrutura dos arquivos relacionados aos testes, os resultados obtidos, a simulação de falha validada e a análise final da etapa.

## 2. Ambiente de Execução

### Ambiente utilizado

- Flutter SDK
- Dart SDK
- flutter_test
- flutter test

### Arquitetura

O projeto segue arquitetura MVC, com separação das responsabilidades em camadas de controllers, repositories, services e models. Nos testes unitários executados, as regras centrais de notas e pastas foram avaliadas com isolamento de persistência por meio de serviços fake, reduzindo interferência de banco de dados e de componentes de interface.

## 3. Estrutura dos testes executados

Os testes executados e os arquivos diretamente relacionados à suíte ficaram organizados da seguinte forma:

```text
test/
|-- documento_c_test.dart
|-- widget_test.dart
|-- services/
    -- fake_note_service.dart

lib/src/features/notas/
|-- controllers/
|   |-- folder_controller.dart
|   |-- note_controller.dart
|   `-- note_editor_controller.dart
|-- data/
|   |-- repositories/
|   |   |-- folder_repository.dart
|   |   `-- note_repository.dart
|   `-- services/
|       |-- i_folder_service.dart
|       |-- i_note_service.dart
|       |-- sqlite_folder_service.dart
|       `-- sqlite_note_service.dart
 -- models/
    |-- content_stats.dart
    |-- folder.dart
    |-- note.dart
    |-- note_metadata.dart
    `-- notes_drag_payload.dart
```

## 4. Execução dos testes

Os testes unitários foram executados em lote com o comando abaixo:

```bash
flutter test
```

Resultado consolidado da execução:

```text
00:00 +13: All tests passed!
```

Foram executados:

- 12 casos automatizados documentados em `test/documento_c_test.dart` (TC01 a TC12)
- 1 teste complementar em `test/widget_test.dart`, validando a contagem de palavras, caracteres e menções em `ContentStats`

## 5. Resultados dos Testes Unitários

| Caso | Objetivo | Resultado Esperado | Resultado Obtido | Status |
| --- | --- | --- | --- | --- |
| TC01 | Validar a criação de nota e o carregamento da edição | Nota criada com sucesso e dados carregados na edição | `createNote` retornou sucesso, 1 nota foi criada e `loadNote` carregou título e descrição corretamente | Aprovado |
| TC02 | Validar bloqueio de criação de pasta com título vazio | Operação rejeitada com mensagem de erro | `createFolder` retornou falha e a mensagem continha "não pode ser vazio" | Aprovado |
| TC03 | Validar exclusão de nota existente | Nota removida da lista e do serviço | `deleteNote` retornou sucesso, a lista ficou vazia e a nota deixou de existir no serviço fake | Aprovado |
| TC04 | Validar criação de pasta com nome válido | Pasta criada e disponível na listagem | `createFolder` retornou sucesso, com 1 pasta criada e título "Pasta Teste" | Aprovado |
| TC05 | Validar exclusão de pasta existente | Pasta removida da listagem | `deleteFolder` retornou sucesso e a lista de pastas ficou vazia | Aprovado |
| TC06 | Validar movimentação de nota para pasta | Nota associada à pasta de destino | `moveNoteToFolder` retornou sucesso e `idPasta` foi atualizado com o identificador da pasta alvo | Aprovado |
| TC07 | Validar alteração de cor da nota | Cor persistida conforme seleção | A nota foi criada com sucesso e a cor salva permaneceu `0xFFFF8800` | Aprovado |
| TC08 | Validar alteração de cor da pasta | Cor persistida conforme seleção | A pasta foi criada com sucesso e a cor salva permaneceu `0xFF88FF00` | Aprovado |
| TC09 | Validar edição de nota com texto válido | Título e texto atualizados com sucesso | `save` retornou sucesso e os valores editados foram persistidos | Aprovado |
| TC10 | Validar tratamento de texto muito longo | Texto extenso aceito sem perda de conteúdo | `save` retornou sucesso e o texto com 5000 caracteres foi mantido integralmente | Aprovado |
| TC11 | Validar tratamento de título vazio na edição | Título vazio tratado pela implementação e salvo como valor padrão | `save` retornou sucesso e o título foi persistido como "Sem título" | Aprovado |
| TC12 | Validar movimentação de pasta para outra pasta | Hierarquia atualizada com sucesso | `moveFolderToFolder` retornou sucesso e `parentFolderId` passou a apontar para a pasta de destino | Aprovado |

## 6. Simulação de Falha

### Objetivo da simulação

Validar o comportamento do sistema diante de entrada inválida, simulando a tentativa de criação de uma pasta sem preenchimento de título.

### Resultado da simulação

A operação foi interrompida de forma controlada, sem criação de pasta, comprovando que a regra de validação foi aplicada.

### Esperado pelo teste

- `result.$1` igual a `false`
- mensagem de erro contendo a expressão "não pode ser vazio"

### Resultado obtido

- o retorno do método indicou falha
- a mensagem de erro registrada no controller continha a validação esperada

### Resultado do test

**Aprovado**

## 7. Análise dos resultados

Os resultados obtidos demonstram estabilidade dos fluxos centrais relacionados a notas e pastas. A suíte validou criação, exclusão, movimentação, edição e regras de consistência com repetibilidade e resposta imediata, o que reforça a confiabilidade da camada de negócio.

Também ficou evidenciado que a estratégia de uso de serviços fake foi adequada para os testes unitários, pois permitiu focar no comportamento dos controllers e repositories sem dependência direta da persistência real.

Apesar de todos os testes terem sido aprovados, a execução mostrou que alguns casos automatizados refletem o comportamento efetivamente implementado, e não necessariamente a redação literal original do Documento C. Isso aparece com mais clareza no TC10 e no TC11, que seguem a regra atual da aplicação.

## 8. Benefícios observados

- Execução rápida e repetível da suíte automatizada
- Validação antecipada das regras de negócio mais críticas do módulo de notas
- Redução do risco de regressão em criação, edição, exclusão e movimentação
- Isolamento do comportamento da aplicação por meio de serviços fake
- Evidência objetiva de aprovação para os cenários planejados

## 9. Problemas encontrados

- A execução direta do projeto completo no Windows exigiu suporte a symlink por causa de plugins Flutter, o que bloqueou a primeira tentativa de `flutter test`
- A branch `docs` contém a documentação, mas não concentra a base executável da suíte; para execução foi necessário consultar a branch `testesFlutter`
- Há divergência entre parte da descrição textual do Documento C e o comportamento atualmente automatizado em alguns casos, especialmente TC10 e TC11

## 10. Estatísticas finais

| Indicador | Quantidade
| --- | ---
| Testes planejados | 12 
| Testes executados | 12
| Testes aprovados | 12
| Testes reprovados | 0
| Falhas simuladas | 1
