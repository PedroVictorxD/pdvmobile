# Plano do App Flutter PDV Mobile Android

## Objetivo

Este documento define a criacao do app Flutter do PDV mobile do MenuFlow, com foco inicial em Android e com arquitetura preparada para evoluir para execucao em maquineta Stone sem retrabalho estrutural.

O app deve atender dois cenarios:

1. rodar bem em celular ou tablet Android comum para operacao de PDV
2. evoluir para rodar em SmartPOS Stone com integracao de pagamento no proprio terminal

O objetivo nao e apenas "funcionar", e sim entregar um app rapido, confiavel, facil de operar sob pressao, com UX clara para atendimento em restaurante, bar, cafeteria e operacoes de mesa/comanda.

## Escopo da Fase 1

Escopo inicial:

- somente Android
- Flutter como base unica do app
- autenticacao de lojista/merchant
- operacao de mesas e comandas
- catalogo PDV
- criacao manual de pedidos na mesa
- fechamento com pagamento manual
- estrutura pronta para integracao Stone

Fora do escopo da Fase 1:

- iOS
- impressao fiscal
- modo tablet kiosk fechado
- modo offline total com sincronizacao bidirecional complexa
- integracao Stone completa em producao

## Visao de Produto

O app deve se comportar como uma ferramenta de operacao rapida, nao como um app "institucional". Toda decisao de interface deve priorizar:

- leitura rapida
- poucos toques por tarefa
- estado visual muito claro
- baixa margem para erro operacional
- feedback imediato
- fluxo consistente mesmo com internet instavel

O operador principal sera garcom, caixa ou atendente. Em horarios de pico, o app precisa reduzir carga cognitiva. Isso significa:

- botoes grandes
- foco em polegar
- listas com bom contraste
- estados de carregamento enxutos
- confirmacoes apenas quando houver risco real
- acoes destrutivas com protecao

## Contexto Atual do Backend

O backend atual ja oferece boa parte do contrato necessario para o PDV:

- `GET /api/stores/{storeId}/tables`
- `GET /api/stores/{storeId}/tables/sessions`
- `GET /api/tables/{tableId}/session`
- `GET /api/stores/{storeId}/pdv-catalog`
- `POST /api/tables/{tableId}/orders`
- `POST /api/tables/{tableId}/transfer`
- `POST /api/tables/{tableId}/merge`
- `POST /api/tables/operations/{operationId}/undo`
- `POST /api/tables/sessions/{sessionId}/close`
- `POST /api/orders/{id}/pay/confirm`

Metodos de pagamento suportados pelo backend hoje:

- `PIX`
- `CASH`
- `MACHINE_CREDIT`
- `MACHINE_DEBIT`
- `LINK_CREDIT`
- `LINK_DEBIT`

Eventos realtime disponiveis:

- websocket em `/ws`
- topico de mesas: `/topic/stores/{storeId}/tables`
- topico de pedidos: `/topic/stores/{storeId}/orders`
- topico de status do pedido: `/topic/orders/{orderId}/status`

Isso permite construir uma experiencia de PDV mobile moderna sem inventar um backend paralelo.

## Estrategia de Plataforma

### Fase 1: Android comum primeiro

A primeira versao deve ser pensada para celular e tablet Android comuns. Isso acelera:

- validacao de UX
- validacao dos fluxos operacionais
- validacao de desempenho
- validacao do contrato com backend

### Fase 2: Stone SmartPOS

A versao Stone deve reaproveitar o mesmo app Flutter, adicionando uma camada Android nativa para pagamentos no terminal.

Regra de arquitetura:

- Flutter controla produto, fluxo, estado, navegacao e regras de UI
- Android nativo controla integracao especifica da Stone
- comunicacao entre Flutter e Android via `MethodChannel` ou plugin federado interno

Nao acoplar tela, estado global ou dominio do app diretamente a classes nativas da Stone.

## UX e UI

## Principios de UX

- operacao com uma mao sempre que possivel
- acao principal sempre visivel
- nunca esconder total da comanda durante edicao
- estados da mesa devem ser legiveis sem abrir detalhes
- transicoes curtas e discretas
- digitacao minimizada
- busca de produto extremamente rapida
- falhas com mensagem objetiva e recuperavel

## Direcao visual

Visual de PDV profissional, limpo e forte, sem cara de app generico.

Recomendacoes:

- tipografia tecnica e muito legivel
- contraste alto
- cores sem exagero
- sem excesso de cards arredondados ou "efeito marketplace"
- hierarquia clara por tamanho, peso e espacamento

Sugestao de linguagem visual:

- fundo claro quente ou grafite muito suave
- cor primaria ligada a operacao da marca
- cores semanticas fortes para estado
- badges compactos e altamente legiveis
- densidade visual media, nunca apertada demais

## Sistema de estados visuais

- `AVAILABLE`: verde limpo
- `OCCUPIED`: laranja ou vermelho controlado
- `OPEN`: azul operacional
- `CLOSE_REQUESTED`: amarelo de atencao
- `PAID` ou confirmado: verde escuro
- erro: vermelho com texto explicito

## Estrutura de navegacao

Navegacao principal sugerida:

1. login
2. selecao de loja
3. dashboard de mesas
4. sessao da mesa
5. catalogo e montagem do pedido
6. fechamento e pagamento
7. historico rapido ou operacoes recentes

No mobile, a tela principal deve ser o mapa/lista de mesas. Em tablet, pode existir layout master-detail depois.

## Telas principais

### 1. Login

- email e senha
- persistencia segura de sessao
- feedback de erro objetivo
- opcao de reconexao automatica

### 2. Dashboard de mesas

- grid responsivo de mesas
- status, numero, label e total resumido
- busca por mesa
- filtro por status
- indicador de atualizacao em tempo real
- CTA para abrir sessao rapidamente

### 3. Sessao/comanda da mesa

- cabecalho fixo com numero da mesa, label e status
- total da comanda sempre visivel
- lista de pedidos em ordem cronologica
- resumo por item com adicionais
- CTA fixo para adicionar pedido
- acoes de transferir, juntar, desfazer e fechar

### 4. Catalogo PDV

- busca em destaque no topo
- chips de categoria
- lista virtualizada de produtos
- card de produto enxuto
- foto opcional sem prejudicar performance
- preco sempre com destaque
- indicador de indisponivel sem remover contexto

### 5. Montagem do item

- quantidade grande e facil de alterar
- adicionais por grupo com limites claros
- observacoes curtas
- validacao imediata de min/max de adicionais
- resumo do subtotal em tempo real

### 6. Revisao do pedido

- itens agrupados
- observacoes
- subtotal do pedido
- confirmacao simples

### 7. Fechamento e pagamento

Na Fase 1:

- dinheiro
- maquininha credito manual
- maquininha debito manual

Depois:

- pagamento Stone no proprio terminal

## Fluxos criticos

### Fluxo 1: abrir mesa e lancar pedido

1. usuario toca na mesa
2. app carrega sessao atual
3. usuario toca em "Adicionar pedido"
4. busca ou escolhe produtos
5. configura adicionais
6. confirma pedido
7. app envia `POST /api/tables/{tableId}/orders`
8. sessao atualiza total e lista

### Fluxo 2: transferir comanda

1. abrir sessao
2. tocar em transferir
3. selecionar mesa destino
4. confirmar
5. app chama `POST /api/tables/{tableId}/transfer`
6. mostrar resultado e atualizar ambas as mesas

### Fluxo 3: juntar comandas

1. abrir sessao origem
2. tocar em juntar
3. selecionar mesa destino com comanda ativa
4. confirmar
5. app chama `POST /api/tables/{tableId}/merge`

### Fluxo 4: desfazer operacao

1. abrir operacoes recentes
2. validar se a ultima operacao e elegivel
3. confirmar desfazer
4. app chama `POST /api/tables/operations/{operationId}/undo`

### Fluxo 5: fechar comanda com pagamento manual

1. usuario toca em fechar
2. app mostra resumo da comanda
3. usuario escolhe `CASH`, `MACHINE_CREDIT` ou `MACHINE_DEBIT`
4. se for dinheiro, informar valor recebido quando aplicavel
5. app confirma via `POST /api/orders/{id}/pay/confirm` nos pedidos pendentes da comanda
6. ao concluir, app fecha a sessao se o backend exigir fluxo separado

Observacao importante:

Se a confirmacao e por pedido e o fechamento e por sessao, a UX precisa esconder essa complexidade. O app deve oferecer "fechar comanda" como acao unica e orquestrar internamente os passos.

## Arquitetura Flutter Recomendada

## Stack

- Flutter estavel atual do projeto
- Dart com `flutter_lints`
- `Riverpod` para estado
- `go_router` para navegacao
- `Dio` para HTTP
- `freezed` e `json_serializable` para modelos
- `flutter_secure_storage` para token
- `intl` para moeda e datas
- `stomp_dart_client` para realtime
- `cached_network_image` apenas onde imagem agregar valor

## Pilares de arquitetura

- arquitetura por features
- separacao clara entre `presentation`, `application`, `domain` e `data`
- estado imutavel
- contratos de integracao por interface
- zero regra de negocio na UI
- camada de pagamentos desacoplada do provedor

## Estrutura sugerida

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    env/
    error/
    network/
    utils/
    widgets/
  features/
    auth/
    stores/
    tables/
    sessions/
    catalog/
    orders/
    payments/
    realtime/
    settings/
  integrations/
    payments/
      payment_terminal_adapter.dart
      manual_payment_adapter.dart
      stone/
        stone_payment_channel.dart
        stone_payment_adapter.dart
```

## Contrato de pagamentos

Criar uma interface unica de terminal:

```dart
abstract interface class PaymentTerminalAdapter {
  Future<PaymentResult> pay(PaymentRequest request);
  Future<CancelResult> cancel(String transactionId);
  Future<TerminalStatus> status();
}
```

Implementacoes:

- `ManualPaymentAdapter`
- `StonePaymentAdapter`

Isso permite:

- usar pagamento manual na Fase 1
- trocar para Stone em equipamentos homologados
- manter a UI igual

## Performance

## Metas

- abrir dashboard de mesas em menos de 2 segundos em rede normal
- trocar entre mesas sem jank perceptivel
- busca de produtos com resposta imediata
- scroll suave em catalogos longos

## Boas praticas

- usar listas virtualizadas
- evitar rebuilds amplos
- manter widgets pequenos e especializados
- debouncer de busca
- cache controlado de catalogo
- skeletons leves em vez de spinners em tela cheia
- imagens com tamanho limitado
- prefetch apenas do necessario
- reconexao automatica de websocket com backoff

## Responsividade

Breakpoints minimos:

- celular pequeno
- celular grande
- tablet Android
- SmartPOS vertical

Nao assumir largura grande. A versao da maquineta pode ter tela menor e interacao mais lenta.

## Acessibilidade e operacao real

- fonte minima confortavel
- contraste AA no minimo
- alvos de toque grandes
- feedback haptico discreto onde fizer sentido
- suporte correto ao teclado numerico
- labels claras para leitores de tela, mesmo em app operacional

## Estrategia de Dados

## Online-first com resiliencia local

Na primeira versao, adotar `online-first` com cache local leve:

- token e sessao local
- ultima loja usada
- cache curto de mesas
- cache curto de catalogo
- fila local temporaria apenas para intents de UX, nao para pedidos offline completos

Nao implementar modo offline pesado na primeira entrega. Em PDV, consistencia operacional vale mais do que sincronizacao improvisada.

## Realtime

Usar websocket para:

- atualizar status das mesas
- refletir novos pedidos e mudancas de status
- evitar polling agressivo

Fallback:

- polling curto quando websocket cair
- banner discreto de "reconectando"

## Seguranca

- token JWT em armazenamento seguro
- logout ao expirar credencial sem corromper estado local
- mascarar logs sensiveis
- separar ambientes `dev`, `staging` e `prod`
- usar flavors Android desde o inicio

## Integracao Stone

## Diretriz principal

A integracao Stone deve ser tratada como uma capacidade de terminal, nao como parte central do app.

## O que a documentacao oficial indica

Pelos guias oficiais consultados, a SDK Android da Stone:

- suporta pagamentos Android com POS e pinpad
- expoe operacoes como ativacao, autorizacao, captura, cancelamento e reversao
- recomenda feedback visual durante operacoes de provider
- recomenda rodar rotina de reversao periodica para limpar transacoes com erro

As paginas oficiais consultadas tambem indicam:

- ha suporte a SmartPOS Android e pinpad
- existem fluxos por deeplink
- o deeplink ainda tem limitacoes para impressao customizada
- os modelos listados atualmente incluem `Positivo L400`, `Positivo L300`, `Sunmi P2-B`, `Sunmi P2-P` e `Tectoy T8`

## Estrategia recomendada para Stone

### Etapa 1: suporte Stone via camada Android dedicada

Criar integracao nativa Android encapsulada em:

- `StonePaymentChannel`
- `StonePaymentAdapter`
- `StoneTerminalCapabilities`

O Flutter nunca deve conhecer detalhes internos do SDK.

### Etapa 2: comecar por deeplink onde fizer sentido

Para acelerar homologacao inicial em terminal Stone:

- avaliar fluxo por deeplink do app de pagamento Stone
- usar `orderId`, `amount`, tipo de transacao e parametros de parcelamento quando aplicavel
- receber retorno no Android nativo e traduzir para `PaymentResult`

Vantagem:

- entrega inicial mais rapida

Limitacao:

- menor controle fino
- restricoes em customizacao de impressao

### Etapa 3: evoluir para SDK nativa quando necessario

Migrar para SDK nativa quando precisarmos de:

- melhor controle transacional
- cancelamento e reversao mais robustos
- experiencia mais integrada
- telemetria mais rica
- fluxos homologados por device

## Regras de produto para pagamento Stone

- a UI do app nunca deve marcar pagamento como concluido antes do retorno confiavel
- toda transacao deve ter `orderId` ou correlacao local rastreavel
- erros de comunicacao devem cair em estado de conciliacao
- divergencias entre backend e terminal devem gerar tela de resolucao operacional
- nunca assumir que o terminal concluiu apenas porque o app voltou do deeplink

## Android nativo para Stone

Preparar o modulo Android com:

- flavor ou build config para `stone`
- permissao e configuracao de intent/deeplink quando aplicavel
- camada de serializacao de requests e responses entre Kotlin e Dart
- logs estruturados de integracao
- tratamento de ciclo de vida e retorno de intent

## Qualidade e testes

## Testes Flutter

- unitarios para casos de uso
- widget tests para fluxos principais
- golden tests para estados criticos
- integration tests para login, mesas, catalogo e fechamento

## Testes Android/Stone

- teste em Android comum
- teste em tablet de baixa memoria
- teste em dispositivo SmartPOS homologado
- testes de interrupcao de rede
- testes de retorno incompleto de pagamento
- testes de reabertura do app durante transacao

## Observabilidade

- analytics operacional por fluxo
- erro tecnico com `traceId`
- logs locais diagnosticos com expiracao curta
- relatorio de falha de pagamento com contexto funcional

## Roadmap sugerido

### Sprint 1

- scaffold Flutter
- flavors Android
- autenticacao
- selecao de loja
- dashboard de mesas

### Sprint 2

- sessao/comanda
- catalogo PDV
- montagem e envio de pedido
- cache leve

### Sprint 3

- transferir, juntar e desfazer
- realtime websocket
- refinamento de UX e estados

### Sprint 4

- fechamento
- pagamento manual
- telemetria
- endurecimento de erros

### Sprint 5

- preparacao do adaptador Stone
- POC Android nativa
- validacao em SmartPOS

### Sprint 6

- homologacao Stone
- ajustes de performance por device
- conciliacao e estados de erro

## Criterios de aceite

- login persistente e seguro
- abertura de mesas e comandas sem travamento perceptivel
- busca de produto fluida
- pedido manual funcionando ponta a ponta
- transferir, juntar e desfazer funcionando com feedback claro
- fechamento manual operacional
- app funcional em Android comum
- arquitetura preparada para Stone sem reescrever o dominio

## Recomendacao final

A melhor estrategia nao e criar um "app da maquineta" logo de cara. A melhor estrategia e criar um PDV mobile Android excelente, com UX afiada e arquitetura limpa, e depois plugar a Stone como um adaptador de terminal.

Assim, o produto ganha:

- velocidade de entrega
- menor risco tecnico
- melhor testabilidade
- reuso entre celular, tablet e SmartPOS
- menos retrabalho quando a homologacao Stone entrar

## Referencias consultadas

- Backend atual do projeto:
  - `FRONTEND-PDV-HANDOFF.md`
  - `FRONTEND-PAYMENTS-HANDOFF.md`
  - `src/main/java/com/alphadevlabs/menuflow/controller/TableController.java`
  - `src/main/java/com/alphadevlabs/menuflow/controller/PaymentController.java`
  - `src/main/java/com/alphadevlabs/menuflow/config/WebSocketConfig.java`
- Documentacao oficial Stone:
  - https://sdkandroid.stone.com.br/docs/o-que-e-a-sdk-android
  - https://sdkandroid.stone.com.br/docs/dispositivos-suportados-1
  - https://sdkandroid.stone.com.br/docs/boas-pr%C3%A1ticas-de-desenvolvimento
  - https://sdkandroid.stone.com.br/page/deeplink
  - https://github.com/stone-payments/demo-sdk-android
