# ccSuite
Custom script suite on the TES3MP 0.7.0-alpha server "The Cornerclub"

Everything has been dehardcoded into easily-configurable tables (...Config.lua files) with optional support for Tamriel_Data content based on the server plugin setting in ccConfig.lua

Any ccSuite module can be enabled or disabled by changing a single line in ccConfig.lua

# ccScript (Required)
* Spawn location/starting clothes/starting weapon randomizer
* Customizable MOTD that welcomes players after chargen
* /stats - Allows players to track their time on the server
* /deletecharacter - Deletes character file
* Punish players by sending them to random configurable cells
* Three info windows - choose their /command and message

# ccAdvanceQuest
* Choose when your world file will be wiped, if at all
* Choose which dialogue topics will be added to the world file

# ccDynamicDifficulty
* Choose whether the number of players affects the difficulty

# ccFactions
* Players can create and manage factions/guilds (no features beyond chat atm)
* /f - Faction chat
* /factions - Main faction info window
* /factions kick - Kick a member from your faction
* /factions invite - Invite a player to your faction
* /factions promote - Promote a member to a higher rank (not fully implemented)

# ccHardcore
* Players can opt into "permadeath" after chargen
* /ladder - Displays the HC players from highest level to lowest
* Configure whether HC players drop gold on death
* Configure optional safe cells (ccConfig.lua) for HC players

# ccPerks
* Token system - Players earn tokens every day and every second level-up
* Every perk, including its token cost, is customizable in ccPerksConfig.lua
* Lottery
* Spawn custom weapons like melee pillows ("rewards")
* Appear as Creature
* Birthsign changer
* Head changer
* Hair changer
* Gender changer
* Race changer
* Weather changer
* Spawn pet (buggy)
* Warp

# ccServerMsg
* Choose when and what messages will automatically appear every hour
* If relying on a restart schedule, warn players in advance with a warning

# Configuration
* Use ccConfig.lua to enable or disable various modules
* Everything can be customized in each module's Config file
* Make sure to follow the correct format for each entry
* Don't forget commas!

# Installation
Download the entire repo and drag the contents into their respective data and scripts folders in either .../mp-stuff/ (WINDOWS) or .../PluginExamples (LINUX PACKAGE), then read below.

**Every script/data file must be included, even if you don't enable the respective module!**

# Changes to .../scripts/server.lua
Open the **server.lua** file and make the following changes (use CTRL-F or something similar):

**WIP**

# Changes to .../scripts/player/base.lua
Open the **base.lua** file and make the following changes (use CTRL-F or something similar):

**WIP**
