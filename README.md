# Projeto Integrado Mobile
Projeto Integrado do módulo de Desenvolvimento de Aplicação Móvel na UNIFEOB

## 👥 Equipe:
- Enzo Daniel Abreu
- José Carlos Pereira Neto
- Gabriel da Silva Freitas
- Lucas Paulino Gomes
- Thierry Antonello Pengo

---

## 📚 Sumário

- [Visão do Produto](#-visão-do-produto)
- [Aplicação Mobile — Flutter](#-aplicação-mobile--flutter)
- [Dependências Necessárias](#-dependências-necessárias)
- [Estrutura das Pastas](#-estrutura-das-pastas)
- [Testes de Software](#-testes-de-software)
- [Engenharia de Software](#%EF%B8%8F-engenharia-de-software)
- [Inteligência Artificial](#-inteligência-artificial)
- [Exemplo de Uso](#-exemplo-de-uso)
- [Como acessar o repositório](#-como-acessar-o-repositório)

---

## 🚩 Visão do Produto

### Problema

Muitos escritores enfrentam dificuldades significativas em estruturar os elementos complexos de suas histórias, como a construção de mundos, o desenvolvimento de arcos de personagens e a manutenção da consistência narrativa. O processo criativo muitas vezes resulta em ideias dispersas ("sem título"), furos de roteiro, falhas lógicas ou comportamentos inconsistentes de personagens que prejudicam a qualidade da obra.

### Público-alvo

- **Escritores profissionais e amadores**: buscam auxílio em todas as etapas do processo criativo;
- **Comunidade criativa em geral**: usuários interessados em roteirização e escrita estruturada.

### Objetivo

Desenvolver uma aplicação mobile orientada à escrita criativa que funcione por meio de templates customizáveis. O aplicativo visa integrar funcionalidades de escrita roteirizada e livre de forma amigável e intuitiva, permitindo que o autor estruture sua história a partir da criação de projetos que contêm as informações básicas da história e ideias sobre seus eventos.

---

## 📱 Aplicação mobile — Flutter

O framework Flutter foi escolhido para entregar uma experiência multiplataforma consistente em Android, iOS, Windows, macOS e Linux a partir de uma única base de código. O app foi pensado para atender tanto interfaces móveis quanto desktop, com atenção especial à responsividade em diferentes tamanhos de tela e à usabilidade por toque.

A implementação prioriza:

- navegação fluida entre projetos, personagens, notas e diagramas;
- estrutura de gerenciamento de conteúdo com pastas e itens organizáveis por drag-and-drop;
- suporte a imagens, tags e campos customizáveis em fichas de personagens e ideias;

Essa base Flutter permite que o aplicativo una edição de texto, organização de roteiro e ferramentas visuais em um único produto, mantendo o foco na criação e no suporte ao usuário criativo.

É importante ressaltar que na versão MVP desse projeto, as implementações de editor de diagramas, limite de sinopse e modo desempenho não foram concretizadas.

---

## 🧰 Dependências Necessárias

Para executar o projeto, é necessário possuir o ambiente Flutter configurado e instalar as bibliotecas declaradas no `pubspec.yaml`.

### Ambiente base

- `Flutter SDK` com suporte ao `Dart SDK ^3.11.0`;
- `Git` para clonar e atualizar o repositório;
- emulador Android, navegador web ou ambiente desktop compatível para executar a aplicação;
- ferramentas padrão do Flutter para cada plataforma desejada.

### Dependências utilizadas

As principais dependências do projeto são:

- `cupertino_icons`: ícones base para componentes com estilo iOS;
- `google_fonts`: uso de fontes customizadas na interface;
- `flutter_markdown` e `markdown`: renderização e manipulação de conteúdo textual em Markdown;
- `sqlite3`: persistência local de dados;
- `file_picker`: seleção de arquivos pelo usuário;
- `super_clipboard`: suporte ampliado para operações de área de transferência;
- `path` e `path_provider`: manipulação de caminhos e diretórios locais;
- `mistralai_dart`: integração com a API da Mistral para o recurso de inteligência artificial.

Para instalar todas as dependências do projeto:

```bash
flutter pub get
```

### Utilização da chave de API

A integração com IA utiliza a variável de compilação `MISTRAL_API_KEY`, lida no código por meio de `String.fromEnvironment("MISTRAL_API_KEY")`. Na prática, isso significa que a chave deve ser informada ao executar ou gerar a aplicação.

Exemplo de execução:

```bash
flutter run --dart-define=MISTRAL_API_KEY=sua_chave_aqui
```

Exemplo de build:

```bash
flutter build apk --dart-define=MISTRAL_API_KEY=sua_chave_aqui
```

Exemplo com arquivo:

```bash
flutter [run | build apk] -- dart-define-from-file=[config.json | .env]
```
---

## 🗂 Estrutura das Pastas

Tomando como referência a organização de desenvolvimento do projeto, o código segue uma separação por camadas e por domínio funcional. A pasta `lib/src` concentra a aplicação e suas features, enquanto as demais pastas agrupam plataformas, documentação e recursos auxiliares.

```text
Projeto-Integrado-Mobile/
├── android/
├── assets/
│   └── images/
├── docs/
│   └── casosUso/
├── lib/
│   └── src/
│       ├── app/
│       │   ├── database/
│       │   ├── pages/
│       │   ├── routing/
│       │   └── widgets/
│       ├── features/
│       │   ├── characters/
│       │   ├── chatbot/
│       │   ├── diagrams/
│       │   ├── notas/
│       │   ├── projects/
│       │   ├── shared/
│       │   └── tags/
│       └── shared/
├── linux/
├── test/
└── web/
```

---

## 🧪 Testes de Software

De pouco serve um software funcional se sua qualidade é inexistente. A qualidade de software garante uma utilização mais eficiente, segura e de fácil manutenção, além de contribuir para a confiabilidade e a evolução do sistema.

Com base nas normas IEEE/IEC 29119 e ISO/IEC 25010, aplicamos diferentes tipos de testes para assegurar que as principais funcionalidades da aplicação estivessem em conformidade com os requisitos funcionais levantados. Além disso, todo o processo foi devidamente documentado em uma série de artefatos que abrangem os conceitos de qualidade, o planejamento e a execução dos testes, bem como o registro dos resultados obtidos.

Como exemplo prático, há o caso automatizado `TC02 Criação de pasta com título vazio`, implementado no arquivo `test/documento_c_test.dart`. Nesse teste, o sistema tenta criar uma pasta sem preencher o título e valida que a operação deve falhar, retornando uma mensagem informando que o nome não pode ser vazio. Esse cenário é importante porque comprova, de forma automatizada, o respeito a uma regra básica de consistência dos dados e evita que conteúdos incompletos sejam persistidos no aplicativo.

---

## ⚙️ Engenharia de Software

A engenharia de software se refere ao processo anterior à programação do projeto. Para que os desenvolvedores não trabalhem de forma desorganizada e sem direcionamento, é fundamental realizar o levantamento de requisitos, o planejamento das funcionalidades e a definição da arquitetura do sistema, garantindo maior eficiência no desenvolvimento e melhor qualidade no produto final.

Primeiramente, levantamos os requisitos funcionais, não funcionais e as regras de negócios do sistema, como, por exemplo:

- **RF01 — Criação de Projeto**
- **RF02 — Editar informações**
- **RNF01 — Tela responsiva**
- **RNF02 — Modo Desempenho**
- **RN01 — Limite de Sinopse**
- **RN03 — Excluir conteúdo das pastas**

Os requisitos demonstram as funcionalidades e características que o sistema deve possuir para atender às necessidades dos usuários, incluindo tanto requisitos funcionais quanto não funcionais, como criação de projetos, edição de informações, responsividade da interface e desempenho da aplicação. Já as regras de negócio demonstram as restrições, condições e comportamentos específicos que orientam o funcionamento do sistema, como limites de caracteres em sinopses e as condições para exclusão de conteúdos dentro das pastas.

Após terminarmos de levantar os requisitos, começamos a estruturar os casos de uso com seus diagramas e, em seguida, os diagramas de atividades. Os casos de uso permitem representar as interações entre os usuários e o sistema, descrevendo de forma clara as funcionalidades disponíveis e o comportamento esperado de cada operação. Já os diagramas de atividades permitem visualizar o fluxo de execução dessas funcionalidades, detalhando etapas, decisões e possíveis caminhos dentro de cada processo, o que facilita a compreensão da lógica do sistema e o planejamento do desenvolvimento.

Alguns exemplos de casos de uso são:

- **UC01 - Criar novo projeto**
- **UC02 - Editar dados do projeto**
- **UC04 - Editar dados do personagem**
- **UC11 - Personalização e configurações de escrita**
- **UC12 - Interagir com chatbot de IA**

---

## 🤖 Inteligência Artificial

O projeto incorpora recursos de inteligência artificial pensados para apoiar o processo criativo e transformar o aplicativo em um assistente ativo. A partir das especificações do sistema, a IA é capaz de analisar o contexto atual, seja um projeto, um personagem, uma nota ou um diagrama, e gerar insights úteis para organização, perfis e sugestões narrativas.

Esses recursos incluem:

- assistente de insights contextuais que avalia o conteúdo da tela ativa e sugere melhorias;
- chatbot de IA para conversas rápidas sobre enredo, personagens e brainstorming;
- apoio na criação de perfis de personagem e no alinhamento da história com os objetivos do usuário;
- integração com o fluxo de projeto para permitir que o autor solicite ajuda sem sair da edição.

Atualmente, o agente configurado no projeto utiliza o modelo `mistral-small-latest`, acessado pela biblioteca `mistralai_dart`. A escolha desse modelo prioriza, principalmente, o consumo reduzido de tokens, o que ajuda a controlar custo e uso de contexto em interações frequentes dentro do aplicativo. Além disso, o modelo oferece boa velocidade de resposta, integração simples com o fluxo já implementado e desempenho suficiente para tarefas como brainstorming, expansão de ideias, refinamento de personagens e sugestões rápidas de escrita.

Com esse conjunto, o app vai além da simples gestão de ideias: ele se propõe a ser um suporte inteligente para quem está construindo mundos, tramas e personagens.

---

## 📝 Exemplo de Uso

Um fluxo de uso típico pode começar com o escritor criando um novo projeto para a história. Nesse momento, ele registra o título, a proposta da narrativa, a sinopse inicial e as informações-base que servirão de referência para o restante da criação. A partir desse projeto, a aplicação passa a centralizar tudo o que pertence à obra, evitando que ideias fiquem espalhadas em arquivos soltos ou anotações desconectadas.

Em seguida, o usuário pode cadastrar os personagens principais e secundários. Para cada personagem, ele organiza nome, papel na trama, características, objetivos, conflitos e observações importantes. Isso ajuda a manter coerência entre comportamento, motivação e participação de cada figura dentro da história.

Depois disso, o escritor pode criar notas para registrar cenas, diálogos, ideias de capítulos, regras do mundo fictício e lembretes de continuidade. As notas funcionam como um espaço flexível para armazenar tudo o que ainda está em elaboração, permitindo que o processo criativo avance sem exigir que a história esteja totalmente fechada desde o início.

Com o projeto, os personagens e as notas já estruturados, a inteligência artificial pode atuar como apoio complementar, sugerindo ajustes, levantando possibilidades narrativas e ajudando o usuário a desenvolver melhor o material já cadastrado. Assim, a IA não substitui a criação do autor, mas acelera revisões, brainstorming e refinamento de ideias.

Ao final da utilização, o app se mostra como uma central de organização criativa: o projeto guarda a visão geral da obra, os personagens concentram os perfis dramáticos e as notas sustentam o desenvolvimento contínuo das ideias. A estrutura do Flutter contribui diretamente para isso, pois permite manter uma interface responsiva, navegação fluida entre módulos e reaproveitamento de componentes, sustentando de forma prática as principais utilizações do aplicativo em uma única base de código.

---

## 🧭 Como acessar o repositório

1. **Clonar o repositório localmente**

   ```bash
   git clone https://github.com/aspiringluke/Projeto-Integrado-Mobile.git
   ```

2. **Baixar o repositório sem usar Git**

   Acesse a página do projeto no GitHub, clique em `Code` e depois em `Download ZIP`. Após extrair os arquivos em sua máquina, abra a pasta do projeto normalmente na IDE de sua preferência.
