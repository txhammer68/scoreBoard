import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid

Item {
    id: fullRepresentation
    Layout.preferredWidth:viewWidth
    Layout.preferredHeight:viewHeight

    Connections { // reset scoreboad views after popup closed
        target: root
        function onExpandedChanged() {
            viewLoad.item.positionViewAtBeginning()
            }
        }

        Button {
            text: "Configure ScoreBoard"
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.verticalCenter:parent.verticalCenter
            visible: Plasmoid.configurationRequired // Only shows if the config is missing
            onClicked: {
                // Triggers the system's native configure action manually
                plasmoid.internalAction("configure").trigger()
            }
        }

    Loader {
        id:viewLoad
        anchors.fill: parent
        sourceComponent: !inPanel ? desktopRepresentation : panelRepresentation
        active:!Plasmoid.configurationRequired//true
    }

    Component {
        id: fullRep

        Rectangle {
            id:rect1
            width:fullRepresentation.width-4
            height:128
            Layout.fillWidth : true
            Layout.fillHeight : true
            antialiasing : true
            color:backgroundColor
            radius:6

            MouseArea {
                id: mouseArea1a
                anchors.fill: rect1
                cursorShape:  Qt.PointingHandCursor
                hoverEnabled:true
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onEntered:rect1.color=activeBackgroundColor
                onExited:rect1.color=backgroundColor
                onClicked: (mouse)=> {
                    mouse.button == Qt.LeftButton ? Qt.openUrlExternally(scoreBoard[index].gameBoxScoresURL) : getData(gameTypeURL)
                }
                onWheel: (event) => {
                    // Automatically fetch the parent view (either PathView or ListView)
                    let view = rect1.ListView.view || rect1.PathView.view;

                    if (view) {
                        if (event.angleDelta.y > 0) {
                            // Scroll up -> previous item
                            view.decrementCurrentIndex();
                        } else if (event.angleDelta.y < 0) {
                            // Scroll down -> next item
                            view.incrementCurrentIndex();
                        }
                        event.accepted = true;
                    }
                }
            }

            Column {
                id:gameTimes
                anchors.verticalCenter:parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin:260
                spacing:0
                topPadding:1
                Text {
                    id:gameStatus
                    text:gameState(index).split(',')[0]
                    color: (scoreBoard[index].gameStatusState == "in") ? "green" : (scoreBoard[index].gameStatusState == "post") ? "red" : disabledTextColor
                    font.pointSize:smallFontSize
                    antialiasing:true
                    leftPadding:(scoreBoard[index].gameStatusState == "in") ? 4:0
                    anchors.horizontalCenter:parent.horizontalCenter
                }

                Text {
                    text:(scoreBoard[index].gameStatusState == "in") ? scoreBoard[index].leagueAbbreviation !== "MLB" ? scoreBoard[index].gameClock : "" : Qt.formatDateTime(new Date(scoreBoard[index].gameDate),"M/dd/yy")
                    color:(scoreBoard[index].gameStatusState == "in") ? textColor : disabledTextColor
                    font.pointSize:smallFontSize
                    antialiasing:true
                    anchors.horizontalCenter:parent.horizontalCenter
                }
            }

            ColumnLayout {
                spacing:0
                width:parent.width-16
                height:parent.height-16
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.leftMargin:10

                RowLayout {
                    spacing:2
                    width:parent.width-10
                    Layout.fillWidth:true

                    Image {
                        id:atl
                        source: scoreBoard[index].awayTeamLogo
                        width:iconSizeMed
                        height:iconSizeMed
                        sourceSize.height:height
                        sourceSize.width:width
                        horizontalAlignment:Qt.AlignLeft
                        smooth:true
                        fillMode:Image.PreserveAspectFit
                    }

                    Text {
                        id:ateam
                        text:scoreBoard[index].awayTeamName
                        color:textColor
                        font.pointSize:defaultFontSize+2
                        antialiasing : true
                        width:80
                        leftPadding:10
                        Layout.fillWidth:true
                        horizontalAlignment:Qt.AlignLeft
                    }

                    Text {
                        id:ats
                        text:scoreBoard[index].awayTeamScore
                        color:winningTeam (scoreBoard[index].awayTeamWinner,index)
                        font.bold:scoreBoard[index].awayTeamWinner
                        font.pointSize:defaultFontSize+3
                        antialiasing : true
                        horizontalAlignment:Qt.AlignLeft
                        Layout.fillWidth:false
                        topPadding:6
                        rightPadding:20
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
                        width:iconSizeMed
                        height:iconSizeMed
                        sourceSize.height:height
                        sourceSize.width:width
                        smooth:true
                        fillMode:Image.PreserveAspectFit
                        horizontalAlignment:Qt.AlignLeft
                    }

                    Text {
                        id:hta
                        text:scoreBoard[index].homeTeamName
                        color:textColor
                        font.pointSize:defaultFontSize+2
                        antialiasing : true
                        width:80
                        leftPadding:10
                        horizontalAlignment:Qt.AlignLeft
                        Layout.fillWidth:true
                    }

                    Text {
                        id:hts
                        text: scoreBoard[index].homeTeamScore
                        color:winningTeam (scoreBoard[index].homeTeamWinner,index)
                        font.bold:scoreBoard[index].homeTeamWinner
                        font.pointSize:defaultFontSize+3
                        antialiasing : true
                        horizontalAlignment:Qt.AlignLeft
                        rightPadding:20
                        topPadding:6
                        Layout.fillWidth:false
                    }
                }
            }
            Text {
                anchors.bottom:rect1.bottom
                anchors.left:rect1.left
                text:scoreBoard[index].gameHeadline
                color:disabledTextColor
                font.pointSize:smallFontSize
                antialiasing : true
                horizontalAlignment:Qt.AlignLeft
                leftPadding:5
                topPadding:2
                width:rect1.width*.97
                Layout.fillWidth:true
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }
        }
    }


    Component {
        id: desktopRepresentation

    PathView {
        id: scoresList
        anchors.fill:parent
        model: Plasmoid.configurationRequired ? 0:scoreBoard.length
        clip: true
        //anchors.margins:4
        pathItemCount: inPanel ? scoreBoard.length > 4 ? 4 : scoreBoard.length : 1
        preferredHighlightBegin: !inPanel ? .5 : 0
        preferredHighlightEnd: !inPanel ? .5 : 0
        highlightRangeMode: PathView.StrictlyEnforced
        highlightMoveDuration: 350

        path: Path {
            startX: scoresList.width/1.95
            startY: !inPanel ? -128:0
            PathLine {
                x: scoresList.width/1.95
                y: !inPanel ?  scoresList.height+130:viewHeight
            }
        }

        delegate: Plasmoid.configurationRequired ? undefined:fullRep

        Timer {
            id:init
            running:!inPanel && !Plasmoid.configurationRequired
            repeat: true
            interval:7000
            onTriggered:scoresList.incrementCurrentIndex()
            }
        }
    }

    Component {
        id: panelRepresentation

        ListView {
            id:scoresList
            anchors.fill:fullRepresentation
            anchors.margins:4
            spacing:4
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: 0
            clip:true
            interactive: false
            model: Plasmoid.configurationRequired ? 0:scoreBoard.length
            highlight:highlight
            highlightMoveDuration:500
            highlightMoveVelocity:-1
            highlightFollowsCurrentItem:true
            delegate:Plasmoid.configurationRequired ? undefined:fullRep
        }
    }
}
