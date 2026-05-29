**Documento A - Base Conceitual de Teste**

**Projeto:** Wireframe

**Tecnologia:** Flutter

**Arquitetura:** MVVM

**Normas Aplicadas:** ISO/IEC/IEEE 29119-1

**Equipe:**

- Enzo Daniel Abreu
- Gabriel da Silva Freitas
- José Carlos Pereira Neto
- Lucas Paulino Gomes
- Thierry Antonello Pengo

**1\. Sistema sob teste**

Fluxo de criação de notas

**2\. Itens de teste**

- NoteViewModel
- NoteEditorViewModel
- FolderViewModel
- FolderRepository
- NoteRepository
- FolderService
- NoteService

**3\. Escopo**

- Criação de Notas
- Validação de Campos: Título, sinopse, tags, cores
- Gerenciamento de Tags: Seleção e criação de novas tags
- Customização Visual
- Persistência: FakeFolderService
- Navegação: Retorno do diálogo com dados validados

**4\. Fora de Escopo**

- Criação de projeto e personagem
- Gestão de Imagens: Upload de cover e accent images
- Banco de Dados (SQLite): Persistência em disco
- Performance: Otimização de memória
- Testes de UI avançados: Gestos complexos e animações

**5\. Requisitos Funcionais**

- **RF01:** O sistema deve permitir ao usuário o registro de notas de texto
- **RF02:** O sistema deve permitir a exclusão de registros de notas
- **RF03:** O sistema deve permitir ao usuário organizar suas notas em pastas
- **RF04:** O sistema deve permitir ao usuário editar o texto das notas
- **RF06:** O sistema deve permitir ao usuário adicionar títulos às notas criadas
- **RF07:** O sistema deve permitir ao usuário adicionar e atribuir tags às notas criadas.

**6\. Condições de teste**

- **CT01:** O Projeto deve validar a criação do registro de nota de texto
- **CT02:** O Projeto deve validar a abertura da edição de nota após criá-la
- **CT03:** O Projeto deve validar a exclusão do registro de nota de texto
- **CT04:** O Projeto deve validar a criação da pasta
- **CT05:** O Projeto deve validar a exclusão da pasta
- **CT06:** O Projeto deve validar a organização de registros em pastas
- **CT07:** O Projeto deve validar a alteração de cor das notas
- **CT08:** O Projeto deve validar a alteração de cor das pastas
- **CT09:** O Projeto deve validar a alteração do texto das notas
- **CT10:** O Projeto deve validar a criação de tags as notas

**7\. Tipos de teste**

- Testes de Unidade
- Testes Funcionais
- Testes de Integração
- Testes de Interface
- Testes de Regressão

**8\. Riscos**

- **R01:** falha na criação de registos de notas ou pastas
- **R02:** Exclusão falha dos registos de notas ou pastas
- **R03:** Falha em mover notas ou pastas
- **R04:** Edição de textos das notas falha
- **R05:** Nota ou pasta criada com título vazio
- **R06:** Tags duplicadas ou com nomes idênticos em uma mesma nota
- **R07:** Tag não adicionada