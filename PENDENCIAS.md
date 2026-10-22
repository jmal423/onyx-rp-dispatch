# Pendências do ONYX Dispatch

Atualizar este ficheiro quando uma pendência for investigada, alterada, confirmada ou resolvida.

## Acesso ao dispatch por força

- **Estado:** regras de encaminhamento e permissões de chefia implementadas em 2026-10-22; falta validação no FiveM.
- **EMS (`ambulance`):** vê apenas as unidades EMS na lista e recebe apenas pedidos de ajuda médica. Não recebe assaltos, tiros/10-13 nem alertas de pessoas armadas.
- **Polícia (`police`) e Sheriff (`sheriff`):** cada força vê a lista de unidades das três forças — LSPD, Sheriff e EMS — e recebe os alertas policiais e médicos relevantes.
- **Chamadas médicas/revive:** são encaminhadas apenas para EMS. Polícia e Sheriff não recebem chamadas de revive; ver unidades EMS no mapa/lista não lhes dá acesso aos alertas médicos.
- **Filtros da lista de unidades:** botões por força (LSPD, Sheriff e EMS) ocultam/mostram unidades apenas na lista lateral. Os blips no mapa não são afetados e continuam visíveis.
- **Chefias:** `Config.Dispatcher.Perms` usa `'highest'` para police, sheriff e ambulance. O grau máximo é lido das definições reais do framework e validado no servidor. Cada emprego tem o seu próprio estado/contador de operador; sair de serviço desativa o modo.
- **Segurança do modo operador:** o servidor ignora o emprego enviado pelo cliente e confirma o emprego atual, estado de serviço e grau antes de aceitar a ativação.
- **Teste pendente:** confirmar no servidor que apenas o grau máximo de cada emprego pode ativar o modo operador, que os estados são independentes por força e que a permissão acompanha alterações de emprego e serviço. O servidor de teste usa o job `sheriff`; confirmar `bcso` ao preparar o servidor principal.

### Atalhos de rádio

- **Estado:** implementados no código em 2026-10-22; falta validação no FiveM.
- `Alt+1`: 10-20 — comunicar localização da unidade.
- `Alt+2`: 10-32 — pedir apoio à própria força. Este código consta da lista LSPD fornecida pelo utilizador como “Pedir apoio (1, 2, 3)”.
- `Alt+3`: 10-99 urgente — pedir apoio à própria força. 10-99 não consta da lista LSPD fornecida; é um código já adotado como código próprio do dispatch.
- `Alt+4`: 10-99 urgente — pedir apoio conjunto LSPD e Sheriff.
- `Alt+5`: **Pedido de assistência médica — Polícia**; disponível para a polícia e encaminhado apenas para EMS, sem enviar chamados policiais para EMS. Não lhe atribuir um código numérico da lista LSPD.
- Os dois atalhos 10-99 são urgentes. As binds continuam configuráveis em `Config.RadioCodes` e nas definições de teclas do FiveM.
- Cooldown dos códigos reduzido de 10 para 3 segundos por grupo; 10-20, pedido médico e restantes códigos de apoio têm temporizadores independentes.
- A lista original define 10-14 como “Transporte de ferido ao hospital”; não corresponde a pedir EMS e não deve ser reutilizado para `Alt+5`. O título de `Alt+5` ficou definido como “Pedido de assistência médica — Polícia”.
- O servidor valida emprego e serviço e define os destinatários: códigos de força para a própria força; Alt+4 apenas para LSPD/Sheriff; Alt+5 apenas para polícia, enviado apenas a EMS.
- Se não houver EMS de serviço, o chamado não é criado nem aparece no dispatch; quem o enviou recebe o aviso de falta de EMS. Havendo EMS, o pedido aparece silenciosamente no dispatch de Polícia e Sheriff de serviço, apenas para consulta; só EMS recebe o alerta operacional e pode responder.
- Polícia, Sheriff e EMS de serviço veem o estado, callsign/nome e distância das unidades EMS que respondem. A lista atualiza quando EMS entra ou sai da resposta. Mantêm-se as notificações à pessoa que enviou o pedido.
- **Teste manual:** sem EMS de serviço, confirmar que Alt+5 não cria alerta e avisa quem o enviou. Com EMS de serviço, confirmar que Polícia e Sheriff veem o pedido silencioso, não o conseguem responder no painel pequeno nem no menu do mapa grande, e veem a lista/distância de EMS atualizada em resposta. Confirmar que EMS recebe o alerta acionável, que a polícia emissora recebe confirmação, bloqueio fora de serviço, bloqueio de Alt+4 para EMS e cooldown.

### Filtros da lista lateral — implementação inicial

- **Estado:** implementado em 2026-10-22; falta teste no FiveM.
- LSPD/Sheriff podem alternar a visibilidade de cada força na lista lateral. A escolha fica guardada no armazenamento local da NUI.
- EMS vê só unidades EMS na lista e não recebe botões para revelar unidades policiais.
- Os filtros são aplicados apenas às linhas da lista; não alteram os dados usados para desenhar os blips do mapa.
- Foi acrescentado o job de cada unidade aos dados da interface para permitir a filtragem sem alterar a lógica de blips.
- **Teste manual:** em serviço, abrir o mapa grande com um jogador LSPD, Sheriff e EMS online. Alternar cada botão e confirmar que só a lista lateral muda; fechar/abrir a NUI e confirmar que a preferência se mantém. Entrar como EMS e confirmar que só aparece a unidade EMS na lista, enquanto os blips continuam no mapa.

## Lista de ocorrências — organização visual

- **Estado:** primeira reorganização de texto aplicada; falta validação no FiveM.
- Títulos e horas passaram a ocupar colunas próprias, impedindo que o título empurre a hora ou que a hora se sobreponha ao texto. A mensagem ganhou espaçamento e entrelinha próprios.
- As cores e os efeitos atuais foram mantidos para serem avaliados depois, com a hierarquia de texto já corrigida.
- **Próximo passo:** comparar a lista no viewport da captura e em 720p/4K; depois recolher feedback e rever cores/realce.

## Redimensionamento da NUI e small invisível

- **Estado:** alterações implementadas; o utilizador confirmou que a barra superior ficou proporcional em 800×600. Falta retestar no jogo a posição do toast ao abrir/fechar ESC e inventário, e a escala das definições em 720p.
- Ao mudar a resolução, a NUI espera 250 ms para estabilizar, volta a ajustar o mapa à janela e pede ao cliente Lua para reapresentar o small se o mapa grande estiver fechado e o jogador continuar autorizado/de serviço. A posição do small é guardada como proporção da área útil, para manter a colocação relativa entre resoluções e reinícios da NUI.
- A posição só é guardada após arrastar o painel; abrir/fechar menus e alterações automáticas de estilo já não reescrevem a posição guardada. A aplicação da posição também substitui explicitamente a transformação CSS de centragem.
- Corrigida a transformação CSS do `#toastContainer`, que estava a ser sobrescrita e podia deslocar o small verticalmente.
- **Ajuste 720p:** reduzido o mínimo da escala global de 14 px para 12 px, a largura mínima do toast e a largura máxima das definições. Em ecrãs baixos, as margens e espaçamentos das definições também diminuem para evitar um modal desproporcional.
- **Barra superior em resoluções pequenas:** a largura agora considera o espaço ocupado pelos painéis laterais, para não se sobrepor aos cabeçalhos. Em 800 px de largura, passa de cerca de 528 px para cerca de 356 px.
- **Menus:** o small é temporariamente ocultado enquanto o Pause Menu ou inventário está aberto e reaparece ao fechar. A deteção usa `IsPauseMenuActive()` e os state bags `invOpen`, `invBusy` e `inv_busy`.
- **Validação confirmada:** barra de controlos do mapa sem sobrepor os cabeçalhos laterais em 800×600.
- **Validação pendente:** alterar entre 720p e 4K; abrir/fechar ESC e ox_inventory em 800×600 e confirmar que o toast regressa à mesma posição; confirmar que a NUI continua correta com o mapa grande aberto.

### Tamanho dos ícones no mapa do dispatch em resoluções pequenas

- **Estado:** por ajustar.
- **Problema:** os ícones/blips desenhados no mapa do dispatch ficam demasiado grandes em resoluções pequenas.
- **Âmbito:** ajustar apenas os marcadores do mapa NUI do dispatch, com escala responsiva. Não alterar os blips do mapa/minimapa do GTA.
- **Validação:** comparar 800×600, 720p e 4K; garantir que os ícones ficam legíveis sem tapar o mapa nem mudar de tamanho de forma excessiva entre resoluções.

## Nome da resource e exports

- **Estado:** renomeação concluída em 2026-10-22. A resource, os exports, os eventos, as chaves de locale e a tabela de callsigns usam `onyx_dispatch`.
- Os dois consumidores internos usam `exports['onyx_dispatch']`. A pesquisa não encontrou outros recursos Qbox a chamar o namespace antigo.
- No arranque, a tabela anterior de callsigns é renomeada ou combinada com `onyx_dispatch`; a tabela de origem só é removida após confirmar que todos os identificadores estão presentes na tabela nova.
- Integrações externas fora deste repositório que chamem os eventos antigos precisam de ser atualizadas para o namespace novo.

## Small não reaparece após reiniciar a resource

- **Estado:** por resolver; investigação pausada por prioridade do utilizador.
- **Comportamento:** depois de `restart onyx_dispatch`, o painel small não aparece automaticamente. Abrir e fechar o mapa grande faz com que apareça. O utilizador confirmou que continua a acontecer.
- **Evidência disponível:** o log mostra `Loaded Successfully!` da NUI, mas não confirma a sincronização do jogador nem a decisão de visibilidade.
- **Tentativas:** commits `4bac49e`, `75a61d2`, `c7b3803` e `6770fb1` alteraram o fluxo de restart/sincronização; não resolveram o problema e foram revertidos.
- **Estado do código:** rollback aplicado; manter o comportamento anterior a essas quatro tentativas até retomar a investigação.
- **Próxima investigação:** recolher logs temporários em cada etapa: autorização NUI, pedido `PlayerLoaded`, emprego/duty no servidor, `DutyState`, `SendSourceData`, resultado de `IsAllowed()` e mensagem `show_small`. Corrigir a etapa comprovadamente interrompida e testar no servidor após restart da resource.
- **Ideia para investigar:** a notificação de arranque “O recurso ainda está a carregar. Tente novamente dentro de alguns segundos” pode indicar uma janela em que o small tenta abrir antes de a resource/NUI ou os dados do jogador estarem prontos. Na próxima investigação, identificar quem dispara essa notificação e comparar o seu momento com `PlayerLoaded`, estado de serviço e `show_small`; só depois decidir se é preciso sincronizar ou repetir a apresentação do small.
- **Atualização (2026-10-22):** continua por resolver e não foi alterado nesta atualização dos códigos de rádio.

## Alertas de ocorrências ingame: assaltos, pessoa armada, explosões e incêndios

- **Estado:** export genérico server-side disponível para integração por outros recursos; os adaptadores específicos continuam por implementar.
- **Pedido:** adicionar alertas ingame para 10-90 (assalto), 10-72 (pessoa armada), explosões, incêndios e ocorrências semelhantes.
- **Já existe no Onyx Dispatch:** 10-13 automático para disparos não silenciados, com whitelist global de armas/empregos e cooldown; 10-20 e pedidos 10-99 são códigos de rádio separados, não detetores de crimes.
- **Assaltos Qbox:** `qbx_storerobbery`, `qbx_bankrobbery`, `qbx_jewelery`, `qbx_houserobbery` e `qbx_truckrobbery` têm pontos de servidor que validam o início/alarme do assalto. Os alertas encontrados são enviados para `police:server:policeAlert` ou para a interface policial Qbox; o Onyx Dispatch não os consome atualmente. Ligar aos eventos depois da validação, evitando eventos de tentativa inválida, duplicados e chamadas repetidas do mesmo alarme.
- **10-72:** não criar alerta só porque alguém tem uma arma equipada; isso produziria falsos positivos. Falta fechar um critério de ocorrência, por exemplo apontar uma arma a outra pessoa em público, e validar a deteção no servidor antes de distribuir o alerta.
- **Explosões:** não há detetor no Onyx Dispatch. A implementação deve usar eventos de explosão do servidor com tipos permitidos, cooldown e agregação de explosões próximas para evitar spam e ruído de explosões secundárias.
- **Incêndios:** não há detetor global no Onyx Dispatch. Ligar aos recursos que iniciam incêndios; evitar polling global no cliente, que pode gerar alertas imprecisos. O Qbox Bank Robbery inicia fogo de thermite no cliente, pelo que esse fluxo pode ser integrado na origem.
- **Destinatários:** aplicar a regra em “Acesso ao dispatch por força”: LSPD/Sheriff recebem alertas policiais; EMS não recebe assaltos, tiros ou pessoas armadas. Chamadas médicas/revive vão apenas para EMS.
- **Workflow disponível:** `exports['onyx_dispatch']:SendAlert({...})`; só envia a empregos configurados e a unidades de serviço. Ver `INTEGRATION.md` para payload, retornos e exemplos.
- **Observadores:** `observer_jobs` envia cópias silenciosas e só de leitura, com atualizações de unidades em resposta. Pode ser usado para a polícia acompanhar pedidos médicos sem lhes dar a ação de responder.
- **Política configurável:** `Config.Dispatcher.AlertRouting` define destinos de `police`, `medical` e `medical_observers`; a exportação rejeita empregos fora dessas listas e de `Config.AllowedJobs`.
- **Próximo passo:** definir critério de 10-72 e destinatários por tipo de ocorrência; depois adicionar chamadas ao export nos pontos server-side de sucesso dos recursos de assalto, explosão e incêndio, sem alterar os fluxos de pagamento ou validação Qbox.
- **Validação:** esta entrada documenta apenas inspeção estática do código. Nenhuma ocorrência nova foi implementada ou testada em jogo.
