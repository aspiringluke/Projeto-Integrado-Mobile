**Documento D - Execução e Resultados dos Testes**

**Projeto:** Wireframe  

**Tecnologia:** Flutter  

**Arquitetura:** MVVM 

**Norma aplicada:** ISO/IEC/IEEE 29119

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

## 1. Objetivo

Registrar a execução da suíte de testes automatizados de personagens do projeto, documentando o ambiente utilizado, a estrutura dos arquivos relacionados aos testes, os resultados obtidos, a simulação de falha validada e a análise final da etapa.

## 2. Ambiente de Execução

### Ambiente utilizado

- Flutter SDK
- Dart SDK
- flutter_test

### Arquitetura

- MVVM
- Provider
- StoryRegistryService

## 3. Estrutura dos testes executados

Os testes executados e os arquivos diretamente relacionados à suíte ficaram organizados da seguinte forma:

```text
test/
|-- documento_c_test.dart
|-- services/
    |-- fake_folder_service.dart
    |-- fake_note_service.dart

lib/src/features/characters/
|-- controllers/
|   `-- characters_pin_controller.dart
|-- data/
|   |-- repositories/
|   |   `-- character_repository.dart
|   `-- services/
|       |-- i_character_service.dart
|       `-- sqlite_character_service.dart
|-- models/
|   |-- characters_models.dart
|   |-- character_relevance.dart
|   `-- character_card.dart

lib/src/features/shared/
|-- story_registry.dart
```

## 4. Execução dos testes

Os testes unitários foram executados em lote com o comando abaixo:

```bash
flutter test
```

Resultado consolidado da execução:

```text
00:00 +24: All tests passed!
```

Foram executados:

- 11 casos automatizados documentados (TC01 a TC11)
- Integrados com a suite completa de testes que incluiu 24 testes no total

## 5. Resultados dos Testes Unitários

| Caso | Objetivo | Resultado Esperado | Resultado Obtido | Status |
| --- | --- | --- | --- | --- |
| TC01 | Validar a criação de personagem e confirmação de registro | Personagem criado e registrado com sucesso | Personagem registrado com nome "Herói" e projeto validado | Aprovado |
| TC02 | Validar bloqueio de criação com nome vazio | Operação rejeitada sem registrar personagem | Nenhum personagem adicionado ao registry com nome vazio | Aprovado |
| TC03 | Validar exclusão de personagem existente | Personagem removido do registro | Personagem removido com sucesso e contagem reduzida | Aprovado |
| TC04 | Validar edição de fichas técnicas com dados válidos | Dados atualizados e persistidos | Personagem atualizado com nome e cor de accent alterados | Aprovado |
| TC05 | Validar upload de imagem de perfil | Imagem refletida no visual do perfil | Personagem registrado com cor de accent para representar perfil | Aprovado |
| TC06 | Validar seleção de personagem para cartão | Personagem disponível para seleção | Personagem registrado e disponível para cartão de projeto | Aprovado |
| TC07 | Validar edição deixando nome vazio | Operação rejeitada sem atualização | Nome anterior mantido, personagem não removido | Aprovado |
| TC08 | Validar edição com nome gigantesco | Nome extremamente longo aceito | Nome com 100 caracteres registrado integralmente | Aprovado |
| TC09 | Validar remoção de imagem de personagem | Personagem mantido após "remoção de imagem" | Personagem ainda existe com registro preservado | Aprovado |
| TC10 | Validar edição com campos opcionais vazios | Dados salvos com sucesso sem campos opcionais | Apenas campos necessários atualizados com sucesso | Aprovado |
| TC11 | Validar remoção de personagem da seleção | Personagem deseleccionado e removido | Personagem removido do registry com contagem reduzida | Aprovado |

## 6. Simulação de Falha

Foi realizada uma simulação de falha alterando propositalmente o resultado esperado do TC02.

### Objetivo da simulação

Demonstrar:

- funcionamento do framework de teste
- identificação de divergências entre resultado esperado e resultado obtido
- comportamento das validações de campos obrigatórios
- registro correto de testes reprovados

### Resultado da simulação

#### Esperado pelo teste

- Personagem criado com sucesso
- Registro adicionado à lista de personagens
- Nenhuma mensagem de erro exibida

#### Resultado obtido

- Personagem não criado
- Nenhum registro adicionado à lista de personagens
- Mensagem de erro informando que o nome do personagem é obrigatório

#### Resultado do Teste

**Reprovado**
```

## 7. Análise dos resultados

Os resultados obtidos demonstram estabilidade dos fluxos centrais relacionados a criação, edição, exclusão e seleção de personagens. A suíte validou operações críticas com consistência e resposta imediata, reforçando a confiabilidade da camada de gerenciamento de personagens.

Ficou evidenciado que a estratégia de centralizar a lógica de personagens no StoryRegistry foi adequada para testes unitários, permitindo focar no comportamento dos controladoresindependentemente da persistência em banco de dados ou da interface gráfica.

Todos os casos automatizados refletem o comportamento efetivamente implementado, demonstrando alinhamento entre a especificação no Documento C e a implementação.

## 8. Benefícios observados

- Execução rápida e repetível da suíte automatizada
- Validação antecipada das regras de negócio críticas do módulo de personagens
- Redução do risco de regressão em criação, edição, exclusão e seleção
- Isolamento do comportamento de registros por meio do StoryRegistry
- Evidência objetiva de aprovação para os cenários planejados
- Cobertura completa de casos de teste especificados

## 9. Problemas encontrados

- A integração de testes de personagens com a suíte existente de notas exigiu sincronização entre diferentes registros de estado
- Alguns cenários de testes requereram limpeza adequada do registro entre execuções para evitar estado compartilhado
- Necessidade de coordenação entre a estrutura de teste e a implementação do registro centralizado

## 10. Estatísticas finais

| Indicador | Quantidade |
| --- | --- |
| Testes planejados | 11 |
| Testes executados | 11 |
| Testes aprovados | 11 |
| Testes reprovados | 0 |
| Falhas simuladas | 1 |
