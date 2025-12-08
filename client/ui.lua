local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- UI State
local UIOpen = false
local CurrentChatType = 'local'
local ChatHistory = {}
local MessageQueue = {}
local SendingMessage = false

-- Constants
local CHAT_KEY = 0x9720FCEE -- T Key
local CLOSE_KEY = 0x156E0F17 -- ESC Key

-- Send message to NUI
local function SendReactMessage(action, data)
    data = data or {}
    SendNUIMessage({
        action = action,
        data = data
    })
end

-- Open chat UI
local function OpenChatUI()
    if UIOpen then return end
    
    UIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'chat:open' })
end

-- Close chat UI
local function CloseChatUI()
    if not UIOpen then return end
    
    UIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'chat:close' })
end

-- Add message to local history and display
local function DisplayMessage(sender, message, chatType)
    table.insert(ChatHistory, {
        sender = sender,
        message = message,
        chatType = chatType,
        timestamp = GetGameTimer()
    })
    
    -- Keep history manageable
    if #ChatHistory > 100 then
        table.remove(ChatHistory, 1)
    end
    
    -- Send to UI
    SendNUIMessage({
        type = 'chat:message',
        sender = sender,
        message = message,
        chatType = chatType
    })
end

-- Register NUI callbacks
RegisterNUICallback('sendMessage', function(data, cb)
    local message = data.message
    local chatType = data.chatType or 'local'
    
    if not message or message == '' then
        cb({ success = false, error = 'Empty message' })
        return
    end
    
    if string.len(message) > Config.MaxMessageLength then
        SendNUIMessage({
            type = 'chat:system',
            message = 'Message is too long!'
        })
        cb({ success = false, error = 'Message too long' })
        return
    end
    
    -- Handle slash commands in message
    if message:sub(1, 1) == '/' then
        local parts = {}
        for word in message:gmatch('%S+') do
            table.insert(parts, word)
        end
        
        local command = parts[1]:lower():sub(2) -- Remove the / prefix
        table.remove(parts, 1)
        local msgContent = table.concat(parts, ' ')
        
        -- Check if this is a whitelisted command
        local isWhitelisted = Config.Whitelist[command] == true
        
        if isWhitelisted then
            TriggerServerEvent('rex-chat:executeCommand', command, msgContent)
            cb({ success = true })
            return
        end
        
        -- Route to appropriate chat type commands
        if command == 's' or command == 'shout' then
            TriggerServerEvent('rex-chat:shout', msgContent)
        elseif command == 'ooc' then
            TriggerServerEvent('rex-chat:ooc', msgContent)
        elseif command == 'job' then
            TriggerServerEvent('rex-chat:job', msgContent)
        elseif command == 'a' or command == 'admin' then
            TriggerServerEvent('rex-chat:admin', msgContent)
        elseif command == 'w' or command == 'whisper' then
            local targetId = tonumber(parts[1])
            if targetId and #parts > 1 then
                table.remove(parts, 1)
                local whisperMsg = table.concat(parts, ' ')
                TriggerServerEvent('rex-chat:whisper', targetId, whisperMsg)
            else
                SendNUIMessage({
                    type = 'chat:system',
                    message = 'Usage: /w <player_id> <message>'
                })
                cb({ success = false, error = 'Invalid whisper command' })
                return
            end
        else
            -- Unknown command, send as local chat
            TriggerServerEvent('rex-chat:local', message)
        end
    else
        -- No slash command, send based on selected chat type
        if chatType == 'local' then
            TriggerServerEvent('rex-chat:local', message)
        elseif chatType == 'shout' then
            TriggerServerEvent('rex-chat:shout', message)
        elseif chatType == 'ooc' then
            TriggerServerEvent('rex-chat:ooc', message)
        elseif chatType == 'job' then
            TriggerServerEvent('rex-chat:job', message)
        elseif chatType == 'admin' then
            TriggerServerEvent('rex-chat:admin', message)
        elseif chatType == 'whisper' then
            local targetId = tonumber(data.targetId)
            if targetId then
                TriggerServerEvent('rex-chat:whisper', targetId, message)
            else
                cb({ success = false, error = 'Invalid whisper target' })
                return
            end
        else
            cb({ success = false, error = 'Invalid chat type' })
            return
        end
    end
    
    cb({ success = true })
end)

RegisterNUICallback('sendWhisper', function(data, cb)
    local targetId = tonumber(data.targetId)
    local message = data.message
    
    if not message or message == '' then
        cb({ success = false, error = 'Empty message' })
        return
    end
    
    if not targetId then
        cb({ success = false, error = 'Invalid target' })
        return
    end
    
    TriggerServerEvent('rex-chat:whisper', targetId, message)
    cb({ success = true })
end)

RegisterNUICallback('closeChat', function(data, cb)
    CloseChatUI()
    cb({ success = true })
end)

RegisterNUICallback('getChatHistory', function(data, cb)
    cb({ history = ChatHistory })
end)

-- Receive messages from server
RegisterNetEvent('rex-chat:receiveLocal', function(playerName, message)
    DisplayMessage(playerName, message, 'local')
end)

RegisterNetEvent('rex-chat:receiveWhisper', function(otherName, message, direction)
    if direction == 'sent' then
        DisplayMessage('Whisper to ' .. otherName, message, 'whisper')
    else
        DisplayMessage('Whisper from ' .. otherName, message, 'whisper')
    end
end)

RegisterNetEvent('rex-chat:receiveShout', function(playerName, message)
    DisplayMessage(playerName .. ' [SHOUT]', message, 'shout')
end)

RegisterNetEvent('rex-chat:receiveOOC', function(playerName, message)
    DisplayMessage('[OOC] ' .. playerName, message, 'ooc')
end)

RegisterNetEvent('rex-chat:receiveJob', function(playerName, jobName, message)
    DisplayMessage('[' .. jobName:upper() .. '] ' .. playerName, message, 'job')
end)

RegisterNetEvent('rex-chat:receiveAdmin', function(playerName, message)
    DisplayMessage('[ADMIN] ' .. playerName, message, 'admin')
end)

RegisterNetEvent('rex-chat:receiveCommand', function(sender, message)
    DisplayMessage(sender, message, 'system')
end)

-- Handle key press for opening chat and ESC to close
CreateThread(function()
    while true do
        Wait(0)
        
        if IsControlJustReleased(0, CHAT_KEY) then
            OpenChatUI()
        end
        
        if UIOpen and IsControlJustReleased(0, CLOSE_KEY) then
            CloseChatUI()
        end
    end
end)

-- Block game controls when UI is open
CreateThread(function()
    while true do
        Wait(0)
        
        if UIOpen then
            DisableControlAction(0, 0x9720FCEE, true) -- T key
            DisableControlAction(0, 0x156E0F17, true) -- ESC key
        end
    end
end)
