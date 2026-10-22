# Adaptadores de assaltos Qbox do servidor de testes

Cada recurso chama a mesma exportação `SendRobberyAlert`; a diferença fica limitada ao ponto onde o recurso confirma o assalto e aos dados da localização. Ao trocar um recurso, move a chamada correspondente para o evento de sucesso do novo script. Não copies títulos, som, blips ou encaminhamento: isso está centralizado em `Config.RobberyAlerts`.

| Recurso | Ponto confirmado | Tipo ONYX | Localização enviada |
| --- | --- | --- | --- |
| `qbx_storerobbery` | `server:registerOpened`, depois da sessão/tempo/distância serem validados; `completeSafe`, depois do código e sessão serem validados | `store_register` / `store_safe` | Coordenadas da caixa ou cofre |
| `qbx_bankrobbery` | `server:setBankState`, após validar a autorização, expiração, polícia necessária e proximidade e confirmar a abertura do banco | `bank_fleeca`, `bank_paleto` ou `bank_pacific` | Entrada do banco configurada |
| `qbx_jewelery` | `fireAlarm`, alcançado depois de uma vitrine abrir com sucesso; o bloqueio `alarmFired` evita repetir | `jewelry` | Posição do jogador que confirmou a vitrine |
| `qbx_houserobbery` | Após skillcheck confirmado e atraso `callCopsTimeout` | `house` | Coordenadas exteriores da casa |
| `qbx_truckrobbery` | `server:startMission`, depois de validar jogador, distância, disponibilidade, saldo, polícia e cobrança | `armored_truck` | Ponto de partida escolhido para o camião |

Os cinco `fxmanifest.lua` do servidor de testes declaram `dependency 'onyx_dispatch'`, para o export estar disponível antes dos adaptadores. Estes cinco pontos de chamada vivem nos recursos Qbox do servidor de testes; não fazem parte da pasta distribuível `onyx_dispatch`. Ao trocar um script, só é preciso portar o ponto de chamada correspondente para o novo servidor. As notificações originais de `qbx_police` foram mantidas nesta primeira passagem; verificar no teste se o telefone/blip Qbox e o painel ONYX criam duplicação indesejada.

## Molde para um recurso futuro

```lua
exports['onyx_dispatch']:SendRobberyAlert({
    kind = 'bank_fleeca', -- ou um tipo novo registado em Config.RobberyAlerts.TYPES
    location = 'Fleeca — Legion Square',
    coords = serverValidatedCoords,
    unique_id = ('recurso:ocorrencia:%s'):format(serverIncidentId),
})
```

O `unique_id` tem de identificar aquela instância do assalto e ser estável para chamadas repetidas do mesmo evento. Gera-o no servidor; não confies num ID fornecido pelo cliente. Só chama a exportação depois das verificações de autorização, localização, estado e início confirmado do recurso de origem.
