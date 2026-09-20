# open.mp Custom Skins

A reusable custom skin system for [open.mp](https://open.mp/) servers, built as a standalone filterscript.

It allows server owners to register custom `.dff` and `.txd` character models and use them as player skins without modifying their existing gamemode.

## Features

* Standalone filterscript
* Works with existing open.mp gamemodes
* Custom `.dff` + `.txd` character models
* Automatic model downloading through open.mp artwork
* Client-side caching of downloaded models
* Custom skin IDs
* Easy skin registration
* No changes required to the main gamemode

## Requirements

* [open.mp Server](https://open.mp/)
* open.mp client
* A valid custom GTA San Andreas character model
* `.dff` and `.txd` files for the model

## Installation

### 1. Download the repository

Clone the repository or download it as a ZIP.

```bash
git clone https://github.com/YOUR_USERNAME/openmp-custom-skins.git
```

### 2. Copy the filterscript

Copy:

```text
customskins.pwn
```

into your server's:

```text
filterscripts/
```

Compile the filterscript using your open.mp Pawn compiler.

You should get:

```text
filterscripts/customskins.amx
```

### 3. Create the models folder

Your server should have:

```text
server/
├── config.json
├── filterscripts/
│   └── customskins.amx
└── models/
```

Place your custom character models inside the `models` folder.

Example:

```text
models/
├── police01.dff
├── police01.txd
├── medic01.dff
└── medic01.txd
```

### 4. Enable open.mp artwork

Open your `config.json`.

Make sure artwork is enabled:

```json
"artwork": {
    "enable": true,
    "models_path": "models",
    "port": 7777
}
```

If you are already using the default open.mp artwork configuration, you normally don't need to change anything.

### 5. Enable the filterscript

In `config.json`, find:

```json
"pawn": {
    "main_scripts": [
        "yourgamemode 1"
    ],
    "side_scripts": []
}
```

Add `customskins` to `side_scripts`:

```json
"pawn": {
    "main_scripts": [
        "yourgamemode 1"
    ],
    "side_scripts": [
        "customskins 1"
    ]
}
```

Your existing gamemode stays untouched.

## Registering a Custom Skin

Inside `customskins.pwn`, register your model using `AddCharModel`.

Example:

```pawn
#define SKIN_POLICE 20001

AddCharModel(
    305,
    SKIN_POLICE,
    "police01.dff",
    "police01.txd"
);
```

### Parameters

```text
AddCharModel(baseid, newid, dffname, txdname);
```

* `baseid` — GTA character model used as the base
* `newid` — custom model ID
* `dffname` — `.dff` model filename
* `txdname` — `.txd` texture filename

Use a custom model ID in the range supported by your open.mp version.

## Assigning a Custom Skin

Once the model has been registered, assign it to a player:

```pawn
SetPlayerSkin(playerid, SKIN_POLICE);
```

For example:

```pawn
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, SKIN_POLICE);
    return 1;
}
```

The player will then use the custom character model.

## How Downloads Work

When a player joins your server, open.mp checks whether the required custom model is available locally.

```text
Player joins
     |
     v
Server advertises custom models
     |
     v
Client checks local files
     |
     +---- Already cached ----> Load model
     |
     +---- Not cached --------> Download
                                  |
                                  v
                              Cache locally
                                  |
                                  v
                              Load model
```

Players don't need to manually download every model.

After a model has been downloaded, the client can use the cached resource on future connections.

## Example

Suppose your server has:

```text
models/
├── police01.dff
├── police01.txd
├── medic01.dff
└── medic01.txd
```

Register them:

```pawn
#define SKIN_POLICE 20001
#define SKIN_MEDIC  20002

public OnGameModeInit()
{
    AddCharModel(
        305,
        SKIN_POLICE,
        "police01.dff",
        "police01.txd"
    );

    AddCharModel(
        274,
        SKIN_MEDIC,
        "medic01.dff",
        "medic01.txd"
    );

    return 1;
}
```

Then assign them:

```pawn
SetPlayerSkin(playerid, SKIN_POLICE);
```

or:

```pawn
SetPlayerSkin(playerid, SKIN_MEDIC);
```

## Important

### Custom model files

This repository does **not** provide copyrighted GTA San Andreas character models.

Only use `.dff` and `.txd` files that you created yourself or have permission to redistribute.

### Model compatibility

Your custom character model needs to be compatible with GTA San Andreas character-model requirements and the animations/base model you are using.

### Server port

The artwork server needs to be reachable by clients.

If your game server uses:

```text
7777
```

and your artwork configuration also uses:

```json
"port": 7777
```

make sure your hosting/network configuration allows the required connection.

## Project Structure

```text
openmp-custom-skins/
│
├── customskins.pwn
├── include/
│   └── customskins.inc
├── models/
│   └── README.md
├── README.md
├── LICENSE
└── .gitignore
```

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for the complete license text.

## Contributing

Pull requests and improvements are welcome.

If you find a bug or have an idea for a new feature, open an issue or submit a pull request.

## Credits

Built for the open.mp community.

* open.mp — multiplayer framework
* GTA San Andreas — original game and model format
