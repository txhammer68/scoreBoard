import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmCore
import QtNetwork
import org.kde.plasma.configuration
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.notification
import "./scripts/scoresAPI.js" as ScoresAPI

// Scoreboard Widget
// USA sports MLB,NBA,NFL,MLS,NHL,WNBA,World Cup
// txhammer 03/2026

PlasmoidItem {
    id: root
    fullRepresentation: FullRepresentation { }
    compactRepresentation: CompactRepresentation { }

    // --- Configuration Properties ---
    property bool isConfigured: false
    property string gameTypeIdx: plasmoid.configuration.gameIdx
    property string gameTypeURL:ScoresAPI.urls[gameTypeIdx]
    property bool viewMode:plasmoid.configuration.viewMode
    property bool autoUpdate:plasmoid.configuration.chkBoxUpdate
    property var scoreBoard:{}
    property bool activeGames:false

    property int viewHeight: viewMode ?  124 : 400
    property int viewWidth:420

    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property string updateURL:"https://raw.githubusercontent.com/txhammer68/scoreBoard/refs/heads/main/metadata.json"

    Component.onCompleted: {
        if (gameTypeURL.length > 0) {
            getData(gameTypeURL)
            autoUpdate ? getData(updateURL):""
            gameTimer.start()
        } else {
            isConfigured=false
            Plasmoid.configurationRequired = true
        }
    }

    onGameTypeURLChanged: {
        getData(gameTypeURL)
        gameTimer.start()
    }

    Plasmoid.contextualActions: [
        PlasmCore.Action {
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

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        // Set a timeout (10 seconds) so the widget doesn't hang on a dead connection
        xhr.timeout = 10000;
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText);
                        if (url === gameTypeURL) {
                            scoreBoard = data;
                            isConfigured = true;
                            Plasmoid.configurationRequired = false;
                            checkActiveGames();
                        } else if (url === updateURL) {
                            processUpdateData(data);
                        }
                    } catch (e) {
                        console.error("Failed to parse JSON from:", url, e);
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

    function checkActiveGames () {
          for (let i = 0; i < scoreBoard.events.length; i++) {
              if (scoreBoard.events[i].status.type.state == "in") {
                  activeGames=true
                  return null
              }
        }
        activeGames=false
        return null
    }

    function gameState(index) {
        if (scoreBoard.events[index].status.type.state == "pre") {
            return (Qt.formatDateTime(new Date(scoreBoard.events[index].date),"h:mm ap"))
        }
        else if (scoreBoard.events[index].status.type.state == "in") {
            if (scoreBoard.events[index].status.type.description != "In Progress") {
                return (scoreBoard.events[index].status.type.shortDetail)
            }
            return (scoreBoard.events[index].status.period+getOrdinal(scoreBoard.events[index].status.period))
        }
        else {
            return ( scoreBoard.events[index].status.type.shortDetail)
        }
    }

    function winningTeam (x,index){
        let c=Kirigami.Theme.textColor
        if (scoreBoard.events[index].status.type.state == "post") {
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
        interval: activeGames ? 5*60*1000 : 30*60*1000
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
        target: NetworkInformation
        function onReachabilityChanged(newReachability) {
            if (newReachability === NetworkInformation.Online) {
                suspendTimer.start();
            }
        }
    }
}
