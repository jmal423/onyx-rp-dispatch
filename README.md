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
| **Alertas** | Alertas policiais configuráveis para disparos e radares de velocidade. |
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
| `Alt + 5` | Polícia pede assistência médica aos EMS; Polícia e Sheriff de serviço veem o pedido e as unidades EMS a caminho, sem som e sem poder responder |
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
- **Modo operador:** opcional. A alteração de canal de rádio suporta `pma-voice`, `mumble-voip` e Toko; outros VOIP precisam de uma integração própria.

## ◉ Alertas: incluído e por integrar

**Incluído:** alertas policiais configuráveis para disparos e radares, com filtros de empregos, armas, zonas e cooldown. Os códigos 10-20, 10-32 e 10-99 são enviados manualmente pelos atalhos de rádio. O pedido médico de Alt+5 é encaminhado operacionalmente apenas aos EMS; Polícia e Sheriff de serviço veem uma cópia silenciosa, apenas informativa, com a lista e a distância das unidades EMS que estão a caminho.

**Ainda requer integração com outros recursos:** assaltos, pessoas armadas, explosões e incêndios. A resource não deteta automaticamente esses eventos por defeito. O estado atual está em [PENDENCIAS.md](PENDENCIAS.md).

## ⌘ Exports

Os exports client e server usam o nome da resource `onyx_dispatch`:

```lua
-- Client
local playerInfo = exports['onyx_dispatch']:GetPlayerInfo()
local notifications = exports['onyx_dispatch']:GetPlayerNotifications()

-- Server
local dispatchPlayers = exports['onyx_dispatch']:GetPlayersDispatchData(source)
local dispatchConfig = exports['onyx_dispatch']:GetConfig()
```

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
└── fxmanifest.lua
```

## ⚠️ Notas de distribuição

- Mantém os assets e bibliotecas referenciados pela NUI; não distribuas uma cópia incompleta.
- Inclui apenas asset packs que tens autorização para redistribuir.
- Não guardes neste repositório credenciais, ficheiros `secrets`, logs ou dados da base de dados.
- A instalação deve ser validada no servidor de destino. Uma revisão do código ou do manifest não substitui o teste dentro do FiveM.
