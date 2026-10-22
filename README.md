# ONYX Dispatch

Recurso de dispatch para FiveM, instalado como `onyx_dispatch` em `resources/[standalone]`.

## Estrutura

- `client/`: interface de jogo, unidades, alertas e comandos de chamada.
- `server/`: estado partilhado, persistência e encaminhamento de alertas.
- `configs/`: opções, eventos/framework e idiomas.
- `html/`: interface NUI, mapas, ícones, bibliotecas e sons.

## Dependências

- `ox_lib`
- `oxmysql`
- assetpacks do recurso original
- FXServer com build 4960 ou superior

No `server.cfg`, iniciar `ox_lib` e `oxmysql` antes de `onyx_dispatch`.

## Base de dados

`Config.AutoInsertSQL` está ativo por predefinição. O recurso cria a tabela `onyx_dispatch` para guardar os callsigns. No arranque, migra a tabela anterior automaticamente e preserva os callsigns existentes.

## Compatibilidade

O nome da resource, dos exports e do namespace de eventos é `onyx_dispatch`. Recursos externos que ainda chamem os eventos antigos têm de atualizar as chamadas para o novo namespace.

### Usar os exports

As integrações devem apontar para o nome atual da resource:

```lua
-- Client
local playerInfo = exports['onyx_dispatch']:GetPlayerInfo()
local notifications = exports['onyx_dispatch']:GetPlayerNotifications()

-- Server
local dispatchPlayers = exports['onyx_dispatch']:GetPlayersDispatchData(source)
local dispatchConfig = exports['onyx_dispatch']:GetConfig()
```

Todos os exports, eventos, chaves de locale e a tabela dos callsigns usam `onyx_dispatch`.

## Alertas de ocorrências

- O alerta automático 10-13 deteta disparos não silenciados e respeita a whitelist de armas, empregos, zonas e cooldown configurados.
- 10-20 e 10-99 são códigos de rádio manuais; não representam deteção automática de assaltos ou outras ocorrências.
- Alertas automáticos 10-90, 10-72, explosões e incêndios ainda não estão integrados. Os recursos Qbox de assalto atualmente encaminham os seus alertas para `qbx_police`, sem os enviar para o painel Onyx.
- O levantamento, limites e próximos passos estão em [PENDENCIAS.md](PENDENCIAS.md).

## Segurança e manutenção

- Não guardar credenciais, ficheiros de configuração do servidor, logs ou cache neste repositório.
- As chamadas entre NUI e Lua usam o nome do recurso fornecido pelo FiveM; não dependem de um URL externo.
- Antes de adicionar integrações externas, validar o destino e os dados no servidor.
- Manter ficheiros de bibliotecas e assets originais enquanto forem referenciados pela interface ou pelo código.
