<p align="center">
    <img src="https://img.shields.io/badge/KDE_Plasma-6.0+-blue?style=for-the-badge&logo=kde" alt="KDE Plasma 6">
    <img src="https://img.shields.io/badge/license-GPL--3.0-green?style=for-the-badge" alt="License">
</p>

# scoreBoard
* KDE Plasma 6 sKoreboard Widget
* Get Sports Scores for MLB,MLS,NBA,NFL,NHL,WNBA,World Cup

#### Panel icon View
 <img alt="preview" src="panelView.png" width="40%">
 
#### Compact View
 <img alt="preview1" src="preview1.png" width="40%">
 
#### Full View
 <img alt="preview2" src="preview3.png" width="40%">
 

* Install with
 ``` bash
git clone https://github.com/TxHammer68/scoreBoard /tmp/scoreBoard && kpackagetool6 -t Plasma/Applet -i /tmp/scoreboard/
```
* Upgrade with
``` bash
git clone https://github.com/TxHammer68/scoreBoard /tmp/scoreBoard && kpackagetool6 -t Plasma/Applet -u /tmp/scoreBoard
```
* Remove with
``` bash
kpackagetool6 --remove scoreBoard --type Plasma/Applet
```
* Install widget to panel or desktop floating
* Right click on widget to configure
* Select Sport Type
* Select View

#### Notes
* Add multiple scoreboards for different sport types
* Panel icon changes for active games, full opacity for active games, 65% for no active games
* Update interval is dynamic; 2 minutes when any game is active, 30 minutes if no games
* Compact view is ideal for desktop floating widget, there is an animation that cycles thru all the games
* Full view is scrollable with mouse wheel,ideal for panel placement
* left click on any game to view more details on the web
* middle click on any game to refresh data
* When system wakes from suspend/sleep mode, widget will refresh after network connection is established
* You can resize popup to get proper fit
* Added Update Widget Button in the Config Screen
    * Automatically checks for updates on first load and wake from sleep mode
    * Widget will send a system notification message when update is available
    * Check settings to download/apply update
    * Logout after update for update to be applied
    * Verify settings/config after login

All trademarks, trade names, or logos mentioned or used are the property of their respective owners. Every effort has been made to properly capitalize, punctuate, identify and attribute trademarks and trade names to their respective owners.
