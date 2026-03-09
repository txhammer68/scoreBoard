import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: fullRepresentation
    Layout.preferredWidth:fullRepresentation.width
    Layout.preferredHeight:fullRepresentation.height
    Layout.minimumWidth:120
    Layout.maximumWidth:460
    width:viewWidth
    height:viewHeight

    Connections { // reset scoreboad views after popup closed
        target: root
        function onExpandedChanged() {
            scoresList.positionViewAtBeginning()
        }
    }

   Component.onCompleted:{
       Layout.preferredWidth=viewWidth
       Layout.preferredHeight=viewHeight
   }

   onHeightChanged:{
       Layout.preferredWidth=viewWidth
       Layout.preferredHeight=viewHeight
       width:viewWidth
       height:viewHeight
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
                    mouse.button == Qt.LeftButton ? Qt.openUrlExternally(scoreBoard.events[index].links[0].href) : getData(gameTypeURL)
                }
            }

            Column {
                id:gameTimes
                anchors.horizontalCenter:parent.horizontalCenter
                anchors.verticalCenter:parent.verticalCenter
                spacing:1
                topPadding:-5
                leftPadding:20
                Text {
                    id:gameStatus
                    leftPadding:10
                    text:gameState(index).split(',')[0]
                    color:(scoreBoard.events[index].status.type.state == "in") ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                    font.pointSize:10
                    anchors.horizontalCenter:parent.horizontalCenter
                }

                Text {
                    text:(scoreBoard.events[index].status.type.state == "in") ? scoreBoard.events[index].status.displayClock : Qt.formatDateTime(new Date(scoreBoard.events[index].date),"M/dd/yy")
                    leftPadding:10
                    color:(scoreBoard.events[index].status.type.state == "in") ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                    font.pointSize:10
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
                        source: scoreBoard.events[index].competitions[0].competitors[0].team.logo
                        width:48
                        horizontalAlignment:Qt.AlignLeft
                        sourceSize.height:height
                        sourceSize.width:width
                        antialiasing:true
                        fillMode:Image.PreserveAspectFit
                    }

                    Text {
                        id:ateam
                        text:scoreBoard.events[index].competitions[0].competitors[0].team.displayName
                        color:Kirigami.Theme.textColor
                        font.pointSize:14
                        width:80
                        leftPadding:10
                        Layout.fillWidth:true
                        horizontalAlignment:Qt.AlignLeft
                    }

                    Text {
                        id:ats
                        text:scoreBoard.events[index].competitions[0].competitors[0].score
                        color:scoreBoard.events[index].competitions[0].competitors[0].hasOwnProperty("winner") ? winningTeam(scoreBoard.events[index].competitions[0].competitors[0].winner,index):Kirigami.Theme.textColor
                        font.pointSize:14
                        font.bold:false
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
                        source: scoreBoard.events[index].competitions[0].competitors[1].team.logo
                        width:48
                        sourceSize.height:height
                        sourceSize.width:width
                        antialiasing:true
                        fillMode:Image.PreserveAspectFit
                    }

                    Text {
                        id:hta
                        text:scoreBoard.events[index].competitions[0].competitors[1].team.displayName
                        color:Kirigami.Theme.textColor
                        font.pointSize:14
                        width:80
                        leftPadding:10
                        horizontalAlignment:Qt.AlignLeft
                        Layout.fillWidth:true
                    }

                    Text {
                        id:hts
                        text: scoreBoard.events[index].competitions[0].competitors[1].score
                        color:scoreBoard.events[index].competitions[0].competitors[1].hasOwnProperty("winner") ? winningTeam(scoreBoard.events[index].competitions[0].competitors[1].winner,index):Kirigami.Theme.textColor
                        font.pointSize:14
                        font.bold:false
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
                text:scoreBoard.events[index].competitions[0].hasOwnProperty("headlines") ? scoreBoard.events[index].competitions[0].headlines[0].shortLinkText : ""
                color:Kirigami.Theme.textColor
                font.pointSize:10
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
            anchors.top:fullRepresentation.top
            anchors.left:fullRepresentation.left
            anchors.margins:4
            height:viewHeight
            width:fullRepresentation.width
            spacing:viewMode ? 2:8
            clip:true
            model: scoreBoard.events.length
            highlight:highlight
            highlightMoveDuration:1000
            highlightMoveVelocity:-1
            highlightFollowsCurrentItem:scoresList.currentIndex !== -1 ? true:false
            delegate:fullRep

            Timer {
                id:init
                running:viewMode
                repeat:true
                interval:10000
                onTriggered:{
                    if (scoresList.currentIndex >= scoreBoard.events.length-1) {
                        scoresList.currentIndex=-1
                        scoresList.incrementCurrentIndex();
                    }
                    else scoresList.incrementCurrentIndex();
                }
            }
        }
}
