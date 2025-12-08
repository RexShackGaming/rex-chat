# rex-chat

A comprehensive chat system for RedM, featuring local chat, whisper, shout, and admin commands with configurable distances and message filtering.

## Features

- **Multiple Chat Types**: Local, Global, Whisper, Shout, Out-Of-Character (OOC), Job, and Admin chat
- **Configurable Distances**: Customize how far each chat type reaches
- **Message Filtering**: Block profanity and unwanted words
- **Color Customization**: RGB color support for each chat type
- **Rate Limiting**: Prevent spam with configurable message cooldowns
- **Admin System**: Admin-only commands with group-based permissions
- **Internationalization**: Multi-language support via locale files
- **Modern UI**: Interactive chat interface with HTML/CSS/JS frontend

## Requirements

- **RedM Server**
- **RSG Framework** (rsg-core)
- **ox_lib** - Utility library for RedM

## Installation

### Step 1: Ensure Dependencies Are Installed

Make sure your RedM server has the required dependencies:

1. Download [rsg-core](https://github.com/RexShack/rsg-core) and place it in your resources folder
2. Download [ox_lib](https://github.com/overextended/ox_lib) and place it in your resources folder

### Step 2: Install rex-chat

1. Download the rex-chat resource
2. Place the `rex-chat` folder into your server's `resources` folder
3. Add to your `server.cfg`:

```cfg
ensure ox_lib
ensure rsg-core
ensure rex-chat
```

### Step 3: Verify Installation

Start your server and check the console. You should see no errors related to rex-chat.

## Configuration

Edit `shared/config.lua` to customize the chat system:

### Chat Distances

```lua
ChatDistance = 100.0,      -- Distance for local chat
WhisperDistance = 5.0,     -- Distance for whisper
ShoutDistance = 200.0,     -- Distance for shout
```

### Message Settings

```lua
MaxMessageLength = 256,    -- Maximum characters per message
MinMessageLength = 1,      -- Minimum characters per message
RateLimit = 1000,          -- Milliseconds between messages (prevents spam)
```

### Chat Commands

```lua
Commands = {
    Global = { Prefix = '/', Enabled = true, RequireJob = false },
    Local = { Prefix = 'NONE', Enabled = true, RequireJob = false },
    Whisper = { Prefix = '/w', Enabled = true, RequireJob = false },
    Shout = { Prefix = '/s', Enabled = true, RequireJob = false },
    OOC = { Prefix = '/ooc', Enabled = true, RequireJob = false },
    Job = { Prefix = '/job', Enabled = true, RequireJob = true },
    Admin = { Prefix = '/a', Enabled = true, RequireAdmin = true },
}
```

### Chat Colors

Customize colors for each chat type using RGB values:

```lua
ChatColors = {
    Local = { r = 200, g = 200, b = 200 },
    Global = { r = 100, g = 155, b = 255 },
    Whisper = { r = 150, g = 150, b = 150 },
    Shout = { r = 255, g = 100, b = 100 },
    OOC = { r = 150, g = 200, b = 150 },
    Job = { r = 100, g = 255, b = 100 },
    Admin = { r = 255, g = 100, b = 255 },
    System = { r = 255, g = 255, b = 0 },
}
```

### Blocked Words

Add profanity or inappropriate words to the filter:

```lua
BlockedWords = {
    'badword1',
    'badword2',
}
```

### Admin Settings

```lua
AdminGroups = { 'admin', 'moderator' },  -- Groups that can use admin chat
```

## Usage

### Chat Commands

#### Local Chat (Default)
Simply type a message and press Enter. Only players within `ChatDistance` will see it.

#### Global Chat
```
/message
```
Sends a message visible to all players on the server.

#### Whisper
```
/w message
```
Sends a private message visible only to nearby players (within `WhisperDistance`).

#### Shout
```
/s message
```
Sends a message to players at `ShoutDistance` range (typically louder/further than local).

#### Out-Of-Character (OOC)
```
/ooc message
```
Send OOC messages for out-of-character communication.

#### Job Chat
```
/job message
```
Send messages to players with the same job (job chat permission required).

#### Admin Chat
```
/a message
```
Send messages visible only to admins (admin group membership required).

### Chat Interface

- Open chat with the default RedM chat key
- Type your message
- Use the appropriate command prefix for the chat type
- Press Enter to send

## File Structure

```
rex-chat/
├── fxmanifest.lua          -- Resource manifest
├── README.md               -- This file
├── shared/
│   └── config.lua          -- Configuration file
├── server/
│   └── server.lua          -- Server-side chat logic
├── client/
│   ├── client.lua          -- Client-side main logic
│   └── ui.lua              -- UI management
├── html/
│   ├── index.html          -- Chat UI template
│   ├── script.js           -- Chat UI JavaScript
│   └── style.css           -- Chat UI styling
└── locales/
    └── en.json             -- English locale strings
```

## Support

For issues, questions, or feature requests, join the Discord server:
https://discord.gg/YUV7ebzkqs

## License

Created by RexShackGaming

## Version

v2.0.0
