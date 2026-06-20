import QtQuick
import org.kde.kcmutils as KCM
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.configuration
import org.kde.kirigami.platform
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root
    property alias cfg_gameIdx:sportSel.currentIndex
    property string cfg_gameType
    property string cfg_gameTypeURL
    property alias cfg_favTeam:teamSel.displayText
    property alias cfg_favTeamIdx:teamSel.currentIndex
    property alias cfg_viewMode:chkBoxCompact.checked
    property alias cfg_chkBoxCompact:chkBoxCompact.checked
    property alias cfg_chkBoxFull:chkBoxFull.checked
    property alias cfg_chkBoxUpdate:chkBoxUpdate.checked

    property bool cfg_chkBoxCompactDefault:true
    property bool cfg_chkBoxFullDefault:false
    property bool cfg_chkBoxUpdateDefault:true
    property string cfg_favTeamDefault:""
    property int cfg_favTeamIdxDefault:-1
    property int cfg_gameIdxDefault:-1
    property string cfg_gameTypeDefault:""
    property string cfg_gameTypeURLDefault:""
    property bool cfg_viewModeDefault:true

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

    Component.onCompleted:{
        chkBoxCompact.checked=cfg_chkBoxCompact
        chkBoxFull.checked=cfg_chkBoxFull
        chkBoxUpdate.checked=cfg_chkBoxUpdate
        chkBoxNotify.checked=cfg_chkBoxNotify
        if (sportSel.currentIndex !== -1) {
            sportSel.currentIndex=cfg_gameIdx
            getSportData(sportSel.currentIndex)
            teamSel.currentIndex=cfg_favTeamIdx
        }
        //teamSel.currentIndex=cfg_favTeamIdx
        chkBoxUpdate.checked ? getData(updateURL):""
       }

       Row {
           id:appInfo
           anchors.top:root.top
           anchors.right:root.right
           //anchors.margins:10
           Text {
               id:appVer
               anchors.top:parent.top
               anchors.right:parent.right
               //anchors.topMargin:-20
               //anchors.rightMargin:10
               text:Plasmoid.metaData.version
               color:Theme.disabledTextColor
               font.pointSize:11
           }
       }

    Column {
        id:settingsInputs
        anchors.top:root.top
        anchors.left:root.left
        leftPadding:20
        width:root.width*.98
        spacing:10

        Row {
            spacing:10
            Text {
                text:"Select Sport"
                color:Theme.textColor
                topPadding:7
                width:172
            }
            QQC2.ComboBox {
                id:sportSel
                width:196
                height:32
                currentIndex:-1
                displayText: currentIndex < 0 ? "Select Sport" : model[currentIndex]
                model: ["MLB","NFL","NBA","NHL","MLS","WNBA","WCUP"]
                onCurrentIndexChanged:{
                    cfg_gameType=model[currentIndex]
                    getSportData(currentIndex)
                    //teamSel.currentIndex=-1
                }
            }
        }

        Row {
            spacing:10
            Text {
                text:"Select Team"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.ComboBox {
                id:teamSel
                width:192
                height:32
                currentIndex:-1
                //textRole:"text"
                //valueRole:"value"
                displayText: currentIndex < 0 ? "Select Team" : teamArray[currentIndex]
                model: teamArray
                onCurrentIndexChanged: {
                    cfg_favTeam=teamArray[currentIndex]
                    //cfg_favTeamURL=teamInfo.teams[currentIndex].url
                    //cfg_favTeamID=cfg_teamInfo.teams[currentIndex].id
                }
            }
        }

        Text {
            text:"Select Scoreboard View"
            color:Kirigami.Theme.textColor
            font.pointSize:14
        }
        Row {
            spacing:15
            QQC2.RadioButton {
                id: chkBoxCompact
                checked: true
                text: qsTr("Compact View")
            }

            QQC2.RadioButton {
                id: chkBoxFull
                checked: false
                text: qsTr("Full View")
            }
        }

        QQC2.CheckBox{
            id: chkBoxUpdate
            checked: true
            text: qsTr("Check for Updates")
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
        xhr.open("GET", url,false);
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
                }
            }
        }
        xhr.send();
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
        else if (x == 6) {
            getData(fifaTeams)
        }
    }

    function processTeamData(data) {
        let temp=[]
        for (let i=0;i<data.teams.length;i++) {
            temp.push(data.teams[i].name)
        }
        teamArray=temp
        cfg_gameTypeURL=data.scoresURL
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
