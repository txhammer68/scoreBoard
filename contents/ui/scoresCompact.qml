 Component {
     id: scollView

     Column {
         spacing:2
         width:parent.width
         height:parent.height
         anchors.top:parent.top
         anchors.left:parent.left

         Text {
             id:gameStatus
             text:gameState(index).split(',')[0]
             color: (scoreBoard[index].gameStatusState == "in") ? "green" : (scoreBoard[index].gameStatusState == "post") ? "red" : Kirigami.Theme.disabledTextColor
             font.pointSize:9
             antialiasing:true
             horizontalAlignment:Qt.AlignCenter
         }

         Text {
             text:(scoreBoard[index].gameStatusState == "in") ? scoreBoard[index].leagueAbbreviation !== "MLB" ? scoreBoard[index].gameClock : "" : Qt.formatDateTime(new Date(scoreBoard[index].gameDate),"M/dd/yy")
             color:(scoreBoard[index].gameStatusState == "in") ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
             font.pointSize:9
             antialiasing:true
             horizontalAlignment:Qt.AlignCenter
         }

         RowLayout {
             spacing:2
             width:parent.width
             Layout.fillWidth:true

             Image {
                 id:atl
                 source: scoreBoard[index].awayTeamLogo
                 width:14
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
                 font.pointSize:12
                 antialiasing : true
                 leftPadding:4
                 Layout.fillWidth:true
                 horizontalAlignment:Qt.AlignLeft
             }

             Text {
                 id:ats
                 text:scoreBoard[index].awayTeamScore
                 color:winningTeam(scoreBoard[index].awayTeamWinner,index)
                 font.pointSize:12
                 font.bold:false
                 antialiasing : true
                 horizontalAlignment:Qt.AlignLeft
                 Layout.fillWidth:false
                 bottomPadding:1
                 rightPadding:4
             }
         }

         RowLayout {
             width:parent.width
             Layout.fillWidth:true
             spacing:2
             Layout.topMargin:1

             Image{
                 id:htl
                 source: scoreBoard[index].homeTeamLogo
                 width:14
                 sourceSize.height:height
                 sourceSize.width:width
                 antialiasing:true
                 fillMode:Image.PreserveAspectFit
             }

             Text {
                 id:hta
                 text:scoreBoard[index].homeTeamName
                 color:Kirigami.Theme.textColor
                 font.pointSize:11
                 antialiasing : true
                 leftPadding:2
                 horizontalAlignment:Qt.AlignLeft
                 Layout.fillWidth:true
             }

             Text {
                 id:hts
                 text: scoreBoard[index].homeTeamScore
                 color:winningTeam(scoreBoard[index].homeTeamWinner,index)
                 font.pointSize:11
                 font.bold:false
                 antialiasing : true
                 horizontalAlignment:Qt.AlignLeft
                 bottomPadding:1
                 rightPadding:1
                 Layout.fillWidth:false
             }
         }
     }
 }
