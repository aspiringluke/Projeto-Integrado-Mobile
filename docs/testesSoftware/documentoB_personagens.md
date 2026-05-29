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
- Uso de Serviços Fake para persistência simulada

**2\. Ambiente de Teste**

- Flutter SDK
- Dart SDK
- flutter_test
- integration_test
- Serviços Fake (FakeFolderService, FakeNoteService) para simulação de dados

**3\. Critérios de Entrada**

- Projeto funcional com fluxo de criação de notas implementado
- ViewModels (NoteViewModel, NoteEditorViewModel, FolderViewModel) implementados
- Repositórios (FolderRepository, NoteRepository) e serviços (FolderService, NoteService) concluídos
- Documento A (Base Conceitual de Teste) concluído e aprovado

**4\. Critérios de Saída**

- Todos os testes de unidade, funcionais, integração, interface e regressão executados
- Resultados registrados com cobertura mínima de 80%
- Relatório de testes produzido com evidências de aprovação/reprovação
- Correções aplicadas para testes reprovados

**5\. Ordem de Execução**

- Testar NoteViewModel (criação e validação de notas)
- Testar NoteEditorViewModel (edição de texto e títulos)
- Testar FolderViewModel (criação e exclusão de pastas)
- Testar integração entre NoteRepository e NoteService (persistência de notas)
- Testar integração entre FolderRepository e FolderService (organização em pastas)
- Testar navegação e validação de campos (título, sinopse, cores)
- Testar customização visual (cores de notas e pastas)

**6\. Implementação**

test/  
viewmodel/

note_viewmodel_test.dart

note_editor_viewmodel_test.dart

folder_viewmodel_test.dart  
integration_test/

note_creation_flow_test.dart

folder_management_flow_test.dart

**7\. Controle**

Planejados: Todos os testes baseados nas Condições de Teste (CT01 a CT10) do Documento A

Executados: Após implementação e validação em ambiente de teste

Aprovados: Testes que passam sem falhas

Reprovados: Testes com falhas, com plano de correção documentado

**8\. Execução**

flutter test

flutter test integration_test

**9\. Conclusão**

Encerrar após execução completa de todos os testes, análise dos resultados e correções aplicadas. Produzir relatório final com métricas de cobertura e riscos mitigados (R01 a R05 do Documento A).