public int OnSQLConnect(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Database failure: %s", error);
		
		SetFailState("Databases dont work");
	}
	else
	{
		db = hndl;
		
		char buffer[3096];
		SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
		IsMySql = StrEqual(buffer,"mysql", false) ? true : false;
		
		if(IsMySql)
		{
			Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS prophunt_data (id INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, steam_id VARCHAR(64) NOT NULL DEFAULT NULL, name VARCHAR(64) NOT NULL DEFAULT NULL, hide_win_round INT(11) NOT NULL DEFAULT 0, catch_num INT(11) NOT NULL DEFAULT 0, game_round INT(11) NOT NULL DEFAULT 0, points INT(11) NOT NULL DEFAULT 0);");
			
			SQL_TQuery(db, OnSQLConnectCallback, buffer);
		}
	}
}

public int OnSQLConnectCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Query failure: %s", error);
		return;
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientPostAdminCheck(client);
		}
	}
}

public void SQL_LoadPlayerCallback(Handle DB, Handle results, const char[] error, any client)
{
	if(!IsClientInGame(client) || IsFakeClient(client))
	{
		return;
	}
	
	if(results == INVALID_HANDLE)
	{
		LogError("ERROR %s", error);
		return;
	}

	if(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		g_Hide_Win_Round[client] = SQL_FetchInt(results, 3);
		g_Catch_Num[client] = SQL_FetchInt(results, 4);
		g_Game_Round[client] = SQL_FetchInt(results, 5);
		g_Points[client] = SQL_FetchInt(results, 6);
	}
	else
	{
		char insert[512];
		char playername[64];
		GetClientName(client, playername, sizeof(playername));
		FormatEx(insert, sizeof(insert), "INSERT INTO prophunt_data (steam_id, name, hide_win_round, catch_num, game_round, points) VALUES ('%s','', 0, 0, 0, 0);");
		SQL_TQuery(db, SQL_NothingCallback, insert);
	}
}

public void SQL_NothingCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[Prop Data] Query Fail: %s", error);
		return;
	}
}

public void SQL_GetRank(Handle DB, Handle results, const char[] error, any data)
{
	int client, i = 0;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}
	g_MaxPlayers = SQL_GetRowCount(results);
	
	char SteamID[64];
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		i++;
		
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		
		if(StrEqual(g_SteamID[client], SteamID, true))
		{
			CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Show Rank", i, g_MaxPlayers, g_Points[client], g_Hide_Win_Round[client], g_Game_Round, g_Catch_Num[client]);
			break;
		}
	}
}

public void SQL_GetTop(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	char Name[64];
	int points;
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Nothing_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "top points");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0, Name, sizeof(Name));
		points = SQL_FetchInt(results, 1);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Points", Name, points);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopHideWinRound(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int hide_win_round;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Nothing_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Hide Win");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		hide_win_round = SQL_FetchInt(results, 1);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Hide Win", Name, hide_win_round);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopCatchNum(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int CatchNum;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Nothing_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By CatchNum");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		CatchNum = SQL_FetchInt(results, 1);
		
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y CatchNum", Name, CatchNum);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}
