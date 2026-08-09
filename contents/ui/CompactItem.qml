import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRep

    MouseArea {
        id: mouseArea
        anchors.fill: compactRep
        onClicked: {
            root.expanded = !root.expanded
        }
    }

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
        color: Kirigami.Theme.textColor
        font.pointSize: panelThickness * 0.35
        antialiasing : true
        opacity:Plasmoid.configurationRequired ? 1 : activeGames ? 1:.40
        leftPadding:6
        visible:panelViewMode
    }

    Component {
        id:scoreboard

        Row {
            height:panelThickness+10
            width:panelThickness*10
            spacing:0
            Layout.fillWidth:true

            Image {
                id:atl
                source:scoreBoard[index].awayTeamLogo
                width:parent.height * 0.68
                sourceSize.height:height
                sourceSize.width:width
                Layout.fillWidth:true
                antialiasing:true
                fillMode:Image.PreserveAspectFit
            }

            Text {
                id:ateam
                text:scoreBoard[index].awayTeamAbrv
                color:Kirigami.Theme.textColor
                font.pointSize: parent.height * 0.35
                leftPadding:8
                topPadding:3
                Layout.fillWidth:true
                width:parent.height * 1.54
                antialiasing : true
            }

            Text {
                id:ats
                text:scoreBoard[index].awayTeamScore
                color:Kirigami.Theme.textColor
                font.pointSize: parent.height * 0.35
                width:parent.height * 0.84
                Layout.fillWidth:true
                topPadding:3
                antialiasing : true
            }

            Text {
                id:gameStatus
                text:gameState(index)
                color: (scoreBoard[index].gameStatusState == "in") ? "green" : (scoreBoard[index].gameStatusState == "post") ? "red" : Kirigami.Theme.disabledTextColor
                font.pointSize: parent.height * 0.25
                topPadding:6
                leftPadding:6
                width:parent.height * 1.64
                Layout.fillWidth:true
                antialiasing : true
            }

            Text {
                id:hts
                text:scoreBoard[index].homeTeamScore
                color:Kirigami.Theme.textColor
                font.pointSize: parent.height * 0.35
                width:parent.height * 0.72
                Layout.fillWidth:true
                topPadding:3
                antialiasing : true
            }

            Text {
                id:hta
                text:scoreBoard[index].homeTeamAbrv
                color:Kirigami.Theme.textColor
                font.pointSize: parent.height * 0.35
                width:parent.height * 1.24
                Layout.fillWidth:true
                topPadding:3
                leftPadding:12
                antialiasing : true
            }

            Image{
                id:htl
                source:scoreBoard[index].homeTeamLogo
                width:parent.height * 0.68
                Layout.fillWidth:true
                sourceSize.height:height
                sourceSize.width:width
                antialiasing:true
                fillMode:Image.PreserveAspectFit
            }
        }
    }

    Component {
        id: highlight
        Rectangle {
            width: scoresList.width; height: scoresList.height
            color: "transparent";
            y: scoresList.currentItem.y
            Behavior on y {
                // smooth scroll animation
                NumberAnimation {
                    id:smoothScroll
                    duration: 1100
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Timer {
        id:init
        running:!panelViewMode
        repeat:true
        interval:5000
        onTriggered:{
            if (scoresList.currentIndex >= scoreBoard.length-1) {
                scoresList.currentIndex=-1
                scoresList.incrementCurrentIndex();
            }
            else scoresList.incrementCurrentIndex();
        }
    }

    ListView {
        id:scoresList
        anchors.horizontalCenter:compactRep.horizontalCenter
        anchors.verticalCenter:compactRep.verticalCenter
        width:panelThickness*10
        height:panelThickness
        spacing:2
        clip:true
        model: scoreBoard.length
        highlight:highlight
        highlightMoveDuration:1000
        highlightMoveVelocity:-1
        highlightFollowsCurrentItem:scoresList.currentIndex != -1 ? true:false
        delegate:scoreboard
        visible:!panelViewMode
        MouseArea {
            anchors.fill:parent
            onClicked: (mouse)=> {
                mouse.button == Qt.LeftButton ?  root.expanded = !root.expanded : getData(gameTypeURL)
            }
        }
    }
}
