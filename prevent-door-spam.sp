/* Headers & preprocessor directives */
#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define MAX_EDICTS 2048
#define IGNORE_PLAYER_USE 32768 // Ignore player +USE, prop_door_rotating flag

/* Global variables */
bool g_bInAction[MAX_EDICTS];

/**
 * Plugin public information.
 */
public Plugin myinfo =
{
	name = "Prevent Door Spam",
	author = "ici",
	description = "Prevents players from opening/closing func_door_rotating entities repeatedly",
	version = "1.0.0",
	url = "http://steamcommunity.com/id/1ci/"
};

/**
 * Called when the plugin is fully initialized and all known external references 
 * are resolved. This is only called once in the lifetime of the plugin, and is 
 * paired with OnPluginEnd().
 *
 * If any run-time error is thrown during this callback, the plugin will be marked 
 * as failed.
 */
public void OnPluginStart()
{

	
	HookEntityOutput("prop_door_rotating", "OnOpen", StartAction);
	HookEntityOutput("prop_door_rotating", "OnClose", StartAction);
	HookEntityOutput("prop_door_rotating", "OnFullyOpen", EndAction);
	HookEntityOutput("prop_door_rotating", "OnFullyClosed", EndAction);
}

public Action StartAction(const char[] output, int caller, int activator, float delay)
{
	if (g_bInAction[caller])
	{
		// The door is still opening/closing.
		// Don't allow the player to close the door if it's not fully opened yet and vice versa.
		return Plugin_Handled;
	}
	
	PrintCenterTextAll("StartAction %d", caller);
	g_bInAction[caller] = true;
	int flags = GetEntProp(caller, Prop_Data, "m_spawnflags");
	flags |= IGNORE_PLAYER_USE;
	SetEntProp(caller, Prop_Data, "m_spawnflags", flags);
	
	return Plugin_Continue;
}

public void EndAction(const char[] output, int caller, int activator, float delay)
{
	// The door has finished opening/closing.
	PrintCenterTextAll("EndAction %d", caller);
	g_bInAction[caller] = false;
	int flags = GetEntProp(caller, Prop_Data, "m_spawnflags");
	flags &= ~IGNORE_PLAYER_USE;
	SetEntProp(caller, Prop_Data, "m_spawnflags", flags);
}
