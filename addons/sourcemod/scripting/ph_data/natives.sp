public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("PH_Data_GetPoints", Native_PH_Data_GetPoints);
	CreateNative("PH_Data_SetPoints", Native_PH_Data_SetPoints);
	CreateNative("PH_Data_GetHideWin", Native_PH_Data_GetHideWin);
	CreateNative("PH_Data_GetCatchNum", Native_PH_Data_GetCatchNum);
	CreateNative("PH_Data_GetGameRound", Native_PH_Data_GetGameRound);
	CreateNative("PH_Data_ResetPlayer", Native_PH_Data_ResetPlayer);

	RegPluginLibrary("prophunt_data");
	
	return APLRes_Success;
}

public int Native_PH_Data_GetHideWin(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return g_Hide_Win_Round[client];
}

public int Native_PH_Data_GetCatchNum(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return g_Catch_Num[client];
}

public int Native_PH_Data_GetPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return g_Points[client];
}

public int Native_PH_Data_GetGameRound(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return g_Game_Round[client];
}

public int Native_PH_Data_SetPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	g_Points[client] = points;
	
	return view_as<int>(points);
}

public int Native_PH_Data_ResetPlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	ResetRank(client);
}