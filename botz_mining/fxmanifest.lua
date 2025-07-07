

fx_version 'cerulean'
games { 'gta5' }
lua54 "yes"

client_scripts {
    'config.lua',
    'client/client_smelt.lua',
    'client/client_wash.lua',
    'client/client.lua',
}

server_scripts {
    'config.lua',
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}


ui_page 'nui/index.html'

files {
    'nui/index.html',
}