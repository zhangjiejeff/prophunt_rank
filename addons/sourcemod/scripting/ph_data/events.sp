public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_PH_Data_AllowWarmUp && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		CPrintToChatAll("%s %t", g_PH_Data_Prefix, "Warmup End");
		return;
	}
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_PH_Data_AllowWarmUp && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return;
	}

	if(g_PH_Data_NumPlayers < g_PH_Data_MinPlayers)
	{
		return;
	}
	
	int winner = event.GetInt("winner");
	
	if(g_PH_Data_HideWin > 0 && winner == 2)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			{
				g_Points[i] += g_PH_Data_HideWin;
				g_Hide_Win_Round[i]++;
				CPrintToChat(i, "%s %t", g_PH_Data_Prefix, "Won Hide Round", g_PH_Data_HideWin);
			}
		}		
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_PH_Data_AllowWarmUp && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsValidClient(victim) || !IsValidClient(attacker))
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(attacker) != 3 || victim == attacker)
	{
		if(g_PH_Data_Suicide > 0)
		{
			g_Points[victim] -= g_PH_Data_Suicide;
			CPrintToChat(victim, "%s %t", g_PH_Data_Prefix, "Lost Points By Suicide", g_PH_Data_Suicide);
		}
		
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == 2 && GetClientTeam(attacker) == 3)
	{	
		if(g_PH_Data_BeingCatched >= 1)
		{
			g_Points[victim] -= g_PH_Data_BeingCatched;	
			CPrintToChat(attacker, "%s %t", g_PH_Data_Prefix, "Lost Points By BeingCatched", g_PH_Data_BeingCatched);
		}
		if(g_PH_Data_Cathing >= 1)
		{
			g_Points[attacker] += g_PH_Data_Cathing;
			CPrintToChat(attacker, "%s %t", g_PH_Data_Prefix, "Gain Points By Catching", g_PH_Data_Cathing);
		}
		g_Catch_Num[attacker]++;
	}
	return Plugin_Continue;
}
