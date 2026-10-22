local incidentConfig = Config.IncidentAlerts or {}
local incidentSourceCooldowns = {}
local incidentTargetCooldowns = {}
local incidentLocationCooldowns = {}
local explosionSourceCooldowns = {}
local incidentSequence = 0
local eventsSincePrune = 0

local function IsPoliceServiceJob(jobName)
    for _, allowedJob in ipairs((Config.Dispatcher.AlertRouting or {}).police or {}) do
        if allowedJob == jobName then return true end
    end
    return false
end

local function IsProtectedTargetJob(jobName)
    for _, protectedJob in ipairs((Config.PoliceAlerts and Config.PoliceAlerts.whitelisted_jobs) or {}) do
        if protectedJob == jobName then return true end
    end
    return false
end

local function IsFiniteNumber(value)
    return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
end

local function MakeLocationKey(kind, coords)
    local cellSize = 60
    return ('%s:%d:%d'):format(kind, math.floor(coords.x / cellSize), math.floor(coords.y / cellSize))
end

local function CreateIncident(kind, coords, targetData)
    if type(coords) ~= 'vector3' then return false end
    if not Config.PoliceAlerts or Config.PoliceAlerts.ENABLE ~= true then return false end
    local settings = incidentConfig[kind]
    if not settings or settings.ENABLE ~= true then return false end

    local locationKey = MakeLocationKey(kind, coords)
    local now = os.time()
    if (incidentLocationCooldowns[locationKey] or 0) > now then return false end

    local title, message, sound, flash, sprite
    if kind == 'ArmedPlayers' then
        title = '10-72 - Pessoa armada'
        message = ('Jogador armado avistado perto da via pública%s.'):format(targetData and targetData.name and (' (' .. targetData.name .. ')') or '')
        sound, flash, sprite = 2, false, 156
    elseif kind == 'NearbyGunshots' then
        title = '10-13 - Disparos'
        message = ('Foram detetados disparos nas proximidades%s.'):format(targetData and targetData.name and (' (' .. targetData.name .. ')') or '')
        sound, flash, sprite = 3, true, 313
    elseif kind == 'Fires' then
        title = 'Incêndio reportado'
        message = 'Fogo detetado nas proximidades.'
        sound, flash, sprite = 3, true, 436
    elseif kind == 'Explosions' then
        title = 'Explosão reportada'
        message = 'Foi detetada uma explosão nesta localização.'
        sound, flash, sprite = 4, true, 436
    else
        return false
    end

    local id = ('incident:%s:%s:%s'):format(kind, now, incidentSequence + 1)
    local sent = SendAlert({
        category = 'police',
        jobs = Config.Dispatcher.AlertRouting.police,
        observer_jobs = {},
        coords = coords,
        title = title,
        message = message,
        unique_id = id,
        flash = flash,
        sound = sound,
        blip = {
            sprite = sprite,
            scale = 1.0,
            colour = kind == 'ArmedPlayers' and 1 or 6,
            flashes = flash,
            text = title,
            time = 5,
            radius = 0,
        },
    })

    incidentLocationCooldowns[locationKey] = now + (tonumber(settings.cooldown) or 60)
    incidentSequence = incidentSequence + 1
    return sent == true
end

RegisterNetEvent('onyx_dispatch:ReportIncident')
AddEventHandler('onyx_dispatch:ReportIncident', function(data)
    local reporterId = source
    if type(data) ~= 'table' then return end

    local reporter = self and self[reporterId]
    if not reporter or not reporter.on_duty or GetJob(reporterId) ~= reporter.job
        or not IsPoliceServiceJob(reporter.job) then return end

    local kind = data.kind
    local configKey = kind == 'armed_player' and 'ArmedPlayers'
        or kind == 'nearby_gunshot' and 'NearbyGunshots'
        or kind == 'fire' and 'Fires'
        or nil
    local settings = configKey and incidentConfig[configKey]
    if not settings or settings.ENABLE ~= true then return end

    local now = os.time()
    local sourceKey = ('%s:%s'):format(reporterId, configKey)
    if (incidentSourceCooldowns[sourceKey] or 0) > now then return end
    incidentSourceCooldowns[sourceKey] = now + 2

    local coords
    local targetData
    if kind == 'fire' then
        local input = data.coords
        if type(input) ~= 'table' or not IsFiniteNumber(input.x) or not IsFiniteNumber(input.y) or not IsFiniteNumber(input.z) then return end
        coords = vector3(input.x, input.y, input.z)
        local reporterPed = GetPlayerPed(reporterId)
        if reporterPed == 0 or #(GetEntityCoords(reporterPed) - coords) > (tonumber(settings.scan_radius) or 180) + 25 then return end
    else
        local targetId = tonumber(data.target)
        if not targetId or targetId % 1 ~= 0 or targetId == reporterId then return end
        local target = self and self[targetId]
        local targetPed = GetPlayerPed(targetId)
        if not target or not targetPed or targetPed == 0 or not DoesEntityExist(targetPed)
            or IsProtectedTargetJob(GetJob(targetId)) then return end

        local weapon = GetSelectedPedWeapon(targetPed)
        if not weapon or weapon == GetHashKey('WEAPON_UNARMED') or not IsPedArmed(targetPed, 4) then return end
        local whitelistedWeapons = (Config.PoliceAlerts.GunShots or {}).WhitelistedWeapons or {}
        if kind == 'nearby_gunshot' and whitelistedWeapons[weapon] then return end
        if kind == 'nearby_gunshot' and data.silenced == true then return end

        coords = GetEntityCoords(targetPed)
        local reporterPed = GetPlayerPed(reporterId)
        if reporterPed == 0 or #(GetEntityCoords(reporterPed) - coords) > (tonumber(settings.scan_radius) or 180) + 25 then return end

        if kind == 'armed_player' then
            local roadDistance = tonumber(data.road_distance)
            if not IsFiniteNumber(roadDistance) or roadDistance < 0
                or roadDistance > (tonumber(settings.road_distance) or 22) then return end
        end

        local targetKey = ('%s:%s'):format(configKey, targetId)
        if (incidentTargetCooldowns[targetKey] or 0) > now then return end
        incidentTargetCooldowns[targetKey] = now + (tonumber(settings.cooldown) or 60)
        targetData = { name = target.char_name }
    end

    CreateIncident(configKey, coords, targetData)

    eventsSincePrune = eventsSincePrune + 1
    if eventsSincePrune >= 100 then
        eventsSincePrune = 0
        local currentTime = os.time()
        for key, expiry in pairs(incidentSourceCooldowns) do
            if expiry <= currentTime then incidentSourceCooldowns[key] = nil end
        end
        for key, expiry in pairs(incidentTargetCooldowns) do
            if expiry <= currentTime then incidentTargetCooldowns[key] = nil end
        end
        for key, expiry in pairs(incidentLocationCooldowns) do
            if expiry <= currentTime then incidentLocationCooldowns[key] = nil end
        end
    end
end)

if (incidentConfig.Explosions or {}).ENABLE == true then
    AddEventHandler('explosionEvent', function(sender, eventData)
        local sourceId = tonumber(sender)
        local sourcePed = sourceId and GetPlayerPed(sourceId) or 0
        if not sourceId or sourceId <= 0 or sourcePed == 0 or not DoesEntityExist(sourcePed) then return end

        if type(eventData) ~= 'table' then return end
        local x, y, z = tonumber(eventData.posX), tonumber(eventData.posY), tonumber(eventData.posZ)
        if not IsFiniteNumber(x) or not IsFiniteNumber(y) or not IsFiniteNumber(z)
            or math.abs(x) > 10000 or math.abs(y) > 10000 or math.abs(z) > 10000 then return end

        local coords = vector3(x, y, z)
        local settings = incidentConfig.Explosions or {}
        if #(GetEntityCoords(sourcePed) - coords) > (tonumber(settings.max_source_distance) or 300) then return end

        local now = os.time()
        if (explosionSourceCooldowns[sourceId] or 0) > now then return end
        explosionSourceCooldowns[sourceId] = now + (tonumber(settings.source_cooldown) or 5)

        CreateIncident('Explosions', coords)
    end)
end
