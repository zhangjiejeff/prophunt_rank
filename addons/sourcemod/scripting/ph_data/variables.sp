// Chat's main prefix;

// ConVars
ConVar g_CVAR_PH_Data_Prefix;
ConVar g_CVAR_PH_Data_StartPoints;
ConVar g_CVAR_PH_Data_MaxPlayers_Top;
ConVar g_CVAR_PH_Data_MinPlayers;
ConVar g_CVAR_PH_Data_Suicide;
ConVar g_CVAR_PH_Data_BeingCatched;
ConVar g_CVAR_PH_Data_Catching;
ConVar g_CVAR_PH_Data_HideWin;
ConVar g_CVAR_PH_Data_AllowWarmUp;

// Variables to Store ConVar Values;

char g_PH_Data_Prefix[32];
int g_PH_Data_StartPoints;
int g_PH_Data_MaxPlayers_Top;
int g_PH_Data_MinPlayers;
int g_PH_Data_NumPlayers;
int g_PH_Data_Suicide;
int g_PH_Data_BeingCatched;
int g_PH_Data_Cathing;
int g_PH_Data_HideWin;
int g_PH_Data_AllowWarmUp;

// Stores the main points, that are given after some events;
int g_Points[MAXPLAYERS + 1];
int g_Catch_Num[MAXPLAYERS + 1];
int g_Hide_Win_Round[MAXPLAYERS + 1];
int g_Game_Round[MAXPLAYERS + 1];
char g_SteamID[MAXPLAYERS + 1][64];

int g_MaxPlayers;
// Handle for the database;
Handle db;

// Check if it is MySQL that you set on the databases.cfg
bool IsMySql;