local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- Chat messages history
local ChatHistory = {}
local MaxHistoryLines = 50

-- Add message to history
local function AddToHistory(sender, message, chatType)
    table.insert(ChatHistory, {
        sender = sender,
        message = message,
        type = chatType,
        timestamp = GetGameTimer()
    })
    
    if #ChatHistory > MaxHistoryLines then
        table.remove(ChatHistory, 1)
    end
end

-- Print colored message to chat
local function PrintChatMessage(name, message, color)
    local r, g, b = color.r / 255, color.g / 255, color.b / 255
    TriggerEvent('chat:addMessage', {
        args = { name, message },
        color = { r, g, b }
    })
end

-- Local chat receive
RegisterNetEvent('rex-chat:receiveLocal', function(playerName, message)
    AddToHistory(playerName, message, 'local')
    PrintChatMessage(playerName, message, Config.ChatColors.Local)
end)

-- Whisper receive
RegisterNetEvent('rex-chat:receiveWhisper', function(otherName, message, direction)
    AddToHistory(otherName, message, 'whisper')
    
    if direction == 'sent' then
        PrintChatMessage(locale('chat_cl_wisper_to') .. otherName, message, Config.ChatColors.Whisper)
    else
        PrintChatMessage(otherName .. locale('chat_cl_wispers'), message, Config.ChatColors.Whisper)
    end
end)

-- Shout receive
RegisterNetEvent('rex-chat:receiveShout', function(playerName, message)
    AddToHistory(playerName, message, 'shout')
    PrintChatMessage(playerName .. locale('chat_cl_shouts'), message, Config.ChatColors.Shout)
end)

-- OOC receive
RegisterNetEvent('rex-chat:receiveOOC', function(playerName, message)
    AddToHistory(playerName, message, 'ooc')
    PrintChatMessage('[OOC] ' .. playerName, message, Config.ChatColors.OOC)
end)

-- Job chat receive
RegisterNetEvent('rex-chat:receiveJob', function(playerName, jobName, message)
    AddToHistory(playerName, message, 'job')
    PrintChatMessage('[' .. jobName:upper() .. '] ' .. playerName, message, Config.ChatColors.Job)
end)

-- Admin chat receive
RegisterNetEvent('rex-chat:receiveAdmin', function(playerName, message)
    AddToHistory(playerName, message, 'admin')
    PrintChatMessage('[ADMIN] ' .. playerName, message, Config.ChatColors.Admin)
end)

-- Removed old command handlers - using UI system now
