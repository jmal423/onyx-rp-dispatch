local incidentScan = Config.IncidentAlerts or {}

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

CreateThread(function()
    while true do
        local settings = incidentScan.Fires or {}
        if settings.ENABLE and Config.PoliceAlerts and Config.PoliceAlerts.ENABLE then
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
