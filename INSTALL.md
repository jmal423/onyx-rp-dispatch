# Instalação do ONYX Dispatch num servidor Qbox

Este guia cobre a instalação numa instalação Qbox com `ox_lib` e `oxmysql`. A configuração incluída está adaptada ao servidor de desenvolvimento ONYX; é obrigatório ajustar os nomes dos empregos e as permissões para cada servidor.

## Requisitos

- FXServer com build **4960 ou superior**.
- Qbox com a camada de compatibilidade QB disponível como `qb-core` (é o nome usado pela configuração atual para obter o objeto QBCore).
- `ox_lib` e `oxmysql`, iniciados antes desta resource.
- Os asset packs exigidos pelo manifest e distribuídos/licenciados com a cópia da resource.
- Base de dados configurada e acessível através do `oxmysql`.

## 1. Instalar a resource

1. Copia a pasta para `resources/[standalone]/onyx_dispatch`.
2. Mantém o nome da pasta exatamente como `onyx_dispatch`; os exemplos de exports dependem dele.
3. Confirma que `fxmanifest.lua`, `html/`, `client/`, `server/` e `configs/` estão diretamente dentro dessa pasta. Evita uma pasta duplicada como `onyx_dispatch/onyx_dispatch/`.

Não removas `html/images`, `html/sound` ou ficheiros de biblioteca referenciados pela NUI. A resource não fica completa se esses assets não forem incluídos na cópia licenciada.

## 2. Configurar a ordem de arranque

No `server.cfg`, garante que a base de dados, `ox_lib`, Qbox e a compatibilidade QB arrancam antes do dispatch. Exemplo; ajusta os nomes/grupos à estrutura do teu servidor:

```cfg
ensure oxmysql
ensure ox_lib
ensure qbx_core
ensure qb-core # camada de compatibilidade QB usada pela configuração atual
ensure onyx_dispatch
```

Se o teu pack Qbox não incluir a resource de compatibilidade `qb-core`, instala/ativa a camada de compatibilidade suportada pelo pack antes do dispatch. Se tiver outro nome, altera `Config.FrameworkTriggers.qbcore.resource_name` em `configs/config.lua` para o nome real. O framework deve disponibilizar `GetCoreObject` e os eventos de carregamento, alteração de emprego e serviço configurados nesse bloco.

## 3. Configurar framework, base de dados e notificações

Em `configs/config.lua`, confirma estas opções:

```lua
Config.Framework = 'qbcore'
Config.Database = 'oxmysql'
Config.AutoInsertSQL = true
Config.Notification = 'ox_lib'
Config.Language = 'PT'
```

`auto_detect` existe, mas para uma instalação nova é mais previsível escolher explicitamente `qbcore` e `oxmysql`. Se mudares o nome do recurso QB ou os eventos do framework, atualiza também `Config.FrameworkTriggers.qbcore`.

Com `Config.AutoInsertSQL = true`, a resource cria a tabela `onyx_dispatch` na base de dados ativa e, quando aplicável, migra os callsigns da tabela anterior. Se preferires gerir SQL manualmente, define a opção como `false` e cria a tabela equivalente com as colunas `identifier` (VARCHAR(50)) e `callsign` (VARCHAR(100)). Faz cópia de segurança da base de dados antes de instalar ou migrar.

## 4. Adaptar empregos e permissões

Os nomes têm de coincidir exatamente com `job.name` do teu Qbox. A configuração incluída usa `police`, `sheriff` e `ambulance`; substitui-os pelos empregos reais do servidor.

- `Config.AllowedJobs`: empregos autorizados a usar o dispatch e agrupamento de unidades que se veem entre si.
- `Config.BlipData`: define cores para cada emprego que aparece no mapa. Adiciona uma entrada para cada emprego incluído em `AllowedJobs`.
- `Config.Dispatcher.Perms`: emprego e grade mínima para funções do modo operador.
- `Config.PoliceAlerts.police_jobs`: empregos que recebem os alertas policiais automáticos.
- `Config.PoliceAlerts.whitelisted_jobs`: empregos que não devem gerar esses alertas (por exemplo, disparos de agentes).
- `Config.JobCallCommands`: comandos de chamadas civis, desativados por predefinição com `ENABLE = false`. Se os ativares, revê o `job_table` de cada comando.

Não copies cegamente a lista de empregos de exemplo. Em particular, `AllowedJobs` controla o acesso/agrupamento do dispatch, enquanto `job_table` de cada chamada controla quem recebe aquela chamada.

## 5. Confirmar controlos e integrações

As teclas são editáveis em `Config.RadioCodes`, `Config.large_ui`, `Config.respond`, `Config.small_ui_left` e `Config.small_ui_right`. Os valores padrão dos atalhos de rádio são Alt+1 (10-20), Alt+2 (10-32), Alt+3 (10-99 urgente da própria força), Alt+4 (10-99 urgente conjunto LSPD/Sheriff) e Alt+5 (pedido policial de assistência médica aos EMS). O mapa abre em K e a resposta usa G. Os jogadores podem alterar os mapeamentos nas definições de FiveM.

Se ativares o modo operador, configura `Config.Dispatcher.VoipResource` para o VOIP suportado pelo teu servidor (`pmavoice`, `mumble`, `toko` ou `other`). A opção `other` exige implementar as funções de rádio em `client/other/dispatcher.lua`. O dispatch e os alertas básicos não precisam do modo operador.

Os exports próprios e eventos públicos usam o namespace `onyx_dispatch`. Atualiza scripts externos que ainda chamem outros nomes; não assumas compatibilidade automática com integrações antigas. Exemplos de exports estão no [README](README.md).

## 6. Testar no servidor

1. Reinicia o servidor ou inicia a resource pela consola do txAdmin.
2. Confirma que não há erros de dependência, framework ou ligação à base de dados na consola.
3. Entra com um personagem cujo emprego esteja em `Config.AllowedJobs` e passa a serviço.
4. Confirma que o painel pequeno aparece, que K abre o mapa e que G responde a uma ocorrência de teste.
5. Confirma que um personagem fora de serviço ou com emprego não autorizado não vê o dispatch.
6. Testa os códigos de rádio e uma chamada civil apenas se tiveres ativado essas opções.
7. Confirma na base de dados que a tabela `onyx_dispatch` existe e que o callsign fica guardado após sair e voltar a entrar.

O comando de teste `dispatchtest` vem desativado. Ativa `Config.EnableTestCommand` apenas num ambiente de teste e volta a desligá-lo antes de abrir o servidor ao público.

## Limites conhecidos

- A configuração e este guia têm como alvo Qbox com compatibilidade QB e `oxmysql`; não são uma validação de instalação em ESX ou em frameworks personalizados.
- O alerta automático de disparos depende das opções em `Config.PoliceAlerts`. Alertas de assaltos, pessoas armadas, explosões e incêndios precisam de integração específica com os recursos que geram esses eventos.
- Mudanças no cliente, na NUI, nos jobs ou no VOIP têm de ser testadas no servidor real. A validação estática do código não substitui o teste em jogo.
