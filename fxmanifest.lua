fx_version 'cerulean'
game 'rdr3'
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Libra Community'
description 'RSG Core Postman Job (ox_lib notifications)'
version '3.2.0'

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',   -- before client.lua
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'ox_target'
}
