import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: main
    anchors.top:parent.top
    anchors.left:parent.left
    anchors.margins:20
    width:parent.width
    height:parent.height

    property alias cfg_gameIdx:sportSel.currentIndex
    property string cfg_gameTypeURL
    property string cfg_favTeam:""
    property int cfg_favTeamIdx:-1
    property alias cfg_chkBoxUpdate:chkBoxUpdate.checked
    property alias cfg_panelViewMode:chkBoxIcon.checked

    property bool cfg_chkBoxUpdateDefault:true
    property string cfg_favTeamDefault:""
    property int cfg_favTeamIdxDefault:-1
    property int cfg_gameIdxDefault:-1
    property string cfg_gameTypeURLDefault:""

    property string mlbTeams:"./scripts/mlbTeams.json"
    property string nflTeams:"./scripts/nflTeams.json"
    property string nbaTeams:"./scripts/nbaTeams.json"
    property string wnbaTeams:"./scripts/wnbaTeams.json"
    property string nhlTeams:"./scripts/nhlTeams.json"
    property string mlsTeams:"./scripts/mlsTeams.json"
    property string fifaTeams:"./scripts/fifaTeams.json"
    property var teamArray:[]
    property var teamInfo:[]

    property string updateURL:"https://raw.githubusercontent.com/txhammer68/scoreBoard/refs/heads/main/metadata.json"
    property string updateCMD:"git clone https://github.com/TxHammer68/scoreBoard /tmp/scoreBoard/ && kpackagetool6 -t Plasma/Applet -u /tmp/scoreBoard/"
    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property bool updateAvail:false
    property string updateMsg:"Updated Version Ready "+"("+updateVersion+")"

    readonly property bool inPanel:(Plasmoid.formFactor !== PlasmaCore.Types.Planar)

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Component.onCompleted:{
        chkBoxIcon.checked=cfg_panelViewMode
        chkBoxUpdate.checked=cfg_chkBoxUpdate
        if (cfg_gameIdx !== -1) {
            sportSel.currentIndex=cfg_gameIdx
            getSportData(cfg_gameIdx)
        }
        else {
            sportSel.currentIndex=-1;
        }
        chkBoxUpdate.checked ? getData(updateURL):""
    }

    Text {
          id:appVer
           anchors.top:main.top
           anchors.right:main.right
           anchors.rightMargin:40
           text:Plasmoid.metaData.version
           color:Kirigami.Theme.disabledTextColor
           font.pointSize:Kirigami.Theme.defaultFont.pointSize
       }

    Column {
        id:settingsInputs
        anchors.top:main.top
        anchors.left:main.left

        width:main.width*.98
        spacing:10

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
                displayText:currentIndex < 0 ? "Select Sport" : currentText
                model: ["MLB","MLS","NBA","NFL","NHL","WNBA","WCUP"]
                onCurrentIndexChanged:{
                    if (currentIndex < 0) return;
                    getSportData(sportSel.currentIndex)
                }
            }
        }

        Row {
            spacing:10
            Text {
                text:"Select Team"
                color:Kirigami.Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.ComboBox {
                id:teamSel
                width:192
                height:32
                currentIndex:-1
                displayText: currentIndex < 0 ? "Select Team" : currentText
                model: teamArray
                onActivated: {
                    cfg_favTeam=teamArray[currentIndex]
                    cfg_favTeamIdx=teamSel.currentIndex
                }
            }
        }

        Text {
            text:"Select Panel View"
            color:Kirigami.Theme.textColor
            font.pointSize:14
            topPadding:20
            visible:inPanel
        }
        Row {
            spacing:15
            visible:inPanel
            QQC2.RadioButton {
                id: chkBoxIcon
                checked: true
                text: qsTr("Icon View")
            }

            QQC2.RadioButton {
                id: chkBoxScroll
                checked: !chkBoxIcon.checked
                text: qsTr("Scrolling Scoreboard View")
            }
        }

        QQC2.CheckBox{
            id: chkBoxUpdate
            checked: true
            text: qsTr("Check for Updates")
            topPadding:20
        }

        Row {
            spacing:10
            visible:(updateAvail && chkBoxUpdate.checked)
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

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET",url,true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText)
                    if (url == mlbTeams) {
                        processTeamData(response)
                    }
                    else if (url == nflTeams) {
                        processTeamData(response)
                    }
                    else if (url == nbaTeams) {
                        processTeamData(response)
                    }
                    else if (url == nhlTeams) {
                        processTeamData(response)
                    }
                    else if (url == mlsTeams) {
                        processTeamData(response)
                    }
                    else if (url == wnbaTeams) {
                        processTeamData(response)
                    }
                    else if (url == fifaTeams) {
                        processTeamData(response)
                    }
                    else if (url == updateURL) {
                        processUpdateData(response)
                    }
                    if (url !== updateURL) {
                        if (cfg_favTeamIdx >= 0) {
                            teamSel.currentIndex = cfg_favTeamIdx
                        } else {
                            teamSel.currentIndex = -1
                        }
                    }
                }
            }
        };
        xhr.send();
    }

    function getSportData(x) {
        if (x == 0) {
            getData(mlbTeams)
        }
        else if (x == 1) {
            getData(mlsTeams)
        }
        else if (x == 2) {
            getData(nbaTeams)
        }
        else if (x == 3) {
            getData(nflTeams)
        }
        else if (x == 4) {
            getData(nhlTeams)
        }
        else if (x == 5) {
            getData(wnbaTeams)
        }
        else if (x == 6) {
            getData(fifaTeams)
        }
        return
    }

    function processTeamData(data) {
        let temp=[]
        for (let i=0;i<data.teams.length;i++) {
            temp.push(data.teams[i].name)
          }
        teamArray=temp
        cfg_gameTypeURL=data.scoresURL
        return
    }

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            updateAvail=true
          }
        return
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            let exitCode = scripts["exit code"]
            let exitStatus = scripts["exit status"]
            let stdout = scripts["stdout"]
            let stderr = scripts["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
          }
        function exec(cmd) {
            connectSource(cmd)
          }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }
}
