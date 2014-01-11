#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"
#define CVAR_FLAGS     FCVAR_PLUGIN|FCVAR_NOTIFY

public Plugin:myinfo = 
{
	name = "L4D2 scavenge 1st round skip",
	author = "def075",
	description = "dirty bug fix for scavenge + server-side changelevel",
	version = PLUGIN_VERSION,
	url = ""
}

new g_round = 0;
new Handle:g_plugin_enable = INVALID_HANDLE;

/* default cvars */
new g_scavenge_round_setup_time = 45;
new g_scavenge_round_initial_time = 90;
new g_scavenge_round_restart_delay = 10;
new g_scavenge_round_restart_delay_tied = 15;

public OnPluginStart()
{
	CreateConVar("l4d2_scavenge_1st_round_skip_version", PLUGIN_VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_plugin_enable = CreateConVar("l4d2_scavenge_1st_round_skip_enable", "1", "Enable(1)/Disable(0) the l4d2_scavenge_1st_round_skip plugin.", CVAR_FLAGS);
	
	HookConVarChange(FindConVar("scavenge_round_setup_time"), ScavengeRoundSetupTimeChanged);
	HookConVarChange(FindConVar("scavenge_round_initial_time"), ScavengeRoundInitialTimeChanged);
	HookConVarChange(FindConVar("scavenge_round_restart_delay"), ScavengeRoundRestartDelayChanged);
	HookConVarChange(FindConVar("scavenge_round_restart_delay_tied"), ScavengeRoundRestartDelayTiedChanged);
	HookConVarChange(g_plugin_enable, PluginEnableChanged);
	
	HookEvent("scavenge_round_finished", EventRoundFinished);
}
public OnMapStart()
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;
	if (enable) {
		SetConVarInt(FindConVar("scavenge_round_setup_time"), 0);
		SetConVarInt(FindConVar("scavenge_round_initial_time"), 0);
		SetConVarInt(FindConVar("scavenge_round_restart_delay"), 0);
		SetConVarInt(FindConVar("scavenge_round_restart_delay_tied"), 0);
	}
	g_round = 1;
}
public PluginEnableChanged(Handle:convar,
						   const String:oldValue[],
						   const String:newValue[])
{
	new bool:enable = StringToInt(newValue) == 1;
	if (enable) {
		if (g_round > 1) {
			SetConVarInt(FindConVar("scavenge_round_setup_time"),
						 g_scavenge_round_setup_time);
			SetConVarInt(FindConVar("scavenge_round_initial_time"),
						 g_scavenge_round_initial_time);
			SetConVarInt(FindConVar("scavenge_round_restart_delay"),
					 g_scavenge_round_restart_delay);
			SetConVarInt(FindConVar("scavenge_round_restart_delay_tied"),
						 g_scavenge_round_restart_delay_tied);
		} else {
			SetConVarInt(FindConVar("scavenge_round_setup_time"), 0);
			SetConVarInt(FindConVar("scavenge_round_initial_time"), 0);
			SetConVarInt(FindConVar("scavenge_round_restart_delay"), 0);
			SetConVarInt(FindConVar("scavenge_round_restart_delay_tied"), 0);
		}
	} else {
		SetConVarInt(FindConVar("scavenge_round_setup_time"),
					 g_scavenge_round_setup_time);
		SetConVarInt(FindConVar("scavenge_round_initial_time"),
					 g_scavenge_round_initial_time);
		SetConVarInt(FindConVar("scavenge_round_restart_delay"),
					 g_scavenge_round_restart_delay);
		SetConVarInt(FindConVar("scavenge_round_restart_delay_tied"),
					 g_scavenge_round_restart_delay_tied);
	}
}
public ScavengeRoundSetupTimeChanged(Handle:convar,
									 const String:oldValue[],
									 const String:newValue[])
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;
	new value = StringToInt(newValue);
	if (value > 0) {
		g_scavenge_round_setup_time = value;
		if (enable && g_round <= 1) {
			SetConVarInt(convar, 0);
		}
	}
}
public ScavengeRoundInitialTimeChanged(Handle:convar,
									   const String:oldValue[],
									   const String:newValue[])
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;	
	new value = StringToInt(newValue);
	if (value > 0) {
		g_scavenge_round_initial_time = value;
		if (enable && g_round <= 1) {
			SetConVarInt(convar, 0);
		}
	}
}
public ScavengeRoundRestartDelayChanged(Handle:convar,
										const String:oldValue[],
										const String:newValue[])
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;	
	new value = StringToInt(newValue);
	if (value > 0) {
		g_scavenge_round_restart_delay = value;
		if (enable && g_round <= 1) {
			SetConVarInt(convar, 0);
		}
	}
}
public ScavengeRoundRestartDelayTiedChanged(Handle:convar,
											const String:oldValue[],
											const String:newValue[])
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;
	new value = StringToInt(newValue);
	if (value > 0) {
		g_scavenge_round_restart_delay_tied = value;
		if (enable && g_round <= 1) {
			SetConVarInt(convar, 0);
		}
	}
}
public Action:EventRoundFinished(Handle:event, const String:name[], bool:dontBroadcast)
{
	new bool:enable = GetConVarInt(g_plugin_enable) == 1;
	
	g_round += 1;
	if (enable && g_round == 2) {
		SetConVarInt(FindConVar("scavenge_round_setup_time"),
					 g_scavenge_round_setup_time);
		SetConVarInt(FindConVar("scavenge_round_initial_time"),
					 g_scavenge_round_initial_time);
		SetConVarInt(FindConVar("scavenge_round_restart_delay"),
					 g_scavenge_round_restart_delay);
		SetConVarInt(FindConVar("scavenge_round_restart_delay_tied"),
					 g_scavenge_round_restart_delay_tied);
		PrintToChatAll("\x04[scavenge_1st_round_skip] \x01 Fixed 1st round bug.");
	}
}
