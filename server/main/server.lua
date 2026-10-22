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
            
            pauseMenuBlips[playerId].name = L("playerblip", self[playerId].callsign, self[playerId].char_name)
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

RegisterServerEvent("cd_dispatch:PlayerResponding")
AddEventHandler("cd_dispatch:PlayerResponding", function(responseData)
    for _, playerData in pairs(self) do
        for _, allowedJob in pairs(responseData.job_table) do
            if playerData.job == allowedJob then
                TriggerClientEvent("cd_dispatch:PlayerResponding", playerData.source, responseData)
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
    
    if settings.callsign and settings.callsign ~= self[playerId].callsign then
        self[playerId].callsign = settings.callsign
        Checks("set_callsign", playerId, settings.callsign)
        PlayerBlipsActions(playerId, "update")
    end
    
    if settings.vehicle and settings.vehicle ~= self[playerId].vehicle then
        self[playerId].vehicle = settings.vehicle
        PlayerBlipsActions(playerId, "update")
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
