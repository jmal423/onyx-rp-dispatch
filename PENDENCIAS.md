# Pendências do ONYX Dispatch

Atualizar este ficheiro quando uma pendência for investigada, alterada, confirmada ou resolvida.

## Small não reaparece após reiniciar a resource

- **Estado:** por resolver; investigação pausada por prioridade do utilizador.
- **Comportamento:** depois de `restart onyx_dispatch`, o painel small não aparece automaticamente. Abrir e fechar o mapa grande faz com que apareça. O utilizador confirmou que continua a acontecer.
- **Evidência disponível:** o log mostra `Loaded Successfully!` da NUI, mas não confirma a sincronização do jogador nem a decisão de visibilidade.
- **Tentativas:** commits `4bac49e`, `75a61d2`, `c7b3803` e `6770fb1` alteraram o fluxo de restart/sincronização; não resolveram o problema e foram revertidos.
- **Estado do código:** rollback aplicado; manter o comportamento anterior a essas quatro tentativas até retomar a investigação.
- **Próxima investigação:** recolher logs temporários em cada etapa: autorização NUI, pedido `PlayerLoaded`, emprego/duty no servidor, `DutyState`, `SendSourceData`, resultado de `IsAllowed()` e mensagem `show_small`. Corrigir a etapa comprovadamente interrompida e testar no servidor após restart da resource.
- **Ideia para investigar:** a notificação de arranque “O recurso ainda está a carregar. Tente novamente dentro de alguns segundos” pode indicar uma janela em que o small tenta abrir antes de a resource/NUI ou os dados do jogador estarem prontos. Na próxima investigação, identificar quem dispara essa notificação e comparar o seu momento com `PlayerLoaded`, estado de serviço e `show_small`; só depois decidir se é preciso sincronizar ou repetir a apresentação do small.
- **Atualização (2026-10-22):** continua por resolver e não foi alterado nesta atualização dos códigos de rádio.
