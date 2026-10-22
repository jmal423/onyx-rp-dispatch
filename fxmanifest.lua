fx_version 'cerulean'
game 'gta5'
name 'onyx_dispatch'
author 'ONYX RP'
description 'ONYX RP emergency services dispatch'
version '4.3.4'
lua54 'yes'

shared_scripts {
    'configs/locales.lua',
    'configs/config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'configs/client_customise_me.lua',
    'client/**/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configs/server_customise_me.lua',
    'server/**/*.lua'
}

ui_page {
    'html/index.html'
}
files {
    'configs/locales_ui.js',
    'configs/config_ui.js',
    'html/index.html',
    'html/css/*.css',
    'html/images/*.png',
    'html/images/*.svg',
    'html/images/*.jpg',
    'html/**/*.js',
    'html/sound/*.wav'
}

exports {
    'GetPlayerInfo',
    'GetPlayerNotifications',
    'GetPlayersDispatchData',
    'GetConfig',
}

server_exports {
    'GetPlayersDispatchData',
    'GetConfig',
    'SendAlert',
    'SendRobberyAlert',
}


dependency 'ox_lib'
dependency 'oxmysql'
dependency '/server:4960'

escrow_ignore {
    'client/main/functions.lua',
    'client/other/*.lua',
    'configs/*.lua',
    'server/main/auto_sql_insert.lua',
    'server/other/*.lua'
}
dependency '/assetpacks'
