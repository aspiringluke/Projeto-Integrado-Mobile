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
- [Testes de Software](#-testes-de-software)
- [Engenharia de Software](#%EF%B8%8F-engenharia-de-software)
- [Inteligência Artificial](#-inteligência-artificial)
- [Como acessar o repositório](#-como-acessar-o-repositório)

---

## 🚩 Visão do Produto

### Problema

Muitos escritores enfrentam dificuldades significativas em estruturar os elementos complexos de suas histórias, como a construção de mundos, o desenvolvimento de arcos de personagens e a manutenção da consistência narrativa. O processo criativo muitas vezes resulta em ideias dispersas ("sem título"), furos de roteiro, falhas lógicas ou comportamentos inconsistentes de personagens que prejudicam a qualidade da obra.

### Público-Alvo

- **Escritores profissionais e amadores**: Buscam auxílio em todas as etapas do processo criativo;
- **Comunidade criativa em geral**: Usuários interessados em roteirização e escrita estruturada.

### Objetivo

Desenvolver uma aplicação mobile orientada à escrita criativa que funcione através de templates customizáveis. O aplicativo visa integrar funcionalidades de escrita roteirizada e livre de forma amigável e intuitiva, permitindo que o autor estruture sua história a partir da criação de projetos que contêm as informações básicas da história e ideias sobre seus eventos.

---

## 📱 Aplicação mobile — Flutter

O framework Flutter foi escolhido para entregar uma experiência multiplataforma consistente em Android, iOS, Windows, macOS e Linux a partir de uma única base de código. O app foi pensado para atender tanto interfaces móveis quanto desktop, com atenção especial à responsividade em diferentes tamanhos de tela e à usabilidade por toque.

A implementação prioriza:

- navegação fluida entre projetos, personagens, notas e diagramas;
- estrutura de gerenciamento de conteúdo com pastas e itens organizáveis por drag-and-drop;
- editor de diagramas com nós, arestas e grupos para modelar relações narrativas de forma visual;
- suporte a imagens, tags e campos customizáveis em fichas de personagens e ideias;
- modo de desempenho que reduz animações e sombras para rodar melhor em dispositivos de entrada;
- validação de limites de sinopse e persistência local para evitar perda de dados.

Essa base Flutter permite que o aplicativo una edição de texto, organização de roteiro e ferramentas visuais em um único produto, mantendo o foco na criação e no suporte ao usuário criativo.

É importante ressaltar que na versão MVP desse projeto, as implementações de editor de diagramas e gerenciamento de conteúdo com drag-and-drop não foram concretizados.

---

## 🧪 Testes de Software

De pouco serve um software funcional se sua qualidade é inexistente. A qualidade de software garante uma utilização mais eficiente, segura e de fácil manutenção, além de contribuir para a confiabilidade e a evolução do sistema.

Com base nas normas IEEE/IEC 29119 e ISO/IEC 25010, aplicamos diferentes tipos de testes para assegurar que as principais funcionalidades da aplicação estivessem em conformidade com os requisitos funcionais levantados. Além disso, todo o processo foi devidamente documentado em uma série de artefatos que abrangem os conceitos de qualidade, o planejamento e a execução dos testes, bem como o registro dos resultados obtidos.

---

## ⚙️ Engenharia de Software

A engenharia de software se refere ao processo anterior à programação do projeto. Para que os desenvolvedores não trabalhem de forma desorganizada e sem direcionamento, é fundamental realizar o levantamento de requisitos, o planejamento das funcionalidades e a definição da arquitetura do sistema, garantindo maior eficiência no desenvolvimento e melhor qualidade no produto final.

Primeiramente levantamos os requisitos funcionais, não funcionais e regras de negócios do sistema, como, por exemplo:

- **RF01 — Criação de Projeto**
- **RF02 — Editar informações**
- **RNF01 — Tela responsiva**
- **RNF02 — Modo Desempenho**
- **RN01 — Limite de Sinopse**
- **RN03 — Excluir contéudo das pastas**

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

O projeto incorpora recursos de inteligência artificial pensados para apoiar o processo criativo e transformar o aplicativo em um assistente ativo. A partir das especificações do sistema, a IA é capaz de analisar o contexto atual — seja um projeto, um personagem, uma nota ou um diagrama — e gerar insights úteis para organização, perfis e sugestões narrativas.

Esses recursos incluem:

- assistente de insights contextuais que avalia o conteúdo da tela ativa e sugere melhorias;
- chatbot de IA para conversas rápidas sobre enredo, personagens e brainstorming;
- apoio na criação de perfis de personagem e no alinhamento da história com os objetivos do usuário;
- integração com o fluxo de projeto para permitir que o autor solicite ajuda sem sair da edição.

Com esse conjunto, o app vai além da simples gestão de ideias: ele se propõe a ser um suporte inteligente para quem está construindo mundos, tramas e personagens.

---

## 🧭 Como acessar o repositório

1. **Clonar o repositório localmente**

    ```bash
    git clone https://github.com/aspiringluke/Projeto-Integrado-Mobile.git
    ```

2. **Instalar as dependências**

    ```bash
    flutter pub get
    ```

