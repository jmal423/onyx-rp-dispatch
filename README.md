<div align="center">

<img src="docs/brand/onyx-server-logo-wide.png" alt="Logótipo ONYX RP" width="700">

# ONYX DISPATCH

### Centro de ocorrências e gestão de unidades para FiveM

Interface NUI, alertas policiais, códigos de rádio e localização de equipas — numa resource preparada para servidores Qbox.

<p>
  <img alt="FiveM" src="https://img.shields.io/badge/FiveM-FXServer-00A86B?style=for-the-badge&logo=rockstargames&logoColor=white">
  <img alt="Qbox" src="https://img.shields.io/badge/framework-Qbox-5B8DEF?style=for-the-badge">
  <img alt="Lua 5.4" src="https://img.shields.io/badge/Lua-5.4-6E4C9A?style=for-the-badge&logo=lua&logoColor=white">
  <img alt="Idioma" src="https://img.shields.io/badge/idioma-pt--PT-D62828?style=for-the-badge">
</p>

[Instalação manual](INSTALL.md) · [Instalação com IA](AI_INSTALL.md) · [Pendências e estado](PENDENCIAS.md)

</div>

---

## ✦ O que inclui

| Área | Funcionalidade |
|---|---|
| **Central** | Painel de ocorrências, mapa de dispatch, estado e dados das unidades. |
| **Unidades** | Chamadasigns, viatura atribuída, estado de serviço e resposta a ocorrências. |
| **Mapa** | Marcadores de unidades no mapa do dispatch e blips no mapa/minimapa do GTA. |
| **Alertas** | Disparos, jogador armado junto a uma estrada, explosões e incêndios, além de radares de velocidade. |
| **Rádio** | Atalhos 10-20, 10-32, 10-99 urgente, apoio conjunto LSPD/Sheriff e pedido médico da Polícia aos EMS. |
| **Acesso** | Acesso baseado no emprego e no estado de serviço do framework. |
| **Interface** | NUI adaptável a diferentes resoluções, com posições guardadas no cliente. |

### Atalhos predefinidos

| Atalho | Ação |
|---|---|
| `Alt + 1` | Enviar 10-20 — localização da unidade |
| `Alt + 2` | Enviar 10-32 — pedir apoio à própria força |
| `Alt + 3` | Enviar 10-99 urgente — assistência à própria força |
| `Alt + 4` | Enviar 10-99 urgente conjunto — LSPD e Sheriff |
| `Alt + 5` | Se houver EMS de serviço, envia-lhes o pedido e mostra uma cópia silenciosa à Polícia e ao Sheriff. Sem EMS, não cria o chamado e avisa quem o enviou |
| `K` | Abrir/fechar o mapa do dispatch |
| `G` | Responder à ocorrência selecionada |
| `←` / `→` | Ocorrência anterior / seguinte no painel pequeno |

Os mapeamentos podem ser alterados nas definições de teclas do FiveM. O painel pequeno aparece automaticamente para unidades autorizadas quando estão de serviço.

## ↗ Instalação rápida

**Requisitos:** Qbox com camada de compatibilidade QB, `ox_lib`, `oxmysql`, FXServer build 4960+ e os asset packs licenciados exigidos pelo manifest.

1. Coloca a pasta completa em `resources/[standalone]/onyx_dispatch`.
2. Confirma os nomes dos recursos e dos empregos do teu servidor.
3. Ajusta `configs/config.lua`, em especial `Config.AllowedJobs`, `Config.BlipData` e as permissões do modo operador.
4. Inicia `oxmysql`, `ox_lib`, Qbox e a camada QB compatível antes da resource.
5. Adiciona `ensure onyx_dispatch` ao `server.cfg`.
6. Inicia a resource e confirma a ligação à base de dados e a persistência dos callsigns.

> Para os passos completos, exemplos de configuração e checklist de validação, segue [INSTALL.md](INSTALL.md). Para delegar o processo a um agente, usa o prompt em [AI_INSTALL.md](AI_INSTALL.md).

## ⚙️ Requisitos e configuração

- **Framework alvo:** Qbox através da camada de compatibilidade QB chamada `qb-core` por predefinição. Se o teu servidor usar outro nome ou eventos, configura `Config.FrameworkTriggers.qbcore`.
- **Base de dados:** `oxmysql`. Com `Config.AutoInsertSQL = true`, a resource cria a tabela `onyx_dispatch` e tenta preservar os callsigns numa migração existente.
- **Empregos:** os valores incluídos (`police`, `sheriff`, `ambulance`) são exemplos. Usa os nomes exatos de `job.name` do teu servidor.
- **Agrupamento:** `Config.AllowedJobs` define quem tem acesso e que unidades são agrupadas; cada `job_table` define os destinatários de uma chamada específica.
- **Chamadas civis:** os comandos estão desativados por predefinição. Revê os destinatários antes de os ativares.
- **Cooldown de rádio:** 3 segundos por grupo, ajustável em `Config.RadioCodes.cooldown`.
- **Modo operador:** opcional. A alteração de canal de rádio suporta `pma-voice`, `mumble-voip` e Toko; outros VOIP precisam de uma integração própria.
- **Chefia do dispatch:** o grau mais alto configurado no Qbox de cada emprego em `Config.Dispatcher.Perms` pode ativar o modo operador. A validação é feita no servidor e o modo termina ao sair de serviço.
- **Encaminhamento entre forças:** `Config.Dispatcher.AlertRouting` separa alertas policiais, pedidos médicos e cópias silenciosas para observadores. Ajusta os empregos antes de instalar noutro servidor.

## ◉ Alertas: incluído e por integrar

**Incluído:** alertas policiais configuráveis para disparos, jogadores armados junto a vias, explosões, incêndios e radares, com filtros e cooldowns. O alerta de pessoa armada só é emitido quando um jogador armado está até 22 m de uma via (ajustável em `Config.IncidentAlerts`). Disparos não dependem da proximidade a uma via. Explosões usam o evento OneSync do FXServer e verificam a distância ao jogador que as originou; incêndios são detetados por unidades policiais de serviço próximas. Os alertas policiais são encaminhados a Polícia e Sheriff. Os códigos 10-20, 10-32 e 10-99 são enviados manualmente pelos atalhos de rádio. O pedido médico de Alt+5 só é criado quando há EMS de serviço; é encaminhado operacionalmente apenas aos EMS. Polícia e Sheriff de serviço veem uma cópia silenciosa, apenas informativa, com a lista e a distância das unidades EMS a caminho. Sem EMS, o chamado não é criado e quem o enviou recebe um aviso.

**Ainda requer integração com outros recursos:** assaltos. O alerta 10-90 não é criado automaticamente até cada recurso validar o início e chamar o export server-side `SendAlert`. Não ligues o alerta a eventos client-side de tentativa: são falsificáveis e podem gerar chamadas falsas. O estado e os testes pendentes estão em [PENDENCIAS.md](PENDENCIAS.md).

## ⌘ Exports

Os exports client e server usam o nome da resource `onyx_dispatch`:

```lua
-- Client
local playerInfo = exports['onyx_dispatch']:GetPlayerInfo()
local notifications = exports['onyx_dispatch']:GetPlayerNotifications()

-- Server
local dispatchPlayers = exports['onyx_dispatch']:GetPlayersDispatchData(source)
local dispatchConfig = exports['onyx_dispatch']:GetConfig()

-- Server, dentro de outro recurso (após validar o evento original):
local sent, operationalCount, observerCount = exports['onyx_dispatch']:SendAlert({
    category = 'police',
    jobs = { 'police', 'sheriff' },
    observer_jobs = {},
    coords = GetEntityCoords(GetPlayerPed(source)),
    title = '10-90 - Assalto em curso',
    message = 'Alarme confirmado no estabelecimento.',
    flash = true,
    sound = 4,
})
```

`SendAlert` e os exemplos de integração estão detalhados em [INTEGRATION.md](INTEGRATION.md). A exportação é apenas server-side; valida a categoria e só entrega a unidades de serviço configuradas em `AlertRouting`.

Os eventos públicos também usam o namespace `onyx_dispatch`. Atualiza integrações externas para os nomes atuais antes de substituir uma instalação existente.

## 🗂 Estrutura

```text
onyx_dispatch/
├── client/       # Interface de jogo, unidades e alertas
├── configs/      # Configuração do framework, empregos, teclas e idiomas
├── html/         # Interface NUI, mapas, imagens, bibliotecas e sons
├── server/       # Ocorrências, unidades, alertas e persistência
├── AI_INSTALL.md # Procedimento e prompt para instalação assistida por IA
├── INSTALL.md    # Guia de instalação Qbox
├── INTEGRATION.md # API server-side para alertas de outros recursos
└── fxmanifest.lua
```

## ⚠️ Notas de distribuição

- Mantém os assets e bibliotecas referenciados pela NUI; não distribuas uma cópia incompleta.
- Inclui apenas asset packs que tens autorização para redistribuir.
- Não guardes neste repositório credenciais, ficheiros `secrets`, logs ou dados da base de dados.
- A instalação deve ser validada no servidor de destino. Uma revisão do código ou do manifest não substitui o teste dentro do FiveM.
