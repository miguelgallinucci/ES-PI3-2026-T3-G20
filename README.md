# MesclaInvest

Projeto acadêmico desenvolvido para a disciplina **Projeto Integrador 3 (PI3)** — Engenharia de Software — PUC-Campinas (2026).

## Objetivo do projeto
O MesclaInvest é uma plataforma acadêmica de investimentos em startups por meio de tokens digitais. O projeto visa demonstrar a viabilidade técnica de um ecossistema de investimentos descentralizado, focando na integração entre uma aplicação móvel performática e um backend resiliente baseado em serviços de nuvem. A plataforma permite a exploração de oportunidades, análise técnica de ativos e a gestão de carteiras digitais em um ambiente controlado e didático.

## Tecnologias utilizadas
- **Flutter/Dart**: Desenvolvimento da aplicação móvel com foco em experiência do usuário e alta fidelidade visual.
- **Firebase Auth**: Gestão de identidade, autenticação segura e controle de acesso.
- **Cloud Firestore**: Banco de Dados NoSQL escalável para sincronização de dados em tempo real.
- **Firebase Cloud Functions**: Backend serverless para processamento de regras de negócio e operações críticas.
- **Node.js/TypeScript**: Ambiente de execução e linguagem tipada para o desenvolvimento do backend.

## Arquitetura geral
O sistema adota uma arquitetura distribuída e desacoplada, garantindo segurança e separação de responsabilidades:
- **`mobile/`**: Aplicativo móvel responsável pela interface, navegação, apresentação de dados e interação direta com o usuário através de serviços dedicados.
- **`functions/`**: Backend em Cloud Functions que concentra a lógica de negócio e o processamento de transações, assegurando a integridade dos dados no banco de dados.

## Estrutura de pastas
```text
projeto/
├── mobile/                 # Código fonte da aplicação móvel
│   ├── lib/
│   │   ├── core/           # Tema, utilitários e constantes globais
│   │   ├── shared/         # Componentes reutilizáveis e globais
│   │   └── features/       # Módulos organizados por domínio de funcionalidade
├── functions/              # Código fonte do ecossistema de backend
│   ├── src/                # Lógica das Cloud Functions organizada por serviços
├── firebase.json           # Configuração de infraestrutura Firebase
└── README.md               # Documentação técnica do projeto
```

## Organização do Frontend
A aplicação móvel é organizada seguindo o padrão de **Features**, otimizando a manutenção e escalabilidade:
- **Pages**: Telas que compõem o fluxo de navegação da aplicação.
- **Widgets**: Componentes específicos de cada funcionalidade.
- **Services**: Camada de comunicação com o Firebase e orquestração de dados.
- **Models**: Estruturas de dados tipadas e lógica de serialização.
- **core/utils**: Utilitários globais como formatadores de entrada, máscaras e constantes.
- **shared/widgets**: Componentes de interface padronizados que garantem consistência visual.

## Organização do Backend
O backend é estruturado de forma modular e extensível em `functions/src/`:
- **auth**: Gestão de perfis e dados de usuário após a autenticação.
- **wallet**: Operações de gestão de saldo e controle da carteira digital.
- **startups**: Gestão de interações, dúvidas e curadoria do catálogo.
- **transactions**: Processamento centralizado de aquisição de ativos.
- **shared**: Recursos compartilhados, utilitários e instâncias do Firebase Admin SDK.

## Funcionalidades do sistema
- **Autenticação de usuários**: Sistema seguro de login, registro e recuperação de acesso.
- **Cadastro inteligente**: Fluxo de registro com validações em tempo real e máscaras automáticas de entrada.
- **Catálogo de startups**: Listagem detalhada de oportunidades com segmentação por setor e estágio de maturação.
- **Detalhamento técnico**: Acesso a informações estratégicas, estrutura societária e documentos das startups.
- **Comunicação interativa**: Canal para envio de perguntas e esclarecimento de dúvidas sobre ativos.
- **Carteira digital**: Central de controle para gestão de saldo disponível e ativos adquiridos.
- **Histórico de movimentações**: Registro cronológico e detalhado de todas as operações realizadas.
- **Aquisição de tokens**: Fluxo transacional orquestrado via Cloud Functions com validação de saldo disponível.
- **Balcão de negociações**: Ambiente dedicado para visualização e interação com ofertas de ativos.
- **Dashboard de acompanhamento**: Painel visual com métricas de desempenho e evolução dos ativos.

## Cloud Functions
As operações de backend são processadas pelas seguintes Cloud Functions:
- `createUserProfile`: Responsável por inicializar a estrutura de dados do usuário no banco de dados.
- `addSimulatedBalance`: Realiza a adição de saldo inicial para utilização na carteira do usuário.
- `sendQuestion`: Processa e organiza o envio de dúvidas enviadas por investidores.
- `buyTokens`: Orquestra a transação de compra de ativos, garantindo a atomicidade da operação.

## Como executar o projeto

### Frontend (Mobile)
```bash
cd mobile
flutter pub get
flutter run
```

### Backend (Functions)
```bash
cd functions
npm install
npm run build
```

## Comandos de verificação
Para validação técnica da qualidade do código:
- **Análise Estática**: `cd mobile && flutter analyze`
- **Validação de Backend**: `cd functions && npm run build` (Garante a integridade do código TypeScript)

## Observações importantes
- **Publicação de Cloud Functions**: O funcionamento em ambiente conectado exige que as funções de backend sejam publicadas no console do Firebase.
- **Ambiente de Infraestrutura**: O deploy das funções de nuvem depende da configuração correta do projeto no Firebase e da utilização do plano de serviço adequado.
- **Gerenciamento da pasta functions/lib**: Esta pasta é gerada automaticamente durante o processo de build. Alterações devem ser feitas exclusivamente nos arquivos da pasta `src`.
- **Integridade de Dados**: Os esquemas de dados no Firestore são padronizados para garantir a compatibilidade entre a aplicação móvel e o backend.

## Próximas evoluções
- Expansão das regras operacionais do balcão de negociações.
- Evolução contínua das métricas analíticas do dashboard.
- Refinamento progressivo das regras de segurança e acesso do banco de dados.
- Automação do fluxo de publicação das Cloud Functions.
- Implementação de baterias de testes integrados para o fluxo transacional completo.

## Integrantes
- Alycia Santos Bond
- Matheus Fernando de Camargo
- Miguel Batista Gallinucci
- Pedro Alencar Biliu Vale Vieira
