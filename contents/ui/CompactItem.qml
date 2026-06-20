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
            font.pointSize: 12
            antialiasing : true
            opacity:activeGames ? 1:.40
            leftPadding:6
        }
}
