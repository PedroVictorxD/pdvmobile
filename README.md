# PDV Mobile

Aplicativo Flutter para operacao de garcom e suporte ao lancamento de pedidos em mesas, com foco inicial em Android e evolucao planejada para maquininhas de cartao com Android.

## Objetivo

O projeto sera usado como apoio operacional em restaurante, bar e cafeteria, priorizando:

- lancamento rapido de pedidos
- consulta de mesas e comandas
- fechamento com pagamento manual na Fase 1
- base arquitetural pronta para integracao futura com terminal Stone

O documento funcional principal esta em `docsmd/FLUTTER-PDV-MOBILE-ANDROID-STONE-PLAN.md`.

## Estrategia de branches

Seguiremos um fluxo simples inspirado em Git Flow:

- `main`: branch principal e estavel
- `develop`: branch de integracao das features
- `feature/nome-da-feature`: branch temporaria para cada nova funcionalidade
- `hotfix/nome-do-ajuste`: branch temporaria para correcoes urgentes saindo de `main`

Regras do projeto:

- cada feature nasce em uma nova branch `feature/*`
- cada feature e commitada separadamente
- nenhuma nova implementacao sera commitada fora do fluxo definido
- hotfix nao sera uma branch permanente; criaremos `hotfix/*` quando necessario

## Fluxo de trabalho

1. criar branch a partir de `develop` com o padrao `feature/nome-da-feature`
2. implementar apenas o escopo da feature
3. commitar somente a feature trabalhada
4. integrar em `develop`
5. quando necessario, criar `hotfix/nome-do-ajuste` a partir de `main`

## Status atual

- base Flutter criada
- definicao inicial de Git e branches em andamento
- proximo passo: organizar o plano de implementacao por features
