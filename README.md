# ccSuite
Custom script suite on the TES3MP 0.7.0-alpha server "The Cornerclub"

Everything has been dehardcoded into easily-configurable tables (...Config.lua files) with optional support for Tamriel_Data content based on the server plugin setting in ccConfig.lua

Any ccSuite module can be enabled or disabled by changing a single line in ccConfig.lua

# Installation
Download the entire repo, drag the two folders into /CoreScripts/, then add the following lines to /CoreScripts/scripts/customScripts.lua:

```
require("ccsuite/ccConfig")
require("ccsuite/ccSetup")
require("ccsuite/ccBuild")
require("ccsuite/ccHardcore")
require("ccsuite/ccFactions")
require("ccsuite/ccPerks")
require("ccsuite/ccAdvanceQuests")
require("ccsuite/ccCellReset")
require("ccsuite/ccCharGen")
require("ccsuite/ccCommands")
require("ccsuite/ccCommon")
require("ccsuite/ccDynamicDifficulty")
require("ccsuite/ccServerMessage")
require("ccsuite/ccStats")
require("ccsuite/ccWindowManager")
```

**Every script/data file must be included, even if you don't enable its respective module!**

# Configuration
* Use ccConfig.lua to enable or disable various modules
* Every module can be customized from this file
* Over 750 lines of customization
* Make sure to follow the correct format for each entry and remember your commas

# ccAdvanceQuest
* Choose when your world file will be wiped, if at all
* Choose which dialogue topics will be added to the world file

# ccBuild
* /build - Teleports players to a special cell where objects can be spawned
* No penalties upon dying in the cell, even for hardcore players
* Module can be configured to enable or disable wiping of the build cell 

# ccCellReset
* Choose when your cells will be wiped upon server restart, if at all

# ccDynamicDifficulty
* Choose whether the number of players affects the difficulty
* Choose the value by which the difficulty changes, if enabled

# ccFactions
* Players can create and manage factions/guilds
* A faction can claim one cell and members will respawn there upon death
* /f - Faction chat
* /faction - Main faction control window

# ccHardcore
* Players can opt into "permadeath" after chargen
* /ladder - Displays the HC players from highest level to lowest
* Configure whether HC players drop gold on death
* Configure optional safe cells (ccConfig.lua) for HC players

# ccPerks
* Token system - Players earn tokens every day and every second level-up
* Every perk, including its token cost, is customizable in ccPerksConfig.lua
* Lottery
* Appear as Creature
* Birthsign changer
* Head changer
* Hair changer
* Gender changer
* Race changer
* Weather changer
* Spawn pet (buggy)
* Warp

# ccServerMessage
* Choose when and what messages will automatically appear every hour
* If relying on a restart schedule, warn players in advance with a warning
