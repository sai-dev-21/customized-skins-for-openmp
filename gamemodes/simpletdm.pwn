/*
    Simple TDM
    By BrunoBM16, AmyrAhmady (iAmir)
*/

#define MIXED_SPELLINGS

#include <open.mp>

enum
{
    DIALOG_HELP,
    DIALOG_SHOP
}

enum E_TEAMS
{
    BLUE_TEAM,
    RED_TEAM
}

enum E_MAPS
{
    MAP_JEFFERSON,
    MAP_LVPD,
    MAP_STADIUM
}

new const Map_Interiors[] =
{
    15,
    3,
    14
};

new const Float:Spawn_Positions[][] = // X1, Y1 and Z1 are blue team spawn coords. The others are for red team.
{
    //X1              Y1                Z1               X2               Y2                Z2    
    {2192.8801269531, -1141.5604248047, 1031.9156494141, 2222.1796875012, -1149.0386962891, 1028.5592041016}, // Jefferson.
    {194.15101623535, 158.105789184571, 1004.4303588867, 284.68838500977, 172.746673583981, 1009.0396118164}, // LVPD.
    {-1350.687500143, 1591.87976074221, 1053.7849121094, -1494.388793945, 1564.86840820312, 1054.8217773438} // Stadium.
};

const BLUE_COLOUR = 0x0000BBAA;
const RED_COLOUR = 0xAA3333AA;

forward OnMapUpdate();

new
    Text:Map_Duration_TextDraw,
    Current_Map = _:MAP_JEFFERSON, 
    Map_Timer = 0, 
    Map_Duration = 300;

main()
{
    print("----------\nSimple TDM loaded.\n----------");
}

public OnGameModeInit()
{
    Map_Duration_TextDraw = TextDrawCreate(558.996826, 28.000167, "300");
    TextDrawLetterSize(Map_Duration_TextDraw, 0.400000, 1.600000);
    TextDrawAlignment(Map_Duration_TextDraw, TEXT_DRAW_ALIGN_LEFT);
    TextDrawColor(Map_Duration_TextDraw, -1);
    TextDrawSetShadow(Map_Duration_TextDraw, 0);
    TextDrawSetOutline(Map_Duration_TextDraw, 1);
    TextDrawBackgroundColor(Map_Duration_TextDraw, 255);
    TextDrawFont(Map_Duration_TextDraw, TEXT_DRAW_FONT_2);
    TextDrawSetProportional(Map_Duration_TextDraw, true);
    TextDrawSetShadow(Map_Duration_TextDraw, 0);
	
    SetGameModeText("Simple TDM");
    EnableStuntBonusForAll(false);
    UsePlayerPedAnims();
    SetWeather(0);
    SetWorldTime(12);
	
    AddPlayerClass(287, 2296.5663, 2451.6270, 10.8203, 87.8270, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
	
    Map_Timer = SetTimer("OnMapUpdate", 1000, true); //Map timer
    return true;
}

public OnGameModeExit()
{
    TextDrawDestroy(Map_Duration_TextDraw);
    KillTimer(Map_Timer);
    return true;
}

public OnMapUpdate()
{
    static Duration_String[4];
	
    if(Map_Duration != 0)
    {
        Map_Duration--;
        format(Duration_String, sizeof(Duration_String), "%i", Map_Duration);
        TextDrawSetString(Map_Duration_TextDraw, Duration_String);		
    }
    else
    {
	    if(Current_Map == _:MAP_STADIUM)
        {
            Current_Map = _:MAP_JEFFERSON;
        }
        else
        {
            Current_Map++;
        }
		
        Map_Duration = 300;
		
        for(new i = 0, j = MAX_PLAYERS; i <= j; i++)
        {
            if(IsPlayerConnected(i))
            {
                SetPlayerTeam(i, random(2));
                SpawnPlayer(i);
            }
        }
        SendClientMessageToAll(-1, "Starting a new map...");
    }
    return true;
}

public OnPlayerConnect(playerid)
{
    SetPlayerTeam(playerid, NO_TEAM);
    SendClientMessage(playerid, -1, "Welcome to Simple TDM.");
    TextDrawShowForPlayer(playerid, Map_Duration_TextDraw);
    return true;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 2296.5662, 2451.6270, 10.8202);
    SetPlayerFacingAngle(playerid, 87.8271);
    SetPlayerCameraPos(playerid, 2293.3640, 2451.7341, 12.8202);
    SetPlayerCameraLookAt(playerid, 2296.5662, 2451.6270, 10.8203);
    return true;
}

public OnPlayerSpawn(playerid)
{
    if(GetPlayerTeam(playerid) == NO_TEAM)
    {
        SetPlayerTeam(playerid, random(2));
    }
    
    GivePlayerWeapon(playerid, WEAPON_COLT45, 300);
    GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 250);
	
    SetPlayerInterior(playerid, Map_Interiors[Current_Map]);
	
    if(GetPlayerTeam(playerid) == _:BLUE_TEAM)
    {
        SetPlayerSkin(playerid, 285);
        SetPlayerColor(playerid, BLUE_COLOUR);
        SetPlayerPos(playerid, Spawn_Positions[Current_Map][0], Spawn_Positions[Current_Map][1], Spawn_Positions[Current_Map][2]);
    }
    else if(GetPlayerTeam(playerid) == _:RED_TEAM)
    {
        SetPlayerSkin(playerid, 287);
        SetPlayerColor(playerid, RED_COLOUR);
        SetPlayerPos(playerid, Spawn_Positions[Current_Map][3], Spawn_Positions[Current_Map][4], Spawn_Positions[Current_Map][5]);
    }
    return true;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    SendDeathMessage(killerid, playerid, reason);
	
    if(killerid != INVALID_PLAYER_ID)
    {
        GivePlayerMoney(killerid, 3500);
        SendClientMessage(playerid, -1, "You killed someone, you got $3500.");
    }
    return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!strcmp("/help", cmdtext))
    {
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "Commands", "/help - this very same dialog.\n/kill - suicide.\n/shop - weapon shop.", "Close", "");
    }
    else if(!strcmp("/kill", cmdtext))
    {
        SendClientMessage(playerid, -1, "You killed yourself.");
        SetPlayerHealth(playerid, 0.0);
    }
    else if(!strcmp("/shop", cmdtext))
    {
        ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "Weapon Shop", "Desert Eagle - $3000\nAK-47 - $4500\nM4 - $5000\nSniper Rifle - $6000", "Buy", "Cancel");
    }
    else
    {
        SendClientMessage(playerid, -1, "Invalid command.");
    }
    return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_SHOP)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerMoney(playerid) < 3000)
                    {
                        SendClientMessage(playerid, -1, "You don't have enough money to buy this weapon ($3000).");
                    }
                    else
                    {
                        GivePlayerWeapon(playerid, WEAPON_DEAGLE, 300);
                        GivePlayerMoney(playerid, -3000);
                    }					
                }
                case 1:
                {
                    if(GetPlayerMoney(playerid) < 4500)
                    {
                        SendClientMessage(playerid, -1, "You don't have enough money to buy this weapon ($4500).");
                    }
                    else
                    {
                        GivePlayerWeapon(playerid, WEAPON_AK47, 300);
                        GivePlayerMoney(playerid, -4500);
                    }
                }
                case 2:
                {
                    if(GetPlayerMoney(playerid) < 5000)
                    {
                        SendClientMessage(playerid, -1, "You don't have enough money to buy this weapon ($5000).");
                    }
                    else
                    {
                        GivePlayerWeapon(playerid, WEAPON_M4, 300);
                        GivePlayerMoney(playerid, -5000);
                    }
                }
                case 3:
                {
                    if(GetPlayerMoney(playerid) < 6000)
                    {
                        SendClientMessage(playerid, -1, "You don't have enough money to buy this weapon ($6000).");
                    }
                    else
                    {
                        GivePlayerWeapon(playerid, WEAPON_RIFLE, 90);
                        GivePlayerMoney(playerid, -6000);
                    }
                }				
            }
        }
    }
    return true;
}
