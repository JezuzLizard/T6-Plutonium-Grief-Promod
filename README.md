# T6-Plutonium-Grief-Promod
A plutonium mod for the Grief gamemode in zombies.

This mod requires this plugin to run: https://github.com/fedddddd/t6-gsc-utils

### Created by: JezuzLizard and 5and5

## Download
[Download](https://www.mediafire.com/file/344hf0kvpal2exv/BO2-Pluto_Grief_Server.zip/file)

## Change Notes

### General 
* Round scoring - Down all enemy players to score a point for your team, reach the roundlimit to win the match
* Shellshock due to bullets reduced from 0.75 to 0.25 seconds
* Zombies per round limited
* Reduced pistol starting ammo
* Removed quick revive, staminup and pack-a-punch on all maps

### Teams
* Server owner can set preset teams for tournament settings

### UI
* Scoreboard tracks stabs, confirms, revives and downs
* Kill feed displayed when hitting a player within 4 seconds of downing
* HUD shows round wins, 3 wins equals a game win

## Maps

### Mob of the Dead
* Moved initial spawn points to east cellblock
* Added option for Jug
* Disabled doors leading to spawn
* Blocked off hallway to spawn

### Buried
* Moved initial spawn points to Jug
* Blocked off ways to get to the upper tunnels and courthouse area
* Disabled candy shop and gerenal store doors

### Trazit Farm
* Switched Jug and Speed Cola

### Trazit Town
* No changes made

### Custom Maps
* Trazit Depot
* Trazit Power
* Trazit Tunnel
* Trazit Diner
* MoTD Docks
* MoTD Citadel
* Die Rise Dragon location
* Die Rise PDW location

### Gamerules
```
shellshock_cooldown //Controls the the time before a shellshock will occur again
melee_shellshock_time //Duration of melee shellshock attack
bullet_shellshock_time //Duration of bullet shellshock attack
perks_disabled //Disables perks
powerups_disabled //Disables powerups
grief_brutus_enabled //Enables brutus on MoTD
shock_on_pain //Whether you get shellshocked on taking damage from fire and zombies
auto_balance_teams //Auto balance the teams at the start of the match
mystery_box_enabled //Enable the mystery box
depot_remove_debris_over_lava //Remove the depot debris over the lava pit
disable_doors //Disable certain doors on MoTD
buildables //Disable buildables
player_health //Sets the player's base health
reduced_pistol_ammo //Reduced pistol ammo on spawn
reduce_mp5_ammo //Reduce mp5 ammo on spawn
knife_lunge //Whether you'll sometimes knife lunge
grief_messages
display_instructions
suicide_check_time
round_restart_points
spawn_zombies_wait_time
next_round_time
zombie_round
magic
scorelimit
```

### Admin Command List
```
/togglehud
/printorigin
/printangles
/cvar <cvarname> <newval>
/cmdlist [pagenumber]
/playerlist [pagenumber] [team]
/stats [name|guid|clientnum]
/listgamerules
/resetgamerule <gamerule>
/setgamerule <gamerule> <value> [nummatches]
/unpause
/pause [minutes]
/respawnspectators
/togglerespawn <name|guid|clientnum|self>
/spectator <name|guid|clientnum|self>
/toggleteamchanging
/clantag <name|guid|clientnum> <newtag>
/togglechat
/unmute <name|guid|clientnum>
/mute <name|guid|clientnum> [duration_in_minutes]
/setrank <name|guid|clientnum|self> <rank>
/tempban <name|guid|clientnum> <duration_in_minutes> [reason]
/ban <name|guid|clientnum> [reason]
/execonteam <team> <cmdname> [cmdargs] ...
/execonallplayers <cmdname> [cmdargs] ...
/setrotation <rotationdvar>
/changemap <mapalias>
/rotate
/restart
/randomnextmap
/resetrotation
/nextmap <mapalias>
/cvarall <cvarname> <newval>
/dvar <dvarname> <newval>
/unlock
/lock <password>
/kick <name|guid|clientnum>
/setcvar <name|guid|clientnum|self> <cvarname> <newval>
```

Fully integrated with the Cut Survival Maps mod: https://github.com/JezuzLizard/Cut-Tranzit-Locations
