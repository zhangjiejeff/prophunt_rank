#if defined _ph_data_included
  #endinput
#endif
#define _ph_data_included


/*********************************************************
 * Get's the number of a player's points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/
native int PH_Data_GetPoints(int client);

/*********************************************************
 * Get's the number of a player's hide win rounds
 *
 * @param client		The client to get the hide win rounds
 * @return				The number of hide win rounds		
 *********************************************************/
native int PH_Data_GetHideWin(int client);

/*********************************************************
 * Get's the number of a player's catch number
 *
 * @param client		The client to get the catch number
 * @return				The number of catch T		
 *********************************************************/
native int PH_Data_GetCatchNum(int client);

/*********************************************************
 * Get's the number of a player's Game Round
 *
 * @param client		The client to get the game round
 * @return				The number of game round		
 *********************************************************/
native int PH_Data_GetGameRound(int client);

/*********************************************************
 * Sets points to a certain player
 *
 * @param client		The client to get the points
 * @param points		Number of points to set
 * @noreturn	
 *********************************************************/
native bool PH_Data_SetPoints(int client, int points);

/*********************************************************
 * Reset a Player's Stats
 *
 * @param client		The client to reset the data
 * @noreturn
 *********************************************************/
native bool PH_Data_ResetPlayer(int client);