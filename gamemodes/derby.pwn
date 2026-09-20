/*
    Neverending derby by Laronic, AmyrAhmady (iAmir) 2024
*/
#include <open.mp>

#define COLOR_WHITE                          (0xFFFFFFFF)
#define COLOR_RIGHTGRAY                      (0xAAAAAAFF)

#define COL_WHITE                            "{FFFFFF}"
#define COL_LIGHTGRAY                        "{AAAAAA}"

#define DERBY_MIN_Z                          (98.8186)
#define DERBY_VEHICLE_CHANGE_AFTER_X_MINUTES (10)

forward DerbyBoundsTimer();
forward DerbyChangeSpawnVehicleTimer();

enum E_DERBY_VEHICLE_DATA
{
    E_DERBY_VEHICLE_DATA_MODELID,
    E_DERBY_VEHICLE_DATA_NAME[17]
}

enum E_DERBY_SPECTATE_DATA
{
    Float:E_DERBY_SPECTATE_CAMERA_POS[3],
    Float:E_DERBY_SPECTATE_CAMER_LOOK_AT[3]
}

new const
    Float:gDerbyVehicleSpawnPos[][] =
    {
        // x        y          z         a
        {-286.0154, 2170.4055, 113.1998, 24.9575},
        {-282.2158, 2171.8750, 113.0660, 356.8835},
        {-277.9834, 2171.0759, 112.9337, 324.5068},
        {-275.2377, 2167.6433, 112.9016, 315.8257},
        {-282.1338, 2164.4744, 113.1198, 340.6168}
    },
    gDerbyVehicleData[][E_DERBY_VEHICLE_DATA] =
    {
        // modelid        name
        {423,             "Mr. Whoopee"},
        {424,             "BF Injection"},
        {431,             "Bus"},
        {470,             "Patriot"},
        {489,             "Rancher"},
        {494,             "Hotring Racer"},
        {495,             "Sandking"},
        {500,             "Mesa"},
        {504,             "Bloodring Banger"},
        {568,             "Bandito"},
        {573,             "Dune"}
    },
    Float:gDerbySpectateLocations[][E_DERBY_SPECTATE_DATA] =
    {
        //{x         y          z       }, {x          y          z       }
        {{-491.6039, 2507.6335, 192.6075}, {-490.9164, 2506.9109, 192.2130}},
        {{129.4124,  2392.3538, 208.0453}, {128.5621,  2391.8315, 207.6809}},
        {{59.2768,   2085.0254, 215.9476}, {58.7588,   2085.8782, 215.5232}},
        {{-388.2449, 2133.5051, 179.3613}, {-387.4951, 2134.1648, 178.9019}}
    }
;

new
    gDerbySpawnVehicleID = 495,

    gPlayerVehicleID[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...},
    gPlayerInternalClassID[MAX_PLAYERS char],
    gPlayerSpectateLocationIdx[MAX_PLAYERS char]
;

main()
{
    print("Gamemode");
    print("---------");
    print("  Neverending-derby by Laronic, AmyrAhmady (iAmir) 2024");
    print(" ");
}

public OnGameModeInit()
{
    SetGameModeText("Neverending Derby");
    EnableStuntBonusForAll(false);

    SetWeather(18);
    SetWorldTime(20);

    // Check if anyone is below DERBY_MIN_Z every 3 seconds
    SetTimer("DerbyBoundsTimer", (3 * 1000), true);

    // Change spawn vehicle every x minutes
    SetTimer("DerbyChangeSpawnVehicleTimer", (DERBY_VEHICLE_CHANGE_AFTER_X_MINUTES * 60000), true);

    AddPlayerClass(0, -279.9328, 2166.9966, 106.6839, 269.1425, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    AddPlayerClass(0, -279.9328, 2166.9966, 106.6839, 269.1425, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    AddPlayerClass(0, -279.9328, 2166.9966, 106.6839, 269.1425, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);

    CreateObject(18450, -138.88177, 2289.22510, 113.03210,   -0.90000, -9.22000, -20.04000);
    CreateObject(18450, -213.29880, 2316.17163, 101.34100,   -0.90000, -7.62000, -20.04000);
    CreateObject(18450, -29.21287, 2251.18701, 121.08775,   -0.90000, -1.50000, -17.64000);
    CreateObject(18450, -351.50629, 2360.31567, 108.56236,   1.96000, -4.48000, -0.36000);
    CreateObject(18450, -431.37790, 2360.92432, 105.44030,   1.96000, 0.00000, -0.36000);
    return true;
}

public OnPlayerRequestClass(playerid, classid)
{
    new direction = ((classid - gPlayerInternalClassID{playerid}) + 1) % 3 - 1;
    gPlayerInternalClassID{playerid} = classid;

    static total_spectate_locations = sizeof(gDerbySpectateLocations);
    gPlayerSpectateLocationIdx{playerid} = (gPlayerSpectateLocationIdx{playerid} + direction) % total_spectate_locations;

    SetPlayerCameraPos
    (
        playerid,
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMERA_POS][0],
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMERA_POS][1],
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMERA_POS][2]
    );
    SetPlayerCameraLookAt
    (
        playerid,
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMER_LOOK_AT][0],
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMER_LOOK_AT][1],
        gDerbySpectateLocations[ gPlayerSpectateLocationIdx{playerid} ][E_DERBY_SPECTATE_CAMER_LOOK_AT][2]
    );
    return true;
}

public OnPlayerConnect(playerid)
{
    new
        string[128],
        name[MAX_PLAYER_NAME + 1]
    ;
    GetPlayerName(playerid, name, sizeof(name));

    format(string, sizeof(string), COL_LIGHTGRAY"%s "COL_WHITE"has joined the neverending derby!", name);
    SendClientMessageToAll(COLOR_WHITE, string);
    return true;
}

public OnPlayerDisconnect(playerid, reason)
{
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);

    gPlayerSpectateLocationIdx{playerid} = 0;
    gPlayerInternalClassID{playerid} = 0;

    DestroyPlayerVehicle(playerid);
    return true;
}

public OnPlayerSpawn(playerid)
{
    // Loop through spawn positions to avoid vehicles being stacked on top of each other
    static
        vehicle_spawn_cycle = 0,
        total_vehicle_spawn_pos = sizeof(gDerbyVehicleSpawnPos)
    ;
    if(vehicle_spawn_cycle++ >= total_vehicle_spawn_pos - 1)
    {
        vehicle_spawn_cycle = 0;
    }
    gPlayerVehicleID[playerid] = AddStaticVehicleEx
    (
        gDerbySpawnVehicleID,
        gDerbyVehicleSpawnPos[vehicle_spawn_cycle][0],
        gDerbyVehicleSpawnPos[vehicle_spawn_cycle][1],
        gDerbyVehicleSpawnPos[vehicle_spawn_cycle][2],
        gDerbyVehicleSpawnPos[vehicle_spawn_cycle][3],
        random(128),
        random(128),
        -1,
        true //enable sirens - wee woo!
    );
    PutPlayerInVehicle(playerid, gPlayerVehicleID[playerid], 0);
    return true;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    DestroyPlayerVehicle(playerid);
    return true;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    // Put the player back in their vehicle if they decice to exit it
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
    {
        PutPlayerInVehicle(playerid, gPlayerVehicleID[playerid], 0);
    }
    return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp("/kill", cmdtext, true, 5) == 0)
    {
        SetPlayerHealth(playerid, -1.0);
    }
    else
    {
        SendClientMessage(playerid, COLOR_WHITE, "Unknown command - Available commands:");
        SendClientMessage(playerid, COLOR_WHITE, "/kill - Commit not living");
    }
    return 1;
}

public DerbyBoundsTimer()
{
    for(new i = 0, len = MAX_PLAYERS, Float:z; i <= len; i++)
    {
        if(!IsPlayerConnected(i))
        {
            continue;			
        }

        if(gPlayerVehicleID[i] == INVALID_VEHICLE_ID)
        {
            continue;
        }

        if(!GetPlayerPos(i, z, z, z)) // IsPlayerConnected (check if the player is valid) + get z pos
        {
            continue;
        }

        if(z > DERBY_MIN_Z)
        {
            continue;
        }

        SetVehicleHealth(gPlayerVehicleID[i], -1.0);
    }
    return true;
}

public DerbyChangeSpawnVehicleTimer()
{
    new
        string[64],
        rand = -1
    ;
    // Randomly select a new spawn vehicle, excluding the current one
    while(rand == -1 || gDerbySpawnVehicleID == gDerbyVehicleData[rand][E_DERBY_VEHICLE_DATA_MODELID])
    {
        rand = random(sizeof gDerbyVehicleData);
    }
    format(string, sizeof(string), "vehicle change!~n~%s", gDerbyVehicleData[rand][E_DERBY_VEHICLE_DATA_NAME]);
    GameTextForAll(string, 5000, 6);

    gDerbySpawnVehicleID = gDerbyVehicleData[rand][E_DERBY_VEHICLE_DATA_MODELID];
    return true;
}

DestroyPlayerVehicle(playerid)
{
    if(gPlayerVehicleID[playerid] == INVALID_VEHICLE_ID)
    {
        return false;
    }
    DestroyVehicle(gPlayerVehicleID[playerid]);

    gPlayerVehicleID[playerid] = INVALID_VEHICLE_ID;
    return true;
}
