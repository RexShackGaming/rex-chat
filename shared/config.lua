Config = {
    -- Chat settings
    ChatDistance = 100.0, -- Distance for local chat
    WhisperDistance = 5.0, -- Distance for whisper
    ShoutDistance = 200.0, -- Distance for shout
    
    -- Message limits
    MaxMessageLength = 256,
    MinMessageLength = 1,
    RateLimit = 1000, -- Milliseconds between messages
    
    -- Chat commands (slash commands are routed to external message system)
    Commands = {
        Local = { Enabled = true, RequireJob = false },
        Whisper = { Enabled = true, RequireJob = false },
        Shout = { Enabled = true, RequireJob = false },
        OOC = { Enabled = true, RequireJob = false },
        Job = { Enabled = true, RequireJob = true },
        Admin = { Enabled = true, RequireJob = false, RequireAdmin = true },
    },
    
    -- Chat colors (RGB)
    ChatColors = {
        Local = { r = 200, g = 200, b = 200 },
        Global = { r = 100, g = 155, b = 255 },
        Whisper = { r = 150, g = 150, b = 150 },
        Shout = { r = 255, g = 100, b = 100 },
        OOC = { r = 150, g = 200, b = 150 },
        Job = { r = 100, g = 255, b = 100 },
        Admin = { r = 255, g = 100, b = 255 },
        System = { r = 255, g = 255, b = 0 },
    },
    
    -- Blocked words (add profanity as needed)
    BlockedWords = {
        -- Add blocked words here
    },
    
    -- Player groups that can use admin chat
    AdminGroups = { 'admin', 'moderator' },
    
    -- Command whitelist for chat command execution
    Whitelist = {
        id   = true,
        cid  = true,
        cash = true,
    },
}
