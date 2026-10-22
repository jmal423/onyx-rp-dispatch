--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX, QBCore = nil, nil

if Config.Framework == 'esx' then
    pcall(function() ESX = exports[Config.FrameworkTriggers.resource_name]:getSharedObject() end)
    if ESX == nil then
        TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)
    end
    
elseif Config.Framework == 'qbcore' then
    TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
    if QBCore == nil then
        QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
    end
    
elseif Config.Framework == 'other' then
    --add your own code here.
end


function GetIdentifier(source)
    if Config.Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        end

    elseif Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.PlayerData.citizenid
        end

    elseif Config.Framework == 'other' then
        return GetPlayerIdentifiers(source)[1] --return your identifier here (string).

    end
end

function GetJob(source)
    if Config.Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.job.name
        end
    
    elseif Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.PlayerData.job.name
        end

    elseif Config.Framework == 'other' then
        return 'unemployed' --return the players job name (string).

    end
end

function IsPlayerOnDuty(source)
    if not Config.UseFrameworkDutySystem then return false end

    if Config.Framework == 'esx' then
        local player = ESX.GetPlayerFromId(source)
        return player ~= nil and player.job ~= nil and player.job.onDuty == true
    elseif Config.Framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayer(source)
        return player ~= nil and player.PlayerData.job ~= nil and player.PlayerData.job.onduty == true
    end

    return false
end

function GetFrameworkPlayerJob(source)
    if Config.Framework == 'esx' then
        local player = ESX.GetPlayerFromId(source)
        return player and player.job and player.job.name or nil
    elseif Config.Framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayer(source)
        return player and player.PlayerData.job and player.PlayerData.job.name or nil
    end
    return nil
end

local function GetConfiguredHighestJobGrade(jobName)
    local jobDefinition
    if Config.Framework == 'qbcore' and QBCore and QBCore.Shared and QBCore.Shared.Jobs then
        jobDefinition = QBCore.Shared.Jobs[jobName]
    elseif Config.Framework == 'esx' and ESX and ESX.Jobs then
        jobDefinition = ESX.Jobs[jobName]
    end

    local grades = jobDefinition and (jobDefinition.grades or jobDefinition.Grades)
    if type(grades) ~= 'table' then return nil end

    local highest
    for key, gradeData in pairs(grades) do
        local level = type(gradeData) == 'table' and tonumber(gradeData.level or gradeData.grade) or tonumber(key)
        if level and (highest == nil or level > highest) then highest = level end
    end
    return highest
end

function CanOperateDispatch(source)
    if not Config.Dispatcher.ENABLE then return false end

    local jobName = GetFrameworkPlayerJob(source)
    local requiredGrade = jobName and Config.Dispatcher.Perms[jobName]
    if requiredGrade == nil then return false end

    local playerGrade
    if Config.Framework == 'qbcore' then
        local player = QBCore and QBCore.Functions.GetPlayer(source)
        local grade = player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.grade
        playerGrade = type(grade) == 'table' and tonumber(grade.level) or tonumber(grade)
    elseif Config.Framework == 'esx' then
        local player = ESX and ESX.GetPlayerFromId(source)
        playerGrade = player and player.job and tonumber(player.job.grade)
    end
    if not playerGrade then return false end

    if requiredGrade == 'highest' then
        local highestGrade = GetConfiguredHighestJobGrade(jobName)
        return highestGrade ~= nil and playerGrade == highestGrade
    end

    requiredGrade = tonumber(requiredGrade)
    return requiredGrade ~= nil and playerGrade >= requiredGrade
end

function CheckJob(source, job)
    if CheckMultiJobs(job) and self[source].on_duty then
        return true
    else
        return false
    end
end

function RemoveMoney(source, amount)
    if Config.Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeAccountMoney('bank', amount)
        end

    elseif Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            xPlayer.Functions.RemoveMoney('bank', amount, 'Speeding fine')
        end

    elseif Config.Framework == 'other' then
        --remove money from a player.
    end
end


--███╗   ███╗ █████╗ ██╗███╗   ██╗
--████╗ ████║██╔══██╗██║████╗  ██║
--██╔████╔██║███████║██║██╔██╗ ██║
--██║╚██╔╝██║██╔══██║██║██║╚██╗██║
--██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
--╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝


RegisterServerEvent('onyx_dispatch:PlayerLoaded')
AddEventHandler('onyx_dispatch:PlayerLoaded', function()
    local _source = source
    local data = GetCharacterInfo(_source)
    self[_source] = {}
    self[_source].source = _source
    self[_source].char_name = data.char_name
    self[_source].callsign = data.callsign
    self[_source].phone_number = data.phone_number
    self[_source].job = GetJob(_source)
    self[_source].radio_channel = 0
    self[_source].vehicle = 'foot'
    self[_source].status = {
        name = 'Disponível',
        color = '#539D1B'
    }
    self[_source].on_duty = IsPlayerOnDuty(_source)
    self[_source].can_dispatch = CanOperateDispatch(_source)
    TriggerClientEvent('onyx_dispatch:DutyState', _source, self[_source].on_duty)
    TriggerClientEvent('onyx_dispatch:DispatcherPermission', _source, self[_source].can_dispatch)
    TriggerClientEvent('onyx_dispatch:SendSourceData', _source, self[_source], IsDispatchActiveForJob(self[_source].job))
    PlayerBlipsActions(_source, 'update')
    if CheckMultiJobs(self[_source].job) then
        RefreshLargeUI(self[_source].job)
    end
end)

function GetCharacterInfo(source)
    local identifier = GetIdentifier(source)
    local data = {}
    data.char_name, data.callsign = L('unknown'), ''

    if Config.Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            data.char_name = xPlayer.getName(source)
        end
    
    elseif Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            data.char_name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        end
    
    elseif Config.Framework == 'other' then
        --add your own code here.

    end

    local Result = DatabaseQuery('SELECT callsign FROM onyx_dispatch WHERE identifier = ?', {identifier})
    if Result and Result[1] and type(Result[1].callsign) == 'string' and Result[1].callsign ~= '' then
        data.callsign = Result[1].callsign
    end
    
    data.phone_number = GetPhoneNumber(source)
    return data
end

function GetPhoneNumber(source)
    if GetResourceState('lb-phone') == 'started' then
        return exports['lb-phone']:GetEquippedPhoneNumber(source)
    end

    if Config.Framework == 'esx' then 
        local identifier = GetIdentifier(source)
        local Result = DatabaseQuery('SELECT phone_number FROM users WHERE identifier="'..identifier..'"')
        if Result and Result[1] and Result[1].phone_number then
            return Result[1].phone_number
        end

    elseif Config.Framework == 'qbcore' then 
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer and xPlayer.PlayerData.charinfo.phone then
            return xPlayer.PlayerData.charinfo.phone
        end

    elseif Config.Framework == 'other' then 
        --add your own code here.

    end
    return ''
end

function SetCallsign(source, callsign)
    local identifier = GetIdentifier(source)
    if type(identifier) ~= 'string' or type(callsign) ~= 'string' or callsign == '' or #callsign >= 16 then return end

    local Result = DatabaseQuery('SELECT callsign FROM onyx_dispatch WHERE identifier = ?', {identifier})
    if not Result then return end
    if Result[1] then
        DatabaseQuery('UPDATE onyx_dispatch SET callsign = ? WHERE identifier = ?', {callsign, identifier})
    else
        DatabaseQuery('INSERT INTO onyx_dispatch (identifier, callsign) VALUES (?, ?)', {identifier, callsign})
    end
end

RegisterServerEvent('onyx_dispatch:JobSet')
AddEventHandler('onyx_dispatch:JobSet', function(job)
    local _source = source
    if self and self[_source] then
        job = GetFrameworkPlayerJob(_source) -- Never accept a job identity supplied by the client.
        if type(job) ~= 'string' then return end
        local old_job = self[_source].job
        if self[_source].dispatcher and (job ~= old_job or not CanOperateDispatch(_source)) then
            SetDispatcherState(_source, false, true)
        end
        self[_source].job = job
        self[_source].can_dispatch = CanOperateDispatch(_source)
        TriggerClientEvent('onyx_dispatch:DispatcherPermission', _source, self[_source].can_dispatch)
        PlayerBlipsActions(_source, 'update')
        if CheckMultiJobs(job) then
            RefreshLargeUI(job)
            TriggerClientEvent('onyx_dispatch:SendSourceData', _source, self[_source], IsDispatchActiveForJob(self[_source].job))
        end
        if CheckMultiJobs(old_job) then
            RefreshLargeUI(old_job)
        end
    end
end)


--██████╗  █████╗ ██████╗ ██╗ ██████╗      ██████╗██╗  ██╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██╗     
--██╔══██╗██╔══██╗██╔══██╗██║██╔═══██╗    ██╔════╝██║  ██║██╔══██╗████╗  ██║████╗  ██║██╔════╝██║     
--██████╔╝███████║██║  ██║██║██║   ██║    ██║     ███████║███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██║     
--██╔══██╗██╔══██║██║  ██║██║██║   ██║    ██║     ██╔══██║██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║     
--██║  ██║██║  ██║██████╔╝██║╚██████╔╝    ╚██████╗██║  ██║██║  ██║██║ ╚████║██║ ╚████║███████╗███████╗
--╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚══════╝


RegisterServerEvent('onyx_dispatch:GetRadioChannel')
AddEventHandler('onyx_dispatch:GetRadioChannel', function(radio_channel)
    local _source = source
    if radio_channel ~= nil and CheckJob(_source, self[_source].job) and self and self[_source] then
        self[_source].radio_channel = tonumber(radio_channel)
        RefreshLargeUI(self[_source].job)
        PlayerBlipsActions(_source, 'update')
    end
end)


--███╗   ██╗ ██████╗ ████████╗██╗███████╗██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--██╔██╗ ██║██║   ██║   ██║   ██║█████╗  ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██║╚██╗██║██║   ██║   ██║   ██║██╔══╝  ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║ ╚████║╚██████╔╝   ██║   ██║██║     ██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝


function Notification(source, notif_type, message)
    if source and notif_type and message then
        if Config.Notification == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        
        elseif Config.Notification == 'qbcore' then
            if notif_type == 1 then
                TriggerClientEvent('QBCore:Notify', source, message, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('QBCore:Notify', source, message, 'primary')
            elseif notif_type == 3 then
                TriggerClientEvent('QBCore:Notify', source, message, 'error')
            end
        
        elseif Config.Notification == 'cd_notifications' then
            if notif_type == 1 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('dispatch'), message = message, type = 'success', options = {duration = 5}})
            elseif notif_type == 2 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('dispatch'), message = message, type = 'inform', options = {duration = 5}})
            elseif notif_type == 3 then
                TriggerClientEvent('cd_notifications:Add', source, {title =  L('dispatch'), message = message, type = 'error', options = {duration = 5}})
            end

        elseif Config.Notification == 'okokNotify' then
            if notif_type == 1 then
                TriggerClientEvent('okokNotify:Alert', source, L('dispatch'), message, 5000, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('okokNotify:Alert', source, L('dispatch'), message, 5000, 'info')
            elseif notif_type == 3 then
                TriggerClientEvent('okokNotify:Alert', source, L('dispatch'), message, 5000, 'error')
            end

        elseif Config.Notification == 'ps-ui' then
            if notif_type == 1 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'success')
            elseif notif_type == 2 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'primary')
            elseif notif_type == 3 then
                TriggerClientEvent('ps-ui:Notify', source, message, 'error')
            end

        elseif Config.Notification == 'ox_lib' then
            if notif_type == 1 then
                lib.notify(source, {title = L('dispatch'), description = message, type = 'success'})
            elseif notif_type == 2 then
                lib.notify(source, {title = L('dispatch'), description = message, type = 'inform'})
            elseif notif_type == 3 then
                lib.notify(source, {title = L('dispatch'), description = message, type = 'error'})
            end

        elseif Config.Notification == 'chat' then
            TriggerClientEvent('chatMessage', source, message)

        elseif Config.Notification == 'other' then
            --add your own notification.

        end
    end
end


-- ██████╗ ████████╗██╗  ██╗███████╗██████╗ 
--██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
--██║   ██║   ██║   ███████║█████╗  ██████╔╝
--██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
--╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
-- ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


RegisterServerEvent('esx:cd_multicharacter:SwitchCharacter')
AddEventHandler('esx:cd_multicharacter:SwitchCharacter', function(_source)
	if type(_source) ~= 'number' then _source = source end
	PlayerDropped(_source)
end)

RegisterServerEvent('cd_donatorshop:CharacterNameChanged')
AddEventHandler('cd_donatorshop:CharacterNameChanged', function(new_name, _source)
	if type(_source) ~= 'number' then _source = source end
	if self and self[_source] then
        self[_source].char_name = new_name
        PlayerBlipsActions(_source, 'update')
    end
end)

RegisterNetEvent('onyx_dispatch:OnDutyChecks')
AddEventHandler('onyx_dispatch:OnDutyChecks', function(boolean)
    local _source = source
    while not self do Wait(1000) end
    if self[_source] and Config.UseFrameworkDutySystem and type(boolean) == 'boolean' then
        local duty = IsPlayerOnDuty(_source)

        self[_source].on_duty = duty
        self[_source].can_dispatch = CanOperateDispatch(_source)
        if not duty and self[_source].dispatcher then
            SetDispatcherState(_source, false, true)
        end
        TriggerClientEvent('onyx_dispatch:DutyState', _source, duty)
        TriggerClientEvent('onyx_dispatch:DispatcherPermission', _source, self[_source].can_dispatch)
        if duty then
            PlayerBlipsActions(_source, 'update')
        else
            TriggerClientEvent('onyx_dispatch:ForceCloseLargeUI', _source)
            PlayerBlipsActions(_source, 'remove')
        end
    end
end)

function PlayerDropped(source)
    if self and source and self[source] then
        PlayerBlipsActions(source, 'remove')
        if self[source].dispatcher then
            SetDispatcherState(source, false, true)
        end
        if CheckMultiJobs(self[source].job) then
            RefreshLargeUI(self[source].job)
        end
	    Wait(2000)
        self[source] = nil
    end
end
AddEventHandler('playerDropped', function()
    PlayerDropped(source)
end)

RegisterServerEvent('onyx_dispatch:AddNotification')
AddEventHandler('onyx_dispatch:AddNotification', function(data)
    for c, d in pairs(self) do
        for cc, dd in pairs(data.job_table) do
            if d.job == dd then
                TriggerClientEvent('onyx_dispatch:AddNotification', d.source, data)
            end
        end
    end
end)


--███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ███████╗██╗  ██╗██████╗  ██████╗ ██████╗ ████████╗███████╗
--██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ██╔════╝╚██╗██╔╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝
--███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝    █████╗   ╚███╔╝ ██████╔╝██║   ██║██████╔╝   ██║   ███████╗
--╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██╔══╝   ██╔██╗ ██╔═══╝ ██║   ██║██╔══██╗   ██║   ╚════██║
--███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ███████╗██╔╝ ██╗██║     ╚██████╔╝██║  ██║   ██║   ███████║
--╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


function GetPlayersDispatchData(source)
    return self[source]
end


--██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


RegisterServerEvent('onyx_dispatch:Debug')
AddEventHandler('onyx_dispatch:Debug', function()
    local _source = source
    print('^6-----------------------^0')
    print('^1CODESIGN DEBUG^0')
    print(string.format('^6Identifier:^0 %s', GetIdentifier(_source)))
    print(string.format('^6Job Name:^0 %s', GetJob(_source)))
    if GetResourceState('cd_devtools') == 'started' then
        local count = 0
        while not self[_source] do Wait(1000) count = count+1 print('^6Waited '..count..' second(s) for the player data to cache.^0') end
        TriggerClientEvent('table', _source, self[_source])
        print('^3Check the client side cd_devtools UI.^0')
    else
        print('^1You need to have cd_devtools started!^0')
    end
    print('^6-----------------------^0')
end)
