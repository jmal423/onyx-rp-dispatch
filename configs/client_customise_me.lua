--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX, QBCore = nil, nil
JobData, on_duty = {}, false

local function UpdateDispatchVisibility()
    if not Authorised then return end
    DispatchRestartTrace('visibility_check', {
        job = JobData and JobData.name,
        on_duty = on_duty,
        allowed = IsAllowed(),
        source_info_loaded = HasSourceInfoLoaded(),
        large = uiStates and uiStates.large == true
    })
    if IsAllowed() then
        if HasSourceInfoLoaded() and not uiStates.large then ShowSmallUI() end
    else
        if uiStates.large then HideLargeUI() end
        HideSmallUI()
    end
end

CreateThread(function()
    if Config.Framework == 'esx' then
        while ESX == nil do
            pcall(function() ESX = exports[Config.FrameworkTriggers.resource_name]:getSharedObject() end)
            if ESX == nil then
                TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)
            end
            Wait(100)
        end
        JobData = ESX.PlayerData.job or {}
        on_duty = Config.UseFrameworkDutySystem and JobData.onDuty == true
        UpdateDispatchVisibility()

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function(xPlayer)
            JobData = xPlayer.job or {}
            on_duty = Config.UseFrameworkDutySystem and JobData.onDuty == true
            while not Authorised do Wait(100) end
            TriggerServerEvent('onyx_dispatch:PlayerLoaded')
            UpdateDispatchVisibility()
        end)

        RegisterNetEvent(Config.FrameworkTriggers.job)
        AddEventHandler(Config.FrameworkTriggers.job, function(job)
            local last_job = JobData.name
            JobData = job or {}
            if Config.UseFrameworkDutySystem then
                on_duty = JobData.onDuty == true
            end
            if last_job ~= JobData.name then
                TriggerServerEvent('onyx_dispatch:JobSet', GetJob())
            end
            if Config.UseFrameworkDutySystem then
                TriggerServerEvent('onyx_dispatch:OnDutyChecks', on_duty)
            end
            UpdateDispatchVisibility()
        end)


    elseif Config.Framework == 'qbcore' then
        while QBCore == nil do
            TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
            if QBCore == nil then
                QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
            end
            Wait(100)
        end
        JobData = QBCore.Functions.GetPlayerData().job or {}
        on_duty = Config.UseFrameworkDutySystem and JobData.onduty == true
        DispatchRestartTrace('framework_initialised', { framework = 'qbcore', job = JobData.name, on_duty = on_duty })
        UpdateDispatchVisibility()

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function()
            JobData = QBCore.Functions.GetPlayerData().job or {}
            on_duty = Config.UseFrameworkDutySystem and JobData.onduty == true
            DispatchRestartTrace('framework_player_loaded', { framework = 'qbcore', job = JobData.name, on_duty = on_duty })
            while not Authorised do Wait(100) end
            TriggerServerEvent('onyx_dispatch:PlayerLoaded')
            DispatchRestartTrace('player_loaded_requested', { framework = 'qbcore', job = JobData.name, on_duty = on_duty })
            UpdateDispatchVisibility()
        end)

        RegisterNetEvent(Config.FrameworkTriggers.job)
        AddEventHandler(Config.FrameworkTriggers.job, function(JobInfo)
            local last_job = JobData.name
            JobData = JobInfo or {}
            if last_job ~= JobData.name then
                TriggerServerEvent('onyx_dispatch:JobSet', GetJob())
            end
            if Config.UseFrameworkDutySystem then
                on_duty = JobData.onduty == true
                TriggerServerEvent('onyx_dispatch:OnDutyChecks', on_duty)
            end
            UpdateDispatchVisibility()
        end)

        RegisterNetEvent(Config.FrameworkTriggers.duty)
        AddEventHandler(Config.FrameworkTriggers.duty, function(boolean)
            if type(boolean) ~= 'boolean' or on_duty == boolean or not Config.UseFrameworkDutySystem then return end
            on_duty = boolean
            TriggerServerEvent('onyx_dispatch:OnDutyChecks', on_duty)
            UpdateDispatchVisibility()
        end)
    

    elseif Config.Framework == 'other' then
        -- Custom frameworks must explicitly provide a trusted duty integration.
        on_duty = false

    end
end)

function GetJob()
    if Config.Framework == 'esx' then
        while JobData.name == nil do Wait(0) end
        return JobData.name
    
    elseif Config.Framework == 'qbcore' then
        while JobData.name == nil do Wait(0) end
        return JobData.name

    elseif Config.Framework == 'other' then
        return 'unemployed' --return a players job name (string).
    end
end

function GetJob_grade()
    if Config.Framework == 'esx' then
        while JobData.grade == nil do Wait(0) end
        return JobData.grade
    
    elseif Config.Framework == 'qbcore' then
        while JobData.grade.level == nil do Wait(0) end
        return JobData.grade.level

    elseif Config.Framework == 'other' then
        return 0 --return a players job grade (number).
    end
end

function GetJob_label()
    if Config.Framework == 'esx' then
        while JobData.label == nil do Wait(0) end
        return JobData.label
    
    elseif Config.Framework == 'qbcore' then
        while JobData.label == nil do Wait(0) end
        return JobData.label

    elseif Config.Framework == 'other' then
        return 'Unemployed' --return a players job label (string).
    end
end

function IsAllowed()
    if not JobData or type(JobData.name) ~= 'string' then return false end
    local job = GetJob()
    if CheckMultiJobs(job) and on_duty then
        return true
    end
    return false
end

function CheckJob(job_table, job)
    if job_table then
        if job == nil then
            job = GetJob()
        end
        for c, d in pairs(job_table) do
            if job == d and on_duty then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent('onyx_dispatch:ScriptRestarted')
AddEventHandler('onyx_dispatch:ScriptRestarted', function()
    DispatchRestartTrace('script_restarted_received', { authorised = Authorised, job = JobData and JobData.name, on_duty = on_duty })
    local waitStarted = GetGameTimer()
    while not Authorised do Wait(0) end
    DispatchRestartTrace('nui_authorisation_wait_complete', { waited_ms = GetGameTimer() - waitStarted })
    TriggerServerEvent('onyx_dispatch:PlayerLoaded')
    DispatchRestartTrace('player_loaded_requested', { reason = 'resource_restart', job = JobData and JobData.name, on_duty = on_duty })
end)


--██╗  ██╗███████╗██╗   ██╗███████╗     █████╗ ███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
--██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝    ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
--█████╔╝ █████╗   ╚████╔╝ ███████╗    ███████║██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
--██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║    ██╔══██║██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
--██║  ██╗███████╗   ██║   ███████║    ██║  ██║██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
--╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝


CreateThread(function()
    while not Authorised do Wait(100) end
    if Config.large_ui.ENABLE then
        RegisterKeyMapping(Config.large_ui.command, L('dispatchlarge_description'), 'keyboard', Config.large_ui.key)
        RegisterCommand(Config.large_ui.command, function()
            TriggerEvent('onyx_dispatch:KEY_largeui') --The event to open the large UI.
        end)
    end
    if Config.respond.ENABLE then
        RegisterKeyMapping(Config.respond.command, L('respond_description'), 'keyboard', Config.respond.key)
        RegisterCommand(Config.respond.command, function()
            TriggerEvent('onyx_dispatch:KEY_responding') --The event to toggle the responding.
        end)
    end
    if Config.move_mode.ENABLE then
        TriggerEvent('chat:addSuggestion', '/moverdispatch', L('movemode_description'))
        RegisterCommand(Config.move_mode.command, function()
            TriggerEvent('onyx_dispatch:EnableMoveMode') --The event to enable move mode.
        end)
    end
    if Config.small_ui_left.ENABLE then
        RegisterKeyMapping(Config.small_ui_left.command, L('scrollleft_description'), 'keyboard', Config.small_ui_left.key)
        RegisterCommand(Config.small_ui_left.command, function()
            Decreasecount() --The function to scroll left through notifications on the small UI.
        end)
    end
    if Config.small_ui_right.ENABLE then
        RegisterKeyMapping(Config.small_ui_right.command, L('scrollright_description'), 'keyboard', Config.small_ui_right.key)
        RegisterCommand(Config.small_ui_right.command, function()
            Increasecount() --The function to scroll right through notifications on the small UI.
        end)
    end
end)

local keyLabelMap = {
    LEFT = '←',
    RIGHT = '→',
    UP = '↑',
    DOWN = '↓',
    RETURN = 'ENTER',
    BACK = 'BACKSPACE',
    ['b_194'] = '↑',
    ['b_195'] = '↓',
    ['b_196'] = '←',
    ['b_197'] = '→',
    ['b_198'] = 'DEL',
    ['b_199'] = 'ESC',
    ['b_200'] = 'INS',
    ['b_201'] = 'END',
    ['b_1000'] = 'SHIFT',
    ['b_1002'] = 'TAB',
    ['b_1003'] = 'ENTER',
    ['b_1004'] = 'BACKSPACE',
    ['b_1008'] = 'HOME',
    ['b_1009'] = 'PAGE UP',
    ['b_1010'] = 'PAGE DOWN',
    ['b_1012'] = 'CAPS LOCK',
    ['b_1013'] = 'CTRL',
    ['b_1014'] = 'RIGHT CTRL',
    ['b_1015'] = 'ALT',
    ['b_2000'] = 'SPACE',
}

local function GetMappedKeyLabel(command)
    if type(command) ~= 'string' or command == '' then return '—' end

    local mapped = GetControlInstructionalButton(0, GetHashKey(command) | 0x80000000, true)
    if type(mapped) ~= 'string' or mapped == '' then return '—' end

    if keyLabelMap[mapped] then return keyLabelMap[mapped] end

    local key = mapped:match('^t_(.+)$')
    if not key then return '—' end

    local normalizedKey = key:upper()
    if normalizedKey == 'NONE' or normalizedKey == 'NULL' then return '—' end

    return keyLabelMap[normalizedKey] or key
end

function GetDispatchKeybindLabels()
    return {
        previous = GetMappedKeyLabel(Config.small_ui_left.ENABLE and Config.small_ui_left.command),
        respond = GetMappedKeyLabel(Config.respond.ENABLE and Config.respond.command),
        next = GetMappedKeyLabel(Config.small_ui_right.ENABLE and Config.small_ui_right.command),
    }
end

CreateThread(function()
    local lastLabels
    while true do
        Wait(500)
        local labels = GetDispatchKeybindLabels()
        local signature = table.concat({labels.previous, labels.respond, labels.next}, '\0')
        if signature ~= lastLabels then
            lastLabels = signature
            SendNUIMessage({action = 'dispatchKeybinds', keys = labels})
        end
    end
end)

RegisterNetEvent('onyx_dispatch:DutyState')
AddEventHandler('onyx_dispatch:DutyState', function(duty)
    if type(duty) ~= 'boolean' then return end
    on_duty = duty
    DispatchRestartTrace('duty_state_received', { on_duty = duty, job = JobData and JobData.name })
    UpdateDispatchVisibility()
end)


--███╗   ██╗ ██████╗ ████████╗██╗███████╗██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--██╔██╗ ██║██║   ██║   ██║   ██║█████╗  ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██║╚██╗██║██║   ██║   ██║   ██║██╔══╝  ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║ ╚████║╚██████╔╝   ██║   ██║██║     ██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝


function Notification(notif_type, message)
    if notif_type and message then
        if Config.Notification == 'esx' then
            ESX.ShowNotification(message)
        
        elseif Config.Notification == 'qbcore' then
            if notif_type == 1 then
                QBCore.Functions.Notify(message, 'success')
            elseif notif_type == 2 then
                QBCore.Functions.Notify(message, 'primary')
            elseif notif_type == 3 then
                QBCore.Functions.Notify(message, 'error')
            end
        
        elseif Config.Notification == 'cd_notifications' then
            if notif_type == 1 then
                TriggerEvent('cd_notifications:Add', {title =  L('dispatch'), message = message, type = 'success', options = {duration = 5}})
            elseif notif_type == 2 then
                TriggerEvent('cd_notifications:Add', {title =  L('dispatch'), message = message, type = 'inform', options = {duration = 5}})
            elseif notif_type == 3 then
                TriggerEvent('cd_notifications:Add', {title =  L('dispatch'), message = message, type = 'error', options = {duration = 5}})
            end

        elseif Config.Notification == 'okokNotify' then
            if notif_type == 1 then
                exports['okokNotify']:Alert(L('dispatch'), message, 5000, 'success')
            elseif notif_type == 2 then
                exports['okokNotify']:Alert(L('dispatch'), message, 5000, 'info')
            elseif notif_type == 3 then
                exports['okokNotify']:Alert(L('dispatch'), message, 5000, 'error')
            end
        
        elseif Config.Notification == 'ps-ui' then
            if notif_type == 1 then
                exports['ps-ui']:Notify(message, 'success', 5000)
            elseif notif_type == 2 then
                exports['ps-ui']:Notify(message, 'primary', 5000)
            elseif notif_type == 3 then
                exports['ps-ui']:Notify(message, 'error', 5000)
            end
        
        elseif Config.Notification == 'ox_lib' then
            if notif_type == 1 then
                lib.notify({title = L('dispatch'), description = message, type = 'success'})
            elseif notif_type == 2 then
                lib.notify({title = L('dispatch'), description = message, type = 'inform'})
            elseif notif_type == 3 then
                lib.notify({title = L('dispatch'), description = message, type = 'error'})
            end

        elseif Config.Notification == 'chat' then
            TriggerEvent('chatMessage', message)
            
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


function BlipSound(sound)
    if tostring(sound) == '1' then
        DispatchSound('normal')

    elseif tostring(sound) == '2' then
        DispatchSound('normal')
        Wait(800)
        DispatchSound('normal')
        
    elseif tostring(sound) == '3' or tostring(sound) == '4' then
        DispatchSound('panic')
    end
end

function TabletAnimation(boolean)
    local ped = PlayerPedId()
    if boolean then
        PlayAnimation('amb@world_human_seat_wall_tablet@female@base', 'base', -1)
        tablet_prop = CreateObject(`prop_cs_tablet`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(tablet_prop, ped, GetPedBoneIndex(ped, 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(tablet_prop)
    else
        StopAnimTask(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base' ,8.0, -8.0, -1, 50, 0, false, false, false)
        NetworkRequestControlOfEntity(tablet_prop)
        SetEntityAsMissionEntity(tablet_prop)
        DeleteEntity(tablet_prop)
        tablet_prop = nil
    end
end

RegisterNetEvent('onyx_dispatch:OnDutyChecks')
AddEventHandler('onyx_dispatch:OnDutyChecks', function(boolean)
    if type(boolean) == 'boolean' and Config.UseFrameworkDutySystem and on_duty ~= boolean then
        on_duty = boolean
        TriggerServerEvent('onyx_dispatch:OnDutyChecks', on_duty)
        UpdateDispatchVisibility()
    end
end)


--██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


if Config.Debug then
    local function Debug()
        while not Authorised do Wait(1000) end
        print('^6-----------------------^0')
        print('^1CODESIGN DEBUG^0')
        print(string.format('^6Resource Name:^0 %s', GetCurrentResourceName()))
        print(string.format('^6Framework:^0 %s', Config.Framework))
        print(string.format('^6Database:^0 %s', Config.Database))
        print(string.format('^6Config.AutoInsertSQL:^0 %s', Config.AutoInsertSQL))
        print(string.format('^6Notification:^0 %s', Config.Notification))
        print(string.format('^6Language:^0 %s', Config.Language))
        print(string.format('^6UsingOneSync:^0 %s', Config.UsingOneSync))
        if Config.Framework == 'esx' or Config.Framework == 'qbcore' or Config.Framework == 'other' then
            while JobData.name == nil do Wait(0) end
            print(string.format('^6Job Name:^0 %s', GetJob()))
            print(string.format('^6Job Grade:^0 %s', GetJob_grade()))
        end
        print(string.format('^6Use Framework Duty System:^0 %s', Config.UseFrameworkDutySystem))
        print(string.format('^6On Duty:^0 %s', on_duty))
        print(string.format('^6Is Allowed:^0 %s', IsAllowed()))
        print('^6-----------------------^0')
        TriggerServerEvent('onyx_dispatch:Debug')
    end

    CreateThread(function()
        Wait(3000)
        Debug()
    end)

    RegisterCommand('debug_dispatch', function()
        Debug()
    end)
end

if Config.EnableTestCommand then
    RegisterCommand('dispatchtest', function() --THIS IS A TEST COMMAND.
        local data = exports['onyx_dispatch']:GetPlayerInfo()
        TriggerServerEvent('onyx_dispatch:AddNotification', {
            job_table = {'police', 'sheriff', },
            coords = data.coords,
            title = '10-15 - Store Robbery',
            message = 'A '..data.sex..' robbing a store at '..data.street, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = '911 - Store Robbery',
                time = 5,
                radius = 0,
            }
        })
    end)
end
