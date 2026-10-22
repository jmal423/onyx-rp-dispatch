# Integrar outros recursos com o ONYX Dispatch

Usa o export server-side `SendAlert` para ligar um assalto ou outro evento confirmado ao dispatch. Os 10-13 são detetados e enviados automaticamente pelo cliente do jogador que dispara; o jogador não carrega numa tecla e não é preciso uma unidade policial perto ou a ver o disparo. Tiros silenciados e disparos em `Config.PoliceAlerts.GunShots.SuppressedZones` são ignorados. O 10-72 verifica automaticamente jogadores armados perto de vias em todos os clientes, incluindo o próprio jogador; a proximidade de um polícia não é necessária. Explosões e incêndios observados por clientes também têm deteção integrada. Os alertas são encaminhados à Polícia e Sheriff de serviço. Fogos só podem ser reportados quando um cliente os tem carregados no jogo. Continua a usar o export para assaltos e eventos especiais de outros recursos. O export não cria eventos de rede; chama-o a partir do servidor do recurso que detetou e validou a ocorrência.

## Exemplo

No código server-side do recurso de assaltos, chama o export apenas no ramo em que o assalto foi realmente iniciado:

```lua
local function SendRobberyDispatchAlert(source, locationName)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false, 'player_unavailable' end

    return exports['onyx_dispatch']:SendAlert({
        category = 'police',
        jobs = { 'police', 'sheriff' },
        observer_jobs = {},
        coords = GetEntityCoords(ped),
        title = '10-90 - Assalto em curso',
        message = ('Alarme confirmado em %s.'):format(locationName),
        flash = true,
        sound = 4,
        blip = {
            sprite = 161,
            scale = 1.0,
            colour = 1,
            time = 5,
        },
    })
end
```

Para um pedido médico, indica `category = 'medical'` e usa os destinatários configurados em `Config.Dispatcher.AlertRouting.medical`. Se a polícia precisar de acompanhar o estado sem poder responder, acrescenta os empregos de `Config.Dispatcher.AlertRouting.medical_observers` em `observer_jobs`. Os observadores recebem uma cópia silenciosa e só de leitura; as unidades EMS mantêm a resposta operacional. O servidor valida os empregos indicados contra `AlertRouting`, por isso adapta estes nomes à estrutura real do servidor.

## Payload

| Campo | Obrigatório | Descrição |
| --- | --- | --- |
| `category` | Sim | `police` ou `medical`. O servidor valida o encaminhamento contra `Config.Dispatcher.AlertRouting`. |
| `jobs` | Sim | Lista operacional, subconjunto do grupo configurado para a categoria e de `Config.AllowedJobs`. |
| `observer_jobs` | Não | Subconjunto de `AlertRouting.medical_observers`, para uma cópia silenciosa e só de leitura. Não pode repetir empregos de `jobs`. |
| `coords` | Sim | `vector3` ou `{ x = ..., y = ..., z = ... }`. |
| `title` | Sim | Título mostrado no dispatch. |
| `message` | Sim | Descrição mostrada no dispatch. |
| `unique_id` | Não | ID estável para a ocorrência; se omitido, é criado automaticamente. |
| `flash` | Não | `true` ativa o destaque urgente; por omissão `false`. |
| `sound` | Não | Índice de som entre 0 e 4; por omissão `0` (silencioso). |
| `blip` | Não | Opções `sprite`, `scale`, `colour`, `flashes`, `text`, `time` e `radius`. Valores omitidos recebem defaults seguros. |

O dispatch só envia para jogadores que estejam de serviço e cujo emprego esteja em `jobs` ou `observer_jobs`. Se não houver destinatários operacionais de serviço em `jobs`, a chamada não é criada. Os observadores não podem responder, mas recebem as atualizações de quem está a caminho.

## Retorno

```lua
local sent, result, observerCount = exports['onyx_dispatch']:SendAlert(payload)
if sent then
    print(('Alerta enviado a %d unidades operacionais e %d observadores.'):format(result, observerCount))
else
    print(('Alerta não enviado: %s'):format(result))
end
```

Em sucesso, `result` é o número de unidades operacionais e o terceiro retorno é o número de observadores notificados. Em falha, o segundo valor identifica a causa: `invalid_payload`, `invalid_category`, `invalid_routing`, `invalid_coords`, `invalid_text`, `unknown_job`, `no_jobs`, `no_recipients` ou `duplicate_id`.

## Regras de integração

- Usa o export só em ficheiros server-side e depois de o recurso de origem confirmar o início da ocorrência.
- Não ligues o export a um evento client-side sem validação; isso permite alertas falsos e spam.
- Recursos de assalto devem chamar o export no ponto server-side em que o alarme/assalto fica confirmado, não ao iniciar uma animação, lockpick ou tentativa.
- Não uses `TriggerServerEvent` para tentar chamar esta exportação. O nome do recurso e a API pública são `onyx_dispatch`.
- Para prevenir duplicados, mantém um `unique_id` por ocorrência e só chama o export uma vez por início confirmado.
- A exportação não deteta crimes por si só e não altera o recurso que iniciou o assalto, incêndio ou explosão.
