import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: configScoreBoard
    property string title:"Scoreboard Settings"
    property alias cfg_gameIdx:sportSel.currentIndex
    property string cfg_gameType
    property string cfg_gameTypeURL
    property alias cfg_viewMode:chkBoxCompact.checked
    property alias cfg_chkBoxCompact:chkBoxCompact.checked
    property alias cfg_chkBoxFull:chkBoxFull.checked

    property string updateURL:"https://raw.githubusercontent.com/txhammer68/scoreBoard/refs/heads/main/metadata.json"
    property string updateCMD:"git clone https://github.com/TxHammer68/scoreBoard /tmp/scoreBoard/ && kpackagetool6 -t Plasma/Applet -u /tmp/scoreBoard/"
    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property bool updateAvail:false
    property string updateMsg:"Updated Version Ready "+"("+updateVersion+")"

    property string mlbTeams:"./data/mlbTeams.json"
    property string nflTeams:"./data/nflTeams.json"
    property string nbaTeams:"./data/nbaTeams.json"
    property string wnbaTeams:"./data/wnbaTeams.json"
    property string nhlTeams:"./data/nhlTeams.json"
    property string mlsTeams:"./data/mlsTeams.json"

   Component.onCompleted:{
        getData(updateURL)
        sportSel.currentIndex=cfg_gameIdx
        chkBoxCompact.checkState=cfg_chkBoxCompact
        chkBoxFull.checkState=cfg_chkBoxFull
        if (sportSel.currentIndex != -1) {
            getSportData(sportSel.currentIndex)
        }
    }

    Text {
        id:appVer
        anchors.top:configScoreBoard.top
        anchors.right:configScoreBoard.right
        anchors.margins:10
        text:Plasmoid.metaData.version
        color:Kirigami.Theme.disabledTextColor
        font.pointSize:11
    }

    Column {
        id:settingsInputs
        anchors.top:configScoreBoard.top
        anchors.left:configScoreBoard.left
        leftPadding:20
        width:configScoreBoard.width-50
        spacing:20

        Text {
            text:"Scoreboard Settings"
            color:Kirigami.Theme.textColor
            font.pointSize:16
        }

        Row {
            spacing:10
            Text {
                text:"Select Sport"
                color:Kirigami.Theme.textColor
                topPadding:7
                width:172
            }
            QQC2.ComboBox {
                id:sportSel
                width:196
                height:32
                currentIndex:-1
                displayText: currentIndex < 0 ? "Select Sport" : model[currentIndex]
                model: ["MLB","NFL","NBA","NHL","MLS","WNBA"]
                onCurrentIndexChanged:{
                    cfg_gameType=model[currentIndex]
                    getSportData(currentIndex)
                }
           }
        }

        QQC2.ButtonGroup { id: viewSel;exclusive: true }

        Text {
            text:"Select Scoreboard View"
            color:Kirigami.Theme.textColor
            font.pointSize:14
        }
        Row {
            spacing:15
            QQC2.CheckBox {
                id: chkBoxCompact
                checked: true
                tristate : false
                QQC2.ButtonGroup.group: viewSel
                text: qsTr("Compact View")
            }

            QQC2.CheckBox {
                id: chkBoxFull
                checked: false
                tristate : false
                QQC2.ButtonGroup.group: viewSel
                text: qsTr("Full View")
            }
        }

        Row {
            spacing:10
            visible:updateAvail
            Rectangle {
                id:updateWidget
                width:120
                height:32
                color:"transparent"
                border.color:updateAvail ? Kirigami.Theme.linkColor:Kirigami.Theme.disabledTextColor
                radius:6
                Text {
                    text:"Update Widget"
                    color:updateAvail ?  Kirigami.Theme.textColor:Kirigami.Theme.disabledTextColor
                    anchors.centerIn:parent
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: updateAvail ? Qt.PointingHandCursor:Qt.ArrowCursor
                    hoverEnabled:updateAvail
                    onClicked:{
                        updateAvail ? executable.exec(updateCMD):""
                    }
                }
            }
            Text {
                text:updateMsg
                color:Kirigami.Theme.textColor
                font.pointSize:11
                topPadding:5
                visible:updateAvail
            }
        }
    }

    function getSportData(x) {
        if (x == 0) {
            getData(mlbTeams)
        }
        else if (x == 1) {
            getData(nflTeams)
        }
        else if (x == 2) {
            getData(nbaTeams)
        }
        else if (x == 3) {
            getData(nhlTeams)
        }
        else if (x == 4) {
            getData(mlsTeams)
        }
        else if (x == 5) {
            getData(wnbaTeams)
        }
     }

    function getData(url) {
        let xhr = new XMLHttpRequest()
        xhr.open("GET", url,true)
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                    let data = JSON.parse(xhr.responseText)
                    if (url == updateURL) {
                         processUpdateData(data)
                    }
                    else processTeamData(data)
                }
            }
        xhr.send()
    }

    function processTeamData(data) {
        cfg_gameTypeURL=data.scoresURL
        return null
    }

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            updateAvail=true
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            let exitCode = data["exit code"]
            let exitStatus = data["exit status"]
            let stdout = data["stdout"]
            let stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }
}
