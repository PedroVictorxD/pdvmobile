# Git Flow do PDV Mobile

## Branches base

- `main`: representa a linha principal e estavel do projeto
- `develop`: concentra a integracao das features concluidas

## Branches temporarias

- `feature/nome-da-feature`: usada para desenvolvimento de uma funcionalidade
- `hotfix/nome-do-ajuste`: usada para correcao urgente a partir de `main`

## Padrao operacional

1. partir de `develop` para criar uma `feature/*`
2. manter o escopo da branch focado em uma unica entrega
3. commitar apenas o que pertence a essa feature
4. integrar a feature em `develop`
5. criar `hotfix/*` a partir de `main` somente quando houver necessidade real

## Observacoes

- nao manteremos uma branch fixa chamada `hotfix`
- o prefixo `hotfix/` sera usado sob demanda, que e o comportamento mais alinhado ao Git Flow
- a `main` deve permanecer a referencia mais segura do projeto
