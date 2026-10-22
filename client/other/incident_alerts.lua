local incidentScan = Config.IncidentAlerts or {}

local function IsInGunshotWhitelistedZone(coords)
    local zones = Config.PoliceAlerts and Config.PoliceAlerts.GunShots
        and Config.PoliceAlerts.GunShots.WhitelistedZones or {}

    for _, zone in pairs(zones) do
        if zone.coords and #(coords - zone.coords) <= (tonumber(zone.distance) or 0) then
            return true
        end
    end

    return false
end

local function GetRoadDistance(coords)
    local found, nodeCoords = GetClosestVehicleNodeWithHeading(
        coords.x, coords.y, coords.z, 0, 3.0, 0
    )

    if found ~= true or not nodeCoords then return nil end
    return #(coords - nodeCoords)
end

CreateThread(function()
    while true do
        local settings = incidentScan.ArmedPlayers or {}
        if settings.ENABLE and Authorised and on_duty
            and Config.PoliceAlerts and Config.PoliceAlerts.ENABLE then
            local myCoords = GetEntityCoords(PlayerPedId())
            local scanRadius = tonumber(settings.scan_radius) or 120
            local roadDistance = tonumber(settings.road_distance) or 22

            for _, playerId in ipairs(GetActivePlayers()) do
                if playerId ~= PlayerId() then
                    local targetPed = GetPlayerPed(playerId)
                    if targetPed ~= 0 and DoesEntityExist(targetPed)
                        and not IsPedDeadOrDying(targetPed, true)
                        and IsPedArmed(targetPed, 4) then
                        local targetCoords = GetEntityCoords(targetPed)
                        if #(myCoords - targetCoords) <= scanRadius then
                            local distanceToRoad = GetRoadDistance(targetCoords)
                            if distanceToRoad and distanceToRoad <= roadDistance then
                                TriggerServerEvent('onyx_dispatch:ReportIncident', {
                                    kind = 'armed_player',
                                    target = GetPlayerServerId(playerId),
                                    road_distance = distanceToRoad,
                                })
                            end
                        end
                    end
                end
            end
            Wait(tonumber(settings.scan_interval) or 2000)
        else
            Wait(2000)
        end
    end
end)

local lastGunshotReports = {}
AddEventHandler('CEventGunShot', function(entities, eventEntity)
    local settings = incidentScan.NearbyGunshots or {}
    if not settings.ENABLE or not Authorised or not on_duty
        or not Config.PoliceAlerts or not Config.PoliceAlerts.ENABLE
        or not Config.PoliceAlerts.GunShots or not Config.PoliceAlerts.GunShots.ENABLE then return end

    local shooterPed = eventEntity
    if (not shooterPed or shooterPed == 0 or not DoesEntityExist(shooterPed)) and type(entities) == 'table' then
        shooterPed = entities[1]
    end
    if not shooterPed or shooterPed == 0 or not DoesEntityExist(shooterPed) or not IsPedAPlayer(shooterPed) then return end

    local playerId = NetworkGetPlayerIndexFromPed(shooterPed)
    if playerId == -1 or playerId == PlayerId() or not NetworkIsPlayerActive(playerId)
        or IsPedDeadOrDying(shooterPed, true) or IsPedCurrentWeaponSilenced(shooterPed) then return end

    local targetCoords = GetEntityCoords(shooterPed)
    if #(GetEntityCoords(PlayerPedId()) - targetCoords) > (tonumber(settings.scan_radius) or 180)
        or IsInGunshotWhitelistedZone(targetCoords) then return end

    local hasWeapon, weaponHash = GetCurrentPedWeapon(shooterPed)
    if not hasWeapon or (Config.PoliceAlerts.GunShots.WhitelistedWeapons or {})[weaponHash] then return end

    local targetId = GetPlayerServerId(playerId)
    local now = GetGameTimer()
    if not targetId or targetId <= 0 or (lastGunshotReports[targetId] or 0) > now then return end

    lastGunshotReports[targetId] = now + (tonumber(settings.cooldown) or 20) * 1000
    TriggerServerEvent('onyx_dispatch:ReportIncident', {
        kind = 'nearby_gunshot',
        target = targetId,
    })
end)

CreateThread(function()
    while true do
        local settings = incidentScan.Fires or {}
        if settings.ENABLE and Authorised and on_duty
            and Config.PoliceAlerts and Config.PoliceAlerts.ENABLE then
            local coords = GetEntityCoords(PlayerPedId())
            local radius = tonumber(settings.scan_radius) or 180
            local found, fireCoords = GetClosestFirePos(coords.x, coords.y, coords.z)

            if found and fireCoords and #(coords - fireCoords) <= radius then
                TriggerServerEvent('onyx_dispatch:ReportIncident', {
                    kind = 'fire',
                    coords = { x = fireCoords.x, y = fireCoords.y, z = fireCoords.z },
                })
            end
            Wait(tonumber(settings.scan_interval) or 5000)
        else
            Wait(3000)
        end
    end
end)
