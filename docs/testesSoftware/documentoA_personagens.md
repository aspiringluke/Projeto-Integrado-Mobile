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

Fluxo de criação, edição, exclusão e gerenciamento de personagens.

**2\. Itens de teste**

- CharacterViewModel
- CharacterEditorViewModel
- CharacterRepository
- CharacterService
- ProjectViewModel
- ProjectRepository
- ProjectService

**3\. Escopo**

- Criação de Personagens
- Validação de Campos: nome, descrição e fichas técnicas
- Edição de Dados de Personagem
- Upload e Remoção de Imagens de Perfil
- Seleção e Remoção de Personagens no Cartão de Projeto
- Persistência dos Dados de Personagem
- Navegação entre criação e edição de personagens

**4\. Fora de Escopo**

- Criação e gerenciamento de notas
- Criação e gerenciamento de pastas
- Criação e gerenciamento de projetos
- Performance e otimização de memória
- Testes de UI avançados: animações e gestos complexos
- Armazenamento externo e serviços de terceiros

**5\. Requisitos Funcionais**

- **RF18:** O sistema deve permitir a criação de personagens.
- **RF19:** O sistema deve permitir a edição dos dados dos personagens.
- **RF20:** O sistema deve permitir o upload e gerenciamento de imagens de personagem.
- **RF21:** O sistema deve permitir a exclusão de personagens.
- **RF06:** O sistema deve permitir a seleção de personagens para exibição no cartão de projeto.

**6\. Condições de Teste**

- **CT01:** O projeto deve validar a criação de personagem e a abertura automática da tela de edição.
- **CT02:** O projeto deve validar a tentativa de criação de personagem com nome vazio.
- **CT03:** O projeto deve validar a exclusão de personagem existente.
- **CT04:** O projeto deve validar a edição de fichas técnicas com dados válidos.
- **CT05:** O projeto deve validar o upload de imagem de perfil de personagem.
- **CT06:** O projeto deve validar a seleção de personagem para o cartão de projeto.
- **CT07:** O projeto deve validar a edição de personagem com nome vazio.
- **CT08:** O projeto deve validar o comportamento do sistema diante de descrições excessivamente longas.
- **CT09:** O projeto deve validar a remoção de imagem de personagem.
- **CT10:** O projeto deve validar a edição de fichas técnicas com campos opcionais vazios.
- **CT11:** O projeto deve validar a remoção de personagem da seleção do cartão de projeto.

**7\. Tipos de Teste**

- Testes de Unidade
- Testes Funcionais
- Testes de Integração
- Testes de Interface
- Testes de Regressão

**8\. Riscos**

- **R01:** Falha na criação de personagens.
- **R02:** Exclusão incorreta ou incompleta de personagens.
- **R03:** Falha na edição dos dados do personagem.
- **R04:** Personagem criado ou editado com nome vazio.
- **R05:** Falha no upload da imagem de perfil.
- **R06:** Falha na remoção da imagem de perfil.
- **R07:** Imagem do personagem não persistida corretamente.
- **R08:** Falha na seleção de personagem para o cartão de projeto.
- **R09:** Falha na remoção de personagem do cartão de projeto.
- **R10:** Dados das fichas técnicas não salvos corretamente.
- **R11:** Descrições muito extensas causarem comportamento inesperado ou perda de dados.
