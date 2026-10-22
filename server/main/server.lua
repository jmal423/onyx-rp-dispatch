local resourceName = GetCurrentResourceName()
local divider = "^8=========================================^0"
local supportText = [[
^2NEED SUPPORT?^0
^0Discord: ^3https://discord.gg/codesign.
^0Documentation: ^3https://docs.codesign.pro.
]] .. divider

local startupSuccess = nil

if not Config then
    print(divider .. "\n\n^8[" .. resourceName .. "]^1 [unable_to_start]\n^0Config.lua Syntax Error\n\n" .. supportText)
    startupSuccess = false
end

if not Locales[Config.Language] then
    print(divider .. "\n\n^8[" .. resourceName .. "]^1 [unable_to_start]\n^0Config.Language/locales.lua Typo : [" .. Config.Language .. "]\n\n" .. supportText)
    startupSuccess = false
end

if Config.Database ~= "mysql" and Config.Database ~= "ghmattimysql" and Config.Database ~= "oxmysql" then
    print(divider .. "\n\n^8[" .. resourceName .. "]^1 [unable_to_start]\n^0Config.Database Typo : [" .. Config.Database .. "]\n\n" .. supportText)
    startupSuccess = false
end

if Config.Framework ~= "esx" and Config.Framework ~= "qbcore" and Config.Framework ~= "other" then
    print(divider .. "\n\n^8[" .. resourceName .. "]^1 [unable_to_start]\n^0Config.Framework Typo : [" .. Config.Framework .. "]\n\n" .. supportText)
    startupSuccess = false
end

if startupSuccess == nil then
    startupSuccess = true
end

CreateThread(function()
    local attempts = 0
    while startupSuccess == nil and attempts <= 100 do
        Wait(1000)
        attempts = attempts + 1
    end
    
    if startupSuccess == true then
        Authorised = true
        
        RegisterServerEvent("cd_dispatch:SpeedtrapLocations")
        AddEventHandler("cd_dispatch:SpeedtrapLocations", function()
            TriggerClientEvent("cd_dispatch:PoliceiconColour", source, 21654)
        end)
        
        if Config.AutoInsertSQL then
            InsertSQL()
        end
        
        Wait(2000)
        TriggerClientEvent("cd_dispatch:ScriptRestarted", -1)
    end
end)

self = {}
DispatcherData = {
    active = false,
    count = 0
}

function FormatPlayersForLargeUI(playersList)
    local formattedData = {}
    
    for i = 1, #playersList do
        local player = playersList[i]
        
        if Config.UsingOneSync then
            local coords = GetEntityCoords(GetPlayerPed(player.source))
            self[player.source].coords = {x = coords.x, y = coords.y}
        end
        
        local blipColor = "blue"
        if Config.BlipData[self[player.source].job] and 
           Config.BlipData[self[player.source].job].largeui_blip_colour then
            blipColor = Config.BlipData[self[player.source].job].largeui_blip_colour
        end
        
        formattedData[#formattedData + 1] = {
            id = self[player.source].source,
            job = self[player.source].job,
            name = self[player.source].char_name,
            callsign = self[player.source].callsign,
            channel = self[player.source].radio_channel,
            vehicle = self[player.source].vehicle,
            group = self[player.source].group,
            blipcolour = blipColor,
            coords = self[player.source].coords,
            status = self[player.source].status
        }
    end
    
    return formattedData
end
function RefreshLargeUI(jobName)
    if not Config.Dispatcher.ENABLE or not DispatcherData.active then
        return
    end
    
    local eligiblePlayers = {}
    local allowedJobs = CheckMultiJobs(jobName)
    
    for playerId, playerData in pairs(self) do
        for _, allowedJob in pairs(allowedJobs) do
            if playerData.job == allowedJob and playerData.on_duty then
                eligiblePlayers[#eligiblePlayers + 1] = playerData
                break
            end
        end
    end
    
    local formattedData = FormatPlayersForLargeUI(eligiblePlayers)
    
    for i = 1, #eligiblePlayers do
        TriggerClientEvent("cd_dispatch:RefreshLargeUI", eligiblePlayers[i].source, jobName, formattedData)
    end
end

RegisterServerEvent("cd_dispatch:LargeUIData")
AddEventHandler("cd_dispatch:LargeUIData", function(jobName, callbackId)
    if not ValidateType(jobName, "string") then
        ShowError("3334")
        return
    end
    
    local playerData = {}
    local eligiblePlayers = {}
    local allowedJobs = CheckMultiJobs(jobName)
    
    for playerId, data in pairs(self) do
        for _, allowedJob in pairs(allowedJobs) do
            if data.job == allowedJob and data.on_duty then
                eligiblePlayers[#eligiblePlayers + 1] = data
                break
            end
        end
    end
    
    if Config.UsingOneSync then
        playerData = FormatPlayersForLargeUI(eligiblePlayers)
    else
        for i = 1, #eligiblePlayers do
            TriggerClientEvent("cd_dispatch:GetNonOnesyncCoords", eligiblePlayers[i].source)
        end
        Wait(1000)
        playerData = FormatPlayersForLargeUI(eligiblePlayers)
    end
    
    for i = 1, #eligiblePlayers do
        TriggerClientEvent("cd_dispatch:Callback", eligiblePlayers[i].source, playerData, callbackId)
    end
end)

function GetPlayersCoordinates(playersList)
    local coordinates = {}
    
    for i = 1, #playersList do
        local player = playersList[i]
        if player and GetPlayerName(player.source) then
            if Config.UsingOneSync then
                local coords = GetEntityCoords(GetPlayerPed(player.source))
                coordinates[#coordinates + 1] = {
                    char_name = self[player.source].char_name,
                    x = coords.x,
                    y = coords.y
                }
            else
                coordinates[#coordinates + 1] = {
                    char_name = self[player.source].char_name,
                    x = self[player.source].coords.x,
                    y = self[player.source].coords.y
                }
            end
        end
    end
    
    return coordinates
end

RegisterServerEvent("cd_dispatch:GetCoords")
AddEventHandler("cd_dispatch:GetCoords", function(jobName, callbackId)
    if not ValidateType(jobName, "string") then
        ShowError("4777")
        return
    end
    
    local eligiblePlayers = {}
    local allowedJobs = CheckMultiJobs(jobName)
    
    for playerId, playerData in pairs(self) do
        for _, allowedJob in pairs(allowedJobs) do
            if playerData.job == allowedJob and playerData.on_duty then
                eligiblePlayers[#eligiblePlayers + 1] = playerData
                break
            end
        end
    end
    
    if not Config.UsingOneSync then
        for i = 1, #eligiblePlayers do
            TriggerClientEvent("cd_dispatch:GetNonOnesyncCoords", eligiblePlayers[i].source)
        end
        Wait(1000)
    end
    
    for i = 1, #eligiblePlayers do
        TriggerClientEvent("cd_dispatch:Callback", eligiblePlayers[i].source, 
                          GetPlayersCoordinates(eligiblePlayers), callbackId)
    end
end)

RegisterServerEvent("cd_dispatch:GetNonOnesyncCoords")
AddEventHandler("cd_dispatch:GetNonOnesyncCoords", function(coords)
    local playerId = source
    if ValidateType(coords, "vector3") then
        if self[playerId] then
            self[playerId].coords = {x = coords.x, y = coords.y}
        else
            ShowError("6844")
        end
    end
end)

local pauseMenuBlips = {}
local blipsToRemove = {}

RegisterServerEvent("cd_dispatch:PlayerBlips:emergancylights")
AddEventHandler("cd_dispatch:PlayerBlips:emergancylights", function(flashingEnabled)
    local playerId = source
    if ValidateType(flashingEnabled, "boolean") then
        pauseMenuBlips[playerId].flashing_blip = flashingEnabled
        PlayerBlipsActions(playerId, "update")
    else
        ShowError("7784")
    end
end)

CreateThread(function()
    if not Config.PauseMenuBlips.ENABLE then return end
    
    while true do
        Wait(Config.PauseMenuBlips.data_update_timer * 1000)
        
        if pauseMenuBlips then
            if Config.UsingOneSync then
                for _, blipData in pairs(pauseMenuBlips) do
                    local playerPed = GetPlayerPed(blipData.source)
                    pauseMenuBlips[blipData.source].coords = GetEntityCoords(playerPed)
                end
            end
            
            for _, blipData in pairs(pauseMenuBlips) do
                TriggerClientEvent("cd_dispatch:PlayerBlips_update", 
                                 blipData.source, blipData.source, 
                                 pauseMenuBlips, blipsToRemove)
                blipsToRemove = {}
            end
        end
    end
end)

function PlayerBlipsActions(playerId, action)
    if not Config.PauseMenuBlips.ENABLE then return end
    
    if not ValidateType(playerId, "number") or not ValidateType(action, "string") then
        ShowError("6656")
        return
    end
    
    if not self or not self[playerId] then
        ShowError("4855")
        return
    end
    
    if action == "update" then
        local allowedJobs = CheckMultiJobs(self[playerId].job)
        
        if allowedJobs and self[playerId].on_duty then
            if not pauseMenuBlips[playerId] then
                pauseMenuBlips[playerId] = {}
            end
            
            pauseMenuBlips[playerId].blip_colour = {0, 0}
            
            if Config.BlipData and Config.BlipData[self[playerId].job] and 
               Config.BlipData[self[playerId].job].pausemenu_blip_colour then
                pauseMenuBlips[playerId].blip_colour = Config.BlipData[self[playerId].job].pausemenu_blip_colour
            end
            
            if Config.PauseMenuBlips.blip_type == "dynamic" or Config.PauseMenuBlips.blip_type == "auto" then
                if self[playerId].vehicle then
                    pauseMenuBlips[playerId].blip_sprite = Config.PauseMenuBlips.blip_sprites[self[playerId].vehicle]
                else
                    pauseMenuBlips[playerId].blip_sprite = Config.PauseMenuBlips.blip_sprites.static
                end
            else
                pauseMenuBlips[playerId].blip_sprite = Config.PauseMenuBlips.blip_sprites.static
            end
            
            if Config.PauseMenuBlips.radiochannel_on_blips then
                pauseMenuBlips[playerId].radio_channel = self[playerId].radio_channel or 0
            end
            
            local callsign = self[playerId].callsign
            if type(callsign) == 'string' then
                callsign = callsign:match('^%s*(.-)%s*$')
                if callsign:sub(1, 1) == '[' and callsign:sub(-1) == ']' then
                    callsign = callsign:sub(2, -2)
                end
            end
            if callsign and callsign ~= '' and callsign ~= L('unknown') then
                pauseMenuBlips[playerId].name = L("playerblip", callsign, self[playerId].char_name)
            else
                pauseMenuBlips[playerId].name = self[playerId].char_name or L('unknown')
            end
            pauseMenuBlips[playerId].job = self[playerId].job
            pauseMenuBlips[playerId].job_table = allowedJobs
            pauseMenuBlips[playerId].source = playerId
        else
            if not pauseMenuBlips[playerId] then return end
            pauseMenuBlips[playerId] = nil
            table.insert(blipsToRemove, playerId)
            TriggerClientEvent("cd_dispatch:PlayerBlips_disable", playerId)
        end
    elseif action == "remove" then
        if not pauseMenuBlips[playerId] then return end
        pauseMenuBlips[playerId] = nil
        table.insert(blipsToRemove, playerId)
        TriggerClientEvent("cd_dispatch:PlayerBlips_disable", playerId)
    end
end

local trackedDispatchCalls = {}
local trackedCallLifetime = 3600

local function TrackDispatchCall(uniqueId, coords, jobs)
    if type(uniqueId) ~= 'string' or uniqueId == '' or type(coords) ~= 'vector3' or type(jobs) ~= 'table' then return end

    local allowedJobs = {}
    for _, job in ipairs(jobs) do
        if type(job) == 'string' then allowedJobs[job] = true end
    end
    if not next(allowedJobs) then return end

    trackedDispatchCalls[uniqueId] = {
        coords = coords,
        jobs = allowedJobs,
        responders = {},
        expires = os.time() + trackedCallLifetime,
    }
end

local function IsTrackedCallRecipient(playerData, call)
    return playerData and playerData.on_duty and call.jobs[playerData.job] == true
end

local function SendRespondersSnapshot(uniqueId, call)
    local responders = {}
    for playerId in pairs(call.responders) do
        local unit = self and self[playerId]
        local ped = GetPlayerPed(playerId)
        if unit and ped and ped ~= 0 and DoesEntityExist(ped) then
            local distance = #(call.coords - GetEntityCoords(ped))
            responders[#responders + 1] = {
                source = playerId,
                callsign = unit.callsign or '',
                name = unit.char_name or L('unknown'),
                distance = math.floor(distance + 0.5),
            }
        else
            call.responders[playerId] = nil
        end
    end
    table.sort(responders, function(first, second)
        if first.distance == second.distance then
            return first.callsign < second.callsign
        end
        return first.distance < second.distance
    end)

    for playerId, playerData in pairs(self or {}) do
        if IsTrackedCallRecipient(playerData, call) then
            TriggerClientEvent('cd_dispatch:RespondersSnapshot', playerId, uniqueId, responders)
        end
    end
end

RegisterServerEvent("cd_dispatch:PlayerResponding")
AddEventHandler("cd_dispatch:PlayerResponding", function(responseData)
    local playerId = source
    if type(responseData) ~= 'table' or type(responseData.unique_id) ~= 'string' then return end

    local call = trackedDispatchCalls[responseData.unique_id]
    local unit = self and self[playerId]
    if not call or call.expires <= os.time() or not unit then return end

    local action = responseData.action
    if action ~= 'add' and action ~= 'remove' then return end
    if action == 'add' then
        if not IsTrackedCallRecipient(unit, call) or call.responders[playerId] then return end
        call.responders[playerId] = true
    else
        if not call.responders[playerId] then return end
        call.responders[playerId] = nil
    end

    local responderCount = 0
    for _ in pairs(call.responders) do responderCount = responderCount + 1 end
    local authoritativeResponse = {
        unique_id = responseData.unique_id,
        action = action,
        responding = action == 'add' and responderCount - 1 or responderCount + 1,
        char_info = {
            source = playerId,
            callsign = unit.callsign or '',
            char_name = unit.char_name or L('unknown'),
        },
    }

    for targetId, targetData in pairs(self or {}) do
        if IsTrackedCallRecipient(targetData, call) then
            TriggerClientEvent('cd_dispatch:PlayerResponding', targetId, authoritativeResponse)
        end
    end
    SendRespondersSnapshot(responseData.unique_id, call)
end)

CreateThread(function()
    while true do
        local interval = Config.UpdateDistanceUI and Config.UpdateDistanceUI.timer or 3
        Wait(math.max(1, tonumber(interval) or 3) * 1000)
        local now = os.time()
        for uniqueId, call in pairs(trackedDispatchCalls) do
            if call.expires <= now then
                trackedDispatchCalls[uniqueId] = nil
            elseif next(call.responders) then
                SendRespondersSnapshot(uniqueId, call)
            end
        end
    end
end)

RegisterServerEvent("cd_dispatch:SaveUserSettings")
AddEventHandler("cd_dispatch:SaveUserSettings", function(settings)
    local playerId = source
    local statusChanged = false
    
    if not self or not self[playerId] then
        ShowError("1454")
        return
    end
    
    if settings.status and settings.status.name ~= self[playerId].status.name then
        self[playerId].status = settings.status
        statusChanged = true
    end
    
    if type(settings.callsign) == 'string' then
        local callsign = settings.callsign:match('^%s*(.-)%s*$')
        if callsign ~= '' and #callsign < 16 and not callsign:find('[%c]') and callsign ~= self[playerId].callsign then
            self[playerId].callsign = callsign
            Checks("set_callsign", playerId, callsign)
            PlayerBlipsActions(playerId, "update")
        end
    end
    
    local allowedJobs = CheckMultiJobs(self[playerId].job)
    if ValidateType(allowedJobs, "table") then
        for _, playerData in pairs(self) do
            for _, allowedJob in pairs(allowedJobs) do
                if playerData.job == allowedJob and playerData.on_duty then
                    TriggerClientEvent("cd_dispatch:SyncUserSettings", playerData.source, {
                        source = playerId,
                        status = self[playerId].status,
                        callsign = self[playerId].callsign,
                        vehicle = self[playerId].vehicle
                    })
                    
                    if statusChanged and Config.NotifyStatusChange then
                        SendNotification(playerData.source, 2, "notify_status_change",
                                       self[playerId].callsign, self[playerId].char_name,
                                       settings.status.name)
                    end
                    break
                end
            end
        end
    else
        ShowError("7841")
    end
end)

local automaticVehicleTypes = {
    foot = true,
    car = true,
    motorcycle = true,
    helicopter = true,
    boat = true,
}

RegisterServerEvent('onyx_dispatch:SetAutomaticVehicle')
AddEventHandler('onyx_dispatch:SetAutomaticVehicle', function(vehicleType)
    local playerId = source
    local playerData = self and self[playerId]

    if not playerData or not playerData.on_duty then return end
    if Config.PauseMenuBlips.blip_type ~= 'auto' or not automaticVehicleTypes[vehicleType] then return end
    if playerData.vehicle == vehicleType then return end

    playerData.vehicle = vehicleType
    PlayerBlipsActions(playerId, 'update')

    local allowedJobs = CheckMultiJobs(playerData.job)
    if type(allowedJobs) == 'table' then
        for targetId, targetData in pairs(self) do
            for _, allowedJob in pairs(allowedJobs) do
                if targetData.job == allowedJob and targetData.on_duty then
                    TriggerClientEvent('cd_dispatch:SyncUserSettings', targetId, {
                        source = playerId,
                        status = playerData.status,
                        callsign = playerData.callsign,
                        vehicle = playerData.vehicle,
                    })
                    break
                end
            end
        end
    end

    RefreshLargeUI(playerData.job)
end)

RegisterServerEvent("cd_dispatch:Dispatcher_AddCall")
AddEventHandler("cd_dispatch:Dispatcher_AddCall", function(callData)
    if not callData or not callData.coords then
        ShowError("9001 - Invalid callData or missing coords")
        return
    end
    callData.coords = vector3(callData.coords.x, callData.coords.y, callData.coords.z)
    
    local allowedJobs = CheckMultiJobs(callData.job)
    if not allowedJobs then
        ShowError("9002 - CheckMultiJobs returned nil for job: " .. tostring(callData.job))
        return
    end

    TrackDispatchCall(callData.unique_id, callData.coords, allowedJobs)

    local sentCount = 0
    for playerId, playerData in pairs(self) do
        for _, allowedJob in pairs(allowedJobs) do
            if playerData.job == allowedJob and playerData.on_duty then
                TriggerClientEvent("cd_dispatch:AddNotification", playerData.source, callData, true)
                sentCount = sentCount + 1
                break
            end
        end
    end
end)

local radioCodeCooldowns = {}
local radioCodeSequence = 0
local radioCodeJobs = {
    police = true,
    sheriff = true,
    ambulance = true,
}

local function EscapeRadioCodeText(value, limit)
    if type(value) ~= 'string' then value = tostring(value or '') end
    value = value:gsub('[%c]', ' '):sub(1, limit)
    return value:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

RegisterNetEvent('onyx_dispatch:SendRadioCode')
AddEventHandler('onyx_dispatch:SendRadioCode', function(code, street)
    local sourceId = source
    if not Config.RadioCodes or not Config.RadioCodes.ENABLE then return end
    if code ~= '10-20' and code ~= '10-99' and code ~= '10-99-joint' then return end

    local unit = self and self[sourceId]
    local job = GetJob(sourceId)
    if not unit or not unit.on_duty or type(job) ~= 'string' or unit.job ~= job then return end
    if not radioCodeJobs[job] then return end
    if Config.UseFrameworkDutySystem and not IsPlayerOnDuty(sourceId) then return end

    local targetJobs
    local titleKey
    local messageKey
    local flash = 0
    local sound = 1
    local blipSprite = 792

    if code == '10-20' then
        targetJobs = {job}
        titleKey = 'radio_code_10_20_title'
        messageKey = 'radio_code_10_20_message'
    elseif code == '10-99' then
        targetJobs = {job}
        titleKey = 'radio_code_10_99_title'
        messageKey = 'radio_code_10_99_message'
        flash = 1
        sound = 4
        blipSprite = 58
    else
        if job ~= 'police' and job ~= 'sheriff' then return end
        targetJobs = {'police', 'sheriff'}
        titleKey = 'radio_code_10_99_joint_title'
        messageKey = 'radio_code_10_99_joint_message'
        flash = 1
        sound = 4
        blipSprite = 58
    end

    local ped = GetPlayerPed(sourceId)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end
    local coords = GetEntityCoords(ped)

    local cooldown = math.max(1, tonumber(Config.RadioCodes.cooldown) or 10)
    local now = os.time()
    local cooldownGroup = code == '10-20' and '10-20' or '10-99'
    radioCodeCooldowns[sourceId] = radioCodeCooldowns[sourceId] or {}
    local nextAllowed = radioCodeCooldowns[sourceId][cooldownGroup] or 0
    if now < nextAllowed then
        TriggerClientEvent('onyx_dispatch:RadioCodeCooldown', sourceId, nextAllowed - now)
        return
    end
    radioCodeCooldowns[sourceId][cooldownGroup] = now + cooldown

    street = EscapeRadioCodeText(street, 100)
    if street == '' then street = L('unknown') end

    local callsign = EscapeRadioCodeText(unit.callsign or '', 32):match('^%s*(.-)%s*$')
    if callsign:sub(1, 1) == '[' and callsign:sub(-1) == ']' then
        callsign = callsign:sub(2, -2)
    end
    local callsignPrefix = callsign ~= '' and callsign ~= L('unknown') and ('[' .. callsign .. '] ') or ''

    radioCodeSequence = radioCodeSequence + 1
    local notification = {
        job_table = targetJobs,
        coords = coords,
        title = L(titleKey),
        message = L(
            messageKey,
            callsignPrefix,
            EscapeRadioCodeText(unit.char_name or L('unknown'), 64),
            street
        ),
        flash = flash,
        unique_id = ('radio:%s:%s:%s'):format(sourceId, now, radioCodeSequence),
        sound = sound,
        blip = {
            sprite = blipSprite,
            scale = code == '10-20' and 0.95 or 1.1,
            colour = code == '10-20' and 3 or 1,
            flashes = flash == 1,
            text = L(titleKey),
            time = 5,
            radius = 0,
        },
    }

    TrackDispatchCall(notification.unique_id, coords, targetJobs)

    for playerId, playerData in pairs(self) do
        if playerData.on_duty then
            for _, targetJob in ipairs(targetJobs) do
                if playerData.job == targetJob then
                    TriggerClientEvent('cd_dispatch:AddNotification', playerId, notification, true)
                    break
                end
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    radioCodeCooldowns[playerId] = nil

    for uniqueId, call in pairs(trackedDispatchCalls) do
        if call.responders[playerId] then
            call.responders[playerId] = nil
            local responderCount = 0
            for _ in pairs(call.responders) do responderCount = responderCount + 1 end

            local unit = self and self[playerId]
            local removal = {
                unique_id = uniqueId,
                action = 'remove',
                responding = responderCount + 1,
                char_info = {
                    source = playerId,
                    callsign = unit and unit.callsign or '',
                    char_name = unit and unit.char_name or '',
                },
            }
            for targetId, targetData in pairs(self or {}) do
                if IsTrackedCallRecipient(targetData, call) then
                    TriggerClientEvent('cd_dispatch:PlayerResponding', targetId, removal)
                end
            end
            SendRespondersSnapshot(uniqueId, call)
        end
    end
end)

RegisterServerEvent("cd_dispatch:DispatcherToggle")
AddEventHandler("cd_dispatch:DispatcherToggle", function(isEnabled, jobName)
    local playerId = source
    
    if not ValidateType(isEnabled, "boolean") or not ValidateType(jobName, "string") then
        ShowError("1145")
        return
    end
    
    if type(playerId) == "number" then
        self[playerId].dispatcher = isEnabled
    end
    
    if isEnabled then
        DispatcherData.count = DispatcherData.count + 1
        DispatcherData.active = true
    else
        DispatcherData.count = DispatcherData.count - 1
        if DispatcherData.count <= 0 then
            DispatcherData.count = 0
            DispatcherData.active = false
        end
    end
    
    local allowedJobs = CheckMultiJobs(jobName)
    for _, playerData in pairs(self) do
        for _, allowedJob in pairs(allowedJobs) do
            if playerData.job == allowedJob and playerData.on_duty then
                TriggerClientEvent("cd_dispatch:DispatcherToggle", playerData.source, DispatcherData.active)
                
                if Config.Dispatcher.notify_activity then
                    if isEnabled then
                        SendNotification(playerData.source, 2, "dispatcher_joined",
                                       self[playerId].callsign, self[playerId].char_name,
                                       DispatcherData.count)
                    else
                        SendNotification(playerData.source, 2, "dispatcher_left",
                                       self[playerId].callsign, self[playerId].char_name,
                                       DispatcherData.count)
                    end
                    
                    if not DispatcherData.active then
                        SendNotification(playerData.source, 2, "dispatcher_all_offline")
                    end
                end
                break
            end
        end
    end
end)

RegisterServerEvent("cd_dispatch:SetGPS")
AddEventHandler("cd_dispatch:SetGPS", function(targetPlayer)
    TriggerClientEvent("cd_dispatch:SetGPS", source, GetEntityCoords(GetPlayerPed(targetPlayer)))
end)

local groupsData = {}

RegisterServerEvent("cd_dispatch:UpdateGroups")
AddEventHandler("cd_dispatch:UpdateGroups", function(groupInfo)
    local playerId = source
    local groupIndex = nil
    
    for i = 1, #Config.AllowedJobs do
        if Config.AllowedJobs[i] then
            for _, job in pairs(Config.AllowedJobs[i]) do
                if job == groupInfo.job then
                    if not groupsData[i] then
                        groupsData[i] = {}
                    end
                    groupsData[i] = groupInfo.groups
                    groupIndex = i
                    break
                end
            end
        else
            ShowError("4114")
        end
    end
    
    groupInfo.job = nil
    
    if groupsData[groupIndex] and groupInfo.sources then
        for _, targetSource in pairs(groupInfo.sources) do
            TriggerClientEvent("cd_dispatch:UpdateGroups", targetSource, groupInfo)
        end
    end
end)

function SendNotification(targetSource, notifType, localeKey, ...)
    if not ValidateType(targetSource, "number") or 
       not ValidateType(notifType, "number") or 
       not ValidateType(localeKey, "string") then
        ShowError("0132")
        return
    end
    
    if Locales[Config.Language] and Locales[Config.Language][localeKey] then
        local message = string.format(Locales[Config.Language][localeKey], ...)
        local success = xpcall(function()
            Notification(targetSource, notifType, message)
        end, HandleError)
        
        if not success then
            ShowError("6584 ^")
        end
    else
        ShowError("0063")
    end
end

function ShowError(errorCode)
    print(divider .. "\n\n^8[" .. resourceName .. "] ^1[error_code - " .. errorCode .. "]\n\n" .. supportText)
end

function HandleError(errorMessage)
    print(divider .. "\n\n^8[" .. resourceName .. "] [Codesign ErrorHandler]\n^1" .. errorMessage)
end

function ValidateType(value, expectedType)
    local actualType = type(value)
    if actualType == expectedType then
        return true
    else
        HandleError(string.format("%s expected, got %s : %s", expectedType, actualType, value))
        return false
    end
end

function DatabaseQuery(query, params)
    if params == nil then params = {} end
    
    if not ValidateType(query, "string") then
        ShowError("5465474878")
        return
    end
    
    local isWaiting = true
    local result = nil
    
    if Config.Database == "mysql" then
        local success = xpcall(function()
            MySQL.Async.fetchAll(query, params, function(queryResult)
                result = queryResult
                isWaiting = false
            end)
        end, HandleError)
        
        if not success then
            ShowError("99999999 ^")
        end
        
        local attempts = 0
        while isWaiting and attempts <= 50 do
            Wait(0)
            attempts = attempts + 1
        end
    elseif Config.Database == "ghmattimysql" then
        local success = xpcall(function()
            exports.ghmattimysql:execute(query, params, function(queryResult)
                result = queryResult
                isWaiting = false
            end)
        end, HandleError)
        
        if not success then
            ShowError("99998888 ^")
        end
        
        local attempts = 0
        while isWaiting and attempts <= 50 do
            Wait(0)
            attempts = attempts + 1
        end
    elseif Config.Database == "oxmysql" then
        local success = xpcall(function()
            MySQL.Async.fetchAll(query, params, function(queryResult)
                result = queryResult
                isWaiting = false
            end)
        end, HandleError)
        
        if not success then
            ShowError("99997777 ^")
        end
        
        local attempts = 0
        while isWaiting and attempts <= 50 do
            Wait(0)
            attempts = attempts + 1
        end
    end
    
    return result
end

function Checks(checkType, playerId, value)
    if checkType == "set_callsign" then
        local success = xpcall(function()
            SetCallsign(playerId, value)
        end, HandleError)
        
        if not success then
            ShowError("5554 ^")
        end
    end
end

Notif = SendNotification
E = ShowError
E2 = HandleError
T = ValidateType
