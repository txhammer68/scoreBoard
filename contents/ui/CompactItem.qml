import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRep

    function getGameType () {
        if (gameTypeIdx == 0) {
            return "⚾" }
        else if (gameTypeIdx == 1) {
            return "⚽" }
        else if (gameTypeIdx == 2) {
            return "🏀" }
        else if (gameTypeIdx == 3) {
            return "🏈" }
        else if (gameTypeIdx == 4) {
            return "🏒" }
        else if (gameTypeIdx == 5) {
            return "🏀" }
        else if (gameTypeIdx == 6) {
            return "⚽" }
    }

    Text {
        anchors.centerIn: parent
        text:Plasmoid.configurationRequired ? "?":getGameType ()
        color: textColor
        font.pointSize: panelThickness * 0.35
        antialiasing : true
        opacity:Plasmoid.configurationRequired ? 1 : activeGames ? 1:.40
        leftPadding:6
        visible:panelViewMode
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                root.expanded = !root.expanded
            }
        }
    }

    Component {
        id:scoreboard

        Row {
            height:panelThickness+10
            width:panelThickness*7
            topPadding:7
            spacing:0
            Layout.fillWidth:true

            Image {
                id:atl
                source:scoreBoard[index].awayTeamLogo
                width:parent.height * 0.48
                Layout.fillWidth:true
                smooth:true
                fillMode:Image.PreserveAspectFit
                anchors.topMargin:5
            }

            Text {
                id:ateam
                text:scoreBoard[index].awayTeamAbrv
                color:textColor
                font.pointSize: parent.height * 0.19
                topPadding:5
                leftPadding:8
                Layout.fillWidth:true
                width:parent.height * .95
                antialiasing : true
            }

            Text {
                id:ats
                text:scoreBoard[index].awayTeamScore
                color:textColor
                font.pointSize: parent.height * 0.19
                width:parent.height * 0.70
                Layout.fillWidth:true
                topPadding:5
                antialiasing : true
            }

            Text {
                id:gameStatus
                text:gameState(index)
                color: (scoreBoard[index].gameStatusState == "in") ? "green" : (scoreBoard[index].gameStatusState == "post") ? "red" : disabledTextColor
                font.pointSize: parent.height * 0.18
                topPadding:5
                leftPadding:6
                width:parent.height * 1.4
                Layout.fillWidth:true
                antialiasing : true
            }

            Text {
                id:hts
                text:scoreBoard[index].homeTeamScore
                color:textColor
                font.pointSize: parent.height * 0.19
                width:parent.height * 0.4
                Layout.fillWidth:true
                topPadding:5
                antialiasing : true
            }

            Text {
                id:hta
                text:scoreBoard[index].homeTeamAbrv
                color:textColor
                font.pointSize: parent.height * 0.19
                width:parent.height * 0.89
                Layout.fillWidth:true
                topPadding:5
                leftPadding:12
                antialiasing : true
            }

            Image{
                id:htl
                source:scoreBoard[index].homeTeamLogo
                width:parent.height * 0.48
                Layout.fillWidth:true
                smooth:true
                fillMode:Image.PreserveAspectFit
                anchors.topMargin:5
            }
        }
    }

    PathView {
        id: scoresList
        anchors.fill:parent
        model: !panelViewMode ? scoreBoard.length : 1
        clip: true
        anchors.margins:4
        pathItemCount: 1
        preferredHighlightBegin: .5
        preferredHighlightEnd: .5
        highlightRangeMode: PathView.StrictlyEnforced
        highlightMoveDuration: 1000
        visible:!panelViewMode

        MouseArea {
            anchors.fill:parent
            onClicked: (mouse)=> {
                mouse.button == Qt.LeftButton ?  root.expanded = !root.expanded : getData(gameTypeURL)
            }
            onWheel: (event) => {
                if (event.angleDelta.y > 0) {
                    // Scroll up -> previous item
                    scoresList.decrementCurrentIndex();
                } else if (event.angleDelta.y < 0) {
                    // Scroll down -> next item
                    scoresList.incrementCurrentIndex();
                }
                event.accepted = true
            }
        }

        path: Path {
            startX: scoresList.width/1.95
            startY: -panelThickness*.95
            PathLine {
                x: scoresList.width/1.95
                y: panelThickness*2//!inPanel ?  scoresList.height+130:viewHeight
            }
        }

        delegate: !panelViewMode ? scoreboard : undefined

        Timer {
            running: !panelViewMode
            repeat: true
            interval:7000
            onTriggered:scoresList.incrementCurrentIndex();
        }
    }
}
