function SendRobberyAlert(data)
    if not Config.RobberyAlerts or Config.RobberyAlerts.ENABLE ~= true then
        return false, 'disabled'
    end
    if type(data) ~= 'table' or type(data.kind) ~= 'string' then
        return false, 'invalid_payload'
    end

    local profile = Config.RobberyAlerts.TYPES and Config.RobberyAlerts.TYPES[data.kind]
    if type(profile) ~= 'table' then
        return false, 'unknown_robbery_type'
    end
    if type(profile.title) ~= 'string' or profile.title == ''
        or type(profile.description) ~= 'string' or profile.description == '' then
        return false, 'invalid_text'
    end
    if type(data.unique_id) ~= 'string' or not data.unique_id:match('^[%w_:%-%.]+$') then
        return false, 'invalid_payload'
    end

    local location = type(data.location) == 'string' and data.location:match('^%s*(.-)%s*$') or ''
    if location == '' then
        return false, 'invalid_text'
    end

    local routing = Config.Dispatcher and Config.Dispatcher.AlertRouting
    local policeJobs = routing and routing.police
    if type(policeJobs) ~= 'table' then
        return false, 'invalid_routing'
    end

    local blip = Config.RobberyAlerts.BLIP or {}
    return SendAlert({
        category = 'police',
        jobs = policeJobs,
        observer_jobs = {},
        coords = data.coords,
        title = profile.title,
        message = ('%s em %s.'):format(profile.description, location),
        unique_id = data.unique_id,
        flash = Config.RobberyAlerts.FLASH == true,
        sound = Config.RobberyAlerts.SOUND or 0,
        blip = {
            sprite = blip.sprite,
            scale = blip.scale,
            colour = blip.colour,
            time = blip.time,
            text = profile.title,
        },
    })
end
