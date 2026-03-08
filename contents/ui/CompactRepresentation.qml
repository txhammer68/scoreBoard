import QtQuick
import QtQuick.Layouts

Item {
    id: compactRepresentation
    Layout.preferredWidth:36
    Layout.minimumWidth:26
    Layout.maximumWidth:42

    CompactItem {
        id: compactItem
        anchors.fill: parent
    }
}
