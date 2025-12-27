fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}

file 'config.lua'