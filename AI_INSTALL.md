# Instalação assistida por IA

Este ficheiro é um procedimento para um agente de IA instalar `onyx_dispatch` num servidor FiveM Qbox. O agente deve executar as verificações e alterações no workspace do servidor, sem adivinhar configurações.

## Prompt para copiar

```text
Instala a resource ONYX Dispatch neste servidor FiveM Qbox.

Segue AI_INSTALL.md e INSTALL.md dentro da pasta da resource. Primeiro inspeciona o servidor e identifica o caminho correto, as dependências e os nomes reais dos empregos. Não inventes valores: pergunta apenas pelos dados necessários que não consigas confirmar nos ficheiros/configuração existente.

Faz uma cópia de segurança dos ficheiros que alterares, instala a pasta com o nome onyx_dispatch, configura dependências e ordem de arranque, ajusta apenas as opções necessárias para este servidor e apresenta um resumo das alterações e dos passos de teste.

Não exponhas credenciais, tokens, connection strings, chaves ou conteúdo de ficheiros secrets. Não apagues tabelas nem dados existentes. Não reinicies ou pares o servidor sem autorização explícita. Não afirmes que foi testado dentro do jogo se não o foi.
```

## Procedimento obrigatório do agente

### A. Inspecionar antes de alterar

1. Determina a raiz real do servidor e o perfil txAdmin ativo; não assumes que a resource atual ou o `server.cfg` deste repositório pertencem ao destino.
2. Confirma que o destino é Qbox e identifica como se chama a camada QB compatível. A configuração desta resource procura `qb-core` por predefinição e usa o export `GetCoreObject`.
3. Confirma os nomes reais dos recursos `ox_lib` e `oxmysql`, a ordem de arranque e a versão/build do FXServer.
4. Obtém os nomes reais de `job.name` para polícia, sheriff e EMS e confirma como o servidor representa o serviço (`onduty`). Não tires conclusões a partir de nomes visíveis aos jogadores.
5. Procura as definições relevantes sem imprimir nem copiar para a conversa passwords, tokens, connection strings ou ficheiros `secrets`. Se precisares de confirmar a configuração da base de dados, verifica apenas que `oxmysql` está configurado e iniciado; não reveles a connection string.
6. Confirma que a cópia da resource inclui todos os ficheiros requeridos pelo `fxmanifest.lua`, especialmente `html/images`, `html/sound` e bibliotecas. Não substituas assets por downloads de origem desconhecida.

### B. Parar e pedir dados apenas quando necessário

Antes de editar, pede ao utilizador apenas os valores que não sejam determináveis no servidor:

- caminho do servidor/perfil correto, se houver mais de um candidato;
- emprego e agrupamento de cada equipa, se os nomes ou quem deve ver cada unidade não forem claros;
- emprego e grade mínima do chefe de dispatch, se o modo operador for desejado;
- recurso VOIP, apenas se o modo operador for usado;
- escolha de ativar chamadas civis por comando, que vêm desativadas por predefinição.

Não atives alertas civis, integrações de assaltos, modo operador ou eventos de outros recursos por suposição.

### C. Instalar e configurar

1. Copia a pasta completa para `resources/[standalone]/onyx_dispatch`. Evita uma pasta duplicada e preserva os assets originais incluídos na cópia licenciada.
2. Faz backup dos ficheiros de configuração antes de os alterar. Não substituas configurações locais por defaults do repositório.
3. Em `configs/config.lua`, configura explicitamente `Config.Framework = 'qbcore'`, `Config.Database = 'oxmysql'` e `Config.Notification` para um sistema presente no servidor. Define `Config.Language = 'PT'` se o servidor usar português.
4. Se a camada QB tiver outro nome/eventos, ajusta `Config.FrameworkTriggers.qbcore` e confirma que o framework fornece `GetCoreObject`, carregamento de personagem, atualização de emprego e estado de serviço.
5. Atualiza `Config.AllowedJobs`, `Config.BlipData`, `Config.Dispatcher.Perms`, `Config.Dispatcher.AlertRouting`, `Config.PoliceAlerts` e, se ativado, cada `job_table` em `Config.JobCallCommands`. Usa exclusivamente os nomes de emprego confirmados. O valor `'highest'` em `Dispatcher.Perms` dá a permissão ao grau mais alto que o Qbox define para esse emprego.
6. Mantém `Config.AutoInsertSQL = true` quando `oxmysql` e a base de dados já estiverem configurados. Faz/valida backup da base de dados antes do primeiro arranque. A resource cria `onyx_dispatch` e tenta preservar os callsigns existentes durante a migração. Nunca apagues manualmente a tabela de origem.
7. Acrescenta a linha `ensure onyx_dispatch` depois de `oxmysql`, `ox_lib`, Qbox e da camada QB compatível no `server.cfg`. Faz backup do ficheiro antes de editar e não alteres credenciais ou outras linhas sem relação com a instalação.
8. Confirma exports e eventos externos. Os nomes próprios da resource são `onyx_dispatch`; não renomeies a pasta nem reintroduzas namespaces antigos.

### D. Validar e reportar

1. Revê o diff e confirma que só foram alterados os ficheiros necessários. Confirma `git diff --check` quando o destino usar Git.
2. Confirma os nomes e a ordem das dependências sem revelar segredos.
3. Não pares nem reinicies o servidor. Se for necessário arrancar/reiniciar para concluir, deixa o comando exato e pede autorização explícita antes de o executar.
4. Entrega um relatório curto com: caminho de instalação, ficheiros alterados, valores configurados, migração de callsigns, dependências em falta e testes ainda necessários.
5. Distingue validação estática de teste em jogo. Para a verificação em jogo, confirma painel em serviço, ausência de painel fora de serviço, mapa, resposta a ocorrência, códigos de rádio e persistência do callsign.

## O que o agente não deve assumir

- `police`, `sheriff` e `ambulance` são exemplos desta cópia, não garantias sobre outro servidor.
- `Config.AllowedJobs` determina acesso e agrupamento; `job_table` define os destinatários de cada chamada.
- `Config.Dispatcher.AlertRouting` limita os empregos operacionais por categoria; `observer_jobs` são cópias silenciosas e só de leitura para monitorização.
- Os alertas automáticos incluídos não integram automaticamente os assaltos, pessoas armadas, explosões ou incêndios de outros recursos.
- Outros recursos podem criar alertas através do export server-side `exports['onyx_dispatch']:SendAlert(...)`; segue o contrato e os exemplos de validação em `INTEGRATION.md`. Não chames a exportação a partir do cliente nem cries um evento de rede aberto para a encaminhar.
- O modo operador só controla o rádio nos VOIP implementados. Um VOIP diferente requer código de integração em `client/other/dispatcher.lua`.
- A configuração atual é alvo Qbox com camada QB e `oxmysql`; suporte ESX/custom exige configuração e validação próprias.
