**Documento B - Processo de Teste**

**Projeto:** Wireframe

**Tecnologia:** Flutter

**Arquitetura:** MVVM

**Norma aplicada:** ISO/IEC/IEEE 29119-2

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

**1\. Estratégia de Teste**

- Testes de Unidade
- Testes Funcionais
- Testes de Integração
- Testes de Interface
- Testes de Regressão
- Uso de serviços simulados para persistência de dados
- Validação dos fluxos de criação, edição, exclusão e organização de notas

**2\. Ambiente de Teste**

- Flutter SDK
- Dart SDK
- flutter_test
- integration_test
- FakeFolderService

**3\. Critérios de Entrada**

- Fluxo de criação de notas implementado
- Funcionalidade de gerenciamento de pastas implementada
- Funcionalidade de gerenciamento de tags implementada
- NoteViewModel implementado
- NoteEditorViewModel implementado
- FolderViewModel implementado
- FolderRepository implementado
- NoteRepository implementado
- FolderService implementado
- NoteService implementado

**4\. Critérios de Saída**

- Todos os testes de unidade, funcionais, integração, interface e regressão executados
- Cobertura mínima de 80% dos componentes definidos no escopo
- Correções aplicadas para falhas encontradas
- Relatório de testes produzido com evidências de aprovação/reprovação

**5\. Ordem de Execução**

- Testar NoteViewModel (criação e validação de notas)
- Testar NoteEditorViewModel (edição de notas)
- Testar FolderViewModel (criação, exclusão e organização de pastas)
- Testar gerenciamento de tags
- Testar integração entre NoteRepository e NoteService
- Testar integração entre FolderRepository e FolderService
- Testar criação de notas
- Testar exclusão de notas
- Testar organização de notas em pastas
- Testar alteração de texto das notas
- Testar alteração de cores de notas e pastas
- Testar navegação e retorno dos diálogos com dados validados

**6\. Implementação**

test/

viewmodel/

- note_viewmodel_test.dart
- note_editor_viewmodel_test.dart
- folder_viewmodel_test.dart

integration_test/

- note_creation_flow_test.dart
- note_deletion_flow_test.dart
- folder_management_flow_test.dart
- note_tag_management_flow_test.dart
- note_customization_flow_test.dart

**7\. Controle**

**Planejados:** Todos os testes derivados das Condições de Teste CT01 a CT10 do Documento A.

**Executados:** Após conclusão da implementação dos componentes e preparação do ambiente de teste.

**Aprovados:** Testes executados com resultado esperado sem falhas.

**Reprovados:** Testes com falhas registradas e plano de correção definido.

**8\. Execução**

flutter test

flutter test integration_test


**9\. Conclusão**

O processo de teste será encerrado após a execução completa dos testes planejados, análise dos resultados obtidos e aplicação das correções necessárias.

Deverá ser produzido um relatório final contendo:

- Cobertura dos testes executados
- Evidências de aprovação e reprovação
- Defeitos identificados e corrigidos
- Avaliação dos riscos mitigados (R01 a R07)
- Conclusão sobre a qualidade do fluxo de criação e gerenciamento de notas