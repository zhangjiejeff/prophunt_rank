// Hooks every say command to check if it is similar to console commands;
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(StrEqual(command, "rank"))
	{
		Command_Rank(client, 1);
	}
	else if(StrEqual(command, "mystats"))
	{
		Command_MyStats(client, 1);
	}
}

public Action Command_Rank(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	GetRank(client);
}

public Action Command_ResetMyRank(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	char buffer[512];
	Menu menu = new Menu(Menu_ResetData_Handler);
	FormatEx(buffer, sizeof(buffer), "%t", "Want to Reset Data");
	menu.SetTitle(buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("yes", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("no", buffer);
	
	menu.ExitButton = false;
	menu.Display(client, 0);
}

public Action Command_MyStats(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	char name[MAX_NAME_LENGTH + 2];
	char buffer[512];
	Menu menu = new Menu(Menu_Nothing_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Stats");
	menu.SetTitle(buffer);
	
	GetClientName(client, name, sizeof(name));
	FormatEx(buffer, sizeof(buffer), "%t", "Player Name", name);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player SteamID", g_SteamID[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Points", g_Points[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Game Round", g_Game_Round[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Hide Win", g_Hide_Win_Round[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Catch Num", g_Catch_Num[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public Action Command_ResetRank_All(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "TRUNCATE TABLE prophunt_data;");

	SQL_TQuery(db, SQL_NothingCallback, query);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
	
	CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Reset All");
	
	return Plugin_Handled;
}

public Action Command_Top(int client, int args)
{
	int num = 0;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	if(g_PH_Data_MaxPlayers_Top < num)
	{
		CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Show More Than X Players", g_PH_Data_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT name, points, steam_id FROM prophunt_data ORDER BY points DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTop, query, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action Command_TopHideWinRound(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	
	if(num > g_PH_Data_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Show More Than X Players", g_PH_Data_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT name, hide_win_round FROM prophunt_data ORDER BY hide_win_round DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopHideWinRound, query, GetClientUserId(client));
	
	return Plugin_Handled;
}


public Action Command_TopCatchNum(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	if(num > g_PH_Data_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Show More Than X Players", g_PH_Data_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT name, catch_num FROM prophunt_data ORDER BY catch_num DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopCatchNum, query, GetClientUserId(client));
	
	return Plugin_Handled;
}


public int Menu_ResetData_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		switch(choice)
		{
			case 0:
			{
				ResetRank(client);
				CPrintToChat(client, "%s %t", g_PH_Data_Prefix, "Your Rank Reset");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int Menu_Nothing_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}