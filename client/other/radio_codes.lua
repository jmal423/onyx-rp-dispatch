if Config.RadioCodes and Config.RadioCodes.ENABLE then
    RegisterNetEvent('onyx_dispatch:RadioCodeCooldown')
    AddEventHandler('onyx_dispatch:RadioCodeCooldown', function(seconds)
        if type(seconds) == 'number' then
            Notif(3, 'radio_code_cooldown', math.ceil(seconds))
        end
    end)

    local function SendRadioCode(code)
        -- Key mappings bind the number key; Alt is checked as a required modifier.
        if not IsControlPressed(0, 19) and not IsDisabledControlPressed(0, 19) then return end
        if not IsAllowed() then return end
        if code == '10-99-joint' then
            local job = GetJob()
            if job ~= 'police' and job ~= 'sheriff' then return end
        end

        local playerInfo = exports['onyx_dispatch']:GetPlayerInfo()
        local street = playerInfo and playerInfo.street or ''
        if type(street) ~= 'string' then street = '' end
        street = street:gsub('[%c<>"&]', ' '):sub(1, 100)

        TriggerServerEvent('onyx_dispatch:SendRadioCode', code, street)
    end

    local function RegisterRadioCode(code, binding, description)
        RegisterCommand(binding.command, function()
            SendRadioCode(code)
        end, false)
        RegisterKeyMapping(binding.command, L(description), 'keyboard', binding.key)
    end

    RegisterRadioCode('10-20', Config.RadioCodes.location, 'radio_code_10_20_description')
    RegisterRadioCode('10-99', Config.RadioCodes.assistance, 'radio_code_10_99_description')
    RegisterRadioCode('10-99-joint', Config.RadioCodes.policeAssistance, 'radio_code_10_99_joint_description')
end
