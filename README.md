# T6-Plutonium-Grief-Promod
A Plutonium mod for the Grief gamemode in zombies.

## Installation

Note: Only dedicated servers are officially supported

Follow this guide to set one up: https://plutonium.pw/docs/server/t6/setting-up-a-server/

Download the latest release or build from scratch with the included build tool.

Follow these instructions on how to install: https://plutonium.pw/docs/modding/loading-mods/#getting-started

## Created by: JezuzLizard and 5and5

[![IMAGE ALT TEXT HERE](Grief_on_all_maps.png)](https://www.youtube.com/watch?v=vuwAIZxHpWM&ab_channel=Lanevader)

## Change Notes

### General 
* Round scoring - Down all enemy players to score a point for your team, reach the roundlimit to win the match
* Shellshock due to bullets reduced from 0.75 to 0.25 seconds
* Points awarded for shooting or knifing enemy players

### Custom Game Settings
#### General
* Score limit
* Starting points
* Zombies run speed
* Zombies per round
* Max zombie on the map
* Players health
* Suicide check time

#### Custom Restrictions
* Mystery box restrictions
* Door restrictions
* Power ups restrictions
* Perk restricitions
* Buildable restricitions
* Knife lunge restricitions
* Starting ammo restricitions

### Teams
* Server owner can set preset teams for tournament settings

### UI
* Scoreboard tracks stabs, confirms, revives and downs
* Kill feed displayed when hitting a player within 4 seconds of downing
* HUD shows round wins, 3 wins equals a game win by default

## Maps

### Mob of the Dead
* Moved initial spawn points to east cellblock
* Added option for Jug
* Disabled doors leading to spawn
* Blocked off hallway to spawn

### Buried
* Moved initial spawn points to Jug area
* Blocked off ways to get to the upper tunnels
* Disabled candy shop and gerenal store doors

### Trazit Farm
* Switched Jug and Speed Cola

### Trazit Town
* No changes made

### Custom Maps
* Trazit Depot
* Trazit Power
* Trazit Tunnel
* Trazit Dinner

### Admin Command List
```
"!commandlist"
"!restart"
"!maprotate"
"!resetrotation"
"!map:<mapname>"
"!nextmap:<mapname>"
"!setmap:<mapname>"
"!kick:<playername>"
"!tempban:<playername>"
"!ban:<playername>"
"!magic:<bool>"
"!powerups:<bool>"
"!roundnumber:<int>"
"!knifelunge:<bool>"
"!dvar:<name>:<int>"
"!cvar:<name>:<int>"
"!cvarall:<name>:<int>"
"!lockserver:<password>"
"!unlockserver"
"!buildables:<bool>"
"!reducedammo:<bool>"
"!maxzombies:<int>"
"!depotjug:<bool>"
"!cellblockjug:<bool>"
```

### Server Config Setting
```
set grief_gamerule_scorelimit 3
set grief_gamerule_zombies_per_round 3
set grief_gamerule_suicide_check_wait 5
set grief_gamerule_next_round_timer 5
set grief_gamerule_round_restart_points 8000
set grief_gamerule_player_health 100
set grief_gamerule_mystery_box_enabled 0
set grief_gamerule_knife_lunge 1
set grief_gamerule_magic 1
set grief_gamerule_reduced_pistol_ammo 1
set grief_gamerules_disable_zombie_special_runspeeds 0
set grief_gamerule_disable_doors 1
set grief_brutus_enabled 1
//set grief_gamerule_powerup_restrictions "all"
set grief_gamerule_perk_restrictions "specialty_quickrevive specialty_weapupgrade specialty_longersprint specialty_rof"
set grief_perk_location_override "location farm perk specialty_armorvest origin 8169.2,-6319.8,117 angles 0,300,0 location farm perk specialty_fastreload origin 8216.6,-6410.6,245 angles 0,300,0" // switches jug and speed cola on farm
set grief_gamerule_mystery_box_enabled 0
set grief_killfeed_enable 1
//set grief_gamerule_depot_jug 1
//set grief_gamerule_cellblock_jug 1

sv_maprotation "exec zm_grief_cellblock.cfg map zm_prison exec zm_grief_diner.cfg map zm_transit exec zm_grief_town.cfg map zm_transit exec zm_grief_transit.cfg map zm_transit exec zm_grief_farm.cfg map zm_transit exec zm_grief_power.cfg map zm_transit exec zm_grief_tunnel.cfg map zm_transit exec zm_grief_street.cfg map zm_buried"

```

### Credits
Fully integrated with the Cut Survival Maps mod: https://github.com/JezuzLizard/Cut-Tranzit-Locations

### Installation
* Server setup guide: https://forum.plutonium.pw/topic/13/plutot6-server-set-up-guide
* This mod requires this plugin to run: https://github.com/fedddddd/t6-gsc-utils

