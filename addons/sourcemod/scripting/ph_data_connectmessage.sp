/* [CS:GO] PropHunt Data & Rank Connect Message
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
#include <ph_data>

#pragma semicolon 1
#pragma newdecls required

// ConVars
ConVar g_CVAR_PH_Data_ConnectMessage_Type;
ConVar g_CVAR_PH_Data_ConnectMessage_HudText_Red;
ConVar g_CVAR_PH_Data_ConnectMessage_HudText_Green;
ConVar g_CVAR_PH_Data_ConnectMessage_HudText_Blue;

// Variables to store ConVar Values;
int g_PH_Data_ConnectMessage_Type;
int g_PH_Data_ConnectMessage_HudText_Red;
int g_PH_Data_ConnectMessage_HudText_Green;
int g_PH_Data_ConnectMessage_HudText_Blue;

public Plugin myinfo = 
{
	name = "[PH Data] Connect's Message",
	author = "ZhangJie",
	description = "It shows a message when a player connect, with his points and data.",
	version = "1.0",
	url = "https://www.github.com/1204601575"
};

public void OnPluginStart()
{	
	g_CVAR_PH_Data_ConnectMessage_Type = CreateConVar("ph_data_connectmessage_type", "1", "Type of HUD that you want to use in the connect message (0 = Disable, 1 = HintText, 2 = CenterText, 3 = Chat, 4 = HudText)", _, true, 0.0, true, 4.0);
	g_CVAR_PH_Data_ConnectMessage_HudText_Red = CreateConVar("ph_data_connectmessage_hudtext_red", "255", "RGB Code for the Red Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);
	g_CVAR_PH_Data_ConnectMessage_HudText_Green = CreateConVar("ph_data_connectmessage_hudtext_green", "255", "RGB Code for the Green Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);
	g_CVAR_PH_Data_ConnectMessage_HudText_Blue = CreateConVar("ph_data_connectmessage_hudtext_blue", "255", "RGB Code for the Blue Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);

	AutoExecConfig(true, "ph_data_connectmessage", "ph_data");
}

public void OnConfigsExecuted()
{
	g_PH_Data_ConnectMessage_Type = g_CVAR_PH_Data_ConnectMessage_Type.IntValue;
	g_PH_Data_ConnectMessage_HudText_Red = g_CVAR_PH_Data_ConnectMessage_HudText_Red.IntValue;
	g_PH_Data_ConnectMessage_HudText_Green = g_CVAR_PH_Data_ConnectMessage_HudText_Green.IntValue;
	g_PH_Data_ConnectMessage_HudText_Blue = g_CVAR_PH_Data_ConnectMessage_HudText_Blue.IntValue;
}

public void OnClientPostAdminCheck(int client)
{
	if(!g_PH_Data_ConnectMessage_Type)
	{
		return;
	}
	
	int points = PH_Data_GetPoints(client);
	int hidewin = PH_Data_GetHideWin(client);
	int catchnum = PH_Data_GetCatchNum(client);
	int gameround = PH_Data_GetGameRound(client);
	
	for (int i = 0; i < MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			/*
				Type of HUD that you want to use in the connect message:
					0 = Disable
					1 = HintText
					2 = CenterText
					3 = Chat
					4 = HudText
			*/
			switch(g_PH_Data_ConnectMessage_Type)
			{
				case 1:
				{
					PrintHintText(i, "[%N|%d分]进入服务器, 吃鸡局:%d局/%d局, 抓人数:%d", client, points, hidewin, gameround, catchnum);
				}
				case 2:
				{
					PrintCenterText(i, "[%N|%d分]进入服务器, 吃鸡局:%d局/%d局, 抓人数:%d", client, points, hidewin, gameround, catchnum);
				}
				case 3:
				{
					PrintToChat(i, "[%N|%d分]进入服务器, 吃鸡局:%d局/%d局, 抓人数:%d", client, points, hidewin, gameround, catchnum);
				}
				case 4:
				{
					SetHudTextParams(-1.0, 0.125, 5.0, g_PH_Data_ConnectMessage_HudText_Red, g_PH_Data_ConnectMessage_HudText_Green, g_PH_Data_ConnectMessage_HudText_Blue, 255, 0, 0.25, 1.5, 0.5);
					ShowHudText(i, 5, "[%N|%d分]进入服务器, 吃鸡局:%d局/%d局, 抓人数:%d", client, points, hidewin, gameround, catchnum);
				}
			}
		}
	}
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	
	return false;
}