local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- Player chat cooldowns
local ChatCooldowns = {}

-- Get player name
local function GetPlayerName(source)
    local player = RSGCore.Functions.GetPlayer(source)
    if player then
        return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    end
    return 'Unknown'
end

-- Get player job
local function GetPlayerJob(source)
    local player = RSGCore.Functions.GetPlayer(source)
    if player then
        return player.PlayerData.job.name
    end
    return 'civilian'
end

-- Check if player is admin
local function IsPlayerAdmin(source)
    -- Check using IsPlayerAceAllowed (RedM ACL system)
    if IsPlayerAceAllowed(source, 'command.admin') then
        return true
    end
    
    -- Fallback to group check
    local player = RSGCore.Functions.GetPlayer(source)
    if player then
        for _, group in ipairs(Config.AdminGroups) do
            if player.PlayerData.group == group then
                return true
            end
        end
    end
    return false
end

-- Check rate limit
local function IsOnCooldown(source)
    if not ChatCooldowns[source] then
        ChatCooldowns[source] = 0
    end
    
    if GetGameTimer() - ChatCooldowns[source] < Config.RateLimit then
        return true
    end
    
    ChatCooldowns[source] = GetGameTimer()
    return false
end

-- Filter message content
local function FilterMessage(message)
    local filtered = message
    
    for _, word in ipairs(Config.BlockedWords) do
        local replacement = string.rep('*', #word)
        filtered = string.gsub(filtered, word, replacement, nil)
    end
    
    return filtered
end

-- Get nearby players
local function GetNearbyPlayers(source, distance)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local players = {}
    
    for _, player in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(coords - playerCoords)
        
        if dist <= distance and player ~= tostring(source) then
            table.insert(players, tonumber(player))
        end
    end
    
    return players
end

-- Local chat
RegisterNetEvent('rex-chat:local', function(message)
    local source = source
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local playerName = GetPlayerName(source)
    
    local nearbyPlayers = GetNearbyPlayers(source, Config.ChatDistance)
    table.insert(nearbyPlayers, source)
    
    for _, player in ipairs(nearbyPlayers) do
        TriggerClientEvent('rex-chat:receiveLocal', player, playerName, message)
    end
end)

-- Whisper
RegisterNetEvent('rex-chat:whisper', function(targetId, message)
    local source = source
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    local targetPlayer = RSGCore.Functions.GetPlayer(tonumber(targetId))
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_player_not_found'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local senderName = GetPlayerName(source)
    local targetName = GetPlayerName(targetId)
    
    -- Send to sender
    TriggerClientEvent('rex-chat:receiveWhisper', source, targetName, message, 'sent')
    -- Send to recipient
    TriggerClientEvent('rex-chat:receiveWhisper', targetId, senderName, message, 'received')
end)

-- Shout
RegisterNetEvent('rex-chat:shout', function(message)
    local source = source
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local playerName = GetPlayerName(source)
    
    local nearbyPlayers = GetNearbyPlayers(source, Config.ShoutDistance)
    table.insert(nearbyPlayers, source)
    
    for _, player in ipairs(nearbyPlayers) do
        TriggerClientEvent('rex-chat:receiveShout', player, playerName, message)
    end
end)

-- Global OOC chat
RegisterNetEvent('rex-chat:ooc', function(message)
    local source = source
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local playerName = GetPlayerName(source)
    
    for _, player in ipairs(GetPlayers()) do
        TriggerClientEvent('rex-chat:receiveOOC', player, playerName, message)
    end
end)

-- Job chat
RegisterNetEvent('rex-chat:job', function(message)
    local source = source
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local playerName = GetPlayerName(source)
    local playerJob = GetPlayerJob(source)
    
    for _, player in ipairs(GetPlayers()) do
        local otherPlayer = RSGCore.Functions.GetPlayer(tonumber(player))
        if otherPlayer and otherPlayer.PlayerData.job.name == playerJob then
            TriggerClientEvent('rex-chat:receiveJob', player, playerName, playerJob, message)
        end
    end
end)

-- Admin chat
RegisterNetEvent('rex-chat:admin', function(message)
    local source = source
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_admin_needed'), type = 'error' })
        return
    end
    
    if IsOnCooldown(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_rate_limit'), type = 'error' })
        return
    end
    
    if #message < Config.MinMessageLength or #message > Config.MaxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = locale('chat_no_message'), type = 'error' })
        return
    end
    
    message = FilterMessage(message)
    local playerName = GetPlayerName(source)
    
    for _, player in ipairs(GetPlayers()) do
        if IsPlayerAdmin(tonumber(player)) then
            TriggerClientEvent('rex-chat:receiveAdmin', player, playerName, message)
        end
    end
end)

-- Execute whitelisted commands
RegisterNetEvent('rex-chat:executeCommand', function(command, args)
    local source = source
    
    -- Check if command is whitelisted
    if not Config.Whitelist[command] then
        TriggerClientEvent('rex-chat:receiveCommand', source, 'System', 'Command not found', 'error')
        return
    end
    
    -- Execute specific commands
    if command == 'cid' then
        local player = RSGCore.Functions.GetPlayer(source)
        if player then
            local citizenId = player.PlayerData.citizenid
            TriggerClientEvent('rex-chat:receiveCommand', source, 'System', 'Citizen ID: ' .. citizenId)
        end
    elseif command == 'id' then
        TriggerClientEvent('rex-chat:receiveCommand', source, 'System', 'Your Player ID: ' .. source)
    elseif command == 'cash' then
        local player = RSGCore.Functions.GetPlayer(source)
        if player then
            local cashAmount = player.PlayerData.money['cash']
            TriggerClientEvent('rex-chat:receiveCommand', source, 'System', 'You have: $' .. cashAmount)
        end
    else
        -- Add more custom commands here as needed
        TriggerClientEvent('ox_lib:notify', source, { title = 'Chat', description = 'Command not implemented yet', type = 'error' })
    end
end)

-- Clean up cooldown on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    ChatCooldowns[source] = nil
end)