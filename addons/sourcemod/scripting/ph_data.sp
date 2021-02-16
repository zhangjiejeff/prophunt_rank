/* [CS:GO] PropHunt Data & Rank
 *
 *  Copyright (C) 2021 ZhangJie
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <colorvariables>

#pragma semicolon 1
#pragma newdecls required

#include "ph_data/variables.sp"
#include "ph_data/commands.sp"
#include "ph_data/database.sp"
#include "ph_data/events.sp"
#include "ph_data/natives.sp"

public Plugin myinfo =
{
	name = "[PH]Data",
	author = "ZhangJie",
	description = "Rank Specified for PropHunt Servers",
	version = "1.01",
	url = "https://www.github.com/1204601575"
};

public void OnPluginStart()
{
	// Connection to the database;
	SQL_TConnect(OnSQLConnect, "ph_data");
	
	// ConVars
	g_CVAR_PH_Data_StartPoints 	= CreateConVar("ph_data_startpoints", "100", "How many points that a new player starts", _, true, 0.0, false);
	g_CVAR_PH_Data_HideWin = CreateConVar("ph_data_hidewin", "3", "How many points you get when you hide and win a round (0 will disable it)", _, true, 0.0, false);
	g_CVAR_PH_Data_Catching = CreateConVar("ph_data_catching", "1", "How many points you get when you catch a person (0 will disable it)", _, true, 0.0, false);
	g_CVAR_PH_Data_MaxPlayers_Top = CreateConVar("ph_data_maxplayers_top", "10", "Max number of players that are shown in the top commands", _, true, 1.0, false);
	g_CVAR_PH_Data_MinPlayers = CreateConVar("ph_data_minplayers", "4", "Minimum players for activating the rank system (0 will disable this function)", _, true, 0.0, false);
	g_CVAR_PH_Data_Prefix = CreateConVar("ph_data_prefix", "[{purple}PH RANK{default}]", "Prefix to be used in every chat's plugin");
	g_CVAR_PH_Data_BeingCatched = CreateConVar("ph_data_beingcatched", "1", "How many points you lost if you got catched", _, true, 0.0, false);
	g_CVAR_PH_Data_Suicide = CreateConVar("ph_data_deathshooting", "1", "How many points you lost if you get killed by suicide", _, true, 0.0, false);
	g_CVAR_PH_Data_AllowWarmUp = CreateConVar("ph_data_allow_warmup", "0", "Allow players to get or lose points during Warmup", _, true, 0.0, true, 0.0);

	// Events
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("round_start",Event_RoundStart, EventHookMode_PostNoCopy);
	
	// Normal Commands
	RegConsoleCmd("sm_rank", Command_Rank, "Shows a player rank in the menu");
	RegConsoleCmd("sm_mystats", Command_MyStats, "Shows all the stats of a player");
	RegConsoleCmd("sm_top", Command_Top, "Shows the Top Players List, order by points");
	RegConsoleCmd("sm_tophide", Command_TopHideWinRound, "Show the Top Players List, order by Zombie Kills");
	RegConsoleCmd("sm_topcatch", Command_TopCatchNum, "Show the Top Players List, order by Infected Humans");
	RegConsoleCmd("sm_resetmyrank", Command_ResetMyRank, "It lets a player reset his rank all by himself");
	
	// Admin Commands
	RegAdminCmd("sm_resetrank_all", Command_ResetRank_All, ADMFLAG_ROOT, "Deletes all the players that are in the database");
	
	// Exec Config
	AutoExecConfig(true, "ph_data", "ph_data");
	
	// Translations
	LoadTranslations("ph_data.phrases");
	
	
	// Let's iniciate to 0, just to be sure;
	g_PH_Data_NumPlayers = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnConfigsExecuted()
{
	g_CVAR_PH_Data_Prefix.GetString(g_PH_Data_Prefix, sizeof(g_PH_Data_Prefix));
	g_PH_Data_HideWin = g_CVAR_PH_Data_HideWin.IntValue;
	g_PH_Data_Cathing = g_CVAR_PH_Data_Catching.IntValue;
	g_PH_Data_StartPoints = g_CVAR_PH_Data_StartPoints.IntValue;
	g_PH_Data_MaxPlayers_Top = g_CVAR_PH_Data_MaxPlayers_Top.IntValue;
	g_PH_Data_MinPlayers = g_CVAR_PH_Data_MinPlayers.IntValue;
	g_PH_Data_AllowWarmUp = g_CVAR_PH_Data_AllowWarmUp.IntValue;
	g_PH_Data_MinPlayers = g_CVAR_PH_Data_MinPlayers.IntValue;
	g_PH_Data_Suicide = g_CVAR_PH_Data_Suicide.IntValue;
	g_PH_Data_BeingCatched = g_CVAR_PH_Data_BeingCatched.IntValue;
}

public void OnClientPostAdminCheck(int client)
{
	g_Points[client] = g_PH_Data_StartPoints;
	g_Catch_Num[client] = 0;
	g_Hide_Win_Round[client] = 0;
	g_Game_Round[client] = 0;
	g_PH_Data_NumPlayers++;
	
	if(g_PH_Data_NumPlayers == g_PH_Data_MinPlayers)
	{
		CPrintToChatAll("%s %t", g_PH_Data_Prefix, "Currently Min Players", g_PH_Data_MinPlayers);
	}
	
	LoadPlayerInfo(client);
}

public void OnClientDisconnect(int client)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	g_PH_Data_NumPlayers--;
	
	if(g_PH_Data_NumPlayers < g_PH_Data_MinPlayers)
	{
		CPrintToChatAll("%s %t", g_PH_Data_Prefix, "Currently Not Min Players", g_PH_Data_MinPlayers);
	}
	
	char update[2048];
	char playername[64];
	GetClientName(client, playername, sizeof(playername));
	GetClientAuthId(client, AuthId_Steam3, g_SteamID[client], sizeof(g_SteamID[]));
	SQL_EscapeString(db, playername, playername, sizeof(playername));
	FormatEx(update, sizeof(update), "UPDATE prophunt_data SET name = '%s', hide_win_round = %i, catch_num = %i, game_round = %i, points =  %i WHERE steam_id='%s';", playername, g_Hide_Win_Round[client], g_Catch_Num[client], g_Game_Round[client], g_Points[client], g_SteamID[client]);
	
	SQL_TQuery(db, SQL_NothingCallback, update, client);
}

public void LoadPlayerInfo(int client)
{
	char buffer[2048];

	GetClientAuthId(client, AuthId_Steam3, g_SteamID[client], sizeof(g_SteamID[]));
	if(db != INVALID_HANDLE)
	{
		FormatEx(buffer, sizeof(buffer), "SELECT * FROM prophunt_data WHERE steam_id = '%s';", g_SteamID[client]);
		SQL_TQuery(db, SQL_LoadPlayerCallback, buffer, client);
	}
}

stock void GetRank(int client)
{
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM prophunt_data ORDER BY points DESC;");
	
	SQL_TQuery(db, SQL_GetRank, query, GetClientUserId(client));
}

stock void ResetRank(int client)
{
	char query[255];
	Format(query, sizeof(query), "DELETE FROM prophunt_data WHERE SteamID = '%s';", g_SteamID[client]);

	SQL_TQuery(db, SQL_NothingCallback, query);
	
	OnClientPostAdminCheck(client);
}


stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		return true;
	}
	
	return false;
}