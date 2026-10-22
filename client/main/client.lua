Authorised = false
isLoaded = false
isDispatcherOffline = false
CreateThread(function()
    SetNuiFocus(false, false)
    Wait(1000)
    while true do
        if isLoaded ~= false then
            break
        end
        TriggerServerEvent("cd_dispatch:SpeedtrapLocations")
        Wait(1000)
    end
end)
RegisterNetEvent("cd_dispatch:PoliceiconColour")
AddEventHandler("cd_dispatch:PoliceiconColour", function(color)
    if isLoaded then
        return
    end
    if color ~= nil then
        if type(color) == "number" then
            if color - 8952 == 12702 then
                isLoaded = true
                SendNUIMessage({
                    mapdayhours = 845
                })
                Wait(1000)
                while true do
                    if isDispatcherOffline ~= false then
                        break
                    end
                    Wait(1000)
                    SendNUIMessage({
                        mapdayhours = 845
                    })
                end
                isLoaded = nil
            end
        end
    end
end)
RegisterNUICallback("dispatcheroffline", function()
    isDispatcherOffline = true
    Authorised = true
    if Config.Debug then
        print("Loaded Successfully!")
    end
end)
Authorised = isDispatcherOffline
notifications = {}
currentNotificationIndex = 0
notifications[currentNotificationIndex] = {}
isRespondingOnCooldown = false
uiStates = {}
isDispatcher = false
NUI_status = false
SourceInfo = {}
auto_vehicle_blip = {}
auto_vehicle_blip.forced = {}
function GetPlayerNotifications()
    return notifications
end
function GetPlayersDispatchData()
    return SourceInfo
end
callbackResults = {}
callbackIndex = 0
function RunCallback(job, callbackType)
    callbackIndex = callbackIndex + 1
    if callbackType == "update_ui_blips" then
        TriggerServerEvent("cd_dispatch:GetCoords", job, callbackIndex)
    elseif callbackType == "large_ui_data" then
        TriggerServerEvent("cd_dispatch:LargeUIData", job, callbackIndex)
    end
    while true do
        if callbackResults[callbackIndex] ~= nil then
            break
        end
        Wait(0)
    end
    local result = callbackResults[callbackIndex]
    return result
end
RegisterNetEvent("cd_dispatch:Callback")
AddEventHandler("cd_dispatch:Callback", function(result, index)
    callbackResults[index] = result
    Wait(5000)
    callbackResults[index] = nil
end)
function HasSourceInfoLoaded()
    if SourceInfo.char_name and SourceInfo.callsign then
        return true
    end
    return false
end
RegisterNetEvent("cd_dispatch:KEY_smallui")
AddEventHandler("cd_dispatch:KEY_smallui", function()
    if Checks("is_allowed") then
        if not uiStates.small then
            if HasSourceInfoLoaded() then
                ShowSmallUI()
                return
            else
                Notif(2, "still_loading")
            end
        end
    else
        if Config.Debug then
            E("9711 - no_perms/off_duty")
        end
    end
    HideSmallUI()
end)
RegisterNetEvent("cd_dispatch:KEY_largeui")
AddEventHandler("cd_dispatch:KEY_largeui", function()
    if Checks("is_allowed") then
        if uiStates.large then
            return
        end
        if HasSourceInfoLoaded() then
            uiStates.large = true
            TabletAnimation(true)
            if uiStates.small then
                HideSmallUI()
            end
            local job = Checks("get_job")
            if T(job, "string") then
                if not Config.UsingOneSync then
                    SendNUIMessage({
                        action = "loading"
                    })
                end
                SendNUIMessage({
                    action = "showlarge_ui",
                    job = job,
                    large_uidata = RunCallback(job, "large_ui_data"),
                    mode = GetTime()
                })
                Checks("enable_nui")
                if Config.Dispatcher.ENABLE then
                    if Config.Dispatcher.AutoRefreshBlips.ENABLE then
                        local isDispatcherActive = false
                        local dispatcherCheck = Checks("is_dispatcher")
                        if T(dispatcherCheck, "boolean") then
                            if dispatcherCheck then
                                isDispatcherActive = true
                            end
                        else
                            E("6887")
                        end
                        if isDispatcherActive then
                            while true do
                                if not uiStates.large then
                                    break
                                end
                                Wait(Config.Dispatcher.AutoRefreshBlips.refresh_timer * 1000)
                                SendNUIMessage({
                                    action = "updatecoords",
                                    coords = RunCallback(job, "update_ui_blips")
                                })
                            end
                        end
                    end
                end
            else
                E("6584")
            end
        else
            Notif(2, "still_loading")
        end
    else
        if Config.Debug then
            E("9711 - no_perms/off_duty")
        end
    end
end)
RegisterNetEvent("cd_dispatch:KEY_responding")
AddEventHandler("cd_dispatch:KEY_responding", function()
    if Checks("is_allowed") then
        if uiStates.small then
            if notifications then
                if #notifications > 0 then
                    local currentNotification = notifications[currentNotificationIndex]
                    if currentNotification then
                        if currentNotification.coords ~= nil then
                            if not currentNotification.responding_state then
                                if not isRespondingOnCooldown then
                                    isRespondingOnCooldown = true
                                    TriggerEvent("cd_dispatch:StopSpammings")
                                    Responding(currentNotificationIndex, "add")
                                else
                                    Notif(3, "cooldown")
                                end
                            else
                                if not isRespondingOnCooldown then
                                    isRespondingOnCooldown = true
                                    TriggerEvent("cd_dispatch:StopSpammings")
                                    Responding(currentNotificationIndex, "remove")
                                else
                                    Notif(3, "cooldown")
                                end
                            end
                        else
                            E("2987")
                        end
                    end
                end
            end
        end
    else
        if Config.Debug then
            E("9711 - no_perms/off_duty")
        end
    end
end)
RegisterNetEvent("cd_dispatch:RefreshLargeUI")
AddEventHandler("cd_dispatch:RefreshLargeUI", function(job, largeUIData)
    if uiStates.large then
        SendNUIMessage({
            action = "showlarge_ui",
            job = job,
            large_uidata = largeUIData,
            mode = GetTime()
        })
    end
end)
RegisterNetEvent("cd_dispatch:EnableMoveMode")
AddEventHandler("cd_dispatch:EnableMoveMode", function()
    if Checks("is_allowed") then
        if uiStates.small then
            Checks("enable_nui")
            SendNUIMessage({
                action = "movemode"
            })
        end
    else
        if Config.Debug then
            E("9711 - no_perms/off_duty")
        end
    end
end)
RegisterNetEvent("cd_dispatch:SendSourceData")
AddEventHandler("cd_dispatch:SendSourceData", function(sourceData, dispatcherState)
    if T(sourceData, "table") then
        if T(dispatcherState, "boolean") then
            SourceInfo.char_name = sourceData.char_name
            SourceInfo.callsign = sourceData.callsign
            SourceInfo.phone_number = sourceData.phone_number
            if Config.Dispatcher.ENABLE then
                SourceInfo.dispatcher = Checks("is_dispatcher")
            else
                SourceInfo.dispatcher = false
            end
            isDispatcher = dispatcherState
            SourceInfo.job = sourceData.job
            SourceInfo.source = sourceData.source
            SendNUIMessage({
                action = "currentplayer",
                values = SourceInfo
            })
            SourceInfo.dispatcher = nil
            SourceInfo.job = nil
            if Config.PauseMenuBlips.blip_type == "auto" then
                auto_vehicle_blip.last = sourceData.vehicle
            end
            if Config.Debug then
                print("DEBUG: SourceInfo updated: " .. json.encode(SourceInfo))
            end
        end
    else
        E("8751")
    end
end)
if Config.UpdateDistanceUI.ENABLE then
    CreateThread(function()
        while true do
            Wait(Config.UpdateDistanceUI.timer * 1000)
            local distances = {}
            local index = 1
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, notification in ipairs(notifications) do
                distances[index] = {}
                distances[index].unique_id = notification.unique_id
                distances[index].distance = math.ceil(#(vector3(notification.coords.x, notification.coords.y, notification.coords.z) - playerCoords))
                index = index + 1
            end
            if #distances > 0 then
                SendNUIMessage({
                    action = "updatedistance",
                    values = distances
                })
            end
        end
    end)
end
RegisterNetEvent("cd_dispatch:AddNotification")
AddEventHandler("cd_dispatch:AddNotification", function(notificationData, isDispatcherNotification)
    if Config.Debug then
        print("DEBUG: Received notification: " .. json.encode(notificationData))
    end
    
    if not notifications then
        notifications = {}
        currentNotificationIndex = 0
        notifications[currentNotificationIndex] = {}
    end
    
    if T(notificationData, "table") then
        if not notificationData.unique_id then
            E("3777")
            return
        end
        
        if type(notificationData.job) == "string" then
            notificationData.job_table = notificationData.job_table or {}
            table.insert(notificationData.job_table, notificationData.job)
        end
        
        local hasJobAccess = Checks("check_job", notificationData.job_table)
        if T(hasJobAccess, "boolean") then
            if hasJobAccess then
                if Config.Debug then
                    print("DEBUG: Player has job access for notification")
                end

                if not uiStates.small and not uiStates.large then
                    ShowSmallUI()
                end
                
                currentNotificationIndex = currentNotificationIndex + 1
                notifications[currentNotificationIndex] = {}
                notifications[currentNotificationIndex].count = currentNotificationIndex
                notifications[currentNotificationIndex].job_table = notificationData.job_table
                notifications[currentNotificationIndex].responding = 0
                notifications[currentNotificationIndex].responding_state = false
                notifications[currentNotificationIndex].coords = {
                    x = RoundDec(notificationData.coords.x),
                    y = RoundDec(notificationData.coords.y),
                    z = RoundDec(notificationData.coords.z)
                }
                notifications[currentNotificationIndex].title = notificationData.title
                notifications[currentNotificationIndex].message = notificationData.message
                notifications[currentNotificationIndex].flash = notificationData.flash
                notifications[currentNotificationIndex].unique_id = notificationData.unique_id
                notifications[currentNotificationIndex].distance = math.ceil(#(vector3(notificationData.coords.x, notificationData.coords.y, notificationData.coords.z) - GetEntityCoords(PlayerPedId())))
                
                SendNUIMessage({
                    action = "AddNotification",
                    count = currentNotificationIndex,
                    job = notifications[currentNotificationIndex].job,
                    responding = notifications[currentNotificationIndex].responding,
                    flash = notifications[currentNotificationIndex].flash,
                    coords = notifications[currentNotificationIndex].coords,
                    title = notifications[currentNotificationIndex].title,
                    message = notifications[currentNotificationIndex].message,
                    unique_id = notifications[currentNotificationIndex].unique_id,
                    distance = notifications[currentNotificationIndex].distance,
                    dispatcher_table = notificationData
                })
                
                if Config.Debug then
                    print("DEBUG: Notification added to UI: " .. notifications[currentNotificationIndex].unique_id)
                end
                
                if notificationData.blip then
                    if type(notificationData.blip.radius) == "number" then
                        if notificationData.blip.radius > 0 then
                            local randomSignX = math.random(1, 2)
                            if randomSignX == 1 then
                                notifications[currentNotificationIndex].coords.x = notifications[currentNotificationIndex].coords.x + math.random(1, notificationData.blip.radius)
                            else
                                notifications[currentNotificationIndex].coords.x = notifications[currentNotificationIndex].coords.x - math.random(1, notificationData.blip.radius)
                            end
                            local randomSignY = math.random(1, 2)
                            if randomSignY == 1 then
                                notifications[currentNotificationIndex].coords.y = notifications[currentNotificationIndex].coords.y + math.random(1, notificationData.blip.radius)
                            else
                                notifications[currentNotificationIndex].coords.y = notifications[currentNotificationIndex].coords.y - math.random(1, notificationData.blip.radius)
                            end
                        end
                    end
                end
                
                if notificationData.blip then
                    if notificationData.blip.sound ~= nil then
                        Checks("blip_sound", notificationData.blip.sound)
                    end
                else
                    if notificationData.sound ~= nil then
                        Checks("blip_sound", notificationData.sound)
                    end
                end
                

                if notificationData.blip then
                    local blip = AddBlipForCoord(notifications[currentNotificationIndex].coords.x, notifications[currentNotificationIndex].coords.y, notifications[currentNotificationIndex].coords.z)
                    SetBlipSprite(blip, notificationData.blip.sprite)
                    SetBlipScale(blip, notificationData.blip.scale)
                    SetBlipColour(blip, notificationData.blip.colour)
                    if notificationData.blip.flashes then
                        SetBlipFlashes(blip, true)
                    end
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(notificationData.blip.text)
                    EndTextCommandSetBlipName(blip)
                    
                    local radiusBlip = nil
                    if type(notificationData.blip.radius) == "number" then
                        if notificationData.blip.radius > 0 then
                            radiusBlip = AddBlipForRadius(notifications[currentNotificationIndex].coords.x, notifications[currentNotificationIndex].coords.y, notifications[currentNotificationIndex].coords.z, notificationData.blip.radius + 0.0)
                            SetBlipColour(radiusBlip, notificationData.blip.colour)
                        end
                    end
                    
                    notifications[currentNotificationIndex].blip = blip
                    notifications[currentNotificationIndex].radius_blip = radiusBlip
                    
                    local blipTime = notificationData.blip.time
                    local blipTimeStrLength = #tostring(notificationData.blip.time)
                    if blipTimeStrLength > 4 then
                        blipTime = notificationData.blip.time * 0.1
                    else
                        if blipTimeStrLength <= 4 then
                            blipTime = notificationData.blip.time * 60 * 1000 * 0.1
                        end
                    end
                    
                    local opacity = 255
                    local interval = blipTime
                    SetBlipAlpha(blip, opacity)
                    if radiusBlip then
                        SetBlipAlpha(radiusBlip, opacity)
                    end
                    
                    while opacity ~= 0 do
                        Wait(interval)
                        opacity = opacity - 1
                        SetBlipAlpha(blip, opacity)
                        if radiusBlip then
                            SetBlipAlpha(radiusBlip, opacity)
                        end
                        if opacity == 0 then
                            if DoesBlipExist(blip) then
                                RemoveBlip(blip)
                            end
                            if DoesBlipExist(radiusBlip) then
                                RemoveBlip(radiusBlip)
                            end
                            break
                        end
                    end
                end
            else
                if Config.Debug then
                    print("DEBUG: No job access for notification")
                end
            end
        else
            E("5414")
        end
    else
        E("1466")
    end
end)
RegisterNetEvent("cd_dispatch:PlayerResponding")
AddEventHandler("cd_dispatch:PlayerResponding", function(responseData)
    if T(responseData, "table") then
        if T(responseData.unique_id, "string") then
            if notifications then
                local notificationIndex = FindUniqueID(responseData.unique_id)
                if notificationIndex then
                    if responseData.action == "add" then
                        notifications[notificationIndex].responding = responseData.responding + 1
                        SendNUIMessage({
                            action = "add_responding",
                            unique_id = responseData.unique_id,
                            SourceName = responseData.char_info.char_name,
                            SourceCallsign = responseData.char_info.callsign,
                            source = responseData.char_info.source
                        })
                    else
                        if responseData.action == "remove" then
                            notifications[notificationIndex].responding = responseData.responding - 1
                            SendNUIMessage({
                                action = "remove_responding",
                                unique_id = responseData.unique_id,
                                SourceName = responseData.char_info.char_name,
                                SourceCallsign = responseData.char_info.callsign,
                                source = responseData.char_info.source
                            })
                        end
                    end
                end
            end
        end
    else
        E("0231")
    end
end)
RegisterNetEvent("cd_dispatch:StopSpammings")
AddEventHandler("cd_dispatch:StopSpammings", function()
    Wait(500)
    isRespondingOnCooldown = false
end)
RegisterNetEvent("cd_dispatch:GetNonOnesyncCoords")
AddEventHandler("cd_dispatch:GetNonOnesyncCoords", function()
    TriggerServerEvent("cd_dispatch:GetNonOnesyncCoords", GetEntityCoords(PlayerPedId()))
end)
RegisterNetEvent("cd_dispatch:SetGPS")
AddEventHandler("cd_dispatch:SetGPS", function(coords)
    SetNewWaypoint(coords.x, coords.y)
end)
RegisterNetEvent("cd_dispatch:DispatcherToggle")
AddEventHandler("cd_dispatch:DispatcherToggle", function(state)
    if T(state, "boolean") then
        isDispatcher = state
    else
        E("8845")
    end
end)
RegisterNetEvent("cd_dispatch:UpdateGroups")
AddEventHandler("cd_dispatch:UpdateGroups", function(groups)
    SendNUIMessage({
        action = "updategroups",
        values = groups
    })
end)
RegisterNetEvent("cd_dispatch:SyncUserSettings")
AddEventHandler("cd_dispatch:SyncUserSettings", function(settings)
    SendNUIMessage({
        action = "syncusersettings",
        values = settings
    })
    if Config.PauseMenuBlips.blip_type == "auto" then
        auto_vehicle_blip.last = settings.vehicle
    end
end)
function Responding(notificationIndex, action)
    if T(notificationIndex, "number") then
        if T(action, "string") then
            if notifications then
                if notifications[notificationIndex] then
                    local responseData = {}
                    responseData.action = action
                    responseData.job_table = notifications[notificationIndex].job_table
                    responseData.responding = notifications[notificationIndex].responding
                    responseData.unique_id = notifications[notificationIndex].unique_id
                    responseData.char_info = SourceInfo
                    if action == "add" then
                        notifications[notificationIndex].responding_state = true
                        SetNewWaypoint(notifications[notificationIndex].coords.x, notifications[notificationIndex].coords.y)
                        TriggerServerEvent("cd_dispatch:PlayerResponding", responseData)
                    elseif action == "remove" then
                        notifications[notificationIndex].responding_state = false
                        SetWaypointOff()
                        TriggerServerEvent("cd_dispatch:PlayerResponding", responseData)
                    else
                        E("6544")
                    end
                end
            else
                E("3332")
            end
        end
    else
        E("8866")
    end
end
function HideLargeUI()
    uiStates.large = false
    NUI_status = false
    ShowSmallUI()
    TabletAnimation(false)
    FreezeEntityPosition(PlayerPedId(), false)
end
function ShowSmallUI()
    uiStates.small = true
    SendNUIMessage({
        action = GetNUIState(uiStates.small)
    })
end
function HideSmallUI()
    uiStates.small = false
    SendNUIMessage({
        action = GetNUIState(uiStates.small)
    })
end
function GetTime()
    local hour = GetClockHours()
    if hour > 6 and hour < 22 then
        return "day"
    else
        return "night"
    end
end
function GetNUIState(isVisible)
    if T(isVisible, "boolean") then
        if isVisible then
            return "show_small"
        else
            return "hide_small"
        end
    else
        E("6146")
    end
end
function Increasecount()
    if uiStates.small then
        if notifications then
            if currentNotificationIndex then
                if notifications[currentNotificationIndex] then
                    if #notifications == 0 then
                        return
                    end
                    currentNotificationIndex = currentNotificationIndex + 1
                    if currentNotificationIndex > #notifications then
                        currentNotificationIndex = 1
                    end
                    while true do
                        if notifications[currentNotificationIndex] ~= nil then
                            break
                        end
                        Wait(0)
                        currentNotificationIndex = currentNotificationIndex + 1
                        if currentNotificationIndex > #notifications then
                            currentNotificationIndex = 1
                        end
                    end
                    SendNUIMessage({
                        action = "move_right"
                    })
                end
            end
        else
            E("3516")
        end
    end
end
function Decreasecount()
    if uiStates.small then
        if notifications then
            if currentNotificationIndex then
                if notifications[currentNotificationIndex] then
                    if #notifications == 0 then
                        return
                    end
                    currentNotificationIndex = currentNotificationIndex - 1
                    if currentNotificationIndex < 1 then
                        currentNotificationIndex = #notifications
                    end
                    while true do
                        if notifications[currentNotificationIndex] ~= nil then
                            break
                        end
                        Wait(0)
                        currentNotificationIndex = currentNotificationIndex - 1
                        if currentNotificationIndex < 1 then
                            currentNotificationIndex = #notifications
                        end
                    end
                    SendNUIMessage({
                        action = "move_left"
                    })
                end
            end
        else
            E("7655")
        end
    end
end
function RoundDec(value)
    if T(value, "number") then
        return math.floor(value * math.pow(10, 2) + 0.5) / 100
    else
        E("6844")
    end
end
function DispatchSound(soundType)
    if T(soundType, "string") then
        SendNUIMessage({
            action = "playsound",
            type = soundType
        })
    else
        E("4564")
    end
end
function FindUniqueID(uniqueID)
    for _, notification in pairs(notifications) do
        if notification.unique_id == uniqueID then
            return notification.count
        end
    end
end
RegisterNUICallback("hidelarge_ui", function()
    HideLargeUI()
end)
RegisterNUICallback("deletesingle_alert", function(data)
    if T(data, "table") then
        data.count = tonumber(data.count)
        if notifications then
            if notifications[data.count] then
                if DoesBlipExist(notifications[data.count].blip) then
                    RemoveBlip(notifications[data.count].blip)
                end
                if DoesBlipExist(notifications[data.count].radius_blip) then
                    RemoveBlip(notifications[data.count].radius_blip)
                end
                notifications[data.count] = nil
                currentNotificationIndex = #notifications
            end
        else
            E("3651")
        end
    else
        E("7796")
    end
end)
RegisterNUICallback("deleteall_alerts", function()
    if T(notifications, "table") then
        for _, notification in pairs(notifications) do
            if DoesBlipExist(notification.blip) then
                RemoveBlip(notification.blip)
            end
            if DoesBlipExist(notification.radius_blip) then
                RemoveBlip(notification.radius_blip)
            end
        end
        notifications = {}
        currentNotificationIndex = 0
        notifications[currentNotificationIndex] = {}
    else
        E("9989")
    end
end)
RegisterNUICallback("add_responding", function(data)
    if T(data, "table") then
        Responding(data.count, "add")
    else
        E("9846")
    end
end)
RegisterNUICallback("remove_responding", function(data)
    if T(data, "table") then
        Responding(data.count, "remove")
    else
        E("6958")
    end
end)
RegisterNUICallback("getglobalcoords", function(data)
    if T(data, "table") then
        SendNUIMessage({
            action = "updatecoords",
            coords = RunCallback(data.job, "update_ui_blips")
        })
    else
        E("9684")
    end
end)
RegisterNUICallback("moveend_smallui", function()
    NUI_status = false
end)
RegisterNUICallback("usersettings", function(settings)
    if T(settings, "table") then
        TriggerServerEvent("cd_dispatch:SaveUserSettings", settings)
        if Config.PauseMenuBlips.blip_type ~= "auto" then
            return
        end
        if auto_vehicle_blip.forced.last ~= nil then
            if auto_vehicle_blip.forced.last then
                auto_vehicle_blip.last = auto_vehicle_blip.current
            end
        end
        auto_vehicle_blip.forced.current = settings.vehicle
    else
        E("6123")
    end
end)
RegisterNUICallback("togglevoice", function(data)
    if T(data, "table") then
        if data.enabled then
            NUI_status = false
            Wait(100)
            Checks("enable_nui_2")
            FreezeEntityPosition(PlayerPedId(), true)
        else
            NUI_status = false
            Wait(100)
            Checks("enable_nui")
            FreezeEntityPosition(PlayerPedId(), false)
        end
    else
        E("2233")
    end
end)
RegisterNUICallback("changechannel", function(data)
    if T(data, "table") then
        if data.channel then
            if data.channel > 0 then
                Checks("change_radio", data.channel)
            end
        else
            if data.channel == 0 then
                Checks("leave_radio")
            end
        end
    else
        E("2315")
    end
end)
RegisterNUICallback("setgps", function(data)
    if T(data, "table") then
        if Config.UsingOneSync then
            TriggerServerEvent("cd_dispatch:SetGPS", data.id)
        else
            local targetCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(data.id)))
            SetNewWaypoint(targetCoords.x, targetCoords.y)
        end
    else
        E("2315")
    end
end)
RegisterNUICallback("dispatchertoggle", function(data)
    if T(data, "table") then
        local job = Checks("get_job")
        if T(job, "string") then
            SourceInfo.dispatcher = true
            TriggerServerEvent("cd_dispatch:DispatcherToggle", data.state, job)
        else
            E("3354")
        end
    else
        E("6654")
    end
end)
RegisterNUICallback("assigncall", function(data)
    if T(data, "table") then
        TriggerServerEvent("cd_dispatch:Dispatcher_AddCall", data.notification)
    else
        E("1544")
    end
end)
RegisterNUICallback("updategroups", function(data)
    if T(data, "table") then
        TriggerServerEvent("cd_dispatch:UpdateGroups", data)
    else
        E("7844")
    end
end)
CreateThread(function()
    while true do
        if isDispatcherOffline ~= false then
            break
        end
        Wait(1000)
    end
    SendNUIMessage({
        gunshots = "cd_dispatch:Sendplayername",
        values = Config.Debug
    })
    isDispatcherOffline = nil
end)
function E(errorCode)
    print("^1[error_code-" .. errorCode .. "]")
end
function E2(errorMessage)
    print("^1[Codesign ErrorHandler] - " .. errorMessage)
end
function T(value, expectedType)
    local actualType = type(value)
    if actualType == expectedType then
        return true
    else
        E2(string.format("%s expected, got %s : %s", expectedType, actualType, value))
        return false
    end
end
function Notif(notificationType, messageKey, ...)
    if T(notificationType, "number") then
        if T(messageKey, "string") then
            if Locales[Config.Language] then
                if Locales[Config.Language][messageKey] then
                    local formattedMessage = string.format(Locales[Config.Language][messageKey], ...)
                    if notificationType == 1 or notificationType == 2 or notificationType == 3 then
                        local success, err = xpcall(function()
                            Notification(notificationType, formattedMessage)
                        end, E2)
                        if not success then
                            E("98676 ^")
                        end
                    end
                end
            else
                E("8814")
            end
        end
    else
        E("3016")
    end
end
function Checks(action, param1, param2)
    if action == "blip_sound" then
        local success, err = xpcall(function()
            BlipSound(param1)
        end, E2)
        if not success then
            E("5554 ^")
        end
    elseif action == "is_allowed" then
        local result
        local success, err = xpcall(function()
            result = IsAllowed()
        end, E2)
        if success then
            return result
        else
            E("8876 ^")
        end
    elseif action == "get_job" then
        local result
        local success, err = xpcall(function()
            result = GetJob()
        end, E2)
        if success then
            return result
        else
            E("7784 ^")
        end
    elseif action == "enable_nui" then
        local success, err = xpcall(function()
            TriggerEvent("cd_dispatch:ToggleNUIFocus")
        end, E2)
        if not success then
            E("5146 ^")
        end
    elseif action == "enable_nui_2" then
        local success, err = xpcall(function()
            TriggerEvent("cd_dispatch:ToggleNUIFocus_2")
        end, E2)
        if not success then
            E("1555 ^")
        end
    elseif action == "is_dispatcher" then
        local result
        local success, err = xpcall(function()
            result = IsDispatcher()
        end, E2)
        if success then
            return result
        else
            E("8742 ^")
        end
    elseif action == "check_job" then
        local result
        local success, err = xpcall(function()
            result = CheckJob(param1)
        end, E2)
        if success then
            return result
        else
            E("6645 ^")
        end
    elseif action == "change_radio" then
        local success, err = xpcall(function()
            ChangeRadio(param1)
        end, E2)
        if not success then
            E("7765 ^")
        end
    elseif action == "leave_radio" then
        local success, err = xpcall(function()
            LeaveRadio()
        end, E2)
        if not success then
            E("4567 ^")
        end
    end
end