fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'rex-chat'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua',
    'client/ui.lua'
}

ui_page 'html/index.html'

dependencies {
    'rsg-core',
    'ox_lib',
}

files {
  'locales/*.json',
  'html/index.html',
  'html/style.css',
  'html/script.js'
}

lua54 'yes'
