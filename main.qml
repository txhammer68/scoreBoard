import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtNetwork
import org.kde.plasma.configuration
import org.kde.kirigami as Kirigami
import org.kde.notification

// Scoreboard Widget
// USA sports MLB,NBA,NFL,MLS,NHL,WNBA,World Cup
// txhammer 03/2026

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints:!Plasmoid.configurationRequired ? PlasmaCore.Types.NoBackground:PlasmaCore.Types.StandardBackground
    fullRepresentation: FullRepresentation { }
    compactRepresentation: CompactRepresentation { }

    toolTipMainText:getGameType ()
    //toolTipSubText: ""

    property var scoreBoard:[]
    property int key:-1
    property bool activeGames:false
    property int viewHeight: Plasmoid.configurationRequired ? 80 : viewMode ?  118 : scoreBoard.length > 4 ? 122*4:122*scoreBoard.length
    property int viewWidth:420
    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property bool updateAvail:false
    property string updateMsg:"Updated Version Ready "+"("+updateVersion+")"
    property string updateURL:"https://raw.githubusercontent.com/txhammer68/scoreBoard/refs/heads/main/metadata.json"
    property string updateCMD:"git clone https://github.com/TxHammer68/scoreBoard /tmp/scoreBoard/ && kpackagetool6 -t Plasma/Applet -u /tmp/scoreBoard/"

    // --- Configuration Properties ---
    property int gameTypeIdx: plasmoid.configuration.gameIdx
    property string favTeam: plasmoid.configuration.favTeam
    property string gameTypeURL: plasmoid.configuration.gameTypeURL
    property bool viewMode:plasmoid.configuration.viewMode
    property bool autoUpdate:plasmoid.configuration.chkBoxUpdate


    Component.onCompleted: {
        if (gameTypeURL.length > 0) {
            getData(gameTypeURL)
            autoUpdate ? getData(updateURL):""
            gameTimer.start()
        } else {
            Plasmoid.configurationRequired = true
        }
    }

    onGameTypeURLChanged: {
        getData(gameTypeURL)
        gameTimer.restart()
    }

    onFavTeamChanged:{
        getData(gameTypeURL)
        gameTimer.restart()
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Refresh Data"
            icon.name: "view-refresh"
            priority: Plasmoid.HighPriorityAction
            onTriggered: getData(gameTypeURL)
        }
    ]

    Item {
        Notification {
            id: updateNotification
            componentName: "plasma_workspace"
            eventId: "notification"
            title: "Update"
            text: "ScoreBoard Update Available, Check Settings in Widget."
            iconName: "task-due"
            flags: Notification.CloseOnTimeout
            urgency: Notification.DefaultUrgency
        }
    }

    function getGameType () {
        if (gameTypeIdx == 0) {
            return "MLB ScoreBoard" }
            else if (gameTypeIdx == 1) {
                return "MLS ScoreBoard" }
                else if (gameTypeIdx == 2) {
                    return "NBA Scoreboard" }
                    else if (gameTypeIdx == 3) {
                        return "NFL ScoreBoard" }
                        else if (gameTypeIdx == 4) {
                            return "NHL ScoreBoard" }
                            else if (gameTypeIdx == 5) {
                                return "WNBA ScoreBoard" }
                                else if (gameTypeIdx == 6) {
                                    return "WCUP ScoreBoard" }

    }

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        // Set a timeout (10 seconds) so the widget doesn't hang on a dead connection
        xhr.timeout = 10000;
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText)
                        if (url === gameTypeURL) {
                            findKey (data)
                            processGameData(data)
                            checkActiveGames(data)
                        } else if (url === updateURL) {
                            processUpdateData(data)
                        }
                    } catch (e) {
                        console.error("Failed to parse JSON from:", url, e);
                        ///console.log("Raw Response Data:", xhr.responseText);
                    }
                } else {
                    // Handle API Down or Network Error (404, 500, etc.)
                    console.warn("API Error:", xhr.status, "URL:", url);
                    if (url === gameTypeURL) {
                        // Don't wipe current scores immediately on one failure,
                        // but mark that we have a connection issue if you choose.
                        activeGames = false;
                    }
                }
            }
        };

        xhr.ontimeout = function () {
            console.error("Request timed out for:", url);
        };

        xhr.onerror = function () {
            console.error("Network error occurred while fetching:", url);
        };

        xhr.send();
    }

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            updateNotification.sendEvent()
        }
    }

    function findKey (data) {
        if (typeof(data) !== undefined) {
            key=-1
            if (data.events.length > 0 ) { // check if any data exists
                for (let i = 0; i < data.events.length; i++) {
                    if (data.events[i].competitions[0].competitors[0].team.displayName===favTeam)  {
                        key=i
                        return null
                    }
                    else if (data.events[i].competitions[0].competitors[1].team.displayName===favTeam)  {
                        key=i
                        return null
                    }
                }
                if (key == -1) { // else no fav team playing
                    key = 0
                    return null
                }
             }
          }
          else {
              key = -1
              return null
          }
       }

    function processGameData (data) {
        if (typeof(data) != undefined) {
            let array={}
            let scoresList=[]
            if (key !== -1) { // put fav team first in the list of games if playing
                if ( data.events.length > 0 ) { // check if any data exists
                    array={
                        leagueAbbreviation:data.leagues[0].abbreviation,
                        gameStatusState:data.events[key].competitions[0].status.type.state,
                        gameStatusDetail:data.events[key].competitions[0].status.type.shortDetail,
                        gameStatusDescription:data.events[key].competitions[0].status.type.description,
                        gamePeriod:data.events[key].competitions[0].status.period,
                        gameClock:data.events[key].competitions[0].status.displayClock,
                        gameDate:data.events[key].competitions[0].date,
                        gameBoxScoresURL:data.events[key].links[0].href,
                        homeTeamName:data.events[key].competitions[0].competitors[0].team.displayName,
                        homeTeamLogo:data.events[key].competitions[0].competitors[0].team.logo,
                        homeTeamScore:data.events[key].competitions[0].competitors[0].score,
                        homeTeamRecord:data.events[key].competitions[0].competitors[0].hasOwnProperty('records') ? data.events[key].competitions[0].competitors[0].records[0].summary : "--",
                        homeTeamWinner:data.events[key].competitions[0].competitors[0].winner !=undefined ? data.events[key].competitions[0].competitors[0].winner:false,
                        awayTeamName:data.events[key].competitions[0].competitors[1].team.displayName,
                        awayTeamLogo:data.events[key].competitions[0].competitors[1].team.logo,
                        awayTeamScore:data.events[key].competitions[0].competitors[1].score,
                        awayTeamRecord:data.events[key].competitions[0].competitors[1].hasOwnProperty('records') ? data.events[key].competitions[0].competitors[1].records[0].summary : "--",
                        awayTeamWinner:data.events[key].competitions[0].competitors[1].winner !=undefined ? data.events[key].competitions[0].competitors[1].winner:false,
                        gameHeadline:data.events[key].competitions[0].hasOwnProperty("headlines") ? data.events[key].competitions[0].headlines[0].shortLinkText : ""}
                        scoresList.push(array)
                }
                for (let i=0;i<data.events.length;i++) {
                    if (i === key) {
                        continue; // skip if fav team key
                    }
                    else {
                        array={
                            leagueAbbreviation:data.leagues[0].abbreviation,
                            gameStatusState:data.events[i].competitions[0].status.type.state,
                            gameStatusDetail:data.events[i].competitions[0].status.type.shortDetail,
                            gameStatusDescription:data.events[i].competitions[0].status.type.description,
                            gamePeriod:data.events[i].competitions[0].status.period,
                            gameClock:data.events[i].competitions[0].status.displayClock,
                            gameDate:data.events[i].competitions[0].date,
                            gameBoxScoresURL:data.events[i].links[0].href,
                            homeTeamName:data.events[i].competitions[0].competitors[0].team.displayName,
                            homeTeamLogo:data.events[i].competitions[0].competitors[0].team.logo,
                            homeTeamScore:data.events[i].competitions[0].competitors[0].score,
                            homeTeamRecord:data.events[i].competitions[0].competitors[0].hasOwnProperty('records') ? data.events[i].competitions[0].competitors[0].records[0].summary : "--",
                            homeTeamWinner:data.events[i].competitions[0].competitors[0].winner !=undefined ? data.events[i].competitions[0].competitors[0].winner:false,
                            awayTeamName:data.events[i].competitions[0].competitors[1].team.displayName,
                            awayTeamLogo:data.events[i].competitions[0].competitors[1].team.logo,
                            awayTeamScore:data.events[i].competitions[0].competitors[1].score,
                            awayTeamRecord:data.events[i].competitions[0].competitors[1].hasOwnProperty('records') ? data.events[i].competitions[0].competitors[1].records[0].summary : "--",
                            awayTeamWinner:data.events[i].competitions[0].competitors[1].winner !=undefined ? data.events[i].competitions[0].competitors[1].winner:false,
                            gameHeadline:data.events[i].competitions[0].hasOwnProperty("headlines") ? data.events[i].competitions[0].headlines[0].shortLinkText : ""}
                            scoresList.push(array)
                    }
                }
                scoreBoard=scoresList
                Plasmoid.configurationRequired=false
            }
        }
    else {
        let array={
            gameStatusState: "pre",
            gameStatusDetail:"No Data",
            gameStatusDescription:"No Data"
        }
        scoresList.push(array)
        scoreBoard=scoresList
        key=-1
        gameTimer.restart()
        return null
      }
    }

    function checkActiveGames (data) {
          for (let i = 0; i < data.events.length; i++) {
              if (data.events[i].status.type.state == "in") {
                  activeGames=true;
                  return null;
              }
          }
        activeGames=false
        return null
    }

    function gameState(index) {
        if (scoreBoard[index].gameStatusState == "pre") {
            return (Qt.formatDateTime(new Date(scoreBoard[index].gameDate),"h:mm ap"))
        }
        else if (scoreBoard[index].gameStatusState == "in") {
            if (scoreBoard[index].gameStatusDescription != "In Progress") {
                return (scoreBoard[index].gameStatusDetail)
            }
            return (scoreBoard[index].gamePeriod+getOrdinal(scoreBoard[index].gamePeriod))
        }
        else {
            return ( scoreBoard[index].gameStatusDetail)
        }
    }

    function winningTeam (x,index){
        let c=Kirigami.Theme.textColor
        if (scoreBoard[index].gameStatusState == "post") {
            x ? c=Kirigami.Theme.textColor:c=Kirigami.Theme.disabledTextColor
        }
        else c=Kirigami.Theme.textColor
            return c
    }

    function getOrdinal(n) {            // assigns superfix to inning
        let s=["th","st","nd","rd"],
        v=n%100
        return (s[(v-20)%10]||s[v]||s[0])
    }

    // Main update timer for live game data
    Timer {
        id: gameTimer
        interval: activeGames ? 2*60*1000 : 30*60*1000
        running:false
        repeat: true
        onTriggered: getData(gameTypeURL)
    }

     // timer to trigger update after wake from suspend mode
     // delay 20 secs for suspend to resume
    Timer {
        id: suspendTimer
        interval: 20*1000
        running: false
        repeat:  false
        onTriggered: {
            getData(gameTypeURL)
            autoUpdate ? getData(updateURL):""
            gameTimer.restart()
        }
    }

    Connections {
        target:NetworkInformation
        onReachabilityChanged: {
            if (NetworkInformation.reachability == 4) {
                suspendTimer.start();
            }
        }
    }
}
