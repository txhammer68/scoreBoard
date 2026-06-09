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
        if (gameType == "MLB") {
            return "⚾" }
        else if (gameType == "NFL") {
             return "🏈" }
        else if (gameType == "NBA") {
             return "🏀" }
        else if (gameType == "NHL") {
             return "🏒" }
        else if (gameType == "WNBA") {
             return "🏀" }
        else if (gameType == "MLS") {
             return "⚽" }
    }
        Text {
           anchors.fill: parent
            text: isConfigured ? getGameType () : "?"
            color: Kirigami.Theme.textColor
            font.pointSize: 12
            antialiasing : true
            opacity:activeGames ? 1:.40
            Layout.alignment: Qt.AlignVCenter
        }
}
