import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: fullRepresentation
    Layout.preferredWidth:viewWidth
    Layout.preferredHeight:viewHeight+10
    Layout.minimumWidth:viewWidth/2
    Layout.maximumWidth:viewWidth*1.5
    Layout.minimumHeight:100
    Layout.maximumHeight:132*6

    width:viewWidth
    height:viewHeight

    Connections { // reset scoreboad views after popup closed
        target: root
        function onExpandedChanged() {
            scoresList.positionViewAtBeginning()
        }
    }

    Component {
        id: highlight
        Rectangle {
            width: scoresList.width; height: scoresList.height
            color: "transparent";
            y: scoresList.currentItem.y ? scoresList.currentItem.y:0
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

    Component {
        id: configRepresentation

        Rectangle {
            visible:Plasmoid.configurationRequired
            anchors.fill:parent
            color:"transparent"
            radius:6
            antialiasing : true
            border.color:Kirigami.Theme.disabledTextColor

            Text {
                text:"Configure ScoreBoard"
                color:Kirigami.Theme.textColor
                anchors.centerIn:parent
                font.pointSize:14
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onEntered: parent.border.color=Kirigami.Theme.linkColor
                onExited:parent.border.color=Kirigami.Theme.textColor
                onClicked:plasmoid.internalAction("configure").trigger()
            }
        }
}

    Component {
        id: fullRep

        Rectangle {
            id:rect1
            width:fullRepresentation.width*.98
            height:124
            Layout.fillWidth : true
            Layout.fillHeight : true
            antialiasing : true
            color:Kirigami.Theme.backgroundColor
            radius:6

            MouseArea {
                id: mouseArea1a
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                hoverEnabled:true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onEntered:parent.color=Kirigami.Theme.activeBackgroundColor
                onExited:parent.color=Kirigami.Theme.backgroundColor
                onClicked: (mouse)=> {
                    mouse.button == Qt.LeftButton ? Qt.openUrlExternally(scoreBoard[index].gameBoxScoresURL) : getData(gameTypeURL)
                }
            }

            Column {
                id:gameTimes
                anchors.verticalCenter:parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin:290
                spacing:0
                topPadding:-4
                Text {
                    id:gameStatus
                    text:gameState(index).split(',')[0]
                    color: (scoreBoard[index].gameStatusState == "in") ? "green" : (scoreBoard[index].gameStatusState == "post") ? "red" : Kirigami.Theme.disabledTextColor
                    font.pointSize:11
                    antialiasing:true
                    anchors.horizontalCenter:parent.horizontalCenter
                }

                Text {
                    text:(scoreBoard[index].gameStatusState == "in") ? scoreBoard[index].leagueAbbreviation !== "MLB" ? scoreBoard[index].gameClock : "" : Qt.formatDateTime(new Date(scoreBoard[index].gameDate),"M/dd/yy")
                    color:(scoreBoard[index].gameStatusState == "in") ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                    font.pointSize:11
                    antialiasing:true
                    anchors.horizontalCenter:parent.horizontalCenter
                }
            }

            ColumnLayout {
                spacing:0
                width:parent.width-16
                height:parent.height-12
                anchors.top:parent.top
                anchors.left:parent.left

                RowLayout {
                    spacing:2
                    width:parent.width-10
                    Layout.fillWidth:true

                    Image {
                        id:atl
                        source: scoreBoard[index].awayTeamLogo
                        width:48
                        horizontalAlignment:Qt.AlignLeft
                        sourceSize.height:height
                        sourceSize.width:width
                        antialiasing:true
                        fillMode:Image.PreserveAspectFit
                    }

                    Text {
                        id:ateam
                        text:scoreBoard[index].awayTeamName
                        color:Kirigami.Theme.textColor
                        font.pointSize:14
                        antialiasing : true
                        width:80
                        leftPadding:10
                        Layout.fillWidth:true
                        horizontalAlignment:Qt.AlignLeft
                    }

                    Text {
                        id:ats
                        text:scoreBoard[index].awayTeamScore
                        color:winningTeam(scoreBoard[index].awayTeamWinner,index)
                        font.pointSize:14
                        font.bold:false
                        antialiasing : true
                        horizontalAlignment:Qt.AlignLeft
                        Layout.fillWidth:false
                        bottomPadding:5
                        rightPadding:10
                    }
                }

                RowLayout {
                    width:parent.width-10
                    Layout.fillWidth:true
                    spacing:0
                    Layout.topMargin:10

                    Image{
                        id:htl
                        source: scoreBoard[index].homeTeamLogo
                        width:48
                        sourceSize.height:height
                        sourceSize.width:width
                        antialiasing:true
                        fillMode:Image.PreserveAspectFit
                    }

                    Text {
                        id:hta
                        text:scoreBoard[index].homeTeamName
                        color:Kirigami.Theme.textColor
                        font.pointSize:14
                        antialiasing : true
                        width:80
                        leftPadding:10
                        horizontalAlignment:Qt.AlignLeft
                        Layout.fillWidth:true
                    }

                    Text {
                        id:hts
                        text: scoreBoard[index].homeTeamScore
                        color:winningTeam(scoreBoard[index].homeTeamWinner,index)
                        font.pointSize:14
                        font.bold:false
                        antialiasing : true
                        horizontalAlignment:Qt.AlignLeft
                        bottomPadding:5
                        rightPadding:10
                        Layout.fillWidth:false
                    }
                }
            }
            Text {
                anchors.bottom:rect1.bottom
                anchors.left:rect1.left
                text:scoreBoard[index].gameHeadline
                color:Kirigami.Theme.textColor
                font.pointSize:10
                antialiasing : true
                horizontalAlignment:Qt.AlignLeft
                leftPadding:5
                topPadding:2
                width:rect1.width
                Layout.fillWidth:true
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }
        }
    }

        ListView {
            id:scoresList
            Layout.fillWidth: true
            Layout.fillHeight: true
            width: fullRepresentation.width
            height: fullRepresentation.height
            anchors.top:fullRepresentation.top
            anchors.left:fullRepresentation.left
            anchors.margins:4
            spacing:viewMode ? 2:4
            clip:true
            model: Plasmoid.configurationRequired ? 1:scoreBoard.length
            highlight:highlight
            highlightMoveDuration:1000
            highlightMoveVelocity:-1
            highlightFollowsCurrentItem:scoresList.currentIndex !== -1 ? true:false
            delegate:Plasmoid.configurationRequired ? configRepresentation:fullRep

            Timer {
                id:init
                running:viewMode && !Plasmoid.configurationRequired
                repeat: true
                interval:10000
                onTriggered:{
                    if (scoresList.currentIndex >= scoreBoard.length-1) {
                        scoresList.currentIndex=-1
                        scoresList.incrementCurrentIndex();
                    }
                    else scoresList.incrementCurrentIndex();
                }
            }
    }
}
