# open.mp Custom Skins

A simple custom character skin system for **open.mp gamemodes** using the built-in artwork/model system.

This allows you to add custom `.dff` and `.txd` character models to your gamemode so players can automatically download and cache them when they join your server.

## Features

* Custom player character models
* `.dff` + `.txd` support
* Automatic client downloads through open.mp artwork
* Local caching on the player's client
* Works directly inside your gamemode
* No external client modification required
* Simple `AddCharModel()` registration
* Works with existing `SetPlayerSkin()` logic

---

## Requirements

* [open.mp](https://open.mp/) server
* open.mp-compatible Pawn compiler
* Valid GTA San Andreas character `.dff` and `.txd` files

---

## Installation

### 1. Add your model files

Place your custom character files inside the server's `models` folder.

Example:

```text
server/
├── config.json
├── gamemodes/
│   └── mygamemode.amx
└── models/
    ├── police01.dff
    ├── police01.txd
    ├── medic01.dff
    └── medic01.txd
```

The `.dff` and `.txd` filenames must match the names you register in the gamemode.

---

## 2. Enable artwork

Open your `config.json`.

Make sure this is enabled:

```json
"artwork": {
    "enable": true,
    "models_path": "models",
    "port": 7777
}
```

If your server already has artwork enabled, you don't need to change anything.

---

## 3. Register your custom models

Open your main gamemode source:

```text
gamemodes/mygamemode.pwn
```

Add your custom model IDs near your other definitions:

```pawn
#define SKIN_POLICE 20001
#define SKIN_MEDIC  20002
```

Then register the models inside `OnGameModeInit()`:

```pawn
public OnGameModeInit()
{
    AddCharModel(305, SKIN_POLICE, "police01.dff", "police01.txd");
    AddCharModel(274, SKIN_MEDIC, "medic01.dff", "medic01.txd");

    return 1;
}
```

### What is `AddCharModel()`?

```pawn
AddCharModel(baseid, newid, dffname, txdname);
```

Example:

```pawn
AddCharModel(305, 20001, "police01.dff", "police01.txd");
```

| Parameter | Description                          |
| --------- | ------------------------------------ |
| `baseid`  | GTA character model used as the base |
| `newid`   | Your custom model ID                 |
| `dffname` | Custom `.dff` filename               |
| `txdname` | Custom `.txd` filename               |

Use a custom model ID in the range supported by open.mp.

---

## 4. Give the custom skin to a player

After registering the model, use the custom ID with `SetPlayerSkin()`.

Example:

```pawn
SetPlayerSkin(playerid, SKIN_POLICE);
```

For example, inside `OnPlayerSpawn()`:

```pawn
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, SKIN_POLICE);

    return 1;
}
```

The player will now use the custom police model.

---

# How the download system works

You don't need to manually send the `.dff` or `.txd` files to players.

open.mp handles the artwork download process.

```text
              PLAYER JOINS
                   |
                   v
          Server advertises model
                   |
                   v
          Client checks local cache
              /          \
             /            \
        Already exists    Missing
             |              |
             v              v
        Load model       Download
                            |
                            v
                       Cache locally
                            |
                            v
                         Load model
```

The first time a player joins, the required files are downloaded.

On later connections, the client can use the cached files instead of downloading them again.

---

# Multiple custom skins

You can register as many custom character models as your server needs.

Example:

```pawn
#define SKIN_POLICE     20001
#define SKIN_MEDIC      20002
#define SKIN_SECURITY   20003
#define SKIN_MECHANIC   20004
#define SKIN_GANG       20005

public OnGameModeInit()
{
    AddCharModel(305, SKIN_POLICE,
        "police01.dff", "police01.txd");

    AddCharModel(274, SKIN_MEDIC,
        "medic01.dff", "medic01.txd");

    AddCharModel(280, SKIN_SECURITY,
        "security01.dff", "security01.txd");

    AddCharModel(50, SKIN_MECHANIC,
        "mechanic01.dff", "mechanic01.txd");

    AddCharModel(105, SKIN_GANG,
        "gang01.dff", "gang01.txd");

    return 1;
}
```

Then:

```pawn
SetPlayerSkin(playerid, SKIN_POLICE);
```

or:

```pawn
SetPlayerSkin(playerid, SKIN_MEDIC);
```

---

# Using it with factions

You can assign different models depending on the player's faction.

Example:

```pawn
if(PlayerInfo[playerid][pFaction] == FACTION_POLICE)
{
    SetPlayerSkin(playerid, SKIN_POLICE);
}
```

Another faction:

```pawn
if(PlayerInfo[playerid][pFaction] == FACTION_MEDIC)
{
    SetPlayerSkin(playerid, SKIN_MEDIC);
}
```

This means your existing faction/roleplay systems can use custom models without needing a separate skin system.

---

# Important

## Model files

Do not include copyrighted GTA San Andreas models or other people's custom models in your repository unless you have permission to redistribute them.

Only use:

* Models you created yourself
* Models you have permission to redistribute
* Models whose license explicitly allows redistribution

## File names

Make sure the filenames match exactly.

For example:

```pawn
AddCharModel(305, 20001, "police01.dff", "police01.txd");
```

requires:

```text
models/
├── police01.dff
└── police01.txd
```

## Port

Your artwork server must be reachable by players.

If your server uses:

```text
7777
```

make sure the required port is available through your hosting/firewall configuration.

---

# Example Complete Setup

### Server

```text
my-server/
│
├── config.json
│
├── gamemodes/
│   ├── mygamemode.pwn
│   └── mygamemode.amx
│
└── models/
    ├── police01.dff
    ├── police01.txd
    ├── medic01.dff
    └── medic01.txd
```

### config.json

```json
"artwork": {
    "enable": true,
    "models_path": "models",
    "port": 7777
}
```

### Gamemode

```pawn
#define SKIN_POLICE 20001
#define SKIN_MEDIC  20002

public OnGameModeInit()
{
    AddCharModel(305, SKIN_POLICE,
        "police01.dff", "police01.txd");

    AddCharModel(274, SKIN_MEDIC,
        "medic01.dff", "medic01.txd");

    return 1;
}
```

### Assign the skin

```pawn
SetPlayerSkin(playerid, SKIN_POLICE);
```

That's it.

The custom model is registered by the gamemode, open.mp handles the artwork download, and the client caches the required files locally.

---

## License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE) for the complete license text.

## Credits

Built for the **open.mp** community.
