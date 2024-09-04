fx_version 'bodacious'
games { 'gta5' }
lua54 'yes'

escrow_ignore {'*.lua'}

shared_scripts { 
    '@ox_lib/init.lua',
    'config.lua'
}

client_script {'client.lua'}

server_script {'server.lua'}

dependency '/assetpacks'